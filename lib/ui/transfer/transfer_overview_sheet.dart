import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/wallet.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:wallet_flutter/network/model/response/account_info_response.dart';
import 'package:wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:wallet_flutter/network/model/response/process_response.dart';
import 'package:wallet_flutter/network/model/response/receivable_response.dart';
import 'package:wallet_flutter/network/model/response/receivable_response_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:wallet_flutter/ui/transfer/transfer_manual_entry_sheet.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/ui/widgets/sheets.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/user_data_util.dart';

class AppTransferOverviewSheet extends StatefulWidget {
  const AppTransferOverviewSheet() : super();

  @override
  AppTransferOverviewSheetState createState() => AppTransferOverviewSheetState();
}

class AppTransferOverviewSheetState extends State<AppTransferOverviewSheet> {
  static const int NUM_SWEEP = 15; // Number of accounts to sweep from a seed

  // accounts to private keys/account balances
  Map<String, AccountBalanceItem> privKeyBalanceMap = {};

  bool _animationOpen = false;

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context, {String? quickSeed}) {
    void manualEntryCallback(String seed) {
      Navigator.of(context).pop();
      startTransfer(context, seed, manualEntry: true);
    }

    // If there's a quick seed, open the manual transfer sheet
    if (quickSeed != null) {
      return TransferManualEntrySheet(
        quickSeed: quickSeed,
        validSeedCallback: manualEntryCallback,
      );
    } else {
      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: SafeArea(
            minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  // A container for the header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Emtpy SizedBox
                      const SizedBox(
                        height: 60,
                        width: 60,
                      ),
                      Column(
                        children: <Widget>[
                          Handlebars.horizontal(context),
                          // The header
                          Container(
                            margin: const EdgeInsets.only(top: 15.0),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                            child: AutoSizeText(
                              CaseChange.toUpperCase(Z.of(context).transferHeader, context),
                              style: AppStyles.textStyleHeader(context),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              stepGranularity: 0.1,
                            ),
                          ),
                        ],
                      ),
                      // Emtpy SizedBox
                      const SizedBox(
                        height: 60,
                        width: 60,
                      ),
                    ],
                  ),

                  // A container for the illustration and paragraphs
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.2,
                              maxWidth: MediaQuery.of(context).size.width * 0.6),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: SvgPicture.asset("assets/illustrations/transferfunds_paperwalletonly.svg",
                                    color: StateContainer.of(context).curTheme.text45,
                                    width: MediaQuery.of(context).size.width),
                              ),
                              Center(
                                child: SvgPicture.asset("assets/illustrations/transferfunds_start.svg",
                                    color: StateContainer.of(context).curTheme.primary,
                                    width: MediaQuery.of(context).size.width),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: AlignmentDirectional.centerStart,
                          margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 35 : 50, vertical: 20),
                          child: AutoSizeText(
                            Z
                                .of(context)
                                .transferIntro
                                .replaceAll("%1", Z.of(context).scanQrCode)
                                .replaceAll("%2", NonTranslatable.appName),
                            style: AppStyles.textStyleParagraph(context),
                            textAlign: TextAlign.start,
                            maxLines: 6,
                            stepGranularity: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        Z.of(context).scanQrCode,
                        Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                          UIUtil.cancelLockEvent();
                          final String? result = await UserDataUtil.getQRData(DataType.ADDRESS, context) as String?;
                          if (result == null) {
                            return;
                          }

                          if (!NanoUtil.isValidSeed(result)) {
                            UIUtil.showSnackbar(Z.of(context).qrInvalidSeed, context);
                            return;
                          }
                          startTransfer(context, result);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        Z.of(context).manualEntry,
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                          Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: TransferManualEntrySheet(
                              validSeedCallback: manualEntryCallback,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  Future<void> startTransfer(BuildContext context, String seed, {bool manualEntry = false}) async {
    // Show loading overlay
    _animationOpen = true;
    final AnimationType animationType =
        manualEntry ? AnimationType.TRANSFER_SEARCHING_MANUAL : AnimationType.TRANSFER_SEARCHING_QR;
    AppAnimation.animationLauncher(context, animationType, onPoppedCallback: () => _animationOpen = false);
    // Get accounts from seed
    final List<String> accounts = await getAccountsFromSeed(context, seed);
    try {
      final AccountsBalancesResponse resp = await sl.get<AccountService>().requestAccountsBalances(accounts);
      if (_animationOpen) {
        Navigator.of(context).pop();
      }
      final List<String> accountsToRemove = [];
      resp.balances!.forEach((String account, AccountBalanceItem balItem) {
        final BigInt balance = BigInt.parse(balItem.balance ?? "0");
        final BigInt receivable = BigInt.parse(balItem.receivable ?? "0");
        if (balance + receivable == BigInt.zero) {
          accountsToRemove.add(account);
        } else {
          // Update balance of this item
          privKeyBalanceMap[account]!.balance = balItem.balance;
          privKeyBalanceMap[account]!.receivable = balItem.receivable;
        }
      });
      accountsToRemove.forEach(privKeyBalanceMap.remove);
      if (privKeyBalanceMap.isEmpty) {
        UIUtil.showSnackbar(Z.of(context).transferNoFunds.replaceAll("%2", NonTranslatable.currencyName), context);
        return;
      }
      // Go to confirmation screen
      EventTaxiImpl.singleton().fire(TransferConfirmEvent(balMap: privKeyBalanceMap));
      Navigator.of(context).pop();
    } catch (e) {
      sl.get<Logger>().e("error", e);
      if (_animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).sendError, context);
    }
  }

  Future<BigInt> getGiftCardBalance(BuildContext context, String seed) async {
    // Get accounts from seed
    final List<String> accounts = await getAccountsFromSeed(context, seed);
    try {
      final AccountsBalancesResponse resp = await sl.get<AccountService>().requestAccountsBalances(accounts);

      if (_animationOpen) {
        Navigator.of(context).pop();
      }
      final List<String> accountsToRemove = [];
      BigInt totalBalance = BigInt.zero;
      resp.balances!.forEach((String account, AccountBalanceItem balItem) {
        final BigInt balance = BigInt.parse(balItem.balance ?? "0");
        final BigInt receivable = BigInt.parse(balItem.receivable ?? "0");
        if (balance + receivable == BigInt.zero) {
          accountsToRemove.add(account);
        } else {
          // Update balance of this item
          privKeyBalanceMap[account]!.balance = balItem.balance;
          privKeyBalanceMap[account]!.receivable = balItem.receivable;
          totalBalance += balance + receivable;
        }
      });
      accountsToRemove.forEach(privKeyBalanceMap.remove);
      if (privKeyBalanceMap.isEmpty) {
        return BigInt.zero;
      }

      // return privKeyBalanceMap;
      return totalBalance;
    } catch (e) {
      sl.get<Logger>().e("error", e);
    }
    return BigInt.zero;
  }

  Future<void> startAutoTransfer(BuildContext context, String seed, AppWallet wallet) async {
    // Show loading overlay
    _animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.TRANSFER_SEARCHING_MANUAL,
        onPoppedCallback: () => _animationOpen = false);

    // Get accounts from seed
    final List<String> accounts = await getAccountsFromSeed(context, seed);
    BigInt amountTransferred = BigInt.zero;
    try {
      final AccountsBalancesResponse resp = await sl.get<AccountService>().requestAccountsBalances(accounts);
      final List<String> accountsToRemove = [];
      resp.balances!.forEach((String account, AccountBalanceItem balItem) {
        final BigInt balance = BigInt.parse(balItem.balance!);
        final BigInt receivable = BigInt.parse(balItem.receivable!);
        if (balance + receivable == BigInt.zero) {
          accountsToRemove.add(account);
        } else {
          // Update balance of this item
          privKeyBalanceMap[account]!.balance = balItem.balance;
          privKeyBalanceMap[account]!.receivable = balItem.receivable;
        }
      });
      accountsToRemove.forEach(privKeyBalanceMap.remove);
      if (privKeyBalanceMap.isEmpty) {
        UIUtil.showSnackbar(Z.of(context).transferNoFunds, context, durationMs: 5000);
        return;
      }

      amountTransferred =
          await const AppTransferConfirmSheet().createState().autoProcessWallets(privKeyBalanceMap, wallet.address!);
    } catch (e) {
      sl.get<Logger>().e("error", e);
      if (_animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).giftProcessError, context, durationMs: 5000);
    }

    // sleep for a couple seconds to flex the animation / since this happens pretty fast
    await Future<dynamic>.delayed(const Duration(seconds: 2));
    if (_animationOpen) {
      Navigator.of(context).pop();
    }
    if (amountTransferred == BigInt.zero) {
      UIUtil.showSnackbar(Z.of(context).giftProcessError, context, durationMs: 5000);
    } else {
      UIUtil.showSnackbar(Z.of(context).giftProcessSuccess, context, durationMs: 5000);
    }
  }

  Future<void> startAutoRefund(BuildContext context, String seed, String refundAddress) async {
    // Show loading overlay
    _animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.TRANSFER_SEARCHING_MANUAL,
        onPoppedCallback: () => _animationOpen = false);

    // sleep for a couple seconds to flex the animation:
    await Future<dynamic>.delayed(const Duration(seconds: 3));
    // Get accounts from seed
    final List<String> accounts = await getAccountsFromSeed(context, seed);
    try {
      final AccountsBalancesResponse resp = await sl.get<AccountService>().requestAccountsBalances(accounts);
      final List<String> accountsToRemove = [];
      resp.balances!.forEach((String account, AccountBalanceItem balItem) {
        final BigInt balance = BigInt.parse(balItem.balance!);
        final BigInt receivable = BigInt.parse(balItem.receivable!);
        if (balance + receivable == BigInt.zero) {
          accountsToRemove.add(account);
        } else {
          // Update balance of this item
          privKeyBalanceMap[account]!.balance = balItem.balance;
          privKeyBalanceMap[account]!.receivable = balItem.receivable;
        }
      });
      accountsToRemove.forEach(privKeyBalanceMap.remove);
      if (privKeyBalanceMap.isEmpty) {
        UIUtil.showSnackbar(Z.of(context).transferNoFunds, context);
        return;
      }

      const AppTransferConfirmSheet().createState().refundWallets(privKeyBalanceMap, refundAddress);
      //.autoProcessWallets(privKeyBalanceMap);
      // Go to confirmation screen
      // EventTaxiImpl.singleton().fire(TransferConfirmEvent(balMap: privKeyBalanceMap));
      // Navigator.of(context).pop();
    } catch (e) {
      sl.get<Logger>().e("error", e);
      if (_animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(Z.of(context).giftProcessError, context);
    }
    if (_animationOpen) {
      Navigator.of(context).pop();
    }
    UIUtil.showSnackbar(Z.of(context).giftRefundSuccess, context, durationMs: 5000);
  }

  Future<void> receiveAtIndex(BuildContext context, String seed, int index, String derivationMethod) async {
    final String receivingAccount = await NanoUtil.uniSeedToAddress(seed, index, derivationMethod);
    final String receivingAccountPrivKey = await NanoUtil.uniSeedToPrivate(seed, index, derivationMethod);

    final AccountsBalancesResponse resp = await sl.get<AccountService>().requestAccountsBalances([receivingAccount]);
    final AccountBalanceItem balanceItem = resp.balances!.values.first;
    balanceItem.privKey = receivingAccountPrivKey;

    BigInt totalTransferred = BigInt.zero;

    // sleep for a couple seconds to ensure it's confirmed
    // await Future<dynamic>.delayed(const Duration(seconds: 2));

    final AccountInfoResponse accountInfoResp = await sl.get<AccountService>().getAccountInfo(receivingAccount);
    if (!accountInfoResp.unopened) {
      balanceItem.frontier = accountInfoResp.frontier;
    }
    // Receive receivable blocks
    final ReceivableResponse pr = await sl.get<AccountService>().getReceivable(receivingAccount, 10);
    final Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks!;
    for (final String hash in receivableBlocks.keys) {
      final ReceivableResponseItem? item = receivableBlocks[hash];
      if (balanceItem.frontier != null) {
        final ProcessResponse resp = await sl.get<AccountService>().requestReceive(AppWallet.defaultRepresentative,
            balanceItem.frontier, item!.amount, hash, receivingAccount, balanceItem.privKey);
        if (resp.hash != null) {
          balanceItem.frontier = resp.hash;
          totalTransferred += BigInt.parse(item.amount!);
        }
      } else {
        final ProcessResponse resp =
            await sl.get<AccountService>().requestOpen(item!.amount, hash, receivingAccount, balanceItem.privKey);
        if (resp.hash != null) {
          balanceItem.frontier = resp.hash;
          totalTransferred += BigInt.parse(item.amount!);
        }
      }
      // Hack that waits for blocks to be confirmed
      await Future<dynamic>.delayed(const Duration(milliseconds: 600));
    }
  }

  Future<void> sendAtIndex(BuildContext context, String seed, int index, String derivationMethod, String address,
      String amountRaw, bool maxSend) async {
    final String sendingAccount = await NanoUtil.uniSeedToAddress(seed, index, derivationMethod);

    // Hack that waits for blocks to be confirmed
    await Future<dynamic>.delayed(const Duration(milliseconds: 600));

    // // AccountBalanceItem balanceItem = AccountBalanceItem(balance: );
    final AccountInfoResponse accountInfoResp = await sl.get<AccountService>().getAccountInfo(sendingAccount);

    final String privKey = await NanoUtil.uniSeedToPrivate(
      await StateContainer.of(context).getSeed(),
      index,
      derivationMethod,
    );

    final ProcessResponse resp = await sl.get<AccountService>().requestSend(
          StateContainer.of(context).wallet!.representative,
          accountInfoResp.frontier,
          amountRaw,
          address,
          sendingAccount,
          privKey,
          max: maxSend,
        );
    // Hack that waits for blocks to be confirmed
    await Future<dynamic>.delayed(const Duration(milliseconds: 600));
  }

  // Get NUM_SWEEP accounts from seed to request balances for
  Future<List<String>> getAccountsFromSeed(BuildContext context, String seed) async {
    final List<String> accountsToRequest = [];
    String privKey;
    String address;
    // Get NUM_SWEEP private keys + accounts from seed
    for (int i = 0; i < NUM_SWEEP; i++) {
      privKey = NanoUtil.seedToPrivate(seed, i);
      address = NanoUtil.seedToAddress(seed, i);
      // Don't add this if it is the currently logged in account
      if (address != StateContainer.of(context).wallet!.address) {
        privKeyBalanceMap.putIfAbsent(address, () => AccountBalanceItem(privKey: privKey));
        accountsToRequest.add(address);
      }
    }
    // Also treat this seed as a private key
    address = NanoAccounts.createAccount(NonTranslatable.accountType, NanoKeys.createPublicKey(seed));
    if (address != StateContainer.of(context).wallet!.address) {
      privKeyBalanceMap.putIfAbsent(address, () => AccountBalanceItem(privKey: seed));
      accountsToRequest.add(address);
    }
    return accountsToRequest;
  }
}
