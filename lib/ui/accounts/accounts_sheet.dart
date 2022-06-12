import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheets.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';

class AppAccountsSheet {
  List<Account> accounts;

  AppAccountsSheet(this.accounts);

  mainBottomSheet(BuildContext context) {
    AppSheets.showAppHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return AppAccountsWidget(accounts: accounts);
        });
  }
}

class AppAccountsWidget extends StatefulWidget {
  final List<Account?> accounts;

  AppAccountsWidget({Key? key, required this.accounts}) : super(key: key);

  @override
  _AppAccountsWidgetState createState() => _AppAccountsWidgetState();
}

class _AppAccountsWidgetState extends State<AppAccountsWidget> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();

  bool? _addingAccount;
  ScrollController _scrollController = new ScrollController();

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
    this._addingAccount = false;
    this._accountIsChanging = false;
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  Future<void> _handleAccountsBalancesResponse(AccountsBalancesResponse resp) async {
    // Handle balances event
    widget.accounts.forEach((account) {
      resp.balances!.forEach((address, balance) {
        address = address.replaceAll("xrb_", "nano_");
        String combinedBalance = (BigInt.tryParse(balance.balance!)! + BigInt.tryParse(balance.pending!)!).toString();
        if (account!.address == address && combinedBalance != account.balance) {
          sl.get<DBHelper>().updateAccountBalance(account, combinedBalance);
          setState(() {
            account.balance = combinedBalance;
          });
        }
      });
    });
  }

  void _registerBus() {
    _accountModifiedSub = EventTaxiImpl.singleton().registerTo<AccountModifiedEvent>().listen((event) {
      if (event.deleted) {
        if (event.account!.selected) {
          Future.delayed(Duration(milliseconds: 50), () {
            setState(() {
              widget.accounts.where((a) => a!.index == StateContainer.of(context).selectedAccount!.index).forEach((account) {
                account!.selected = true;
              });
            });
          });
        }
        setState(() {
          widget.accounts.removeWhere((a) => a!.index == event.account!.index);
        });
      } else {
        // Name change
        setState(() {
          widget.accounts.removeWhere((a) => a!.index == event.account!.index);
          widget.accounts.add(event.account);
          widget.accounts.sort((a, b) => a!.index!.compareTo(b!.index!));
        });
      }
    });
  }

  void _destroyBus() {
    if (_accountModifiedSub != null) {
      _accountModifiedSub!.cancel();
    }
  }

  Future<void> _requestBalances(BuildContext context, List<Account?> accounts) async {
    List<String?> addresses = [];
    accounts.forEach((account) {
      if (account!.address != null) {
        addresses.add(account.address);
      }
    });
    try {
      AccountsBalancesResponse resp = await sl.get<AccountService>().requestAccountsBalances(addresses);
      await _handleAccountsBalancesResponse(resp);
    } catch (e) {
      sl.get<Logger>().e("Error", e);
    }
  }

  Future<void> _changeAccount(Account account, StateSetter setState) async {
    // Change account
    widget.accounts.forEach((a) {
      if (a!.selected) {
        setState(() {
          a.selected = false;
        });
      } else if (account.index == a.index) {
        setState(() {
          a.selected = true;
        });
      }
    });
    await sl.get<DBHelper>().changeAccount(account);
    EventTaxiImpl.singleton().fire(AccountChangedEvent(account: account, delayPop: true));
  }

  // get total account balances:
  String _getTotalBalance() {
    BigInt totalBalance = BigInt.zero;
    widget.accounts.forEach((account) {
      if (account!.balance != null) {
        totalBalance += BigInt.parse(account.balance!);
      }
    });
    return totalBalance.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.035,
        ),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //A container for the header
              Container(
                margin: EdgeInsets.only(top: 30.0, bottom: 15),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                child: Column(
                  children: <Widget>[
                    AutoSizeText(
                      CaseChange.toUpperCase(AppLocalization.of(context)!.accounts, context),
                      style: AppStyles.textStyleHeader(context),
                      maxLines: 1,
                      stepGranularity: 0.1,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5.0),
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
                                fontFamily: 'NunitoSans',
                              ),
                            ),
                            TextSpan(
                              text: getRawAsThemeAwareAmount(context, _getTotalBalance()),
                              style: TextStyle(
                                color: StateContainer.of(context).curTheme.primary60,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'NunitoSans',
                              ),
                            ),
                            TextSpan(
                              text: (StateContainer.of(context).nyanoMode) ? (" nyano)") : (" NANO)"),
                              style: TextStyle(
                                color: StateContainer.of(context).curTheme.primary60,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w100,
                                fontFamily: 'NunitoSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              //A list containing accounts
              Expanded(
                  key: expandedKey,
                  child: Stack(
                    children: <Widget>[
                      widget.accounts == null
                          ? Center(
                              child: Text("Loading"),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              itemCount: widget.accounts.length,
                              controller: _scrollController,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildAccountListItem(context, widget.accounts[index]!, setState);
                              },
                            ),
                      //List Top Gradient
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 20.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                StateContainer.of(context).curTheme.backgroundDark00!,
                                StateContainer.of(context).curTheme.backgroundDark!,
                              ],
                              begin: AlignmentDirectional(0.5, 1.0),
                              end: AlignmentDirectional(0.5, -1.0),
                            ),
                          ),
                        ),
                      ),
                      // List Bottom Gradient
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 20.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [StateContainer.of(context).curTheme.backgroundDark!, StateContainer.of(context).curTheme.backgroundDark00!],
                              begin: AlignmentDirectional(0.5, 1.0),
                              end: AlignmentDirectional(0.5, -1.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 15,
              ),
              //A row with Add Account button
              Row(
                children: <Widget>[
                  widget.accounts.length >= MAX_ACCOUNTS
                      ? SizedBox()
                      : AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY,
                          AppLocalization.of(context)!.addAccount,
                          Dimens.BUTTON_TOP_DIMENS,
                          disabled: _addingAccount,
                          onPressed: () {
                            if (!_addingAccount!) {
                              setState(() {
                                _addingAccount = true;
                              });
                              StateContainer.of(context).getSeed().then((seed) {
                                sl.get<DBHelper>().addAccount(seed, nameBuilder: AppLocalization.of(context)!.defaultNewAccountName).then((newAccount) {
                                  _requestBalances(context, [newAccount]);
                                  StateContainer.of(context).updateRecentlyUsedAccounts();
                                  widget.accounts.add(newAccount);
                                  setState(() {
                                    _addingAccount = false;
                                    widget.accounts.sort((a, b) => a!.index!.compareTo(b!.index!));
                                    // Scroll if list is full
                                    if (expandedKey.currentContext != null) {
                                      RenderBox box = expandedKey.currentContext!.findRenderObject() as RenderBox;
                                      if (widget.accounts.length * 72.0 >= box.size.height) {
                                        _scrollController.animateTo(
                                          newAccount!.index! * 72.0 > _scrollController.position.maxScrollExtent
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
              //A row with Close button
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY_OUTLINE,
                    AppLocalization.of(context)!.close,
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
      userOrAddress = account.user!.getDisplayName(ignoreNickname: true);
    } else {
      userOrAddress = account.address!.substring(0, 12) + "...";
    }

    return Slidable(
      closeOnScroll: true,
      endActionPane: _getSlideActionsForAccount(context, account, setState),
      child: TextButton(
          style: TextButton.styleFrom(
            primary: StateContainer.of(context).curTheme.text15,
            backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
            padding: EdgeInsets.all(0.0),
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
          child: Column(
            children: <Widget>[
              Divider(
                height: 2,
                color: StateContainer.of(context).curTheme.text15,
              ),
              Container(
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
                        margin: EdgeInsetsDirectional.only(
                            start: StateContainer.of(context).natriconOn! ? 8 : 20, end: StateContainer.of(context).natriconOn! ? 16 : 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: Icon(
                                          AppIcons.accountwallet,
                                          color: account.selected ? StateContainer.of(context).curTheme.success : StateContainer.of(context).curTheme.primary,
                                          size: 30,
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 30,
                                          alignment: AlignmentDirectional(0, 0.3),
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
                                ),
                                // Account name and address
                                Container(
                                  width: (MediaQuery.of(context).size.width - 116) * 0.5,
                                  margin: EdgeInsetsDirectional.only(start: StateContainer.of(context).natriconOn! ? 8.0 : 20.0),
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
                              alignment: AlignmentDirectional(1, 0),
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    // Main balance text
                                    TextSpan(
                                      text: '',
                                      children: [
                                        displayCurrencyAmount(
                                          context,
                                          TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: "NunitoSans",
                                              fontWeight: FontWeight.w900,
                                              color: StateContainer.of(context).curTheme.text,
                                              decoration: TextDecoration.lineThrough),
                                        ),
                                        TextSpan(
                                          text: (account.balance != null ? getCurrencySymbol(context) : "") +
                                              (account.balance != null && !account.selected
                                                  ? getRawAsThemeAwareAmount(context, account.balance)
                                                  : account.selected
                                                      ? StateContainer.of(context).wallet!.getAccountBalanceDisplay(context)
                                                      : ""),
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: "NunitoSans",
                                            fontWeight: FontWeight.w900,
                                            color: StateContainer.of(context).curTheme.text,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                style: TextStyle(fontSize: 16.0),
                                stepGranularity: 0.1,
                                minFontSize: 1,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Selected indicator
                    // Container(
                    //         height: 70,
                    //         width: 6,
                    //         color: account.selected ? StateContainer.of(context).curTheme.primary : Colors.transparent,
                    //       )
                    // handle bars:
                    Container(
                      width: 4,
                      height: 30,
                      margin: EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  ActionPane _getSlideActionsForAccount(BuildContext context, Account account, StateSetter setState) {
    List<Widget> _actions = [];

    _actions.add(SlidableAction(
        autoClose: false,
        borderRadius: BorderRadius.circular(5.0),
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
        foregroundColor: StateContainer.of(context).curTheme.primary,
        icon: Icons.edit,
        label: AppLocalization.of(context)!.edit,
        onPressed: (BuildContext context) async {
          await Future.delayed(Duration(milliseconds: 250));
          AccountDetailsSheet(account).mainBottomSheet(context);
          await Slidable.of(context)!.close();
        }));
    if (account.index! > 0) {
      _actions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: AppLocalization.of(context)!.hide,
          onPressed: (BuildContext context) {
            AppDialogs.showConfirmDialog(
                context,
                AppLocalization.of(context)!.hideAccountHeader,
                AppLocalization.of(context)!.removeAccountText.replaceAll("%1", AppLocalization.of(context)!.addAccount),
                CaseChange.toUpperCase(AppLocalization.of(context)!.yes, context), () async {
              await Future.delayed(Duration(milliseconds: 250));
              // Remove account
              await sl.get<DBHelper>().deleteAccount(account);
              EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: account, deleted: true));
              setState(() {
                widget.accounts.removeWhere((a) => a!.index == account.index);
              });
              await Slidable.of(context)!.close();
            }, cancelText: CaseChange.toUpperCase(AppLocalization.of(context)!.no, context));
          }));
    }

    return ActionPane(
      // motion: const DrawerMotion(),
      motion: const ScrollMotion(),
      extentRatio: (account.index! > 0) ? 0.5 : 0.25,
      // All actions are defined in the children parameter.
      children: _actions,
    );
  }
}
