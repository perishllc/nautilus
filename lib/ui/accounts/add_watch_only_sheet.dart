import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:quiver/strings.dart';

class AddWatchOnlyAccountSheet extends StatefulWidget {
  const AddWatchOnlyAccountSheet({Key? key, required this.accounts}) : super(key: key);

  final List<Account> accounts;

  _AddWatchOnlyAccountSheetState createState() => _AddWatchOnlyAccountSheetState();
}

class _AddWatchOnlyAccountSheetState extends State<AddWatchOnlyAccountSheet> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();

  bool? _addingAccount;
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
  }

  @override
  void dispose() {
    // _destroyBus();
    super.dispose();
  }

  void _registerBus() {
    _accountModifiedSub =
        EventTaxiImpl.singleton().registerTo<AccountModifiedEvent>().listen((AccountModifiedEvent event) {
      if (event.deleted) {
        if (event.account!.selected) {
          Future.delayed(const Duration(milliseconds: 50), () {
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
                            CaseChange.toUpperCase(AppLocalization.of(context)!.addWatchOnlyAccount, context),
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

              // enter address:

              const SizedBox(
                height: 15,
              ),
              //A row with Add Account button
              Row(
                children: <Widget>[
                  if (widget.accounts.length < MAX_ACCOUNTS)
                    AppButton.buildAppButton(
                      context,
                      AppButtonType.PRIMARY,
                      AppLocalization.of(context)!.addAccount,
                      Dimens.BUTTON_TOP_DIMENS,
                      disabled: _addingAccount,
                      onPressed: () {},
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
}
