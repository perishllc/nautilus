import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_cron/easy_cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/scheduled.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/util/confirm_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/misc.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/numberutil.dart';

class AddScheduledSheet extends StatefulWidget {
  const AddScheduledSheet({required this.localCurrency}) : super();

  final AvailableCurrency localCurrency;

  @override
  AddScheduledSheetState createState() => AddScheduledSheetState();
}

class AddScheduledSheetState extends State<AddScheduledSheet> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _frequencyFocusNode = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();

  List<User> _users = [];
  bool? animationOpen;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a username is being entered
  bool _isUser = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;
  bool _clearButton = false;

  String _nameValidationText = "";
  String _amountValidationText = "";
  String _addressValidationText = "";
  String _timestampValidationText = "";
  int _timestamp = 0;

  bool _localCurrencyMode = false;
  late NumberFormat _localCurrencyFormat;
  AddressStyle _addressStyle = AddressStyle.TEXT60;

  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";

  final TextEditingController _cronController = TextEditingController();
  final String _valueChanged = '';
  final String _valueToValidate = '';
  final String _valueSaved = '';

  bool _isSheetOpen = true;

  @override
  void initState() {
    super.initState();

    // On amount focus change
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        setState(() {
          _amountValidationText = "";
        });
      }
    });
    // On address focus change
    _addressFocusNode.addListener(() async {
      if (_addressFocusNode.hasFocus) {
        setState(() {
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
            _users = [];
          });
        }
      } else {
        setState(() {
          // _addressHint = Z.of(context).enterUserOrAddress;
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

    _frequencyFocusNode.addListener(() async {
      if (_frequencyFocusNode.hasFocus) {
        setState(() {
          _timestampValidationText = "";
        });
      }
    });

    _nameFocusNode.addListener(() async {
      if (_nameFocusNode.hasFocus) {
        setState(() {
          _nameValidationText = "";
        });
      }
    });

    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(
        locale: widget.localCurrency.getLocale().toString(), symbol: widget.localCurrency.getCurrencySymbol());
    // // State initializationrue;
    // _addressValid = false;
    // _pasteButtonVisible = true;
    // _addressValidAndUnfocused = false;
    // _addressValidationText = "";
    // _users = <User>[];
    // // Add focus listeners
    // // On address focus change
    // _addressFocusNode!.addListener(() async {
    // });
  }

  // /// Return true if textfield should be shown, false if colorized should be shown
  // bool _shouldShowTextField() {
  //   if (widget.address != null) {
  //     return false;
  //   } else if (_addressValidAndUnfocused) {
  //     return false;
  //   }
  //   return true;
  // }

  Widget getEnterNameContainer() {
    return AppTextField(
      topMargin: 30,
      textAlign: TextAlign.center,
      focusNode: _nameFocusNode,
      controller: _nameController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [LengthLimitingTextInputFormatter(60)],
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: Z.of(context).enterName,
      fadePrefixOnCondition: true,
      // prefixShowFirstCondition: _pasteHttpButton,
      // fadeSuffixOnCondition: true,
      // suffixShowFirstCondition: _pasteHttpButton,
      // style: _addressStyle == AddressStyle.TEXT60
      //     ? AppStyles.textStyleAddressText60(context)
      //     : _addressStyle == AddressStyle.TEXT90
      //         ? AppStyles.textStyleAddressText90(context)
      //         : AppStyles.textStyleAddressPrimary(context),
      style: AppStyles.textStyleAddressText90(context),
      onChanged: (String text) async {
        // Always reset the error message to be less annoying
        if (_nameValidationText.isNotEmpty) {
          setState(() {
            _nameValidationText = "";
          });
        }
      },
    );
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
        });
      },
      textInputAction: TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      hintText: Z.of(context).enterAmount,
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
      ),
      // fadeSuffixOnCondition: true,
      // suffixShowFirstCondition: !_isMaxSend(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      // onSubmitted: (String text) {
      //   FocusScope.of(context).unfocus();
      //   if (!Address(_addressController.text).isValid()) {
      //     FocusScope.of(context).requestFocus(_addressFocusNode);
      //   }
      // },
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
        textInputAction: TextInputAction.next,
        maxLines: null,
        autocorrect: false,
        hintText: Z.of(context).enterUserOrAddress,
        // prefixButton: TextFieldButton(
        //   icon: AppIcons.scan,
        //   onPressed: () async {
        //     await _scanQR();
        //   },
        // ),
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
          FocusScope.of(context).unfocus();
          if (_amountController.text.isEmpty) {
            FocusScope.of(context).requestFocus(_amountFocusNode);
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

  Widget getEnterFrequencyContainer() {
    double margin = 280;
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
      textAlign: TextAlign.center,
      focusNode: _frequencyFocusNode,
      controller: _frequencyController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [LengthLimitingTextInputFormatter(60)],
      textInputAction: TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      hintText: Z.of(context).enterFrequency,
      fadePrefixOnCondition: true,
      style: AppStyles.textStyleAddressText90(context),
      onChanged: (String text) async {
        // Always reset the error message to be less annoying
        if (_timestampValidationText.isNotEmpty) {
          setState(() {
            _timestampValidationText = "";
          });
        }
      },
    );
  }

  Future<void> pickTime() async {
    _timestampValidationText = "";
    // final DateTime? pickedDate = await showRoundedDatePicker(
    //   context: context,
    //   height: 300,
    //   initialDate: _timestamp != 0 ? DateTime.fromMillisecondsSinceEpoch(_timestamp * 1000) : DateTime.now(),
    //   firstDate: DateTime(DateTime.now().hour + 1),
    //   lastDate: DateTime(DateTime.now().year + 3),
    //   theme: ThemeData(
    //     dialogBackgroundColor: StateContainer.of(context).curTheme.backgroundDarkest,
    //     primaryColor: StateContainer.of(context).curTheme.primary,
    //     textTheme: TextTheme(
    //       bodyLarge: TextStyle(
    //         color: StateContainer.of(context).curTheme.text,
    //       ),
    //       bodyMedium: TextStyle(
    //         color: StateContainer.of(context).curTheme.text,
    //       ),
    //       bodySmall: TextStyle(
    //         color: StateContainer.of(context).curTheme.primary60,
    //       ),
    //     ),
    //   ),
    // );
    DateTime? pickedDate = DateTime.now();
    // await CupertinoRoundedDatePicker.show(
    //   context,
    //   fontFamily: "Mali",
    //   textColor: StateContainer.of(context).curTheme.text!,
    //   background: StateContainer.of(context).curTheme.background!,
    //   borderRadius: 16,
    //   initialDatePickerMode: CupertinoDatePickerMode.time,
    //   use24hFormat: true,
    //   initialDate: _timestamp != 0 ? DateTime.fromMillisecondsSinceEpoch(_timestamp * 1000) : DateTime.now(),
    //   onDateTimeChanged: (DateTime newDateTime) {
    //     pickedDate = newDateTime;
    //   },
    // );
    if (!mounted) return;
    if (pickedDate != null) {
      // final TimeOfDay? pickedTime = await showRoundedTimePicker(
      //   context: context,
      //   initialTime: _timestamp != 0
      //       ? TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(_timestamp * 1000))
      //       : TimeOfDay.now(),
      //   theme: ThemeData(
      //     dialogBackgroundColor: StateContainer.of(context).curTheme.backgroundDarkest,
      //     primaryColor: StateContainer.of(context).curTheme.primary,
      //     textTheme: TextTheme(
      //       bodyLarge: TextStyle(
      //         color: StateContainer.of(context).curTheme.text,
      //       ),
      //       bodyMedium: TextStyle(
      //         color: StateContainer.of(context).curTheme.text,
      //       ),
      //       bodySmall: TextStyle(
      //         color: StateContainer.of(context).curTheme.text,
      //       ),
      //     ),
      //   ),
      // );
      // TimeOfDay? pickedTime = TimeOfDay.now();
      // await CupertinoRoundedDatePicker.show(
      //   context,
      //   fontFamily: "Mali",
      //   textColor: StateContainer.of(context).curTheme.text!,
      //   background: StateContainer.of(context).curTheme.background!,
      //   borderRadius: 16,
      //   initialDatePickerMode: CupertinoDatePickerMode.time,
      //   use24hFormat: true,
      //   initialDate: _timestamp != 0 ? DateTime.fromMillisecondsSinceEpoch(_timestamp * 1000) : DateTime.now(),
      //   onDateTimeChanged: (DateTime newDateTime) {
      //     pickedTime = TimeOfDay.fromDateTime(newDateTime);
      //   },
      // );

      DateTime? pickedDateTime = await showOmniDateTimePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
        lastDate: DateTime.now().add(
          const Duration(days: 3652),
        ),
        is24HourMode: true,
        isShowSeconds: false,
        minutesInterval: 1,
        secondsInterval: 1,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: StateContainer.of(context).curTheme.primary,
          brightness: StateContainer.of(context).curTheme.brightness,
          // colorScheme: ColorScheme.fromSwatch().copyWith(
          // //   secondary: StateContainer.of(context).curTheme.primary10,
          //   brightness: StateContainer.of(context).curTheme.brightness,
          // //   error: StateContainer.of(context).curTheme.error,
          //   primary: StateContainer.of(context).curTheme.primary,
          // //   background: StateContainer.of(context).curTheme.background,
          // //   tertiary: StateContainer.of(context).curTheme.warning,

          // ),
        ),
        type: OmniDateTimePickerType.dateAndTime,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        constraints: const BoxConstraints(
          maxWidth: 350,
          maxHeight: 650,
        ),
        transitionBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget child) {
          return FadeTransition(
            opacity: anim1.drive(
              Tween(
                begin: 0,
                end: 1,
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        selectableDayPredicate: (DateTime dateTime) {
          // disable dates before today:
          return dateTime.isAfter(DateTime.now().subtract(const Duration(days: 1)));
        },
      );

      if (pickedDateTime != null) {
        // final DateTime finalDateTime = DateTime(
        //   pickedDate?.year ?? 0,
        //   pickedDate?.month ?? 0,
        //   pickedDate?.day ?? 0,
        //   pickedTime?.hour ?? 0,
        //   pickedTime?.minute ?? 0,
        // );
        final DateTime finalDateTime = pickedDateTime!;
        setState(() {
          _timestamp = finalDateTime.millisecondsSinceEpoch ~/ 1000;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
      child: SafeArea(
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
              // Top row of the sheet which contains the header and the scan qr button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Empty SizedBox
                  const SizedBox(
                    width: 60,
                    height: 60,
                  ),
                  // The header of the sheet
                  Container(
                    margin: EdgeInsets.zero,
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                    child: Column(
                      children: <Widget>[
                        Handlebars.horizontal(
                          context,
                          margin: const EdgeInsets.only(top: 10, bottom: 15),
                        ),
                        AutoSizeText(
                          CaseChange.toUpperCase(Z.of(context).schedulePayment, context),
                          style: AppStyles.textStyleHeader(context),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          stepGranularity: 0.1,
                        ),
                      ],
                    ),
                  ),

                  // Scan QR Button
                  const SizedBox(width: 60, height: 60),
                ],
              ),

              // The main container that holds "Enter Name" and "Enter Address" text fields
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  child: GestureDetector(
                    onTap: () {
                      // Clear focus of our fields when tapped in this empty space
                      _nameFocusNode.unfocus();
                      _amountFocusNode.unfocus();
                      _addressFocusNode.unfocus();
                      _frequencyFocusNode.unfocus();
                    },
                    child: KeyboardAvoider(
                      duration: Duration.zero,
                      autoScroll: true,
                      focusPadding: 40,
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              // // Column for Enter Name container + Enter Name Error container
                              // Column(
                              //   children: [
                              //     getEnterNameContainer(),
                              //     Container(
                              //       alignment: AlignmentDirectional.center,
                              //       margin: const EdgeInsets.only(top: 3),
                              //       child: Text(_nameValidationText,
                              //           style: TextStyle(
                              //             fontSize: 14.0,
                              //             color: StateContainer.of(context).curTheme.primary,
                              //             fontFamily: "NunitoSans",
                              //             fontWeight: FontWeight.w600,
                              //           )),
                              //     ),
                              //   ],
                              // ),

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
                                                          return Misc.buildUserItem(context, _users[index], true,
                                                              (User user) {
                                                            _addressController!.text =
                                                                user.getDisplayName(ignoreNickname: true)!;
                                                            _addressFocusNode!.unfocus();
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

                                  // Enter Address Error Container
                                  Container(
                                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                                    child: Text(_addressValidationText,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: StateContainer.of(context).curTheme.primary,
                                          fontFamily: "NunitoSans",
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ],
                              ),
                              // const Text(
                              //   'CronFormField data readable value:',
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),

                              // Column for Enter Amount container + Enter Amount Error container
                              Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topCenter,
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: <Widget>[
                                        getEnterAmountContainer(),
                                      ],
                                    ),
                                  ),
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
                                ],
                              ),

                              // // frequency container:
                              // Column(
                              //   children: [
                              //     Container(
                              //       alignment: Alignment.topCenter,
                              //       margin: EdgeInsets.only(
                              //         left: MediaQuery.of(context).size.width * 0.105,
                              //         right: MediaQuery.of(context).size.width * 0.105,
                              //         top: 300,
                              //       ),
                              //       child: CronFormField(
                              //         // controller: _cronController,
                              //         initialValue: "0 0 1 * *", // the first of every month
                              //         labelText: Z.of(context).schedule,
                              //         onChanged: (String val) => setState(() => _valueChanged = val),
                              //         validator: (String? val) {
                              //           setState(() => _valueToValidate = val ?? '');
                              //           return null;
                              //         },
                              //         onSaved: (String? val) => setState(() => _valueSaved = val ?? ''),
                              //         // outputFormat: CronExpressionOutputFormat.AUTO,
                              //       ),
                              //     ),
                              //     const SizedBox(height: 10),
                              //     Text(CronExpression.fromString(_valueChanged).toReadableString()),
                              //     const SizedBox(height: 30),
                              //   ],
                              // ),
                            ],
                          ),
                          // Column for timestamp container + error container
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10), // spacer

                              // pick date and time button:
                              // Container(
                              //   alignment: Alignment.topCenter,
                              //   child: AppButton.buildAppButton(
                              //     context,
                              //     AppButtonType.PRIMARY,
                              //     Z.of(context).pickTime,
                              //     Dimens.BUTTON_TOP_DIMENS,
                              //     onPressed: pickTime,
                              //   ),
                              // ),

                              // pick a time text and button:
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.105),
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: pickTime,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Container(
                                        //   onp
                                        // )
                                        // pick time text:
                                        if (_timestamp == 0)
                                          Text(
                                            Z.of(context).pickTime,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: StateContainer.of(context).curTheme.text,
                                              fontFamily: "NunitoSans",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        else
                                          Container(
                                            alignment: AlignmentDirectional.center,
                                            margin: const EdgeInsets.only(top: 3),
                                            child: Text(
                                                DateFormat("EEEE, MMMM d, yyyy, h:mm a")
                                                    .format(DateTime.fromMillisecondsSinceEpoch(_timestamp * 1000)),
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: StateContainer.of(context).curTheme.primary,
                                                  fontFamily: "NunitoSans",
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                alignment: AlignmentDirectional.center,
                                margin: const EdgeInsets.only(top: 3),
                                child: Text(_timestampValidationText,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: StateContainer.of(context).curTheme.primary,
                                      fontFamily: "NunitoSans",
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //A column with "Add Contact" and "Close" buttons
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Add Contact Button
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, Z.of(context).schedulePayment, Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () async {
                        if (!await validateForm()) {
                          return;
                        }

                        if (!mounted) return;

                        final String amountRaw = SendSheetHelpers.getAmountRaw(
                          context,
                          _localCurrencyFormat,
                          _amountController,
                          _localCurrencyMode,
                        );

                        late String finalAddress;

                        if (SendSheetHelpers.isSpecialAddress(_addressController.text)) {
                          // Need to make sure its a valid contact or user
                          final User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController.text);
                          if (user == null) {
                            setState(() {
                              _addressValidationText =
                                  SendSheetHelpers.getInvalidAddressMessage(context, _addressController.text);
                            });
                            return;
                          } else {
                            finalAddress = user.address!;
                          }
                        } else {
                          finalAddress = _addressController.text;
                        }

                        final Scheduled sched = Scheduled(
                          // label: _nameController.text,
                          amount_raw: amountRaw,
                          timestamp: _timestamp,
                          address: finalAddress,
                          active: true,
                          paid: false,
                        );
                        if (!mounted) return;
                        Navigator.of(context).pop(sched);

                        // if (await validateForm()) {
                        //   final String formAddress = widget.address ?? _amountController!.text;
                        //   // if we're given an address with corresponding username, just block:
                        //   if (_correspondingUsername != null) {
                        //     Navigator.of(context).pop(formAddress);
                        //   } else if (_correspondingAddress != null) {
                        //     Navigator.of(context).pop(_correspondingAddress);
                        //   } else {
                        //     // just an address:
                        //     Navigator.of(context).pop(formAddress);
                        //   }
                        // }
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Close Button
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
                          onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> validateForm() async {
    bool isValid = true;

    // // validate name
    // if (_nameController.text.isEmpty) {
    //   setState(() {
    //     _nameValidationText = Z.of(context).nameEmpty;
    //   });
    //   isValid = false;
    // } else {
    //   setState(() {
    //     _nameValidationText = "";
    //   });
    // }

    // validate amount
    if (_amountController.text.isEmpty || _amountController.text == "0") {
      setState(() {
        _amountValidationText = Z.of(context).amountMissing;
      });
      isValid = false;
    } else {
      setState(() {
        _amountValidationText = "";
      });
    }

    // validate address
    final bool isUser = _addressController.text.startsWith("@") || _addressController.text.startsWith("#");
    final bool isFavorite = _addressController.text.startsWith("★");
    final bool isDomain = _addressController.text.contains(".") || _addressController.text.contains(r"$");
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

    // validate timestamp
    if (_timestamp == 0) {
      setState(() {
        _timestampValidationText = Z.of(context).timestampEmpty;
      });
      isValid = false;
      // check if time is in the future:
    } else if (_timestamp < (DateTime.now().millisecondsSinceEpoch ~/ 1000)) {
      setState(() {
        _timestampValidationText = Z.of(context).timestampInPast;
      });
      isValid = false;
    }

    // if (_frequencyController.text.isEmpty) {
    //   setState(() {
    //     _timestampValidationText = Z.of(context).frequencyEmpty;
    //   });
    //   isValid = false;
    // } else {
    //   try {
    //     UnixCronParser().parse(_frequencyController.text);
    //   } catch (e) {
    //     setState(() {
    //       _timestampValidationText = Z.of(context).invalidFrequency;
    //     });
    //     isValid = false;
    //   }
    // }

    if (isValid) {
      setState(() {
        _timestampValidationText = "";
      });
    }

    return isValid;
  }
}
