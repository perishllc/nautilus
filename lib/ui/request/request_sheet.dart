import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as Math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/themes.dart';
import 'package:nautilus_wallet_flutter/ui/request/request_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/request/request_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/receive/share_card.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/model/db/contact.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';

class RequestSheet extends StatefulWidget {
  final Widget qrWidget;

  // if this gets used in the future, make sure to implement: localCurrency so that the currency switcher doesn't crash
  RequestSheet({this.qrWidget}) : super();

  _RequestSheetStateState createState() => _RequestSheetStateState();
}

class _RequestSheetStateState extends State<RequestSheet> {
  FocusNode _requestAddressFocusNode;
  TextEditingController _requestAddressController;
  FocusNode _requestAmountFocusNode;
  TextEditingController _requestAmountController;

  // States
  AddressStyle _requestAddressStyle;
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

  GlobalKey shareCardKey;
  ByteData shareImageData;

  // Address copied items
  // Current state references
  bool _showShareCard;
  bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  Future<Uint8List> _capturePng() async {
    if (shareCardKey != null && shareCardKey.currentContext != null) {
      RenderRepaintBoundary boundary = shareCardKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData.buffer.asUint8List();
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _requestAmountFocusNode = FocusNode();
    _requestAddressFocusNode = FocusNode();
    _requestAmountController = TextEditingController();
    _requestAddressController = TextEditingController();
    _requestAddressStyle = AddressStyle.TEXT60;
    _users = List();
    // quickSendAmount = widget.quickSendAmount;
    this.animationOpen = false;
    // if (widget.contact != null) {
    //   // Setup initial state for contact pre-filled
    //   _sendAddressController.text = widget.contact.name;
    //   _isUser = true;
    //   _showContactButton = false;
    //   _pasteButtonVisible = false;
    //   _requestAddressStyle = AddressStyle.PRIMARY;
    // } else if (widget.address != null) {
    //   // Setup initial state with prefilled address
    //   _requestAddressController.text = widget.address;
    //   _showContactButton = false;
    //   _pasteButtonVisible = false;
    //   _requestAddressStyle = AddressStyle.TEXT90;
    //   _addressValidAndUnfocused = true;
    // }
    // On amount focus change
    _requestAmountFocusNode.addListener(() {
      if (_requestAmountFocusNode.hasFocus) {
        if (_rawAmount != null) {
          setState(() {
            _requestAmountController.text = NumberUtil.getRawAsUsableString(_rawAmount).replaceAll(",", "");
            _rawAmount = null;
          });
        }
        if (quickSendAmount != null) {
          _requestAmountController.text = "";
          setState(() {
            quickSendAmount = null;
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
    // On address focus change
    _requestAddressFocusNode.addListener(() {
      if (_requestAddressFocusNode.hasFocus) {
        setState(() {
          _addressHint = null;
          _addressValidAndUnfocused = false;
        });
        _requestAddressController.selection = TextSelection.fromPosition(TextPosition(offset: _requestAddressController.text.length));
        if (_requestAddressController.text.length > 0 && !_requestAddressController.text.startsWith("nano_")) {
          if (_requestAddressController.text.startsWith("@")) {
            sl.get<DBHelper>().getUsersWithNameLike(_requestAddressController.text.substring(1)).then((userList) {
              setState(() {
                _users = userList;
              });
            });
          } else if (_requestAddressController.text.startsWith("★")) {
            sl.get<DBHelper>().getContactsWithNameLike(_requestAddressController.text.substring(1)).then((userList) {
              setState(() {
                _users = userList;
              });
            });
          }
        }

        if (_requestAddressController.text.length == 0) {
          setState(() {
            _users = [];
          });
        }
      } else {
        setState(() {
          _addressHint = "";
          _users = [];
          if (Address(_requestAddressController.text).isValid()) {
            _addressValidAndUnfocused = true;
          }
        });
        if (_requestAddressController.text.trim() == "@" || _requestAddressController.text.trim() == "★") {
          _requestAddressController.text = "";
          setState(() {
            _showContactButton = true;
          });
        }
      }
    });
    // Set initial state of copy button
    _addressCopied = false;
    // Create our SVG-heavy things in the constructor because they are slower operations
    // Share card initialization
    shareCardKey = GlobalKey();
    _showShareCard = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
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
                          ? Text("@" + StateContainer.of(context).wallet?.username,
                              style: TextStyle(
                                fontFamily: "OverpassMono",
                                fontWeight: FontWeight.w100,
                                fontSize: 24.0,
                                color: StateContainer.of(context).curTheme.text60,
                              ))
                          : UIUtil.threeLineAddressText(context, StateContainer.of(context).wallet.address, type: ThreeLineAddressTextType.PRIMARY60),
                    ),
                    // (StateContainer.of(context).wallet?.username != null)
                    //     ? Container(
                    //         margin: EdgeInsets.only(top: 15.0),
                    //         child: Text("@" + StateContainer.of(context).wallet?.username,
                    //             style: TextStyle(
                    //               fontFamily: "OverpassMono",
                    //               fontWeight: FontWeight.w100,
                    //               fontSize: 24.0,
                    //               color: StateContainer.of(context).curTheme.text60,
                    //             )))
                    //     : null,
                    // Container(
                    //   margin: EdgeInsets.only(top: 15.0),
                    //   child: UIUtil.threeLineAddressText(context, StateContainer.of(context).wallet.address, type: ThreeLineAddressTextType.PRIMARY60),
                    // ),
                  ],
                ),
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 60,
                ),
              ],
            ),

            // account / wallet name:
            Container(
              margin: EdgeInsets.only(top: 10.0, left: 30, right: 30),
              child: Container(
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: StateContainer.of(context).selectedAccount.name,
                        style: TextStyle(
                          color: StateContainer.of(context).curTheme.text60,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'NunitoSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Address Text
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 30),
            //   child: OneOrThreeLineAddressText(address: StateContainer.of(context).wallet.address, type: AddressTextType.PRIMARY60),
            // ),
            // A main container that holds everything
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 5, bottom: 5),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        // Clear focus of our fields when tapped in this empty space
                        _requestAddressFocusNode.unfocus();
                        _requestAmountFocusNode.unfocus();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: SizedBox.expand(),
                        constraints: BoxConstraints.expand(),
                      ),
                    ),
                    // A column for Enter Amount, Enter Address, Error containers and the pop up list
                    Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            // Column for Balance Text, Enter Amount container + Enter Amount Error container
                            Column(
                              children: <Widget>[
                                // Balance Text
                                FutureBuilder(
                                  future: sl.get<SharedPrefsUtil>().getPriceConversion(),
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (snapshot.hasData && snapshot.data != null && snapshot.data != PriceConversion.HIDDEN) {
                                      return Container(
                                        child: RichText(
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
                                                  fontFamily: 'NunitoSans',
                                                ),
                                              ),
                                              (StateContainer.of(context).nyanoMode)
                                                  ? TextSpan(
                                                      text: "y",
                                                      style: TextStyle(
                                                        color: StateContainer.of(context).curTheme.primary60,
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w700,
                                                        fontFamily: 'NunitoSans',
                                                        decoration: TextDecoration.lineThrough,
                                                      ),
                                                    )
                                                  : TextSpan(),
                                              TextSpan(
                                                text: _localCurrencyMode
                                                    ? StateContainer.of(context).wallet.getLocalCurrencyPrice(StateContainer.of(context).curCurrency,
                                                        locale: StateContainer.of(context).currencyLocale)
                                                    : getCurrencySymbol(context) + StateContainer.of(context).wallet.getAccountBalanceDisplay(context),
                                                style: TextStyle(
                                                  color: StateContainer.of(context).curTheme.primary60,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'NunitoSans',
                                                ),
                                              ),
                                              TextSpan(
                                                text: ")",
                                                style: TextStyle(
                                                  color: StateContainer.of(context).curTheme.primary60,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w100,
                                                  fontFamily: 'NunitoSans',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      child: Text(
                                        "*******",
                                        style: TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w100,
                                          fontFamily: 'NunitoSans',
                                        ),
                                      ),
                                    );
                                  },
                                ),
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

                            // Column for Enter Address container + Enter Address Error container
                            Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                                        alignment: Alignment.bottomCenter,
                                        constraints: BoxConstraints(maxHeight: 174, minHeight: 0),
                                        // ********************************************* //
                                        // ********* The pop-up Contacts List ********* //
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(25),
                                              color: StateContainer.of(context).curTheme.backgroundDarkest,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              margin: EdgeInsets.only(bottom: 50),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.only(bottom: 0, top: 0),
                                                itemCount: _users.length,
                                                itemBuilder: (context, index) {
                                                  return _buildUserItem(_users[index]);
                                                },
                                              ), // ********* The pop-up Contacts List End ********* //
                                              // ************************************************** //
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ******* Enter Address Container ******* //
                                      getEnterAddressContainer(),
                                      // ******* Enter Address Container End ******* //
                                    ],
                                  ),
                                ),

                                // ******* Enter Address Error Container ******* //
                                Container(
                                  alignment: AlignmentDirectional(0, 0),
                                  margin: EdgeInsets.only(top: 3),
                                  child: Text(_addressValidationText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: 'NunitoSans',
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                // ******* Enter Address Error Container End ******* //
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //A column with Request Payment and Create QR code buttons
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Share Address Button
                        AppButtonType.PRIMARY,
                        AppLocalization.of(context).requestPayment,
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        disabled: _showShareCard, onPressed: () {
                      bool validRequest = _validateRequest();
                      // verifyies the input is a user in the db
                      if (!_requestAddressController.text.startsWith("nano_") && validRequest) {
                        // Need to make sure its a valid contact or user
                        sl.get<DBHelper>().getUserOrContactWithName(_requestAddressController.text.substring(1)).then((user) {
                          if (user == null) {
                            setState(() {
                              if (_requestAddressController.text.startsWith("★")) {
                                _addressValidationText = AppLocalization.of(context).favoriteInvalid;
                              } else if (_requestAddressController.text.startsWith("@")) {
                                _addressValidationText = AppLocalization.of(context).usernameInvalid;
                              }
                            });
                          } else {
                            Sheets.showAppHeightNineSheet(
                                context: context,
                                widget: RequestConfirmSheet(
                                    amountRaw: _localCurrencyMode
                                        ? NumberUtil.getAmountAsRaw(_convertLocalCurrencyToCrypto())
                                        : _rawAmount == null
                                            ? (StateContainer.of(context).nyanoMode)
                                                ? NumberUtil.getNyanoAmountAsRaw(_requestAmountController.text)
                                                : NumberUtil.getAmountAsRaw(_requestAmountController.text)
                                            : _rawAmount,
                                    destination: user.address,
                                    contactName: (user is User)
                                        ? user.username
                                        : (user is Contact)
                                            ? user.name
                                            : null,
                                    localCurrency: _localCurrencyMode ? _requestAmountController.text : null));
                          }
                        });
                      } else if (validRequest) {
                        Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: RequestConfirmSheet(
                                amountRaw: _localCurrencyMode
                                    ? NumberUtil.getAmountAsRaw(_convertLocalCurrencyToCrypto())
                                    : _rawAmount == null
                                        ? (StateContainer.of(context).curTheme is NyanTheme)
                                            ? NumberUtil.getNyanoAmountAsRaw(_requestAmountController.text)
                                            : NumberUtil.getAmountAsRaw(_requestAmountController.text)
                                        : _rawAmount,
                                destination: _requestAddressController.text,
                                localCurrency: _localCurrencyMode ? _requestAmountController.text : null));
                      }
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Share Address Button
                        AppButtonType.PRIMARY_OUTLINE,
                        AppLocalization.of(context).createQR,
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        disabled: _showShareCard, onPressed: () {
                      // do nothing
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  void _showSendingAnimation(BuildContext context) {
    animationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.SEND, StateContainer.of(context).curTheme.animationOverlayStrong, StateContainer.of(context).curTheme.animationOverlayMedium,
        onPoppedCallback: () => animationOpen = false));
  }

  // Future<void> _doRequest() async {
  //   try {
  //     _showSendingAnimation(context);
  //     sl.get<AccountService>().requestPayment("nano_3bp14yai9rb16to6mk7m5kt4x8rsia6zmrak8phuo734t5mdf15odns66joo", "1000000000000000000000000");

  //     // // TODO:
  //     // ProcessResponse resp = await sl.get<AccountService>().requestSend(
  //     //     StateContainer.of(context).wallet.representative,
  //     //     StateContainer.of(context).wallet.frontier,
  //     //     widget.amountRaw,
  //     //     destinationAltered,
  //     //     StateContainer.of(context).wallet.address,
  //     //     NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount.index),
  //     //     max: widget.maxSend);
  //     // if (widget.manta != null) {
  //     //   widget.manta.sendPayment(transactionHash: resp.hash, cryptoCurrency: "NANO");
  //     // }
  //     // StateContainer.of(context).wallet.frontier = resp.hash;
  //     // StateContainer.of(context).wallet.accountBalance += BigInt.parse(widget.amountRaw);
  //     // // Show complete
  //     // // Contact contact = await sl.get<DBHelper>().getContactWithAddress(widget.destination);
  //     // // String contactName = contact == null ? null : contact.name;
  //     // Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  //     // StateContainer.of(context).requestUpdate();
  //     // // Sheets.showAppHeightNineSheet(context: context, closeOnTap: true, removeUntilHome: true, widget: RequestCompleteSheet());
  //   } catch (e) {
  //     // Send failed
  //     if (animationOpen) {
  //       Navigator.of(context).pop();
  //     }
  //     UIUtil.showSnackbar(AppLocalization.of(context).sendError, context);
  //     Navigator.of(context).pop();
  //   }
  // }

  String _convertLocalCurrencyToCrypto() {
    String convertedAmt = _requestAmountController.text.replaceAll(",", ".");
    convertedAmt = NumberUtil.sanitizeNumber(convertedAmt);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueLocal = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(StateContainer.of(context).wallet.localCurrencyConversion);
    return NumberUtil.truncateDecimal(valueLocal / conversion).toString();
  }

  String _convertCryptoToLocalCurrency() {
    String convertedAmt = NumberUtil.sanitizeNumber(_requestAmountController.text, maxDecimalDigits: 2);
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

  void toggleLocalCurrency() {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
    // this way you can tap button and tap back and not end up with X.9993451 NANO
    if (_localCurrencyMode) {
      // Switching to crypto-mode
      String cryptoAmountStr;
      // Check out previous state
      if (_requestAmountController.text == _lastLocalCurrencyAmount) {
        cryptoAmountStr = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = _requestAmountController.text;
        _lastCryptoAmount = _convertLocalCurrencyToCrypto();
        cryptoAmountStr = _lastCryptoAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _requestAmountController.text = cryptoAmountStr;
        _requestAmountController.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (_requestAmountController.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
      } else {
        _lastCryptoAmount = _requestAmountController.text;
        _lastLocalCurrencyAmount = _convertCryptoToLocalCurrency();
        localAmountStr = _lastLocalCurrencyAmount;
      }
      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _requestAmountController.text = localAmountStr;
        _requestAmountController.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
      });
    }
  }

  // Build contact items for the list
  Widget _buildUserItem(dynamic user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 42,
          width: double.infinity - 5,
          child: FlatButton(
            onPressed: () {
              _requestAddressController.text = (user is User) ? ("@" + user.username) : ("★" + user.name);
              _requestAddressFocusNode.unfocus();
              setState(() {
                _isUser = true;
                _showContactButton = false;
                _pasteButtonVisible = false;
                _requestAddressStyle = AddressStyle.PRIMARY;
              });
            },
            child: Text((user is User) ? user.username : user.name, textAlign: TextAlign.center, style: AppStyles.textStyleAddressPrimary(context)),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25),
          height: 1,
          color: StateContainer.of(context).curTheme.text03,
        ),
      ],
    );
  }

  /// Validate form data to see if valid
  /// @returns true if valid, false otherwise
  bool _validateRequest() {
    bool isValid = true;
    _requestAmountFocusNode.unfocus();
    _requestAddressFocusNode.unfocus();
    // Validate amount
    if (_requestAmountController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _amountValidationText = AppLocalization.of(context).amountMissing;
      });
    } else {
      String bananoAmount = _localCurrencyMode
          ? _convertLocalCurrencyToCrypto()
          : _rawAmount == null
              ? _requestAmountController.text
              : NumberUtil.getRawAsUsableString(_rawAmount);
      BigInt balanceRaw = StateContainer.of(context).wallet.accountBalance;
      BigInt sendAmount = BigInt.tryParse(getThemeAwareAmountAsRaw(context, bananoAmount));
      if (sendAmount == null || sendAmount == BigInt.zero) {
        isValid = false;
        setState(() {
          _amountValidationText = AppLocalization.of(context).amountMissing;
        });
      } else if (sendAmount > balanceRaw) {
        // this is valid for a request
        // isValid = false;
        // setState(() {
        //   _amountValidationText = AppLocalization.of(context).insufficientBalance;
        // });
      }
    }
    // Validate address
    bool isUser = _requestAddressController.text.startsWith("@");
    bool isFavorite = _requestAddressController.text.startsWith("★");
    bool isNano = _requestAddressController.text.startsWith("nano_");
    if (_requestAddressController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = AppLocalization.of(context).addressMising;

        _pasteButtonVisible = true;
      });
    } else if (!isFavorite && !isUser && !Address(_requestAddressController.text).isValid()) {
      isValid = false;
      setState(() {
        _addressValidationText = AppLocalization.of(context).invalidAddress;
        _pasteButtonVisible = true;
      });
    } else if (!isUser && !isFavorite) {
      setState(() {
        _addressValidationText = "";
        _pasteButtonVisible = false;
      });
      _requestAddressFocusNode.unfocus();
    }
    return isValid;
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  getEnterAmountContainer() {
    return AppTextField(
      focusNode: _requestAmountFocusNode,
      controller: _requestAmountController,
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
      fadeSuffixOnCondition: true,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (text) {
        FocusScope.of(context).unfocus();
        if (!Address(_requestAddressController.text).isValid()) {
          FocusScope.of(context).requestFocus(_requestAddressFocusNode);
        }
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Address Container Method ************//
  //*******************************************************//
  getEnterAddressContainer() {
    return AppTextField(
        topMargin: 124,
        padding: _addressValidAndUnfocused ? EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
        textAlign: _isUser && false ? TextAlign.start : TextAlign.center,
        focusNode: _requestAddressFocusNode,
        controller: _requestAddressController,
        cursorColor: StateContainer.of(context).curTheme.primary,
        inputFormatters: [
          _isUser ? LengthLimitingTextInputFormatter(20) : LengthLimitingTextInputFormatter(65),
        ],
        textInputAction: TextInputAction.done,
        maxLines: null,
        autocorrect: false,
        hintText: _addressHint == null ? "" : AppLocalization.of(context).enterAddress,
        prefixButton: TextFieldButton(
          icon: AppIcons.star,
          onPressed: () {
            if (_showContactButton && _users.length == 0) {
              // Show menu
              FocusScope.of(context).requestFocus(_requestAddressFocusNode);
              if (_requestAddressController.text.length == 0) {
                _requestAddressController.text = "★";
                _requestAddressController.selection = TextSelection.fromPosition(TextPosition(offset: _requestAddressController.text.length));
              }
              sl.get<DBHelper>().getContacts().then((userList) {
                setState(() {
                  _users = userList;
                });
              });
            }
          },
        ),
        fadePrefixOnCondition: true,
        prefixShowFirstCondition: _showContactButton && _users.length == 0,
        suffixButton: TextFieldButton(
          icon: AppIcons.paste,
          onPressed: () {
            if (!_pasteButtonVisible) {
              return;
            }
            Clipboard.getData("text/plain").then((ClipboardData data) {
              if (data == null || data.text == null) {
                return;
              }
              Address address = Address(data.text);
              if (address.isValid()) {
                sl.get<DBHelper>().getUserWithAddress(address.address).then((user) {
                  if (user == null) {
                    setState(() {
                      _isUser = false;
                      _addressValidationText = "";
                      _requestAddressStyle = AddressStyle.TEXT90;
                      _pasteButtonVisible = false;
                      _showContactButton = false;
                    });
                    _requestAddressController.text = address.address;
                    _requestAddressFocusNode.unfocus();
                    setState(() {
                      _addressValidAndUnfocused = true;
                    });
                  } else {
                    // Is a user
                    setState(() {
                      _isUser = true;
                      _addressValidationText = "";
                      _requestAddressStyle = AddressStyle.PRIMARY;
                      _pasteButtonVisible = false;
                      _showContactButton = false;
                    });
                    _requestAddressController.text = "@" + user.username;
                  }
                });
              }
            });
          },
        ),
        fadeSuffixOnCondition: true,
        suffixShowFirstCondition: _pasteButtonVisible,
        style: _requestAddressStyle == AddressStyle.TEXT60
            ? AppStyles.textStyleAddressText60(context)
            : _requestAddressStyle == AddressStyle.TEXT90
                ? AppStyles.textStyleAddressText90(context)
                : AppStyles.textStyleAddressPrimary(context),
        onChanged: (text) {
          bool isUser = text.startsWith("@");
          bool isFavorite = text.startsWith("★");
          bool isNano = text.startsWith("nano_");

          // prevent spaces:
          if (text.contains(" ")) {
            text = text.replaceAll(" ", "");
            _requestAddressController.text = text;
            _requestAddressController.selection = TextSelection.fromPosition(TextPosition(offset: _requestAddressController.text.length));
          }

          if (text.length > 0) {
            setState(() {
              _showContactButton = false;
            });
          } else {
            setState(() {
              _showContactButton = true;
            });
          }
          // add the @ back in:
          if (text.length > 0 && !isUser && !isNano && !isFavorite) {
            // add @ to the beginning of the string:
            _requestAddressController.text = "@" + text;
            _requestAddressController.selection = TextSelection.fromPosition(TextPosition(offset: _requestAddressController.text.length));
            isUser = true;
          }

          if (text.length > 0 && text.startsWith("@nano_")) {
            setState(() {
              // remove the @ from the beginning of the string:
              _requestAddressController.text = text.replaceFirst("@nano_", "nano_");
              _requestAddressController.selection = TextSelection.fromPosition(TextPosition(offset: _requestAddressController.text.length));
              isUser = false;
            });
          }

          // check if it's a real nano address:
          // bool isUser = !text.startsWith("nano_") && !text.startsWith("★");
          if (text.length == 0) {
            setState(() {
              _isUser = false;
              _users = [];
            });
          } else if (isUser) {
            setState(() {
              _isUser = true;
            });
            sl.get<DBHelper>().getUserSuggestionsWithNameLike(text.substring(1)).then((matchedList) {
              setState(() {
                _users = matchedList;
              });
            });
          } else if (isFavorite) {
            setState(() {
              _isUser = true;
            });
            sl.get<DBHelper>().getContactsWithNameLike(text.substring(1)).then((matchedList) {
              setState(() {
                _users = matchedList;
              });
            });
          } else {
            setState(() {
              _isUser = false;
              _users = [];
            });
          }
          // Always reset the error message to be less annoying
          setState(() {
            _addressValidationText = "";
          });
          if (!isUser && Address(text).isValid()) {
            _requestAddressFocusNode.unfocus();
            setState(() {
              _requestAddressStyle = AddressStyle.TEXT90;
              _addressValidationText = "";
              _pasteButtonVisible = false;
            });
          } else if (!isUser) {
            setState(() {
              _requestAddressStyle = AddressStyle.TEXT60;
              _pasteButtonVisible = true;
            });
          } else {
            sl.get<DBHelper>().getUserWithName(text).then((user) {
              if (user == null) {
                setState(() {
                  _requestAddressStyle = AddressStyle.TEXT60;
                });
              } else {
                setState(() {
                  _pasteButtonVisible = false;
                  _requestAddressStyle = AddressStyle.PRIMARY;
                });
              }
            });
          }
        },
        overrideTextFieldWidget: _addressValidAndUnfocused
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _addressValidAndUnfocused = false;
                  });
                  Future.delayed(Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(_requestAddressFocusNode);
                  });
                },
                child: UIUtil.threeLineAddressText(context, _requestAddressController.text))
            : null);
  } //************ Enter Address Container Method End ************//
  //*************************************************************//
}
