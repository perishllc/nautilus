import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/node.dart';
import 'package:wallet_flutter/model/db/work_source.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/user_data_util.dart';

class AddWorkSourceSheet extends StatefulWidget {
  const AddWorkSourceSheet({this.address}) : super();

  final String? address;

  @override
  AddWorkSourceSheetState createState() => AddWorkSourceSheetState();
}

class AddWorkSourceSheetState extends State<AddWorkSourceSheet> {
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _httpFocusNode = FocusNode();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _httpController = TextEditingController();

  // bool _clearNameButton = false;
  bool _clearHttpButton = false;
  bool _clearWsButton = false;

  // bool _pasteNameButton = true;
  bool _pasteHttpButton = true;

  String _nameValidationText = "";
  String _httpValidationText = "";

  // late bool _addressValidAndUnfocused;
  // String? _addressHint;
  // late String _addressValidationText;
  // AddressStyle? _addressStyle;

  @override
  void initState() {
    super.initState();
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
      topMargin: 20,
      // padding: _addressValidAndUnfocused ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
      textAlign: TextAlign.center,
      focusNode: _nameFocusNode,
      controller: _nameController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [LengthLimitingTextInputFormatter(60)],
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: Z.of(context).enterNodeName,
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

  Widget getEnterHttpContainer() {
    return AppTextField(
      topMargin: 20,
      // padding: _addressValidAndUnfocused ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
      textAlign: TextAlign.center,
      focusNode: _httpFocusNode,
      controller: _httpController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [LengthLimitingTextInputFormatter(60)],
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: Z.of(context).enterHttpUrl,
      fadePrefixOnCondition: true,
      prefixShowFirstCondition: _pasteHttpButton,
      suffixButton: TextFieldButton(
        icon: _clearHttpButton ? AppIcons.clear : AppIcons.paste,
        onPressed: () async {
          if (_clearHttpButton) {
            setState(() {
              _pasteHttpButton = true;
              _clearHttpButton = false;
              _httpController.text = "";
            });
            return;
          }

          final String? data = await UserDataUtil.getClipboardText(DataType.RAW);
          if (data == null) {
            return;
          }
          setState(() {
            _httpController.text = data;
            _clearHttpButton = true;
          });
        },
      ),
      fadeSuffixOnCondition: true,
      suffixShowFirstCondition: _pasteHttpButton,
      // style: _addressStyle == AddressStyle.TEXT60
      //     ? AppStyles.textStyleAddressText60(context)
      //     : _addressStyle == AddressStyle.TEXT90
      //         ? AppStyles.textStyleAddressText90(context)
      //         : AppStyles.textStyleAddressPrimary(context),
      style: AppStyles.textStyleAddressText90(context),
      onChanged: (String text) async {
        // prevent spaces:
        if (text.contains(" ")) {
          text = text.replaceAll(" ", "");
          _httpController.text = text;
          _httpController.selection = TextSelection.fromPosition(TextPosition(
            offset: _httpController.text.length,
          ));
        }

        if (text.isNotEmpty) {
          setState(() {
            _pasteHttpButton = true;
            _clearHttpButton = true;
          });
        } else {
          setState(() {
            _pasteHttpButton = true;
            _clearHttpButton = false;
          });
        }

        // Always reset the error message to be less annoying
        if (_httpValidationText.isNotEmpty) {
          setState(() {
            _httpValidationText = "";
          });
        }
      },
      onSubmitted: (String text) {
        FocusScope.of(context).unfocus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
        child: SafeArea(
      minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
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
                      CaseChange.toUpperCase(Z.of(context).addWorkSource, context),
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
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      // Clear focus of our fields when tapped in this empty space
                      _nameFocusNode.unfocus();
                      _httpFocusNode.unfocus();
                    },
                    child: Container(
                      color: Colors.transparent,
                      constraints: const BoxConstraints.expand(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  KeyboardAvoider(
                    duration: Duration.zero,
                    autoScroll: true,
                    focusPadding: 40,
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            // Column for Enter Address container + Enter Address Error container
                            Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      getEnterNameContainer(),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(_nameValidationText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      getEnterHttpContainer(),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(_httpValidationText,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          //A column with "Add Contact" and "Close" buttons
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  // Add Node Button
                  AppButton.buildAppButton(
                      context, AppButtonType.PRIMARY, Z.of(context).addWorkSource, Dimens.BUTTON_TOP_DIMENS,
                      onPressed: () async {
                    if (!await validateForm()) {
                      return;
                    }
                    final WorkSource node = WorkSource(
                      name: _nameController.text,
                      url: _httpController.text,
                      type: WorkSourceTypes.URL,
                      selected: false,
                    );
                    Navigator.of(context).pop(node);

                    // if (await validateForm()) {
                    //   final String formAddress = widget.address ?? _httpController!.text;
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
    ));
  }

  Future<bool> validateForm() async {
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameValidationText = Z.of(context).nameEmpty;
      });
      isValid = false;
    } else {
      setState(() {
        _nameValidationText = "";
      });
    }

    if (_httpController.text.isEmpty) {
      setState(() {
        _httpValidationText = Z.of(context).urlEmpty;
      });
      isValid = false;
    } else {
      setState(() {
        _httpValidationText = "";
      });
    }

    return isValid;
  }
}
