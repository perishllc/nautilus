import 'dart:async';

import 'package:easy_cron/easy_cron.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/subs_changed_event.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/network/model/block_types.dart';
import 'package:wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

// SubscriptionService singleton
class SubscriptionService {
  // Constructor
  SubscriptionService() {
    initNotifications();
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String PRO_PAYMENT_ADDRESS = "nano_35n1a3fbbar5imzmsyrfxaeqwgkgkd7autbjxon9btfbui5ys86g8kmpbjte";
  static const String PRO_PAYMENT_MONTHLY_COST = "1000000000000000000000000000000";
  static const String PRO_PAYMENT_LIFETIME_COST = "100000000000000000000000000000000";

  final Logger log = sl.get<Logger>();

  Future<void> initNotifications() async {
    // initialize timezones:
    tz.initializeTimeZones();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("ic_stat_logo_transparent");
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

    setupChineseNewYearNotification();

    scheduleNotifications();
  }

  Future<void> scheduleNotifications() async {
    // cancel all existing subscriptions:
    await flutterLocalNotificationsPlugin.cancelAll();

    // go through all subscriptions and set up notifications:
    final List<Subscription> subs = await sl.get<DBHelper>().getSubscriptions();
    for (final Subscription sub in subs) {
      // only check active subscriptions:
      if (!sub.active) {
        continue;
      }
      await scheduleSubNotification(sub);
    }

    // chinese new year notification:
    setupChineseNewYearNotification();
  }

  Future<void> checkAreSubscriptionsPaid(List<AccountHistoryResponseItem> history) async {
    // get all subscriptions:
    final List<Subscription> subs = await sl.get<DBHelper>().getSubscriptions();
    for (final Subscription sub in subs) {
      // ignore: use_build_context_synchronously
      final bool isPaid = await checkSubPaid(history, sub);
      log.d("Subscription ${sub.name} is paid: $isPaid");
      if (isPaid != sub.paid) {
        // make sure the tag matches the real state:
        await sl.get<DBHelper>().toggleSubscriptionPaid(sub);
      }
    }
    EventTaxiImpl.singleton().fire(SubsChangedEvent(subs: await sl.get<DBHelper>().getSubscriptions()));

    // update scheduled notifications:
    scheduleNotifications();
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
      "Subscriptions",
      channelDescription: "Subscription Reminder Notifications",
      importance: Importance.max,
      priority: Priority.high,
      ticker: "ticker",
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    try {
      final tz.TZDateTime tzdatetime = tz.TZDateTime.from(DateTime.now().add(const Duration(seconds: 10)), tz.local);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Subscription Reminder",
        "Your subscription is due",
        tzdatetime,
        const NotificationDetails(
          android: androidNotificationDetails,
          iOS: darwinNotificationDetails,
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> setupChineseNewYearNotification() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "events_channel",
      "Events",
      channelDescription: "Events Notifications",
      importance: Importance.max,
      priority: Priority.high,
      ticker: "ticker",
      styleInformation: BigTextStyleInformation(
"""
As one of the biggest traditions to celebrate Chinese New Year, many people gift money in red envelopes. That’s why, for the coming week, you’ll be able to digitally gift a red envelope filled with nano to the ones you love!

Simply click "send" and select the red envelope in the top left corner to share some nano with your friends, family, colleagues, or even a stranger on the internet!

Have a happy Chinese New Year!
""",
      ),
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    try {
      final DateTime chineseNewYear = DateTime(2023, 1, 22, 8);
      final tz.TZDateTime tzdatetime = tz.TZDateTime.from(chineseNewYear, tz.local);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        2023,
        "Happy Chinese New Year!",
        "",
        tzdatetime,
        const NotificationDetails(
          android: androidNotificationDetails,
          iOS: darwinNotificationDetails,
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      log.e(e);
    }
  }

  // check whether a subscription has been paid:
  Future<bool> checkSubPaid(List<AccountHistoryResponseItem> history, Subscription sub) async {
    // first check if sub is active:
    if (!sub.active) {
      return false;
    }

    // search through the wallet history to see if we paid to the address:
    bool hasPaid = false;
    int paidTimestamp = 0;
    if (history.isNotEmpty) {
      for (final AccountHistoryResponseItem histItem in history) {
        if (histItem.subtype == BlockTypes.SEND && histItem.account == sub.address) {
          if (BigInt.parse(histItem.amount!) >= BigInt.parse(sub.amount_raw)) {
            hasPaid = true;
            paidTimestamp = histItem.local_timestamp ?? 0;
            break;
          }
          // todo: optimize:
          // if (histItem.local_timestamp != null) {
          //   // if the timestamp is earlier than the last payment time then we can stop searching:
          //   if (histItem.local_timestamp! < TODO) {
          //     break;
          //   }
          // }
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
    final DateTime subTime = UnixCronParser().parse(sub.frequency).next().time;
    final tz.TZDateTime tzdatetime = tz.TZDateTime.from(subTime, tz.local);

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "subscriptions_channel",
      "Subscriptions",
      channelDescription: "Subscription Reminder Notifications",
      importance: Importance.max,
      priority: Priority.high,
      ticker: "ticker",
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      sub.id ?? 0,
      "Subscription Reminder",
      "Your subscription for ${sub.name} is due",
      tzdatetime,
      const NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
