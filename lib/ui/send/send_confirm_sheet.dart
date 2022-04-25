import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:manta_dart/messages.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';

import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/contact.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/box.dart';
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

class SendConfirmSheet extends StatefulWidget {
  final String amountRaw;
  final String destination;
  final String contactName;
  final String localCurrency;
  final bool maxSend;
  final MantaWallet manta;
  final PaymentRequestMessage paymentRequest;
  final int natriconNonce;
  final String memo;

  SendConfirmSheet(
      {this.amountRaw,
      this.destination,
      this.contactName,
      this.localCurrency,
      this.manta,
      this.paymentRequest,
      this.natriconNonce,
      this.maxSend = false,
      this.memo})
      : super();

  _SendConfirmSheetState createState() => _SendConfirmSheetState();
}

class _SendConfirmSheetState extends State<SendConfirmSheet> {
  String amount;
  String destinationAltered;
  bool animationOpen;
  bool isMantaTransaction;

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
    this.isMantaTransaction = widget.manta != null && widget.paymentRequest != null;
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
                          CaseChange.toUpperCase(AppLocalization.of(context).sending, context),
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
                  // "TO" text
                  Container(
                    margin: EdgeInsets.only(top: 30.0, bottom: 10),
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
                      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: isMantaTransaction
                          ? Column(
                              children: <Widget>[
                                AutoSizeText(
                                  widget.paymentRequest.merchant.name,
                                  minFontSize: 12,
                                  stepGranularity: 0.1,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.headerPrimary(context),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                AutoSizeText(
                                  widget.paymentRequest.merchant.address,
                                  minFontSize: 10,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  stepGranularity: 0.1,
                                  style: AppStyles.addressText(context),
                                ),
                                Container(
                                  margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context).curTheme.text30,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsetsDirectional.only(start: 10, end: 20),
                                        child: Icon(
                                          AppIcons.appia,
                                          color: StateContainer.of(context).curTheme.text30,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context).curTheme.text30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                smallScreen(context)
                                    ? UIUtil.oneLineAddressText(context, destinationAltered)
                                    : UIUtil.threeLineAddressText(context, destinationAltered)
                              ],
                            )
                          : UIUtil.threeLineAddressText(context, destinationAltered, contactName: widget.contactName)),
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
    bool memoSendFailed = false;
    try {
      _showSendingAnimation(context);
      // ProcessResponse resp = await sl.get<AccountService>().requestSend(
      //     StateContainer.of(context).wallet.representative,
      //     StateContainer.of(context).wallet.frontier,
      //     widget.amountRaw,
      //     destinationAltered,
      //     StateContainer.of(context).wallet.address,
      //     NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount.index),
      //     max: widget.maxSend);
      // if (widget.manta != null) {
      //   widget.manta.sendPayment(transactionHash: resp.hash, cryptoCurrency: "NANO");
      // }
      // StateContainer.of(context).wallet.frontier = resp.hash;
      // StateContainer.of(context).wallet.accountBalance += BigInt.parse(widget.amountRaw);

      // if there's a memo to be sent, send it:
      if (widget.memo != null && widget.memo.isNotEmpty) {
        String privKey = NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount.index);
        // get epoch time as hex:
        int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
        String nonce_hex = secondsSinceEpoch.toRadixString(16);
        String signature = NanoSignatures.signBlock(nonce_hex, privKey);

        // check validity locally:
        String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet?.address);
        bool isValid = NanoSignatures.validateSig(nonce_hex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
        if (!isValid) {
          throw Exception("Invalid signature?!");
        }

        // create a local memo object:
        var uuid = Uuid();
        String localUuid = "LOCAL:" + uuid.v4();
        // // current block height:
        // int currentBlockHeightInList = StateContainer.of(context).wallet.history.length > 0 ? (StateContainer.of(context).wallet.history[0].height + 1) : 1;
        // var newRequestTXData = new TXData(
        //   from_address: StateContainer.of(context).wallet.address,
        //   to_address: destinationAltered,
        //   amount_raw: widget.amountRaw,
        //   uuid: localUuid,
        //   block: resp.hash,
        //   is_acknowledged: false,
        //   is_fulfilled: false,
        //   is_request: false,
        //   request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        //   memo: widget.memo,
        //   height: currentBlockHeightInList,
        // );
        // // add it to the database:
        // await sl.get<DBHelper>().addTXData(newRequestTXData);

        try {
          print("sending memo now!");

          // encrypt the memo:
          // this is easily the worst code I've ever written.
          print("box.encrypt(\"${widget.memo}\", \"${destinationAltered}\", \"${privKey}\");");
          String builtExpression = await rootBundle.loadString("assets/nano-lib.js") + "box.encrypt(\"${widget.memo}\", \"${destinationAltered}\", \"${privKey}\");";
          JsEvalResult jsResult = StateContainer.of(context).flutterJs.evaluate(builtExpression);

          String encryptedMemo = jsResult.stringResult;

          print("encrypted memo: ${encryptedMemo}");

          // await sl
          //     .get<AccountService>()
          //     .sendTXMemo(destinationAltered, StateContainer.of(context).wallet.address, widget.amountRaw, signature, nonce_hex, widget.memo, resp.hash);
        } catch (e) {
          memoSendFailed = true;
        }

        // if the memo send failed delete the object:
        if (memoSendFailed) {
          print("memo send failed, deleting TXData object");
          // remove from the database:
          await sl.get<DBHelper>().deleteTXDataByUuid(localUuid);
        } else {
          // hack to get tx memo to update:
          EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: null));
        }
      }

      // // go through and check to see if any unfulfilled payments are now fulfilled
      // List<TXData> unfulfilledPayments = await sl.get<DBHelper>().getUnfulfilledTXs();
      // for (int i = 0; i < unfulfilledPayments.length; i++) {
      //   TXData txData = unfulfilledPayments[i];

      //   // TX is unfulfilled and in the past:
      //   // int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      //   // if (currentTime - int.parse(txData.request_time) > 0) {
      //   // }
      //   // check destination of this request is where we're sending to:
      //   // check to make sure we are the recipient of this request:
      //   // check to make sure the amounts are the same:
      //   if (txData.from_address == destinationAltered &&
      //       txData.to_address == StateContainer.of(context).wallet.address &&
      //       txData.amount_raw == widget.amountRaw) {
      //     // this is the payment we're fulfilling
      //     // update the TXData to be fulfilled
      //     await sl.get<DBHelper>().changeTXFulfillmentStatus(txData.uuid, true);
      //     // update the ui to reflect the change in the db:
      //     StateContainer.of(context).updateRequests();
      //     break;
      //   }
      // }

      // // Show complete
      // dynamic user = await sl.get<DBHelper>().getUserOrContactWithAddress(widget.destination);
      // String contactName;
      // if (user != null) {
      //   if (user is Contact) {
      //     contactName = "★" + user.name;
      //   } else if (user is User) {
      //     contactName = "@" + user.username;
      //   }
      // }

      // if (memoSendFailed) {
      //   UIUtil.showSnackbar(AppLocalization.of(context).sendMemoError, context, durationMs: 5000);
      // }

      // Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      // StateContainer.of(context).requestUpdate();
      // if (widget.natriconNonce != null) {
      //   setState(() {
      //     StateContainer.of(context).updateNatriconNonce(StateContainer.of(context).selectedAccount.address, widget.natriconNonce);
      //   });
      // }
      // Sheets.showAppHeightNineSheet(
      //     context: context,
      //     closeOnTap: true,
      //     removeUntilHome: true,
      //     widget: SendCompleteSheet(
      //         amountRaw: widget.amountRaw,
      //         destination: destinationAltered,
      //         contactName: contactName,
      //         localAmount: widget.localCurrency,
      //         paymentRequest: widget.paymentRequest,
      //         natriconNonce: widget.natriconNonce));
    } catch (e) {
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
