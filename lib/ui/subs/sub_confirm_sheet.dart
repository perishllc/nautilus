import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/bus/subs_changed_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/model/method.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/response/auth_item.dart';
import 'package:wallet_flutter/network/model/response/handoff_response.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/auth/auth_complete_sheet.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/subs/sub_complete_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/security.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/biometrics.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class SubConfirmSheet extends StatefulWidget {
  const SubConfirmSheet({
    required this.sub,
  }) : super();

  final Subscription sub;

  @override
  SubConfirmSheetState createState() => SubConfirmSheetState();
}

class SubConfirmSheetState extends State<SubConfirmSheet> {
  late bool animationOpen;

  StreamSubscription<AuthenticatedEvent>? _authSub;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton().registerTo<AuthenticatedEvent>().listen((AuthenticatedEvent event) {
      if (event.authType == AUTH_EVENT_TYPE.SEND) {
        _doSend();
      }
    });
  }

  void _destroyBus() {
    if (_authSub != null) {
      _authSub!.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    animationOpen = false;
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _showAnimation(BuildContext context, AnimationType type) {
    animationOpen = true;
    AppAnimation.animationLauncher(context, type, onPoppedCallback: () => animationOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            Handlebars.horizontal(context),
            // The main widget that holds the text fields, "SENDING" and "TO" texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // "SENDING" TEXT
                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(Z.of(context).subscribeButton, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  if (widget.sub.label.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.105,
                          right: MediaQuery.of(context).size.width * 0.105),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "",
                          children: [
                            TextSpan(
                              text: widget.sub.label,
                              style: AppStyles.textStyleParagraphPrimary(context),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Address text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                    margin: EdgeInsets.only(
                        top: 30,
                        left: MediaQuery.of(context).size.width * 0.105,
                        right: MediaQuery.of(context).size.width * 0.105),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: UIUtil.threeLineAddressText(context, widget.sub.address),
                  ),
                  // if (widget.sub.label.isNotEmpty)
                  //   Container(
                  //     margin: EdgeInsets.only(
                  //         left: MediaQuery.of(context).size.width * 0.105,
                  //         right: MediaQuery.of(context).size.width * 0.105),
                  //     padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //       color: StateContainer.of(context).curTheme.backgroundDarkest,
                  //       borderRadius: BorderRadius.circular(50),
                  //     ),
                  //     child: RichText(
                  //       textAlign: TextAlign.center,
                  //       text: TextSpan(
                  //         text: "",
                  //         children: [
                  //           TextSpan(
                  //             text: widget.sub.message,
                  //             style: AppStyles.textStyleParagraphPrimary(context),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // if (widget.authItem.nonce.isNotEmpty)
                  //   Container(
                  //     margin: EdgeInsets.only(
                  //         left: MediaQuery.of(context).size.width * 0.105,
                  //         right: MediaQuery.of(context).size.width * 0.105),
                  //     padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //       color: StateContainer.of(context).curTheme.backgroundDarkest,
                  //       borderRadius: BorderRadius.circular(50),
                  //     ),
                  //     // Amount text
                  //     child: RichText(
                  //       textAlign: TextAlign.center,
                  //       text: TextSpan(
                  //         text: widget.authItem.nonce,
                  //         style: AppStyles.textStyleParagraphPrimary(context),
                  //       ),
                  //     ),
                  //   ),

                  // "FOR" text
                  Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(Z.of(context).registerFor, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.105,
                        right: MediaQuery.of(context).size.width * 0.105),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // Amount text
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "",
                        children: [
                          TextSpan(
                            text: getThemeAwareRawAccuracy(context, widget.sub.amount_raw),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: getRawAsThemeAwareFormattedAmount(context, widget.sub.amount_raw),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          // TextSpan(
                          //   text: widget.localCurrency != null ? " (${widget.localCurrency})" : "",
                          //   style: AppStyles.textStyleParagraphPrimary(context).copyWith(
                          //     color: StateContainer.of(context).curTheme.primary!.withOpacity(0.75),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // "EVERY" text
                  Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(Z.of(context).subscribeEvery, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.105,
                        right: MediaQuery.of(context).size.width * 0.105),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: widget.sub.frequency,
                        style: AppStyles.textStyleParagraphPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //A container for CONFIRM and CANCEL buttons
            Column(
              children: <Widget>[
                // A row for CONFIRM Button
                Row(
                  children: <Widget>[
                    // CONFIRM Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        CaseChange.toUpperCase(Z.of(context).confirm, context),
                        Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                      // make sure notifications are enabled:
                      final bool notificationsEnabled = await sl.get<SharedPrefsUtil>().getNotificationsOn();
                      if (!notificationsEnabled) {
                        if (!mounted) return;
                        final bool notificationTurnedOn = await SendSheetHelpers.showNotificationDialog(context);
                        if (!notificationTurnedOn) {
                          return;
                        }
                      }

                      // Authenticate
                      final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                      final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();

                      if (!mounted) return;

                      final String authText = Z.of(context).subscribing;

                      if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                        try {
                          final bool authenticated =
                              await sl.get<BiometricUtil>().authenticateWithBiometrics(context, authText);
                          if (authenticated) {
                            sl.get<HapticUtil>().fingerprintSucess();
                            EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
                          }
                        } catch (e) {
                          await authenticateWithPin();
                        }
                      } else if (authMethod.method == AuthMethod.PIN) {
                        await authenticateWithPin();
                      } else {
                        EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
                      }
                    })
                  ],
                ),
                // A row for CANCEL Button
                Row(
                  children: <Widget>[
                    // CANCEL Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        CaseChange.toUpperCase(Z.of(context).cancel, context),
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  Future<void> _doSend() async {
    String? poppedError;
    try {
      _showAnimation(context, AnimationType.GENERIC);

      // save the subscription to the database:
      await sl.get<DBHelper>().saveSubscription(widget.sub);

      EventTaxiImpl.singleton().fire(SubsChangedEvent(subs: await sl.get<DBHelper>().getSubscriptions()));

      // Send the subscription amount:
      // bool payNow = false;
      // if (payNow) {
      //   final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
      //   final String privKey = await NanoUtil.uniSeedToPrivate(await StateContainer.of(context).getSeed(),
      //       StateContainer.of(context).selectedAccount!.index!, derivationMethod);
      //   var resp = await sl.get<AccountService>().requestSend(
      //         StateContainer.of(context).wallet!.representative,
      //         StateContainer.of(context).wallet!.frontier,
      //         widget.sub.amount_raw,
      //         widget.sub.address,
      //         StateContainer.of(context).wallet!.address,
      //         privKey,
      //         max: false,
      //       );
      //   if (!mounted) return;
      //   StateContainer.of(context).wallet!.frontier = resp.hash;
      //   StateContainer.of(context).wallet!.accountBalance += BigInt.parse(
      //     widget.sub.amount_raw,
      //   );
      // }

      // Show complete
      if (!mounted) return;

      Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      Sheets.showAppHeightNineSheet(
        context: context,
        closeOnTap: true,
        removeUntilHome: true,
        widget: SubCompleteSheet(
          label: widget.sub.label,
        ),
      );
    } catch (error) {
      sl.get<Logger>().d("sub_confirm_error: $error");
      // Auth failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      if (poppedError != null) {
        UIUtil.showSnackbar(poppedError, context, durationMs: 5000);
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).authError, context, durationMs: 5000);
      Navigator.of(context).pop();
    }
  }

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    final String? expectedPin = await sl.get<Vault>().getPin();
    final String? plausiblePin = await sl.get<Vault>().getPlausiblePin();
    if (!mounted) return;
    final bool? auth = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        plausiblePin: plausiblePin,
        description: Z.of(context).authConfirm,
      );
    }));
    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
