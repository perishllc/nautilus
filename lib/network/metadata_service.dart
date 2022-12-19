import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:wallet_flutter/network/model/base_request.dart';
import 'package:wallet_flutter/network/model/payment/payment_ack.dart';
import 'package:wallet_flutter/network/model/payment/payment_memo.dart';
import 'package:wallet_flutter/network/model/payment/payment_message.dart';
import 'package:wallet_flutter/network/model/payment/payment_request.dart';
import 'package:wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:wallet_flutter/network/model/response/error_response.dart';
import 'package:wallet_flutter/network/model/response/funding_response_item.dart';
import 'package:wallet_flutter/service_locator.dart';

// MetadataService singleton
class MetadataService {
  // Constructor
  MetadataService();

  static const String PRO_PAYMENT_ADDRESS = "nano_35n1a3fbbar5imzmsyrfxaeqwgkgkd7autbjxon9btfbui5ys86g8kmpbjte";
  static const String PRO_PAYMENT_MONTHLY_COST = "1000000000000000000000000000000";
  static const String PRO_PAYMENT_LIFETIME_COST = "100000000000000000000000000000000";

  // meta:
  static String META_SERVER = "https://meta.perish.co";

  // ignore_for_file: non_constant_identifier_names
  // static String SERVER_ADDRESS_HTTP = "$HTTP_PROTO$META_SERVER/api";
  static String SERVER_ADDRESS_PAYMENTS = "$META_SERVER/payments";
  static String SERVER_ADDRESS_NOTIFICATIONS = "$META_SERVER/notifications";
  static String SERVER_ADDRESS_ALERTS = "$META_SERVER/alerts";
  static String SERVER_ADDRESS_FUNDING = "$META_SERVER/funding";

  final Logger log = sl.get<Logger>();

  Future<void> initCommunication() async {}

  // HTTP API

  Future<dynamic> makeNotificationsRequest(BaseRequest request) async {
    final http.Response response = await http.post(Uri.parse(SERVER_ADDRESS_NOTIFICATIONS),
        headers: {'Content-type': 'application/json'}, body: json.encode(request.toJson()));

    if (response.statusCode != 200) {
      return null;
    }
    try {
      final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
      if (decoded.containsKey("error")) {
        return ErrorResponse.fromJson(decoded as Map<String, dynamic>);
      }

      return decoded;
    } catch (e) {
      log.e("Error decoding notifications response: ${response.body} $e");
      return null;
    }
  }

  // /* Send Request */
  // Future<void> sendRequest(BaseRequest request) async {
  //   // We don't care about order or server response in these requests
  //   //log.d("sending ${json.encode(request.toJson())}");
  //   _send(await compute(encodeRequestItem, request));
  // }

  Future<dynamic> makePaymentsRequest(BaseRequest request) async {
    final http.Response response = await http.post(Uri.parse(SERVER_ADDRESS_PAYMENTS),
        headers: {'Content-type': 'application/json'}, body: json.encode(request.toJson()));

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
  Future<void> requestPayment(String? account, String? amountRaw, String? requestingAccount, String requestSignature,
      String requestNonce, String? memoEnc, String localUuid) async {
    final PaymentRequest request = PaymentRequest(
        account: account,
        amount_raw: amountRaw,
        requesting_account: requestingAccount,
        request_signature: requestSignature,
        request_nonce: requestNonce,
        memo_enc: memoEnc,
        local_uuid: localUuid);

    // queueRequest(request);
    final dynamic response = await makePaymentsRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
  }

  // send payment record (memo) to an account:
  Future<void> sendTXMemo(String account, String requestingAccount, String? amountRaw, String requestSignature,
      String requestNonce, String memoEnc, String? block, String localUuid) async {
    final PaymentMemo request = PaymentMemo(
        account: account,
        requesting_account: requestingAccount,
        request_signature: requestSignature,
        request_nonce: requestNonce,
        memo_enc: memoEnc,
        block: block,
        local_uuid: localUuid);
    final dynamic response = await makePaymentsRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error} ${response.details}");
    }
  }

  Future<void> sendTXMessage(String account, String requestingAccount, String requestSignature, String requestNonce,
      String memoEnc, String localUuid) async {
    final PaymentMessage request = PaymentMessage(
        account: account,
        requesting_account: requestingAccount,
        request_signature: requestSignature,
        request_nonce: requestNonce,
        memo_enc: memoEnc,
        local_uuid: localUuid);
    final dynamic response = await makePaymentsRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error} ${response.details}");
    }
  }

  Future<void> requestACK(String? requestUuid, String? account, String? requestingAccount) async {
    final PaymentACK request = PaymentACK(uuid: requestUuid, account: account, requesting_account: requestingAccount);
    final dynamic response = await makePaymentsRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error} ${response.details}");
    }
  }

  // metadata:

  Future<AlertResponseItem?> getAlert(String lang) async {
    final http.Response response =
        await http.get(Uri.parse("$SERVER_ADDRESS_ALERTS/$lang"), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      List<AlertResponseItem> alerts;
      alerts = (json.decode(response.body) as List)
          .map((i) => AlertResponseItem.fromJson(i as Map<String, dynamic>))
          .toList();
      if (alerts.isNotEmpty) {
        if (alerts[0].active!) {
          return alerts[0];
        }
      }
    }
    return null;
  }

  Future<List<FundingResponseItem>?> getFunding(String lang) async {
    final http.Response response =
        await http.get(Uri.parse("$SERVER_ADDRESS_FUNDING/$lang"), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      List<FundingResponseItem> alerts;
      alerts = (json.decode(response.body) as List)
          .map((i) => FundingResponseItem.fromJson(i as Map<String, dynamic>))
          .toList();
      if (alerts.isNotEmpty) {
        return alerts;
      }
    }
    return null;
  }
}
