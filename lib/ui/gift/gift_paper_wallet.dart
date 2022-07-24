import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/gift/gift_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';

class GeneratePaperWalletScreen extends StatefulWidget {
  final AvailableCurrency localCurrency;
  // needs: StateContainer.of(context).curCurrency
  GeneratePaperWalletScreen({required this.localCurrency}) : super();

  @override
  _GeneratePaperWalletScreenState createState() => _GeneratePaperWalletScreenState();
}

class _GeneratePaperWalletScreenState extends State<GeneratePaperWalletScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String paper_wallet_seed = NanoSeeds.generateSeed();
  late String paper_wallet_account;

  FocusNode? _addressFocusNode;
  FocusNode? _amountFocusNode;
  FocusNode? _splitAmountFocusNode;
  FocusNode? _memoFocusNode;
  TextEditingController? _amountController;
  TextEditingController? _splitAmountController;
  TextEditingController? _memoController;

  ScrollController _scrollController = ScrollController();

  // States
  AddressStyle? _addressStyle;
  String? _amountHint = "";
  String? _splitAmountHint = "";
  String _addressHint = "";
  String? _memoHint = "";
  String _amountValidationText = "";
  String _splitAmountValidationText = "";
  String _addressValidationText = "";
  String _memoValidationText = "";
  String? quickSendAmount;
  List<dynamic>? _users;
  bool? animationOpen;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a username is being entered
  bool _isUser = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _showContactButton = true;
  // Local currency mode/fiat conversion
  bool _localCurrencyMode = false;
  String _lastLocalCurrencyAmount = "";
  String _lastLocalCurrencySplitAmount = "";
  String _lastCryptoAmount = "";
  String _lastCryptoSplitAmount = "";
  NumberFormat? _localCurrencyFormat;

  @override
  void initState() {
    super.initState();

    paper_wallet_account = NanoUtil.seedToAddress(paper_wallet_seed, 0);

    _amountFocusNode = FocusNode();
    _splitAmountFocusNode = FocusNode();
    _amountController = TextEditingController();
    _splitAmountController = TextEditingController();
    _memoFocusNode = FocusNode();
    _memoController = TextEditingController();
    _addressStyle = AddressStyle.TEXT60;

    // On amount focus change
    _amountFocusNode!.addListener(() {
      if (_amountFocusNode!.hasFocus) {
        setState(() {
          _amountHint = null;
          _amountValidationText = "";
          _splitAmountValidationText = "";
        });
      } else {
        setState(() {
          _amountHint = "";
        });
      }
    });
    // On split amount focus change
    _splitAmountFocusNode!.addListener(() {
      if (_splitAmountFocusNode!.hasFocus) {
        setState(() {
          _splitAmountHint = null;
          _splitAmountValidationText = "";
          _amountValidationText = "";
        });
      } else {
        setState(() {
          _splitAmountHint = "";
        });
      }
    });
    // On memo focus change
    _memoFocusNode!.addListener(() {
      if (_memoFocusNode!.hasFocus) {
        setState(() {
          _memoHint = null;
          _amountValidationText = "";
        });
      } else {
        setState(() {
          _memoHint = "";
        });
      }
    });
    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(locale: widget.localCurrency.getLocale().toString(), symbol: widget.localCurrency.getCurrencySymbol());
    // Set quick send amount
    if (quickSendAmount != null && quickSendAmount!.isNotEmpty && quickSendAmount != "0") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _amountController!.text = getRawAsThemeAwareAmount(context, quickSendAmount);
        });
      });
    }
  }

  bool _validateRequest() {
    bool isValid = true;
    // Validate amount
    BigInt? sendAmount;
    if (_amountController!.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _amountValidationText = AppLocalization.of(context)!.amountMissing;
      });
    } else {
      String bananoAmount;
      if (_localCurrencyMode) {
        bananoAmount = _convertLocalCurrencyToCrypto(_amountController!.text);
      } else {
        bananoAmount = _amountController!.text.replaceAll(_localCurrencyFormat!.currencySymbol, "").replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, "");
      }
      if (bananoAmount.isEmpty) {
        bananoAmount = "0";
      }
      final BigInt balanceRaw = StateContainer.of(context).wallet!.accountBalance;
      sendAmount = BigInt.tryParse(getThemeAwareAmountAsRaw(context, bananoAmount));
      if (sendAmount == null || sendAmount == BigInt.zero) {
        isValid = false;
        setState(() {
          _amountValidationText = AppLocalization.of(context)!.amountMissing;
        });
      } else if (sendAmount > balanceRaw) {
        isValid = false;
        setState(() {
          _amountValidationText = AppLocalization.of(context)!.insufficientBalance;
        });
      }
    }

    // Validate split amount
    if (_splitAmountController!.text.trim().isNotEmpty) {
      String bananoAmount;
      if (_localCurrencyMode) {
        bananoAmount = _convertLocalCurrencyToCrypto(_splitAmountController!.text);
      } else {
        bananoAmount =
            _splitAmountController!.text.replaceAll(_localCurrencyFormat!.currencySymbol, "").replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, "");
      }
      if (bananoAmount.isEmpty) {
        bananoAmount = "0";
      }
      final BigInt balanceRaw = StateContainer.of(context).wallet!.accountBalance;
      final BigInt? splitAmount = BigInt.tryParse(getThemeAwareAmountAsRaw(context, bananoAmount));

      if (splitAmount == null || splitAmount == BigInt.zero) {
        isValid = false;
        setState(() {
          _splitAmountValidationText = AppLocalization.of(context)!.amountMissing;
        });
      } else if (sendAmount != null && splitAmount > sendAmount) {
        isValid = false;
        setState(() {
          _splitAmountValidationText = AppLocalization.of(context)!.amountGiftGreaterError;
        });
      } else if (splitAmount > balanceRaw) {
        isValid = false;
        setState(() {
          _splitAmountValidationText = AppLocalization.of(context)!.insufficientBalance;
        });
      }
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  // Back Button
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    width: 50,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          primary: StateContainer.of(context).curTheme.text15,
                          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                  ),

                  // Safety icon
                  Container(
                    alignment: Alignment.center,
                    child: Icon(
                      AppIcons.money_bill_wave,
                      size: 48,
                      color: StateContainer.of(context).curTheme.primary,
                    ),
                  ),
                ],
              ),

              // The header
              Container(
                margin: EdgeInsetsDirectional.only(
                  start: smallScreen(context) ? 30 : 40,
                  end: smallScreen(context) ? 30 : 40,
                  top: 10,
                ),
                alignment: AlignmentDirectional.centerStart,
                child: AutoSizeText(
                  AppLocalization.of(context)!.createGiftHeader,
                  style: AppStyles.textStyleHeaderColored(context),
                  stepGranularity: 0.1,
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ),
              // The paragraph
              Container(
                height: 128,
                padding: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 15.0),
                child: DraggableScrollbar(
                  controller: _scrollController,
                  scrollbarColor: StateContainer.of(context).curTheme.primary!,
                  scrollbarTopMargin: 2.0,
                  scrollbarBottomMargin: 2.0,
                  scrollbarHeight: 30,
                  scrollbarHideAfterDuration: Duration.zero,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    // child: AutoSizeText(
                    //   AppLocalization.of(context)!.giftInfo,
                    //   style: AppStyles.textStyleParagraph(context),
                    //   maxLines: 12,
                    //   minFontSize: 12,
                    //   stepGranularity: 0.5,
                    // ),
                    child: Text(
                      AppLocalization.of(context)!.giftInfo,
                      style: AppStyles.textStyleParagraph(context),
                    ),
                    // ),
                  ),
                ),
              ),
              // A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  // Clear focus of our fields when tapped in this empty space
                  _amountFocusNode!.unfocus();
                  _splitAmountFocusNode!.unfocus();
                  _memoFocusNode!.unfocus();
                },
                child: KeyboardAvoider(
                  duration: Duration.zero,
                  autoScroll: true,
                  focusPadding: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.w600,
                            )),
                      ),

                      // ******* Enter Amount Container ******* //
                      getEnterSplitAmountContainer(),
                      // ******* Enter Amount Container End ******* //

                      // ******* Enter Amount Error Container ******* //
                      Container(
                        alignment: AlignmentDirectional.center,
                        margin: const EdgeInsets.only(top: 3),
                        child: Text(_splitAmountValidationText,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: StateContainer.of(context).curTheme.primary,
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.w600,
                            )),
                      ),

                      // ******* Enter Amount Error Container End ******* //
                      // Column for Enter Memo container + Enter Memo Error container
                      Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topCenter,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                                  alignment: Alignment.bottomCenter,
                                  constraints: const BoxConstraints(maxHeight: 80, minHeight: 0),
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
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.w600,
                                )),
                          )
                          // ******* Enter Memo Error Container End ******* //
                        ],
                      ),
                    ],
                  ),
                ),
              )),

              // Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context)!.createGiftCard, Dimens.BUTTON_BOTTOM_DIMENS,
                      onPressed: () {
                    final bool isValid = _validateRequest();
                    if (!isValid) {
                      return;
                    }

                    final String? memo = _memoController!.text.isNotEmpty ? _memoController!.text : null;

                    Sheets.showAppHeightNineSheet(
                        context: context,
                        widget: GenerateConfirmSheet(
                          paperWalletSeed: paper_wallet_seed,
                          memo: memo ?? "",
                          destination: paper_wallet_account,
                          amountRaw: _localCurrencyMode
                              ? NumberUtil.getAmountAsRaw(_convertLocalCurrencyToCrypto(_amountController!.text))
                              : getThemeAwareAmountAsRaw(context, _amountController!.text),
                          splitAmountRaw: _localCurrencyMode
                              ? NumberUtil.getAmountAsRaw(_convertLocalCurrencyToCrypto(_splitAmountController!.text))
                              : getThemeAwareAmountAsRaw(context, _splitAmountController!.text),
                        ));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _convertLocalCurrencyToCrypto(String amount) {
    String convertedAmt = amount.replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, "").replaceAll(_localCurrencyFormat!.symbols.DECIMAL_SEP, ".");
    convertedAmt = NumberUtil.sanitizeNumber(convertedAmt);
    if (convertedAmt.isEmpty) {
      return "";
    }
    final Decimal valueLocal = Decimal.parse(convertedAmt);
    final Decimal conversion = Decimal.parse(StateContainer.of(context).wallet!.localCurrencyConversion!);
    final String nanoAmount = NumberUtil.truncateDecimal((valueLocal / conversion).toDecimal(scaleOnInfinitePrecision: 16));
    return convertCryptoToLocalAmount(nanoAmount, _localCurrencyFormat);
  }

  String _convertCryptoToLocalCurrency(String amount) {
    String sanitizedAmt = amount.replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, "").replaceAll(_localCurrencyFormat!.symbols.DECIMAL_SEP, ".");
    sanitizedAmt = NumberUtil.sanitizeNumber(sanitizedAmt);
    if (sanitizedAmt.isEmpty) {
      return "";
    }
    final Decimal valueCrypto = Decimal.parse(sanitizedAmt);
    final Decimal conversion = Decimal.parse(StateContainer.of(context).wallet!.localCurrencyConversion!);
    sanitizedAmt = NumberUtil.truncateDecimal(valueCrypto * conversion, digits: 2);

    return (_localCurrencyFormat!.currencySymbol + convertCryptoToLocalAmount(sanitizedAmt, _localCurrencyFormat)).replaceAll(" ", "");
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
        balance = StateContainer.of(context)
            .wallet!
            .getLocalCurrencyBalance(context, StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale);
      } else {
        balance = getRawAsThemeAwareFormattedAmount(context, StateContainer.of(context).wallet!.accountBalance.toString());
      }
      // Convert to Integer representations
      int textFieldInt;
      int balanceInt;
      if (_localCurrencyMode) {
        // Sanitize currency values into plain integer representations
        textField = textField.replaceAll(",", ".");
        final String sanitizedTextField = NumberUtil.sanitizeNumber(textField);
        balance = balance.replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, "");
        balance = balance.replaceAll(",", ".");
        final String sanitizedBalance = NumberUtil.sanitizeNumber(balance);
        textFieldInt = (Decimal.parse(sanitizedTextField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
        balanceInt = (Decimal.parse(sanitizedBalance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
      } else {
        textField = textField.replaceAll(",", "");
        textFieldInt = (Decimal.parse(textField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
        balanceInt = (Decimal.parse(balance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
      }
      return textFieldInt == balanceInt;
    } catch (e) {
      return false;
    }
  }

  void toggleLocalCurrency() {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
    // this way you can tap button and tap back and not end up with X.9993451 NANO
    if (_localCurrencyMode) {
      // Switching to crypto-mode
      String cryptoAmountStr;
      String cryptoSplitAmountStr;
      // Check out previous state
      if (_amountController!.text == _lastLocalCurrencyAmount) {
        cryptoAmountStr = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = _amountController!.text;
        _lastCryptoAmount = _convertLocalCurrencyToCrypto(_amountController!.text);
        cryptoAmountStr = _lastCryptoAmount;
      }
      // split:
      if (_splitAmountController!.text == _lastLocalCurrencySplitAmount) {
        cryptoSplitAmountStr = _lastCryptoSplitAmount;
      } else {
        _lastLocalCurrencySplitAmount = _splitAmountController!.text;
        _lastCryptoSplitAmount = _convertLocalCurrencyToCrypto(_splitAmountController!.text);
        cryptoSplitAmountStr = _lastCryptoSplitAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _amountController!.text = cryptoAmountStr;
        _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
        _splitAmountController!.text = cryptoSplitAmountStr;
        _splitAmountController!.selection = TextSelection.fromPosition(TextPosition(offset: cryptoSplitAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      String localSplitAmountStr;
      // Check our previous state
      if (_amountController!.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
        if (!_lastLocalCurrencyAmount.startsWith(_localCurrencyFormat!.currencySymbol)) {
          _lastLocalCurrencyAmount = _localCurrencyFormat!.currencySymbol + _lastLocalCurrencyAmount;
        }
      } else {
        _lastCryptoAmount = _amountController!.text;
        _lastLocalCurrencyAmount = _convertCryptoToLocalCurrency(_amountController!.text);
        localAmountStr = _lastLocalCurrencyAmount;
      }
      // split:
      if (_splitAmountController!.text == _lastCryptoAmount) {
        localSplitAmountStr = _lastLocalCurrencySplitAmount;
        if (!_lastLocalCurrencySplitAmount.startsWith(_localCurrencyFormat!.currencySymbol)) {
          _lastLocalCurrencySplitAmount = _localCurrencyFormat!.currencySymbol + _lastLocalCurrencySplitAmount;
        }
      } else {
        _lastCryptoSplitAmount = _splitAmountController!.text;
        _lastLocalCurrencySplitAmount = _convertCryptoToLocalCurrency(_splitAmountController!.text);
        localSplitAmountStr = _lastLocalCurrencySplitAmount;
      }

      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _amountController!.text = localAmountStr;
        _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
        _splitAmountController!.text = localSplitAmountStr;
        _splitAmountController!.selection = TextSelection.fromPosition(TextPosition(offset: localSplitAmountStr.length));
      });
    }
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  Widget getEnterAmountContainer() {
    return AppTextField(
      focusNode: _amountFocusNode,
      controller: _amountController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'NunitoSans',
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(13),
        if (_localCurrencyMode)
          CurrencyFormatter(
              decimalSeparator: _localCurrencyFormat!.symbols.DECIMAL_SEP, commaSeparator: _localCurrencyFormat!.symbols.GROUP_SEP, maxDecimalDigits: 2)
        else
          CurrencyFormatter(maxDecimalDigits: NumberUtil.maxDecimalDigits),
        LocalCurrencyFormatter(active: _localCurrencyMode, currencyFormat: _localCurrencyFormat)
      ],
      onChanged: (String text) {
        // Always reset the error message to be less annoying
        setState(() {
          _amountValidationText = "";
        });
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _amountHint == null ? "" : AppLocalization.of(context)!.enterAmount,
      prefixButton: TextFieldButton(
        icon: AppIcons.swapcurrency,
        onPressed: () {
          toggleLocalCurrency();
        },
      ),
      suffixButton: TextFieldButton(
        icon: AppIcons.max,
        onPressed: () {
          if (_isMaxSend()) {
            return;
          }
          if (!_localCurrencyMode) {
            _amountController!.text = getRawAsThemeAwareAmount(context, StateContainer.of(context).wallet!.accountBalance.toString());
          } else {
            String localAmount = StateContainer.of(context)
                .wallet!
                .getLocalCurrencyBalance(context, StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale);
            localAmount = localAmount.replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, "");
            localAmount = localAmount.replaceAll(_localCurrencyFormat!.symbols.DECIMAL_SEP, ".");
            localAmount = NumberUtil.sanitizeNumber(localAmount).replaceAll(".", _localCurrencyFormat!.symbols.DECIMAL_SEP);
            _amountController!.text = _localCurrencyFormat!.currencySymbol + localAmount;
          }
        },
      ),
      fadeSuffixOnCondition: true,
      suffixShowFirstCondition: !_isMaxSend(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (String text) {
        FocusScope.of(context).nextFocus();
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  Widget getEnterSplitAmountContainer() {
    return AppTextField(
      focusNode: _splitAmountFocusNode,
      controller: _splitAmountController,
      topMargin: 10,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'NunitoSans',
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(13),
        if (_localCurrencyMode)
          CurrencyFormatter(
              decimalSeparator: _localCurrencyFormat!.symbols.DECIMAL_SEP, commaSeparator: _localCurrencyFormat!.symbols.GROUP_SEP, maxDecimalDigits: 2)
        else
          CurrencyFormatter(maxDecimalDigits: NumberUtil.maxDecimalDigits),
        LocalCurrencyFormatter(active: _localCurrencyMode, currencyFormat: _localCurrencyFormat)
      ],
      onChanged: (String text) {
        // Always reset the error message to be less annoying
        setState(() {
          _splitAmountValidationText = "";
        });
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _splitAmountHint == null ? "" : AppLocalization.of(context)!.enterSplitAmount,
      prefixButton: TextFieldButton(
        icon: AppIcons.swapcurrency,
        onPressed: () {
          toggleLocalCurrency();
        },
      ),
      fadeSuffixOnCondition: true,
      suffixShowFirstCondition: !_isMaxSend(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (String text) {
        FocusScope.of(context).nextFocus();
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Memo Container Method ************//
  //*******************************************************//
  Widget getEnterMemoContainer() {
    return AppTextField(
      topMargin: 10,
      padding: EdgeInsets.zero,
      textAlign: TextAlign.center,
      focusNode: _memoFocusNode,
      controller: _memoController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        LengthLimitingTextInputFormatter(200),
      ],
      textInputAction: TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      hintText: _memoHint == null ? "" : AppLocalization.of(context)!.enterGiftMemo,
      fadeSuffixOnCondition: true,
      style: TextStyle(
        // fontWeight: FontWeight.w700,
        // fontSize: 16.0,
        // color: StateContainer.of(context).curTheme.primary,
        // fontFamily: 'NunitoSans',
        color: StateContainer.of(context).curTheme.text60,
        fontSize: AppFontSizes.small,
        height: 1.5,
        fontWeight: FontWeight.w100,
        fontFamily: 'OverpassMono',
      ),
    );
  } //************ Enter Memo Container Method End ************//
  //*************************************************************//
}
