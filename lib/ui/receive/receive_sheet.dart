import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:quiver/strings.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/receive/receive_show_qr.dart';
import 'package:wallet_flutter/ui/receive/split_bill_sheet.dart';
import 'package:wallet_flutter/ui/request/request_confirm_sheet.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/util/confirm_sheet.dart';
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
import 'package:wallet_flutter/util/numberutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:wallet_flutter/util/user_data_util.dart';

// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
// import 'package:ndef/ndef.dart' as ndef;
// import 'package:flutter_nearby_messages_api/flutter_nearby_messages_api.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  NumericalRangeFormatter({this.min, this.max});

  final double? min;
  final double? max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == "") {
      return newValue;
    } else if (int.parse(newValue.text) < min!) {
      return TextEditingValue.empty.copyWith(text: min!.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max! ? oldValue : newValue;
    }
  }
}

class ReceiveSheet extends StatefulWidget {
  const ReceiveSheet({required this.localCurrency, this.address, this.qrWidget}) : super();
  final AvailableCurrency localCurrency;
  final Widget? qrWidget;
  final String? address;

  @override
  // ignore: library_private_types_in_public_api
  _ReceiveSheetState createState() => _ReceiveSheetState();
}

class _ReceiveSheetState extends State<ReceiveSheet> {
  GlobalKey? shareCardKey;
  ByteData? shareImageData;
  // Address copied items
  // Current state references
  bool _showShareCard = false;
  late bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  String? _rawAmount;

  // states:
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
  String? quickSendAmount;
  late List<User> _users;
  bool? animationOpen;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a username is being entered
  bool _isUser = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;
  bool _clearButton = false;
  bool _showContactButton = true;
  // Local currency mode/fiat conversion
  bool _localCurrencyMode = false;
  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";
  late NumberFormat _localCurrencyFormat;

  final int _REQUIRED_CONFIRMATION_HEIGHT = 10;

  Widget? qrWidget;

  bool _isSheetOpen = true;

  @override
  void initState() {
    super.initState();
    // Set initial state of copy button
    _addressCopied = false;
    // Create our SVG-heavy things in the constructor because they are slower operations
    // Share card initialization
    shareCardKey = GlobalKey();
    _showShareCard = false;
    _users = <User>[];

    // _amountHint = Z.of(context).enterAmount;
    // _addressHint = Z.of(context).enterUserOrAddress;
    // _memoHint = Z.of(context).enterMemo;

    // On amount focus change
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        if (_rawAmount != null) {
          setState(() {
            _amountController.text = getRawAsThemeAwareAmount(context, _rawAmount);
            _rawAmount = null;
          });
        }
        setState(() {
          _amountHint = "";
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
          if (_addressController.text.isNotEmpty) {
            _clearButton = true;
          } else {
            _clearButton = false;
          }
          _addressStyle = AddressStyle.TEXT60;
        });
        _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
        if (_addressController.text.isNotEmpty &&
            _addressController.text.length > 1 &&
            SendSheetHelpers.isSpecialAddress(_addressController.text)) {
          final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController.text);
          if (_addressController.text != formattedAddress && !SendSheetHelpers.isWellKnown(_addressController.text)) {
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
            _users = <User>[];
          });
        }
      } else {
        setState(() {
          _addressHint = Z.of(context).enterUserOrAddress;
          _users = <User>[];
          if (Address(_addressController.text).isValid()) {
            _addressValidAndUnfocused = true;
          }
          if (_addressController.text.isEmpty) {
            _pasteButtonVisible = true;
            _clearButton = false;
          }
        });

        if (SendSheetHelpers.stripPrefixes(_addressController.text).isEmpty) {
          setState(() {
            _addressController.text = "";
          });
          return;
        }
        // check if UD / ENS / opencap / onchain address:
        if (_addressController.text.isNotEmpty &&
            !_addressController.text.contains("★") &&
            !_addressController.text.startsWith(NonTranslatable.currencyPrefix)) {
          User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController.text);
          if (user == null) {
            if (!mounted) return;
            if (!_isSheetOpen) return;
            final bool? confirmed = await Sheets.showAppHeightSmallSheet(
              context: context,
              widget: ConfirmSheet(subtitle: Z.of(context).checkUsernameConfirmInfo),
              allowSlide: true,
            ) as bool?;

            if (confirmed == true) {
              user ??= await sl.get<UsernameService>().figureOutUsernameType(_addressController.text);
            }
          }

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
      locale: widget.localCurrency.getLocale().toString(),
      symbol: widget.localCurrency.getCurrencySymbol(),
    );

    qrWidget = widget.qrWidget;
  }

  @override
  Widget build(BuildContext context) {
    // The main column that holds everything
    return SafeArea(
      minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
      child: WillPopScope(
        onWillPop: () async {
          setState(() {
            _isSheetOpen = false;
          });
          return true;
        },
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
                      Sheets.showAppHeightNineSheet(
                          context: context,
                          widget: SplitBillSheet(
                            localCurrencyFormat: _localCurrencyFormat,
                          ));
                    },
                    icon: Icons.call_split,
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
                            CaseChange.toUpperCase(Z.of(context).requestFrom, context),
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
                  alignment: Alignment.center,
                  child: AppDialogs.infoButton(
                    context,
                    () {
                      AppDialogs.showInfoDialog(context, Z.of(context).requestSheetInfoHeader,
                          Z.of(context).requestSheetInfo.replaceAll("%1", NonTranslatable.appName));
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

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
                    child: Stack(
                      children: <Widget>[
                        // wallet / balance button:
                        Misc.walletBalanceButton(context, _localCurrencyMode),

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
                                                      if (_amountController.text.isEmpty) {
                                                        FocusScope.of(context).requestFocus(_amountFocusNode);
                                                      }
                                                      setState(() {
                                                        _isUser = true;
                                                        _showContactButton = false;
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
                  ),
                ),

                // A column for Enter Amount, Enter Address, Error containers and the pop up list
              ),
            ),

            //A column with Copy Address and Share Address buttons
            Column(
              children: <Widget>[
                // Row(
                //   children: <Widget>[
                //     AppButton.buildAppButton(
                //       context,
                //       // Share Address Button
                //       AppButtonType.PRIMARY_OUTLINE,
                //       Z.of(context).nearby,
                //       Dimens.BUTTON_BOTTOM_DIMENS,
                //       onPressed: () async {
                //         Sheets.showAppHeightNineSheet(
                //           context: context,
                //           widget: const NearbyDevicesSheet(),
                //         );
                //       },
                //     ),
                //   ],
                // ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context, AppButtonType.PRIMARY, Z.of(context).request, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      final bool validRequest = await _validateRequest();
                      if (!mounted) return;

                      if (!validRequest) {
                        return;
                      }
                      final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController.text);

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
                          if (!mounted) return;
                          amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
                        }
                      }

                      if (_isMaxSend()) {
                        if (!mounted) return;
                        amountRaw = StateContainer.of(context).wallet!.accountBalance.toString();
                      }

                      // verifies the input is a user in the db
                      if (SendSheetHelpers.isSpecialAddress(_addressController.text)) {
                        // Need to make sure its a valid contact or user
                        final User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController.text);
                        if (user == null) {
                          setState(() {
                            _addressValidationText =
                                SendSheetHelpers.getInvalidAddressMessage(context, _addressController.text);
                          });
                        } else {
                          Sheets.showAppHeightNineSheet(
                              context: context,
                              widget: RequestConfirmSheet(
                                amountRaw: amountRaw,
                                destination: user.address!,
                                contactName: user.getDisplayName(),
                                localCurrency: _localCurrencyMode ? _amountController.text : null,
                                memo: _memoController.text,
                              ));
                        }
                      } else if (_addressController.text.contains(".") || _addressController.text.contains(r"$")) {
                        String? address;

                        // check if UD domain:
                        address = await sl.get<UsernameService>().checkUnstoppableDomain(_addressController.text);
                        address ??= await sl.get<UsernameService>().checkENSDomain(_addressController.text);
                        address ??= await sl.get<UsernameService>().checkOpencapDomain(_addressController.text);

                        if (!mounted) return;

                        if (address == null) {
                          _addressValidationText = Z.of(context).domainInvalid;
                        }
                      } else {
                        Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: RequestConfirmSheet(
                                amountRaw: amountRaw,
                                destination: _addressController.text,
                                localCurrency: _localCurrencyMode ? _amountController.text : null,
                                memo: _memoController.text));
                      }
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).showAddress, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () async {
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
                          if (!mounted) return;
                          amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
                        }
                      }
                      Sheets.showAppHeightEightSheet(
                        context: context,
                        widget: ReceiveShowQRSheet(
                          localCurrency: widget.localCurrency,
                          address: widget.address,
                          qrWidget: widget.qrWidget,
                          amountRaw: amountRaw,
                        ),
                      );
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

  void redrawQrCode() {
    String? raw;
    if (_localCurrencyMode) {
      _lastLocalCurrencyAmount = _amountController.text;
      _lastCryptoAmount = sanitizedAmount(_localCurrencyFormat,
          convertLocalCurrencyToLocalizedCrypto(context, _localCurrencyFormat, _amountController.text));
      if (_lastCryptoAmount.isNotEmpty) {
        raw = NumberUtil.getAmountAsRaw(_lastCryptoAmount);
      }
    } else {
      raw = _amountController.text.isNotEmpty
          ? NumberUtil.getAmountAsRaw(_amountController.text
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

  Future<bool> showNeedVerificationAlert() async {
    switch (await showDialog<int>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
      // case 1:

      //   // go to qr code
      //   if (receive == null) {
      //     return false;
      //   }
      //   Navigator.of(context).pop();
      //   // TODO: BACKLOG: this is a roundabout solution to get the qr code to show up
      //   // probably better to do with an event bus
      //   Sheets.showAppHeightNineSheet(context: context, widget: receive!);
      //   return true;
      default:
        return false;
    }
  }

  /// Validate form data to see if valid
  /// @returns true if valid, false otherwise
  Future<bool> _validateRequest() async {
    bool isValid = true;
    _amountFocusNode.unfocus();
    _addressFocusNode.unfocus();
    _memoFocusNode.unfocus();
    // Validate amount
    if (_amountController.text.trim().isEmpty) {
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
    // final bool isPhoneNumber = _isPhoneNumber(_addressController!.text);
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

      if ((_memoController.text.isNotEmpty && _addressController.text.isNotEmpty) && !notificationsEnabled) {
        final bool notificationTurnedOn = await SendSheetHelpers.showNotificationDialog(context);
        if (!notificationTurnedOn) {
          isValid = false;
        } else {
          // not sure why this is needed to get it to update:
          // probably event bus related:
          await sl.get<SharedPrefsUtil>().setNotificationsOn(true);
        }
      }

      if (isValid) {
        // still valid && you have to have a nautilus username to send requests:
        if (StateContainer.of(context).wallet!.user == null &&
            StateContainer.of(context).wallet!.confirmationHeight < _REQUIRED_CONFIRMATION_HEIGHT) {
          isValid = false;
          await showNeedVerificationAlert();
        }
      }

      // if (isValid && sl.get<AccountService>().fallbackConnected) {
      //   if (_memoController!.text.trim().isNotEmpty) {
      //     isValid = false;
      //     // await showFallbackConnectedAlert();
      //   }
      // }
    }
    return isValid;
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  Widget getEnterAmountContainer() {
    double margin = 200;
    if (_addressController.text.startsWith(NonTranslatable.currencyPrefix)) {
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

        redrawQrCode();
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
      fadeSuffixOnCondition: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (String text) {
        if (_addressController.text.isEmpty) {
          FocusScope.of(context).requestFocus(_addressFocusNode);
        }
      },
    );
  } //************ Enter Amount Container Method End ************//
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
        textInputAction: _memoController.text.isEmpty ? TextInputAction.next : TextInputAction.done,
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
                    _addressController.text = scanResult;
                    _addressValidationText = "";
                    _addressValidAndUnfocused = true;
                  });
                  _addressFocusNode.unfocus();
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
                _addressController.text = "";
                _users = <User>[];
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
                      _pasteButtonVisible = false;
                      _showContactButton = false;
                    });
                    _addressController.text = address.address!;
                    _addressFocusNode.unfocus();
                    setState(() {
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
                      _pasteButtonVisible = false;
                      _showContactButton = false;
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
          final bool isNano = text.startsWith(NonTranslatable.currencyPrefix);

          // prevent spaces:
          if (text.contains(" ")) {
            text = text.replaceAll(" ", "");
            _addressController.text = text;
            _addressController.selection =
                TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
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

          if (text.isNotEmpty && text.startsWith(NonTranslatable.currencyPrefix)) {
            isUser = false;
          }

          if (text.isNotEmpty && text.contains(".")) {
            isUser = false;
          }

          // check if it's a real nano address:
          if (text.isEmpty) {
            setState(() {
              _isUser = false;
              _users = [];
            });
          } else if (isFavorite) {
            final List<User> matchedList =
                await sl.get<DBHelper>().getContactsWithNameLike(SendSheetHelpers.stripPrefixes(text));
            final Set<String?> nicknames = {};
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
    if (_addressController.text.startsWith(NonTranslatable.currencyPrefix)) {
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
