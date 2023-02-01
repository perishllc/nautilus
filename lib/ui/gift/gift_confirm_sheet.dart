import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/giftcards.dart';
import 'package:wallet_flutter/network/model/record_types.dart';
import 'package:wallet_flutter/network/model/response/process_response.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/security.dart';
import 'package:wallet_flutter/util/biometrics.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class GenerateConfirmSheet extends StatefulWidget {
  const GenerateConfirmSheet(
      {this.amountRaw = "",
      this.splitAmountRaw = "",
      this.destination = "",
      this.paperWalletSeed = "",
      this.memo = "",
      this.requireCaptcha = false,
      this.localCurrency,
      this.maxSend = false})
      : super();

  final String amountRaw;
  final String splitAmountRaw;
  final String destination;
  final String paperWalletSeed;
  final String memo;
  final bool requireCaptcha;
  final String? localCurrency;
  final bool maxSend;

  GenerateConfirmSheetState createState() => GenerateConfirmSheetState();
}

class GenerateConfirmSheetState extends State<GenerateConfirmSheet> {
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
            Handlebars.horizontal(context),
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
                          CaseChange.toUpperCase(Z.of(context).creatingGiftCard, context),
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

                  // "SPLIT BY" TEXT
                  if (widget.splitAmountRaw.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            CaseChange.toUpperCase(Z.of(context).splitBy, context),
                            style: AppStyles.textStyleHeader(context),
                          ),
                        ],
                      ),
                    ),

                  if (widget.splitAmountRaw.isNotEmpty)
                    // Container for the split amount text
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
                      // Split Amount text
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "",
                          children: [
                            TextSpan(
                              text: getThemeAwareRawAccuracy(context, widget.splitAmountRaw),
                              style: AppStyles.textStyleParagraphPrimary(context),
                            ),
                            displayCurrencySymbol(
                              context,
                              AppStyles.textStyleParagraphPrimary(context),
                            ),
                            TextSpan(
                              text: getRawAsThemeAwareAmount(context, widget.splitAmountRaw),
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

                  if (widget.memo.isNotEmpty)
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
                  if (widget.memo.isNotEmpty)
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
                          widget.memo,
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
                        context,
                        AppButtonType.PRIMARY,
                        CaseChange.toUpperCase(Z.of(context).confirm, context),
                        Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                      // Authenticate
                      final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                      final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
                      if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                        try {
                          if (!mounted) return;
                          final bool authenticated = await sl.get<BiometricUtil>().authenticateWithBiometrics(
                              context,
                              Z
                                  .of(context)
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
    String? branchLink;
    try {
      _showAnimation(context);
      final String walletAddress = StateContainer.of(context).wallet!.address!;

      // create link:
      // final BranchUniversalObject buo = BranchUniversalObject(
      //     canonicalIdentifier: 'flutter/branch',
      //     title: 'Nautilus Gift Card',
      //     contentDescription: 'Get the app to open this gift card!',
      //     keywords: ['Nautilus', "Gift Card"],
      //     publiclyIndex: true,
      //     locallyIndex: true,
      //     contentMetadata: BranchContentMetaData()
      //       ..addCustomMetadata('seed', widget.paperWalletSeed)
      //       ..addCustomMetadata('address', widget.destination)
      //       ..addCustomMetadata('memo', widget.memo)
      //       ..addCustomMetadata('senderAddress', StateContainer.of(context).wallet!.address) // TODO: sign these:
      //       ..addCustomMetadata('signature', "")
      //       ..addCustomMetadata('nonce', "")
      //       ..addCustomMetadata('amount_raw', widget.amountRaw));

      // final BranchLinkProperties lp = BranchLinkProperties(
      //     //alias: 'flutterplugin', //define link url,
      //     channel: 'nautilusapp',
      //     feature: 'gift',
      //     stage: 'new share');

      // final BranchResponse branchResponse = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

      BranchResponse<dynamic>? branchResponse;

      if (widget.splitAmountRaw.isNotEmpty) {
        Map resp = await sl.get<GiftCards>().createSplitGiftCard(
          seed: widget.paperWalletSeed,
          requestingAccount: walletAddress,
          memo: widget.memo,
          splitAmountRaw: widget.splitAmountRaw,
          requireCaptcha: widget.requireCaptcha,
        ) as Map;

        if (resp.containsKey("success")) {
          branchLink = resp["link"] as String;
        }
      } else {
        branchResponse = await sl.get<GiftCards>().createGiftCard(
          context,
          paperWalletSeed: widget.paperWalletSeed,
          amountRaw: widget.amountRaw,
          memo: widget.memo,
          requireCaptcha: widget.requireCaptcha,
        );
        if (branchResponse.success) {
          branchLink = branchResponse.result as String;
        }
      }

      // send funds:
      ProcessResponse? resp;
      final bool linkCreationSuccess = branchLink != null;
      if (linkCreationSuccess) {
        resp = await sl.get<AccountService>().requestSend(
            StateContainer.of(context).wallet!.representative,
            StateContainer.of(context).wallet!.frontier,
            widget.amountRaw,
            widget.destination,
            StateContainer.of(context).wallet!.address,
            NanoUtil.seedToPrivate(
                await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!),
            max: widget.maxSend);
        StateContainer.of(context).wallet!.frontier = resp.hash;
        StateContainer.of(context).wallet!.accountBalance += BigInt.parse(widget.amountRaw);
      }

      // ignore: use_build_context_synchronously
      await sl.get<GiftCards>().handleResponse(
            context,
            success: linkCreationSuccess,
            amountRaw: widget.amountRaw,
            destination: widget.destination,
            localCurrency: widget.localCurrency,
            hash: resp?.hash,
            link: branchLink,
            paperWalletSeed: widget.paperWalletSeed,
            memo: widget.memo,
          );
    } catch (error) {
      sl.get<Logger>().d("gift_confirm_error: $error");
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      Clipboard.setData(ClipboardData(text: (branchLink ?? "") + RecordTypes.SEPARATOR + widget.paperWalletSeed));
      UIUtil.showSnackbar(Z.of(context).giftCardCreationErrorSent, context, durationMs: 20000);
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
            .replaceAll("%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
            .replaceAll("%2", StateContainer.of(context).currencyMode),
      );
    }));
    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }
}
