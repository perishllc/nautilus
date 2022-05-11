import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:manta_dart/messages.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';

import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/contact.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/record_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/ui/generate/generate_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
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
import 'package:nautilus_wallet_flutter/themes.dart';
import 'package:uuid/uuid.dart';

class GenerateConfirmSheet extends StatefulWidget {
  final String amountRaw;
  final String destination;
  final String paperWalletSeed;
  final String memo;
  final String localCurrency;
  final bool maxSend;

  GenerateConfirmSheet({this.amountRaw, this.destination, this.paperWalletSeed, this.memo, this.localCurrency, this.maxSend = false}) : super();

  _GenerateConfirmSheetState createState() => _GenerateConfirmSheetState();
}

class _GenerateConfirmSheetState extends State<GenerateConfirmSheet> {
  String amount;
  String destinationAltered;
  bool animationOpen;

  StreamSubscription<AuthenticatedEvent> _authSub;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton().registerTo<AuthenticatedEvent>().listen((event) {
      if (event.authType == AUTH_EVENT_TYPE.SEND) {
        _doSend();
      }
    });
  }

  void _destroyBus() {
    if (_authSub != null) {
      _authSub.cancel();
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
    destinationAltered = widget.destination.replaceAll("xrb_", "nano_");
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _showSendingAnimation(BuildContext context) {
    animationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.SEND, StateContainer.of(context).curTheme.animationOverlayStrong, StateContainer.of(context).curTheme.animationOverlayMedium,
        onPoppedCallback: () => animationOpen = false));
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
                  // "SENDING" TEXT
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(AppLocalization.of(context).creatingGiftCard, context),
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
                        text: '',
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
                              color: StateContainer.of(context).curTheme.primary.withOpacity(0.75),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  (widget.memo != null)
                      ? (
                          // "TO" text
                          Container(
                          margin: EdgeInsets.only(top: 30.0, bottom: 10),
                          child: Column(
                            children: <Widget>[
                              Text(
                                CaseChange.toUpperCase(AppLocalization.of(context).withMessage, context),
                                style: AppStyles.textStyleHeader(context),
                              ),
                            ],
                          ),
                        ))
                      : Container(),
                  (widget.memo != null)
                      ?
                      // memo text
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: StateContainer.of(context).curTheme.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            widget.memo,
                            style: AppStyles.textStyleParagraph(context),
                            textAlign: TextAlign.center,
                          ))
                      : Container(),
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
                          context, AppButtonType.PRIMARY, CaseChange.toUpperCase(AppLocalization.of(context).confirm, context), Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () async {
                        // Authenticate
                        AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                        bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
                        if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                          try {
                            bool authenticated = await sl
                                .get<BiometricUtil>()
                                .authenticateWithBiometrics(context, AppLocalization.of(context).sendAmountConfirm.replaceAll("%1", amount));
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
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, CaseChange.toUpperCase(AppLocalization.of(context).cancel, context),
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
          StateContainer.of(context).wallet.representative,
          StateContainer.of(context).wallet.frontier,
          widget.amountRaw,
          destinationAltered,
          StateContainer.of(context).wallet.address,
          NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount.index),
          max: widget.maxSend);

      StateContainer.of(context).wallet.frontier = resp.hash;
      StateContainer.of(context).wallet.accountBalance += BigInt.parse(widget.amountRaw);

      String memo = widget.memo != null ? widget.memo : ""; 

      BranchUniversalObject buo = BranchUniversalObject(
          canonicalIdentifier: 'flutter/branch',
          //canonicalUrl: '',
          title: 'Nautilus Gift Card',
          // imageUrl: 'https://flutter.dev/assets/flutter-lockup-4cb0ee072ab312e59784d9fbf4fb7ad42688a7fdaea1270ccf6bbf4f34b7e03f.svg',
          contentDescription: 'Get the app to open this gift card!',
          keywords: ['Nautilus', "Gift Card"],
          publiclyIndex: true,
          locallyIndex: true,
          contentMetadata: BranchContentMetaData()
            ..addCustomMetadata('seed', widget.paperWalletSeed)
            ..addCustomMetadata('address', destinationAltered)
            ..addCustomMetadata('memo', widget.memo ?? "")
            ..addCustomMetadata('senderAddress', StateContainer.of(context).wallet.address) // TODO: sign these:
            ..addCustomMetadata('signature', "")
            ..addCustomMetadata('nonce', "")
            ..addCustomMetadata('amount_raw', widget.amountRaw));

      BranchLinkProperties lp = BranchLinkProperties(
          //alias: 'flutterplugin', //define link url,
          channel: 'nautilusapp',
          feature: 'gift',
          stage: 'new share');

      BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
      if (response.success) {
        // create a local memo object to show the gift card creation details:
        var uuid = Uuid();
        var newGiftTXData = new TXData(
          from_address: StateContainer.of(context).wallet.address,
          to_address: destinationAltered,
          amount_raw: widget.amountRaw,
          uuid: "LOCAL:" + uuid.v4(),
          block: resp.hash,
          record_type: RecordTypes.GIFT_LOAD,
          status: "created",
          metadata: widget.paperWalletSeed + "^" + response.result,
          is_acknowledged: false,
          is_fulfilled: false,
          is_request: false,
          is_memo: false,
          request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          memo: widget.memo,
          height: 0,
        );
        // add it to the database:
        await sl.get<DBHelper>().addTXData(newGiftTXData);
        // hack to get tx memo to update:
        EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: null));

        // Show complete
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
        StateContainer.of(context).requestUpdate();

        Sheets.showAppHeightNineSheet(
            context: context,
            closeOnTap: false,
            removeUntilHome: true,
            widget: GenerateCompleteSheet(
              amountRaw: widget.amountRaw,
              destination: destinationAltered,
              localAmount: widget.localCurrency,
              sharableLink: response.result,
              walletSeed: widget.paperWalletSeed,
            ));
      } else {
        print('Error : ${response.errorCode} - ${response.errorMessage}');
        // attempt to refund the transaction?!:
        await AppTransferOverviewSheet().startAutoTransfer(context, widget.paperWalletSeed, StateContainer.of(context).wallet);

        // create a local memo object to show the gift card creation details:
        var uuid = Uuid();
        var newGiftTXData = new TXData(
          from_address: StateContainer.of(context).wallet.address,
          to_address: destinationAltered,
          amount_raw: widget.amountRaw,
          uuid: "LOCAL:" + uuid.v4(),
          block: resp.hash,
          record_type: RecordTypes.GIFT_LOAD,
          status: "create_failed",
          metadata: widget.paperWalletSeed + "^" + "failed",
          is_acknowledged: false,
          is_fulfilled: false,
          is_request: false,
          is_memo: false,
          request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          memo: widget.memo,
          height: 0,
        );
        // add it to the database:
        await sl.get<DBHelper>().addTXData(newGiftTXData);
        // hack to get tx memo to update:
        EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: null));
      }
    } catch (e) {
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(AppLocalization.of(context).sendError, context);
      Navigator.of(context).pop();
    }
  }

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    String expectedPin = await sl.get<Vault>().getPin();
    bool auth = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return new PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        description: AppLocalization.of(context).sendAmountConfirmPin.replaceAll("%1", amount),
      );
    }));
    if (auth != null && auth) {
      await Future.delayed(Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
