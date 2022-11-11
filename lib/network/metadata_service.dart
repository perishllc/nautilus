import 'dart:async';
import 'dart:convert';

import 'package:ens_dart/ens_dart.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/network/model/base_request.dart';
import 'package:nautilus_wallet_flutter/network/model/payment/payment_ack.dart';
import 'package:nautilus_wallet_flutter/network/model/payment/payment_memo.dart';
import 'package:nautilus_wallet_flutter/network/model/payment/payment_message.dart';
import 'package:nautilus_wallet_flutter/network/model/payment/payment_request.dart';
import 'package:nautilus_wallet_flutter/network/model/response/error_response.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:web3dart/web3dart.dart';

// MetadataService singleton
class MetadataService {
  // Constructor
  MetadataService() {
    initCommunication();
  }

  // Server Connection Strings
  static String BASE_SERVER_ADDRESS = "nautilus.perish.co";
  // static const String DEV_SERVER_ADDRESS = "node-local.perish.co:5076";
  static const String DEV_SERVER_ADDRESS = "35.139.167.170:5076";
  static String HTTP_PROTO = "https://";
  static String WS_PROTO = "wss://";

  static String RPC_URL = "nautilus.perish.co";
  static String WS_URL = "nautilus.perish.co";

  // ignore_for_file: non_constant_identifier_names
  static String SERVER_ADDRESS_WS = "$WS_PROTO$BASE_SERVER_ADDRESS";
  static String SERVER_ADDRESS_HTTP = "$HTTP_PROTO$BASE_SERVER_ADDRESS/api";
  static String SERVER_ADDRESS_ALERTS = "$HTTP_PROTO$BASE_SERVER_ADDRESS/alerts";
  static String SERVER_ADDRESS_FUNDING = "$HTTP_PROTO$BASE_SERVER_ADDRESS/funding";
  static String SERVER_ADDRESS_GIFT = "$HTTP_PROTO$BASE_SERVER_ADDRESS/gift";

  // auth:
  static String AUTH_SERVER = "https://auth.perish.co";

  static const String NANO_TO_USERNAME_LEASE_ENDPOINT = "https://api.nano.to/";
  static const String NANO_TO_KNOWN_ENDPOINT = "https://nano.to/known.json";
  static const String XNO_TO_KNOWN_ENDPOINT = "https://xno.to/known.json";

  // UD / ENS:
  static const String UD_ENDPOINT = "https://unstoppabledomains.g.alchemy.com/domains/";
  static const String ENS_RPC_ENDPOINT = "https://mainnet.infura.io/v3/";
  static const String ENS_WSS_ENDPOINT = "wss://mainnet.infura.io/ws/v3/";
  // UD / ENS:
  static late Web3Client _web3Client;
  static late Ens ens;

  final Logger log = sl.get<Logger>();

  Future<void> initCommunication() async {

  }

  // HTTP API

  Future<dynamic> makeHttpRequest(BaseRequest request) async {
    final http.Response response =
        await http.post(Uri.parse(SERVER_ADDRESS_HTTP), headers: {'Content-type': 'application/json'}, body: json.encode(request.toJson()));

    if (response.statusCode != 200) {
      return null;
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    if (decoded.containsKey("error")) {
      return ErrorResponse.fromJson(decoded as Map<String, dynamic>);
    }

    return decoded;
  }


  // request money from an account:
  Future<void> requestPayment(
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
  Future<void> sendTXMemo(String account, String requestingAccount, String? amountRaw, String requestSignature, String requestNonce, String memoEnc,
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
      throw Exception("Received error ${response.error} ${response.details}");
    }
  }

  Future<void> sendTXMessage(String account, String requestingAccount, String requestSignature, String requestNonce, String memoEnc, String localUuid) async {
    final PaymentMessage request = PaymentMessage(
        account: account,
        requesting_account: requestingAccount,
        request_signature: requestSignature,
        request_nonce: requestNonce,
        memo_enc: memoEnc,
        local_uuid: localUuid);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error} ${response.details}");
    }
  }

  Future<void> requestACK(String? requestUuid, String? account, String? requestingAccount) async {
    final PaymentACK request = PaymentACK(uuid: requestUuid, account: account, requesting_account: requestingAccount);
    final dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error} ${response.details}");
    }
  }

}
