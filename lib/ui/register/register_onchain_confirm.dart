import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/response/process_response.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/register/register_onchain_complete_sheet.dart';
import 'package:wallet_flutter/ui/send/send_complete_sheet.dart';
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

class RegisterOnchainConfirmSheet extends StatefulWidget {
  const RegisterOnchainConfirmSheet({
    required this.username,
  }) : super();

  final String username;

  @override
  _RegisterOnchainConfirmSheetState createState() => _RegisterOnchainConfirmSheetState();
}

class _RegisterOnchainConfirmSheetState extends State<RegisterOnchainConfirmSheet> {
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

  void _showSendingAnimation(BuildContext context) {
    animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.REGISTER_USERNAME,
        onPoppedCallback: () => animationOpen = false);
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
                  // "REGISTERING" TEXT
                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(Z.of(context).registering, context),
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
                      child: UIUtil.threeLineAddressText(context, StateContainer.of(context).wallet!.address!,
                          contactName: "@${widget.username!}")),

                  // "FOR" text
                  // Container(
                  //   margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                  //   child: Column(
                  //     children: <Widget>[
                  //       Text(
                  //         CaseChange.toUpperCase(Z.of(context).registerFor, context),
                  //         style: AppStyles.textStyleHeader(context),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Container for the amount text
                  // Container(
                  //   margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                  //   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //     color: StateContainer.of(context).curTheme.backgroundDarkest,
                  //     borderRadius: BorderRadius.circular(50),
                  //   ),
                  //   // Amount text
                  //   child: RichText(
                  //     textAlign: TextAlign.center,
                  //     text: TextSpan(
                  //       text: "${widget.leaseDuration!} : ",
                  //       children: [
                  //         TextSpan(
                  //           text: getThemeAwareRawAccuracy(context, widget.amountRaw),
                  //           style: AppStyles.textStyleAddressPrimary(context),
                  //         ),
                  //         displayCurrencySymbol(
                  //           context,
                  //           AppStyles.textStyleAddressPrimary(context),
                  //         ),
                  //         TextSpan(
                  //           text: getRawAsThemeAwareAmount(context, widget.amountRaw),
                  //           style: AppStyles.textStyleAddressPrimary(context),
                  //         ),
                  //         TextSpan(
                  //           text: widget.localCurrency != null ? " (${widget.localCurrency})" : "",
                  //           style: AppStyles.textStyleAddressPrimary(context).copyWith(
                  //             color: StateContainer.of(context).curTheme.primary!.withOpacity(0.75),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
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
                      if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                        if (!mounted) return;
                        try {
                          final bool authenticated = await sl.get<BiometricUtil>().authenticateWithBiometrics(
                                context,
                                Z.of(context).registerUsername,
                              );
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
    try {
      _showSendingAnimation(context);

      await sl.get<UsernameService>().registerUsernameToAccountMap(context, widget.username);
      await sl.get<UsernameService>().registerAccountToUsernameMap(context, widget.username);

      // sleep for a while before updating the database:
      await Future<dynamic>.delayed(const Duration(milliseconds: 2000));

      // refresh the wallet by just updating to the same account:
      await StateContainer.of(context).updateWallet(account: StateContainer.of(context).selectedAccount!);

      // Show complete
      // await StateContainer.of(context).requestUpdate();
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));

      Sheets.showAppHeightNineSheet(
          context: context,
          closeOnTap: true,
          removeUntilHome: true,
          widget: RegisterOnchainCompleteSheet(username: widget.username));
    } catch (e) {
      print(e.toString());
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).usernameError, context);
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
        description: Z.of(context).registerUsername,
      );
    }));
    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
