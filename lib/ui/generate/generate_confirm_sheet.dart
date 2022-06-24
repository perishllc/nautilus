import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/authentication_method.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/record_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/network/model/status_types.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/generate/generate_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
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
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:uuid/uuid.dart';

class GenerateConfirmSheet extends StatefulWidget {
  final String? amountRaw;
  final String? destination;
  final String? paperWalletSeed;
  final String? memo;
  final String? localCurrency;
  final bool maxSend;

  GenerateConfirmSheet({this.amountRaw, this.destination, this.paperWalletSeed, this.memo, this.localCurrency, this.maxSend = false}) : super();

  _GenerateConfirmSheetState createState() => _GenerateConfirmSheetState();
}

class _GenerateConfirmSheetState extends State<GenerateConfirmSheet> {
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

  void _showAnimation(BuildContext context) {
    animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.GENERATE, onPoppedCallback: () => animationOpen = false);
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
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(AppLocalization.of(context)!.creatingGiftCard, context),
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
                        text: '',
                        children: [
                          TextSpan(
                            text: getThemeAwareRawAccuracy(context, widget.amountRaw),
                            style: AppStyles.textStyleAddressPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleAddressPrimary(context),
                          ),
                          TextSpan(
                            text: getRawAsThemeAwareAmount(context, widget.amountRaw),
                            style: AppStyles.textStyleAddressPrimary(context),
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

                  if (widget.memo != null)
                    Container(
                      margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            CaseChange.toUpperCase(AppLocalization.of(context)!.withMessage, context),
                            style: AppStyles.textStyleHeader(context),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(),
                  if (widget.memo != null)
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
                        ))
                  else
                    const SizedBox(),
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
                        final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                        final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
                        if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                          try {
                            bool authenticated = await sl.get<BiometricUtil>().authenticateWithBiometrics(
                                context,
                                AppLocalization.of(context)!
                                    .sendAmountConfirm
                                    .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
                                    .replaceAll("%2", StateContainer.of(context).currencyMode));
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
      _showAnimation(context);
      final ProcessResponse resp = await sl.get<AccountService>().requestSend(
          StateContainer.of(context).wallet!.representative,
          StateContainer.of(context).wallet!.frontier,
          widget.amountRaw,
          widget.destination,
          StateContainer.of(context).wallet!.address,
          NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!),
          max: widget.maxSend);

      StateContainer.of(context).wallet!.frontier = resp.hash;
      StateContainer.of(context).wallet!.accountBalance += BigInt.parse(widget.amountRaw!);

      final String memo = widget.memo ?? "";

      final BranchUniversalObject buo = BranchUniversalObject(
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
            ..addCustomMetadata('address', widget.destination)
            ..addCustomMetadata('memo', widget.memo ?? "")
            ..addCustomMetadata('senderAddress', StateContainer.of(context).wallet!.address) // TODO: sign these:
            ..addCustomMetadata('signature', "")
            ..addCustomMetadata('nonce', "")
            ..addCustomMetadata('amount_raw', widget.amountRaw));

      final BranchLinkProperties lp = BranchLinkProperties(
          //alias: 'flutterplugin', //define link url,
          channel: 'nautilusapp',
          feature: 'gift',
          stage: 'new share');

      final BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
      if (response.success) {
        // create a local memo object to show the gift card creation details:
        const Uuid uuid = Uuid();
        final TXData newGiftTXData = TXData(
          from_address: StateContainer.of(context).wallet!.address,
          to_address: widget.destination,
          amount_raw: widget.amountRaw,
          uuid: "LOCAL:${uuid.v4()}",
          block: resp.hash,
          record_type: RecordTypes.GIFT_LOAD,
          status: "created",
          metadata: widget.paperWalletSeed! + RecordTypes.SEPARATOR + (response.result as String),
          is_acknowledged: false,
          is_fulfilled: false,
          is_request: false,
          is_memo: false,
          request_time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          memo: widget.memo,
          height: 0,
        );
        // add it to the database:
        await sl.get<DBHelper>().addTXData(newGiftTXData);
        await StateContainer.of(context).updateTXMemos();

        // Show complete
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
        StateContainer.of(context).requestUpdate();

        Sheets.showAppHeightNineSheet(
            context: context,
            closeOnTap: false,
            removeUntilHome: true,
            widget: GenerateCompleteSheet(
              amountRaw: widget.amountRaw,
              destination: widget.destination,
              localAmount: widget.localCurrency,
              sharableLink: response.result as String,
              walletSeed: widget.paperWalletSeed,
            ));
      } else {
        print('Error : ${response.errorCode} - ${response.errorMessage}');
        // attempt to refund the transaction?!:
        await AppTransferOverviewSheet().startAutoTransfer(context, widget.paperWalletSeed!, StateContainer.of(context).wallet);

        // create a local memo object to show the gift card creation details:
        const Uuid uuid = const Uuid();
        final TXData newGiftTXData = TXData(
          from_address: StateContainer.of(context).wallet!.address,
          to_address: widget.destination,
          amount_raw: widget.amountRaw,
          uuid: "LOCAL:${uuid.v4()}",
          block: resp.hash,
          record_type: RecordTypes.GIFT_LOAD,
          status: StatusTypes.CREATE_FAILED,
          metadata: widget.paperWalletSeed! + RecordTypes.SEPARATOR + StatusTypes.CREATE_FAILED,
          is_acknowledged: false,
          is_fulfilled: false,
          is_request: false,
          is_memo: false,
          request_time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          memo: widget.memo,
          height: 0,
        );
        // add it to the database:
        await sl.get<DBHelper>().addTXData(newGiftTXData);
        await StateContainer.of(context).updateTXMemos();
      }
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
    final String? expectedPin = await sl.get<Vault>().getPin();
    final bool? auth = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        description: AppLocalization.of(context)!
            .sendAmountConfirmPin
            .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
            .replaceAll("%2", StateContainer.of(context).currencyMode),
      );
    }));
    if (auth != null && auth) {
      await Future.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
