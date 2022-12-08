import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/network/username_service.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/misc.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/user_data_util.dart';

class AddWatchOnlyAccountSheet extends StatefulWidget {
  const AddWatchOnlyAccountSheet({super.key});

  // final List<Account> accounts;

  @override
  _AddWatchOnlyAccountSheetState createState() => _AddWatchOnlyAccountSheetState();
}

class _AddWatchOnlyAccountSheetState extends State<AddWatchOnlyAccountSheet> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();
  FocusNode? _nameFocusNode;
  FocusNode? _addressFocusNode;
  TextEditingController? _nameController;
  TextEditingController? _addressController;

  // State variables
  bool? _addressValid;
  bool? _pasteButtonVisible;
  late bool _addressValidAndUnfocused;
  String? _addressHint;
  String? _nameHint;
  String? _nameValidationText;
  late String _addressValidationText;
  String? _correspondingUsername;
  String? _correspondingAddress;
  AddressStyle? _addressStyle;
  late List<User> _users;
  // Set to true when a username is being entered
  bool _isUser = false;

  bool _addingAccount = false;
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<AccountModifiedEvent>? _accountModifiedSub;
  late bool _accountIsChanging;

  Future<bool> _onWillPop() async {
    if (_accountModifiedSub != null) {
      _accountModifiedSub!.cancel();
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    // _addingAccount = false;
    // _accountIsChanging = false;
    // Text field initialization
    _nameFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    // State initializationrue;
    _addressValid = false;
    _pasteButtonVisible = true;
    _addressValidAndUnfocused = false;
    _nameValidationText = "";
    _addressValidationText = "";
    _users = [];
    // On name focus change
    _nameFocusNode!.addListener(() {
      if (_nameFocusNode!.hasFocus) {
        setState(() {
          _nameHint = "";
        });
      } else {
        setState(() {
          _nameHint = Z.of(context).contactNameHint;
        });
      }
    });
    // On address focus change
    _addressFocusNode!.addListener(() async {
      if (_addressFocusNode!.hasFocus) {
        setState(() {
          _addressHint = "";
          _addressValidAndUnfocused = false;
          _pasteButtonVisible = true;
          _addressStyle = AddressStyle.TEXT60;
        });
        _addressController!.selection = TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
        if (_addressController!.text.isNotEmpty && !_addressController!.text.startsWith("nano_")) {
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
            _users = [];
          });
        }
      } else {
        setState(() {
          _addressHint = null;
          _users = [];
          if (Address(_addressController!.text).isValid()) {
            _addressValidAndUnfocused = true;
          }
          if (_addressController!.text.isEmpty) {
            _pasteButtonVisible = true;
          }
        });
        // check if UD / ENS / opencap / onchain address:
        if (_addressController!.text.isNotEmpty && !_addressController!.text.contains("★")) {
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
    });
  }

  @override
  void dispose() {
    // _destroyBus();
    super.dispose();
  }

  void _registerBus() {
    _accountModifiedSub = EventTaxiImpl.singleton().registerTo<AccountModifiedEvent>().listen((AccountModifiedEvent event) {
      if (event.deleted) {
        // if (event.account!.selected) {
        //   Future.delayed(const Duration(milliseconds: 50), () {
        //     setState(() {
        //       widget.accounts.where((Account a) => a.index == StateContainer.of(context).selectedAccount!.index).forEach((Account account) {
        //         account.selected = true;
        //       });
        //     });
        //   });
        // }
        // setState(() {
        //   widget.accounts.removeWhere((Account a) => a.index == event.account!.index);
        // });
      } else {
        // Name change
        // setState(() {
        //   widget.accounts.removeWhere((Account a) => a.index == event.account!.index);
        //   widget.accounts.add(event.account!);
        //   widget.accounts.sort((Account a, Account b) => a.index!.compareTo(b.index!));
        // });
      }
    });
  }

  void _destroyBus() {
    if (_accountModifiedSub != null) {
      _accountModifiedSub!.cancel();
    }
  }

  Future<void> _changeAccount(Account account, StateSetter setState) async {
    // // Change account
    // for (final Account acc in widget.accounts) {
    //   if (acc.selected) {
    //     setState(() {
    //       acc.selected = false;
    //     });
    //   } else if (account.index == acc.index) {
    //     setState(() {
    //       acc.selected = true;
    //     });
    //   }
    // }
    // await sl.get<DBHelper>().changeAccount(account);
    // EventTaxiImpl.singleton().fire(AccountChangedEvent(account: account, delayPop: true));
  }

  /// Return true if textfield should be shown, false if colorized should be shown
  bool _shouldShowTextField() {
    return !_addressValidAndUnfocused;
  }

  //************ Enter Address Container Method ************//
  //*******************************************************//
  Widget getEnterAddressContainer() {
    return AppTextField(
      topMargin: 115,
      padding: _addressValidAndUnfocused ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
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
            if (scanResult == null) {
              UIUtil.showSnackbar(Z.of(context).qrInvalidAddress, context);
            } else if (!QRScanErrs.ERROR_LIST.contains(scanResult)) {
              if (mounted) {
                setState(() {
                  _addressController!.text = scanResult;
                  _addressValidationText = "";
                  _addressValid = true;
                  _addressValidAndUnfocused = true;
                });
                _addressFocusNode!.unfocus();
              }
            }
          }),
      fadePrefixOnCondition: true,
      prefixShowFirstCondition: _pasteButtonVisible,
      suffixButton: TextFieldButton(
        icon: AppIcons.paste,
        onPressed: () async {
          if (!_pasteButtonVisible!) {
            return;
          }
          final String? data = await UserDataUtil.getClipboardText(DataType.ADDRESS);
          if (data != null) {
            setState(() {
              _addressValid = true;
              _pasteButtonVisible = false;
              _addressController!.text = data;
              _addressValidAndUnfocused = true;
            });
            _addressFocusNode!.unfocus();
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
      onChanged: (String text) async {
        bool isUser = false;
        final bool isDomain = text.contains(".") || text.contains(r"$");
        final bool isFavorite = text.startsWith("★");
        final bool isNano = text.startsWith("nano_");

        // prevent spaces:
        if (text.contains(" ")) {
          text = text.replaceAll(" ", "");
          _addressController!.text = text;
          _addressController!.selection = TextSelection.fromPosition(TextPosition(offset: _addressController!.text.length));
        }

        if (text.isNotEmpty) {
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

        if (text.isNotEmpty && !isUser && !isNano) {
          isUser = true;
        }

        if (text.isNotEmpty && text.startsWith("nano_")) {
          isUser = false;
        }

        if (text.isNotEmpty && text.contains(".")) {
          isUser = false;
        }

        // check if it's a real nano address:
        // bool isUser = !text.startsWith("nano_") && !text.startsWith("★");
        if (text.isEmpty) {
          setState(() {
            _isUser = false;
            _users = [];
          });
        } else if (isUser || isDomain) {
          final List<User> matchedList = await sl.get<DBHelper>().getUserContactSuggestionsWithNameLike(SendSheetHelpers.stripPrefixes(text));
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
                setState(() {
                  _addressValidAndUnfocused = false;
                });
                Future.delayed(const Duration(milliseconds: 50), () {
                  FocusScope.of(context).requestFocus(_addressFocusNode);
                });
              },
              child: UIUtil.threeLineAddressText(context, _addressController!.text))
          : null,
    );
  }

  Future<bool> validateForm() async {
    bool isValid = true;
    // Address Validations
    // Don't validate address if it came pre-filled in
    final String formAddress = _addressController!.text;
    final String formattedAddress = SendSheetHelpers.stripPrefixes(formAddress);
    final String formattedNickname = SendSheetHelpers.stripPrefixes(_nameController!.text);

    // if (widget.address == null) {
    if (formAddress.isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = Z.of(context).addressOrUserMissing;
      });
    } else if (formAddress.startsWith("nano_")) {
      // we're dealing with an address:

      if (!Address(formAddress).isValid()) {
        isValid = false;
        setState(() {
          _addressValidationText = Z.of(context).invalidAddress;
        });
      }

      _addressFocusNode!.unfocus();
      final bool accountExists = await sl.get<DBHelper>().watchAccountExistsWithAddress(formAddress);
      if (accountExists) {
        isValid = false;
        setState(() {
          _addressValidationText = Z.of(context).watchAccountExists;
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
      // check if there's a corresponding address:
      final User? user = await sl.get<DBHelper>().getUserOrContactWithName(_addressController!.text);
      if (user != null && user.address != null) {
        setState(() {
          _correspondingAddress = user.address;
        });

        // we're dealing with a username:
        final bool accountExists = await sl.get<DBHelper>().watchAccountExistsWithAddress(user.address!);
        if (accountExists) {
          isValid = false;
          setState(() {
            _addressValidationText = Z.of(context).watchAccountExists;
          });
        }
      } else {
        isValid = false;
        setState(() {
          _addressValidationText = (formattedAddress.contains(".") || formattedAddress.contains(r"$"))
              ? Z.of(context).domainInvalid
              : Z.of(context).userNotFound;
        });
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
    if (_nameController!.text.isEmpty) {
      isValid = false;
      setState(() {
        _nameValidationText = Z.of(context).accountNameMissing;
      });
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.035,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //A container for the header
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                child: Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text20,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          AutoSizeText(
                            CaseChange.toUpperCase(Z.of(context).watchOnlyAccount, context),
                            style: AppStyles.textStyleHeader(context),
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // The main container that holds "Enter Name" and "Enter Address" text fields
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  child: GestureDetector(
                    onTap: () {
                      // Clear focus of our fields when tapped in this empty space
                      _nameFocusNode!.unfocus();
                      _addressFocusNode!.unfocus();
                    },
                    child: KeyboardAvoider(
                      duration: Duration.zero,
                      autoScroll: true,
                      focusPadding: 40,
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  // Enter Name Container
                                  AppTextField(
                                    focusNode: _nameFocusNode,
                                    controller: _nameController,
                                    // topMargin: MediaQuery.of(context).size.height * 0.14,
                                    topMargin: 30,
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    textInputAction: TextInputAction.next,
                                    hintText: _nameHint ?? Z.of(context).accountNameHint,
                                    keyboardType: TextInputType.text,

                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.0,
                                      color: StateContainer.of(context).curTheme.text,
                                      fontFamily: "NunitoSans",
                                    ),
                                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                                    onSubmitted: (text) {
                                      if (!Address(_addressController!.text).isValid()) {
                                        FocusScope.of(context).requestFocus(_addressFocusNode);
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
                                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                                    child: Text(_nameValidationText ?? "",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: StateContainer.of(context).curTheme.primary,
                                          fontFamily: "NunitoSans",
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ],
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
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
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
                                                          return Misc.buildUserItem(context, _users[index], true, (User user) {
                                                            _addressController!.text = user.getDisplayName(ignoreNickname: true)!;
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),
              //A row with Add Account button
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY,
                    Z.of(context).addWatchOnlyAccount,
                    Dimens.BUTTON_TOP_DIMENS,
                    disabled: _addingAccount,
                    onPressed: () async {
                      if (await validateForm()) {
                        final String formAddress = _addressController!.text;
                        final String formattedNickname = _nameController!.text;
                        Account? newAccount;
                        if (_correspondingUsername != null) {
                          newAccount = await sl.get<DBHelper>().addWatchOnlyAccount(formattedNickname, formAddress);
                        } else if (_correspondingAddress != null) {
                          newAccount = await sl.get<DBHelper>().addWatchOnlyAccount(formattedNickname, _correspondingAddress!);
                        } else {
                          // just an address:
                          newAccount = await sl.get<DBHelper>().addWatchOnlyAccount(formattedNickname, formAddress);
                        }

                        if (newAccount == null) {
                          UIUtil.showSnackbar(Z.of(context).addWatchOnlyAccount, context, durationMs: 5000);
                          return;
                        }
                        StateContainer.of(context).updateRecentlyUsedAccounts();
                        EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: newAccount, created: true));
                        UIUtil.showSnackbar(Z.of(context).addWatchOnlyAccountSuccess, context, durationMs: 5000);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
              //A row with Close button
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY_OUTLINE,
                    Z.of(context).close,
                    Dimens.BUTTON_BOTTOM_DIMENS,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
