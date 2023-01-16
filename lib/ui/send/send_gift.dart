import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/src/objects/branch_universal_object.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/fcm_update_event.dart';
import 'package:wallet_flutter/bus/notification_setting_change_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/notification_setting.dart';
import 'package:wallet_flutter/network/giftcards.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/numberutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class SendGiftSheet extends StatefulWidget {
  const SendGiftSheet({required this.localCurrency}) : super();

  final AvailableCurrency localCurrency;

  SendGiftSheetState createState() => SendGiftSheetState();
}

enum AddressStyle { TEXT60, TEXT90, PRIMARY }

class SendGiftSheetState extends State<SendGiftSheet> {
  final Logger log = sl.get<Logger>();

  FocusNode _amountFocusNode = FocusNode();
  FocusNode _memoFocusNode = FocusNode();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _memoController = TextEditingController();

  // States
  AddressStyle _addressStyle = AddressStyle.TEXT60;
  String? _amountHint;
  String? _addressHint;
  String? _memoHint;
  String _amountValidationText = "";
  String _addressValidationText = "";
  String _memoValidationText = "";
  String? quickSendAmount = "";
  List<User> _users = [];
  bool animationOpen = false;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a username is being entered
  bool _isUser = false;
  bool _isFavorite = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;
  bool _clearButton = false;
  bool _showContactButton = true;
  // Local currency mode/fiat conversion
  bool _localCurrencyMode = false;
  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";
  late NumberFormat _localCurrencyFormat;

  // Receive card instance
  ReceiveSheet? receive;

  String? _rawAmount;

  bool _addressCopied = false;
  Timer? _addressCopiedTimer;

  @override
  void initState() {
    super.initState();

    // _amountHint = Z.of(context).enterAmount;
    // _addressHint = Z.of(context).enterUserOrAddress;
    // _memoHint = Z.of(context).enterMemo;

    // On amount focus change
    _amountFocusNode!.addListener(() {
      if (_amountFocusNode!.hasFocus) {
        if (_rawAmount != null) {
          setState(() {
            _amountController!.text = getRawAsThemeAwareAmount(context, _rawAmount);
            _rawAmount = null;
          });
        }
        if (quickSendAmount != null) {
          _amountController!.text = "";
          setState(() {
            quickSendAmount = null;
          });
        }
        setState(() {
          _amountHint = "";
          _amountValidationText = "";
        });
      } else {
        setState(() {
          _amountHint = Z.of(context).enterAmount;
        });
      }
    });
    // On memo focus change
    _memoFocusNode!.addListener(() {
      if (_memoFocusNode!.hasFocus) {
        setState(() {
          _memoHint = "";
          _memoValidationText = "";
        });
      } else {
        setState(() {
          _memoHint = Z.of(context).enterMemo;
        });
      }
    });

    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(
        locale: widget.localCurrency.getLocale().toString(), symbol: widget.localCurrency.getCurrencySymbol());
    // Set quick send amount
    if (quickSendAmount != null && quickSendAmount!.isNotEmpty && quickSendAmount != "0") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _amountController!.text = getRawAsThemeAwareAmount(context, quickSendAmount);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the header of the sheet, balance text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
                // Container for the header, address and balance text
                Column(
                  children: <Widget>[
                    Handlebars.horizontal(context),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          // Header
                          AutoSizeText(
                            CaseChange.toUpperCase(Z.of(context).createGiftCard, context),
                            style: AppStyles.textStyleHeader(context),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: AppDialogs.infoButton(
                    context,
                    () {
                      AppDialogs.showInfoDialog(
                        context,
                        Z.of(context).giftCardInfoHeader,
                        Z
                            .of(context)
                            .giftInfo
                            .replaceAll("%1", NonTranslatable.appName)
                            .replaceAll("%2", NonTranslatable.currencyName),
                        scrollable: true,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
            // account / wallet name:
            OutlinedButton(
              onPressed: () async {
                Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address));
                setState(() {
                  _addressCopied = true;
                });
                _addressCopiedTimer?.cancel();
                _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                  if (!mounted) return;
                  setState(() {
                    _addressCopied = false;
                  });
                });
                UIUtil.showSnackbar(Z.of(context).addressCopied, context, durationMs: 1500);
              },
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        AppIcons.content_copy,
                        size: 24,
                        color: StateContainer.of(context).curTheme.primary,
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 5),
                        Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: '',
                                  children: [
                                    TextSpan(
                                      text: StateContainer.of(context).selectedAccount!.name,
                                      style: TextStyle(
                                        color: StateContainer.of(context).curTheme.text60,
                                        fontSize: AppFontSizes.small,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  text: '',
                                  children: [
                                    TextSpan(
                                      text: StateContainer.of(context).wallet?.username ??
                                          Address(StateContainer.of(context).wallet!.address).getShortFirstPart(),
                                      style: TextStyle(
                                        color: StateContainer.of(context).curTheme.text60,
                                        fontSize: AppFontSizes.small,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        FutureBuilder<PriceConversion>(
                          future: sl.get<SharedPrefsUtil>().getPriceConversion(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData && snapshot.data != null && snapshot.data != PriceConversion.HIDDEN) {
                              return RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  text: '',
                                  children: [
                                    TextSpan(
                                      text: "(",
                                      style: TextStyle(
                                        color: StateContainer.of(context).curTheme.primary60,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                    if (!_localCurrencyMode)
                                      TextSpan(
                                        text: getThemeAwareRawAccuracy(
                                          context,
                                          StateContainer.of(context).wallet!.accountBalance.toString(),
                                        ),
                                        style: TextStyle(
                                          color: StateContainer.of(context).curTheme.primary60,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "NunitoSans",
                                        ),
                                      ),
                                    if (!_localCurrencyMode)
                                      displayCurrencySymbol(
                                        context,
                                        TextStyle(
                                          color: StateContainer.of(context).curTheme.primary60,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "NunitoSans",
                                        ),
                                      ),
                                    TextSpan(
                                      text: _localCurrencyMode
                                          ? StateContainer.of(context).wallet!.getLocalCurrencyBalance(
                                              context, StateContainer.of(context).curCurrency,
                                              locale: StateContainer.of(context).currencyLocale)
                                          : getRawAsThemeAwareFormattedAmount(
                                              context, StateContainer.of(context).wallet!.accountBalance.toString()),
                                      style: TextStyle(
                                        color: StateContainer.of(context).curTheme.primary60,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                    TextSpan(
                                      text: ")",
                                      style: TextStyle(
                                        color: StateContainer.of(context).curTheme.primary60,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const Text(
                              "*******",
                              style: TextStyle(
                                color: Colors.transparent,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w100,
                                fontFamily: "NunitoSans",
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // A main container that holds everything
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                child: GestureDetector(
                  onTap: () {
                    // Clear focus of our fields when tapped in this empty space
                    _amountFocusNode!.unfocus();
                    _memoFocusNode!.unfocus();
                  },
                  child: KeyboardAvoider(
                    duration: Duration.zero,
                    autoScroll: true,
                    focusPadding: 40,
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            // Enter Amount container + Enter Amount Error container
                            Column(
                              children: <Widget>[
                                // ******* Enter Amount Container ******* //
                                getEnterAmountContainer(),
                                // ******* Enter Amount Container End ******* //

                                // ******* Enter Amount Error Container ******* //
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(_amountValidationText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                // ******* Enter Amount Error Container End ******* //
                              ],
                            ),
                            // Column for Enter Memo container + Enter Memo Error container
                            Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context).size.width * 0.105,
                                            right: MediaQuery.of(context).size.width * 0.105),
                                        alignment: Alignment.bottomCenter,
                                        constraints: const BoxConstraints(maxHeight: 174, minHeight: 0),
                                      ),

                                      // ******* Enter Memo Container ******* //
                                      getEnterMemoContainer(),
                                      // ******* Enter Memo Container End ******* //
                                    ],
                                  ),
                                ),

                                // ******* Enter Memo Error Container ******* //
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(_memoValidationText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                // ******* Enter Memo Error Container End ******* //
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // A column for Enter Amount, Enter Address, Error containers and the pop up list
              ),
            ),

            //A column with "Scan QR Code" and "Send" buttons
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Send Button
                    AppButton.buildAppButton(
                        context, AppButtonType.PRIMARY, Z.of(context).createGiftCard, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      final bool validRequest = await _validateRequest();

                      if (!validRequest || !mounted) {
                        return;
                      }

                      late String formattedAddress;
                      final String formattedAmount = sanitizedAmount(_localCurrencyFormat, _amountController!.text);

                      String amountRaw;

                      if (_amountController!.text.isEmpty || _amountController!.text == "0") {
                        amountRaw = "0";
                      } else {
                        if (_localCurrencyMode) {
                          amountRaw = NumberUtil.getAmountAsRaw(sanitizedAmount(
                              _localCurrencyFormat,
                              convertLocalCurrencyToLocalizedCrypto(
                                  context, _localCurrencyFormat, _amountController!.text)));
                        } else {
                          if (_rawAmount != null) {
                            amountRaw = _rawAmount!;
                          } else {
                            if (!mounted) return;
                            amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
                          }
                        }
                      }

                      String? link;
                      String? paperWalletSeed;

                      // we need to create a gift card and change the destination address to the gift card address:
                      paperWalletSeed = NanoSeeds.generateSeed();
                      final String paperWalletAccount = NanoUtil.seedToAddress(paperWalletSeed, 0);
                      // final String paperWalletAccount = "nano_1i4fcujt49de3mio9eb9y5jakw8o9m1za6ntidxn4nkwgnunktpy54z1ma58";
                      if (!mounted) return;
                      final BranchResponse<dynamic> giftCardItem = await sl<GiftCards>().createGiftCard(
                        context,
                        paperWalletSeed: paperWalletSeed,
                        amountRaw: amountRaw,
                        memo: _memoController!.text,
                      );

                      if (giftCardItem.success) {
                        link = giftCardItem.result as String;
                        formattedAddress = paperWalletAccount;
                      } else {
                        if (!mounted) return;
                        UIUtil.showSnackbar(Z.of(context).giftCardCreationError, context);
                        return;
                      }

                      bool isMaxSend = false;
                      if (_isMaxSend()) {
                        isMaxSend = true;
                        if (!mounted) return;
                        amountRaw = StateContainer.of(context).wallet!.accountBalance.toString();
                      }

                      Sheets.showAppHeightEightSheet(
                          context: context,
                          widget: SendConfirmSheet(
                              amountRaw: amountRaw,
                              destination: formattedAddress,
                              maxSend: isMaxSend,
                              // phoneNumber: phoneNumber ?? "",
                              link: link,
                              paperWalletSeed: paperWalletSeed,
                              localCurrency: _localCurrencyMode ? _amountController!.text : null,
                              memo: _memoController!.text));
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  // Determine if this is a max send or not by comparing balances
  bool _isMaxSend() {
    // Sanitize commas
    if (_amountController!.text.isEmpty) {
      return false;
    }
    try {
      String textField = _amountController!.text;
      String balance;
      if (_localCurrencyMode) {
        balance = StateContainer.of(context).wallet!.getLocalCurrencyBalance(
            context, StateContainer.of(context).curCurrency,
            locale: StateContainer.of(context).currencyLocale);
      } else {
        balance = getRawAsThemeAwareAmount(context, StateContainer.of(context).wallet!.accountBalance.toString());
      }
      // Convert to Integer representations
      int textFieldInt;
      int balanceInt;
      if (_localCurrencyMode) {
        // Sanitize currency values into plain integer representations
        textField = textField.replaceAll(",", ".");
        final String sanitizedTextField = sanitizedAmount(_localCurrencyFormat, textField);
        final String sanitizedBalance = sanitizedAmount(_localCurrencyFormat, balance);
        textFieldInt =
            (Decimal.parse(sanitizedTextField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int))
                .toDouble()
                .toInt();
        balanceInt = (Decimal.parse(sanitizedBalance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int))
            .toDouble()
            .toInt();
      } else {
        textField = sanitizedAmount(_localCurrencyFormat, textField);
        textFieldInt = (Decimal.parse(textField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int))
            .toDouble()
            .toInt();
        balanceInt =
            (Decimal.parse(balance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
      }
      return textFieldInt == balanceInt;
    } catch (e) {
      return false;
    }
  }

  /// Validate form data to see if valid
  /// @returns true if valid, false otherwise
  Future<bool> _validateRequest() async {
    bool isValid = true;
    _amountFocusNode!.unfocus();
    _memoFocusNode!.unfocus();
    // Validate amount
    if (_amountController!.text.trim().isEmpty && _memoController!.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _amountValidationText = Z.of(context).amountMissing;
      });
    } else {
      String bananoAmount;
      if (_localCurrencyMode) {
        bananoAmount = sanitizedAmount(_localCurrencyFormat,
            convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text));
      } else {
        if (_rawAmount == null) {
          bananoAmount = sanitizedAmount(_localCurrencyFormat, _amountController!.text);
        } else {
          bananoAmount = getRawAsThemeAwareAmount(context, _rawAmount);
        }
      }
      if (bananoAmount.isEmpty) {
        bananoAmount = "0";
      }
      final BigInt balanceRaw = StateContainer.of(context).wallet!.accountBalance;
      final BigInt? sendAmount = BigInt.tryParse(getThemeAwareAmountAsRaw(context, bananoAmount));
      if (sendAmount == null || sendAmount == BigInt.zero) {
        if (_memoController!.text.trim().isEmpty) {
          isValid = false;
          setState(() {
            _amountValidationText = Z.of(context).amountMissing;
          });
        } else {
          setState(() {
            _amountValidationText = "";
          });
        }
      } else if (sendAmount > balanceRaw) {
        isValid = false;
        setState(() {
          _amountValidationText = Z.of(context).insufficientBalance;
        });
      } else {
        setState(() {
          _amountValidationText = "";
        });
      }
    }
    return isValid;
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  Widget getEnterAmountContainer() {
    return AppTextField(
      topMargin: 80,
      focusNode: _amountFocusNode,
      controller: _amountController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: "NunitoSans",
      ),
      inputFormatters: [
        CurrencyFormatter2(
          active: _localCurrencyMode,
          currencyFormat: _localCurrencyFormat,
          maxDecimalDigits: _localCurrencyMode ? _localCurrencyFormat.decimalDigits ?? 2 : NumberUtil.maxDecimalDigits,
        ),
      ],
      onChanged: (String text) {
        // Always reset the error message to be less annoying
        setState(() {
          _amountValidationText = "";
          // Reset the raw amount
          _rawAmount = null;
        });
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _amountHint ?? Z.of(context).enterAmount,
      prefixButton: _rawAmount == null
          ? TextFieldButton(
              padding: EdgeInsets.zero,
              widget: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RichText(
                    textAlign: TextAlign.center,
                    text: displayCurrencySymbol(
                      context,
                      TextStyle(
                        color: StateContainer.of(context).curTheme.primary,
                        fontSize: _localCurrencyMode ? 12 : 20,
                        fontWeight: _localCurrencyMode ? FontWeight.w400 : FontWeight.w800,
                        fontFamily: "NunitoSans",
                      ),
                    ),
                  ),
                  const Text("/"),
                  Text(_localCurrencyFormat.currencySymbol.trim(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _localCurrencyMode ? 20 : 12,
                        fontWeight: _localCurrencyMode ? FontWeight.w800 : FontWeight.w400,
                        color: StateContainer.of(context).curTheme.primary,
                        fontFamily: "NunitoSans",
                      )),
                ],
              ),
              onPressed: () {
                final List<String> stateVars = SendSheetHelpers.toggleLocalCurrency(
                  setState,
                  context,
                  _amountController,
                  _localCurrencyMode,
                  _localCurrencyFormat,
                  _lastLocalCurrencyAmount,
                  _lastCryptoAmount,
                );
                setState(() {
                  _localCurrencyMode = !_localCurrencyMode;
                  _lastCryptoAmount = stateVars[0];
                  _lastLocalCurrencyAmount = stateVars[1];
                });
              },
            )
          : null,
      suffixButton: TextFieldButton(
        icon: AppIcons.max,
        onPressed: () {
          if (_isMaxSend()) {
            return;
          }
          if (!_localCurrencyMode) {
            setState(() {
              _amountValidationText = "";
              _amountController!.text = getRawAsThemeAwareFormattedAmount(
                  context, StateContainer.of(context).wallet!.accountBalance.toString());
              _amountController!.selection = TextSelection.collapsed(offset: _amountController!.text.length);
            });
          } else {
            String localAmount = StateContainer.of(context).wallet!.getLocalCurrencyBalance(
                context, StateContainer.of(context).curCurrency,
                locale: StateContainer.of(context).currencyLocale);
            localAmount = localAmount.replaceAll(_localCurrencyFormat.symbols.GROUP_SEP, "");
            localAmount = localAmount.replaceAll(_localCurrencyFormat.symbols.DECIMAL_SEP, ".");
            localAmount =
                NumberUtil.sanitizeNumber(localAmount).replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
            setState(() {
              _amountValidationText = "";
              _amountController!.text = _localCurrencyFormat.currencySymbol + localAmount;
              _amountController!.selection = TextSelection.collapsed(offset: _amountController!.text.length);
            });
          }
        },
      ),
      // fadeSuffixOnCondition: true,
      suffixShowFirstCondition: !_isMaxSend(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (String text) {
        FocusScope.of(context).unfocus();
      },
    );
  } //************ Enter Address Container Method End ************//

  //************ Enter Memo Container Method ************//
  //*******************************************************//
  Widget getEnterMemoContainer() {
    return AppTextField(
      topMargin: 165,
      focusNode: _memoFocusNode,
      controller: _memoController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        LengthLimitingTextInputFormatter(255),
      ],
      textInputAction: TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      hintText: _memoHint ?? Z.of(context).enterMemo,
      fadeSuffixOnCondition: true,
      style: TextStyle(
        color: StateContainer.of(context).curTheme.text60,
        fontSize: AppFontSizes.small,
        height: 1.5,
        fontWeight: FontWeight.w100,
        fontFamily: 'OverpassMono',
      ),
      onChanged: (String text) {
        setState(() {}); // forces address container to respect the memo's status (empty or not empty)
        // nothing for now
      },
    );
  } //************ Enter Memo Container Method End ************//
}
