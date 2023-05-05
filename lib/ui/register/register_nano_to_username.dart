import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/register/register_nano_to_confirm_sheet.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';

// class LeaseOption {
//   final String key;
//   final String leaseLength;
//   final String nanoAmount;

//   LeaseOption(this.key, this.leaseLength, this.nanoAmount);

//   // static List<LeaseOption> get allCountries => [

//   //     ];
// }

class RegisterNanoToUsernameScreen extends StatefulWidget {
  @override
  _RegisterNanoToUsernameScreenState createState() => _RegisterNanoToUsernameScreenState();
}

class _RegisterNanoToUsernameScreenState extends State<RegisterNanoToUsernameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FocusNode? _usernameFocusNode;
  TextEditingController? _usernameController;

  // States
  AddressStyle? _usernameStyle;
  final String _usernameHint = "";
  String _usernameValidationText = "";
  bool _showRegisterButton = false;
  Map? _leaseDetails;
  // int _leaseSelected = 0;
  String? _leaseSelected = "2 Days";
  int _leaseSelectedIndex = 0;
  // Used to replace address textfield with colorized TextSpan
  bool _usernameValidAndUnfocused = false;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode = FocusNode();
    _usernameController = TextEditingController();
    _usernameStyle = AddressStyle.TEXT60;

    // quickSendAmount = widget.quickSendAmount;

    // On username focus change
    _usernameFocusNode!.addListener(() {
    });
    // Set initial state of copy button
    // _addressCopied = false;
    // Create our SVG-heavy things in the constructor because they are slower operations
    // Share card initialization
    // shareCardKey = GlobalKey();
    // _showShareCard = false;
  }

  Widget getDropdown() {
    final List<DropdownMenuItem<String>> dropdownItems = [];

    if (_leaseDetails == null) {
      return Container();
    }

    for (int i = 0; i < (_leaseDetails!["plans"] as List<dynamic>).length; i++) {
      dropdownItems.add(DropdownMenuItem(
        onTap: () => {
          setState(() {
            _usernameValidationText = "";
          })
        },
        value: "${_leaseDetails!["plans"][i]["title"]}",
        child: Text(
          "${_leaseDetails!["plans"][i]["title"]}",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ));
    }

    return Container(
        margin: const EdgeInsetsDirectional.only(end: 25),
        child: DropdownButton(
          value: _leaseSelected,
          items: dropdownItems,
          onChanged: (String? value) {
            setState(() {
              _leaseSelected = value;
            });
          },
        ));
  }

  Widget getPrice() {
    if (_leaseDetails == null) {
      return Container();
    }

    // go through the plans to find the one that matches the selected duration:
    for (int i = 0; i < (_leaseDetails!["plans"] as List<dynamic>).length; i++) {
      if (_leaseDetails!["plans"][i]["title"] == _leaseSelected) {
        _leaseSelectedIndex = i;
        break;
      }
    }

    String? price;
    if (_leaseDetails!["plans"][_leaseSelectedIndex]["value_raw"] != null) {
      price = _leaseDetails!["plans"][_leaseSelectedIndex]["value_raw"] as String?;
    } else {
      return Container();
    }

    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        text: '',
        children: [
          TextSpan(
            text: getThemeAwareRawAccuracy(context, price),
            style: AppStyles.textStyleTransactionAmount(context),
          ),
          displayCurrencySymbol(
            context,
            AppStyles.textStyleTransactionAmount(context),
          ),
          TextSpan(
            text: getRawAsThemeAwareAmount(context, price),
            style: AppStyles.textStyleTransactionAmount(
              context,
            ),
          ),
        ],
      ),
    );

    // return Text(
    //   "Price: ${_leaseDetails["plans"][selectedPlanIndex]["amount_raw"]}",
    //   style: TextStyle(
    //     fontSize: 14,
    //     fontWeight: FontWeight.w600,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
          minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              //A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
              Expanded(
                child: KeyboardAvoider(
                  duration: Duration.zero,
                  autoScroll: true,
                  focusPadding: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          if (StateContainer.of(context).wallet!.username == null)
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 50,
                              width: 50,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: StateContainer.of(context).curTheme.text15,
                                    backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child:
                                      Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                            ),

                          // Safety icon
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Icon(
                              AppIcons.contact,
                              size: 60,
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
                          bottom: 25,
                        ),
                        alignment: AlignmentDirectional.center,
                        child: AutoSizeText(
                          Z.of(context).registerUsernameHeader,
                          style: AppStyles.textStyleHeaderColored(context),
                          stepGranularity: 0.1,
                          maxLines: 1,
                          minFontSize: 12,
                        ),
                      ),
                      // The paragraph
                      Container(
                        margin: EdgeInsetsDirectional.only(
                            start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 15.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              Z.of(context).usernameInfo.replaceAll("%1", NonTranslatable.appName),
                              style: AppStyles.textStyleParagraph(context),
                              maxLines: 6,
                              stepGranularity: 0.5,
                            ),
                            Container(
                              margin: const EdgeInsetsDirectional.only(top: 15),
                              child: AutoSizeText(
                                Z.of(context).usernameWarning.replaceAll("%1", NonTranslatable.appName),
                                style: AppStyles.textStyleParagraphPrimary(context),
                                maxLines: 2,
                                // maxFontSize: 14,
                                stepGranularity: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (StateContainer.of(context).wallet!.username != null)
                        Column(
                          children: <Widget>[
                            // The paragraph describing we already have a username:
                            Container(
                              margin: EdgeInsetsDirectional.only(
                                  start: smallScreen(context) ? 30 : 40,
                                  end: smallScreen(context) ? 30 : 40,
                                  top: 45.0),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: <Widget>[
                                  AutoSizeText(
                                    Z.of(context).usernameAlreadyRegistered,
                                    style: AppStyles.textStyleParagraph(context),
                                    maxLines: 6,
                                    stepGranularity: 0.5,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
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
                              margin: const EdgeInsets.only(top: 20),
                              child: Text(_usernameValidationText,
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
                    ],
                  ),
                ),
              ),
              if (_showRegisterButton)
                Container(
                    margin: const EdgeInsetsDirectional.only(bottom: 50),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                      getDropdown(),
                      getPrice(),
                    ])),
              if (StateContainer.of(context).wallet!.username != null)
                Container(
                  margin: const EdgeInsetsDirectional.only(top: 10),
                  child: Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        Z.of(context).close,
                        Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () {
                          // go back:
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                )
              else
                (!_showRegisterButton)
                    ? // Check availability button
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).checkAvailability,
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                            final String username = _usernameController!.text.replaceAll("@", "");
                            if (_usernameController!.text.isEmpty) {
                              setState(() {
                                _usernameValidationText = Z.of(context).usernameEmpty;
                              });
                              return;
                            }
                            final Map<String, dynamic> resp = await sl
                                .get<UsernameService>()
                                .checkNanoToUsernameAvailability(username) as Map<String, dynamic>;
                            if (resp == null) {
                              setState(() {
                                _usernameValidationText = Z.of(context).usernameError;
                              });
                              return;
                            }
                            if (resp["available"] == true) {
                              setState(() {
                                _leaseDetails = resp;
                                _usernameValidationText = Z.of(context).usernameAvailable;
                                _showRegisterButton = true;
                              });
                            } else if (resp["available"] == false) {
                              setState(() {
                                _usernameValidationText = Z.of(context).usernameUnavailable;
                              });
                            } else if (resp["message"] != null) {
                              setState(() {
                                _usernameValidationText = Z.of(context).usernameInvalid;
                              });
                            } else {
                              setState(() {
                                _usernameValidationText = Z.of(context).usernameError;
                              });
                            }
                          }),
                        ],
                      )
                    : // register username button
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).registerUsername,
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                            final String username = _usernameController!.text.replaceAll("@", "");

                            String? price;
                            if (_leaseDetails!["plans"][_leaseSelectedIndex]["value_raw"] != null) {
                              price = _leaseDetails!["plans"][_leaseSelectedIndex]["value_raw"] as String?;
                            } else {
                              return Container();
                            }

                            final BigInt balanceRaw = StateContainer.of(context).wallet!.accountBalance;
                            final BigInt sendAmount = BigInt.tryParse(price!)!;
                            if (sendAmount > balanceRaw) {
                              setState(() {
                                _usernameValidationText = Z.of(context).insufficientBalance;
                              });
                            } else {
                              final String? destination = _leaseDetails!["address"] as String?;
                              if (destination == null) {
                                return Container();
                              }
                              // build the transaction:
                              Sheets.showAppHeightNineSheet(
                                  context: context,
                                  widget: RegisterNanoToConfirmSheet(
                                    // localCurrency: StateContainer.of(context).curCurrency,
                                    // contact: contact,
                                    destination: destination,
                                    // quickSendAmount: item.amount,
                                    amountRaw: price,
                                    username: username,
                                    checkUrl: _leaseDetails!["check_url"] as String?,
                                    leaseDuration: _leaseDetails!["plans"][_leaseSelectedIndex]["title"] as String?,
                                  ));
                            }
                          }),
                        ],
                      ),
            ],
          ),
        ),
      ),
    );
  }

  //************ Enter Address Container Method ************//
  //*******************************************************//
  Widget getEnterAddressContainer() {
    return AppTextField(
        topMargin: MediaQuery.of(context).size.height * 0.05,
        padding:
            _usernameValidAndUnfocused ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
        textAlign: TextAlign.center,
        focusNode: _usernameFocusNode,
        controller: _usernameController,
        cursorColor: StateContainer.of(context).curTheme.primary,
        inputFormatters: [LengthLimitingTextInputFormatter(20)],
        textInputAction: TextInputAction.done,
        maxLines: null,
        autocorrect: false,
        hintText: _usernameHint == null ? "" : Z.of(context).enterUsername,
        fadePrefixOnCondition: true,
        style: _usernameStyle == AddressStyle.TEXT60
            ? AppStyles.textStyleAddressText60(context)
            : _usernameStyle == AddressStyle.TEXT90
                ? AppStyles.textStyleAddressText90(context)
                : AppStyles.textStyleAddressPrimary(context),
        onChanged: (String text) {
          final bool isUser = text.startsWith("@");
          final bool isFavorite = text.startsWith("★");
          final bool isNano = text.startsWith(NonTranslatable.currencyPrefix);

          // prevent spaces:
          if (text.contains(" ")) {
            text = text.replaceAll(" ", "");
            _usernameController!.text = text;
            _usernameController!.selection =
                TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
          }

          if (text.isNotEmpty) {
            //   setState(() {
            //     _showContactButton = false;
            //   });
            // } else {
            //   setState(() {
            //     _showContactButton = true;
            //   });
          }
          // add the @ back in:
          if (text.isNotEmpty && !isUser && !isNano && !isFavorite) {
            // add @ to the beginning of the string:
            _usernameController!.text = "@$text";
            _usernameController!.selection =
                TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
          }

          if (text.isNotEmpty && text.startsWith("@nano_")) {
            setState(() {
              // remove the @ from the beginning of the string:
              _usernameController!.text =
                  text.replaceFirst("@${NonTranslatable.currencyPrefix}", NonTranslatable.currencyPrefix);
              _usernameController!.selection =
                  TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
            });
          }
          // Always reset the error message to be less annoying
          setState(() {
            _showRegisterButton = false;
            _usernameValidationText = "";
          });
        },
        overrideTextFieldWidget: _usernameValidAndUnfocused
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _usernameValidAndUnfocused = false;
                  });
                  Future.delayed(const Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(_usernameFocusNode);
                  });
                },
                child: UIUtil.threeLineAddressText(context, _usernameController!.text))
            : null);
  } //************ Enter Address Container Method End ************//
  //*************************************************************//
}
