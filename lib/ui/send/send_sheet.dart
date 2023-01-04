import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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
import 'package:wallet_flutter/bus/deep_link_event.dart';
import 'package:wallet_flutter/bus/fcm_update_event.dart';
import 'package:wallet_flutter/bus/notification_setting_change_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/notification_setting.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/response/auth_item.dart';
import 'package:wallet_flutter/network/model/response/pay_item.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/auth/auth_confirm_sheet.dart';
import 'package:wallet_flutter/ui/handoff/handoff_confirm_sheet.dart';
import 'package:wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:wallet_flutter/ui/scan/scan_screen.dart';
import 'package:wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:wallet_flutter/ui/send/send_gift.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/misc.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/deviceutil.dart';
import 'package:wallet_flutter/util/numberutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:wallet_flutter/util/user_data_util.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SendSheet extends StatefulWidget {
  const SendSheet({required this.localCurrency, this.user, this.address, this.quickSendAmount}) : super();

  final AvailableCurrency localCurrency;
  final User? user;
  final String? address;
  final String? quickSendAmount;

  @override
  SendSheetState createState() => SendSheetState();
}

enum AddressStyle { TEXT60, TEXT90, PRIMARY }

mixin SendSheetHelpers {
  static String stripPrefixes(String addressText) {
    return addressText.replaceAll("@", "").replaceAll("★", "").replaceAll("#", "");
  }

  static List<String> toggleLocalCurrency(
    var setState,
    BuildContext context,
    TextEditingController amountController,
    bool localCurrencyMode,
    NumberFormat localCurrencyFormat,
    String lastLocalCurrencyAmount,
    String lastCryptoAmount,
  ) {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
    // this way you can tap button and tap back and not end up with X.9993451 NANO
    if (localCurrencyMode) {
      // Switching to crypto-mode
      String cryptoAmountStr;
      // Check out previous state
      if (amountController.text == lastLocalCurrencyAmount) {
        cryptoAmountStr = lastCryptoAmount;
      } else {
        lastLocalCurrencyAmount = amountController.text;
        lastCryptoAmount = convertLocalCurrencyToLocalizedCrypto(context, localCurrencyFormat, amountController.text);
        cryptoAmountStr = lastCryptoAmount;
      }
      setState(() {
        localCurrencyMode = false;
      });
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        amountController.text = cryptoAmountStr;
        amountController.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
      });
      return [lastCryptoAmount, lastLocalCurrencyAmount];
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (amountController.text == lastCryptoAmount) {
        localAmountStr = lastLocalCurrencyAmount;
        if (!lastLocalCurrencyAmount.startsWith(localCurrencyFormat.currencySymbol)) {
          lastLocalCurrencyAmount = localCurrencyFormat.currencySymbol + lastLocalCurrencyAmount;
        }
      } else {
        lastCryptoAmount = amountController.text;
        lastLocalCurrencyAmount = convertCryptoToLocalCurrency(
          context,
          localCurrencyFormat,
          amountController.text,
        );
        localAmountStr = lastLocalCurrencyAmount;
      }
      setState(() {
        localCurrencyMode = true;
      });
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        amountController.text = localAmountStr;
        amountController.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
      });
      return [lastCryptoAmount, lastLocalCurrencyAmount];
    }
  }

  static String getAmountRaw(
    BuildContext context,
    NumberFormat localCurrencyFormat,
    TextEditingController amountController,
    bool localCurrencyMode,
  ) {
    final String formattedAmount = sanitizedAmount(localCurrencyFormat, amountController.text);

    String amountRaw;
    if (amountController.text.isEmpty || amountController.text == "0") {
      amountRaw = "0";
    } else {
      if (localCurrencyMode) {
        amountRaw = NumberUtil.getAmountAsRaw(sanitizedAmount(localCurrencyFormat,
            convertLocalCurrencyToLocalizedCrypto(context, localCurrencyFormat, amountController.text)));
      } else {
        amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
      }
    }
    return amountRaw;
  }

  // static Future<void> addressFocusNodeListener(
  //     FocusNode _addressFocusNode, TextEditingController _addressController) async {
  //   if (_addressFocusNode.hasFocus) {
  //     setState(() {
  //       _addressHint = "";
  //       _addressValidationText = "";
  //       _addressValidAndUnfocused = false;
  //       _pasteButtonVisible = true;
  //       _addressStyle = AddressStyle.TEXT60;
  //       if (_addressController!.text.isNotEmpty) {
  //         _clearButton = true;
  //       } else {
  //         _clearButton = false;
  //       }
  //     });
  //     _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
  //     if (_addressController.text.isNotEmpty &&
  //         _addressController.text.length > 1 &&
  //         !_addressController!.text.startsWith("nano_")) {
  //       final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController.text);
  //       if (_addressController.text != formattedAddress) {
  //         setState(() {
  //           _addressController.text = formattedAddress;
  //         });
  //       }
  //       final List<User> userList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(formattedAddress);
  //       setState(() {
  //         _users = userList;
  //       });
  //     }

  //     if (_addressController!.text.isEmpty) {
  //       setState(() {
  //         _users = [];
  //       });
  //     }
  //   } else {
  //     _addressHint = Z.of(context).enterUserOrAddress;
  //     _users = [];
  //     if (Address(_addressController!.text).isValid()) {
  //       _addressValidAndUnfocused = true;
  //     }
  //     if (_addressController!.text.isEmpty) {
  //       _pasteButtonVisible = true;
  //     }

  //     if (SendSheetHelpers.stripPrefixes(_addressController!.text).isEmpty) {
  //       // setState(() {
  //       _addressController!.text = "";
  //       // });
  //       return;
  //     }
  //     if (_addressController!.text.isNotEmpty && !_addressController!.text.contains("★")) {
  //       final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);
  //       // check if in the username db:
  //       String? address;
  //       String? type;
  //       final User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController!.text);
  //       if (user != null) {
  //         type = user.type;
  //         if (_addressController.text != user.getDisplayName()) {
  //           _addressController.text = user.getDisplayName()!;
  //         }
  //       } else {
  //         // check if UD / ENS / opencap address
  //         if (_addressController!.text.contains(r"$")) {
  //           // check if opencap address:
  //           address = await sl.get<UsernameService>().checkOpencapDomain(formattedAddress);
  //           if (address != null) {
  //             type = UserTypes.OPENCAP;
  //           }
  //         } else if (_addressController!.text.contains(".")) {
  //           // check if UD domain:
  //           address = await sl.get<UsernameService>().checkUnstoppableDomain(formattedAddress);
  //           if (address != null) {
  //             type = UserTypes.UD;
  //           } else {
  //             // check if ENS domain:
  //             address = await sl.get<UsernameService>().checkENSDomain(formattedAddress);
  //             if (address != null) {
  //               type = UserTypes.ENS;
  //             }
  //           }
  //         }
  //       }

  //       if (type != null) {
  //         _pasteButtonVisible = false;
  //         _addressStyle = AddressStyle.PRIMARY;

  //         if (address != null && user == null) {
  //           // add to the db if missing:
  //           final User user = User(username: formattedAddress, address: address, type: type, is_blocked: false);
  //           await sl.get<DBHelper>().addUser(user);
  //         }
  //       } else {
  //         _addressStyle = AddressStyle.TEXT60;
  //       }
  //     }
  //   }
  // }
}

class SendSheetState extends State<SendSheet> {
  final Logger log = sl.get<Logger>();

  FocusNode _addressFocusNode = FocusNode();
  FocusNode _amountFocusNode = FocusNode();
  FocusNode _memoFocusNode = FocusNode();
  TextEditingController _addressController = TextEditingController();
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
  bool? animationOpen;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a username is being entered
  bool _isUser = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;
  bool _clearButton = false;
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

  bool _addressCopied = false;
  Timer? _addressCopiedTimer;

  @override
  void initState() {
    super.initState();
    quickSendAmount = widget.quickSendAmount;
    animationOpen = false;

    // _amountHint = Z.of(context).enterAmount;
    // _addressHint = Z.of(context).enterUserOrAddress;
    // _memoHint = Z.of(context).enterMemo;

    if (widget.user != null) {
      // Setup initial state for contact pre-filled
      _addressController.text = widget.user!.getDisplayName()!;
      _isUser = true;
      _pasteButtonVisible = false;
      _addressStyle = AddressStyle.PRIMARY;
    } else if (widget.address != null) {
      // Setup initial state with prefilled address
      _addressController.text = widget.address!;
      _pasteButtonVisible = false;
      _addressStyle = AddressStyle.TEXT90;
      _addressValidAndUnfocused = true;
    }
    // On amount focus change
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        if (_rawAmount != null) {
          setState(() {
            _amountController.text = getRawAsThemeAwareAmount(context, _rawAmount);
            _rawAmount = null;
          });
        }
        if (quickSendAmount != null) {
          _amountController.text = "";
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
    _addressFocusNode.addListener(() async {
      if (_addressFocusNode.hasFocus) {
        setState(() {
          _addressHint = "";
          _addressValidationText = "";
          _addressValidAndUnfocused = false;
          _pasteButtonVisible = true;
          _addressStyle = AddressStyle.TEXT60;
          if (_addressController.text.isNotEmpty) {
            _clearButton = true;
          } else {
            _clearButton = false;
          }
        });
        _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
        if (_addressController.text.isNotEmpty &&
            _addressController.text.length > 1 &&
            !_addressController.text.startsWith("nano_")) {
          final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController.text);
          if (_addressController.text != formattedAddress) {
            setState(() {
              _addressController.text = formattedAddress;
            });
          }
          final List<User> userList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(formattedAddress);
          setState(() {
            _users = userList;
          });
        }

        if (_addressController.text.isEmpty) {
          setState(() {
            _users = [];
          });
        }
      } else {
        setState(() {
          _addressHint = Z.of(context).enterUserOrAddress;
          _users = [];
          if (Address(_addressController.text).isValid()) {
            _addressValidAndUnfocused = true;
          }
          if (_addressController.text.isEmpty) {
            _pasteButtonVisible = true;
          }
        });

        if (SendSheetHelpers.stripPrefixes(_addressController.text).isEmpty) {
          setState(() {
            _addressController.text = "";
          });
          return;
        }
        // check if UD / ENS / opencap / onchain address:
        if (_addressController.text.isNotEmpty && !_addressController.text.contains("★")) {
          User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController.text);
          user ??= await sl.get<UsernameService>().figureOutUsernameType(_addressController.text);

          if (user != null) {
            setState(() {
              _addressController.text = user!.getDisplayName()!;
              _pasteButtonVisible = false;
              _addressStyle = AddressStyle.PRIMARY;
            });
          } else {
            setState(() {
              _addressStyle = AddressStyle.TEXT60;
            });
          }
        }
      }
    });
    // On memo focus change
    _memoFocusNode.addListener(() {
      if (_memoFocusNode.hasFocus) {
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
          _amountController.text = getRawAsThemeAwareAmount(context, quickSendAmount);
        });
      });
    }

    // kind of a hack but w/e
    DeviceUtil.isIpad().then((bool value) async {
      final bool isAvailable = await NfcManager.instance.isAvailable();

      // we don't support NFC so don't show the NFC button:
      if (!isAvailable) {
        return;
      }

      if (value) {
        setState(() {
          isIpad = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _addressFocusNode.dispose();
    _memoFocusNode.dispose();
    _amountController.dispose();
    _addressController.dispose();
    _memoController.dispose();

    super.dispose();
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

  Future<void> _scanQR() async {
    UIUtil.cancelLockEvent();
    final dynamic scanResult = await UserDataUtil.getQRData(DataType.DATA, context);
    if (!mounted) return;
    if (scanResult == null) {
      // ignore: use_build_context_synchronously
      UIUtil.showSnackbar(Z.of(context).qrUnknownError, context);
    } else if (scanResult is String && QRScanErrs.ERROR_LIST.contains(scanResult)) {
      if (scanResult == QRScanErrs.PERMISSION_DENIED) {
        UIUtil.showSnackbar(Z.of(context).qrInvalidPermissions, context);
      } else if (scanResult == QRScanErrs.UNKNOWN_ERROR) {
        UIUtil.showSnackbar(Z.of(context).qrUnknownError, context);
      }
      return;
    } else if (scanResult is Address) {
      // Is a URI
      final Address address = scanResult;
      // See if this address belongs to a contact or username
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(address.address!);

      if (user != null) {
        // Is a user
        if (mounted) {
          setState(() {
            _isUser = true;
            _addressValidationText = "";
            _addressStyle = AddressStyle.PRIMARY;
            _pasteButtonVisible = false;
          });
          _addressController.text = user.getDisplayName()!;
        }
      } else {
        // Not a contact or username
        if (mounted) {
          setState(() {
            _isUser = false;
            _addressValidationText = "";
            _addressStyle = AddressStyle.TEXT90;
            _pasteButtonVisible = false;
          });
          _addressController.text = address.address!;
          _addressFocusNode.unfocus();
          setState(() {
            _addressValidAndUnfocused = true;
          });
        }
      }

      // If amount is present, fill it and go to SendConfirm
      if (mounted && address.amount != null) {
        final BigInt? amountBigInt = BigInt.tryParse(address.amount!);
        if (_localCurrencyMode && mounted) {
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
          _amountController.text = getRawAsThemeAwareAmount(context, address.amount);
        } else if (mounted) {
          setState(() {
            _rawAmount = address.amount;
            // If raw amount has more precision than we support show a special indicator
            _amountController.text = getThemeAwareAccuracyAmount(context, address.amount);
          });
          _addressFocusNode.unfocus();
        }

        // If balance is insufficient show error:
        if (StateContainer.of(context).wallet!.accountBalance < amountBigInt!) {
          UIUtil.showSnackbar(Z.of(context).insufficientBalance, context);
          return;
        }

        // Go to confirm sheet
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendConfirmSheet(
                amountRaw: _localCurrencyMode
                    ? NumberUtil.getAmountAsRaw(sanitizedAmount(_localCurrencyFormat,
                        convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController.text)))
                    : _rawAmount ?? getThemeAwareAmountAsRaw(context, _amountController.text),
                destination: user?.address ?? address.address!,
                contactName: user?.getDisplayName(),
                maxSend: _isMaxSend(),
                localCurrency: _localCurrencyMode ? _amountController.text : null));
      }
    } else if (scanResult is PayItem) {
      // block handoff item:
      final PayItem payItem = scanResult;

      // See if this address belongs to a contact or username
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(payItem.account);
      if (!mounted) return;

      // check if the user has enough balance to send this amount:
      // If balance is insufficient show error:
      final BigInt? amountBigInt = BigInt.tryParse(payItem.amount);
      if (StateContainer.of(context).wallet!.accountBalance < amountBigInt!) {
        UIUtil.showSnackbar(Z.of(context).insufficientBalance, context);
        return;
      }

      // if payItem.exact is false, we should allow the user to change the amount to send to >= amount
      if (!payItem.exact && mounted) {
        // TODO:
        log.d("payItem exact is false: unsupported handoff flow!");
        return;
      }

      // Go to confirm sheet:
      Sheets.showAppHeightNineSheet(
          context: context,
          widget: HandoffConfirmSheet(
            payItem: payItem,
            destination: user?.address ?? payItem.account,
            contactName: user?.getDisplayName(),
          ));
    } else if (scanResult is AuthItem) {
      // handle auth handoff:
      final AuthItem authItem = scanResult;
      // See if this address belongs to a contact or username
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(authItem.account);

      // Go to confirm sheet:
      Sheets.showAppHeightNineSheet(
          context: context,
          widget: AuthConfirmSheet(
            authItem: authItem,
            destination: user?.address ?? authItem.account,
            contactName: user?.getDisplayName(),
          ));
    } else {
      // something went wrong, show generic error:
      UIUtil.showSnackbar(Z.of(context).qrUnknownError, context);
    }
  }

  Future<void> _scanNFC() async {
    // Start Session
    NfcManager.instance.startSession(
      onError: (NfcError error) async {
        log.d("onError: ${error.message}");
      },
      pollingOptions: Set()..add(NfcPollingOption.iso14443),
      onDiscovered: (NfcTag tag) async {
        // Do something with an NfcTag instance.
        final Ndef? ndef = Ndef.from(tag);
        if (ndef?.cachedMessage != null && ndef!.cachedMessage!.records.isNotEmpty) {
          Uint8List payload = ndef.cachedMessage!.records[0].payload;

          if (payload.length < 3) {
            return;
          }

          if (payload[0] == 0x00) {
            payload = payload.sublist(1);
            EventTaxiImpl.singleton().fire(DeepLinkEvent(link: utf8.decode(payload)));
          } else {
            // try anyways?
            EventTaxiImpl.singleton().fire(DeepLinkEvent(link: utf8.decode(payload)));
          }
          NfcManager.instance.stopSession();
        }
      },
    );
    // try {
    //   UIUtil.cancelLockEvent();
    //   startNFCSession("");
    // } catch (e) {
    //   stopNFCSession();
    // }
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
                SizedBox(
                  width: 60,
                  height: 60,
                  child: AppDialogs.infoButton(
                    context,
                    () {
                      Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
                      Sheets.showAppHeightEightSheet(
                          context: context,
                          widget: SendGiftSheet(
                            localCurrency: widget.localCurrency,
                          ));
                    },
                    icon: AppIcons.gift,
                    key: const Key("gift_button"),
                  ),
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
                SizedBox(
                  width: 60,
                  height: 60,
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

            const SizedBox(height: 5),
            // account / wallet name:
            OutlinedButton(
              onPressed: () async {
                Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address));
                setState(() {
                  // Set copied style
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
                    _addressFocusNode.unfocus();
                    _amountFocusNode.unfocus();
                    _memoFocusNode.unfocus();
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
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context).size.width * 0.105,
                                            right: MediaQuery.of(context).size.width * 0.105),
                                        alignment: Alignment.bottomCenter,
                                        constraints: const BoxConstraints(maxHeight: 160, minHeight: 0),
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
                                              margin: const EdgeInsets.only(bottom: 50),
                                              child: _users.isEmpty
                                                  ? const SizedBox()
                                                  : ListView.builder(
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      itemCount: _users.length,
                                                      itemBuilder: (BuildContext context, int index) {
                                                        return Misc.buildUserItem(context, _users[index], false,
                                                            (User user) {
                                                          _addressController.text = user.getDisplayName()!;
                                                          _addressFocusNode.unfocus();
                                                          setState(() {
                                                            _isUser = true;
                                                            _pasteButtonVisible = false;
                                                            _addressStyle = AddressStyle.PRIMARY;
                                                            _addressValidationText = "";
                                                          });
                                                        });
                                                      },
                                                    ),
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
                        context, AppButtonType.PRIMARY, Z.of(context).send, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      final bool validRequest = await _validateRequest();

                      if (!validRequest || !mounted) {
                        return;
                      }

                      String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController.text);
                      final String formattedAmount = sanitizedAmount(_localCurrencyFormat, _amountController.text);

                      String amountRaw;

                      if (_amountController.text.isEmpty || _amountController.text == "0") {
                        amountRaw = "0";
                      } else {
                        if (_localCurrencyMode) {
                          amountRaw = NumberUtil.getAmountAsRaw(sanitizedAmount(
                              _localCurrencyFormat,
                              convertLocalCurrencyToLocalizedCrypto(
                                  context, _localCurrencyFormat, _amountController.text)));
                        } else {
                          if (_rawAmount != null) {
                            amountRaw = _rawAmount!;
                          } else {
                            if (!mounted) return;
                            amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
                          }
                        }
                      }

                      bool isMaxSend = false;
                      if (_isMaxSend()) {
                        isMaxSend = true;
                        if (!mounted) return;
                        amountRaw = StateContainer.of(context).wallet!.accountBalance.toString();
                      }

                      // verifies the input is a user in the db
                      if (!_addressController.text.startsWith("nano_") && _addressController.text.isNotEmpty) {
                        // Need to make sure its a valid contact or user
                        final User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController.text);
                        if (user == null) {
                          setState(() {
                            if (_addressController.text.startsWith("★")) {
                              _addressValidationText = Z.of(context).contactInvalid;
                            } else if (_addressController.text.startsWith("@") ||
                                _addressController.text.startsWith("#")) {
                              _addressValidationText = Z.of(context).usernameInvalid;
                            } else if (_addressController.text.contains(".") ||
                                _addressController.text.contains(r"$")) {
                              _addressValidationText = Z.of(context).domainInvalid;
                            }
                          });
                        } else {
                          Sheets.showAppHeightNineSheet(
                              context: context,
                              widget: SendConfirmSheet(
                                  amountRaw: amountRaw,
                                  destination: user.address!,
                                  contactName: user.getDisplayName(),
                                  maxSend: isMaxSend,
                                  localCurrency: _localCurrencyMode ? _amountController.text : null,
                                  memo: _memoController.text));
                        }
                      } else {
                        Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: SendConfirmSheet(
                                amountRaw: amountRaw,
                                destination: formattedAddress,
                                maxSend: isMaxSend,
                                link: "",
                                paperWalletSeed: "",
                                localCurrency: _localCurrencyMode ? _amountController.text : null,
                                memo: _memoController.text));
                      }
                    }),
                  ],
                ),
                if (Platform.isIOS && !isIpad)
                  Row(
                    children: <Widget>[
                      // Scan QR Code Button
                      AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        Z.of(context).scanQrCode,
                        Dimens.BUTTON_COMPACT_LEFT_DIMENS,
                        onPressed: () {
                          _scanQR();
                        },
                      ),
                      // scan for nfc
                      AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        Z.of(context).scanNFC,
                        Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
                        onPressed: _scanNFC,
                      )
                    ],
                  )
                else
                  Row(
                    children: <Widget>[
                      // Scan QR Code Button
                      AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        Z.of(context).scanQrCode,
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: _scanQR,
                      )
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
    if (_amountController.text.isEmpty) {
      return false;
    }
    try {
      String textField = _amountController.text;
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

  // void toggleLocalCurrency() {
  //   // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
  //   // this way you can tap button and tap back and not end up with X.9993451 NANO
  //   if (_localCurrencyMode) {
  //     // Switching to crypto-mode
  //     String cryptoAmountStr;
  //     // Check out previous state
  //     if (_amountController.text == _lastLocalCurrencyAmount) {
  //       cryptoAmountStr = _lastCryptoAmount;
  //     } else {
  //       _lastLocalCurrencyAmount = _amountController.text;
  //       _lastCryptoAmount =
  //           convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController!.text);
  //       cryptoAmountStr = _lastCryptoAmount;
  //     }
  //     setState(() {
  //       _localCurrencyMode = false;
  //     });
  //     Future<void>.delayed(const Duration(milliseconds: 50), () {
  //       _amountController.text = cryptoAmountStr;
  //       _amountController.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
  //     });
  //   } else {
  //     // Switching to local-currency mode
  //     String localAmountStr;
  //     // Check our previous state
  //     if (_amountController.text == _lastCryptoAmount) {
  //       localAmountStr = _lastLocalCurrencyAmount;
  //       if (!_lastLocalCurrencyAmount.startsWith(_localCurrencyFormat.currencySymbol)) {
  //         _lastLocalCurrencyAmount = _localCurrencyFormat.currencySymbol + _lastLocalCurrencyAmount;
  //       }
  //     } else {
  //       _lastCryptoAmount = _amountController.text;
  //       _lastLocalCurrencyAmount = convertCryptoToLocalCurrency(
  //         context,
  //         _localCurrencyFormat,
  //         _amountController.text,
  //       );
  //       localAmountStr = _lastLocalCurrencyAmount;
  //     }
  //     setState(() {
  //       _localCurrencyMode = true;
  //     });
  //     Future<void>.delayed(const Duration(milliseconds: 50), () {
  //       _amountController.text = localAmountStr;
  //       _amountController.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
  //     });
  //   }
  // }

  /// Validate form data to see if valid
  /// @returns true if valid, false otherwise
  Future<bool> _validateRequest() async {
    // try {
    //   await sl.get<UsernameService>().registerUsernameToAccountMap(context, "testuser");
    // } catch (e) {
    //   print(e);
    // }
    // try {
    //   await sl.get<UsernameService>().registerAccountToUsernameMap(context, "testuser");
    // } catch (e) {
    //   print(e);
    // }
    // try {
    //   print(await sl.get<UsernameService>().checkOnchainUsername("testuser"));
    // } catch (e) {
    //   print(e);
    // }
    // try {
    //   print(await sl.get<UsernameService>().checkOnchainAddress(StateContainer.of(context).wallet!.address!));
    // } catch (e) {
    //   print(e);
    // }

    bool isValid = true;
    _amountFocusNode.unfocus();
    _addressFocusNode.unfocus();
    _memoFocusNode.unfocus();
    // Validate amount
    if (_amountController.text.trim().isEmpty && _memoController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _amountValidationText = Z.of(context).amountMissing;
      });
    } else {
      String bananoAmount;
      if (_localCurrencyMode) {
        bananoAmount = sanitizedAmount(_localCurrencyFormat,
            convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController.text));
      } else {
        if (_rawAmount == null) {
          bananoAmount = sanitizedAmount(_localCurrencyFormat, _amountController.text);
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
        if (_memoController.text.trim().isEmpty) {
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
    final bool isUser = _addressController.text.startsWith("@") || _addressController.text.startsWith("#");
    final bool isFavorite = _addressController.text.startsWith("★");
    final bool isDomain = _addressController.text.contains(".") || _addressController.text.contains(r"$");
    final bool isNano = _addressController.text.startsWith("nano_");
    if (_addressController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = Z.of(context).addressMissing;
        _pasteButtonVisible = true;
      });
    } else if (_addressController.text.isNotEmpty &&
        !isFavorite &&
        !isUser &&
        !isDomain &&
        !Address(_addressController.text).isValid()) {
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
      _addressFocusNode.unfocus();
    }
    if (isValid) {
      // notifications must be turned on if sending a request or memo:
      final bool notificationsEnabled = await sl.get<SharedPrefsUtil>().getNotificationsOn();

      if ((_memoController.text.isNotEmpty /*&& !isPhoneNumber*/ && _addressController.text.isNotEmpty) &&
          !notificationsEnabled) {
        final bool notificationTurnedOn = await showNotificationDialog();
        if (!notificationTurnedOn) {
          isValid = false;
        } else {
          // not sure why this is needed to get it to update:
          // probably event bus related:
          await sl.get<SharedPrefsUtil>().setNotificationsOn(true);
        }
      }
    }
    return isValid;
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  Widget getEnterAmountContainer() {
    double margin = 200;
    if (_addressController.text.startsWith("nano_")) {
      if (_addressController.text.length > 24) {
        margin += 15;
      }
      if (_addressController.text.length > 48) {
        margin += 20;
      }
    }
    return AppTextField(
      topMargin: margin,
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
              _amountController.text = getRawAsThemeAwareFormattedAmount(
                  context, StateContainer.of(context).wallet!.accountBalance.toString());
              _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
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
              _amountController.text = _localCurrencyFormat.currencySymbol + localAmount;
              _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
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
        if (!Address(_addressController.text).isValid()) {
          FocusScope.of(context).requestFocus(_addressFocusNode);
        }
      },
    );
  } //************ Enter Address Container Method End ************//

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
        textInputAction: _memoController.text.isEmpty ? TextInputAction.next : TextInputAction.done,
        maxLines: null,
        autocorrect: false,
        hintText: _addressHint ?? Z.of(context).enterUserOrAddress,
        prefixButton: TextFieldButton(
          icon: AppIcons.scan,
          onPressed: () async {
            await _scanQR();
          },
        ),
        fadePrefixOnCondition: true,
        prefixShowFirstCondition: _users.isEmpty,
        suffixButton: TextFieldButton(
          icon: _clearButton ? AppIcons.clear : AppIcons.paste,
          onPressed: () {
            if (_clearButton) {
              setState(() {
                _isUser = false;
                _addressValidationText = "";
                _pasteButtonVisible = true;
                _clearButton = false;
                _addressController.text = "";
                _users = [];
              });
              return;
            }
            Clipboard.getData("text/plain").then((ClipboardData? data) {
              if (data == null || data.text == null) {
                return;
              }
              final Address address = Address(data.text);
              if (address.isValid()) {
                sl.get<DBHelper>().getUserOrContactWithAddress(address.address!).then((User? user) {
                  if (user == null) {
                    setState(() {
                      _isUser = false;
                      _addressValidationText = "";
                      _addressStyle = AddressStyle.TEXT90;
                      _pasteButtonVisible = true;
                      _clearButton = true;
                      _addressController.text = address.address!;
                      _addressFocusNode.unfocus();
                      _addressValidAndUnfocused = true;
                    });
                  } else {
                    // Is a user
                    setState(() {
                      _addressController.text = user.getDisplayName()!;
                      _addressFocusNode.unfocus();
                      _users = [];
                      _isUser = true;
                      _addressValidationText = "";
                      _addressStyle = AddressStyle.PRIMARY;
                      _pasteButtonVisible = true;
                      _clearButton = true;
                    });
                  }
                });
              }
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
            _addressController.text = text;
            _addressController.selection =
                TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
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
              _users = matchedList;
            });
          } else if (isUser || isDomain) {
            final List<User> matchedList =
                await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(SendSheetHelpers.stripPrefixes(text));
            setState(() {
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
            _addressFocusNode.unfocus();
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
          if (_memoController.text.isEmpty) {
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
                  Future<void>.delayed(const Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(_addressFocusNode);
                  });
                },
                child: UIUtil.threeLineAddressText(context, _addressController.text))
            : null);
  } //************ Enter Address Container Method End ************//

  //************ Enter Memo Container Method ************//
  //*******************************************************//
  Widget getEnterMemoContainer() {
    double margin = 285;
    if (_addressController.text.startsWith("nano_")) {
      if (_addressController.text.length > 24) {
        margin += 10;
      }
      if (_addressController.text.length > 48) {
        margin += 10;
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
}
