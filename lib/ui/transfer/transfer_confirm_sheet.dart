import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/model/wallet.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_info_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/process_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/receivable_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/receivable_response_item.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';

class AppTransferConfirmSheet extends StatefulWidget {
  const AppTransferConfirmSheet({this.privKeyBalanceMap, this.errorCallback}) : super();

  final Map<String, AccountBalanceItem>? privKeyBalanceMap;
  final Function? errorCallback;

  @override
  AppTransferConfirmSheetState createState() => AppTransferConfirmSheetState();
}

class AppTransferConfirmSheetState extends State<AppTransferConfirmSheet> {
  // Total amount there is to transfer
  late BigInt totalToTransfer;
  late String totalAsReadableAmount;
  // Need to be received by current account
  ReceivableResponse? accountReceivable;
  // Whether animation overlay is open
  late bool animationOpen;

  // StateContainer instead
  StateContainerState? state;

  @override
  void initState() {
    super.initState();
    totalToTransfer = BigInt.zero;
    totalAsReadableAmount = "";
    animationOpen = false;
    widget.privKeyBalanceMap!.forEach((String account, AccountBalanceItem accountBalanceItem) {
      totalToTransfer += BigInt.parse(accountBalanceItem.balance!) + BigInt.parse(accountBalanceItem.receivable!);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    state = StateContainer.of(context);
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
              margin: const EdgeInsets.only(top: 30.0, left: 70, right: 70),
              child: AutoSizeText(
                CaseChange.toUpperCase(Z.of(context).transferHeader, context),
                style: AppStyles.textStyleHeader(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                stepGranularity: 0.1,
              ),
            ),

            // A container for the paragraphs
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 35 : 60),
                        child: Text(
                          Z.of(context).transferConfirmInfo.replaceAll("%1", getThemeAwareAccuracyAmount(context, totalToTransfer.toString())),
                          style: AppStyles.textStyleParagraphPrimary(context),
                          textAlign: TextAlign.start,
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 35 : 60),
                        child: Text(
                          Z.of(context).transferConfirmInfoSecond,
                          style: AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.start,
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 35 : 60),
                        child: Text(
                          Z.of(context).transferConfirmInfoThird,
                          style: AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.start,
                        )),
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Send Button
                    AppButton.buildAppButton(
                        context, AppButtonType.PRIMARY, CaseChange.toUpperCase(Z.of(context).confirm, context), Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      animationOpen = true;
                      AppAnimation.animationLauncher(context, AnimationType.TRANSFER_TRANSFERRING, onPoppedCallback: () => animationOpen = false);
                      await processWallets();
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    // Scan QR Code Button
                    AppButton.buildAppButton(
                        context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).cancel.toUpperCase(), Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getPrivKey(int index) async {
    String? seed;
    if (StateContainer.of(context).encryptedSecret != null) {
      seed = NanoHelpers.byteToHex(NanoCrypt.decrypt(StateContainer.of(context).encryptedSecret, await sl.get<Vault>().getSessionKey()));
    } else {
      seed = await sl.get<Vault>().getSeed();
    }
    return NanoUtil.seedToPrivate(seed!, index);
  }

  Future<void> processWallets() async {
    BigInt totalTransferred = BigInt.zero;
    try {
      state!.lockCallback();
      for (final String account in widget.privKeyBalanceMap!.keys) {
        final AccountBalanceItem balanceItem = widget.privKeyBalanceMap![account]!;
        // Get frontiers first
        AccountInfoResponse resp = await sl.get<AccountService>().getAccountInfo(account);
        if (!resp.unopened) {
          balanceItem.frontier = resp.frontier;
        }
        // Receive receivable blocks
        final ReceivableResponse pr = await sl.get<AccountService>().getReceivable(account, 20);
        final Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks!;
        for (final String hash in receivableBlocks.keys) {
          final ReceivableResponseItem? item = receivableBlocks[hash];
          if (balanceItem.frontier != null) {
            final ProcessResponse resp = await sl
                .get<AccountService>()
                .requestReceive(AppWallet.defaultRepresentative, balanceItem.frontier, item!.amount, hash, account, balanceItem.privKey);
            if (resp.hash != null) {
              balanceItem.frontier = resp.hash;
              totalTransferred += BigInt.parse(item.amount!);
            }
          } else {
            final ProcessResponse resp = await sl.get<AccountService>().requestOpen(item!.amount, hash, account, balanceItem.privKey);
            if (resp.hash != null) {
              balanceItem.frontier = resp.hash;
              totalTransferred += BigInt.parse(item.amount!);
            }
          }
          // Hack that waits for blocks to be confirmed
          await Future<dynamic>.delayed(const Duration(milliseconds: 300));
        }
        // Process send from this account
        resp = await sl.get<AccountService>().getAccountInfo(account);
        final ProcessResponse sendResp = await sl
            .get<AccountService>()
            .requestSend(AppWallet.defaultRepresentative, resp.frontier, resp.balance, state!.wallet!.address, account, balanceItem.privKey, max: true);
        if (sendResp.hash != null) {
          totalTransferred += BigInt.parse(balanceItem.balance!);
        }
      }
    } catch (e) {
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      widget.errorCallback!();
      sl.get<Logger>().e("Error processing wallet", e);
      return;
    } finally {
      state!.unlockCallback();
    }
    try {
      state!.lockCallback();
      // Receive all new blocks to our own account
      final ReceivableResponse pr = await sl.get<AccountService>().getReceivable(state!.wallet!.address, 20, includeActive: true);
      final Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks!;
      for (final String hash in receivableBlocks.keys) {
        final ReceivableResponseItem? item = receivableBlocks[hash];
        if (state!.wallet!.openBlock != null) {
          final ProcessResponse resp = await sl.get<AccountService>().requestReceive(state!.wallet!.representative, state!.wallet!.frontier, item!.amount, hash,
              state!.wallet!.address, await _getPrivKey(state!.selectedAccount!.index!));
          if (resp.hash != null) {
            state!.wallet!.frontier = resp.hash;
          }
        } else {
          final ProcessResponse resp = await sl.get<AccountService>().requestOpen(
              item!.amount, hash, state!.wallet!.address, await _getPrivKey(state!.selectedAccount!.index!),
              representative: state!.wallet!.representative);
          if (resp.hash != null) {
            state!.wallet!.frontier = resp.hash;
            state!.wallet!.openBlock = resp.hash;
          }
        }
      }
      state!.requestUpdate();
    } catch (e) {
      // Less-important error
      sl.get<Logger>().e("Error processing wallet", e);
    } finally {
      state!.unlockCallback();
    }
    EventTaxiImpl.singleton().fire(TransferCompleteEvent(amount: totalTransferred));
    if (animationOpen) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop();
  }

  Future<BigInt> autoProcessWallets(Map<String, AccountBalanceItem> privKeyBalanceMap, String address) async {
    BigInt totalTransferred = BigInt.zero;
    try {
      // state.lockCallback();
      for (final String account in privKeyBalanceMap.keys) {
        final AccountBalanceItem balanceItem = privKeyBalanceMap[account]!;
        // Get frontiers first
        AccountInfoResponse resp = await sl.get<AccountService>().getAccountInfo(account);
        if (!resp.unopened) {
          balanceItem.frontier = resp.frontier;
        }
        // Receive receivable blocks
        final ReceivableResponse pr = await sl.get<AccountService>().getReceivable(account, 20);
        final Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks!;
        for (final String hash in receivableBlocks.keys) {
          final ReceivableResponseItem? item = receivableBlocks[hash];
          if (balanceItem.frontier != null) {
            final ProcessResponse resp = await sl
                .get<AccountService>()
                .requestReceive(AppWallet.defaultRepresentative, balanceItem.frontier, item!.amount, hash, account, balanceItem.privKey);
            if (resp.hash != null) {
              balanceItem.frontier = resp.hash;
              totalTransferred += BigInt.parse(item.amount!);
            }
          } else {
            final ProcessResponse resp = await sl.get<AccountService>().requestOpen(item!.amount, hash, account, balanceItem.privKey);
            if (resp.hash != null) {
              balanceItem.frontier = resp.hash;
              totalTransferred += BigInt.parse(item.amount!);
            }
          }
          // Hack that waits for blocks to be confirmed
          await Future<dynamic>.delayed(const Duration(milliseconds: 300));
        }
        // Process send from this account
        resp = await sl.get<AccountService>().getAccountInfo(account);
        final ProcessResponse sendResp = await sl
            .get<AccountService>()
            .requestSend(AppWallet.defaultRepresentative, resp.frontier, resp.balance, address, account, balanceItem.privKey, max: true);
        if (sendResp.hash != null) {
          totalTransferred += BigInt.parse(balanceItem.balance!);
        }
      }
    } catch (e) {
      sl.get<Logger>().e("Error processing wallet", e);
      return BigInt.zero;
    } finally {
      // state.unlockCallback();
    }
    // try {
      // state.lockCallback();
      // Receive all new blocks to our own account? doesn't seem to work:
      // if (state != null) {
      //   throw Exception("state is null, can't receive own blocks");
      // }
      // final ReceivableResponse pr = await sl.get<AccountService>().getReceivable(state!.wallet!.address, 20, includeActive: true);
      // final Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks!;
      // for (final String hash in receivableBlocks.keys) {
      //   final ReceivableResponseItem? item = receivableBlocks[hash];
      //   if (state!.wallet!.openBlock != null) {
      //     final ProcessResponse resp = await sl.get<AccountService>().requestReceive(state!.wallet!.representative, state!.wallet!.frontier, item!.amount, hash,
      //         state!.wallet!.address, await _getPrivKey(state!.selectedAccount!.index!));
      //     if (resp.hash != null) {
      //       state!.wallet!.frontier = resp.hash;
      //     }
      //   } else {
      //     final ProcessResponse resp = await sl.get<AccountService>().requestOpen(
      //         item!.amount, hash, state!.wallet!.address, await _getPrivKey(state!.selectedAccount!.index!),
      //         representative: state!.wallet!.representative);
      //     if (resp.hash != null) {
      //       state!.wallet!.frontier = resp.hash;
      //       state!.wallet!.openBlock = resp.hash;
      //     }
      //   }
      // }
      // state!.requestUpdate();
    // } catch (error) {
    //   // Less-important error
    //   sl.get<Logger>().e("Error processing wallet", error);
    // } finally {
    //   // state.unlockCallback();
    // }

    if (totalTransferred != BigInt.zero) {
      // create a txdata to be shown in place of the tx:
      // TODO: create a txdata for gift card open:
      // var newWalletLoad = new TXData(from_address: from_address, to_address: to_address, amount_raw: totalTransferred.toString());
      // create a local memo object to show the gift card creation details:
      // var uuid = Uuid();
      // var newGiftTXData = new TXData(
      //   from_address: StateContainer.of(context).wallet.address,
      //   to_address: destinationAltered,
      //   amount_raw: widget.amountRaw,
      //   uuid: "LOCAL:" + uuid.v4(),
      //   block: resp.hash,
      //   record_type: RecordTypes.GIFT_OPEN,
      //   status: "opened",
      //   metadata: widget.paperWalletSeed + RecordTypes.SEPARATOR + response.result,
      //   is_acknowledged: false,
      //   is_fulfilled: false,
      //   is_request: false,
      //   is_memo: false,
      //   request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      //   memo: widget.memo,
      //   height: 0,
      // );
      // // add it to the database:
      // await sl.get<DBHelper>().addTXData(newGiftTXData);
      // await StateContainer.of(context).updateTXMemos();
    }
    return totalTransferred;
    // EventTaxiImpl.singleton().fire(TransferCompleteEvent(amount: totalTransferred));
    // if (animationOpen) {
    //   Navigator.of(context).pop();
    // }
    // Navigator.of(context).pop();
  }

  Future<BigInt> refundWallets(Map<String, AccountBalanceItem> privKeyBalanceMap, String address) async {
    BigInt totalTransferred = BigInt.zero;
    try {
      // state.lockCallback();
      for (final String account in privKeyBalanceMap.keys) {
        final AccountBalanceItem balanceItem = privKeyBalanceMap[account]!;
        // Get frontiers first
        AccountInfoResponse resp = await sl.get<AccountService>().getAccountInfo(account);
        if (!resp.unopened) {
          balanceItem.frontier = resp.frontier;
        }
        // Receive receivable blocks
        final ReceivableResponse pr = await sl.get<AccountService>().getReceivable(account, 20);
        final Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks!;
        for (final String hash in receivableBlocks.keys) {
          final ReceivableResponseItem? item = receivableBlocks[hash];
          if (balanceItem.frontier != null) {
            final ProcessResponse resp = await sl
                .get<AccountService>()
                .requestReceive(AppWallet.defaultRepresentative, balanceItem.frontier, item!.amount, hash, account, balanceItem.privKey);
            if (resp.hash != null) {
              balanceItem.frontier = resp.hash;
              totalTransferred += BigInt.parse(item.amount!);
            }
          } else {
            final ProcessResponse resp = await sl.get<AccountService>().requestOpen(item!.amount, hash, account, balanceItem.privKey);
            if (resp.hash != null) {
              balanceItem.frontier = resp.hash;
              totalTransferred += BigInt.parse(item.amount!);
            }
          }
          // Hack that waits for blocks to be confirmed
          await Future<dynamic>.delayed(const Duration(milliseconds: 300));
        }
        // Process send from this account
        resp = await sl.get<AccountService>().getAccountInfo(account);
        final ProcessResponse sendResp = await sl
            .get<AccountService>()
            .requestSend(AppWallet.defaultRepresentative, resp.frontier, resp.balance, address, account, balanceItem.privKey, max: true);
        if (sendResp.hash != null) {
          totalTransferred += BigInt.parse(balanceItem.balance!);
        }
      }
    } catch (e) {
      // if (animationOpen) {
      //   Navigator.of(context).pop();
      // }
      // widget.errorCallback();
      sl.get<Logger>().e("Error processing wallet", e);
      return BigInt.zero;
    } finally {
      // state.unlockCallback();
    }
    return totalTransferred;
    // EventTaxiImpl.singleton().fire(TransferCompleteEvent(amount: totalTransferred));
    // if (animationOpen) {
    //   Navigator.of(context).pop();
    // }
    // Navigator.of(context).pop();
  }
}
