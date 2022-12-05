import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/fcm_update_event.dart';
import 'package:nautilus_wallet_flutter/bus/notification_setting_change_event.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/notification_setting.dart';
import 'package:nautilus_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:url_launcher/url_launcher.dart';

class RemoteMessageSheet extends StatefulWidget {
  const RemoteMessageSheet({this.alert, this.hasDismissButton = true}) : super();

  final AlertResponseItem? alert;
  final bool hasDismissButton;

  @override
  RemoteMessageSheetState createState() => RemoteMessageSheetState();
}

class RemoteMessageSheetState extends State<RemoteMessageSheet> {
  Future<bool> showNotificationDialog() async {
    final NotificationOptions? option = await showDialog<NotificationOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              Z.of(context).notifications,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });

    if (option == null) {
      return false;
    }

    if (option == NotificationOptions.ON) {
      sl.get<SharedPrefsUtil>().setNotificationsOn(true).then((void result) {
        EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: true));
        FirebaseMessaging.instance.requestPermission();
        FirebaseMessaging.instance.getToken().then((String? fcmToken) {
          EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
        });
      });
      return true;
    } else {
      sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((void result) {
        EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: false));
        FirebaseMessaging.instance.getToken().then((String? fcmToken) {
          EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
        });
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the address text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 10,
                ),
                //Container for the address text and sheet handle
                Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text20,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(top: 15.0),
                    //   constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                    //   child: Column(
                    //     children: <Widget>[
                    //       // Header
                    //       AutoSizeText(
                    //         CaseChange.toUpperCase(Z.of(context).messageHeader, context),
                    //         style: AppStyles.textStyleHeader(context),
                    //         textAlign: TextAlign.center,
                    //         maxLines: 1,
                    //         stepGranularity: 0.1,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 10,
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 8, 28, 8),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.only(top: 12, bottom: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.alert!.timestamp != null)
                            Container(
                              margin: const EdgeInsetsDirectional.only(top: 2, bottom: 6),
                              padding: const EdgeInsetsDirectional.only(start: 10, end: 10, top: 2, bottom: 2),
                              decoration: BoxDecoration(
                                color: StateContainer.of(context).curTheme.text05,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100),
                                ),
                                border: Border.all(
                                  color: StateContainer.of(context).curTheme.text10!,
                                ),
                              ),
                              child: Text(
                                "${DateTime.fromMillisecondsSinceEpoch(widget.alert!.timestamp!).toUtc().toString().substring(0, 16)} UTC",
                                style: AppStyles.remoteMessageCardTimestamp(context),
                              ),
                            ),
                          if (widget.alert!.title != null)
                            Container(
                              margin: const EdgeInsetsDirectional.only(top: 2, bottom: 2),
                              child: Text(
                                widget.alert!.title!,
                                style: AppStyles.remoteMessageCardTitle(context),
                              ),
                            ),
                          if (widget.alert!.longDescription != null || widget.alert!.shortDescription != null)
                            Container(
                              margin: const EdgeInsetsDirectional.only(top: 2, bottom: 2),
                              child: Text(
                                widget.alert!.longDescription != null
                                    ? widget.alert!.longDescription!
                                    : widget.alert!.shortDescription!,
                                style: AppStyles.remoteMessageCardShortDescription(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ListGradient(
                      height: 12,
                      top: true,
                      color: StateContainer.of(context).curTheme.backgroundDark!,
                    ),
                    ListGradient(
                      height: 36,
                      top: false,
                      color: StateContainer.of(context).curTheme.backgroundDark!,
                    ),
                  ],
                ),
              ),
            ),
            //A column with Copy Address and Share Address buttons
            Column(
              children: <Widget>[
                if (widget.alert!.link != null)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).readMore,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        final Uri uri = Uri.parse(widget.alert!.link!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                          await sl.get<SharedPrefsUtil>().markAlertRead(widget.alert!);
                          StateContainer.of(context).setAlertRead();
                        }
                      }),
                    ],
                  ),
                if (widget.alert?.id == 4042)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY,
                          Z.of(context).enableNotifications,
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                        final bool enabledNotifications = await showNotificationDialog();
                        if (!mounted) return;
                        // remove the alert:
                        if (enabledNotifications) {
                          sl.get<SharedPrefsUtil>().dismissAlert(widget.alert!);
                          StateContainer.of(context).removeActiveOrSettingsAlert(widget.alert, null);
                          Navigator.pop(context);
                        }
                      }),
                    ],
                  ),
                if (widget.alert?.id == 4043)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY,
                          Z.of(context).enableTracking, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                        bool? trackingEnabled;
                        if (Platform.isIOS) {
                          final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
                          if (status == TrackingStatus.authorized) {
                            trackingEnabled = true;
                          }
                        } else {
                          trackingEnabled = await AppDialogs.showTrackingDialog(context, true);
                        }

                        if (trackingEnabled == null) return;

                        if (!mounted) return;

                        // remove the alert:
                        if (trackingEnabled) {
                          sl.get<SharedPrefsUtil>().dismissAlert(widget.alert!);
                          StateContainer.of(context).removeActiveOrSettingsAlert(widget.alert, null);
                          Navigator.pop(context);
                        }
                      }),
                    ],
                  ),
                if (widget.hasDismissButton && widget.alert!.dismissable)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                          Z.of(context).dismiss, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        sl.get<SharedPrefsUtil>().dismissAlertForWeek(widget.alert!);
                        StateContainer.of(context).removeActiveOrSettingsAlert(widget.alert, null);
                        if (widget.alert?.priority == "high") {
                          StateContainer.of(context).addActiveOrSettingsAlert(null, widget.alert);
                        }
                        Navigator.pop(context);
                      }),
                    ],
                  )
                else
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                          Z.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.pop(context);
                      }),
                    ],
                  )
              ],
            ),
          ],
        ));
  }
}
