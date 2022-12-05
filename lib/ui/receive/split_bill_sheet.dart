import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/receive/split_bill_add_user_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/request/request_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';

class SplitBillSheet extends StatefulWidget {
  const SplitBillSheet({super.key, required this.localCurrencyFormat});

  final NumberFormat localCurrencyFormat;

  @override
  SplitBillSheetState createState() => SplitBillSheetState();
}

class SplitBillSheetState extends State<SplitBillSheet> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();

  bool _localCurrencyMode = false;
  final List<User> users = [];
  final Map<String, dynamic> userMap = <String, dynamic>{};

  bool _addingAccount = false;
  final ScrollController _scrollController = ScrollController();

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  void initState() {
    super.initState();
    _addingAccount = false;
  }

  @override
  void dispose() {
    users.clear();
    userMap.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Empty SizedBox
                  const SizedBox(
                    width: 60,
                    height: 60,
                  ),
                  // A container for the header
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
                                CaseChange.toUpperCase(Z.of(context).splitBillHeader, context),
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

                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.only(top: 25, right: 20),
                    child: AppDialogs.infoButton(
                      context,
                      () {
                        AppDialogs.showInfoDialog(context, Z.of(context).splitBillInfoHeader,
                            Z.of(context).splitBillInfo);
                      },
                    ),
                  ),
                ],
              ),

              // A list containing accounts
              Expanded(
                  key: expandedKey,
                  child: Stack(
                    children: <Widget>[
                      if (users == null)
                        const Center(
                          child: Text("Loading"),
                        )
                      else
                        DraggableScrollbar(
                          controller: _scrollController,
                          scrollbarColor: StateContainer.of(context).curTheme.primary,
                          scrollbarTopMargin: 20.0,
                          scrollbarBottomMargin: 12.0,
                          child: KeyboardAvoider(
                            duration: Duration.zero,
                            autoScroll: true,
                            focusPadding: 40,
                            child: ListView.builder(
                              itemCount: users.length,
                              controller: _scrollController,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildUserListItem(context, users[index], setState);
                              },
                            ),
                          ),
                        ),
                      ListGradient(
                        height: 20,
                        top: true,
                        color: StateContainer.of(context).curTheme.backgroundDark!,
                      ),
                      ListGradient(
                        height: 20,
                        top: false,
                        color: StateContainer.of(context).curTheme.backgroundDark!,
                      ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              //A row with Add Account button
              if (users.length < MAX_ACCOUNTS)
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(right: 28, bottom: 10),
                  child: FloatingActionButton(
                    backgroundColor: StateContainer.of(context).curTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
                    onPressed: !_addingAccount
                        ? () async {
                            if (_addingAccount) {
                              return;
                            }
                            setState(() {
                              _addingAccount = true;
                            });

                            final User? user = await Sheets.showAppHeightEightSheet(
                                context: context, widget: const SplitBillAddUserSheet()) as User?;
                            if (!mounted) return;

                            if (user == null || user.address == null) {
                              sl.get<Logger>().d("Error adding account: user or address was null");
                            } else {
                              // make sure the user isn't already in the list:
                              final String? userOrAddress = user.displayNameOrShortestAddress();

                              if (userMap.keys.contains(userOrAddress)) {
                                sl.get<Logger>().v("Error adding account: user already in list!");
                                UIUtil.showSnackbar(Z.of(context).userAlreadyAddedError, context);
                                setState(() {
                                  _addingAccount = false;
                                });
                                return;
                              }

                              setState(() {
                                // add user to list:
                                users.add(user);
                                // Scroll if list is full
                                // if (expandedKey.currentContext != null) {
                                //   final RenderBox? box = expandedKey.currentContext!.findRenderObject() as RenderBox?;
                                //   if (box == null) return;
                                //   if (users.length * 72.0 >= box.size.height) {
                                //     // _scrollController.animateTo(
                                //     //   user.index! * 72.0 > _scrollController.position.maxScrollExtent
                                //     //       ? _scrollController.position.maxScrollExtent + 72.0
                                //     //       : newAccount.index! * 72.0,
                                //     //   curve: Curves.easeOut,
                                //     //   duration: const Duration(milliseconds: 200),
                                //     // );
                                //   }
                                // }
                              });
                            }
                            setState(() {
                              _addingAccount = false;
                            });
                          }
                        : null,
                    child: const Icon(Icons.add),
                  ),
                ),
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY,
                    Z.of(context).sendRequests,
                    Dimens.BUTTON_TOP_DIMENS,
                    disabled: users.isEmpty,
                    onPressed: () async {
                      final List<dynamic> requestsToSend = [];

                      for (final User user in users) {
                        final String displayName = user.displayNameOrShortestAddress()!;

                        final TextEditingController amountController =
                            userMap[displayName]["_amountController"] as TextEditingController;
                        final TextEditingController memoController =
                            userMap[displayName]["_memoController"] as TextEditingController;

                        // final String amountRaw = userMap[displayName]["_amountController"].text as String;

                        // final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);

                        final String formattedAmount =
                            sanitizedAmount(widget.localCurrencyFormat, amountController.text);

                        String amountRaw;
                        if (amountController.text.isEmpty || amountController.text == "0") {
                          amountRaw = "0";
                        } else {
                          if (_localCurrencyMode) {
                            amountRaw = NumberUtil.getAmountAsRaw(sanitizedAmount(
                                widget.localCurrencyFormat,
                                convertLocalCurrencyToLocalizedCrypto(
                                    context, widget.localCurrencyFormat, amountController.text)));
                          } else {
                            if (!mounted) return;
                            amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
                          }
                        }

                        await Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: RequestConfirmSheet(
                              amountRaw: amountRaw,
                              destination: user.address!,
                              contactName: user.getDisplayName(),
                              localCurrency: _localCurrencyMode ? amountController.text : null,
                              memo: memoController.text,
                            ));
                      }
                    },
                  ),
                  // AppButton.buildAppButton(
                  //   context,
                  //   AppButtonType.PRIMARY,
                  //   Z.of(context).sendAmounts,
                  //   Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
                  //   disabled: users.isEmpty,
                  //   onPressed: () async {
                  //     for (final User user in users) {
                  //       final String displayName = user.displayNameOrShortestAddress()!;

                  //       final TextEditingController amountController =
                  //           userMap[displayName]["_amountController"] as TextEditingController;
                  //       final TextEditingController memoController =
                  //           userMap[displayName]["_memoController"] as TextEditingController;

                  //       // final String amountRaw = userMap[displayName]["_amountController"].text as String;

                  //       // final String formattedAddress = SendSheetHelpers.stripPrefixes(_addressController!.text);

                  //       final String formattedAmount =
                  //           sanitizedAmount(widget.localCurrencyFormat, amountController.text);

                  //       String amountRaw;
                  //       if (amountController.text.isEmpty || amountController.text == "0") {
                  //         amountRaw = "0";
                  //       } else {
                  //         if (_localCurrencyMode) {
                  //           amountRaw = NumberUtil.getAmountAsRaw(sanitizedAmount(
                  //               widget.localCurrencyFormat,
                  //               convertLocalCurrencyToLocalizedCrypto(
                  //                   context, widget.localCurrencyFormat, amountController.text)));
                  //         } else {
                  //           if (!mounted) return;
                  //           amountRaw = getThemeAwareAmountAsRaw(context, formattedAmount);
                  //         }
                  //       }

                  //       await Sheets.showAppHeightNineSheet(
                  //           context: context,
                  //           widget: SendConfirmSheet(
                  //             amountRaw: amountRaw,
                  //             destination: user.address!,
                  //             contactName: user.getDisplayName(),
                  //             localCurrency: _localCurrencyMode ? amountController.text : null,
                  //             memo: memoController.text,
                  //           ));
                  //     }
                  //   },
                  // ),
                ],
              ),
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
        ),
      ),
    );
  }

  Widget _buildUserListItem(BuildContext context, User user, StateSetter setState) {
    // get username if it exists:
    final String? userOrAddress = user.displayNameOrShortestAddress();

    // userOrAddress ??= Address(user.address)

    if (userOrAddress == null) {
      return const SizedBox();
    }

    return Column(
      children: <Widget>[
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        Slidable(
          closeOnScroll: true,
          endActionPane: _getSlideActionsForUser(context, user, setState),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: max(min(MediaQuery.of(context).size.width / 6, 400), 100),
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Icon(
                        AppIcons.accountwallet,
                        color: StateContainer.of(context).curTheme.primary,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      child: Text(
                        userOrAddress,
                        style: TextStyle(
                          color: StateContainer.of(context).curTheme.text,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: getEnterAmountContainer(userOrAddress),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: getEnterMemoContainer(userOrAddress),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // handle bars:
              Container(
                width: 4,
                height: 90,
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: StateContainer.of(context).curTheme.text45,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void toggleLocalCurrency() {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
    // this way you can tap button and tap back and not end up with X.9993451 NANO
    for (final String addr in userMap.keys) {
      if (userMap[addr]["_amountController"] != null) {
        final TextEditingController amountController = userMap[addr]["_amountController"] as TextEditingController;
        String lastLocalCurrencyAmount = userMap[addr]["_lastLocalCurrencyAmount"] as String;
        String lastCryptoAmount = userMap[addr]["_lastCryptoAmount"] as String;

        if (_localCurrencyMode) {
          // Switching to crypto-mode
          String cryptoAmountStr;
          // Check out previous state
          if (amountController.text == lastLocalCurrencyAmount) {
            cryptoAmountStr = lastCryptoAmount;
          } else {
            lastLocalCurrencyAmount = amountController.text;
            lastCryptoAmount =
                convertLocalCurrencyToLocalizedCrypto(context, widget.localCurrencyFormat, amountController.text);
            cryptoAmountStr = lastCryptoAmount;
          }
          // setState(() {
          //   _localCurrencyMode = false;
          // });
          Future<void>.delayed(const Duration(milliseconds: 50), () {
            amountController.text = cryptoAmountStr;
            amountController.selection = TextSelection.fromPosition(TextPosition(offset: cryptoAmountStr.length));
          });
        } else {
          // Switching to local-currency mode
          String localAmountStr;
          // Check our previous state
          if (amountController.text == lastCryptoAmount) {
            localAmountStr = lastLocalCurrencyAmount;
            if (!lastLocalCurrencyAmount.startsWith(widget.localCurrencyFormat.currencySymbol)) {
              lastLocalCurrencyAmount = widget.localCurrencyFormat.currencySymbol + lastLocalCurrencyAmount;
            }
          } else {
            lastCryptoAmount = amountController.text;
            lastLocalCurrencyAmount =
                convertCryptoToLocalCurrency(context, widget.localCurrencyFormat, amountController.text);
            localAmountStr = lastLocalCurrencyAmount;
          }
          Future<void>.delayed(const Duration(milliseconds: 50), () {
            amountController.text = localAmountStr;
            amountController.selection = TextSelection.fromPosition(TextPosition(offset: localAmountStr.length));
          });
        }
      }
    }
    // change the state:
    if (_localCurrencyMode) {
      setState(() {
        _localCurrencyMode = false;
      });
    } else {
      setState(() {
        _localCurrencyMode = true;
      });
    }
  }

  ActionPane _getSlideActionsForUser(BuildContext context, User user, StateSetter setState) {
    final List<Widget> actions = [];

    if (users.isNotEmpty) {
      actions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: Z.of(context).remove,
          onPressed: (BuildContext context) {
            setState(() {
              users.remove(user);
              userMap[user.displayNameOrShortestAddress()!] = null;
            });
          }));
    }

    return ActionPane(
      // motion: const DrawerMotion(),
      motion: const ScrollMotion(),
      extentRatio: 0.25,
      // All actions are defined in the children parameter.
      children: actions,
    );
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  Widget getEnterAmountContainer(String userAddress) {
    // add a map if not already there:
    userMap.putIfAbsent(userAddress, () => {});
    userMap[userAddress].putIfAbsent("_amountFocusNode", () => FocusNode());
    userMap[userAddress].putIfAbsent("_amountController", () => TextEditingController());
    userMap[userAddress].putIfAbsent("_amountHint", () => Z.of(context).enterAmount);
    userMap[userAddress].putIfAbsent("_lastLocalCurrencyAmount", () => "");
    userMap[userAddress].putIfAbsent("_lastCryptoAmount", () => "");

    final FocusNode amountFocusNode = userMap[userAddress]["_amountFocusNode"] as FocusNode;
    amountFocusNode.addListener(() {
      if (amountFocusNode.hasFocus) {
        userMap[userAddress]["_amountHint"] = null;
      } else {
        userMap[userAddress]["_amountHint"] = Z.of(context).enterAmount;
      }
      setState(() {});
    });

    return AppTextField(
      focusNode: userMap[userAddress]["_amountFocusNode"] as FocusNode,
      controller: userMap[userAddress]["_amountController"] as TextEditingController,
      topMargin: 10,
      leftMargin: 20,
      rightMargin: 20,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: "NunitoSans",
      ),
      inputFormatters: <TextInputFormatter>[
        CurrencyFormatter2(
          active: _localCurrencyMode,
          currencyFormat: widget.localCurrencyFormat,
          maxDecimalDigits:
              _localCurrencyMode ? widget.localCurrencyFormat.decimalDigits ?? 2 : NumberUtil.maxDecimalDigits,
        ),
      ],
      onChanged: (String text) {
        // Always reset the error message to be less annoying
        setState(() {
          // _amountValidationText = "";
        });
      },
      prefixButton: TextFieldButton(
        padding: EdgeInsets.zero,
        widget: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: displayCurrencySymbol(
                context,
                TextStyle(
                  color: StateContainer.of(context).curTheme.primary,
                  fontSize: _localCurrencyMode ? 12 : 20,
                  fontWeight: _localCurrencyMode ? FontWeight.w400 : FontWeight.w800,
                  fontFamily: "NunitoSans",
                ),
              ),
            ),
            const Text("/"),
            Text(widget.localCurrencyFormat.currencySymbol.trim(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _localCurrencyMode ? 20 : 12,
                  fontWeight: _localCurrencyMode ? FontWeight.w800 : FontWeight.w400,
                  color: StateContainer.of(context).curTheme.primary,
                  fontFamily: "NunitoSans",
                )),
          ],
        ),
        onPressed: () {
          toggleLocalCurrency();
        },
      ),
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: userMap[userAddress]["_amountHint"] as String?,
      fadeSuffixOnCondition: true,
      // suffixShowFirstCondition: !_isMaxSend(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (String text) {
        // FocusScope.of(context).unfocus();
        FocusScope.of(context).requestFocus(userMap[userAddress]["_memoFocusNode"] as FocusNode);
      },
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Memo Container Method ************//
  //*******************************************************//
  Widget getEnterMemoContainer(String userAddress) {
    // add a map if not already there:
    userMap.putIfAbsent(userAddress, () => {});
    userMap[userAddress].putIfAbsent("_memoFocusNode", () => FocusNode());
    userMap[userAddress].putIfAbsent("_memoController", () => TextEditingController());
    userMap[userAddress].putIfAbsent("_memoHint", () => Z.of(context).enterMemo);
    final FocusNode memoFocusNode = userMap[userAddress]["_memoFocusNode"] as FocusNode;
    memoFocusNode.addListener(() {
      if (memoFocusNode.hasFocus) {
        userMap[userAddress]["_memoHint"] = null;
      } else {
        userMap[userAddress]["_memoHint"] = Z.of(context).enterMemo;
      }
      setState(() {});
    });
    return AppTextField(
      focusNode: userMap[userAddress]["_memoFocusNode"] as FocusNode,
      controller: userMap[userAddress]["_memoController"] as TextEditingController,
      topMargin: 10,
      bottomMargin: 10,
      padding: EdgeInsets.zero,
      leftMargin: 20,
      rightMargin: 20,
      textAlign: TextAlign.center,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        LengthLimitingTextInputFormatter(200),
      ],
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: userMap[userAddress]["_memoHint"] as String?,
      fadeSuffixOnCondition: true,
      style: TextStyle(
        color: StateContainer.of(context).curTheme.text60,
        fontSize: AppFontSizes.small,
        height: 1.5,
        fontWeight: FontWeight.w100,
        fontFamily: 'OverpassMono',
      ),
      onSubmitted: (String text) {
        // FocusScope.of(context).nextFocus();
        bool foundSelf = false;
        for (final String x in userMap.keys) {
          if (x == userAddress) {
            foundSelf = true;
            continue;
          }
          if (foundSelf) {
            FocusScope.of(context).requestFocus(userMap[x]["_amountFocusNode"] as FocusNode);
            break;
          }
        }
        // unfocus the last one
        if (!foundSelf) {
          FocusScope.of(context).unfocus();
        }
      },
    );
  } //************ Enter Memo Container Method End ************//
  //*************************************************************//

}
