import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:event_taxi/event_taxi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
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

class AddContactSheet extends StatefulWidget {
  final String address;

  AddContactSheet({this.address}) : super();

  _AddContactSheetState createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<AddContactSheet> {
  FocusNode _nameFocusNode;
  FocusNode _addressFocusNode;
  TextEditingController _nameController;
  TextEditingController _addressController;

  // State variables
  bool _addressValid;
  bool _pasteButtonVisible;
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
    this._pasteButtonVisible = true;
    this._addressValidAndUnfocused = false;
    this._nameValidationText = "";
    this._addressValidationText = "";
    _users = [];
    // Add focus listeners
    // On name focus change
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        setState(() {
          _nameHint = "";
        });
      } else {
        setState(() {
          _nameHint = AppLocalization.of(context).favoriteNameHint;
        });
      }
    });
    // On address focus change
    _addressFocusNode.addListener(() async {
      if (_addressFocusNode.hasFocus) {
        setState(() {
          _addressHint = "";
          _addressValidAndUnfocused = false;
          _pasteButtonVisible = true;
          _addressStyle = AddressStyle.TEXT60;
        });
        _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
        if (_addressController.text.length > 0 && !_addressController.text.startsWith("nano_")) {
          String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController.text);
          if (_addressController.text != formattedAddress) {
            setState(() {
              _addressController.text = formattedAddress;
            });
          }
          var userList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(formattedAddress);
          if (userList != null) {
            setState(() {
              _users = userList;
            });
          }
        }

        if (_addressController.text.length == 0) {
          setState(() {
            _users = [];
          });
        }
      } else {
        setState(() {
          _addressHint = null;
          _users = [];
          if (Address(_addressController.text).isValid()) {
            _addressValidAndUnfocused = true;
          }
          if (_addressController.text.length == 0) {
            _pasteButtonVisible = true;
          }
        });
        if (_addressController.text.length > 0) {
          String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController.text);
          // check if in the username db:
          String address;
          String type;
          var user = await sl.get<DBHelper>().getUserOrContactWithName(formattedAddress);
          if (user != null) {
            type = user.type;
            if (_addressController.text != user.getDisplayName()) {
              setState(() {
                _addressController.text = user.getDisplayName();
              });
            }
          } else {
            // check if UD or ENS address
            if (_addressController.text.contains(".")) {
              // check if UD domain:
              address = await sl.get<AccountService>().checkUnstoppableDomain(formattedAddress);
              if (address != null) {
                type = UserTypes.UD;
              } else {
                // check if ENS domain:
                address = await sl.get<AccountService>().checkENSDomain(formattedAddress);
                if (address != null) {
                  type = UserTypes.ENS;
                }
              }
            }
          }

          if (type != null) {
            setState(() {
              _pasteButtonVisible = false;
              _addressStyle = AddressStyle.PRIMARY;
            });

            if (address != null && user == null) {
              // add to the db if missing:
              User user = new User(username: formattedAddress, address: address, type: type, blocked: false);
              await sl.get<DBHelper>().addUser(user);
            }
          } else {
            setState(() {
              _addressStyle = AddressStyle.TEXT60;
            });
          }
        }
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
      hintText: _addressHint ?? AppLocalization.of(context).favoriteNameHint,
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
      prefixShowFirstCondition: _pasteButtonVisible,
      suffixButton: TextFieldButton(
        icon: AppIcons.paste,
        onPressed: () async {
          if (!_pasteButtonVisible) {
            return;
          }
          String data = await UserDataUtil.getClipboardText(DataType.ADDRESS);
          if (data != null) {
            setState(() {
              _addressValid = true;
              _pasteButtonVisible = false;
              _addressController.text = data;
              _addressValidAndUnfocused = true;
            });
            _addressFocusNode.unfocus();
          } else {
            setState(() {
              _pasteButtonVisible = true;
              _addressValid = false;
            });
          }
        },
      ),
      fadeSuffixOnCondition: true,
      suffixShowFirstCondition: _pasteButtonVisible,
      style: _addressStyle == AddressStyle.TEXT60
          ? AppStyles.textStyleAddressText60(context)
          : _addressStyle == AddressStyle.TEXT90
              ? AppStyles.textStyleAddressText90(context)
              : AppStyles.textStyleAddressPrimary(context),
      onChanged: (text) async {
        bool isUser = false;
        bool isDomain = text.contains(".");
        bool isFavorite = text.startsWith("★");
        bool isNano = text.startsWith("nano_");

        // prevent spaces:
        if (text.contains(" ")) {
          text = text.replaceAll(" ", "");
          _addressController.text = text;
          _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));
        }

        if (text.length > 0) {
          setState(() {
            if (!_addressValidAndUnfocused) {
              _pasteButtonVisible = true;
            }
          });
        } else {
          setState(() {
            _pasteButtonVisible = true;
          });
        }

        if (text.length > 0 && !isUser && !isNano) {
          isUser = true;
        }

        if (text.length > 0 && text.startsWith("nano_")) {
          isUser = false;
        }

        if (text.length > 0 && text.contains(".")) {
          isUser = false;
        }

        // check if it's a real nano address:
        // bool isUser = !text.startsWith("nano_") && !text.startsWith("★");
        if (text.length == 0) {
          setState(() {
            _isUser = false;
            _users = [];
          });
        } else if (isFavorite) {
          var matchedList = await sl.get<DBHelper>().getContactsWithNameLike(SendSheetHelpers.stripPrefixes(text));
          if (matchedList != null) {
            setState(() {
              _users = matchedList;
            });
          }
        } else if (isUser || isDomain) {
          var matchedList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(SendSheetHelpers.stripPrefixes(text));
          if (matchedList != null) {
            setState(() {
              _users = matchedList;
            });
          }
        } else {
          setState(() {
            _isUser = false;
            _users = [];
          });
        }
        // Always reset the error message to be less annoying
        if (_addressValidationText.length > 0) {
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
  Widget _buildUserItem(User user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 42,
          width: double.infinity - 5,
          child: FlatButton(
            onPressed: () {
              _addressController.text = user.getDisplayName();
              _addressFocusNode.unfocus();
              setState(() {
                _isUser = true;
                _pasteButtonVisible = false;
                _addressStyle = AddressStyle.PRIMARY;
                _addressValidationText = "";
              });
            },
            child: Text(user.getDisplayName(), textAlign: TextAlign.center, style: AppStyles.textStyleAddressPrimary(context)),
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
                      CaseChange.toUpperCase(AppLocalization.of(context).addFavorite, context),
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
            child: KeyboardAvoider(
              duration: Duration(milliseconds: 0),
              autoScroll: true,
              focusPadding: 40,
              child: Column(
                children: <Widget>[
                  // Enter Name Container
                  AppTextField(
                    topMargin: MediaQuery.of(context).size.height * 0.14,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    focusNode: _nameFocusNode,
                    controller: _nameController,
                    textInputAction: widget.address != null ? TextInputAction.done : TextInputAction.next,
                    hintText: _nameHint,
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

                  // Enter Address container
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
                    ],
                  ),
                  // Enter Address Error Container
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(_addressValidationText,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: StateContainer.of(context).curTheme.primary,
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.w600,
                        )),
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
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).addFavorite, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      if (await validateForm()) {
                        User newContact =
                            User(nickname: _nameController.text.substring(1), address: widget.address == null ? _addressController.text : widget.address);
                        await sl.get<DBHelper>().saveContact(newContact);
                        newContact.address = newContact.address.replaceAll("xrb_", "nano_");
                        EventTaxiImpl.singleton().fire(ContactAddedEvent(contact: newContact));
                        UIUtil.showSnackbar(AppLocalization.of(context).contactAdded.replaceAll("%1", newContact.nickname), context);
                        EventTaxiImpl.singleton().fire(ContactModifiedEvent(contact: newContact));
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
    if (widget.address == null) {
      if (_addressController.text.isEmpty) {
        isValid = false;
        setState(() {
          _addressValidationText = AppLocalization.of(context).addressMissing;
        });
      } else if (!Address(_addressController.text).isValid()) {
        isValid = false;
        setState(() {
          _addressValidationText = AppLocalization.of(context).invalidAddress;
        });
      } else {
        _addressFocusNode.unfocus();
        bool addressExists = await sl.get<DBHelper>().contactExistsWithAddress(_addressController.text);
        if (addressExists) {
          setState(() {
            isValid = false;
            _addressValidationText = AppLocalization.of(context).favoriteExists;
          });
        }
      }
    }
    // Name Validations
    if (_nameController.text.isEmpty) {
      isValid = false;
      setState(() {
        _nameValidationText = AppLocalization.of(context).favoriteNameMissing;
      });
    } else {
      bool nameExists = await sl.get<DBHelper>().contactExistsWithName(_nameController.text);
      if (nameExists) {
        setState(() {
          isValid = false;
          _nameValidationText = AppLocalization.of(context).favoriteExists;
        });
      }
    }
    return isValid;
  }
}
