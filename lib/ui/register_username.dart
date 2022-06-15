import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/ui/register/register_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';

import 'send/send_sheet.dart';

// class LeaseOption {
//   final String key;
//   final String leaseLength;
//   final String nanoAmount;

//   LeaseOption(this.key, this.leaseLength, this.nanoAmount);

//   // static List<LeaseOption> get allCountries => [

//   //     ];
// }

class RegisterUsernameScreen extends StatefulWidget {
  @override
  _RegisterUsernameScreenState createState() => _RegisterUsernameScreenState();
}

class _RegisterUsernameScreenState extends State<RegisterUsernameScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  FocusNode? _usernameFocusNode;
  TextEditingController? _usernameController;

  // States
  AddressStyle? _usernameStyle;
  String _usernameText = "";
  String _usernameHint = "";
  String _usernameValidationText = "";
  bool _showRegisterButton = false;
  Map? _leaseDetails;
  // int _leaseSelected = 0;
  String? _leaseSelected = "1 Day";
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
      // if (_usernameFocusNode.hasFocus) {
      //   setState(() {
      //     // _addressHint = null;
      //     // _addressValidAndUnfocused = false;
      //   });
      //   _requestAddressController.selection = TextSelection.fromPosition(TextPosition(offset: _requestAddressController.text.length));
      //   if (_requestAddressController.text.length > 0 && !_requestAddressController.text.startsWith("nano_")) {
      //     if (_requestAddressController.text.startsWith("@")) {
      //       sl.get<DBHelper>().getUsersWithNameLike(_requestAddressController.text.substring(1)).then((userList) {
      //         setState(() {
      //           _users = userList;
      //         });
      //       });
      //     } else if (_requestAddressController.text.startsWith("★")) {
      //       sl.get<DBHelper>().getContactsWithNameLike(_requestAddressController.text.substring(1)).then((userList) {
      //         setState(() {
      //           _users = userList;
      //         });
      //       });
      //     }
      //   }

      //   if (_requestAddressController.text.length == 0) {
      //     setState(() {
      //       _users = [];
      //     });
      //   }
      // } else {
      //   setState(() {
      //     _addressHint = "";
      //     _users = [];
      //     if (Address(_requestAddressController.text).isValid()) {
      //       _addressValidAndUnfocused = true;
      //     }
      //   });
      //   if (_requestAddressController.text.trim() == "@" || _requestAddressController.text.trim() == "★") {
      //     _requestAddressController.text = "";
      //     setState(() {
      //       _showContactButton = true;
      //     });
      //   }
      // }
    });
    // Set initial state of copy button
    // _addressCopied = false;
    // Create our SVG-heavy things in the constructor because they are slower operations
    // Share card initialization
    // shareCardKey = GlobalKey();
    // _showShareCard = false;
  }

  Widget getDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];

    if (_leaseDetails == null) {
      return Container();
    }

    for (var i = 0; i < _leaseDetails!["plans"].length; i++) {
      dropdownItems.add(DropdownMenuItem(
        onTap: () => {
          setState(() {
            _usernameValidationText = "";
          })
        },
        child: Text(
          "${_leaseDetails!["plans"][i]["name"]}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: "${_leaseDetails!["plans"][i]["name"]}",
      ));
    }

    return Container(
        margin: EdgeInsetsDirectional.only(end: 25),
        child: DropdownButton(
          value: _leaseSelected,
          items: dropdownItems,
          onChanged: (dynamic value) {
            setState(() {
              _leaseSelected = value;
            });
          },
        ));

    // return DropdownButton(
    //   items: _leaseDetails["plans"].forEach((dynamic item) => DropdownMenuItem<String>(child: Text(item), value: item)).toList(),
    //   onChanged: (String value) {
    //     setState(() {
    //       print("previous ${this._leaseSelected}");
    //       print("selected $value");
    //       _leaseSelected = value;
    //     });
    //   },
    //   value: _leaseSelected,
    // );
  }

  Widget getPrice() {
    if (_leaseDetails == null) {
      return Container();
    }

    // go through the plans to find the one that matches the selected duration:
    for (var i = 0; i < _leaseDetails!["plans"].length; i++) {
      if (_leaseDetails!["plans"][i]["name"] == _leaseSelected) {
        _leaseSelectedIndex = i;
        break;
      }
    }

    String? price;
    if (_leaseDetails!["plans"][_leaseSelectedIndex]["raw_amount"] != null) {
      price = _leaseDetails!["plans"][_leaseSelectedIndex]["raw_amount"];
    } else if (_leaseDetails!["plans"][_leaseSelectedIndex]["amount_raw"] != null) {
      price = _leaseDetails!["plans"][_leaseSelectedIndex]["amount_raw"];
    } else {
      return Container();
    }

    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        text: '',
        children: [
          displayCurrencyAmount(
              context,
              AppStyles.textStyleTransactionAmount(
                context,
                true,
              )),
          TextSpan(
            text: getCurrencySymbol(context) + getRawAsThemeAwareAmount(context, price),
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
        builder: (context, constraints) => SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              //A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
              Expanded(
                child: KeyboardAvoider(
                  duration: Duration(milliseconds: 0),
                  autoScroll: true,
                  focusPadding: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          (StateContainer.of(context).wallet!.username == null)
                              ?
                              // Back Button
                              Container(
                                  alignment: Alignment.centerLeft,
                                  height: 50,
                                  width: 50,
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        primary: StateContainer.of(context).curTheme.text15,
                                        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                        padding: EdgeInsets.all(0.0),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                                )
                              : SizedBox(),

                          // Safety icon
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(bottom: 15),
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
                        alignment: AlignmentDirectional(0, 0),
                        child: AutoSizeText(
                          AppLocalization.of(context)!.registerUsernameHeader,
                          style: AppStyles.textStyleHeaderColored(context),
                          stepGranularity: 0.1,
                          maxLines: 1,
                          minFontSize: 12,
                        ),
                      ),
                      // The paragraph
                      Container(
                        margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 15.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              AppLocalization.of(context)!.usernameInfo,
                              style: AppStyles.textStyleParagraph(context),
                              maxLines: 6,
                              stepGranularity: 0.5,
                            ),
                            Container(
                              margin: EdgeInsetsDirectional.only(top: 15),
                              child: AutoSizeText(
                                AppLocalization.of(context)!.usernameWarning,
                                style: AppStyles.textStyleParagraphPrimary(context),
                                maxLines: 2,
                                // maxFontSize: 14,
                                stepGranularity: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      (StateContainer.of(context).wallet!.username != null)
                          ? Column(
                              children: <Widget>[
                                // The paragraph describing we already have a username:
                                Container(
                                  margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 45.0),
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    children: <Widget>[
                                      AutoSizeText(
                                        AppLocalization.of(context)!.usernameAlreadyRegistered,
                                        style: AppStyles.textStyleParagraph(context),
                                        maxLines: 6,
                                        stepGranularity: 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          :
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
                                  margin: EdgeInsets.only(top: 20),
                                  child: Text(_usernameValidationText,
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
                ),
              ),
              (_showRegisterButton)
                  ? Container(
                      margin: EdgeInsetsDirectional.only(bottom: 50),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        getDropdown(),
                        getPrice(),
                      ]))
                  : SizedBox(),
              (StateContainer.of(context).wallet!.username != null)
                  ? Container(
                      margin: EdgeInsetsDirectional.only(top: 10),
                      child: Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY,
                            AppLocalization.of(context)!.close,
                            Dimens.BUTTON_TOP_DIMENS,
                            onPressed: () {
                              // go back:
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    )
                  : (!_showRegisterButton)
                      ? // Check availability button
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AppButton.buildAppButton(
                                context, AppButtonType.PRIMARY, AppLocalization.of(context)!.checkAvailability, Dimens.BUTTON_BOTTOM_DIMENS,
                                onPressed: () async {
                              String username = _usernameController!.text.replaceAll("@", "");
                              if (_usernameController!.text.isEmpty) {
                                setState(() {
                                  _usernameValidationText = AppLocalization.of(context)!.usernameEmpty;
                                });
                                return;
                              }
                              Map? resp = await (sl.get<AccountService>().checkUsernameAvailability(username) as FutureOr<Map<dynamic, dynamic>?>);
                              if (resp != null) {
                                if (resp["available"] == true) {
                                  setState(() {
                                    _leaseDetails = resp;
                                    _usernameValidationText = AppLocalization.of(context)!.usernameAvailable;
                                    _showRegisterButton = true;
                                  });
                                } else if (resp["available"] == false) {
                                  setState(() {
                                    _usernameValidationText = AppLocalization.of(context)!.usernameUnavailable;
                                  });
                                } else if (resp["status"] == "Invalid") {
                                  setState(() {
                                    _usernameValidationText = AppLocalization.of(context)!.usernameInvalid;
                                  });
                                } else {
                                  setState(() {
                                    _usernameValidationText = AppLocalization.of(context)!.usernameError;
                                  });
                                }
                              }
                            }),
                          ],
                        )
                      : // register username button
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context)!.registerUsername, Dimens.BUTTON_BOTTOM_DIMENS,
                                onPressed: () async {
                              String username = _usernameController!.text.replaceAll("@", "");

                              String? price;
                              if (_leaseDetails!["plans"][_leaseSelectedIndex]["raw_amount"] != null) {
                                price = _leaseDetails!["plans"][_leaseSelectedIndex]["raw_amount"];
                              } else if (_leaseDetails!["plans"][_leaseSelectedIndex]["amount_raw"] != null) {
                                price = _leaseDetails!["plans"][_leaseSelectedIndex]["amount_raw"];
                              } else {
                                return Container();
                              }

                              BigInt balanceRaw = StateContainer.of(context).wallet!.accountBalance;
                              BigInt sendAmount = BigInt.tryParse(price!)!;
                              if (sendAmount > balanceRaw) {
                                setState(() {
                                  _usernameValidationText = AppLocalization.of(context)!.insufficientBalance;
                                });
                              } else {
                                // build the transaction:
                                Sheets.showAppHeightNineSheet(
                                    context: context,
                                    widget: RegisterConfirmSheet(
                                      // localCurrency: StateContainer.of(context).curCurrency,
                                      // contact: contact,
                                      destination: _leaseDetails!["plans"][_leaseSelectedIndex]["address"],
                                      // quickSendAmount: item.amount,
                                      amountRaw: price,
                                      username: username,
                                      checkUrl: _leaseDetails!["plans"][_leaseSelectedIndex]["check_url"],
                                      leaseDuration: _leaseDetails!["plans"][_leaseSelectedIndex]["name"],
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
  getEnterAddressContainer() {
    return AppTextField(
        topMargin: MediaQuery.of(context).size.height * 0.05,
        padding: _usernameValidAndUnfocused ? EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
        textAlign: TextAlign.center,
        focusNode: _usernameFocusNode,
        controller: _usernameController,
        cursorColor: StateContainer.of(context).curTheme.primary,
        inputFormatters: [LengthLimitingTextInputFormatter(20)],
        textInputAction: TextInputAction.done,
        maxLines: null,
        autocorrect: false,
        hintText: _usernameHint == null ? "" : AppLocalization.of(context)!.enterUsername,
        fadePrefixOnCondition: true,
        style: _usernameStyle == AddressStyle.TEXT60
            ? AppStyles.textStyleAddressText60(context)
            : _usernameStyle == AddressStyle.TEXT90
                ? AppStyles.textStyleAddressText90(context)
                : AppStyles.textStyleAddressPrimary(context),
        onChanged: (text) {
          bool? isUser = text.startsWith("@");
          bool? isFavorite = text.startsWith("★");
          bool? isNano = text.startsWith("nano_");

          // prevent spaces:
          if (text.contains(" ")) {
            text = text.replaceAll(" ", "");
            _usernameController!.text = text;
            _usernameController!.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
          }

          if (text.length > 0) {
            //   setState(() {
            //     _showContactButton = false;
            //   });
            // } else {
            //   setState(() {
            //     _showContactButton = true;
            //   });
          }
          // add the @ back in:
          if (text.length > 0 && !isUser! && !isNano! && !isFavorite!) {
            // add @ to the beginning of the string:
            _usernameController!.text = "@" + text;
            _usernameController!.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
            isUser = true;
          }

          if (text.length > 0 && text.startsWith("@nano_")) {
            setState(() {
              // remove the @ from the beginning of the string:
              _usernameController!.text = text.replaceFirst("@nano_", "nano_");
              _usernameController!.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
              isUser = false;
            });
          }

          // check if it's a real nano address:
          // bool isUser = !text.startsWith("nano_") && !text.startsWith("★");
          // if (text.length == 0) {
          //   setState(() {
          //     _isUser = false;
          //     _users = [];
          //   });
          // } else if (isUser) {
          //   setState(() {
          //     _isUser = true;
          //   });
          //   sl.get<DBHelper>().getUserSuggestionsWithNameLike(text.substring(1)).then((matchedList) {
          //     setState(() {
          //       _users = matchedList;
          //     });
          //   });
          // } else if (isFavorite) {
          //   setState(() {
          //     _isUser = true;
          //   });
          //   sl.get<DBHelper>().getContactsWithNameLike(text.substring(1)).then((matchedList) {
          //     setState(() {
          //       _users = matchedList;
          //     });
          //   });
          // } else {
          //   setState(() {
          //     _isUser = false;
          //     _users = [];
          //   });
          // }
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
                  Future.delayed(Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(_usernameFocusNode);
                  });
                },
                child: UIUtil.threeLineAddressText(context, _usernameController!.text))
            : null);
  } //************ Enter Address Container Method End ************//
  //*************************************************************//
}
