import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/network/model/block_types.dart';
import 'package:wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:easy_cron/easy_cron.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// SubscriptionService singleton
class SubscriptionService {
  // Constructor
  SubscriptionService() {
    initSubs();
  }

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
  );

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String PRO_PAYMENT_ADDRESS = "nano_35n1a3fbbar5imzmsyrfxaeqwgkgkd7autbjxon9btfbui5ys86g8kmpbjte";
  static const String PRO_PAYMENT_MONTHLY_COST = "1000000000000000000000000000000";
  static const String PRO_PAYMENT_LIFETIME_COST = "100000000000000000000000000000000";

  final Logger log = sl.get<Logger>();

  Future<void> initSubs() async {
    // cancel all existing subscriptions:
    await flutterLocalNotificationsPlugin.cancelAll();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // go through all subscriptions and set up notifications:
    final List<Subscription> subs = await sl.get<DBHelper>().getSubscriptions();
    for (final Subscription sub in subs) {
      // only check active subscriptions:
      if (!sub.active) {
        continue;
      }
      // ignore: use_build_context_synchronously
      await scheduleSubNotification(sub);
    }
  }

  Future<void> checkAreSubscriptionsPaid(BuildContext context) async {
    if (StateContainer.of(context).wallet?.history == null) {
      return;
    }

    // get all subscriptions:
    final List<Subscription> subs = await sl.get<DBHelper>().getSubscriptions();
    for (final Subscription sub in subs) {
      // only check active subscriptions:
      if (!sub.active) {
        continue;
      }
      // ignore: use_build_context_synchronously
      final bool isPaid = await checkSubPaid(context, sub);
      log.d("Subscription ${sub.id} is paid: $isPaid");
      if (isPaid != sub.paid) {
        // if not paid then deactivate the subscription:
        await sl.get<DBHelper>().toggleSubscriptionPaid(sub);
      }
    }
  }

  Future<bool> toggleSubscriptionActive(BuildContext context, Subscription sub) async {
    // are we activating or deactivating?
    // if we're activating then notifications must be enabled:
    if (!sub.active) {
      // check if notifications are enabled:
      bool notificationsEnabled = await sl.get<SharedPrefsUtil>().getNotificationsOn();
      if (!notificationsEnabled) {
        final bool notificationTurnedOn = await SendSheetHelpers.showNotificationDialog(context);
        if (!notificationTurnedOn) {
          return false;
        }
        notificationsEnabled = true;
      }

      if (!notificationsEnabled) {
        return false;
      }
    }

    await sl.get<DBHelper>().toggleSubscriptionActive(sub);
    return true;
  }

  Future<void> testNotification(BuildContext context) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "subscriptions_channel",
      "subscriptions",
      channelDescription: "Subscription Reminder Notifications",
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channel);

    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        'plain title',
        'plain body',
        notificationDetails,
      );
    } catch (e) {
      log.e(e);
    }
  }

  // check whether a subscription has been paid:
  Future<bool> checkSubPaid(BuildContext context, Subscription sub) async {
    // first check if sub is active:
    if (!sub.active) {
      return false;
    }

    // search through the wallet history to see if we paid to the address:
    bool hasPaid = false;
    int paidTimestamp = 0;
    final List<AccountHistoryResponseItem>? history = StateContainer.of(context).wallet?.history;
    if (history != null && history.isNotEmpty) {
      for (final AccountHistoryResponseItem histItem in history) {
        if (histItem.subtype == BlockTypes.SEND && histItem.account == sub.address) {
          if (BigInt.parse(histItem.amount!) >= BigInt.parse(sub.amount_raw)) {
            hasPaid = true;
            paidTimestamp = histItem.local_timestamp ?? 0;
            break;
          }
        }
      }
    }

    try {
      final UnixCronParser cronParser = UnixCronParser();
      final CronSchedule schedule = cronParser.parse(sub.frequency);
      final CronTime prevTime = schedule.prev();
      final int prevTimeInSecs = prevTime.time.millisecondsSinceEpoch ~/ 1000;

      if (hasPaid) {
        bool paymentWasRecent = false;
        if (paidTimestamp > 0) {
          // make sure the payment was made after prevTimeInSecs:
          if (paidTimestamp > prevTimeInSecs) {
            paymentWasRecent = true;
          }
        }
        if (paymentWasRecent) {
          return true;
        }
      }

      return false;
    } catch (e) {
      log.e(e);
      return false;
    }
  }

  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {}

  void onDidReceiveNotificationResponse(NotificationResponse details) {}

  Future<void> scheduleSubNotification(Subscription sub) async {
    UnixCronParser cronParser = UnixCronParser();
    final DateTime subTime = cronParser.parse(sub.frequency).next().time;
    final tz.TZDateTime tzdatetime = tz.TZDateTime.from(subTime, tz.local);

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "subscriptions_channel",
      "subscriptions",
      channelDescription: "Subscription Reminder Notifications",
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      sub.id ?? 0,
      "Subscription Reminder",
      "Your subscription for ${sub.name} is due",
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: androidNotificationDetails,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
