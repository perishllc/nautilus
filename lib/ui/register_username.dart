import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';

import 'send/send_sheet.dart';

// import 'package:flare_flutter/flare_actor.dart';
// import 'package:nautilus_wallet_flutter/dimens.dart';
// import 'package:nautilus_wallet_flutter/localization.dart';
// import 'package:nautilus_wallet_flutter/model/vault.dart';
// import 'package:nautilus_wallet_flutter/service_locator.dart';
// import 'package:nautilus_wallet_flutter/styles.dart';
// import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';

class RegisterUsernameScreen extends StatefulWidget {
  @override
  _RegisterUsernameScreenState createState() => _RegisterUsernameScreenState();
}

class _RegisterUsernameScreenState extends State<RegisterUsernameScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  FocusNode _usernameFocusNode;
  TextEditingController _usernameController;

  // States
  AddressStyle _usernameStyle;
  String _usernameText = "";
  String _usernameHint = "";
  String _usernameValidationText = "";
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
    _usernameFocusNode.addListener(() {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Back Button
                        Container(
                          margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 15 : 20),
                          height: 50,
                          width: 50,
                          child: FlatButton(
                              highlightColor: StateContainer.of(context).curTheme.text15,
                              splashColor: StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(0.0),
                              child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                      ],
                    ),
                    // Safety icon
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40,
                        top: 15,
                      ),
                      child: Icon(
                        AppIcons.security,
                        size: 60,
                        color: StateContainer.of(context).curTheme.primary,
                      ),
                    ),
                    // The header
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40,
                        end: smallScreen(context) ? 30 : 40,
                        top: 10,
                      ),
                      alignment: AlignmentDirectional(-1, 0),
                      child: AutoSizeText(
                        "TODO!",
                        style: AppStyles.textStyleHeaderColored(context),
                        stepGranularity: 0.1,
                        maxLines: 1,
                        minFontSize: 12,
                      ),
                    ),
                    // The paragraph
                    // Container(
                    //   margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 15.0),
                    //   alignment: Alignment.centerLeft,
                    //   child: Column(
                    //     children: <Widget>[
                    //       AutoSizeText(
                    //         AppLocalization.of(context).secretInfo,
                    //         style: AppStyles.textStyleParagraph(context),
                    //         maxLines: 5,
                    //         stepGranularity: 0.5,
                    //       ),
                    //       Container(
                    //         margin: EdgeInsetsDirectional.only(top: 15),
                    //         child: AutoSizeText(
                    //           AppLocalization.of(context).secretWarning,
                    //           style: AppStyles.textStyleParagraphPrimary(context),
                    //           maxLines: 4,
                    //           stepGranularity: 0.5,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
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
                                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                                alignment: Alignment.bottomCenter,
                                constraints: BoxConstraints(maxHeight: 174, minHeight: 0),
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

              // Next Screen Button
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).gotItButton, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
              //       Navigator.of(context).pushNamed('/intro_backup', arguments: StateContainer.of(context).encryptedSecret);
              //     }),
              //   ],
              // ),
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
        topMargin: 124,
        padding: _usernameValidAndUnfocused ? EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
        textAlign: TextAlign.center,
        focusNode: _usernameFocusNode,
        controller: _usernameController,
        cursorColor: StateContainer.of(context).curTheme.primary,
        inputFormatters: [LengthLimitingTextInputFormatter(20)],
        textInputAction: TextInputAction.done,
        maxLines: null,
        autocorrect: false,
        hintText: _usernameHint == null ? "" : AppLocalization.of(context).enterUsername,
        fadePrefixOnCondition: true,
        style: _usernameStyle == AddressStyle.TEXT60
            ? AppStyles.textStyleAddressText60(context)
            : _usernameStyle == AddressStyle.TEXT90
                ? AppStyles.textStyleAddressText90(context)
                : AppStyles.textStyleAddressPrimary(context),
        onChanged: (text) {
          bool isUser = text.startsWith("@");
          bool isFavorite = text.startsWith("★");
          bool isNano = text.startsWith("nano_");

          // prevent spaces:
          if (text.contains(" ")) {
            text = text.replaceAll(" ", "");
            _usernameController.text = text;
            _usernameController.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController.text.length));
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
          if (text.length > 0 && !isUser && !isNano && !isFavorite) {
            // add @ to the beginning of the string:
            _usernameController.text = "@" + text;
            _usernameController.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController.text.length));
            isUser = true;
          }

          if (text.length > 0 && text.startsWith("@nano_")) {
            setState(() {
              // remove the @ from the beginning of the string:
              _usernameController.text = text.replaceFirst("@nano_", "nano_");
              _usernameController.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController.text.length));
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
                child: UIUtil.threeLineAddressText(context, _usernameController.text))
            : null);
  } //************ Enter Address Container Method End ************//
  //*************************************************************//
}
