// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:synchronized/synchronized.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/node.dart';
import 'package:wallet_flutter/model/db/work_source.dart';
import 'package:wallet_flutter/model/state_block.dart';
import 'package:wallet_flutter/network/model/base_request.dart';
import 'package:wallet_flutter/network/model/block_types.dart';
import 'package:wallet_flutter/network/model/request/account_history_request.dart';
import 'package:wallet_flutter/network/model/request/account_info_request.dart';
import 'package:wallet_flutter/network/model/request/accounts_balances_request.dart';
import 'package:wallet_flutter/network/model/request/auth_reply_request.dart';
import 'package:wallet_flutter/network/model/request/block_info_request.dart';
import 'package:wallet_flutter/network/model/request/handoff_reply_request.dart';
import 'package:wallet_flutter/network/model/request/process_request.dart';
import 'package:wallet_flutter/network/model/request/receivable_request.dart';
import 'package:wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:wallet_flutter/network/model/request_item.dart';
import 'package:wallet_flutter/network/model/response/account_history_response.dart';
import 'package:wallet_flutter/network/model/response/account_info_response.dart';
import 'package:wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:wallet_flutter/network/model/response/block_info_item.dart';
import 'package:wallet_flutter/network/model/response/callback_response.dart';
import 'package:wallet_flutter/network/model/response/error_response.dart';
import 'package:wallet_flutter/network/model/response/handoff_response.dart';
import 'package:wallet_flutter/network/model/response/price_response.dart';
import 'package:wallet_flutter/network/model/response/process_response.dart';
import 'package:wallet_flutter/network/model/response/receivable_response.dart';
import 'package:wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:web_socket_channel/io.dart';

// late Web3Client _web3Client;
// late Ens ens;

Map? decodeJson(dynamic src) {
  return json.decode(src as String) as Map?;
}

// overriden!:
String HTTP_URL = "";
String WS_URL = "";

// AccountService singleton
class AccountService {
  // Constructor
  AccountService() {
    _requestQueue = Queue();
    _isConnected = false;
    _isConnecting = false;
    suspended = false;
    _lock = Lock();

    () async {
      await updateNode();
    }();
  }

  Future<void> initUrls() async {
    if (HTTP_URL != "") return;
    try {
      final Node node = await sl.get<DBHelper>().getSelectedNode();
      HTTP_URL = node.http_url;
      WS_URL = node.ws_url;
    } catch (e) {
      log.e(e);
    }
    if (HTTP_URL == "" || WS_URL == "") {
      HTTP_URL = "https://nautilus.perish.co/api";
      WS_URL = "wss://nautilus.perish.co";
    }
  }

  Future<void> updateNode() async {
    try {
      final Node node = await sl.get<DBHelper>().getSelectedNode();
      HTTP_URL = node.http_url;
      WS_URL = node.ws_url;
    } catch (e) {
      log.e(e);
    }
    if (HTTP_URL == "" || WS_URL == "") {
      HTTP_URL = "https://nautilus.perish.co/api";
      WS_URL = "wss://nautilus.perish.co";
    }

    // reset vars:
    _isConnected = false;
    _isConnecting = false;
    suspended = false;
    initCommunication(unsuspend: true);
  }

  // Server Connection Strings
  // static const String DEV_SERVER_ADDRESS = "node-local.perish.co:5076";
  static const String DEV_SERVER_ADDRESS = "35.139.167.170:5076";

  final Logger log = sl.get<Logger>();

  // For all requests we place them on a queue with expiry to be processed sequentially
  Queue<RequestItem<dynamic>>? _requestQueue;

  // WS Client
  IOWebSocketChannel? _channel;

  // WS connection status
  late bool _isConnected;
  late bool _isConnecting;
  late bool suspended; // When the app explicity closes the connection
  bool fallbackConnected = false;

  // Lock instance for synchronization
  late Lock _lock;

  // Re-connect handling
  bool _isInRetryState = false;
  StreamSubscription<dynamic>? reconnectStream;

  /// Retry up to once per 3 seconds
  Future<void> reconnectToService() async {
    if (_isInRetryState) {
      return;
    } else if (reconnectStream != null) {
      reconnectStream!.cancel();
    }
    _isInRetryState = true;
    log.d("Retrying connection in 3 seconds...");
    final Future<dynamic> delayed = Future<dynamic>.delayed(const Duration(seconds: 3));
    delayed.then((_) {
      return true;
    });
    reconnectStream = delayed.asStream().listen((_) {
      log.d("Attempting connection to service");
      initCommunication(unsuspend: true);
      _isInRetryState = false;
    });
  }

  // Connect to server
  Future<void> initCommunication({bool unsuspend = false}) async {
    if (_isConnected || _isConnecting) {
      return;
    } else if (suspended && !unsuspend) {
      return;
    } else if (!unsuspend) {
      reconnectToService();
      return;
    }
    _isConnecting = true;

    // DEV SERVER:
    // if (kDebugMode) {
    //   HTTP_PROTO = "http://";
    //   WS_PROTO = "ws://";
    //   BASE_SERVER_ADDRESS = DEV_SERVER_ADDRESS;
    //   log.d("CONNECTED TO DEV SERVER");
    // }

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      _isConnecting = true;
      suspended = false;
      _channel = IOWebSocketChannel.connect(WS_URL, headers: {'X-Client-Version': packageInfo.buildNumber});
      log.d("Connected to service");
      _isConnecting = false;
      _isConnected = true;
      EventTaxiImpl.singleton().fire(ConnStatusEvent(status: ConnectionStatus.CONNECTED));
      _channel!.stream.listen(_onMessageReceived, onDone: connectionClosed, onError: connectionClosedError);
    } catch (e) {
      log.e("Error from service ${e.toString()}", e);
      _isConnected = false;
      _isConnecting = false;
      EventTaxiImpl.singleton().fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
    }
  }

  // Connection closed (normally)
  void connectionClosed() {
    _isConnected = false;
    _isConnecting = false;
    clearQueue();
    log.d("disconnected from service");
    // Send disconnected message
    EventTaxiImpl.singleton().fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
  }

  // Connection closed (with error)
  void connectionClosedError(e) {
    _isConnected = false;
    _isConnecting = false;
    clearQueue();
    log.w("disconnected from service with error ${e.toString()}");
    // Send disconnected message
    EventTaxiImpl.singleton().fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
  }

  // are we connected?

  Future<bool> isConnected() async {
    final ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.bluetooth && connectivityResult != ConnectivityResult.none) {
      // I am connected to some network, make sure there is actually a net connection.
      return InternetConnectionChecker().hasConnection;
    }
    return false;
  }

  // Close connection
  void reset({bool suspend = false}) {
    suspended = suspend;
    if (_channel != null) {
      _channel!.sink.close();
      _isConnected = false;
      _isConnecting = false;
    }
  }

  // Send message
  Future<void> _send(String message) async {
    bool reset = false;
    try {
      if (_channel != null && _isConnected) {
        _channel!.sink.add(message);
      } else {
        reset = true; // Re-establish connection
      }
    } catch (e) {
      reset = true;
    } finally {
      if (reset) {
        // Reset queue item statuses
        for (final RequestItem<dynamic> requestItem in _requestQueue!) {
          requestItem.isProcessing = false;
        }
        if (!_isConnecting && !suspended) {
          initCommunication();
        }
      }
    }
  }

  Future<void> _onMessageReceived(dynamic message) async {
    if (suspended) {
      return;
    }
    await _lock.synchronized(() async {
      _isConnected = true;
      _isConnecting = false;
      log.v("Received $message");
      final Map? msg = await compute(decodeJson, message);
      if (msg == null) {
        throw Exception("Invalid JSON received");
      }
      // Determine response type
      if (msg.containsKey("uuid") || (msg.containsKey("frontier") && msg.containsKey("representative_block"))) {
        // Subscribe response
        final SubscribeResponse resp = await compute(subscribeResponseFromJson, msg);
        // Post to callbacks
        EventTaxiImpl.singleton().fire(SubscribeEvent(response: resp));
      } else if (msg.containsKey("currency") && msg.containsKey("price")) {
        // Price info sent from server
        final PriceResponse resp = PriceResponse.fromJson(msg as Map<String, dynamic>);
        EventTaxiImpl.singleton().fire(PriceEvent(response: resp));
      } else if (msg.containsKey("block") && msg.containsKey("hash") && msg.containsKey("account")) {
        final CallbackResponse resp = await compute(callbackResponseFromJson, msg);
        EventTaxiImpl.singleton().fire(CallbackEvent(response: resp));
      } else if (msg.containsKey("error")) {
        final ErrorResponse resp = ErrorResponse.fromJson(msg as Map<String, dynamic>);
        EventTaxiImpl.singleton().fire(ErrorEvent(response: resp));
      }
      return;
    });
  }

  /* Send Request */
  Future<void> sendRequest(BaseRequest request) async {
    // We don't care about order or server response in these requests
    //log.d("sending ${json.encode(request.toJson())}");
    _send(await compute(encodeRequestItem, request));
  }

  /* Enqueue Request */
  void queueRequest(BaseRequest request, {bool fromTransfer = false}) {
    //log.d("request ${json.encode(request.toJson())}, q length: ${_requestQueue.length}");
    _requestQueue!.add(RequestItem(request, fromTransfer: fromTransfer));
  }

  /* Process Queue */
  Future<void> processQueue() async {
    await _lock.synchronized(() async {
      //log.d("Request Queue length ${_requestQueue.length}");
      if (_requestQueue != null && _requestQueue!.isNotEmpty) {
        final RequestItem<dynamic> requestItem = _requestQueue!.first;
        if (!requestItem.isProcessing!) {
          if (!_isConnected && !_isConnecting && !suspended) {
            initCommunication();
            return;
          } else if (suspended) {
            return;
          }
          requestItem.isProcessing = true;
          final String requestJson = await compute(encodeRequestItem, requestItem.request);
          //log.d("Sending: $requestJson");
          await _send(requestJson);
        } else if (DateTime.now().difference(requestItem.expireDt!).inSeconds > RequestItem.EXPIRE_TIME_S) {
          pop();
          processQueue();
        }
      }
    });
  }

  // Queue Utilities
  bool queueContainsRequestWithHash(String hash) {
    // if (_requestQueue != null || _requestQueue!.length == 0) {
    //   return false;
    // }
    // NATRIUM fix:
    if (_requestQueue == null || _requestQueue!.isEmpty) {
      return false;
    }

    for (final RequestItem requestItem in _requestQueue!) {
      if (requestItem.request is ProcessRequest) {
        final ProcessRequest request = requestItem.request as ProcessRequest;
        final StateBlock block = StateBlock.fromJson(json.decode(request.block!) as Map<String, dynamic>);
        if (block.hash == hash) {
          return true;
        }
      }
    }
    return false;
  }

  bool queueContainsOpenBlock() {
    // NATRIUM fix:
    if (_requestQueue == null || _requestQueue!.isEmpty) {
      return false;
    }
    for (final RequestItem requestItem in _requestQueue!) {
      if (requestItem.request is ProcessRequest) {
        final ProcessRequest request = requestItem.request as ProcessRequest;
        final StateBlock block = StateBlock.fromJson(json.decode(request.block!) as Map<String, dynamic>);
        if (BigInt.tryParse(block.previous!) == BigInt.zero) {
          return true;
        }
      }
    }
    return false;
  }

  void removeSubscribeHistoryReceivableFromQueue() {
    if (_requestQueue == null || _requestQueue!.isEmpty) {
      return;
    }
    final List<RequestItem<dynamic>> toRemove = [];
    for (final RequestItem<dynamic> requestItem in _requestQueue!) {
      if ((requestItem.request is SubscribeRequest ||
              requestItem.request is AccountHistoryRequest ||
              requestItem.request is ReceivableRequest) &&
          !requestItem.isProcessing!) {
        toRemove.add(requestItem);
      }
    }
    toRemove.forEach(_requestQueue!.remove);
  }

  RequestItem? pop() {
    return _requestQueue!.isNotEmpty ? _requestQueue!.removeFirst() : null;
  }

  RequestItem? peek() {
    return _requestQueue!.isNotEmpty ? _requestQueue!.first : null;
  }

  /// Clear entire queue, except for AccountsBalancesRequest
  void clearQueue() {
    final List<RequestItem> reQueue = [];
    for (final RequestItem requestItem in _requestQueue!) {
      if (requestItem.request is AccountsBalancesRequest) {
        reQueue.add(requestItem);
      }
    }
    _requestQueue!.clear();
    // Re-queue requests
    for (final RequestItem requestItem in reQueue) {
      requestItem.isProcessing = false;
      _requestQueue!.add(requestItem);
    }
  }

  Queue<RequestItem>? get requestQueue => _requestQueue;

  // HTTP API

  Future<dynamic> makeHttpRequest(BaseRequest request) async {
    await initUrls();
    final http.Response response = await http.post(
      Uri.parse(HTTP_URL),
      headers: {'Content-type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      return null;
    }
    final Map<dynamic, dynamic> decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    if (decoded.containsKey("error")) {
      return ErrorResponse.fromJson(decoded as Map<String, dynamic>);
    }

    return decoded;
  }

  Future<AccountInfoResponse> getAccountInfo(String account) async {
    final AccountInfoRequest request = AccountInfoRequest(account: account);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      if (response.error == "Account not found") {
        return AccountInfoResponse(unopened: true);
      }
      throw Exception("Received error ${response.error}");
    }
    final AccountInfoResponse infoResponse = AccountInfoResponse.fromJson(response as Map<String, dynamic>);
    return infoResponse;
  }

  Future<ReceivableResponse> getReceivable(String? account, int count,
      {String? threshold, bool includeActive = false}) async {
    threshold = threshold ?? BigInt.from(10).pow(24).toString();

    final ReceivableRequest request =
        ReceivableRequest(account: account, count: count, threshold: threshold, includeActive: includeActive);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    ReceivableResponse pr;
    if (response["blocks"] == "") {
      pr = ReceivableResponse(blocks: {});
    } else {
      pr = ReceivableResponse.fromJson(response as Map<String, dynamic>);
    }
    return pr;
  }

  Future<BlockInfoItem> requestBlockInfo(String? hash) async {
    final BlockInfoRequest request = BlockInfoRequest(hash: hash);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    final BlockInfoItem item = BlockInfoItem.fromJson(response as Map<String, dynamic>);
    return item;
  }

  Future<AccountHistoryResponse> requestAccountHistory(String? account, {int count = 1, bool raw = false}) async {
    final AccountHistoryRequest request = AccountHistoryRequest(account: account, count: count, raw: raw);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }

    if (response == null) {
      throw Exception("Received null for history");
    }

    if (response["history"] == "") {
      response["history"] = [];
    }
    return AccountHistoryResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<AccountsBalancesResponse> requestAccountsBalances(List<String> accounts) async {
    final AccountsBalancesRequest request = AccountsBalancesRequest(accounts: accounts);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error} ${response.details}");
    }
    return AccountsBalancesResponse.fromJson(response);
  }

  // Future<dynamic> createSwapToXMR({
  //   String? amountRaw,
  //   String? xmrAddress,
  // }) async {
  //   final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   final String runningVersion = packageInfo.version;
  //   final http.Response response = await http.post(Uri.parse("https://api.nanswap.com/v1/create-order"),
  //       headers: {"Accept": "application/json", "nanswap-api-key": dotenv.env["NANSWAP_API_KEY"]!},
  //       body: json.encode(
  //         <String, String?>{
  //           "from": "XNO",
  //           "to": "XMR",
  //           "amount": amountRaw,
  //           "toAddress": xmrAddress,
  //         },
  //       ));
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     return {"error": "something went wrong: ${response.body}"};
  //   }
  // }

  // Future<HandoffResponse?> requestHandoff(String URI, HandoffReplyRequest request) async {
  //   final http.Response response = await http.post(Uri.parse(URI), headers: {'Content-type': 'application/json'}, body: json.encode(request.toJson()));

  //   if (response.statusCode != 200) {
  //     return null;
  //   }
  //   final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;

  //   if (decoded.containsKey("error")) {
  //     final ErrorResponse err = ErrorResponse.fromJson(decoded as Map<String, dynamic>);
  //     throw Exception("Received error ${err.error} ${err.details}");
  //   }
  //   final HandoffResponse item = HandoffResponse.fromJson(response as Map<String, dynamic>);
  //   return item;
  // }

  Future<HandoffResponse> requestHandoffHTTP(
    String URI,
    String? representative,
    String? previous,
    String? sendAmount,
    String? link,
    String? account,
    String? privKey, {
    bool max = false,
    String? work,
    String? label,
    String? message,
    Map<String, String?>? metadata,
  }) async {
    final StateBlock sendBlock = StateBlock(
        subtype: BlockTypes.SEND,
        previous: previous,
        representative: representative,
        balance: max ? "0" : sendAmount,
        link: link,
        work: work,
        account: account,
        privKey: privKey);

    final BlockInfoItem previousInfo = await requestBlockInfo(previous);
    final StateBlock previousBlock = StateBlock.fromJson(json.decode(previousInfo.contents!) as Map<String, dynamic>);

    // Update data on our next receivable request
    sendBlock.representative = previousBlock.representative;
    sendBlock.setBalance(previousBlock.balance);
    await sendBlock.sign(privKey);

    // Process
    final HandoffReplyRequest handoffReplyRequest =
        HandoffReplyRequest(block: sendBlock, label: label, message: message, metadata: metadata);

    // return requestHandoff(handoffReplyRequest);

    final http.Response response = await http.post(Uri.parse(URI),
        headers: {'Content-type': 'application/json'}, body: json.encode(handoffReplyRequest.toJson()));

    if (response.statusCode != 200) {
      throw Exception("Received error ${response.statusCode}");
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;

    if (decoded.containsKey("error")) {
      final ErrorResponse err = ErrorResponse.fromJson(decoded as Map<String, dynamic>);
      throw Exception("Received error ${err.error} ${err.details}");
    }
    final HandoffResponse item = HandoffResponse.fromJson(decoded as Map<String, dynamic>);
    return item;
  }

  Future<HandoffResponse> requestAuthHTTP(String URI, String account, String signature, String signed, String formatted,
      {String? message, String? label}) async {
    // Process
    final AuthReplyRequest authReplyRequest = AuthReplyRequest(
      account: account,
      signature: signature,
      signed: signed,
      formatted: formatted,
      message: message,
      label: label,
    );

    // return requestHandoff(handoffReplyRequest);

    final http.Response response = await http.post(Uri.parse(URI),
        headers: {'Content-type': 'application/json'}, body: json.encode(authReplyRequest.toJson()));

    if (response.statusCode != 200) {
      throw Exception("Received error ${response.statusCode}");
    }
    try {
      final Map<dynamic, dynamic> decoded = json.decode(response.body) as Map<dynamic, dynamic>;

      if (decoded.containsKey("error")) {
        final ErrorResponse err = ErrorResponse.fromJson(decoded as Map<String, dynamic>);
        throw Exception("Received error ${err.error} ${err.details}");
      }
      final HandoffResponse item = HandoffResponse.fromJson(decoded as Map<String, dynamic>);
      return item;
    } catch (e) {
      throw Exception("Received error ${e}");
    }
  }

  // Future<HandoffWorkResponse> requestWork(String url, String hash) async {
  // }

  // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  // NEEDS PoW
  // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  Future<String?> requestWork(String url, String hash) async {
    return http
        .post(Uri.parse(url), headers: {'Content-type': 'application/json'}, body: json.encode({"hash": hash}))
        .then((http.Response response) {
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
        if (decoded.containsKey("error")) {
          final ErrorResponse err = ErrorResponse.fromJson(decoded);
          throw Exception("Received error ${err.error} ${err.details}");
        }
        return decoded["work"] as String?;
      } else {
        throw Exception("Received error ${response.statusCode}");
      }
    });
  }

  Future<ProcessResponse> requestProcess(ProcessRequest request) async {
    // check if the request needs PoW:
    try {
      final StateBlock requestBlock = StateBlock.fromJson(json.decode(request.block!) as Map<String, dynamic>);
      final String subtype = request.subtype ?? BlockTypes.SEND;
      String? workHash = requestBlock.previous;
      if (requestBlock.previous == "0" ||
          requestBlock.previous == "0000000000000000000000000000000000000000000000000000000000000000") {
        workHash = NanoUtil.addressToPublicKey(requestBlock.account!);
      }

      if (requestBlock.work == null && workHash != null) {
        // needs work:
        final WorkSource ws = await sl.get<DBHelper>().getSelectedWorkSource();

        switch (ws.type) {
          case WorkSourceTypes.NODE:
            // rely on the node to handle PoW:
            break;
          case WorkSourceTypes.LOCAL:
            // TODO: Local work
            break;
          case WorkSourceTypes.URL:
            final String? work = await requestWork(ws.url!, workHash);
            requestBlock.work = work;
            break;
        }
      }

      requestBlock.hash = null;

      request.block = json.encode(requestBlock.toJson());
    } catch (e) {
      throw Exception("Error trying to add PoW to block: $e");
    }

    // print("request: ${json.encode(request.toJson())}");

    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error} ${response.details}");
    }
    final ProcessResponse item = ProcessResponse.fromJson(response as Map<String, dynamic>);
    return item;
  }

  // Future<ProcessResponse> requestProcess(ProcessRequest request) async {
  //   final dynamic response = await makeHttpRequest(request);
  //   if (response is ErrorResponse) {
  //     throw Exception("Received error ${response.error} ${response.details}");
  //   }
  //   final ProcessResponse item = ProcessResponse.fromJson(response as Map<String, dynamic>);
  //   return item;
  // }

  Future<ProcessResponse> requestReceive(
      String? representative, String? previous, String? balance, String? link, String? account, String? privKey) async {
    final StateBlock receiveBlock = StateBlock(
      subtype: BlockTypes.RECEIVE,
      previous: previous,
      representative: representative,
      balance: balance,
      link: link,
      account: account,
      privKey: privKey,
    );

    // checked elsewhere and not needed here, I think:
    // // db query to check if username for this address exists:
    // try {
    //   User? user = await sl.get<DBHelper>().getUserWithAddress(account!);
    //   bool shouldUpdate = false;
    //   if (user != null && user.type == UserTypes.ONCHAIN) {
    //     int weekAgo = 0;
    //     if (user.last_updated == null || user.last_updated! < weekAgo) {
    //       // user is out of date, update:
    //       shouldUpdate = true;
    //     }
    //   } else if (user == null) {
    //     shouldUpdate = true;
    //   }

    //   if (shouldUpdate) {
    //     // check for username here:
    //   }
    // } catch (error) {
    //   log.e("Error processing receive username $error");
    // }

    final BlockInfoItem previousInfo = await requestBlockInfo(previous);
    final StateBlock previousBlock = StateBlock.fromJson(json.decode(previousInfo.contents!) as Map<String, dynamic>);

    // Update data on our next receivable request
    receiveBlock.representative = previousBlock.representative;
    receiveBlock.setBalance(previousBlock.balance);
    await receiveBlock.sign(privKey);

    // Process
    final ProcessRequest processRequest =
        ProcessRequest(block: json.encode(receiveBlock.toJson()), subtype: BlockTypes.RECEIVE);

    return requestProcess(processRequest);
  }

  Future<ProcessResponse> requestSend(
      String? representative, String? previous, String? sendAmount, String? link, String? account, String? privKey,
      {bool max = false}) async {
    final StateBlock sendBlock = StateBlock(
      subtype: BlockTypes.SEND,
      previous: previous,
      representative: representative,
      balance: max ? "0" : sendAmount,
      link: link,
      account: account,
      privKey: privKey,
    );

    final BlockInfoItem previousInfo = await requestBlockInfo(previous);
    final StateBlock previousBlock = StateBlock.fromJson(json.decode(previousInfo.contents!) as Map<String, dynamic>);

    // Update data on our next receivable request
    sendBlock.representative = previousBlock.representative;
    sendBlock.setBalance(previousBlock.balance);
    await sendBlock.sign(privKey);

    // Process
    final ProcessRequest processRequest = ProcessRequest(
      block: json.encode(sendBlock.toJson()),
      subtype: BlockTypes.SEND,
    );

    return requestProcess(processRequest);
  }

  Future<ProcessResponse> requestOpen(String? balance, String? link, String? account, String? privKey,
      {String? representative}) async {
    representative = representative ?? await sl.get<SharedPrefsUtil>().getRepresentative();
    final StateBlock openBlock = StateBlock(
      subtype: BlockTypes.OPEN,
      previous: "0",
      representative: representative,
      balance: balance,
      link: link,
      account: account,
      privKey: privKey,
    );

    // Sign
    await openBlock.sign(privKey);

    // Process
    final ProcessRequest processRequest = ProcessRequest(
      block: json.encode(openBlock.toJson()),
      subtype: BlockTypes.OPEN,
    );

    return requestProcess(processRequest);
  }

  Future<ProcessResponse> requestChange(
      String? account, String? representative, String? previous, String balance, String privKey) async {
    final StateBlock chgBlock = StateBlock(
      subtype: BlockTypes.CHANGE,
      previous: previous,
      representative: representative,
      balance: balance,
      link: "0000000000000000000000000000000000000000000000000000000000000000",
      account: account,
      privKey: privKey,
    );

    final BlockInfoItem previousInfo = await requestBlockInfo(previous);
    final StateBlock previousBlock = StateBlock.fromJson(json.decode(previousInfo.contents!) as Map<String, dynamic>);

    // Update data on our next receivable request
    chgBlock.setBalance(previousBlock.balance);
    await chgBlock.sign(privKey);

    // Process
    final ProcessRequest processRequest =
        ProcessRequest(block: json.encode(chgBlock.toJson()), subtype: BlockTypes.CHANGE);

    return requestProcess(processRequest);
  }
}
