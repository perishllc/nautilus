import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:nautilus_wallet_flutter/util/biometrics.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/model/authentication_method.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/security.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';

class RegisterConfirmSheet extends StatefulWidget {
  final String? amountRaw;
  final String? destination;
  final String? contactName;
  final String? userName;
  final String? localCurrency;
  final String? leaseDuration;
  final String? checkUrl;
  final String? username;
  final bool maxSend;

  RegisterConfirmSheet(
      {this.amountRaw,
      this.destination,
      this.contactName,
      this.userName,
      this.localCurrency,
      this.checkUrl,
      this.username,
      this.leaseDuration,
      this.maxSend = false})
      : super();

  _RegisterConfirmSheetState createState() => _RegisterConfirmSheetState();
}

class _RegisterConfirmSheetState extends State<RegisterConfirmSheet> {
  late String amount;
  String? destinationAltered;
  late bool animationOpen;

  StreamSubscription<AuthenticatedEvent>? _authSub;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton().registerTo<AuthenticatedEvent>().listen((event) {
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
    this.animationOpen = false;
    // Derive amount from raw amount
    // if (NumberUtil.getRawAsUsableString(widget.amountRaw).replaceAll(",", "") == NumberUtil.getRawAsUsableDecimal(widget.amountRaw).toString()) {
    //   amount = NumberUtil.getRawAsUsableString(widget.amountRaw);
    // } else {
    //   amount = NumberUtil.truncateDecimal(NumberUtil.getRawAsUsableDecimal(widget.amountRaw), digits: 6).toStringAsFixed(6) + "~";
    // }
    // if (NumberUtil.getRawAsUsableString(widget.amountRaw).replaceAll(",", "") == NumberUtil.getRawAsUsableDecimal(widget.amountRaw).toString()) {
    amount = NumberUtil.getRawAsUsableStringPrecise(widget.amountRaw);
    // Ensure nano_ prefix on destination
    destinationAltered = widget.destination!.replaceAll("xrb_", "nano_");
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _showSendingAnimation(BuildContext context) {
    animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.REGISTER_USERNAME, onPoppedCallback: () => animationOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // Sheet handle
            Container(
              margin: EdgeInsets.only(top: 10),
              height: 5,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.text10,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            //The main widget that holds the text fields, "SENDING" and "TO" texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // "REGISTERING" TEXT
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(AppLocalization.of(context)!.registering, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Address text
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: UIUtil.threeLineAddressText(context, StateContainer.of(context).wallet!.address!, contactName: "@" + widget.username!)),

                  // "FOR" text
                  Container(
                    margin: EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(AppLocalization.of(context)!.registerFor, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Container for the amount text
                  Container(
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // Amount text
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: widget.leaseDuration! + " : ",
                        children: [
                          displayCurrencyAmount(
                            context,
                            TextStyle(
                              color: StateContainer.of(context).curTheme.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          TextSpan(
                            text: getCurrencySymbol(context) + ((StateContainer.of(context).nyanoMode) ? NumberUtil.getNanoStringAsNyano(amount) : amount),
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                          TextSpan(
                            text: widget.localCurrency != null ? " (${widget.localCurrency})" : "",
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.primary!.withOpacity(0.75),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //A container for CONFIRM and CANCEL buttons
            Container(
              child: Column(
                children: <Widget>[
                  // A row for CONFIRM Button
                  Row(
                    children: <Widget>[
                      // CONFIRM Button
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, CaseChange.toUpperCase(AppLocalization.of(context)!.confirm, context), Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () async {
                        // Authenticate
                        AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                        bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
                        if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                          try {
                            bool authenticated = await sl
                                .get<BiometricUtil>()
                                .authenticateWithBiometrics(context, AppLocalization.of(context)!.sendAmountConfirm.replaceAll("%1", amount));
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
            ),
          ],
        ));
  }

  Future<void> _doSend() async {
    try {
      _showSendingAnimation(context);
      ProcessResponse resp = await sl.get<AccountService>().requestSend(
          StateContainer.of(context).wallet!.representative,
          StateContainer.of(context).wallet!.frontier,
          widget.amountRaw,
          destinationAltered,
          StateContainer.of(context).wallet!.address,
          NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!),
          max: widget.maxSend);
      StateContainer.of(context).wallet!.frontier = resp.hash;
      StateContainer.of(context).wallet!.accountBalance += BigInt.parse(widget.amountRaw!);

      // Update the state with the new balance
      StateContainer.of(context).requestUpdate();

      bool success = false;
      // store the current time:
      DateTime now = DateTime.now();

      // try until successful or timeout:
      while (success == false) {
        print("checking url: ${widget.checkUrl}");
        try {
          Map? resp = await (sl.get<AccountService>().checkUsernameUrl(widget.checkUrl!) as FutureOr<Map<dynamic, dynamic>?>);
          if (resp != null && resp["completed"] == true) {
            success = true;
          } else {
            // check if it's been more than 30 seconds:
            if (DateTime.now().difference(now).inSeconds > 30) {
              // TODO: store for trying again later:
              success = true;
            }
          }
        } catch (e) {
          print("Error with checkUrl: $e");
        }

        // sleep for a while before trying again:
        await new Future.delayed(const Duration(milliseconds: 3000));
      }

      // sleep for a while before updating the database:
      await new Future.delayed(const Duration(milliseconds: 5000));

      // force update the database:
      await StateContainer.of(context).checkAndCacheNapiDatabases(true);

      // refresh the wallet by just updating to the same account:
      await StateContainer.of(context).updateWallet(account: StateContainer.of(context).selectedAccount!);

      // Show complete
      // await StateContainer.of(context).requestUpdate();
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));

      Sheets.showAppHeightNineSheet(
          context: context,
          closeOnTap: true,
          removeUntilHome: true,
          widget: SendCompleteSheet(amountRaw: widget.amountRaw, destination: destinationAltered, localAmount: widget.localCurrency));
    } catch (e) {
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(AppLocalization.of(context)!.sendError, context);
      Navigator.of(context).pop();
    }
  }

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    String? expectedPin = await sl.get<Vault>().getPin();
    bool? auth = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return new PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        description: AppLocalization.of(context)!.sendAmountConfirmPin.replaceAll("%1", amount),
      );
    }));
    if (auth != null && auth) {
      await Future.delayed(Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
