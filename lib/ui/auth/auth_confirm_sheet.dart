import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/authentication_method.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/method.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/auth_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/handoff_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/auth/auth_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/handoff/handoff_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/security.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/biometrics.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';

class AuthConfirmSheet extends StatefulWidget {
  const AuthConfirmSheet(
      {required this.authItem,
      required this.destination,
      this.contactName,
      this.localCurrency,
      this.maxSend = false,
      this.phoneNumber = "",
      this.paperWalletSeed = "",
      this.link = "",
      this.memo = ""})
      : super();

  final AuthItem authItem;
  final String destination;
  final String? contactName;
  final String? localCurrency;
  final bool maxSend;
  // final bool isPhoneNumber;
  final String phoneNumber;
  final String link;
  final String paperWalletSeed;
  final String memo;

  _AuthConfirmSheetState createState() => _AuthConfirmSheetState();
}

class _AuthConfirmSheetState extends State<AuthConfirmSheet> {
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
                          CaseChange.toUpperCase(
                              (widget.link.isEmpty) ? AppLocalization.of(context)!.sending : AppLocalization.of(context)!.creatingGiftCard, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
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
                            text: getThemeAwareRawAccuracy(context, widget.handoffItem.amount),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: getRawAsThemeAwareFormattedAmount(context, widget.handoffItem.amount),
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

                  // "TO" text
                  if (widget.link.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            CaseChange.toUpperCase(AppLocalization.of(context)!.to, context),
                            style: AppStyles.textStyleHeader(context),
                          ),
                        ],
                      ),
                    ),
                  // Address text
                  if (widget.link.isEmpty)
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: StateContainer.of(context).curTheme.backgroundDarkest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: UIUtil.threeLineAddressText(context, widget.destination, contactName: widget.contactName)),
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
                        context, AppButtonType.PRIMARY, CaseChange.toUpperCase(AppLocalization.of(context)!.confirm, context), Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      // Authenticate
                      final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                      final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();

                      final String authText = AppLocalization.of(context)!
                          .sendAmountConfirm
                          .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.handoffItem.amount))
                          .replaceAll("%2", StateContainer.of(context).currencyMode);

                      if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                        try {
                          final bool authenticated = await sl.get<BiometricUtil>().authenticateWithBiometrics(context, authText);
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
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, CaseChange.toUpperCase(AppLocalization.of(context)!.cancel, context),
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
    bool memoSendFailed = false;
    try {
      final String walletAddress = StateContainer.of(context).wallet!.address!;

      _showAnimation(context, AnimationType.SEND);

      // ProcessResponse? resp = await sl.get<AccountService>().requestSend(
      //     StateContainer.of(context).wallet!.representative,
      //     StateContainer.of(context).wallet!.frontier,
      //     widget.authItem.amount,
      //     widget.destination,
      //     StateContainer.of(context).wallet!.address,
      //     NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!),
      //     max: widget.maxSend);
      // StateContainer.of(context).wallet!.frontier = resp.hash;
      // StateContainer.of(context).wallet!.accountBalance += BigInt.parse(widget.authItem.amount!);

      // construct the response to the server:
      String? url;
      for (final Method method in widget.authItem.methods) {
        if (method.type == "http") {
          url = method.url;
        }
      }

      if (url != null) {
        // found a method we support:

      }

      // HandoffResponse? = await sl.get<AccountService>.requestHandoff(
      //     StateContainer.of(context).wallet!.representative,
      //     StateContainer.of(context).wallet!.frontier,
      //     widget.handoffItem.amount,
      //     widget.destination,
      //     StateContainer.of(context).wallet!.address,
      //     NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!),
      //     max: widget.maxSend);

      // Show complete
      String? contactName = widget.contactName;
      if (widget.contactName == null || widget.contactName!.isEmpty) {
        final User? user = await sl.get<DBHelper>().getUserWithAddress(widget.destination);
        if (user != null) {
          contactName = user.getDisplayName();
        }
      }

      StateContainer.of(context).requestUpdate();
      StateContainer.of(context).updateTXMemos();
      StateContainer.of(context).updateUnified(true);

      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      Sheets.showAppHeightNineSheet(
          context: context,
          closeOnTap: true,
          removeUntilHome: true,
          widget: AuthCompleteSheet(
            label: widget.authItem.label,
          ));
    } catch (error) {
      sl.get<Logger>().d("send_confirm_error: $error");
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      if (widget.link.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: widget.link));
        UIUtil.showSnackbar(AppLocalization.of(context)!.giftCardCreationErrorSent, context, durationMs: 20000);
        Navigator.of(context).pop();
        return;
      }
      UIUtil.showSnackbar(AppLocalization.of(context)!.sendError, context, durationMs: 5000);
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
        description: AppLocalization.of(context)!.authConfirm,
      );
    }));
    if (auth != null && auth) {
      await Future.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
