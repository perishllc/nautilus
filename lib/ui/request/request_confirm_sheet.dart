import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/metadata_service.dart';
import 'package:wallet_flutter/network/model/status_types.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/request/request_complete_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/security.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/biometrics.dart';
import 'package:wallet_flutter/util/box.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:uuid/uuid.dart';

class RequestConfirmSheet extends StatefulWidget {
  const RequestConfirmSheet({required this.amountRaw, required this.destination, this.contactName, this.localCurrency, this.memo}) : super();

  final String amountRaw;
  final String destination;
  final String? contactName;
  final String? localCurrency;
  final String? memo;

  @override
  _RequestConfirmSheetState createState() => _RequestConfirmSheetState();
}

class _RequestConfirmSheetState extends State<RequestConfirmSheet> {
  late bool animationOpen;

  StreamSubscription<AuthenticatedEvent>? _authSub;
  bool clicking = false;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton().registerTo<AuthenticatedEvent>().listen((AuthenticatedEvent event) {
      if (event.authType == AUTH_EVENT_TYPE.REQUEST) {
        _doRequest();
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

  void _showAnimation(BuildContext context) {
    animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.REQUEST, onPoppedCallback: () => animationOpen = false);
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
                  // "REQUESTING" TEXT
                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(Z.of(context).requesting, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Container for the amount text
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
                            text: getThemeAwareRawAccuracy(context, widget.amountRaw),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: getRawAsThemeAwareAmount(context, widget.amountRaw),
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
                  // "FROM" text
                  Container(
                    margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(Z.of(context).from, context),
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
                  if (widget.memo != null && widget.memo!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            CaseChange.toUpperCase(Z.of(context).withMessage, context),
                            style: AppStyles.textStyleHeader(context),
                          ),
                        ],
                      ),
                    ),
                  if (widget.memo != null && widget.memo!.isNotEmpty)
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: StateContainer.of(context).curTheme.backgroundDarkest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          widget.memo!,
                          style: AppStyles.textStyleParagraph(context),
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
                        context, AppButtonType.PRIMARY, CaseChange.toUpperCase(Z.of(context).confirm, context), Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      if (clicking) return;
                      clicking = true;
                      // Authenticate
                      final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                      final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
                      if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                        if (!mounted) return;
                        try {
                          final bool authenticated = await sl.get<BiometricUtil>().authenticateWithBiometrics(
                              context,
                              Z.of(context)
                                  .requestAmountConfirm
                                  .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
                                  .replaceAll("%2", StateContainer.of(context).currencyMode));
                          if (authenticated) {
                            sl.get<HapticUtil>().fingerprintSucess();
                            EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.REQUEST));
                          }
                        } catch (e) {
                          await authenticateWithPin();
                        }
                      } else if (authMethod.method == AuthMethod.PIN) {
                        await authenticateWithPin();
                      } else {
                        EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.REQUEST));
                      }
                      clicking = false;
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

  Future<void> _doRequest() async {
    bool sendFailed = false;
    try {
      _showAnimation(context);

      final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
      final String privKey = await NanoUtil.uniSeedToPrivate(
        await StateContainer.of(context).getSeed(),
        StateContainer.of(context).selectedAccount!.index!,
        derivationMethod,
      );

      // get epoch time as hex:
      final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
      final String nonceHex = secondsSinceEpoch.toRadixString(16);
      final String signature = NanoSignatures.signBlock(nonceHex, privKey);
      // check validity locally:
      final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
      final bool isValid = NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
      if (!isValid) {
        throw Exception("Invalid signature?!");
      }

      const Uuid uuid = Uuid();
      final String localUuid = "LOCAL:${uuid.v4()}";
      // current block height:
      final int currentBlockHeightInList =
          StateContainer.of(context).wallet!.history.isNotEmpty ? (StateContainer.of(context).wallet!.history[0].height! + 1) : 1;
      final String? lastBlockHash = StateContainer.of(context).wallet!.history.isNotEmpty ? StateContainer.of(context).wallet!.history[0].hash : null;

      // create a local txData for the request:
      final TXData newRequestTXData = TXData(
        from_address: StateContainer.of(context).wallet!.address,
        to_address: widget.destination,
        amount_raw: widget.amountRaw,
        uuid: localUuid,
        block: lastBlockHash,
        is_acknowledged: false,
        is_fulfilled: false,
        is_request: true,
        is_memo: false,
        is_message: false,
        request_time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        memo: widget.memo,
        height: currentBlockHeightInList,
      );
      // add it to the database:
      await sl.get<DBHelper>().addTXData(newRequestTXData);

      try {
        // encrypt the memo:
        String? encryptedMemo;
        if (widget.memo != null && widget.memo!.isNotEmpty) {
          encryptedMemo = Box.encrypt(widget.memo!, widget.destination, privKey);
        }

        await sl
            .get<MetadataService>()
            .requestPayment(widget.destination, widget.amountRaw, StateContainer.of(context).wallet!.address, signature, nonceHex, encryptedMemo, localUuid);
      } catch (e) {
        sl.get<Logger>().e("payment request failed: ${e.toString()}");
        sendFailed = true;
      }

      // if the send failed:
      if (sendFailed) {
        // update the status:
        newRequestTXData.status = StatusTypes.CREATE_FAILED;
        await sl.get<DBHelper>().replaceTXDataByUUID(newRequestTXData);
        // await sl.get<DBHelper>().deleteTXDataByUUID(local_uuid);
        // sleep for 2 seconds so the animation finishes otherwise the UX is weird:
        await Future<dynamic>.delayed(const Duration(seconds: 2));
        // update the list view:
        await StateContainer.of(context).updateSolids();
        await StateContainer.of(context).updateUnified(true);
        // go to home and show error:
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
        UIUtil.showSnackbar(Z.of(context).requestError, context, durationMs: 5500);
      } else {
        sl.get<Logger>().v("request succeeded");

        // update the status:
        newRequestTXData.status = StatusTypes.CREATE_SUCCESS;
        await sl.get<DBHelper>().replaceTXDataByUUID(newRequestTXData);

        // Show complete
        // todo: there's a potential memory leak with contacts somewhere here?
        String? contactName = widget.contactName;
        if (widget.contactName == null || widget.contactName!.isEmpty) {
          final User? user = await sl.get<DBHelper>().getUserWithAddress(widget.destination);
          if (user != null) {
            contactName = user.getDisplayName();
          }
        }

        // update the list view:
        await StateContainer.of(context).updateSolids();
        await StateContainer.of(context).updateUnified(false);

        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
        StateContainer.of(context).requestUpdate();

        Sheets.showAppHeightNineSheet(
            context: context,
            closeOnTap: true,
            removeUntilHome: true,
            widget: RequestCompleteSheet(
              amountRaw: widget.amountRaw,
              destination: widget.destination,
              contactName: contactName,
              localAmount: widget.localCurrency,
            ));
      }
    } catch (e) {
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      sendFailed = true;
      UIUtil.showSnackbar(Z.of(context).requestError, context, durationMs: 3500);
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
        description: Z.of(context)
            .sendAmountConfirm
            .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
            .replaceAll("%2", StateContainer.of(context).currencyMode),
      );
    }));
    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.REQUEST));
    }
  }
}
