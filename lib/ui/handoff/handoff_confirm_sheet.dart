import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/method.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/response/handoff_response.dart';
import 'package:wallet_flutter/network/model/response/pay_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/handoff/handoff_complete_sheet.dart';
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

class HandoffConfirmSheet extends StatefulWidget {
  const HandoffConfirmSheet(
      {required this.payItem,
      required this.destination,
      this.contactName,
      this.localCurrency,
      this.maxSend = false,
      this.phoneNumber = "",
      this.paperWalletSeed = "",
      this.link = "",
      this.memo = ""})
      : super();

  final PayItem payItem;
  final String destination;
  final String? contactName;
  final String? localCurrency;
  final bool maxSend;
  // final bool isPhoneNumber;
  final String phoneNumber;
  final String link;
  final String paperWalletSeed;
  final String memo;

  @override
  HandoffConfirmSheetState createState() => HandoffConfirmSheetState();
}

class HandoffConfirmSheetState extends State<HandoffConfirmSheet> {
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
            //The main widget that holds the text fields, "SENDING" and "TO" texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // "HANDOFF" TEXT
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
                            text: getThemeAwareRawAccuracy(context, widget.payItem.amount),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: getRawAsThemeAwareFormattedAmount(context, widget.payItem.amount),
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
                  Container(
                    margin: const EdgeInsets.only(top: 20.0, bottom: 10),
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

                  // "FOR" TEXT
                  Container(
                    margin: const EdgeInsets.only(top: 20.0, bottom: 10),
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
                    // label text
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "",
                        children: [
                          TextSpan(
                            text: widget.payItem.label,
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: "\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: widget.payItem.message,
                            style: AppStyles.textStyleParagraphPrimary(context).copyWith(fontSize: AppFontSizes.small),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Container(
                  //   margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                  //   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //     color: StateContainer.of(context).curTheme.backgroundDarkest,
                  //     borderRadius: BorderRadius.circular(50),
                  //   ),
                  //   // message text
                  //   child: RichText(
                  //     textAlign: TextAlign.center,
                  //     text: TextSpan(
                  //       text: widget.payItem.message,
                  //       style: AppStyles.textStyleParagraphPrimary(context),
                  //     ),
                  //   ),
                  // ),
                  // RichText(
                  //   textAlign: TextAlign.center,
                  //   text: TextSpan(
                  //     text: widget.payItem.message,
                  //     style: AppStyles.textStyleParagraphPrimary(context),
                  //   ),
                  // ),
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

                      if (!mounted) return;

                      final String authText = Z
                          .of(context)
                          .sendAmountConfirm
                          .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.payItem.amount))
                          .replaceAll("%2", StateContainer.of(context).currencyMode);

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
    bool memoSendFailed = false;
    String? poppedError;
    try {
      final String walletAddress = StateContainer.of(context).wallet!.address!;

      _showAnimation(context, AnimationType.SEND);

      // ProcessResponse? resp = await sl.get<AccountService>().requestSend(
      //     StateContainer.of(context).wallet!.representative,
      //     StateContainer.of(context).wallet!.frontier,
      //     widget.payItem.amount,
      //     widget.destination,
      //     StateContainer.of(context).wallet!.address,
      //     NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!),
      //     max: widget.maxSend);
      // StateContainer.of(context).wallet!.frontier = resp.hash;
      // StateContainer.of(context).wallet!.accountBalance += BigInt.parse(widget.payItem.amount!);

      // check if we need to generate the PoW first:
      if (!widget.payItem.work) {
        // we must provide our own PoW:
        // TODO:
      }

      // construct the response to the server:
      String? handoffUrl;
      String? cancelUrl;

      for (final Method method in widget.payItem.methods) {
        if (method.type == "http") {
          switch (method.subtype) {
            case "handoff":
              handoffUrl = method.url;
              break;
            case "cancel":
              cancelUrl = method.url;
              break;
            default:
              handoffUrl = method.url;
              break;
          }
        }
      }

      if (handoffUrl == null) {
        // no method we support:
        poppedError = Z.of(context).handoffSupportedMethodNotFound;
        throw Exception("No supported method found");
      }

      // TODO: call cancel URL if we leave the screen:

      // construct the request:

      // print(url);
      // debug:
      // url = "http://node-local.perish.co:5076/handoff";

      final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
      final String privKey = await NanoUtil.uniSeedToPrivate(
        await StateContainer.of(context).getSeed(),
        StateContainer.of(context).selectedAccount!.index!,
        derivationMethod,
      );

      final HandoffResponse handoffResponse = await sl.get<AccountService>().requestHandoffHTTP(
            handoffUrl,
            StateContainer.of(context).wallet!.representative,
            StateContainer.of(context).wallet!.frontier,
            widget.payItem.amount,
            widget.destination,
            StateContainer.of(context).wallet!.address,
            privKey,
            metadata: widget.payItem.metadata,
          );

      if (!mounted) return;
      // StateContainer.of(context).wallet!.frontier = resp.hash;

      if (handoffResponse.status != 0) {
        poppedError = handoffResponse.message;
        throw Exception("Handoff failed");
      } else {
        StateContainer.of(context).wallet!.accountBalance -= BigInt.parse(widget.payItem.amount);
      }

      // Show complete
      String? contactName = widget.contactName;
      if (widget.contactName == null || widget.contactName!.isEmpty) {
        final User? user = await sl.get<DBHelper>().getUserWithAddress(widget.destination);
        if (user != null) {
          contactName = user.getDisplayName();
        }
      }

      if (!mounted) return;

      StateContainer.of(context).requestUpdate();
      StateContainer.of(context).updateTXMemos();
      StateContainer.of(context).updateUnified(true);

      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      Sheets.showAppHeightNineSheet(
          context: context,
          closeOnTap: true,
          removeUntilHome: true,
          widget: HandoffCompleteSheet(
              amountRaw: widget.payItem.amount,
              destination: widget.destination,
              contactName: contactName,
              memo: widget.memo,
              localAmount: widget.localCurrency));
    } catch (error) {
      sl.get<Logger>().d("handoff_confirm_error: $error");
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      if (poppedError != null) {
        UIUtil.showSnackbar(poppedError, context, durationMs: 5000);
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).sendError, context, durationMs: 5000);
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
        description: Z
            .of(context)
            .sendAmountConfirm
            .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.payItem.amount))
            .replaceAll("%2", StateContainer.of(context).currencyMode),
      );
    }));
    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
