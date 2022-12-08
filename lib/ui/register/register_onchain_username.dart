import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/username_service.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/register/register_nano_to_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/register/register_onchain_confirm.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';

// class LeaseOption {
//   final String key;
//   final String leaseLength;
//   final String nanoAmount;

//   LeaseOption(this.key, this.leaseLength, this.nanoAmount);

//   // static List<LeaseOption> get allCountries => [

//   //     ];
// }

class RegisterOnchainUsernameScreen extends StatefulWidget {
  @override
  _RegisterOnchainUsernameScreenState createState() => _RegisterOnchainUsernameScreenState();
}

class _RegisterOnchainUsernameScreenState extends State<RegisterOnchainUsernameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FocusNode? _usernameFocusNode;
  TextEditingController? _usernameController;

  // States
  AddressStyle? _usernameStyle;
  final String _usernameHint = "";
  String _usernameValidationText = "";
  bool _showRegisterButton = false;
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
    _usernameFocusNode!.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool _hasUsername = StateContainer.of(context).wallet!.username != null;
    _hasUsername = false; // debug override

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
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
                          if (!_hasUsername)
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 50,
                              width: 50,
                              margin: const EdgeInsets.only(left: 10),
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
                                  child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
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
                        margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 15.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              Z.of(context).usernameInfo,
                              style: AppStyles.textStyleParagraph(context),
                              maxLines: 6,
                              stepGranularity: 0.5,
                            ),
                          ],
                        ),
                      ),

                      if (_hasUsername)
                        Column(
                          children: <Widget>[
                            // The paragraph describing we already have a username:
                            Container(
                              margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 45.0),
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
                                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
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
              if (_hasUsername)
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
              else if (!_showRegisterButton)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).checkAvailability, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                      final String username = _usernameController!.text.replaceAll("@", "");
                      if (_usernameController!.text.isEmpty) {
                        setState(() {
                          _usernameValidationText = Z.of(context).usernameEmpty;
                        });
                        return;
                      }
                      final bool available = await sl.get<UsernameService>().checkOnchainUsernameAvailability(username);
                      if (available) {
                        setState(() {
                          _usernameValidationText = Z.of(context).usernameAvailable;
                          _showRegisterButton = true;
                        });
                        return;
                      }
                      setState(() {
                        _usernameValidationText = Z.of(context).usernameUnavailable;
                      });
                    }),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).registerUsername, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                      final String username = _usernameController!.text.replaceAll("@", "");

                      final BigInt balanceRaw = StateContainer.of(context).wallet!.accountBalance;
                      final BigInt sendAmount = BigInt.tryParse("1")!;
                      if (sendAmount > balanceRaw) {
                        setState(() {
                          _usernameValidationText = Z.of(context).insufficientBalance;
                        });
                        return Container();
                      }
                      // build the transaction:
                      Sheets.showAppHeightNineSheet(
                        context: context,
                        widget: RegisterOnchainConfirmSheet(
                          username: username,
                        ),
                      );
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
        padding: _usernameValidAndUnfocused ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
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
          final bool isNano = text.startsWith("nano_");

          // prevent spaces:
          if (text.contains(" ")) {
            text = text.replaceAll(" ", "");
            _usernameController!.text = text;
            _usernameController!.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
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
            _usernameController!.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
          }

          if (text.isNotEmpty && text.startsWith("@nano_")) {
            setState(() {
              // remove the @ from the beginning of the string:
              _usernameController!.text = text.replaceFirst("@nano_", "nano_");
              _usernameController!.selection = TextSelection.fromPosition(TextPosition(offset: _usernameController!.text.length));
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
                  Future.delayed(const Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(_usernameFocusNode);
                  });
                },
                child: UIUtil.threeLineAddressText(context, _usernameController!.text))
            : null);
  } //************ Enter Address Container Method End ************//
  //*************************************************************//
}
