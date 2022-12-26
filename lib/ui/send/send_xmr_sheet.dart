import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/fcm_update_event.dart';
import 'package:wallet_flutter/bus/notification_setting_change_event.dart';
import 'package:wallet_flutter/bus/xmr_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/notification_setting.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:wallet_flutter/ui/send/send_xmr_confirm_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/deviceutil.dart';
import 'package:wallet_flutter/util/numberutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:wallet_flutter/util/user_data_util.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SendXMRSheet extends StatefulWidget {
  const SendXMRSheet({required this.localCurrency, this.user, this.address, this.quickSendAmount}) : super();

  final AvailableCurrency localCurrency;
  final User? user;
  final String? address;
  final String? quickSendAmount;

  @override
  SendXMRSheetState createState() => SendXMRSheetState();
}

enum AddressStyle { TEXT60, TEXT90, PRIMARY }

mixin SendSheetHelpers {
  static String stripPrefixes(String addressText) {
    return addressText.replaceAll("@", "").replaceAll("★", "");
  }
}

class SendXMRSheetState extends State<SendXMRSheet> {
  final Logger log = sl.get<Logger>();

  FocusNode? _addressFocusNode;
  FocusNode? _amountFocusNode;
  FocusNode? _memoFocusNode;
  TextEditingController? _addressController;
  TextEditingController? _amountController;
  TextEditingController? _memoController;

  // States
  AddressStyle? _addressStyle;
  String? _amountHint;
  String? _addressHint;
  String? _memoHint;
  String _amountValidationText = "";
  String _addressValidationText = "";
  String _memoValidationText = "";
  String? quickSendAmount = "";
  late List<User> _users;
  bool? animationOpen;
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

  bool isIpad = false;

  final int _REQUIRED_CONFIRMATION_HEIGHT = 10;

  // Receive card instance
  ReceiveSheet? receive;

  String? _rawAmount;

  @override
  void initState() {
    super.initState();
    _amountFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _memoFocusNode = FocusNode();
    _amountController = TextEditingController();
    _addressController = TextEditingController();
    _memoController = TextEditingController();
    _addressStyle = AddressStyle.TEXT60;
    _users = [];
    quickSendAmount = widget.quickSendAmount;
    animationOpen = false;

    // _amountHint = Z.of(context).enterAmount;
    // _addressHint = Z.of(context).enterUserOrAddress;
    // _memoHint = Z.of(context).enterMemo;

    if (widget.user != null) {
      // Setup initial state for contact pre-filled
      _addressController!.text = widget.user!.getDisplayName()!;
      _isUser = true;
      _showContactButton = false;
      _pasteButtonVisible = false;
      _addressStyle = AddressStyle.PRIMARY;
    } else if (widget.address != null) {
      // Setup initial state with prefilled address
      _addressController!.text = widget.address!;
      _showContactButton = false;
      _pasteButtonVisible = false;
      _addressStyle = AddressStyle.TEXT90;
      _addressValidAndUnfocused = true;
    }
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
    // On address focus change
    _addressFocusNode!.addListener(() async {
      if (_addressFocusNode!.hasFocus) {
        setState(() {
          _addressHint = "";
          _addressValidationText = "";
          _addressValidAndUnfocused = false;
          _pasteButtonVisible = true;
          _addressStyle = AddressStyle.TEXT60;
          if (_addressController!.text.isNotEmpty) {
            _clearButton = true;
          } else {
            _clearButton = false;
          }
        });
        _addressController!.selection =
            TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
        if (_addressController!.text.isNotEmpty &&
            _addressController!.text.length > 1 &&
            !_addressController!.text.startsWith("nano_")) {
          final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);
          if (_addressController!.text != formattedAddress) {
            setState(() {
              _addressController!.text = formattedAddress;
            });
          }
          final List<User> userList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(formattedAddress);
          setState(() {
            _users = userList;
          });
        }

        if (_addressController!.text.isEmpty) {
          setState(() {
            _users = [];
          });
        }
      } else {
        setState(() {
          _addressHint = Z.of(context).enterUserOrAddress;
          _users = [];
          if (Address(_addressController!.text).isValid()) {
            _addressValidAndUnfocused = true;
          }
          if (_addressController!.text.isEmpty) {
            _pasteButtonVisible = true;
          }
        });

        if (SendSheetHelpers.stripPrefixes(_addressController!.text).isEmpty) {
          setState(() {
            _addressController!.text = "";
          });
          return;
        }
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

    // kind of a hack but w/e
    DeviceUtil.isIpad().then((bool value) {
      if (value) {
        setState(() {
          isIpad = true;
        });
      }
    });
  }

  Future<bool> showNotificationDialog() async {
    final NotificationOptions? option = await showDialog<NotificationOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              Z.of(context).notifications,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text("${Z.of(context).notificationInfo}\n", style: AppStyles.textStyleParagraph(context)),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });

    if (option == null) {
      return false;
    }

    if (option == NotificationOptions.ON) {
      sl.get<SharedPrefsUtil>().setNotificationsOn(true).then((void result) {
        EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: true));
        FirebaseMessaging.instance.requestPermission();
        FirebaseMessaging.instance.getToken().then((String? fcmToken) {
          EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
        });
      });
      return true;
    } else {
      sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((void result) {
        EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: false));
        FirebaseMessaging.instance.getToken().then((String? fcmToken) {
          EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
        });
      });
      return false;
    }
  }

  Future<bool> showNeedVerificationAlert() async {
    switch (await showDialog<int>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              Z.of(context).needVerificationAlertHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("${Z.of(context).needVerificationAlert}\n\n", style: AppStyles.textStyleParagraph(context)),
              ],
            ),
            actions: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).goToQRCode,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).ok,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case 1:
        // go to qr code
        if (receive == null) {
          return false;
        }
        Navigator.of(context).pop();
        // TODO: BACKLOG: this is a roundabout solution to get the qr code to show up
        // probably better to do with an event bus
        Sheets.showAppHeightNineSheet(context: context, widget: receive!);
        return true;
      default:
        return false;
    }
  }

  Future<void> showFallbackConnectedAlert() async {
    await showDialog<bool>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              Z.of(context).fallbackHeader.replaceAll("%1", NonTranslatable.appName),
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("${Z.of(context).fallbackInfo.replaceAll("%1", NonTranslatable.appName)}\n\n",
                    style: AppStyles.textStyleParagraph(context)),
              ],
            ),
            actions: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).ok,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void paintQrCode({String? address}) {
    final QrPainter painter = QrPainter(
      data: address ?? StateContainer.of(context).wallet!.address!,
      version: 6,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    painter.toImageData(MediaQuery.of(context).size.width).then((ByteData? byteData) {
      setState(() {
        receive = ReceiveSheet(
          localCurrency: StateContainer.of(context).curCurrency,
          address: StateContainer.of(context).wallet!.address,
          qrWidget: SizedBox(
              width: MediaQuery.of(context).size.width / 2.675, child: Image.memory(byteData!.buffer.asUint8List())),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create QR ahead of time because it improves performance this way
    if (receive == null && StateContainer.of(context).wallet != null) {
      paintQrCode();
    }

    // The main column that holds everything
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the header of the sheet, balance text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
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
                            CaseChange.toUpperCase(Z.of(context).sendFrom, context),
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
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.only(top: 25, right: 20),
                  child: AppDialogs.infoButton(
                    context,
                    () {
                      AppDialogs.showInfoDialog(context, Z.of(context).sendSheetInfoHeader,
                          Z.of(context).sendSheetInfo.replaceAll("%1", NonTranslatable.appName));
                    },
                  ),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: StateContainer.of(context).selectedAccount!.name,
                              style: TextStyle(
                                color: StateContainer.of(context).curTheme.text60,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: "NunitoSans",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("|",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: StateContainer.of(context).curTheme.text30,
                          )),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
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
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: "NunitoSans",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Balance Text
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
                            text: getXMRThemeAwareRawAccuracy(context, StateContainer.of(context).xmrBalance),
                            style: TextStyle(
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
                              : "${getXMRRawAsThemeAwareAmount(context, StateContainer.of(context).xmrBalance)} XMR",
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
            // A main container that holds everything
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 5, bottom: 5),
                child: GestureDetector(
                  onTap: () {
                    // Clear focus of our fields when tapped in this empty space
                    _addressFocusNode!.unfocus();
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

                            // Column for Enter Address container + Enter Address Error container
                            Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      // ******* Enter Address Container ******* //
                                      getEnterAddressContainer(),
                                      // ******* Enter Address Container End ******* //
                                    ],
                                  ),
                                ),

                                // ******* Enter Address Error Container ******* //
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(_addressValidationText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                // ******* Enter Address Error Container End ******* //
                              ],
                            ),

                            // // Column for Enter Memo container + Enter Memo Error container
                            // Column(
                            //   children: <Widget>[
                            //     Container(
                            //       alignment: Alignment.topCenter,
                            //       child: Stack(
                            //         alignment: Alignment.topCenter,
                            //         children: <Widget>[
                            //           Container(
                            //             margin:
                            //                 EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                            //             alignment: Alignment.bottomCenter,
                            //             constraints: const BoxConstraints(maxHeight: 174, minHeight: 0),
                            //           ),

                            //           // ******* Enter Memo Container ******* //
                            //           getEnterMemoContainer(),
                            //           // ******* Enter Memo Container End ******* //
                            //         ],
                            //       ),
                            //     ),

                            //     // ******* Enter Memo Error Container ******* //
                            //     Container(
                            //       alignment: AlignmentDirectional.center,
                            //       margin: const EdgeInsets.only(top: 3),
                            //       child: Text(_memoValidationText,
                            //           style: TextStyle(
                            //             fontSize: 14.0,
                            //             color: StateContainer.of(context).curTheme.primary,
                            //             fontFamily: "NunitoSans",
                            //             fontWeight: FontWeight.w600,
                            //           )),
                            //     ),
                            //     // ******* Enter Memo Error Container End ******* //
                            //   ],
                            // ),
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
                        context, AppButtonType.PRIMARY, Z.of(context).send, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      final bool validRequest = await _validateRequest();

                      if (!validRequest || !mounted) {
                        return;
                      }

                      String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);
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
                          amountRaw = NumberUtil.getXMRAmountAsRaw(formattedAmount);
                        }
                      }

                      bool isMaxSend = false;
                      if (_isMaxSend()) {
                        isMaxSend = true;
                        if (!mounted) return;
                        amountRaw = StateContainer.of(context).xmrBalance;
                      }

                      EventTaxiImpl.singleton()
                          .fire(XMREvent(type: "xmr_get_fee", message: "$formattedAddress:$amountRaw"));
                      Future<dynamic>.delayed(const Duration(milliseconds: 2000));
                      Sheets.showAppHeightNineSheet(
                          context: context,
                          widget: SendXMRConfirmSheet(
                              amountRaw: amountRaw,
                              destination: formattedAddress,
                              maxSend: isMaxSend,
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

  bool _isPhoneNumber(String text) {
    // TODO: make more thorough:
    return double.tryParse(text) != null;
  }

  void toggleLocalCurrency() {
    return; // TODO:
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
      Future<dynamic>.delayed(const Duration(milliseconds: 50), () {
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
      Future<dynamic>.delayed(const Duration(milliseconds: 50), () {
        _amountController!.text = localAmountStr;
        _amountController!.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
      });
    }
  }

  /// Validate form data to see if valid
  /// @returns true if valid, false otherwise
  Future<bool> _validateRequest() async {
    bool isValid = true;
    _amountFocusNode!.unfocus();
    _addressFocusNode!.unfocus();
    _memoFocusNode!.unfocus();
    // Validate amount
    if (_amountController!.text.trim().isEmpty && _memoController!.text.trim().isNotEmpty) {
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
        bananoAmount = sanitizedAmount(_localCurrencyFormat, _amountController!.text);
      }
      if (bananoAmount.isEmpty) {
        bananoAmount = "0";
      }
      final BigInt balanceRaw = BigInt.parse(StateContainer.of(context).xmrBalance);
      final BigInt? sendAmount = BigInt.tryParse(NumberUtil.getXMRAmountAsRaw(bananoAmount));
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
    // Validate address
    final bool isUser = _addressController!.text.startsWith("@") || _addressController!.text.startsWith("#");
    final bool isFavorite = _addressController!.text.startsWith("★");
    final bool isDomain = _addressController!.text.contains(".") || _addressController!.text.contains(r"$");
    final bool isNano = _addressController!.text.startsWith("nano_");
    // final bool isPhoneNumber = _isPhoneNumber(_addressController!.text);
    if (_addressController!.text.isNotEmpty &&
        !isFavorite &&
        !isUser &&
        !isDomain && /*!Address(_addressController!.text).isValid()*/ false) {
      isValid = false;
      setState(() {
        _addressValidationText = Z.of(context).invalidAddress;
        _pasteButtonVisible = true;
      });
    } else if (!isUser && !isFavorite) {
      setState(() {
        _addressValidationText = "";
        _pasteButtonVisible = false;
      });
      _addressFocusNode!.unfocus();
    }
    if (isValid) {
      // notifications must be turned on if sending a request or memo:
      final bool notificationsEnabled = await sl.get<SharedPrefsUtil>().getNotificationsOn();

      // if (((_memoController!.text.isNotEmpty && _addressController!.text.isNotEmpty)) && !notificationsEnabled) {
      //   final bool notificationTurnedOn = await showNotificationDialog();
      //   if (!notificationTurnedOn) {
      //     isValid = false;
      //   } else {
      //     // not sure why this is needed to get it to update:
      //     // probably event bus related:
      //     await sl.get<SharedPrefsUtil>().setNotificationsOn(true);
      //   }
      // }

      // if (isValid && isRequest) {
      //   // still valid && you have to meet requirements to send requests:
      //   if (StateContainer.of(context).wallet!.user == null && StateContainer.of(context).wallet!.confirmationHeight < _REQUIRED_CONFIRMATION_HEIGHT) {
      //     isValid = false;
      //     await showNeedVerificationAlert();
      //   }
      // }

      // if (isValid && sl.get<AccountService>().fallbackConnected) {
      //   if (_memoController!.text.trim().isNotEmpty) {
      //     isValid = false;
      //     await showFallbackConnectedAlert();
      //   }
      // }
    }
    return isValid;
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
            setState(() {
              _amountValidationText = "";
              _amountController!.text = getXMRRawAsThemeAwareAmount(context, StateContainer.of(context).xmrBalance);
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
        if (!Address(_addressController!.text).isValid()) {
          FocusScope.of(context).requestFocus(_addressFocusNode);
        }
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Address Container Method ************//
  //*******************************************************//
  Widget getEnterAddressContainer() {
    return AppTextField(
      topMargin: 115,
      padding:
          _addressValidAndUnfocused ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
      // padding: EdgeInsets.zero,
      textAlign: TextAlign.center,
      // textAlign: (_isUser || _addressController.text.length == 0) ? TextAlign.center : TextAlign.start,
      focusNode: _addressFocusNode,
      controller: _addressController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        if (_isUser) LengthLimitingTextInputFormatter(20) else LengthLimitingTextInputFormatter(65),
      ],
      textInputAction: _memoController!.text.isEmpty ? TextInputAction.next : TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      hintText: _addressHint ?? Z.of(context).enterUserOrAddress,
      prefixButton: TextFieldButton(
          icon: AppIcons.scan,
          onPressed: () async {
            UIUtil.cancelLockEvent();
            final String? scanResult = await UserDataUtil.getQRData(DataType.ADDRESS, context) as String?;
            if (!mounted) return;
            if (scanResult == null) {
              UIUtil.showSnackbar(Z.of(context).qrInvalidAddress, context);
            } else if (!QRScanErrs.ERROR_LIST.contains(scanResult)) {
              if (mounted) {
                setState(() {
                  _addressController!.text = scanResult;
                  _addressValidationText = "";
                  _addressValidAndUnfocused = true;
                });
                _addressFocusNode!.unfocus();
              }
            }
          }),
      fadePrefixOnCondition: true,
      prefixShowFirstCondition: _showContactButton && _users.isEmpty,
      suffixButton: TextFieldButton(
        icon: _clearButton ? AppIcons.clear : AppIcons.paste,
        onPressed: () {
          if (_clearButton) {
            setState(() {
              _isUser = false;
              _addressValidationText = "";
              _pasteButtonVisible = true;
              _clearButton = false;
              _showContactButton = true;
              _addressController!.text = "";
              _users = [];
            });
            return;
          }
          Clipboard.getData("text/plain").then((ClipboardData? data) {
            if (data == null || data.text == null) {
              return;
            }
            final Address address = Address(data.text);
            String addressText = data.text!;
            // if (!address.isValid()) {
            //   return;
            // }
            sl.get<DBHelper>().getUserOrContactWithAddress(addressText).then((User? user) {
              if (user == null) {
                setState(() {
                  _isUser = false;
                  _addressValidationText = "";
                  _addressStyle = AddressStyle.TEXT90;
                  _pasteButtonVisible = true;
                  _clearButton = true;
                  _showContactButton = false;
                  _addressController!.text = addressText;
                  _addressFocusNode!.unfocus();
                  _addressValidAndUnfocused = true;
                });
              } else {
                // Is a user
                setState(() {
                  _addressController!.text = user.getDisplayName()!;
                  _addressFocusNode!.unfocus();
                  _users = [];
                  _isUser = true;
                  _addressValidationText = "";
                  _addressStyle = AddressStyle.PRIMARY;
                  _pasteButtonVisible = true;
                  _clearButton = true;
                  _showContactButton = false;
                });
              }
            });
          });
        },
      ),
      fadeSuffixOnCondition: true,
      suffixShowFirstCondition: _pasteButtonVisible,
      style: _addressStyle == AddressStyle.TEXT60
          ? AppStyles.textStyleAddressText60(context)
          : _addressStyle == AddressStyle.TEXT90
              ? AppStyles.textStyleAddressText90(context)
              : AppStyles.textStyleAddressPrimary(context),
      onChanged: (String text) async {
        bool isUser = false;
        final bool isDomain = text.contains(".") || text.contains(r"$");
        final bool isFavorite = text.startsWith("★");
        final bool isNano = text.startsWith("nano_");

        // prevent spaces:
        if (text.contains(" ")) {
          text = text.replaceAll(" ", "");
          _addressController!.text = text;
          _addressController!.selection =
              TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
        }

        if (text.isNotEmpty) {
          setState(() {
            _showContactButton = false;
            _pasteButtonVisible = true;
            _clearButton = true;
          });
        } else {
          setState(() {
            _showContactButton = true;
            _pasteButtonVisible = true;
            _clearButton = false;
          });
        }

        if (text.isNotEmpty && !isUser && !isNano) {
          isUser = true;
        }

        if (text.isNotEmpty && text.startsWith("nano_")) {
          isUser = false;
        }

        if (text.isNotEmpty && text.contains(".")) {
          isUser = false;
        }

        // check if it's a real nano address:
        // bool isUser = !text.startsWith("nano_") && !text.startsWith("★");
        if (text.isEmpty) {
          setState(() {
            _isUser = false;
            _users = [];
          });
        } else if (isFavorite) {
          final List<User> matchedList =
              await sl.get<DBHelper>().getContactsWithNameLike(SendSheetHelpers.stripPrefixes(text));
          final Set<String?> nicknames = <String?>{};
          matchedList.retainWhere((User x) => nicknames.add(x.nickname));
          setState(() {
            _isFavorite = true;
            _users = matchedList;
          });
        } else if (isUser || isDomain) {
          final List<User> matchedList =
              await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(SendSheetHelpers.stripPrefixes(text));
          setState(() {
            _isFavorite = false;
            _users = matchedList;
          });
        } else {
          setState(() {
            _isUser = false;
            _users = [];
          });
        }
        // Always reset the error message to be less annoying
        if (_addressValidationText.isNotEmpty) {
          setState(() {
            _addressValidationText = "";
          });
        }
        if (isNano && Address(text).isValid()) {
          _addressFocusNode!.unfocus();
          setState(() {
            _addressStyle = AddressStyle.TEXT90;
            _addressValidationText = "";
            _pasteButtonVisible = false;
          });
        } else {
          setState(() {
            _addressStyle = AddressStyle.TEXT60;
          });
        }

        if ((isUser || isFavorite) != _isUser) {
          setState(() {
            _isUser = isUser || isFavorite;
          });
        }
      },
      onSubmitted: (String text) {
        if (_memoController!.text.isEmpty) {
          FocusScope.of(context).nextFocus();
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      overrideTextFieldWidget: _addressValidAndUnfocused
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _addressValidAndUnfocused = false;
                });
                Future.delayed(const Duration(milliseconds: 50), () {
                  FocusScope.of(context).requestFocus(_addressFocusNode);
                });
              },
              child: UIUtil.threeLineAddressText(context, _addressController!.text))
          : null,
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Memo Container Method ************//
  //*******************************************************//
  Widget getEnterMemoContainer() {
    double margin = 200;
    if (_addressController!.text.startsWith("nano_")) {
      if (_addressController!.text.length > 24) {
        margin = 217;
      }
      if (_addressController!.text.length > 48) {
        margin = 238;
      }
    }
    return AppTextField(
      topMargin: margin,
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
  //*************************************************************//
}
