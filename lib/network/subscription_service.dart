import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/network/model/base_request.dart';
import 'package:wallet_flutter/network/model/payment/payment_ack.dart';
import 'package:wallet_flutter/network/model/payment/payment_memo.dart';
import 'package:wallet_flutter/network/model/payment/payment_message.dart';
import 'package:wallet_flutter/network/model/payment/payment_request.dart';
import 'package:wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:wallet_flutter/network/model/response/error_response.dart';
import 'package:wallet_flutter/network/model/response/funding_response_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// SubscriptionService singleton
class SubscriptionService {
  // Constructor
  SubscriptionService() {
    initSubs();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String PRO_PAYMENT_ADDRESS = "nano_35n1a3fbbar5imzmsyrfxaeqwgkgkd7autbjxon9btfbui5ys86g8kmpbjte";
  static const String PRO_PAYMENT_MONTHLY_COST = "1000000000000000000000000000000";
  static const String PRO_PAYMENT_LIFETIME_COST = "100000000000000000000000000000000";

  final Logger log = sl.get<Logger>();

  Future<void> initSubs() async {
    // cancel all existing subscriptions:
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> isSubPaid(Subscription sub) async {
    // check through the payment history for a payment that is paid and has the correct amount

    return true;
  }
}
