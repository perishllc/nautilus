import 'dart:async';
import 'dart:io';
import 'dart:math' as Math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/ui/receive/share_card.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:quiver/strings.dart';
import 'package:share_plus/share_plus.dart';

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
      return const TextEditingValue().copyWith(text: min!.toStringAsFixed(2));
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
  bool _showShareCard = false;
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
      final RenderRepaintBoundary boundary = shareCardKey!.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      final ByteData byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;
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
            _sendAmountController!.text = getRawAsThemeAwareAmount(context, _rawAmount);
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
                    const SizedBox(
                      width: 60,
                      height: 60,
                    ),
                    //Container for the address text and sheet handle
                    Column(
                      children: <Widget>[
                        // Sheet handle
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 5,
                          width: MediaQuery.of(context).size.width * 0.15,
                          decoration: BoxDecoration(
                            color: StateContainer.of(context).curTheme.text20,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        // show napi username if available:
                        Container(
                          margin: (StateContainer.of(context).wallet?.username != null) ? const EdgeInsets.only(top: 35.0) : const EdgeInsets.only(top: 15.0),
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
                    const SizedBox(
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
                    // ******* Enter Amount Error Container End ******* //
                  ],
                ),
                // QR which takes all the available space left from the buttons & address text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 20, bottom: 28, start: 20, end: 20),
                    child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                      final double availableWidth = constraints.maxWidth;
                      final double availableHeight =
                          (StateContainer.of(context).wallet?.username != null) ? (constraints.maxHeight - 70) : constraints.maxHeight;
                      const double widthDivideFactor = 1.3;
                      final double computedMaxSize = Math.min(availableWidth / widthDivideFactor, availableHeight);
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            if (_showShareCard)
                              Container(
                                alignment: AlignmentDirectional.center,
                                child: AppShareCard(
                                  shareCardKey,
                                  Center(
                                    child: Transform.translate(
                                      offset: Offset.zero,
                                      child: ClipOval(
                                        child: Container(
                                          color: Colors.white,
                                          height: computedMaxSize,
                                          width: computedMaxSize,
                                          child: qrWidget,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Image(image: AssetImage("assets/logo.png")),
                                ),
                              ),
                            // This is for hiding the share card
                            Center(
                              child: Container(
                                width: 260,
                                height: 150,
                                color: StateContainer.of(context).curTheme.backgroundDark,
                              ),
                            ),
                            // Background/border part the QR
                            // Center(
                            //   child: SizedBox(
                            //     width: computedMaxSize / 1.07,
                            //     height: computedMaxSize / 1.07,
                            //     child: SvgPicture.asset('legacy_assets/QR.svg'),
                            //   ),
                            // ),

                            // Background/border part the QR:
                            Center(
                              child: ClipOval(
                                child: Container(
                                  color: Colors.white,
                                  height: computedMaxSize,
                                  width: computedMaxSize,
                                  child: qrWidget,
                                ),
                              ),
                            ),

                            // Actual QR part of the QR
                            Center(
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(computedMaxSize / 51),
                                height: computedMaxSize / 1.53,
                                width: computedMaxSize / 1.53,
                                child: qrWidget,
                              ),
                            ),

                            // Outer ring
                            Center(
                              child: Container(
                                width: computedMaxSize,
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
                                decoration: const BoxDecoration(
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
                                decoration: const BoxDecoration(
                                  color: /*StateContainer.of(context).curTheme.primary*/ Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Center(
                              child: SizedBox(
                                height: computedMaxSize / 8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: const Image(image: AssetImage("assets/logo.png")),
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
                          Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address));
                          setState(() {
                            // Set copied style
                            _addressCopied = true;
                          });
                          if (_addressCopiedTimer != null) {
                            _addressCopiedTimer!.cancel();
                          }
                          _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
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
                          final String receiveCardFileName = "share_${StateContainer.of(context).wallet!.address}.png";
                          getApplicationDocumentsDirectory().then((Directory directory) {
                            final String filePath = "${directory.path}/$receiveCardFileName";
                            final File f = File(filePath);
                            setState(() {
                              _showShareCard = true;
                            });
                            Future.delayed(const Duration(milliseconds: 50), () {
                              if (_showShareCard) {
                                _capturePng().then((Uint8List? byteData) {
                                  if (byteData != null) {
                                    f.writeAsBytes(byteData).then((File file) {
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
    String convertedAmt =
        _sendAmountController!.text.replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, "").replaceAll(_localCurrencyFormat!.symbols.DECIMAL_SEP, ".");
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
      Future.delayed(const Duration(milliseconds: 50), () {
        _sendAmountController!.text = cryptoAmountStr;
        _sendAmountController!.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (_sendAmountController!.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
        if (!_lastLocalCurrencyAmount.startsWith(_localCurrencyFormat!.currencySymbol)) {
          _lastLocalCurrencyAmount = _localCurrencyFormat!.currencySymbol + _lastLocalCurrencyAmount;
        }
      } else {
        _lastCryptoAmount = _sendAmountController!.text;
        _lastLocalCurrencyAmount = _convertCryptoToLocalCurrency(_sendAmountController!.text);
        localAmountStr = _lastLocalCurrencyAmount;
      }
      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
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
      raw = _sendAmountController!.text.isNotEmpty
          ? NumberUtil.getAmountAsRaw(
              _sendAmountController!.text.trim().replaceAll(_localCurrencyFormat!.currencySymbol, "").replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, ""))
          : "";
    }
    paintQrCode(address: widget.address, amount: raw);
  }

  Future<void> paintQrCode({String? address, String? amount}) async {
    late String data;
    if (isNotEmpty(amount)) {
      data = "nano:${address!}?amount:${amount!}";
    } else {
      data = "nano:${address!}";
    }
    
    final Widget qr = SizedBox(width: MediaQuery.of(context).size.width / 2.675, child: await UIUtil.getQRImage(context, data));
    setState(() {
      qrWidget = qr;
    });
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  Widget getEnterAmountContainer() {
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
          ? [CurrencyFormatter(currencyFormat: _localCurrencyFormat!), LocalCurrencyFormatter(active: _localCurrencyMode, currencyFormat: _localCurrencyFormat)]
          : [LengthLimitingTextInputFormatter(13)],
      onChanged: (String text) {
        if (_localCurrencyMode == false && !text.contains(".") && text.isNotEmpty && text.length > 1) {
          // if the amount is larger than 133248297 set it to that number:
          if (BigInt.parse(text.replaceAll(_localCurrencyFormat!.currencySymbol, "").replaceAll(_localCurrencyFormat!.symbols.GROUP_SEP, "")) >
              BigInt.parse("133248297")) {
            setState(() {
              // _sendAmountController.text = "133248297";
              // prevent the user from entering more than 13324829
              _sendAmountController!.text = _sendAmountController!.text.substring(0, _sendAmountController!.text.length - 1);
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

        redrawQrCode();
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (String text) {
        FocusScope.of(context).unfocus();
        // if (!Address(_sendAddressController.text).isValid()) {
        //   FocusScope.of(context).requestFocus(_sendAddressFocusNode);
        // }
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

}
