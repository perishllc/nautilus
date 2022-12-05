import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/authentication_method.dart';
import 'package:nautilus_wallet_flutter/model/method.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/auth_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/handoff_response.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/auth/auth_complete_sheet.dart';
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

  @override
  AuthConfirmSheetState createState() => AuthConfirmSheetState();
}

class AuthConfirmSheetState extends State<AuthConfirmSheet> {
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
                          CaseChange.toUpperCase(Z.of(context).authenticating, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  if (widget.authItem.label.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
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
                              text: widget.authItem.label,
                              style: AppStyles.textStyleParagraphPrimary(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.authItem.message.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
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
                              text: widget.authItem.message,
                              style: AppStyles.textStyleParagraphPrimary(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.authItem.nonce.isNotEmpty)
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
                          text: widget.authItem.nonce,
                          style: AppStyles.textStyleParagraphPrimary(context),
                        ),
                      ),
                    ),

                  // "FOR" text
                  Container(
                    margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(Z.of(context).registerFor, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Address text
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
                        context, AppButtonType.PRIMARY, CaseChange.toUpperCase(Z.of(context).confirm, context), Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      // Authenticate
                      final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                      final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();

                      if (!mounted) return;

                      final String authText = Z.of(context).authConfirm;

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
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, CaseChange.toUpperCase(Z.of(context).cancel, context),
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
    final bool memoSendFailed = false;
    String? poppedError;
    try {
      final String walletAddress = StateContainer.of(context).wallet!.address!;

      _showAnimation(context, AnimationType.SEND);

      String? url;
      for (final Method method in widget.authItem.methods) {
        if (method.type == "http") {
          url = method.url;
        }
      }

      if (url == null) {
        // no method we support:
        poppedError = Z.of(context).handoffSupportedMethodNotFound;
        throw Exception("No supported method found");
      }

      // construct the response to the server:
      String stringToSign = "";
      for (final String formatType in widget.authItem.format) {
        if (stringToSign.isNotEmpty) {
          stringToSign += widget.authItem.separator;
        }
        switch (formatType) {
          case "timestamp":
            stringToSign += "${DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond}";
            break;
          case "label":
            stringToSign += widget.authItem.label;
            break;
          case "message":
            stringToSign += widget.authItem.message;
            break;
          case "nonce":
            stringToSign += widget.authItem.nonce;
            break;
          case "account":
            stringToSign += widget.authItem.account;
            break;
        }
      }

      final String formatted = stringToSign;
      final String signed = NanoHelpers.byteToHex(NanoHelpers.stringToBytesUtf8(stringToSign));

      final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();

      final String privKey = await NanoUtil.uniSeedToPrivate(
        await StateContainer.of(context).getSeed(),
        StateContainer.of(context).selectedAccount!.index!,
        derivationMethod,
      );
      final String signature = NanoSignatures.signBlock(signed, privKey);
      // final String pubKey = NanoAccounts.extractPublicKey(walletAddress);
      // final bool isValid = NanoSignatures.validateSig(signed, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));

      final HandoffResponse authResponse = await sl.get<AccountService>().requestAuthHTTP(
            url,
            walletAddress,
            signature,
            signed,
            formatted,
            message: widget.authItem.message,
            label: widget.authItem.label,
          );

      if (!mounted) return;

      if (authResponse.status != 0) {
        poppedError = authResponse.message;
        throw Exception("Auth failed");
      }

      // Show complete

      if (!mounted) return;

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
      sl.get<Logger>().d("auth_confirm_error: $error");
      // Auth failed
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
