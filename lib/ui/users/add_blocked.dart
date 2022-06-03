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
  bool _pasteButtonVisible;
  bool _addressValidAndUnfocused;
  String _addressHint;
  String _addressValidationText;
  String _correspondingNickname;
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
    this._addressValidationText = "";
    _users = [];
    // Add focus listeners
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
      hintText: _addressHint ?? AppLocalization.of(context).enterUserOrAddress,
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
                        User newBlocked;
                        String formAddress = widget.address != null ? widget.address : _addressController.text;
                        // if we're given an address with corresponding username, just block:
                        if (_correspondingUsername != null) {
                          newBlocked = User(nickname: _correspondingNickname ?? null, address: formAddress, username: _correspondingUsername);
                          await sl.get<DBHelper>().blockUser(newBlocked);
                        } else if (_correspondingAddress != null) {
                          newBlocked = User(
                              nickname: _correspondingNickname ?? null, address: _correspondingAddress, username: SendSheetHelpers.stripPrefixes(formAddress));
                          await sl.get<DBHelper>().blockUser(newBlocked);
                        } else {
                          // just an address:
                          newBlocked = User(nickname: _correspondingNickname ?? null, address: formAddress);
                          await sl.get<DBHelper>().blockUser(newBlocked);
                        }
                        EventTaxiImpl.singleton().fire(BlockedAddedEvent(blocked: newBlocked));
                        UIUtil.showSnackbar(AppLocalization.of(context).blockedAdded.replaceAll("%1", newBlocked.getDisplayName()), context);
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
    String formattedAddress = SendSheetHelpers.stripPrefixes(formAddress);

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
      bool blockedExists = await sl.get<DBHelper>().blockedExistsWithUsername(formattedAddress);
      if (blockedExists) {
        isValid = false;
        setState(() {
          _addressValidationText = AppLocalization.of(context).blockedExists;
        });
      } else {
        // check if there's a corresponding address:
        User user = await sl.get<DBHelper>().getUserOrContactWithName(formattedAddress);
        if (user != null) {
          setState(() {
            if (user.address != null) {
              _correspondingAddress = user.address;
            }
            if (user.nickname != null) {
              _correspondingNickname = user.nickname;
            }
          });
        } else {
          isValid = false;
          setState(() {
            _addressValidationText = AppLocalization.of(context).userNotFound;
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
    return isValid;
  }
}
