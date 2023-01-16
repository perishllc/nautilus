import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/misc.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/user_data_util.dart';

class SplitBillAddUserSheet extends StatefulWidget {
  const SplitBillAddUserSheet({this.address}) : super();

  final String? address;

  @override
  SplitBillAddUserSheetState createState() => SplitBillAddUserSheetState();
}

class SplitBillAddUserSheetState extends State<SplitBillAddUserSheet> {
  late FocusNode _nameFocusNode;
  FocusNode? _addressFocusNode;
  TextEditingController? _nameController;
  TextEditingController? _addressController;

  // State variables
  bool? _addressValid;
  bool _pasteButtonVisible = true;
  bool _clearButton = false;
  late bool _addressValidAndUnfocused;
  String? _addressHint;
  late String _addressValidationText;
  String? _correspondingNickname;
  String? _correspondingUsername;
  String? _correspondingAddress;
  String? _userType;
  AddressStyle? _addressStyle;
  late List<User> _users;
  // Set to true when a username is being entered
  bool _isUser = false;

  // on on focus:
  Future<void> onUnfocus() async {
    setState(() {
      _addressHint = null;
      _users = <User>[];
      if (Address(_addressController!.text).isValid()) {
        _addressValidAndUnfocused = true;
      }
      if (_addressController!.text.isEmpty) {
        _pasteButtonVisible = true;
      }
    });
    // check if UD / ENS / opencap / onchain address:
    if (_addressController!.text.isNotEmpty) {
      User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController!.text);
      user ??= await sl.get<UsernameService>().figureOutUsernameType(_addressController!.text);

      if (user != null) {
        setState(() {
          _addressController!.text = user!.getDisplayName()!;
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

  @override
  void initState() {
    super.initState();
    // Text field initialization
    _nameFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    // State initializationrue;
    _addressValid = false;
    _pasteButtonVisible = true;
    _addressValidAndUnfocused = false;
    _addressValidationText = "";
    _users = <User>[];
    // Add focus listeners
    // On address focus change
    _addressFocusNode!.addListener(() async {
      if (_addressFocusNode!.hasFocus) {
        setState(() {
          _addressHint = "";
          _addressValidationText = "";
          _addressStyle = AddressStyle.TEXT60;
          _addressValidAndUnfocused = false;
          _pasteButtonVisible = true;
          if (_addressController!.text.isNotEmpty) {
            _clearButton = true;
          } else {
            _clearButton = false;
          }
        });
        _addressController!.selection =
            TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
        if (_addressController!.text.isNotEmpty && !_addressController!.text.startsWith(NonTranslatable.currencyPrefix)) {
          final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);
          if (_addressController!.text != formattedAddress) {
            setState(() {
              _addressController!.text = formattedAddress;
            });
          }
          final List<User> userList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(formattedAddress);
          setState(() {
            _users = userList;
          });
        }

        if (_addressController!.text.isEmpty) {
          setState(() {
            _users = <User>[];
          });
        }
      } else {
        await onUnfocus();
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
  Widget getEnterAddressContainer() {
    return AppTextField(
      topMargin: 124,
      padding:
          _addressValidAndUnfocused ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
      textAlign: TextAlign.center,
      focusNode: _addressFocusNode,
      controller: _addressController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        if (_isUser) LengthLimitingTextInputFormatter(20) else LengthLimitingTextInputFormatter(65),
      ],
      textInputAction: TextInputAction.done,
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
              setState(() {
                _addressController!.text = scanResult;
                _addressValidationText = "";
                _addressValid = true;
                _addressValidAndUnfocused = true;
              });
              _addressFocusNode!.unfocus();
            }
          }),
      fadePrefixOnCondition: true,
      prefixShowFirstCondition: _pasteButtonVisible,
      suffixButton: TextFieldButton(
        icon: _clearButton ? AppIcons.clear : AppIcons.paste,
        onPressed: () async {
          if (_clearButton) {
            setState(() {
              _isUser = false;
              _addressValidationText = "";
              _pasteButtonVisible = true;
              _clearButton = false;
              _addressController!.text = "";
              _users = <User>[];
            });
            return;
          }

          final String? data = await UserDataUtil.getClipboardText(DataType.ADDRESS);
          if (data == null) {
            return;
          }
          final Address address = Address(data);
          if (address.isValid()) {
            sl.get<DBHelper>().getUserOrContactWithAddress(address.address!).then((User? user) {
              if (user == null) {
                setState(() {
                  _isUser = false;
                  _addressValid = true;
                  _addressValidationText = "";
                  _addressStyle = AddressStyle.TEXT90;
                  _pasteButtonVisible = true;
                  _clearButton = true;
                  _addressController!.text = address.address!;
                  _addressFocusNode!.unfocus();
                  _addressValidAndUnfocused = true;
                });
              } else {
                // Is a user
                setState(() {
                  _addressController!.text = user.getDisplayName()!;
                  _addressFocusNode!.unfocus();
                  _users = [];
                  _isUser = true;
                  _addressValid = true;
                  _addressValidationText = "";
                  _addressStyle = AddressStyle.PRIMARY;
                  _pasteButtonVisible = true;
                  _clearButton = true;
                });
              }
              onUnfocus();
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
      onChanged: (String text) async {
        bool isUser = false;
        final bool isDomain = text.contains(".") || text.contains(r"$");
        final bool isFavorite = text.startsWith("★");
        final bool isNano = text.startsWith(NonTranslatable.currencyPrefix);

        // prevent spaces:
        if (text.contains(" ")) {
          text = text.replaceAll(" ", "");
          _addressController!.text = text;
          _addressController!.selection =
              TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
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
          setState(() {
            _users = matchedList;
          });
        } else if (isUser || isDomain) {
          final List<User> matchedList =
              await sl.get<DBHelper>().getUserSuggestionsWithUsernameLike(SendSheetHelpers.stripPrefixes(text));
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
          _addressFocusNode!.unfocus();
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
                Future.delayed(const Duration(milliseconds: 50), () {
                  FocusScope.of(context).requestFocus(_addressFocusNode);
                });
              },
              child: UIUtil.threeLineAddressText(
                  context, widget.address != null ? widget.address! : _addressController!.text))
          : null,
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
                      CaseChange.toUpperCase(Z.of(context).addAccount, context),
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
                      _addressFocusNode!.unfocus();
                      _nameFocusNode.unfocus();
                    },
                    child: Container(
                      color: Colors.transparent,
                      constraints: const BoxConstraints.expand(),
                      child: const SizedBox.expand(),
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
                                      margin: EdgeInsets.only(
                                          left: MediaQuery.of(context).size.width * 0.105,
                                          right: MediaQuery.of(context).size.width * 0.105),
                                      alignment: Alignment.bottomCenter,
                                      constraints: const BoxConstraints(maxHeight: 174, minHeight: 0),
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
                        ],
                      ),
                    ],
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
                  // Add Contact Button
                  AppButton.buildAppButton(
                      context, AppButtonType.PRIMARY, Z.of(context).addAccount, Dimens.BUTTON_TOP_DIMENS,
                      onPressed: () async {
                    if (await validateForm()) {
                      User user;
                      final String formAddress = widget.address ?? _addressController!.text;
                      // if we're given an address with corresponding username, just block:
                      if (_correspondingUsername != null) {
                        user = User(
                          nickname: _correspondingNickname,
                          address: formAddress,
                          username: _correspondingUsername,
                          type: _userType,
                        );
                      } else if (_correspondingAddress != null) {
                        user = User(
                          nickname: _correspondingNickname,
                          address: _correspondingAddress,
                          username: SendSheetHelpers.stripPrefixes(formAddress),
                          type: _userType,
                        );
                      } else {
                        // just an address:
                        user = User(
                          nickname: _correspondingNickname,
                          address: formAddress,
                          type: _userType,
                        );
                      }

                      Navigator.of(context).pop(user);
                    }
                    // if (await validateForm()) {
                    //   final String formAddress = widget.address ?? _addressController!.text;
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
    // Address Validations
    // Don't validate address if it came pre-filled in
    final String formAddress = widget.address != null ? widget.address! : _addressController!.text;
    final String formattedAddress = SendSheetHelpers.stripPrefixes(formAddress);

    // if (widget.address == null) {
    if (formAddress.isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = Z.of(context).addressOrUserMissing;
      });
    } else if (formAddress.startsWith(NonTranslatable.currencyPrefix)) {
      // we're dealing with an address:

      if (!Address(formAddress).isValid()) {
        isValid = false;
        setState(() {
          _addressValidationText = Z.of(context).invalidAddress;
        });
      }

      _addressFocusNode!.unfocus();
      final bool blockedExists = await sl.get<DBHelper>().blockedExistsWithAddress(formAddress);
      if (blockedExists) {
        isValid = false;
        setState(() {
          _addressValidationText = Z.of(context).blockedExists;
        });
      } else {
        // get the corresponding username if it exists:
        final String? username = await sl.get<DBHelper>().getUsernameWithAddress(formAddress);
        if (username != null) {
          setState(() {
            _correspondingUsername = username;
          });
        }
      }
    } else {
      // we're dealing with a username:
      final bool blockedExists = await sl.get<DBHelper>().blockedExistsWithUsername(formattedAddress);
      if (blockedExists) {
        isValid = false;
        setState(() {
          _addressValidationText = Z.of(context).blockedExists;
        });
      } else {
        // check if there's a corresponding address:
        final User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController!.text);
        if (user != null) {
          setState(() {
            _userType = user.type;
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
            _addressValidationText = Z.of(context).userNotFound;
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
