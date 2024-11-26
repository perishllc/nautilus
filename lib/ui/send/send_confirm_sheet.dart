import 'dart:async';
import 'dart:math';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart' as NFFI;
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:logger/logger.dart';
import 'package:nanoutil/nanoutil.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/scheduled.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/db/work_source.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/anonymous_service.dart';
import 'package:wallet_flutter/network/giftcards.dart';
import 'package:wallet_flutter/network/metadata_service.dart';
import 'package:wallet_flutter/network/model/response/account_info_response.dart';
import 'package:wallet_flutter/network/model/response/process_response.dart';
import 'package:wallet_flutter/network/model/status_types.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/send/send_anonymous_advanced_options.dart';
import 'package:wallet_flutter/ui/send/send_complete_sheet.dart';
import 'package:wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/security.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/biometrics.dart';
import 'package:wallet_flutter/util/box.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class SendConfirmSheet extends StatefulWidget {
  const SendConfirmSheet(
      {required this.amountRaw,
      required this.destination,
      this.contactName,
      this.localCurrency,
      this.maxSend = false,
      this.phoneNumber = "",
      this.paperWalletSeed = "",
      this.link = "",
      this.memo = "",
      this.anonymousMode = false})
      : super();

  final String amountRaw;
  final String destination;
  final String? contactName;
  final String? localCurrency;
  final bool maxSend;
  // final bool isPhoneNumber;
  final String phoneNumber;
  final String link;
  final String paperWalletSeed;
  final String memo;
  final bool anonymousMode;

  @override
  _SendConfirmSheetState createState() => _SendConfirmSheetState();
}

class _SendConfirmSheetState extends State<SendConfirmSheet> {
  late bool animationOpen;
  bool clicking = false;
  bool shownWarning = false;
  bool obscuredMode = false;

  StreamSubscription<AuthenticatedEvent>? _authSub;

  // nanonymous:
  List<Map<String, dynamic>> sends = [];
  String? nanAmountToSendRaw;
  String? nanDestination;
  String? nanFeeRaw;
  bool advancedAnonymousOptions = false;
  bool delaysEnabled = false;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton()
        .registerTo<AuthenticatedEvent>()
        .listen((AuthenticatedEvent event) {
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // show warning dialog if this is a send:
      if ((widget.amountRaw != "0") && widget.link.isEmpty) {
        if (!await showUnopenedWarning(widget.destination)) {
          Navigator.of(context).pop();
        }
        if (mounted) {
          setState(() {
            shownWarning = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            shownWarning = true;
          });
        }
      }

      if (!mounted) return;

      if (widget.anonymousMode) {
        await getNanonymousFeeRaw(context);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _showAnimation(BuildContext context, AnimationType type) {
    animationOpen = true;
    AppAnimation.animationLauncher(context, type,
        onPoppedCallback: () => animationOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            Handlebars.horizontal(context),
            //The main widget that holds the text fields, "SENDING" and "TO" texts
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Clear focus of our fields when tapped in this empty space
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: /*KeyboardAvoider(
                  duration: Duration.zero,
                  autoScroll: true,
                  focusPadding: 40,
                  child: */Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // "SENDING" TEXT
                      Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              CaseChange.toUpperCase(
                                  (widget.link.isEmpty)
                                      ? Z.of(context).sending
                                      : Z.of(context).creatingGiftCard,
                                  context),
                              style: AppStyles.textStyleHeader(context),
                            ),
                          ],
                        ),
                      ),
                      // Container for the amount text
                      if (widget.memo.isNotEmpty && (widget.amountRaw == "0"))
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 15.0),
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.105,
                                right:
                                    MediaQuery.of(context).size.width * 0.105),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: StateContainer.of(context)
                                  .curTheme
                                  .backgroundDarkest,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              widget.memo,
                              style: AppStyles.textStyleParagraph(context),
                              textAlign: TextAlign.center,
                            ))
                      else
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.105,
                              right: MediaQuery.of(context).size.width * 0.105),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: StateContainer.of(context)
                                .curTheme
                                .backgroundDarkest,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          // Amount text
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: "",
                              children: [
                                TextSpan(
                                  text: getThemeAwareRawAccuracy(
                                      context, widget.amountRaw),
                                  style: AppStyles.textStyleParagraphPrimary(
                                      context),
                                ),
                                displayCurrencySymbol(
                                  context,
                                  AppStyles.textStyleParagraphPrimary(context),
                                ),
                                TextSpan(
                                  text: getRawAsThemeAwareFormattedAmount(
                                      context, widget.amountRaw),
                                  style: AppStyles.textStyleParagraphPrimary(
                                      context),
                                ),
                                TextSpan(
                                  text: widget.localCurrency != null
                                      ? " (${widget.localCurrency})"
                                      : "",
                                  style: AppStyles.textStyleParagraphPrimary(
                                          context)
                                      .copyWith(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary!
                                        .withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // "TO" text
                      if (widget.link.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 10),
                          child: Column(
                            children: <Widget>[
                              Text(
                                CaseChange.toUpperCase(
                                    Z.of(context).to, context),
                                style: AppStyles.textStyleHeader(context),
                              ),
                            ],
                          ),
                        ),
                      // Address text
                      if (widget.link.isEmpty)
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 15.0),
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.105,
                                right:
                                    MediaQuery.of(context).size.width * 0.105),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: StateContainer.of(context)
                                  .curTheme
                                  .backgroundDarkest,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: UIUtil.threeLineAddressText(
                                context, widget.destination,
                                contactName: widget.contactName)),

                      // WITH MESSAGE:
                      if (widget.memo.isNotEmpty && (widget.amountRaw != "0"))
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 10),
                          child: Column(
                            children: <Widget>[
                              Text(
                                CaseChange.toUpperCase(
                                    Z.of(context).withMessage, context),
                                style: AppStyles.textStyleHeader(context),
                              ),
                            ],
                          ),
                        ),
                      // MEMO:
                      if (widget.memo.isNotEmpty && (widget.amountRaw != "0"))
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 15.0),
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.105,
                                right:
                                    MediaQuery.of(context).size.width * 0.105),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: StateContainer.of(context)
                                  .curTheme
                                  .backgroundDarkest,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              widget.memo,
                              style: AppStyles.textStyleParagraph(context),
                              textAlign: TextAlign.center,
                            )),

                      // "FEE" text
                      if (widget.anonymousMode && nanFeeRaw == null)
                        const SizedBox(height: 118),
                      if (widget.anonymousMode && nanFeeRaw != null) ...[
                        Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 16, bottom: 10),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    CaseChange.toUpperCase(
                                        Z.current.withFee, context),
                                    style: AppStyles.textStyleHeader(context),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.105,
                                  right: MediaQuery.of(context).size.width *
                                      0.105),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: StateContainer.of(context)
                                    .curTheme
                                    .backgroundDarkest,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              // Amount text
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "",
                                  children: [
                                    TextSpan(
                                      text: getThemeAwareRawAccuracy(
                                          context, nanFeeRaw),
                                      style:
                                          AppStyles.textStyleParagraphPrimary(
                                              context),
                                    ),
                                    displayCurrencySymbol(
                                      context,
                                      AppStyles.textStyleParagraphPrimary(
                                          context),
                                    ),
                                    TextSpan(
                                      text: getRawAsThemeAwareFormattedAmount(
                                          context, nanFeeRaw),
                                      style:
                                          AppStyles.textStyleParagraphPrimary(
                                              context),
                                    ),
                                    TextSpan(
                                      text: widget.localCurrency != null
                                          ? " (${widget.localCurrency})"
                                          : "",
                                      style:
                                          AppStyles.textStyleParagraphPrimary(
                                                  context)
                                              .copyWith(
                                        color: StateContainer.of(context)
                                            .curTheme
                                            .primary!
                                            .withOpacity(0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (widget.anonymousMode)
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Checkbox(
                                value: advancedAnonymousOptions,
                                activeColor:
                                    StateContainer.of(context).curTheme.primary,
                                onChanged: (bool? value) {
                                  if (value == null) return;
                                  setState(() {
                                    advancedAnonymousOptions = value;
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    advancedAnonymousOptions =
                                        !advancedAnonymousOptions;
                                  });
                                },
                                child: Text(
                                  Z.of(context).advancedOptions,
                                  style: AppStyles.textStyleParagraph(context),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 60,
                                alignment: Alignment.center,
                                child: AppDialogs.infoButton(
                                  context,
                                  () {
                                    AppDialogs.showInfoDialog(
                                      context,
                                      Z.of(context).obscureInfoHeader,
                                      Z.of(context).anonymousAdvancedInfoBody,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (advancedAnonymousOptions)
                        AnonymousAdvancedOptions(
                            onSendsChanged: (List<Map<String, dynamic>> sends) {
                          this.sends = sends;
                        }, onDelaysChanged: (bool enabled) {
                          setState(() {
                            delaysEnabled = enabled;
                          });
                        }),

                      // // obscured checkbox:
                      // if (widget.amountRaw != "0" && widget.link.isEmpty)
                      //   Container(
                      //     margin: const EdgeInsets.only(top: 15),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: <Widget>[
                      //         Checkbox(
                      //           value: obscuredMode,
                      //           activeColor: StateContainer.of(context).curTheme.primary,
                      //           onChanged: onObscuredChanged,
                      //         ),
                      //         const SizedBox(width: 10),
                      //         GestureDetector(
                      //           onTap: () {
                      //             onObscuredChanged(!obscuredMode);
                      //           },
                      //           child: Text(
                      //             Z.of(context).obscureTransaction,
                      //             style: AppStyles.textStyleParagraph(context),
                      //           ),
                      //         ),
                      //         Container(
                      //           width: 60,
                      //           height: 60,
                      //           alignment: Alignment.center,
                      //           child: AppDialogs.infoButton(
                      //             context,
                      //             () {
                      //               AppDialogs.showInfoDialog(
                      //                 context,
                      //                 Z.of(context).obscureInfoHeader,
                      //                 Z.of(context).obscureTransactionBody,
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ],
                  ),
                /*),*/
              ),
            ),

            //A container for CONFIRM and CANCEL buttons
            Column(
              children: <Widget>[
                // A row for buttons
                Row(
                  children: <Widget>[
                    // CANCEL Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        CaseChange.toUpperCase(Z.of(context).cancel, context),
                        Dimens.BUTTON_COMPACT_LEFT_DIMENS, onPressed: () {
                      Navigator.of(context).pop();
                    }),
                    // CONFIRM Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        CaseChange.toUpperCase(Z.of(context).confirm, context),
                        Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
                        disabled: !shownWarning, onPressed: () async {
                      if (clicking) return;
                      clicking = true;
                      // Authenticate
                      final AuthenticationMethod authMethod =
                          await sl.get<SharedPrefsUtil>().getAuthMethod();
                      final bool hasBiometrics =
                          await sl.get<BiometricUtil>().hasBiometrics();

                      final bool isMessage =
                          widget.memo.isNotEmpty && (widget.amountRaw == "0");

                      if (!mounted) return;

                      final String authText = isMessage
                          ? Z.of(context).sendMessageConfirm
                          : Z
                              .of(context)
                              .sendAmountConfirm
                              .replaceAll(
                                  "%1",
                                  getRawAsThemeAwareAmount(
                                      context, widget.amountRaw))
                              .replaceAll("%2",
                                  StateContainer.of(context).currencyMode);

                      if (!mounted) return;

                      if (authMethod.method == AuthMethod.BIOMETRICS &&
                          hasBiometrics) {
                        try {
                          final bool authenticated = await sl
                              .get<BiometricUtil>()
                              .authenticateWithBiometrics(context, authText);
                          if (authenticated) {
                            sl.get<HapticUtil>().fingerprintSucess();
                            EventTaxiImpl.singleton()
                                .fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
                          }
                        } catch (e) {
                          await authenticateWithPin();
                        }
                      } else if (authMethod.method == AuthMethod.PIN ||
                          (authMethod.method == AuthMethod.BIOMETRICS &&
                              !hasBiometrics)) {
                        await authenticateWithPin();
                      } else {
                        EventTaxiImpl.singleton()
                            .fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
                      }
                      clicking = false;
                    })
                  ],
                ),
                // A row for CANCEL Button
                // Row(
                //   children: <Widget>[
                //     // CANCEL Button

                //   ],
                // ),
              ],
            ),
          ],
        ));
  }

  Future<bool> showUnopenedWarning(String address) async {
    // if we have the warn setting on, and the account isn't open, show the dialog:
    final bool warningOn =
        await sl.get<SharedPrefsUtil>().getUnopenedWarningOn();
    if (!warningOn) {
      return true;
    }
    // check if the address is open:
    try {
      final AccountInfoResponse accountInfo =
          await sl.get<AccountService>().getAccountInfo(address);
      if (!accountInfo.unopened) {
        return true;
      }
    } catch (e) {
      return false;
    }

    if (!mounted) return false;

    final bool? option = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            surfaceTintColor: StateContainer.of(context).curTheme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              Z.of(context).unopenedWarningWarningHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("${Z.of(context).unopenedWarningWarning}\n\n",
                    style: AppStyles.textStyleParagraph(context)),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: "${Z.of(context).address}:\n",
                    style: AppStyles.textStyleParagraph(context),
                    children: [
                      TextSpan(
                        text: "$address\n",
                        style: AppStyles.textStyleParagraphPrimary(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).imSure,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).goBackButton,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              )
            ],
          );
        });

    return option ?? false;
  }

  Future<void> _doSend() async {
    bool memoSendFailed = false;
    try {
      final bool isMessage = widget.amountRaw == "0";
      final String walletAddress = StateContainer.of(context).wallet!.address!;

      _showAnimation(
          context, isMessage ? AnimationType.SEND_MESSAGE : AnimationType.SEND);

      ProcessResponse? resp;

      final String derivationMethod =
          await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
      final NanoDerivationType derivationType =
          NanoUtilities.derivationMethodToType(derivationMethod);
      if (!isMessage) {
        if (widget.anonymousMode) {
          if (!mounted) return;
          nanDestination = await getNanonymousDestination(context);
          if (nanAmountToSendRaw == null || nanDestination == null) {
            throw Exception(
                "nanAmountToSendRaw == null || nanDestination == null");
          }

          final String privKey = await NanoDerivations.universalSeedToPrivate(
            await StateContainer.of(context).getSeed(),
            index: StateContainer.of(context).selectedAccount!.index!,
            type: derivationType,
          );

          // check if using local work generation:
          final WorkSource ws =
              await sl.get<DBHelper>().getSelectedWorkSource();
          if (ws.type == WorkSourceTypes.LOCAL) {
            if (!mounted) return;
            UIUtil.showSnackbar(
              Z.of(context).generatingWork,
              context,
              durationMs: 25000,
            );
          }
          resp = await sl.get<AccountService>().requestSend(
                StateContainer.of(context).wallet!.representative,
                StateContainer.of(context).wallet!.frontier,
                nanAmountToSendRaw,
                nanDestination,
                StateContainer.of(context).wallet!.address,
                privKey,
                max: widget.maxSend,
              );
          if (!mounted) return;
          StateContainer.of(context).wallet!.frontier = resp.hash;
          StateContainer.of(context).wallet!.accountBalance -=
              BigInt.parse(widget.amountRaw);
        } else if (obscuredMode) {
          sl.get<Logger>().v("OBSCURED MODE");

          // random index between 1-4 billion:
          final int randomIndex = Random().nextInt(3000000000) + 1000000000;

          final NanoDerivationType derivationType =
              NanoUtilities.derivationMethodToType(derivationMethod);

          final String address200 =
              await NanoDerivations.universalSeedToAddress(
            await StateContainer.of(context).getSeed(),
            index: randomIndex,
            type: derivationType,
          );

          final String privKey = await NanoDerivations.universalSeedToPrivate(
              await StateContainer.of(context).getSeed(),
              index: StateContainer.of(context).selectedAccount!.index!,
              type: derivationType);
          resp = await sl.get<AccountService>().requestSend(
                StateContainer.of(context).wallet!.representative,
                StateContainer.of(context).wallet!.frontier,
                widget.amountRaw,
                address200,
                StateContainer.of(context).wallet!.address,
                privKey,
                max: widget.maxSend,
              );
          if (!mounted) return;
          StateContainer.of(context).wallet!.frontier = resp.hash;
          StateContainer.of(context).wallet!.accountBalance -=
              BigInt.parse(widget.amountRaw);

          sl.get<Logger>().v("SENT TO ADDRESS 200");

          // receive from address 200:
          await AppTransferOverviewSheetState().receiveAtIndex(
              context,
              await StateContainer.of(context).getSeed(),
              randomIndex,
              derivationMethod);

          sl.get<Logger>().v("RECEIVED AT ADDRESS 200");

          // send to destination:

          if (!mounted) return;

          await AppTransferOverviewSheetState().sendAtIndex(
            context,
            await StateContainer.of(context).getSeed(),
            randomIndex,
            derivationMethod,
            widget.destination,
            widget.amountRaw,
            true,
          );

          sl.get<Logger>().v("SENT TO DESTINATION");
        } else if (!obscuredMode) {
          // regular mode:
          final String privKey = await NanoDerivations.universalSeedToPrivate(
            await StateContainer.of(context).getSeed(),
            index: StateContainer.of(context).selectedAccount!.index!,
            type: derivationType,
          );

          // check if using local work generation:
          final WorkSource ws =
              await sl.get<DBHelper>().getSelectedWorkSource();
          if (ws.type == WorkSourceTypes.LOCAL) {
            if (!mounted) return;
            UIUtil.showSnackbar(
              Z.current.generatingWork,
              context,
              durationMs: 25000,
            );
          }
          resp = await sl.get<AccountService>().requestSend(
                StateContainer.of(context).wallet!.representative,
                StateContainer.of(context).wallet!.frontier,
                widget.amountRaw,
                widget.destination,
                StateContainer.of(context).wallet!.address,
                privKey,
                max: widget.maxSend,
              );
          if (!mounted) return;
          StateContainer.of(context).wallet!.frontier = resp.hash;
          StateContainer.of(context).wallet!.accountBalance -=
              BigInt.parse(widget.amountRaw);
        }
      }

      // if there's a memo to be sent, and this isn't a gift card creation, send it:
      if (widget.memo.isNotEmpty && widget.link.isEmpty) {
        final NanoDerivationType derivationType =
            NanoUtilities.derivationMethodToType(derivationMethod);
        final String privKey = await NanoDerivations.universalSeedToPrivate(
          await StateContainer.of(context).getSeed(),
          index: StateContainer.of(context).selectedAccount!.index!,
          type: derivationType,
        );
        // get epoch time as hex:
        final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/
            Duration.millisecondsPerSecond;
        final String nonceHex = secondsSinceEpoch.toRadixString(16);
        final String signature = NFFI.NanoSignatures.signBlock(nonceHex, privKey);

        // check validity locally:
        final String pubKey = NFFI.NanoAccounts.extractPublicKey(walletAddress);
        final bool isValid = NFFI.NanoSignatures.validateSig(nonceHex,
            NFFI.NanoHelpers.hexToBytes(pubKey), NFFI.NanoHelpers.hexToBytes(signature));
        if (!isValid) {
          throw Exception("Invalid signature?!");
        }

        // create a local memo object:
        const Uuid uuid = Uuid();
        final String localUuid = "LOCAL:${uuid.v4()}";
        // current block height:
        final int currentBlockHeightInList =
            StateContainer.of(context).wallet!.history.isNotEmpty
                ? (StateContainer.of(context).wallet!.history[0].height! + 1)
                : 1;
        final TXData memoTXData = TXData(
          from_address: walletAddress,
          to_address: widget.destination,
          amount_raw: widget.amountRaw != "0" ? widget.amountRaw : null,
          uuid: localUuid,
          block: resp?.hash,
          is_acknowledged: false,
          is_fulfilled: false,
          is_request: false,
          is_memo: !isMessage,
          is_message: isMessage,
          request_time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          memo: widget.memo, // store unencrypted memo
          height: currentBlockHeightInList,
        );
        // add it to the database:
        await sl.get<DBHelper>().addTXData(memoTXData);

        try {
          // encrypt the memo:
          final String encryptedMemo =
              Box.encrypt(widget.memo, widget.destination, privKey);

          if (isMessage) {
            await sl.get<MetadataService>().sendTXMessage(widget.destination,
                walletAddress, signature, nonceHex, encryptedMemo, localUuid);
          } else {
            // just a memo:
            await sl.get<MetadataService>().sendTXMemo(
                widget.destination,
                walletAddress,
                widget.amountRaw,
                signature,
                nonceHex,
                encryptedMemo,
                resp?.hash,
                localUuid);
          }
        } catch (e) {
          sl.get<Logger>().v("error encrypting memo: $e");
          memoSendFailed = true;
        }

        // if the memo send failed delete the object:
        if (memoSendFailed) {
          sl.get<Logger>().v("memo send failed, updating TXData object");

          // update the TXData object:
          memoTXData.status = StatusTypes.CREATE_FAILED;
          await sl.get<DBHelper>().replaceTXDataByUUID(memoTXData);
          // remove from the database:
          // await sl.get<DBHelper>().deleteTXDataByUUID(local_uuid);
        } else {
          // update the TXData object:
          memoTXData.status = StatusTypes.CREATE_SUCCESS;
          await sl.get<DBHelper>().replaceTXDataByUUID(memoTXData);
          await StateContainer.of(context).updateTXMemos();
        }
      }

      // go through and check to see if any unfulfilled payments are now fulfilled
      final List<TXData> unfulfilledPayments =
          await sl.get<DBHelper>().getUnfulfilledTXs();
      for (int i = 0; i < unfulfilledPayments.length; i++) {
        final TXData txData = unfulfilledPayments[i];

        // TX is unfulfilled and in the past:
        // int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // if (currentTime - int.parse(txData.request_time) > 0) {
        // }
        // check destination of this request is where we're sending to:
        // check to make sure we are the recipient of this request:
        // check to make sure the amounts are the same:
        if (txData.from_address == widget.destination &&
            txData.to_address == StateContainer.of(context).wallet!.address &&
            txData.amount_raw == widget.amountRaw) {
          // this is the payment we're fulfilling
          // update the TXData to be fulfilled
          await sl.get<DBHelper>().changeTXFulfillmentStatus(txData.uuid, true);
          // update the ui to reflect the change in the db:
          StateContainer.of(context).updateSolids();
          StateContainer.of(context).updateTXMemos();
          StateContainer.of(context).updateUnified(true);
          break;
        }
      }

      // check if this fulfilled any subscriptions / scheduled payments:
      final List<Scheduled> scheduledPayments =
          await sl.get<DBHelper>().getScheduled();
      for (int i = 0; i < scheduledPayments.length; i++) {
        final Scheduled scheduled = scheduledPayments[i];
        // check to make sure the recipient is correct and the amount is correct:
        if (scheduled.address == widget.destination &&
            scheduled.amount_raw == widget.amountRaw) {
          // make sure the payment was due:
          final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          if (scheduled.timestamp < currentTime) {
            await sl.get<DBHelper>().deleteScheduled(scheduled);
          }
        }
      }

      // Show complete
      String? contactName = widget.contactName;
      if (widget.contactName == null || widget.contactName!.isEmpty) {
        final User? user =
            await sl.get<DBHelper>().getUserWithAddress(widget.destination);
        if (user != null) {
          contactName = user.getDisplayName();
        }
      }
      StateContainer.of(context).requestUpdate();
      StateContainer.of(context).updateTXMemos();
      if (isMessage) {
        StateContainer.of(context).updateSolids();
      }
      StateContainer.of(context).updateUnified(true);

      if (memoSendFailed) {
        if (!mounted) return;
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
        UIUtil.showSnackbar(
            Z
                .of(context)
                .sendMemoError
                .replaceAll("%1", NonTranslatable.appName),
            context,
            durationMs: 5000);
        return;
      }

      if (widget.link.isNotEmpty) {
        if (!mounted) return;
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        await sl.get<GiftCards>().handleResponse(context,
            success: true,
            amountRaw: widget.amountRaw,
            destination: widget.destination,
            localCurrency: widget.localCurrency,
            link: widget.link,
            hash: resp!.hash!,
            paperWalletSeed: widget.paperWalletSeed,
            memo: widget.memo);
      } else {
        if (!mounted) return;
        Sheets.showAppHeightNineSheet(
            context: context,
            closeOnTap: true,
            removeUntilHome: true,
            widget: SendCompleteSheet(
                amountRaw: widget.anonymousMode
                    ? nanAmountToSendRaw!
                    : widget.amountRaw,
                destination:
                    widget.anonymousMode ? nanDestination! : widget.destination,
                contactName: contactName,
                memo: widget.memo,
                localAmount: widget.localCurrency));
      }
    } catch (error) {
      sl.get<Logger>().d("send_confirm_error: $error");
      // Send failed
      if (animationOpen) {
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
    final bool? auth = await Sheets.showAppHeightFullSheet(
      context: context,
      widget: PinScreen(PinOverlayType.ENTER_PIN,
          expectedPin: expectedPin,
          plausiblePin: plausiblePin,
          description: Z
              .of(context)
              .sendAmountConfirm
              .replaceAll(
                  "%1", getRawAsThemeAwareAmount(context, widget.amountRaw))
              .replaceAll("%2", StateContainer.of(context).currencyMode)),
    );

    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));
    }
  }

  Future<void> onObscuredChanged(bool? value) async {
    if (value == null) return;
    if (value) {
      if (!(await AppDialogs.proCheck(context))) {
        return;
      }
    }
    setState(() {
      obscuredMode = value;
    });
  }

  Future<String> getNanonymousFeeRaw(BuildContext context) async {
    // GET: https://nanonymous.cc/api/v1?feecheck (returns {"fee": "0.02"}:
    final String amountToSendRaw =
        await sl.get<AnonymousService>().getAmountToSendRaw(widget.amountRaw);
    nanAmountToSendRaw = amountToSendRaw;
    final BigInt amountToSendBigInt = BigInt.parse(amountToSendRaw);
    final BigInt originalAmountBigInt = BigInt.parse(widget.amountRaw);
    final BigInt feeBigInt = amountToSendBigInt - originalAmountBigInt;
    nanFeeRaw = feeBigInt.toString();
    return nanFeeRaw!;
  }

  Future<String?> getNanonymousDestination(BuildContext context) async {
    try {
      List<int> percents = <int>[];
      List<int> delays = <int>[];

      int percentSum = 0;

      for (int i = 0; i < sends.length; i++) {
        final Map<String, dynamic> send = sends[i];
        final int percent = send["percent"] as int;
        final int delay = send["seconds"] as int;
        if (advancedAnonymousOptions) {
          percents.add(percent);
          if (delaysEnabled) {
            delays.add(delay);
          }
        }
        percentSum += percent;
      }

      if (advancedAnonymousOptions && percentSum != 100) {
        throw Exception("percentages don't add up to 100!");
      }

      final String destination = await sl.get<AnonymousService>().getAddress(
            widget.destination,
            percents: percents,
            delays: delays,
          );

      return destination;
    } catch (e) {
      return null;
    }
  }
}
