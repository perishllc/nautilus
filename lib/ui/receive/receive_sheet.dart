import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as Math;
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/themes.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/strings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/receive/share_card.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  final double? min;
  final double? max;

  NumericalRangeFormatter({double? this.min, double? this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min!) {
      return TextEditingValue().copyWith(text: min!.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max! ? oldValue : newValue;
    }
  }
}

class ReceiveSheet extends StatefulWidget {
  final AvailableCurrency localCurrency;
  final Widget? qrWidget;
  final String? address;

  ReceiveSheet({required this.localCurrency, this.address, this.qrWidget}) : super();

  _ReceiveSheetStateState createState() => _ReceiveSheetStateState();
}

class _ReceiveSheetStateState extends State<ReceiveSheet> {
  GlobalKey? shareCardKey;
  ByteData? shareImageData;
  // Address copied items
  // Current state references
  bool? _showShareCard;
  late bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  FocusNode? _sendAmountFocusNode;
  String? _rawAmount;
  TextEditingController? _sendAmountController;
  NumberFormat? _localCurrencyFormat;
  bool _localCurrencyMode = false;
  String _amountValidationText = "";
  String? _amountHint = "";
  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";

  Widget? qrWidget;

  Future<Uint8List?> _capturePng() async {
    if (shareCardKey != null && shareCardKey!.currentContext != null) {
      RenderRepaintBoundary boundary = shareCardKey!.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      return byteData.buffer.asUint8List();
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial state of copy button
    _addressCopied = false;
    // Create our SVG-heavy things in the constructor because they are slower operations
    // Share card initialization
    shareCardKey = GlobalKey();
    _showShareCard = false;

    _sendAmountFocusNode = FocusNode();
    _sendAmountController = TextEditingController();

    // On amount focus change
    _sendAmountFocusNode!.addListener(() {
      if (_sendAmountFocusNode!.hasFocus) {
        if (_rawAmount != null) {
          setState(() {
            _sendAmountController!.text = NumberUtil.getRawAsUsableString(_rawAmount).replaceAll(",", "");
            _rawAmount = null;
          });
        }
        // if (quickSendAmount != null) {
        //   _sendAmountController.text = "";
        //   setState(() {
        //     quickSendAmount = null;
        //   });
        // }
        setState(() {
          _amountHint = null;
        });
      } else {
        setState(() {
          _amountHint = "";
        });

        // // Redraw QR?
        // String raw;
        // if (_localCurrencyMode) {
        //   _lastLocalCurrencyAmount = _sendAmountController.text;
        //   _lastCryptoAmount = _convertLocalCurrencyToCrypto();
        //   raw = NumberUtil.getAmountAsRaw(_lastCryptoAmount);
        // } else {
        //   raw = _sendAmountController.text.length > 0 ? NumberUtil.getAmountAsRaw(_sendAmountController.text) : '';
        // }
        // this.paintQrCode(address: widget.address, amount: raw);
      }
    });
    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(locale: widget.localCurrency.getLocale().toString(), symbol: widget.localCurrency.getCurrencySymbol());

    qrWidget = widget.qrWidget;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: GestureDetector(
            onTap: () {
              // Clear focus of our fields when tapped in this empty space
              _sendAmountFocusNode!.unfocus();
            },
            child: Column(
              children: <Widget>[
                // A row for the address text and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Empty SizedBox
                    SizedBox(
                      width: 60,
                      height: 60,
                    ),
                    //Container for the address text and sheet handle
                    Column(
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
                        // show napi username if available:
                        Container(
                          margin: (StateContainer.of(context).wallet?.username != null) ? EdgeInsets.only(top: 35.0) : EdgeInsets.only(top: 15.0),
                          child: (StateContainer.of(context).wallet?.username != null)
                              ? Text(StateContainer.of(context).wallet!.username!,
                                  style: TextStyle(
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 24.0,
                                    color: StateContainer.of(context).curTheme.text60,
                                  ))
                              : UIUtil.threeLineAddressText(context, StateContainer.of(context).wallet!.address!, type: ThreeLineAddressTextType.PRIMARY60),
                        ),
                      ],
                    ),
                    //Empty SizedBox
                    SizedBox(
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),
                // Column for Balance Text, Enter Amount container + Enter Amount Error container WIP
                Column(
                  children: <Widget>[
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
                // QR which takes all the available space left from the buttons & address text
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(top: 20, bottom: 28, start: 20, end: 20),
                    child: LayoutBuilder(builder: (context, constraints) {
                      double availableWidth = constraints.maxWidth;
                      double availableHeight = (StateContainer.of(context).wallet?.username != null) ? (constraints.maxHeight - 70) : constraints.maxHeight;
                      double widthDivideFactor = 1.3;
                      double computedMaxSize = Math.min(availableWidth / widthDivideFactor, availableHeight);
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            _showShareCard!
                                ? Container(
                                    child: AppShareCard(
                                      shareCardKey,
                                      SvgPicture.asset('legacy_assets/QR.svg'),
                                      SvgPicture.asset('legacy_assets/sharecard_logo.svg'),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                  )
                                : SizedBox(),
                            // This is for hiding the share card
                            Center(
                              child: Container(
                                width: 260,
                                height: 150,
                                color: StateContainer.of(context).curTheme.backgroundDark,
                              ),
                            ),
                            // Background/border part the QR
                            Center(
                              child: Container(
                                width: computedMaxSize / 1.07,
                                height: computedMaxSize / 1.07,
                                child: SvgPicture.asset('legacy_assets/QR.svg'),
                              ),
                            ),
                            // Actual QR part of the QR
                            Center(
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(computedMaxSize / 51),
                                height: computedMaxSize / 1.53,
                                width: computedMaxSize / 1.53,
                                // child: widget.qrWidget,
                                child: this.qrWidget,
                              ),
                            ),
                            // Outer ring
                            Center(
                              child: Container(
                                width: (StateContainer.of(context).curTheme is IndiumTheme) ? computedMaxSize / 1.05 : computedMaxSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: StateContainer.of(context).curTheme.primary!, width: computedMaxSize / 90),
                                ),
                              ),
                            ),
                            // Logo Background White
                            Center(
                              child: Container(
                                width: computedMaxSize / 5.5,
                                height: computedMaxSize / 5.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Logo Background Primary
                            Center(
                              child: Container(
                                width: computedMaxSize / 6.5,
                                height: computedMaxSize / 6.5,
                                decoration: BoxDecoration(
                                  color: /*StateContainer.of(context).curTheme.primary*/ Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                height: computedMaxSize / 8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image(image: AssetImage("assets/logo-square.png")),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

                //A column with Copy Address and Share Address buttons
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        AppButton.buildAppButton(
                            context,
                            // Copy Address Button
                            _addressCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                            _addressCopied ? AppLocalization.of(context)!.addressCopied : AppLocalization.of(context)!.copyAddress,
                            Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                          Clipboard.setData(new ClipboardData(text: StateContainer.of(context).wallet!.address));
                          setState(() {
                            // Set copied style
                            _addressCopied = true;
                          });
                          if (_addressCopiedTimer != null) {
                            _addressCopiedTimer!.cancel();
                          }
                          _addressCopiedTimer = new Timer(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              setState(() {
                                _addressCopied = false;
                              });
                            }
                          });
                        }),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        AppButton.buildAppButton(
                            context,
                            // Share Address Button
                            AppButtonType.PRIMARY_OUTLINE,
                            AppLocalization.of(context)!.addressShare,
                            Dimens.BUTTON_BOTTOM_DIMENS,
                            disabled: _showShareCard, onPressed: () {
                          String receiveCardFileName = "share_${StateContainer.of(context).wallet!.address}.png";
                          getApplicationDocumentsDirectory().then((directory) {
                            String filePath = "${directory.path}/$receiveCardFileName";
                            File f = File(filePath);
                            setState(() {
                              _showShareCard = true;
                            });
                            Future.delayed(new Duration(milliseconds: 50), () {
                              if (_showShareCard!) {
                                _capturePng().then((byteData) {
                                  if (byteData != null) {
                                    f.writeAsBytes(byteData).then((file) {
                                      UIUtil.cancelLockEvent();
                                      Share.shareFiles([filePath], text: StateContainer.of(context).wallet!.address);
                                    });
                                  } else {
                                    // TODO - show a something went wrong message
                                  }
                                  setState(() {
                                    _showShareCard = false;
                                  });
                                });
                              }
                            });
                          });
                        }),
                      ],
                    ),
                    // Row(
                    //   children: <Widget>[
                    //     AppButton.buildAppButton(
                    //         context,
                    //         // Share Address Button
                    //         AppButtonType.PRIMARY_OUTLINE,
                    //         AppLocalization.of(context).requestPayment,
                    //         Dimens.BUTTON_BOTTOM_DIMENS,
                    //         disabled: _showShareCard, onPressed: () {
                    //       // do nothing
                    //       // if (request == null) {
                    //       // return;
                    //       // }
                    //       // Sheets.showAppHeightEightSheet(context: context, widget: request);
                    //       // Remove any other screens from stack
                    //       Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));

                    //       // Go to send with address
                    //       Sheets.showAppHeightNineSheet(context: context, widget: RequestSheet());
                    //     }),
                    //   ],
                    // ),
                  ],
                ),
              ],
            )));
  }

  String _convertLocalCurrencyToCrypto() {
    String convertedAmt = _sendAmountController!.text.replaceAll(",", ".");
    convertedAmt = NumberUtil.sanitizeNumber(convertedAmt);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueLocal = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(StateContainer.of(context).wallet!.localCurrencyConversion!);
    return NumberUtil.truncateDecimal((valueLocal / conversion).toDecimal()).toString();
  }

  String _convertCryptoToLocalCurrency() {
    String convertedAmt = NumberUtil.sanitizeNumber(_sendAmountController!.text, maxDecimalDigits: 2);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueCrypto = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(StateContainer.of(context).wallet!.localCurrencyConversion!);
    convertedAmt = NumberUtil.truncateDecimal(valueCrypto * conversion, digits: 2).toString();
    convertedAmt = convertedAmt.replaceAll(".", _localCurrencyFormat!.symbols.DECIMAL_SEP);
    convertedAmt = _localCurrencyFormat!.currencySymbol + convertedAmt;
    return convertedAmt;
  }

  void toggleLocalCurrency() {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
    // this way you can tap button and tap back and not end up with X.9993451 NANO
    if (_localCurrencyMode) {
      // Switching to crypto-mode
      String cryptoAmountStr;
      // Check out previous state
      if (_sendAmountController!.text == _lastLocalCurrencyAmount) {
        cryptoAmountStr = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = _sendAmountController!.text;
        _lastCryptoAmount = _convertLocalCurrencyToCrypto();
        cryptoAmountStr = _lastCryptoAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _sendAmountController!.text = cryptoAmountStr;
        _sendAmountController!.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (_sendAmountController!.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
      } else {
        _lastCryptoAmount = _sendAmountController!.text;
        _lastLocalCurrencyAmount = _convertCryptoToLocalCurrency();
        localAmountStr = _lastLocalCurrencyAmount;
      }
      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _sendAmountController!.text = localAmountStr;
        _sendAmountController!.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
      });
    }
  }

  void redrawQrCode() {
    String? raw;
    if (_localCurrencyMode) {
      _lastLocalCurrencyAmount = _sendAmountController!.text;
      _lastCryptoAmount = _convertLocalCurrencyToCrypto();
      if (_lastCryptoAmount.isNotEmpty) {
        raw = NumberUtil.getAmountAsRaw(_lastCryptoAmount);
      }
    } else {
      raw = _sendAmountController!.text.length > 0 ? NumberUtil.getAmountAsRaw(_sendAmountController!.text) : '';
    }
    this.paintQrCode(address: widget.address, amount: raw);
  }

  void paintQrCode({String? address, String? amount}) {

    late String data;
    if (isNotEmpty(amount)) {
      data = "nano:" + address! + '?amount:' + amount!;
    } else {
      data = "nano:" + address!;
    }

    QrPainter painter = QrPainter(
      data: data,
      version: 9,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    painter.toImageData(MediaQuery.of(context).size.width).then((byteData) {
      setState(() {
        this.qrWidget = Container(width: MediaQuery.of(context).size.width / 2.675, child: Image.memory(byteData!.buffer.asUint8List()));
      });
    });
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
                      decimalSeparator: _localCurrencyFormat!.symbols.DECIMAL_SEP, commaSeparator: _localCurrencyFormat!.symbols.GROUP_SEP, maxDecimalDigits: 2)
                  : CurrencyFormatter(maxDecimalDigits: NumberUtil.maxDecimalDigits),
              LocalCurrencyFormatter(active: _localCurrencyMode, currencyFormat: _localCurrencyFormat)
            ]
          : [LengthLimitingTextInputFormatter(13)],
      onChanged: (text) {
        if (_localCurrencyMode == false && !text.contains(".") && text.isNotEmpty && text.length > 1) {
          // if the amount is larger than 133248297 set it to that number:
          if (BigInt.parse(text) > BigInt.parse("133248297")) {
            setState(() {
              // _sendAmountController.text = "133248297";
              // prevent the user from entering more than 13324829
              _sendAmountController!.text = _sendAmountController!.text.substring(0, _sendAmountController!.text.length - 1);
              _sendAmountController!.selection = TextSelection.fromPosition(TextPosition(offset: _sendAmountController!.text.length));
            });
          } else if (text == "133248297") {
            setState(() {
              // easter egg!
              _sendAmountController!.text = "TODO: Easter Egg Here!";
              _sendAmountController!.selection = TextSelection.fromPosition(TextPosition(offset: _sendAmountController!.text.length));
            });
          }
        }
        // Always reset the error message to be less annoying
        setState(() {
          _amountValidationText = "";
          // Reset the raw amount
          _rawAmount = null;
        });

        this.redrawQrCode();
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _amountHint == null ? "" : AppLocalization.of(context)!.enterAmount,
      prefixButton: _rawAmount == null
          ? TextFieldButton(
              icon: AppIcons.swapcurrency,
              onPressed: () {
                toggleLocalCurrency();
              },
            )
          : null,
      fadeSuffixOnCondition: true,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (text) {
        FocusScope.of(context).unfocus();
        // if (!Address(_sendAddressController.text).isValid()) {
        //   FocusScope.of(context).requestFocus(_sendAddressFocusNode);
        // }
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

}
