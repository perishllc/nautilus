import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';

// import 'package:flare_flutter/flare_actor.dart';
// import 'package:nautilus_wallet_flutter/dimens.dart';
// import 'package:nautilus_wallet_flutter/localization.dart';
// import 'package:nautilus_wallet_flutter/model/vault.dart';
// import 'package:nautilus_wallet_flutter/service_locator.dart';
// import 'package:nautilus_wallet_flutter/styles.dart';
// import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';

class GeneratePaperWalletScreen extends StatefulWidget {
  final AvailableCurrency localCurrency;
  // needs: StateContainer.of(context).curCurrency
  GeneratePaperWalletScreen({@required this.localCurrency}) : super();

  @override
  _GeneratePaperWalletScreenState createState() => _GeneratePaperWalletScreenState();
}

class _GeneratePaperWalletScreenState extends State<GeneratePaperWalletScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  String paper_wallet_seed;
  String paper_wallet_account;

  FocusNode _sendAddressFocusNode;
  TextEditingController _sendAddressController;
  FocusNode _sendAmountFocusNode;
  TextEditingController _sendAmountController;

  // States
  AddressStyle _sendAddressStyle;
  String _amountHint = "";
  String _addressHint = "";
  String _amountValidationText = "";
  String _addressValidationText = "";
  String quickSendAmount;
  List<dynamic> _users;
  bool animationOpen;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a username is being entered
  bool _isUser = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;
  bool _showContactButton = true;
  // Local currency mode/fiat conversion
  bool _localCurrencyMode = false;
  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";
  NumberFormat _localCurrencyFormat;

  String _rawAmount;

  @override
  void initState() {
    super.initState();

    paper_wallet_seed = NanoSeeds.generateSeed();
    paper_wallet_account = NanoUtil.seedToAddress(paper_wallet_seed, 0);

    _sendAmountFocusNode = FocusNode();
    _sendAmountController = TextEditingController();
    _sendAddressStyle = AddressStyle.TEXT60;

    // On amount focus change
    _sendAmountFocusNode.addListener(() {
      if (_sendAmountFocusNode.hasFocus) {
        if (_rawAmount != null) {
          setState(() {
            _sendAmountController.text = NumberUtil.getRawAsUsableString(_rawAmount).replaceAll(",", "");
            _rawAmount = null;
          });
        }
        setState(() {
          _amountHint = null;
        });
      } else {
        setState(() {
          _amountHint = "";
        });
      }
    });
    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(locale: widget.localCurrency.getLocale().toString(), symbol: widget.localCurrency.getCurrencySymbol());
    // Set quick send amount
    if (quickSendAmount != null) {
      _sendAmountController.text = NumberUtil.getRawAsUsableString(quickSendAmount).replaceAll(",", "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (context, constraints) => SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              // A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Back Button
                        Container(
                          margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 15 : 20),
                          height: 50,
                          width: 50,
                          child: FlatButton(
                              highlightColor: StateContainer.of(context).curTheme.text15,
                              splashColor: StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(0.0),
                              child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                      ],
                    ),
                    // Safety icon
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40,
                        top: 15,
                      ),
                      child: Icon(
                        AppIcons.security,
                        size: 60,
                        color: StateContainer.of(context).curTheme.primary,
                      ),
                    ),
                    // The header
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40,
                        end: smallScreen(context) ? 30 : 40,
                        top: 10,
                      ),
                      alignment: AlignmentDirectional(-1, 0),
                      child: AutoSizeText(
                        "TODO!",
                        style: AppStyles.textStyleHeaderColored(context),
                        stepGranularity: 0.1,
                        maxLines: 1,
                        minFontSize: 12,
                      ),
                    ),
                    // The paragraph
                    // Container(
                    //   margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 15.0),
                    //   alignment: Alignment.centerLeft,
                    //   child: Column(
                    //     children: <Widget>[
                    //       // AutoSizeText(
                    //       //   AppLocalization.of(context).secretInfo,
                    //       //   style: AppStyles.textStyleParagraph(context),
                    //       //   maxLines: 5,
                    //       //   stepGranularity: 0.5,
                    //       // ),
                    //       Container(
                    //         margin: EdgeInsetsDirectional.only(top: 15),
                    //         child: Text("$paper_wallet_seed $paper_wallet_account"),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // ******* Enter Amount Container ******* //
                    getEnterAmountContainer(),
                    // ******* Enter Amount Container End ******* //

                    // ******* Enter Amount Error Container ******* //
                    Container(
                      alignment: AlignmentDirectional(0, 0),
                      margin: EdgeInsets.only(top: 3),
                      child: Text(_amountValidationText,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: StateContainer.of(context).curTheme.primary,
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    // ******* Enter Amount Error Container End ******* //
                  ],
                ),
              ),

              // Next Screen Button
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).gotItButton, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
              //       Navigator.of(context).pushNamed('/intro_backup', arguments: StateContainer.of(context).encryptedSecret);
              //     }),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  String _convertLocalCurrencyToCrypto() {
    String convertedAmt = _sendAmountController.text.replaceAll(",", ".");
    convertedAmt = NumberUtil.sanitizeNumber(convertedAmt);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueLocal = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(StateContainer.of(context).wallet.localCurrencyConversion);
    return NumberUtil.truncateDecimal(valueLocal / conversion).toString();
  }

  String _convertCryptoToLocalCurrency() {
    String convertedAmt = NumberUtil.sanitizeNumber(_sendAmountController.text, maxDecimalDigits: 2);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueCrypto = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(StateContainer.of(context).wallet.localCurrencyConversion);
    convertedAmt = NumberUtil.truncateDecimal(valueCrypto * conversion, digits: 2).toString();
    convertedAmt = convertedAmt.replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
    convertedAmt = _localCurrencyFormat.currencySymbol + convertedAmt;
    return convertedAmt;
  }

  // Determine if this is a max send or not by comparing balances
  bool _isMaxSend() {
    // Sanitize commas
    if (_sendAmountController.text.isEmpty) {
      return false;
    }
    try {
      String textField = _sendAmountController.text;
      String balance;
      if (_localCurrencyMode) {
        balance =
            StateContainer.of(context).wallet.getLocalCurrencyPrice(StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale);
      } else {
        balance = StateContainer.of(context).wallet.getAccountBalanceDisplay(context).replaceAll(r",", "");
      }
      // Convert to Integer representations
      int textFieldInt;
      int balanceInt;
      if (_localCurrencyMode) {
        // Sanitize currency values into plain integer representations
        textField = textField.replaceAll(",", ".");
        String sanitizedTextField = NumberUtil.sanitizeNumber(textField);
        balance = balance.replaceAll(_localCurrencyFormat.symbols.GROUP_SEP, "");
        balance = balance.replaceAll(",", ".");
        String sanitizedBalance = NumberUtil.sanitizeNumber(balance);
        textFieldInt = (Decimal.parse(sanitizedTextField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits))).toInt();
        balanceInt = (Decimal.parse(sanitizedBalance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits))).toInt();
      } else {
        textField = textField.replaceAll(",", "");
        textFieldInt = (Decimal.parse(textField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits))).toInt();
        balanceInt = (Decimal.parse(balance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits))).toInt();
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
      // Check out previous state
      if (_sendAmountController.text == _lastLocalCurrencyAmount) {
        cryptoAmountStr = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = _sendAmountController.text;
        _lastCryptoAmount = _convertLocalCurrencyToCrypto();
        cryptoAmountStr = _lastCryptoAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _sendAmountController.text = cryptoAmountStr;
        _sendAmountController.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (_sendAmountController.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
      } else {
        _lastCryptoAmount = _sendAmountController.text;
        _lastLocalCurrencyAmount = _convertCryptoToLocalCurrency();
        localAmountStr = _lastLocalCurrencyAmount;
      }
      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _sendAmountController.text = localAmountStr;
        _sendAmountController.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
      });
    }
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  getEnterAmountContainer() {
    return AppTextField(
      focusNode: _sendAmountFocusNode,
      controller: _sendAmountController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'NunitoSans',
      ),
      inputFormatters: _rawAmount == null
          ? [
              LengthLimitingTextInputFormatter(13),
              _localCurrencyMode
                  ? CurrencyFormatter(
                      decimalSeparator: _localCurrencyFormat.symbols.DECIMAL_SEP, commaSeparator: _localCurrencyFormat.symbols.GROUP_SEP, maxDecimalDigits: 2)
                  : CurrencyFormatter(maxDecimalDigits: NumberUtil.maxDecimalDigits),
              LocalCurrencyFormatter(active: _localCurrencyMode, currencyFormat: _localCurrencyFormat)
            ]
          : [LengthLimitingTextInputFormatter(13)],
      onChanged: (text) {
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
      hintText: _amountHint == null ? "" : AppLocalization.of(context).enterAmount,
      prefixButton: _rawAmount == null
          ? TextFieldButton(
              icon: AppIcons.swapcurrency,
              onPressed: () {
                toggleLocalCurrency();
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
            _sendAmountController.text = StateContainer.of(context).wallet.getAccountBalanceDisplay(context).replaceAll(r",", "");
            _sendAddressController.selection = TextSelection.fromPosition(TextPosition(offset: _sendAddressController.text.length));
          } else {
            String localAmount = StateContainer.of(context)
                .wallet
                .getLocalCurrencyPrice(StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale);
            localAmount = localAmount.replaceAll(_localCurrencyFormat.symbols.GROUP_SEP, "");
            localAmount = localAmount.replaceAll(_localCurrencyFormat.symbols.DECIMAL_SEP, ".");
            localAmount = NumberUtil.sanitizeNumber(localAmount).replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
            _sendAmountController.text = _localCurrencyFormat.currencySymbol + localAmount;
            _sendAddressController.selection = TextSelection.fromPosition(TextPosition(offset: _sendAddressController.text.length));
          }
        },
      ),
      fadeSuffixOnCondition: true,
      suffixShowFirstCondition: !_isMaxSend(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (text) {
        FocusScope.of(context).unfocus();
        if (!Address(_sendAddressController.text).isValid()) {
          FocusScope.of(context).requestFocus(_sendAddressFocusNode);
        }
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

}