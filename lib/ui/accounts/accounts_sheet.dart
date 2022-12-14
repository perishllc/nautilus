import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/account.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:wallet_flutter/ui/accounts/add_watch_only_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:quiver/strings.dart';

class AppAccountsSheet extends StatefulWidget {
  const AppAccountsSheet({super.key, required this.accounts});

  final List<Account> accounts;

  @override
  AppAccountsSheetState createState() => AppAccountsSheetState();
}

class AppAccountsSheetState extends State<AppAccountsSheet> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();

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
    _addingAccount = false;
    _accountIsChanging = false;
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  Future<void> _handleAccountsBalancesResponse(AccountsBalancesResponse resp) async {
    // Handle balances event
    for (final Account account in widget.accounts) {
      resp.balances!.forEach((String address, AccountBalanceItem balance) {
        address = address.replaceAll("xrb_", "nano_");
        final String combinedBalance =
            (BigInt.tryParse(balance.balance!)! + BigInt.tryParse(balance.receivable!)!).toString();
        if (account.address == address && combinedBalance != account.balance) {
          sl.get<DBHelper>().updateAccountBalance(account, combinedBalance);
          setState(() {
            account.balance = combinedBalance;
          });
        }
      });
    }
  }

  void _registerBus() {
    _accountModifiedSub =
        EventTaxiImpl.singleton().registerTo<AccountModifiedEvent>().listen((AccountModifiedEvent event) {
      if (event.deleted) {
        if (event.account!.selected) {
          Future<void>.delayed(const Duration(milliseconds: 50), () {
            setState(() {
              widget.accounts
                  .where((Account a) => a.index == StateContainer.of(context).selectedAccount!.index)
                  .forEach((Account account) {
                account.selected = true;
              });
            });
          });
        }
        setState(() {
          widget.accounts.removeWhere((Account a) => a.index == event.account!.index);
        });
      } else if (event.created && event.account != null) {
        setState(() {
          widget.accounts.add(event.account!);
          _requestBalances(context, widget.accounts);
        });
      } else {
        // Name change
        setState(() {
          widget.accounts.removeWhere((Account a) => a.index == event.account!.index);
          widget.accounts.add(event.account!);
          widget.accounts.sort((Account a, Account b) => a.index!.compareTo(b.index!));
        });
      }
    });
  }

  void _destroyBus() {
    if (_accountModifiedSub != null) {
      _accountModifiedSub!.cancel();
    }
  }

  Future<void> _requestBalances(BuildContext context, List<Account> accounts) async {
    final List<String> addresses = [];
    for (final Account account in accounts) {
      if (account.address != null) {
        addresses.add(account.address!);
      }
    }
    try {
      final AccountsBalancesResponse resp = await sl.get<AccountService>().requestAccountsBalances(addresses);
      if (mounted) {
        await _handleAccountsBalancesResponse(resp);
      }
    } catch (e) {
      sl.get<Logger>().e("Error", e);
    }
  }

  Future<void> _changeAccount(Account account, StateSetter setState) async {
    // Change account
    for (final Account acc in widget.accounts) {
      if (acc.selected) {
        setState(() {
          acc.selected = false;
        });
      } else if (account.index == acc.index) {
        setState(() {
          acc.selected = true;
        });
      }
    }
    await sl.get<DBHelper>().changeAccount(account);
    EventTaxiImpl.singleton().fire(AccountChangedEvent(account: account, delayPop: true));
  }

  // get total account balances:
  String _getTotalBalance() {
    BigInt totalBalance = BigInt.zero;
    for (final Account account in widget.accounts) {
      if (account.balance != null) {
        totalBalance += BigInt.parse(account.balance!);
      }
    }
    return totalBalance.toString();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: AppDialogs.infoButton(
                      context,
                      () {
                        AppDialogs.showConfirmDialog(
                            context,
                            Z.of(context).hideAccountsHeader,
                            Z.of(context).hideAccountsConfirmation,
                            CaseChange.toUpperCase(Z.of(context).yes, context), () async {
                          await Future<dynamic>.delayed(const Duration(milliseconds: 250));
                          final List<Account> accountsToRemove = <Account>[];
                          for (final Account account in widget.accounts) {
                            if (account.selected ||
                                account.index == 0 ||
                                account.watchOnly ||
                                account.balance == null) {
                              continue;
                            }

                            if (BigInt.tryParse(account.balance!) == BigInt.zero) {
                              accountsToRemove.add(account);
                            }
                          }
                          for (final Account account in accountsToRemove) {
                            await sl.get<DBHelper>().deleteAccount(account);
                            EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: account, deleted: true));
                            setState(() {
                              widget.accounts.removeWhere((Account acc) => acc.index == account.index);
                            });
                          }
                        }, cancelText: CaseChange.toUpperCase(Z.of(context).no, context));
                      },
                      icon: AppIcons.trashcan,
                    ),
                  ),
                  Column(
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
                              CaseChange.toUpperCase(Z.of(context).accounts, context),
                              style: AppStyles.textStyleHeader(context),
                              maxLines: 1,
                              stepGranularity: 0.1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text: "(",
                                style: TextStyle(
                                  color: StateContainer.of(context).curTheme.primary60,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                              TextSpan(
                                text: getRawAsThemeAwareFormattedAmount(context, _getTotalBalance()),
                                style: TextStyle(
                                  color: StateContainer.of(context).curTheme.primary60,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                              TextSpan(
                                text: (StateContainer.of(context).nyanoMode) ? (" nyano)") : (" NANO)"),
                                style: TextStyle(
                                  color: StateContainer.of(context).curTheme.primary60,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: AppDialogs.infoButton(
                      context,
                      () {
                        Sheets.showAppHeightEightSheet(context: context, widget: const AddWatchOnlyAccountSheet());
                      },
                      icon: AppIcons.search,
                    ),
                  ),
                ],
              ),

              // A list containing accounts
              Expanded(
                  key: expandedKey,
                  child: Stack(
                    children: <Widget>[
                      if (widget.accounts == null)
                        const Center(
                          child: Text("Loading"),
                        )
                      else
                        DraggableScrollbar(
                          controller: _scrollController,
                          scrollbarColor: StateContainer.of(context).curTheme.primary,
                          scrollbarTopMargin: 20.0,
                          scrollbarBottomMargin: 12.0,
                          child: ListView.builder(
                            // padding: const EdgeInsets.symmetric(vertical: 20),
                            // padding: const EdgeInsets.only(right: 2),
                            itemCount: widget.accounts.length,
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildAccountListItem(context, widget.accounts[index], setState);
                            },
                          ),
                        ),

                      // begin: const AlignmentDirectional(0.5, 1.0),
                      // end: const AlignmentDirectional(0.5, -1.0),
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
              if (widget.accounts.length < MAX_ACCOUNTS)
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                      context,
                      AppButtonType.PRIMARY,
                      Z.of(context).addAccount,
                      Dimens.BUTTON_BOTTOM_DIMENS,
                      disabled: _addingAccount,
                      onPressed: () {
                        if (!_addingAccount) {
                          setState(() {
                            _addingAccount = true;
                          });
                          StateContainer.of(context).getSeed().then((String seed) {
                            sl
                                .get<DBHelper>()
                                .addAccount(seed, nameBuilder: Z.of(context).defaultNewAccountName)
                                .then((Account? newAccount) {
                              if (newAccount == null) {
                                sl.get<Logger>().d("Error adding account: account was null");
                                return;
                              }
                              _requestBalances(context, [newAccount]);
                              StateContainer.of(context).updateRecentlyUsedAccounts();
                              widget.accounts.add(newAccount);
                              setState(() {
                                _addingAccount = false;
                                widget.accounts.sort((Account a, Account b) => a.index!.compareTo(b.index!));
                                // Scroll if list is full
                                if (expandedKey.currentContext != null) {
                                  final RenderBox? box = expandedKey.currentContext!.findRenderObject() as RenderBox?;
                                  if (box == null) return;
                                  if (widget.accounts.length * 72.0 >= box.size.height) {
                                    _scrollController.animateTo(
                                      newAccount.index! * 72.0 > _scrollController.position.maxScrollExtent
                                          ? _scrollController.position.maxScrollExtent + 72.0
                                          : newAccount.index! * 72.0,
                                      curve: Curves.easeOut,
                                      duration: const Duration(milliseconds: 200),
                                    );
                                  }
                                }
                              });
                            });
                          });
                        }
                      },
                    ),
                  ],
                ),
              // Close button
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

  Widget _buildAccountListItem(BuildContext context, Account account, StateSetter setState) {
    // get username if it exists:
    String? userOrAddress;
    if (account.user != null) {
      userOrAddress = account.user!.getDisplayName(/*ignoreNickname: true*/);
    } else {
      userOrAddress = Address(account.address).getShortString();
    }

    return Column(
      children: <Widget>[
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Slidable(
            closeOnScroll: true,
            endActionPane: _getSlideActionsForAccount(context, account, setState),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: StateContainer.of(context).curTheme.text15,
                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),

              // highlightColor: StateContainer.of(context).curTheme.text15,
              // splashColor: StateContainer.of(context).curTheme.text15,
              // padding: EdgeInsets.all(0.0),
              onPressed: () {
                if (!_accountIsChanging) {
                  // Change account
                  if (!account.selected) {
                    setState(() {
                      _accountIsChanging = true;
                    });
                    _changeAccount(account, setState);
                  }
                }
              },
              child: SizedBox(
                height: 70.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Selected indicator
                    // Container(
                    //   height: 70,
                    //   width: 6,
                    //   color: account.selected ? StateContainer.of(context).curTheme.primary : Colors.transparent,
                    // ),
                    // Icon, Account Name, Address and Amount
                    Expanded(
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 20, end: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        margin: EdgeInsets.only(left: account.watchOnly ? 5 : 0),
                                        child: Icon(
                                          account.watchOnly ? AppIcons.search : AppIcons.accountwallet,
                                          color: account.selected
                                              ? StateContainer.of(context).curTheme.success
                                              : StateContainer.of(context).curTheme.primary,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    if (!account.watchOnly)
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 30,
                                          alignment: const AlignmentDirectional(0, 0.3),
                                          child: Text(account.getShortName().toUpperCase(),
                                              style: TextStyle(
                                                color: StateContainer.of(context).curTheme.backgroundDark,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w800,
                                              )),
                                        ),
                                      ),
                                  ],
                                ),
                                // Account name and address
                                Container(
                                  width: (MediaQuery.of(context).size.width - 116) * 0.5,
                                  margin: EdgeInsetsDirectional.only(start: account.watchOnly ? 25 : 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Account name
                                      AutoSizeText(
                                        account.name!,
                                        style: TextStyle(
                                          fontFamily: "NunitoSans",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                          color: StateContainer.of(context).curTheme.text,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 0.1,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                      ),
                                      // Account address
                                      AutoSizeText(
                                        userOrAddress!,
                                        style: TextStyle(
                                          fontFamily: "OverpassMono",
                                          fontWeight: FontWeight.w100,
                                          fontSize: 14.0,
                                          color: StateContainer.of(context).curTheme.text60,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 0.1,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width - 116) * 0.4,
                              alignment: AlignmentDirectional.centerEnd,
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    // Main balance text
                                    TextSpan(
                                      text: "",
                                      children: [
                                        TextSpan(
                                          text: getThemeAwareRawAccuracy(
                                              context, isEmpty(account.balance) ? "0" : account.balance),
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: "NunitoSans",
                                              fontWeight: FontWeight.w900,
                                              color: StateContainer.of(context).curTheme.text),
                                        ),
                                        if (account.balance != null)
                                          displayCurrencySymbol(
                                            context,
                                            TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: "NunitoSans",
                                                fontWeight: FontWeight.w900,
                                                color: StateContainer.of(context).curTheme.text),
                                          ),
                                        TextSpan(
                                          text: account.balance != null
                                              ? (!account.selected)
                                                  ? getRawAsThemeAwareFormattedAmount(
                                                      context, isEmpty(account.balance) ? "0" : account.balance)
                                                  : getRawAsThemeAwareFormattedAmount(context, account.balance)
                                              : "",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: "NunitoSans",
                                            fontWeight: FontWeight.w900,
                                            color: StateContainer.of(context).curTheme.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                style: const TextStyle(fontSize: 16.0),
                                stepGranularity: 0.1,
                                minFontSize: 1,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // handle bars:
                    Container(
                      width: 4,
                      height: 30,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ActionPane _getSlideActionsForAccount(BuildContext context, Account account, StateSetter setState) {
    final List<Widget> actions = <Widget>[];

    actions.add(SlidableAction(
        autoClose: false,
        borderRadius: BorderRadius.circular(5.0),
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
        foregroundColor: StateContainer.of(context).curTheme.primary,
        icon: Icons.edit,
        label: Z.of(context).edit,
        onPressed: (BuildContext context) async {
          await Future<dynamic>.delayed(const Duration(milliseconds: 250));
          if (!mounted) return;
          AccountDetailsSheet(account).mainBottomSheet(context);
          await Slidable.of(context)!.close();
        }));

    actions.add(SlidableAction(
        autoClose: false,
        borderRadius: BorderRadius.circular(5.0),
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
        foregroundColor: StateContainer.of(context).curTheme.warning,
        icon: Icons.copy,
        label: Z.of(context).copy,
        onPressed: (BuildContext context) async {
          await Clipboard.setData(
            ClipboardData(text: account.address),
          );
          if (!mounted) return;
          UIUtil.showSnackbar(
            Z.of(context).addressCopied,
            context,
          );
        }));
    if (account.index! > 0) {
      actions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: Z.of(context).hide,
          onPressed: (BuildContext context) {
            AppDialogs.showConfirmDialog(
                context,
                Z.of(context).hideAccountHeader,
                Z.of(context).removeAccountText.replaceAll("%1", Z.of(context).addAccount),
                CaseChange.toUpperCase(Z.of(context).yes, context), () async {
              await Future<dynamic>.delayed(const Duration(milliseconds: 250));
              // Remove account
              await sl.get<DBHelper>().deleteAccount(account);
              EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: account, deleted: true));
              setState(() {
                widget.accounts.removeWhere((Account acc) => acc.index == account.index);
              });
              await Slidable.of(context)!.close();
            }, cancelText: CaseChange.toUpperCase(Z.of(context).no, context));
          }));
    }

    return ActionPane(
      // motion: const DrawerMotion(),
      motion: const ScrollMotion(),
      // extentRatio: (account.index! > 0) ? 0.5 : 0.25,
      extentRatio: (account.index! > 0) ? 0.66 : 0.5,
      // All actions are defined in the children parameter.
      children: actions,
    );
  }
}
