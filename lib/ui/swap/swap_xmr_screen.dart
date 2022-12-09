import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/swap/swap_xmr_confirm_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/numberutil.dart';
import 'package:wallet_flutter/util/user_data_util.dart';

class SwapXMRScreen extends StatefulWidget {
  // needs: StateContainer.of(context).curCurrency
  const SwapXMRScreen({required this.localCurrency}) : super();
  final AvailableCurrency localCurrency;

  @override
  SwapXMRScreenState createState() => SwapXMRScreenState();
}

class SwapXMRScreenState extends State<SwapXMRScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // String paper_wallet_seed = NanoSeeds.generateSeed();
  // late String paper_wallet_account;

  FocusNode? _amountFocusNode;
  FocusNode? _addressFocusNode;
  TextEditingController? _amountController;
  TextEditingController? _xmrAddressController;

  ScrollController _scrollController = ScrollController();

  // States
  AddressStyle? _addressStyle;
  String? _amountHint = "";
  String _addressHint = "";
  String? _xmrAddressHint = "";
  String _amountValidationText = "";
  String _xmrAddressValidationText = "";
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
  String _lastCryptoAmount = "";
  late NumberFormat _localCurrencyFormat;
  bool _clearButton = false;
  bool _pasteButtonVisible = true;

  @override
  void initState() {
    super.initState();

    // paper_wallet_account = NanoUtil.seedToAddress(paper_wallet_seed, 0);

    _amountFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _amountController = TextEditingController();
    _xmrAddressController = TextEditingController();
    _addressStyle = AddressStyle.TEXT60;

    // On amount focus change
    _amountFocusNode!.addListener(() {
      if (_amountFocusNode!.hasFocus) {
        setState(() {
          _amountHint = null;
          _amountValidationText = "";
        });
      } else {
        setState(() {
          _amountHint = "";
        });
      }
    });
    // On xmr address focus change
    _addressFocusNode!.addListener(() {
      if (_addressFocusNode!.hasFocus) {
        setState(() {
          _xmrAddressHint = null;
          _amountValidationText = "";
          _pasteButtonVisible = true;
        });
      } else {
        setState(() {
          _xmrAddressHint = "";
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
        _amountValidationText = Z.of(context).amountMissing;
      });
    } else {
      String bananoAmount;
      if (_localCurrencyMode) {
        bananoAmount = sanitizedAmount(_localCurrencyFormat, convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text));
      } else {
        bananoAmount = sanitizedAmount(_localCurrencyFormat, _amountController!.text);
      }
      if (bananoAmount.isEmpty) {
        bananoAmount = "0";
      }
      final BigInt balanceRaw = StateContainer.of(context).wallet!.accountBalance;
      sendAmount = BigInt.tryParse(getThemeAwareAmountAsRaw(context, bananoAmount));
      if (sendAmount == null || sendAmount == BigInt.zero) {
        isValid = false;
        setState(() {
          _amountValidationText = Z.of(context).amountMissing;
        });
      } else if (sendAmount > balanceRaw) {
        isValid = false;
        setState(() {
          _amountValidationText = Z.of(context).insufficientBalance;
        });
      }
    }

    // Validate address
    if (_xmrAddressController!.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _xmrAddressValidationText = Z.of(context).addressMissing;
      });
    } else {
      // if (!Address(_xmrAddressController!.text).isValid()) {
      //   isValid = false;
      //   setState(() {
      //     _xmrAddressValidationText = Z.of(context).invalidAddress;
      //   });
      // }
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
                          foregroundColor: StateContainer.of(context).curTheme.text15, backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
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
                      AppIcons.swapcurrency,
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
                alignment: AlignmentDirectional.center,
                child: AutoSizeText(
                  Z.of(context).swapXMRHeader,
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
                  scrollbarColor: StateContainer.of(context).curTheme.primary,
                  scrollbarTopMargin: 2.0,
                  scrollbarBottomMargin: 2.0,
                  scrollbarHeight: 30,
                  scrollbarHideAfterDuration: Duration.zero,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    // child: AutoSizeText(
                    //   Z.of(context).giftInfo,
                    //   style: AppStyles.textStyleParagraph(context),
                    //   maxLines: 12,
                    //   minFontSize: 12,
                    //   stepGranularity: 0.5,
                    // ),
                    child: Text(
                      Z.of(context).swapXMRInfo,
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
                  _addressFocusNode!.unfocus();
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
                              fontFamily: "NunitoSans",
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

                                // ******* Enter XMR Address Container ******* //
                                getEnterXMRAddressContainer(),
                                // ******* Enter XMR Address Container End ******* //
                              ],
                            ),
                          ),

                          // ******* Enter XMR Address Error Container ******* //
                          Container(
                            alignment: AlignmentDirectional.center,
                            margin: const EdgeInsets.only(top: 3),
                            child: Text(_xmrAddressValidationText,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: StateContainer.of(context).curTheme.primary,
                                  fontFamily: "NunitoSans",
                                  fontWeight: FontWeight.w600,
                                )),
                          )
                          // ******* Enter XMR Address Error Container End ******* //
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
                  AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).swapXMRHeader, Dimens.BUTTON_BOTTOM_DIMENS,
                      onPressed: () async {
                    final bool isValid = _validateRequest();
                    if (!isValid) {
                      return;
                    } else {
                      setState(() {
                        _amountValidationText = "";
                        _xmrAddressValidationText = "";
                      });
                    }

                    final String xmrAddress = _xmrAddressController!.text;

                    final String formattedAmount = sanitizedAmount(_localCurrencyFormat, _amountController!.text);
                    final String amountRaw = _localCurrencyMode
                        ? NumberUtil.getAmountAsRaw(
                            sanitizedAmount(_localCurrencyFormat, convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, formattedAmount)))
                        : getThemeAwareAmountAsRaw(context, formattedAmount);

                    // start a swap for monero:

                    final Map resp = await sl.get<AccountService>().createSwapToXMR(amountRaw: amountRaw, xmrAddress: xmrAddress) as Map;
                    if (!resp.containsKey("payInAddress")) {
                      print("Error creating swap: ${resp["error"]}");
                      return;
                    }

                    String payInAddress = resp["payInAddress"] as String;

                    Sheets.showAppHeightNineSheet(
                        context: context,
                        widget: SwapXMRConfirmSheet(
                          destination: payInAddress,
                          amountRaw: amountRaw,
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
        final String sanitizedTextField = sanitizedAmount(_localCurrencyFormat, textField);
        final String sanitizedBalance = sanitizedAmount(_localCurrencyFormat, balance);
        textFieldInt = (Decimal.parse(sanitizedTextField) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
        balanceInt = (Decimal.parse(sanitizedBalance) * Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits) as int)).toDouble().toInt();
      } else {
        textField = sanitizedAmount(_localCurrencyFormat, textField);
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
      // Check out previous state
      if (_amountController!.text == _lastLocalCurrencyAmount) {
        cryptoAmountStr = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = _amountController!.text;
        _lastCryptoAmount = convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text);
        cryptoAmountStr = _lastCryptoAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _amountController!.text = cryptoAmountStr;
        _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (_amountController!.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
        if (!_lastLocalCurrencyAmount.startsWith(_localCurrencyFormat.currencySymbol)) {
          _lastLocalCurrencyAmount = _localCurrencyFormat.currencySymbol + _lastLocalCurrencyAmount;
        }
      } else {
        _lastCryptoAmount = _amountController!.text;
        _lastLocalCurrencyAmount = convertCryptoToLocalCurrency(context, _localCurrencyFormat, _amountController!.text);
        localAmountStr = _lastLocalCurrencyAmount;
      }

      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _amountController!.text = localAmountStr;
        _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
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
        });
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _amountHint == null ? "" : Z.of(context).enterAmount,
      prefixButton: TextFieldButton(
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
            setState(() {
              _amountValidationText = "";
              _amountController!.text = getRawAsThemeAwareFormattedAmount(context, StateContainer.of(context).wallet!.accountBalance.toString());
              _amountController!.selection = TextSelection.collapsed(offset: _amountController!.text.length);
            });
          } else {
            String localAmount = StateContainer.of(context)
                .wallet!
                .getLocalCurrencyBalance(context, StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale);
            localAmount = localAmount.replaceAll(_localCurrencyFormat.symbols.GROUP_SEP, "");
            localAmount = localAmount.replaceAll(_localCurrencyFormat.symbols.DECIMAL_SEP, ".");
            localAmount = NumberUtil.sanitizeNumber(localAmount).replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
            setState(() {
              _amountValidationText = "";
              _amountController!.text = _localCurrencyFormat.currencySymbol + localAmount;
              _amountController!.selection = TextSelection.collapsed(offset: _amountController!.text.length);
            });
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

  //************ Enter Memo Container Method ************//
  //*******************************************************//
  Widget getEnterXMRAddressContainer() {
    return AppTextField(
      topMargin: 10,
      padding: EdgeInsets.zero,
      textAlign: TextAlign.center,
      focusNode: _addressFocusNode,
      controller: _xmrAddressController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        LengthLimitingTextInputFormatter(200),
      ],
      textInputAction: TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      hintText: _xmrAddressHint == null ? "" : Z.of(context).enterMoneroAddress,
      fadeSuffixOnCondition: true,
      style: TextStyle(
        // fontWeight: FontWeight.w700,
        // fontSize: 16.0,
        // color: StateContainer.of(context).curTheme.primary,
        // fontFamily: "NunitoSans",
        color: StateContainer.of(context).curTheme.text60,
        fontSize: AppFontSizes.small,
        height: 1.5,
        fontWeight: FontWeight.w100,
        fontFamily: 'OverpassMono',
      ),
      suffixShowFirstCondition: _pasteButtonVisible,
      suffixButton: TextFieldButton(
        icon: _clearButton ? AppIcons.clear : AppIcons.paste,
        onPressed: () async {
          if (_clearButton) {
            setState(() {
              _isUser = false;
              _xmrAddressValidationText = "";
              _pasteButtonVisible = true;
              _clearButton = false;
              _xmrAddressController!.text = "";
            });
            return;
          }

          final String? data = await UserDataUtil.getClipboardText(DataType.RAW);
          // TODO: validate the monero address:
          if (data != null) {
            if (mounted) {
              setState(() {
                _xmrAddressController!.text = data;
                _pasteButtonVisible = false;
                _clearButton = true;
              });
              _addressFocusNode!.unfocus();
            }
          }
        },
      ),
      onChanged: (String text) async {
        bool isUser = false;
        final bool isDomain = text.contains(".") || text.contains(r"$");
        final bool isFavorite = text.startsWith("★");
        final bool isNano = text.startsWith("nano_");

        // prevent spaces:
        if (text.contains(" ")) {
          text = text.replaceAll(" ", "");
          _xmrAddressController!.text = text;
          _xmrAddressController!.selection = TextSelection.fromPosition(TextPosition(offset: _xmrAddressController!.text.length));
        }

        if (text.isNotEmpty) {
          setState(() {
            _pasteButtonVisible = true;
            _clearButton = true;
          });
        } else {
          setState(() {
            _pasteButtonVisible = true;
            _clearButton = false;
          });
        }
      },
    );
  } //************ Enter Memo Container Method End ************//
  //*************************************************************//
}
