import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/ui/receive/share_card.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/util/numberutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/strings.dart';
import 'package:share_plus/share_plus.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  NumericalRangeFormatter({this.min, this.max});

  final double? min;
  final double? max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min!) {
      return TextEditingValue.empty.copyWith(text: min!.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max! ? oldValue : newValue;
    }
  }
}

class CheckoutSheet extends StatefulWidget {
  const CheckoutSheet({required this.localCurrency, this.address, this.qrWidget, this.amountRaw}) : super();

  final AvailableCurrency localCurrency;
  final Widget? qrWidget;
  final String? address;
  final String? amountRaw;

  @override
  CheckoutSheetState createState() => CheckoutSheetState();
}

class CheckoutSheetState extends State<CheckoutSheet> {
  GlobalKey? shareCardKey;
  ByteData? shareImageData;
  // Address copied items
  // Current state references
  bool _showShareCard = false;
  late bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  FocusNode? _amountFocusNode;
  String? _rawAmount;
  TextEditingController? _amountController;
  late NumberFormat _localCurrencyFormat;
  bool _localCurrencyMode = false;
  String _amountValidationText = "";
  String? _amountHint = "";
  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";

  Widget? qrWidget;

  Future<Uint8List?> _capturePng() async {
    if (shareCardKey != null && shareCardKey!.currentContext != null) {
      final RenderRepaintBoundary? boundary =
          shareCardKey!.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
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

    _amountFocusNode = FocusNode();
    _amountController = TextEditingController();

    if (isNotEmpty(widget.amountRaw) && widget.amountRaw != "0") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _amountController!.text = getRawAsThemeAwareAmount(context, widget.amountRaw);
          redrawQrCode();
        });
      });
    }

    // On amount focus change
    _amountFocusNode!.addListener(() {
      if (_amountFocusNode!.hasFocus) {
        setState(() {
          _amountHint = "";
        });
      } else {
        setState(() {
          _amountHint = Z.of(context).enterAmount;
        });
      }
    });
    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(
        locale: widget.localCurrency.getLocale().toString(), symbol: widget.localCurrency.getCurrencySymbol());

    qrWidget = widget.qrWidget;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
      child: GestureDetector(
        onTap: () {
          // Clear focus of our fields when tapped in this empty space
          _amountFocusNode!.unfocus();
        },
        child: Column(
          children: <Widget>[
            Center(
              child: Handlebars.horizontal(context),
            ),
            // Column for Enter Amount container + Enter Amount Error container WIP
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
            // QR which takes all the available space left from the buttons & address text
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 20, bottom: 28, start: 20, end: 20),
                child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                  final double availableWidth = constraints.maxWidth;
                  final double availableHeight = (StateContainer.of(context).wallet?.username != null)
                      ? (constraints.maxHeight - 70)
                      : constraints.maxHeight;
                  const double widthDivideFactor = 1.3;
                  final double computedMaxSize = math.min(availableWidth / widthDivideFactor, availableHeight);
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
                              border: Border.all(
                                  color: StateContainer.of(context).curTheme.primary!, width: computedMaxSize / 90),
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
                            height: computedMaxSize / 12,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: SvgPicture.asset("assets/logo.svg",
                                  color: StateContainer.of(context).curTheme.primary),
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
                        _addressCopied ? Z.of(context).addressCopied : Z.of(context).copyAddress,
                        Dimens.BUTTON_COMPACT_LEFT_DIMENS, onPressed: () {
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
                    AppButton.buildAppButton(
                        context,
                        // Share Address Button
                        AppButtonType.PRIMARY_OUTLINE,
                        Z.of(context).addressShare,
                        Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
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
              ],
            ),
          ],
        ),
      ),
    );
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
        _lastCryptoAmount =
            convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text);
        cryptoAmountStr = _lastCryptoAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future<void>.delayed(const Duration(milliseconds: 50), () {
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
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        _amountController!.text = localAmountStr;
        _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
      });
    }
  }

  void redrawQrCode() {
    String? raw;
    if (_localCurrencyMode) {
      _lastLocalCurrencyAmount = _amountController!.text;
      _lastCryptoAmount = sanitizedAmount(_localCurrencyFormat,
          convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text));
      if (_lastCryptoAmount.isNotEmpty) {
        raw = NumberUtil.getAmountAsRaw(_lastCryptoAmount);
      }
    } else {
      raw = _amountController!.text.isNotEmpty
          ? NumberUtil.getAmountAsRaw(_amountController!.text
              .trim()
              .replaceAll(_localCurrencyFormat.currencySymbol, "")
              .replaceAll(_localCurrencyFormat.symbols.GROUP_SEP, ""))
          : "";
    }
    paintQrCode(address: widget.address, amount: raw);
  }

  Future<void> paintQrCode({String? address, String? amount}) async {
    late String data;
    if (isNotEmpty(amount)) {
      data = "${NonTranslatable.currencyUriPrefix}:${address!}?amount=${amount!}";
    } else {
      data = "${NonTranslatable.currencyUriPrefix}:${address!}";
    }

    final Widget qr =
        SizedBox(width: MediaQuery.of(context).size.width / 2.675, child: await UIUtil.getQRImage(context, data));
    setState(() {
      qrWidget = qr;
    });
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

        redrawQrCode();
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
      fadeSuffixOnCondition: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (String text) {
        FocusScope.of(context).unfocus();
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

}
