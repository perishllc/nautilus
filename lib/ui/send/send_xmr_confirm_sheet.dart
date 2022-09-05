import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/bus/xmr_event.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/authentication_method.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_info_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_xmr_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/security.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/biometrics.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';

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
                          CaseChange.toUpperCase(AppLocalization.of(context).sending, context),
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
                          CaseChange.toUpperCase(AppLocalization.of(context).to, context),
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
                            CaseChange.toUpperCase(AppLocalization.of(context).withFee, context),
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
                        CaseChange.toUpperCase(AppLocalization.of(context).confirm, context),
                        Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                      // Authenticate
                      final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                      final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();

                      final bool isMessage = widget.memo.isNotEmpty && (widget.amountRaw == "0");

                      final String authText = isMessage
                          ? AppLocalization.of(context).sendMessageConfirm
                          : AppLocalization.of(context)
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
                      } else {
                        await authenticateWithPin();
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
                        CaseChange.toUpperCase(AppLocalization.of(context).cancel, context),
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
              AppLocalization.of(context).unopenedWarningWarningHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("${AppLocalization.of(context).unopenedWarningWarning}\n\n",
                    style: AppStyles.textStyleParagraph(context)),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: "${AppLocalization.of(context).address}:\n",
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
                    AppLocalization.of(context).imSure,
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
                    AppLocalization.of(context).goBackButton,
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
    bool memoSendFailed = false;
    try {
      final bool isMessage = widget.amountRaw == "0";
      final String walletAddress = StateContainer.of(context).wallet!.address!;

      _showAnimation(context, isMessage ? AnimationType.SEND_MESSAGE : AnimationType.SEND);

      EventTaxiImpl.singleton().fire(XMREvent(type: "xmr_send", message: "${widget.destination}:${widget.amountRaw}"));

      // sleep to flex the animation a bit:
      await Future<dynamic>.delayed(const Duration(milliseconds: 3500));

      // Show complete
      String? contactName = widget.contactName;
      if (widget.contactName == null || widget.contactName!.isEmpty) {
        final User? user = await sl.get<DBHelper>().getUserWithAddress(widget.destination);
        if (user != null) {
          contactName = user.getDisplayName();
        }
      }
      // StateContainer.of(context).requestUpdate();
      // StateContainer.of(context).updateTXMemos();
      // if (isMessage) {
      //   StateContainer.of(context).updateSolids();
      // }
      // StateContainer.of(context).updateUnified(true);

      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
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
    } catch (error) {
      sl.get<Logger>().d("send_xmr_confirm_error: $error");
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(AppLocalization.of(context).sendError, context, durationMs: 5000);
      Navigator.of(context).pop();
    }
  }

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    final String? expectedPin = await sl.get<Vault>().getPin();
    final String? plausiblePin = await sl.get<Vault>().getPlausiblePin();
    final bool? auth = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        plausiblePin: plausiblePin,
        description: AppLocalization.of(context)
            .sendAmountConfirm
            .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
            .replaceAll("%2", "XMR"),
      );
    }));
    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
