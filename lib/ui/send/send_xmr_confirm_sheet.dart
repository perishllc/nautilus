import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/bus/xmr_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/response/account_info_response.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/send/send_xmr_complete_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/security.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/biometrics.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class SendXMRConfirmSheet extends StatefulWidget {
  const SendXMRConfirmSheet(
      {required this.amountRaw,
      required this.destination,
      this.contactName,
      this.localCurrency,
      this.maxSend = false,
      // this.phoneNumber = "",
      this.paperWalletSeed = "",
      this.memo = ""})
      : super();

  final String amountRaw;
  final String destination;
  final String? contactName;
  final String? localCurrency;
  final bool maxSend;
  // final bool isPhoneNumber;
  // final String phoneNumber;
  final String paperWalletSeed;
  final String memo;

  @override
  _SendXMRConfirmSheetState createState() => _SendXMRConfirmSheetState();
}

class _SendXMRConfirmSheetState extends State<SendXMRConfirmSheet> {
  late bool animationOpen;

  StreamSubscription<AuthenticatedEvent>? _authSub;
  StreamSubscription<XMREvent>? _xmrSub;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton().registerTo<AuthenticatedEvent>().listen((AuthenticatedEvent event) {
      if (event.authType == AUTH_EVENT_TYPE.SEND) {
        _doSend();
      }
    });
    _xmrSub = EventTaxiImpl.singleton().registerTo<XMREvent>().listen((XMREvent event) {
      if (event.type == "send_done" || event.type == "send_failed") {
        _sendDone(event.type == "send_failed");
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
            //The main widget that holds the text fields, "SENDING" and "TO" texts
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
                          CaseChange.toUpperCase(Z.of(context).sending, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Container for the amount text
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
                            text: getXMRThemeAwareRawAccuracy(context, widget.amountRaw),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: "${getXMRRawAsThemeAwareAmount(context, widget.amountRaw)} XMR",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: widget.localCurrency != null ? " (${widget.localCurrency})" : "",
                            style: AppStyles.textStyleParagraphPrimary(context).copyWith(
                              color: StateContainer.of(context).curTheme.primary!.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(Z.of(context).to, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Address text
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.105,
                          right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: UIUtil.threeLineAddressText(context, widget.destination, contactName: widget.contactName)),

                  // WITH FEE:
                  if (StateContainer.of(context).xmrFee.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            CaseChange.toUpperCase(Z.of(context).withFee, context),
                            style: AppStyles.textStyleHeader(context),
                          ),
                        ],
                      ),
                    ),
                  // FEE:
                  if (StateContainer.of(context).xmrFee.isNotEmpty)
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.105,
                            right: MediaQuery.of(context).size.width * 0.105),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: StateContainer.of(context).curTheme.backgroundDarkest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "${getXMRThemeAwareRawAccuracy(context, StateContainer.of(context).xmrFee)}${getXMRRawAsThemeAwareAmount(context, StateContainer.of(context).xmrFee)} XMR",
                          style: AppStyles.textStyleParagraphPrimary(context),
                          textAlign: TextAlign.center,
                        )),
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
                      // Authenticate
                      final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                      final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();

                      final bool isMessage = widget.memo.isNotEmpty && (widget.amountRaw == "0");

                      if (!mounted) return;

                      final String authText = isMessage
                          ? Z.of(context).sendMessageConfirm
                          : Z
                              .of(context)
                              .sendAmountConfirm
                              .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
                              .replaceAll("%2", StateContainer.of(context).currencyMode);

                      // show warning dialog if this is a send:
                      // if ((widget.amountRaw != "0") &&
                      //     widget.link.isEmpty &&
                      //     !await showUnopenedWarning(widget.destination)) {
                      //   return;
                      // }

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

  Future<bool> showUnopenedWarning(String address) async {
    // if we have the warn setting on, and the account isn't open, show the dialog:
    final bool warningOn = await sl.get<SharedPrefsUtil>().getUnopenedWarningOn();
    if (!warningOn) {
      return true;
    }
    // check if the address is open:
    final AccountInfoResponse accountInfo = await sl.get<AccountService>().getAccountInfo(address);
    if (!accountInfo.unopened) {
      return true;
    }

    if (!mounted) return false;

    final bool? option = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              Z.of(context).unopenedWarningWarningHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("${Z.of(context).unopenedWarningWarning}\n\n", style: AppStyles.textStyleParagraph(context)),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: "${Z.of(context).address}:\n",
                    style: AppStyles.textStyleParagraph(context),
                    children: [
                      TextSpan(
                        text: "$address\n",
                        style: AppStyles.textStyleParagraphPrimary(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).imSure,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).goBackButton,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              )
            ],
          );
        });

    return option ?? false;
  }

  Future<void> _doSend() async {
    try {
      _showAnimation(context, AnimationType.SEND);

      EventTaxiImpl.singleton().fire(XMREvent(type: "xmr_send", message: "${widget.destination}:${widget.amountRaw}"));

      await Future<dynamic>.delayed(const Duration(milliseconds: 10000));
      if (mounted) {
        throw Exception("transaction timeout");
      }
    } catch (error) {
      sl.get<Logger>().d("send_xmr_confirm_error: $error");
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).sendError, context, durationMs: 5000);
      Navigator.of(context).pop();
    }
  }

  Future<void> _sendDone(bool failed) async {
    // sleep to flex the animation a bit:
    await Future<dynamic>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    if (failed) {
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).sendError, context, durationMs: 5000);
      Navigator.of(context).pop();
    } else {
      // Show complete
      String? contactName = widget.contactName;
      if (widget.contactName == null || widget.contactName!.isEmpty) {
        final User? user = await sl.get<DBHelper>().getUserWithAddress(widget.destination);
        if (user != null) {
          contactName = user.getDisplayName();
        }
      }

      if (!mounted) return;

      Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      Sheets.showAppHeightNineSheet(
          context: context,
          closeOnTap: true,
          removeUntilHome: true,
          widget: SendXMRCompleteSheet(
            amountRaw: widget.amountRaw,
            destination: widget.destination,
            contactName: contactName,
            memo: widget.memo,
            localAmount: widget.localCurrency,
          ));
    }
  }

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    final String? expectedPin = await sl.get<Vault>().getPin();
    final String? plausiblePin = await sl.get<Vault>().getPlausiblePin();
    if (!mounted) return;
    final bool? auth = await Navigator.of(context).push(MaterialPageRoute<bool>(builder: (BuildContext context) {
      return PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        plausiblePin: plausiblePin,
        description: Z
            .of(context)
            .sendAmountConfirm
            .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
            .replaceAll("%2", "XMR"),
      );
    }));
    if (auth ?? false) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
