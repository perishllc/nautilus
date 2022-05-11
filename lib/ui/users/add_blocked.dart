import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:event_taxi/event_taxi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/blocked_added_event.dart';
import 'package:nautilus_wallet_flutter/bus/blocked_modified_event.dart';
import 'package:nautilus_wallet_flutter/bus/user_added_event.dart';
import 'package:nautilus_wallet_flutter/bus/user_modified_event.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/db/blocked.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/db/contact.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/util/user_data_util.dart';

class AddBlockedSheet extends StatefulWidget {
  final String address;

  AddBlockedSheet({this.address}) : super();

  _AddBlockedSheetState createState() => _AddBlockedSheetState();
}

class _AddBlockedSheetState extends State<AddBlockedSheet> {
  FocusNode _nameFocusNode;
  FocusNode _addressFocusNode;
  TextEditingController _nameController;
  TextEditingController _addressController;

  // State variables
  bool _addressValid;
  bool _showPasteButton;
  bool _showNameHint;
  bool _showAddressHint;
  bool _addressValidAndUnfocused;
  String _addressHint = "";
  String _nameHint = "";
  String _nameValidationText;
  String _addressValidationText;
  String _correspondingUsername;
  String _correspondingAddress;
  AddressStyle _addressStyle;
  List<dynamic> _users;
  // Set to true when a username is being entered
  bool _isUser = false;

  @override
  void initState() {
    super.initState();
    // Text field initialization
    this._nameFocusNode = FocusNode();
    this._addressFocusNode = FocusNode();
    this._nameController = TextEditingController();
    this._addressController = TextEditingController();
    // State initializationrue;
    this._addressValid = false;
    this._showPasteButton = true;
    this._showNameHint = true;
    this._showAddressHint = true;
    this._addressValidAndUnfocused = false;
    this._nameValidationText = "";
    this._addressValidationText = "";
    _users = [];
    // Add focus listeners
    // On name focus change
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        setState(() {
          _showNameHint = false;
        });
      } else {
        setState(() {
          _showNameHint = true;
        });
      }
    });
    // On address focus change
    _addressFocusNode.addListener(() {
      if (_addressFocusNode.hasFocus) {
        setState(() {
          _addressHint = null;
          _addressValidAndUnfocused = false;
          _showPasteButton = true;
        });
        _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
        if (_addressController.text.length > 0 && !_addressController.text.startsWith("nano_")) {
          if (_addressController.text.startsWith("@")) {
            sl.get<DBHelper>().getUsersWithNameLike(_addressController.text.substring(1)).then((userList) {
              setState(() {
                _users = userList;
              });
            });
          }
        }

        if (_addressController.text.length == 0) {
          setState(() {
            _users = [];
          });
        }
      } else {
        if (_addressController.text.length > 0) {
          sl.get<DBHelper>().getUserOrContactWithName(_addressController.text.substring(1)).then((user) {
            if (user == null) {
              setState(() {
                _addressStyle = AddressStyle.TEXT60;
              });
            } else {
              setState(() {
                _showPasteButton = false;
                _addressStyle = AddressStyle.PRIMARY;
              });
            }
          });
        }

        setState(() {
          _addressHint = "";
          _users = [];
          if (Address(_addressController.text).isValid()) {
            _addressValidAndUnfocused = true;
          }
          if (_addressController.text.length == 0) {
            _showPasteButton = true;
          }
        });
        // if (_sendAddressController.text.trim() == "@" || _sendAddressController.text.trim() == "★") {
        //   _sendAddressController.text = "";
        //   setState(() {
        //     _showContactButton = true;
        //   });
        // }
      }
    });
  }

  /// Return true if textfield should be shown, false if colorized should be shown
  bool _shouldShowTextField() {
    if (widget.address != null) {
      return false;
    } else if (_addressValidAndUnfocused) {
      return false;
    }
    return true;
  }

  //************ Enter Address Container Method ************//
  //*******************************************************//
  getEnterAddressContainer() {
    return AppTextField(
      // padding: !_shouldShowTextField() ? EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
      // focusNode: _addressFocusNode,
      // controller: _addressController,
      // style: _addressValid ? AppStyles.textStyleAddressText90(context) : AppStyles.textStyleAddressText60(context),
      // inputFormatters: [
      //   LengthLimitingTextInputFormatter(65),
      // ],
      // textInputAction: TextInputAction.done,
      // maxLines: null,
      // autocorrect: false,
      // hintText: _showAddressHint ? AppLocalization.of(context).enterUserOrAddress : "",
      topMargin: 124,
      padding: _addressValidAndUnfocused ? EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
      textAlign: TextAlign.center,
      focusNode: _addressFocusNode,
      controller: _addressController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        _isUser ? LengthLimitingTextInputFormatter(20) : LengthLimitingTextInputFormatter(65),
      ],
      textInputAction: TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      hintText: _addressHint == null ? "" : AppLocalization.of(context).enterUserOrAddress,
      prefixButton: TextFieldButton(
          icon: AppIcons.scan,
          onPressed: () async {
            UIUtil.cancelLockEvent();
            String scanResult = await UserDataUtil.getQRData(DataType.ADDRESS, context);
            if (scanResult == null) {
              UIUtil.showSnackbar(AppLocalization.of(context).qrInvalidAddress, context);
            } else if (scanResult != null && !QRScanErrs.ERROR_LIST.contains(scanResult)) {
              if (mounted) {
                setState(() {
                  _addressController.text = scanResult;
                  _addressValidationText = "";
                  _addressValid = true;
                  _addressValidAndUnfocused = true;
                });
                _addressFocusNode.unfocus();
              }
            }
          }),
      fadePrefixOnCondition: true,
      prefixShowFirstCondition: _showPasteButton,
      suffixButton: TextFieldButton(
        icon: AppIcons.paste,
        onPressed: () async {
          if (!_showPasteButton) {
            return;
          }
          String data = await UserDataUtil.getClipboardText(DataType.ADDRESS);
          if (data != null) {
            setState(() {
              _addressValid = true;
              _showPasteButton = false;
              _addressController.text = data;
              _addressValidAndUnfocused = true;
            });
            _addressFocusNode.unfocus();
          } else {
            setState(() {
              _showPasteButton = true;
              _addressValid = false;
            });
          }
        },
      ),
      fadeSuffixOnCondition: true,
      suffixShowFirstCondition: _showPasteButton,
      style: _addressStyle == AddressStyle.TEXT60
          ? AppStyles.textStyleAddressText60(context)
          : _addressStyle == AddressStyle.TEXT90
              ? AppStyles.textStyleAddressText90(context)
              : AppStyles.textStyleAddressPrimary(context),
      onChanged: (text) {
        bool isUser = text.startsWith("@");
        bool isFavorite = text.startsWith("★");
        bool isNano = text.startsWith("nano_");

        // prevent spaces:
        if (text.contains(" ")) {
          text = text.replaceAll(" ", "");
          _addressController.text = text;
          _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
        }

        // remove the @ if it's the only text there:
        if (text == "@" || text == "★" || text == "nano_") {
          _addressController.text = "";
          _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
          setState(() {
            _showPasteButton = true;
            isUser = false;
            _users = [];
          });
          return;
        }
        // add the @ back in:
        if (text.length > 0 && !isUser && !isNano && !isFavorite) {
          // add @ to the beginning of the string:
          _addressController.text = "@" + text;
          _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
          isUser = true;
        }

        if (text.length > 0 && text.startsWith("@nano_")) {
          setState(() {
            // remove the @ from the beginning of the string:
            _addressController.text = text.replaceFirst("@nano_", "nano_");
            _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
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
        if (isNano && Address(text).isValid()) {
          _addressFocusNode.unfocus();
          setState(() {
            _addressStyle = AddressStyle.TEXT90;
            _addressValidationText = "";
            _showPasteButton = false;
          });
        } else {
          setState(() {
            _addressStyle = AddressStyle.TEXT60;
          });
          // } else {
          // sl.get<DBHelper>().getUserWithName(text.substring(1)).then((user) {
          //   if (user == null) {
          //     setState(() {
          //       _sendAddressStyle = AddressStyle.TEXT60;
          //     });
          //   } else {
          //     setState(() {
          //       _pasteButtonVisible = false;
          //       _sendAddressStyle = AddressStyle.PRIMARY;
          //     });
          //   }
          // });
        }
      },
      overrideTextFieldWidget: !_shouldShowTextField()
          ? GestureDetector(
              onTap: () {
                if (widget.address != null) {
                  return;
                }
                setState(() {
                  _addressValidAndUnfocused = false;
                });
                Future.delayed(Duration(milliseconds: 50), () {
                  FocusScope.of(context).requestFocus(_addressFocusNode);
                });
              },
              child: UIUtil.threeLineAddressText(context, widget.address != null ? widget.address : _addressController.text))
          : null,
    );
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
              _addressController.text = (user is User) ? ("@" + user.username) : ("★" + user.name);
              _addressFocusNode.unfocus();
              setState(() {
                _isUser = true;
                _showPasteButton = false;
                _addressStyle = AddressStyle.PRIMARY;
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
              SizedBox(
                width: 60,
                height: 60,
              ),
              // The header of the sheet
              Container(
                margin: EdgeInsets.only(top: 30.0),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                child: Column(
                  children: <Widget>[
                    AutoSizeText(
                      CaseChange.toUpperCase(AppLocalization.of(context).addBlocked, context),
                      style: AppStyles.textStyleHeader(context),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      stepGranularity: 0.1,
                    ),
                  ],
                ),
              ),

              // Scan QR Button
              SizedBox(width: 60, height: 60),
            ],
          ),

          // The main container that holds "Enter Name" and "Enter Address" text fields
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      // Clear focus of our fields when tapped in this empty space
                      _addressFocusNode.unfocus();
                      _nameFocusNode.unfocus();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: SizedBox.expand(),
                      constraints: BoxConstraints.expand(),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          // Column for Enter name + Enter name Error container
                          Column(
                            children: <Widget>[
                              // Enter Name Container
                              AppTextField(
                                // topMargin: MediaQuery.of(context).size.height * 0.14,
                                topMargin: 30,
                                // padding: EdgeInsets.symmetric(horizontal: 30),
                                focusNode: _nameFocusNode,
                                controller: _nameController,
                                textInputAction: widget.address != null ? TextInputAction.done : TextInputAction.next,
                                hintText: _showNameHint ? AppLocalization.of(context).favoriteNameHint : "",
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: StateContainer.of(context).curTheme.text,
                                  fontFamily: 'NunitoSans',
                                ),
                                inputFormatters: [LengthLimitingTextInputFormatter(20), ContactInputFormatter()],
                                onSubmitted: (text) {
                                  if (widget.address == null) {
                                    if (!Address(_addressController.text).isValid()) {
                                      FocusScope.of(context).requestFocus(_addressFocusNode);
                                    } else {
                                      FocusScope.of(context).unfocus();
                                    }
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                                onChanged: (text) {
                                  // Always reset the error message to be less annoying
                                  setState(() {
                                    _nameValidationText = "";
                                  });
                                },
                              ),
                              // Enter Name Error Container
                              Container(
                                margin: EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(_nameValidationText,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: StateContainer.of(context).curTheme.primary,
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
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
          //A column with "Add Contact" and "Close" buttons
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Add Contact Button
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).blockUser, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      if (await validateForm()) {
                        Blocked newBlocked;
                        String formAddress = widget.address != null ? widget.address : _addressController.text;
                        // if we're given an address with corresponding username, just block:
                        if (_correspondingUsername != null) {
                          newBlocked = Blocked(name: _nameController.text.substring(1), address: formAddress, username: _correspondingUsername);
                          sl.get<DBHelper>().blockUser(newBlocked);
                        } else if (_correspondingAddress != null) {
                          // print("Block user with address: ${_correspondingAddress} text: ${formAddress} and name: ${_nameController.text}");
                          newBlocked =
                              Blocked(name: _nameController.text.substring(1), address: _correspondingAddress, username: formAddress.substring(1));
                          sl.get<DBHelper>().blockUser(newBlocked);
                        } else {
                          // just an address:
                          newBlocked = Blocked(name: _nameController.text.substring(1), address: formAddress);
                          sl.get<DBHelper>().blockUser(newBlocked);
                        }
                        EventTaxiImpl.singleton().fire(BlockedAddedEvent(blocked: newBlocked));
                        UIUtil.showSnackbar(AppLocalization.of(context).blockedAdded.replaceAll("%1", newBlocked.name), context);
                        EventTaxiImpl.singleton().fire(BlockedModifiedEvent(blocked: newBlocked));
                        Navigator.of(context).pop();
                      }
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    // Close Button
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Future<bool> validateForm() async {
    bool isValid = true;
    // Address Validations
    // Don't validate address if it came pre-filled in
    String formAddress = widget.address != null ? widget.address : _addressController.text;

    // if (widget.address == null) {
      if (formAddress.isEmpty) {
        isValid = false;
        setState(() {
          _addressValidationText = AppLocalization.of(context).addressOrUserMissing;
        });
      } else if (formAddress.startsWith("nano_")) {
        // we're dealing with an address:

        if (!Address(formAddress).isValid()) {
          isValid = false;
          setState(() {
            _addressValidationText = AppLocalization.of(context).invalidAddress;
          });
        }

        _addressFocusNode.unfocus();
        bool blockedExists = await sl.get<DBHelper>().blockedExistsWithAddress(formAddress);
        if (blockedExists) {
          isValid = false;
          setState(() {
            _addressValidationText = AppLocalization.of(context).blockedExists;
          });
        } else {
          // get the corresponding username if it exists:
          String username = await sl.get<DBHelper>().getUsernameWithAddress(formAddress);
          if (username != null) {
            setState(() {
              _correspondingUsername = username;
            });
          }
        }
      } else {
        // we're dealing with a username:
        bool blockedExists = await sl.get<DBHelper>().blockedExistsWithUsername(formAddress.substring(1));
        if (blockedExists) {
          isValid = false;
          setState(() {
            _addressValidationText = AppLocalization.of(context).blockedExists;
          });
        } else {
          // check if there's a corresponding address:
          User user = await sl.get<DBHelper>().getUserWithName(formAddress.substring(1));
          if (user != null) {
            setState(() {
              _correspondingAddress = user.address;
            });
          } else {
            isValid = false;
            setState(() {
              _addressValidationText = AppLocalization.of(context).usernameNotFound;
            });
          }
        }
      // }
      // reset corresponding username if invalid:
      if (isValid == false && _correspondingUsername != null) {
        setState(() {
          _correspondingUsername = null;
        });
      }
      if (isValid == false && _correspondingAddress != null) {
        setState(() {
          _correspondingAddress = null;
        });
      }
    }
    // Name Validations
    if (_nameController.text.isEmpty) {
      isValid = false;
      setState(() {
        _nameValidationText = AppLocalization.of(context).blockedNameMissing;
      });
    } else {
      bool nameExists = await sl.get<DBHelper>().blockedExistsWithName(_nameController.text.substring(1));
      if (nameExists) {
        setState(() {
          isValid = false;
          _nameValidationText = AppLocalization.of(context).blockedNameExists;
        });
      }
    }
    return isValid;
  }
}
