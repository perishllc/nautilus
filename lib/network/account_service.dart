import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:ens_dart/ens_dart.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/model/state_block.dart';
import 'package:nautilus_wallet_flutter/network/model/base_request.dart';
import 'package:nautilus_wallet_flutter/network/model/block_types.dart';
import 'package:nautilus_wallet_flutter/network/model/payment/payment_ack.dart';
import 'package:nautilus_wallet_flutter/network/model/payment/payment_memo.dart';
import 'package:nautilus_wallet_flutter/network/model/payment/payment_request.dart';
import 'package:nautilus_wallet_flutter/network/model/request/account_history_request.dart';
import 'package:nautilus_wallet_flutter/network/model/request/account_info_request.dart';
import 'package:nautilus_wallet_flutter/network/model/request/accounts_balances_request.dart';
import 'package:nautilus_wallet_flutter/network/model/request/block_info_request.dart';
import 'package:nautilus_wallet_flutter/network/model/request/receivable_request.dart';
import 'package:nautilus_wallet_flutter/network/model/request/process_request.dart';
import 'package:nautilus_wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:nautilus_wallet_flutter/network/model/request_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_info_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/block_info_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/callback_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/error_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/receivable_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/price_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:nautilus_wallet_flutter/sensitive.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:package_info/package_info.dart';
import 'package:synchronized/synchronized.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import 'model/payment/payment_message.dart';

// Server Connection String
String _BASE_SERVER_ADDRESS = "nautilus.perish.co";
String _SERVER_ADDRESS_WS = "wss://nautilus.perish.co";
String _SERVER_ADDRESS_HTTP = "https://nautilus.perish.co/api";
String _SERVER_ADDRESS_ALERTS = "https://nautilus.perish.co/alerts";

const String _FALLBACK_SERVER_ADDRESS_WS = "wss://app.natrium.io";
const String _FALLBACK_SERVER_ADDRESS_HTTP = "https://app.natrium.io/api";
const String _FALLBACK_SERVER_ADDRESS_ALERTS = "https://app.natrium.io/alerts";

const String _USERNAME_LEASE_ENDPOINT = "https://nano.to/lease";

// UD / ENS:
const String _UD_ENDPOINT = "https://unstoppabledomains.g.alchemy.com/domains/";
const String _ENS_RPC_ENDPOINT = "https://mainnet.infura.io/v3/";
const String _ENS_WSS_ENDPOINT = "wss://mainnet.infura.io/ws/v3/";

late Web3Client _web3Client;
late Ens ens;

Map? decodeJson(dynamic src) {
  return json.decode(src as String) as Map?;
}

// AccountService singleton
class AccountService {
  final Logger log = sl.get<Logger>();

  // For all requests we place them on a queue with expiry to be processed sequentially
  Queue<RequestItem>? _requestQueue;

  // WS Client
  IOWebSocketChannel? _channel;

  // WS connection status
  late bool _isConnected;
  late bool _isConnecting;
  late bool suspended; // When the app explicity closes the connection
  bool fallbackConnected = false;

  // Lock instance for synchronization
  late Lock _lock;

  // Constructor
  AccountService() {
    _requestQueue = Queue();
    _isConnected = false;
    _isConnecting = false;
    suspended = false;
    _lock = Lock();
    initCommunication(unsuspend: true);
  }

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
    final Future<dynamic> delayed = Future.delayed(new Duration(seconds: 3));
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

    // check if the nautilus servers are available
    Socket.connect(_BASE_SERVER_ADDRESS, 80, timeout: Duration(seconds: 3)).then((Socket socket) {
      log.d("Nautilus backend is up");
      fallbackConnected = false;
      socket.destroy();
    }).catchError((error) {
      log.d("Nautilus backend is unreachable");
      // switch to fallback servers:
      _SERVER_ADDRESS_WS = _FALLBACK_SERVER_ADDRESS_WS;
      _SERVER_ADDRESS_HTTP = _FALLBACK_SERVER_ADDRESS_HTTP;
      _SERVER_ADDRESS_ALERTS = _FALLBACK_SERVER_ADDRESS_ALERTS;
      fallbackConnected = true;
    });

    // ENS:
    const String rpcUrl = 'https://mainnet.infura.io/v3/${Sensitive.INFURA_API_KEY}';
    const String wsUrl = 'wss://mainnet.infura.io/ws/v3/${Sensitive.INFURA_API_KEY}';

    _web3Client = Web3Client(rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    ens = Ens(client: _web3Client);

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      _isConnecting = true;
      suspended = false;
      _channel = new IOWebSocketChannel.connect(_SERVER_ADDRESS_WS, headers: {'X-Client-Version': packageInfo.buildNumber});
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
        _requestQueue!.forEach((RequestItem requestItem) {
          requestItem.isProcessing = false;
        });
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
      // log.d("Received $message");
      // Map msg = await compute(decodeJson as FutureOr<Map<dynamic, dynamic>> Function(dynamic), message);
      final Map? msg = await compute(decodeJson, message);
      if (msg == null) {
        throw Exception("Invalid JSON received");
      }
      // Determine response type
      if (msg.containsKey("uuid") ||
          (msg.containsKey("frontier") && msg.containsKey("representative_block")) ||
          msg.containsKey("error") && msg.containsKey("currency")) {
        // Subscribe response
        final SubscribeResponse resp = await compute(subscribeResponseFromJson, msg);
        // Post to callbacks
        EventTaxiImpl.singleton().fire(SubscribeEvent(response: resp));
      } else if (msg.containsKey("currency") && msg.containsKey("price") && msg.containsKey("btc")) {
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
    _requestQueue!.add(new RequestItem(request, fromTransfer: fromTransfer));
  }

  /* Process Queue */
  Future<void> processQueue() async {
    await _lock.synchronized(() async {
      //log.d("Request Queue length ${_requestQueue.length}");
      if (_requestQueue != null && _requestQueue!.isNotEmpty) {
        final RequestItem requestItem = _requestQueue!.first;
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
        } else if ((DateTime.now().difference(requestItem.expireDt!).inSeconds > RequestItem.EXPIRE_TIME_S)) {
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

    for (RequestItem requestItem in _requestQueue!) {
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
    for (RequestItem requestItem in _requestQueue!) {
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
    if (_requestQueue != null && _requestQueue!.isNotEmpty) {
      final List<RequestItem> toRemove = [];
      _requestQueue!.forEach((RequestItem requestItem) {
        if ((requestItem.request is SubscribeRequest || requestItem.request is AccountHistoryRequest || requestItem.request is ReceivableRequest) &&
            !requestItem.isProcessing!) {
          toRemove.add(requestItem);
        }
      });
      toRemove.forEach((RequestItem requestItem) {
        _requestQueue!.remove(requestItem);
      });
    }
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
    _requestQueue!.forEach((RequestItem requestItem) {
      if (requestItem.request is AccountsBalancesRequest) {
        reQueue.add(requestItem);
      }
    });
    _requestQueue!.clear();
    // Re-queue requests
    reQueue.forEach((RequestItem requestItem) {
      requestItem.isProcessing = false;
      _requestQueue!.add(requestItem);
    });
  }

  Queue<RequestItem>? get requestQueue => _requestQueue;

  // HTTP API

  Future<dynamic> makeHttpRequest(BaseRequest request) async {
    final http.Response response =
        await http.post(Uri.parse(_SERVER_ADDRESS_HTTP), headers: {'Content-type': 'application/json'}, body: json.encode(request.toJson()));

    if (response.statusCode != 200) {
      return null;
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    if (decoded.containsKey("error")) {
      return ErrorResponse.fromJson(decoded as Map<String, dynamic>);
    }

    return decoded;
  }

  Future<String?> checkUnstoppableDomain(String domain) async {
    final http.Response response =
        await http.get(Uri.parse(_UD_ENDPOINT + domain), headers: {'Content-type': 'application/json', 'Authorization': 'Bearer ${Sensitive.UD_API_KEY}'});

    if (response.statusCode != 200) {
      return null;
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    String? address;

    if (decoded != null && decoded["records"] != null && decoded["records"]["crypto.NANO.address"] != null) {
      address = decoded["records"]["crypto.NANO.address"] as String?;
      if (NanoAccounts.isValid(NanoAccountType.NANO, address!)) {
        return address;
      }
    }

    return null;
  }

  Future<String?> checkENSDomain(String domain) async {
    final String pubKey = await ens.withName(domain).getCoinAddress(CoinType.NANO);
    if (pubKey.isEmpty) {
      return null;
    } else {
      final String address = NanoAccounts.createAccount(NanoAccountType.NANO, pubKey);
      // Validating address
      if (NanoAccounts.isValid(NanoAccountType.NANO, address)) {
        return address;
      } else {
        return null;
      }
    }
  }

  Future<dynamic> checkUsernameAvailability(String username) async {
    final http.Response response = await http.get(Uri.parse("$_USERNAME_LEASE_ENDPOINT/$username"), headers: {"Accept": "application/json"});
    if (response.statusCode != 200) {
      return null;
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    if (decoded.containsKey("error")) {
      return ErrorResponse.fromJson(decoded as Map<String, dynamic>);
    }

    return decoded;
  }

  // TODO: why is this needed?
  Future<void> dummyAPICall() async {
    await http.get(Uri.parse(_SERVER_ADDRESS_HTTP), headers: {"Accept": "application/json"});
  }

  Future<dynamic> checkUsernameUrl(String URL) async {
    final http.Response response = await http.get(Uri.parse(URL), headers: {"Accept": "application/json"});
    if (response.statusCode != 200) {
      return null;
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
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

  Future<ReceivableResponse> getReceivable(String? account, int count, {String? threshold, bool includeActive = false}) async {
    threshold = threshold ?? BigInt.from(10).pow(24).toString();

    final ReceivableRequest request = ReceivableRequest(account: account, count: count, threshold: threshold, includeActive: includeActive);
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

  // request money from an account:
  /*Future<PaymentResponse> */ Future<void> requestPayment(
      String? account, String? amountRaw, String? requestingAccount, String requestSignature, String requestNonce, String? memoEnc, String localUuid) async {
    final PaymentRequest request = PaymentRequest(
        account: account,
        amount_raw: amountRaw,
        requesting_account: requestingAccount,
        request_signature: requestSignature,
        request_nonce: requestNonce,
        memo_enc: memoEnc,
        local_uuid: localUuid);

    // queueRequest(request);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
  }

  // send payment record (memo) to an account:
  Future<void> sendTXMemo(String? account, String? requestingAccount, String? amountRaw, String requestSignature, String requestNonce, String memoEnc,
      String? block, String localUuid) async {
    final PaymentMemo request = PaymentMemo(
        account: account,
        requesting_account: requestingAccount,
        request_signature: requestSignature,
        request_nonce: requestNonce,
        memo_enc: memoEnc,
        block: block,
        local_uuid: localUuid);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
  }

  Future<void> sendTXMessage(String? account, String? requestingAccount, String requestSignature, String requestNonce, String memoEnc, String localUuid) async {
    final PaymentMessage request = PaymentMessage(
        account: account,
        requesting_account: requestingAccount,
        request_signature: requestSignature,
        request_nonce: requestNonce,
        memo_enc: memoEnc,
        local_uuid: localUuid);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
  }

  Future<void> requestACK(String? requestUuid, String? account, String? requestingAccount) async {
    final PaymentACK request = PaymentACK(uuid: requestUuid, account: account, requesting_account: requestingAccount);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
  }
  
  Future<AccountsBalancesResponse> requestAccountsBalances(List<String> accounts) async {
    final AccountsBalancesRequest request = AccountsBalancesRequest(accounts: accounts);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    return AccountsBalancesResponse.fromJson(response);
  }

  Future<ProcessResponse> requestProcess(ProcessRequest request) async {
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    final ProcessResponse item = ProcessResponse.fromJson(response as Map<String, dynamic>);
    return item;
  }

  Future<ProcessResponse> requestReceive(String? representative, String? previous, String? balance, String? link, String? account, String? privKey) async {
    final StateBlock receiveBlock = StateBlock(
        subtype: BlockTypes.RECEIVE, previous: previous, representative: representative, balance: balance, link: link, account: account, privKey: privKey);

    final BlockInfoItem previousInfo = await requestBlockInfo(previous);
    final StateBlock previousBlock = StateBlock.fromJson(json.decode(previousInfo.contents!) as Map<String, dynamic>);

    // Update data on our next receivable request
    receiveBlock.representative = previousBlock.representative;
    receiveBlock.setBalance(previousBlock.balance);
    await receiveBlock.sign(privKey);

    // Process
    final ProcessRequest processRequest = ProcessRequest(block: json.encode(receiveBlock.toJson()), subType: BlockTypes.RECEIVE);

    return requestProcess(processRequest);
  }

  Future<ProcessResponse> requestSend(String? representative, String? previous, String? sendAmount, String? link, String? account, String? privKey,
      {bool max = false}) async {
    final StateBlock sendBlock = StateBlock(
        subtype: BlockTypes.SEND,
        previous: previous,
        representative: representative,
        balance: max ? "0" : sendAmount,
        link: link,
        account: account,
        privKey: privKey);

    final BlockInfoItem previousInfo = await requestBlockInfo(previous);
    final StateBlock previousBlock = StateBlock.fromJson(json.decode(previousInfo.contents!) as Map<String, dynamic>);

    // Update data on our next receivable request
    sendBlock.representative = previousBlock.representative;
    sendBlock.setBalance(previousBlock.balance);
    await sendBlock.sign(privKey);

    // Process
    final ProcessRequest processRequest = ProcessRequest(block: json.encode(sendBlock.toJson()), subType: BlockTypes.SEND);

    return requestProcess(processRequest);
  }

  Future<ProcessResponse> requestOpen(String? balance, String? link, String? account, String? privKey, {String? representative}) async {
    representative = representative ?? await sl.get<SharedPrefsUtil>().getRepresentative();
    final StateBlock openBlock =
        StateBlock(subtype: BlockTypes.OPEN, previous: "0", representative: representative, balance: balance, link: link, account: account, privKey: privKey);

    // Sign
    await openBlock.sign(privKey);

    // Process
    final ProcessRequest processRequest = ProcessRequest(block: json.encode(openBlock.toJson()), subType: BlockTypes.OPEN);

    return requestProcess(processRequest);
  }

  Future<ProcessResponse> requestChange(String? account, String? representative, String? previous, String balance, String privKey) async {
    final StateBlock chgBlock = StateBlock(
        subtype: BlockTypes.CHANGE,
        previous: previous,
        representative: representative,
        balance: balance,
        link: "0000000000000000000000000000000000000000000000000000000000000000",
        account: account,
        privKey: privKey);

    final BlockInfoItem previousInfo = await requestBlockInfo(previous);
    final StateBlock previousBlock = StateBlock.fromJson(json.decode(previousInfo.contents!) as Map<String, dynamic>);

    // Update data on our next receivable request
    chgBlock.setBalance(previousBlock.balance);
    await chgBlock.sign(privKey);

    // Process
    final ProcessRequest processRequest = ProcessRequest(block: json.encode(chgBlock.toJson()), subType: BlockTypes.CHANGE);

    return requestProcess(processRequest);
  }

  Future<AlertResponseItem?> getAlert(String lang) async {
    final http.Response response = await http.get(Uri.parse("$_SERVER_ADDRESS_ALERTS/$lang"), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      List<AlertResponseItem> alerts;
      alerts = (json.decode(response.body) as List).map((i) => AlertResponseItem.fromJson(i as Map<String, dynamic>)).toList();
      if (alerts.isNotEmpty) {
        if (alerts[0].active!) {
          return alerts[0];
        }
      }
    }
    return null;
  }
}
