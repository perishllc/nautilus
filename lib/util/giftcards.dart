import 'package:flutter/cupertino.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/network/model/record_types.dart';
import 'package:nautilus_wallet_flutter/network/model/status_types.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/ui/generate/generate_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:uuid/uuid.dart';

import 'nanoutil.dart';

final BigInt rawPerNano = BigInt.from(10).pow(30);
final BigInt rawPerNyano = BigInt.from(10).pow(24);

class GiftCards {
  Future<BranchResponse> createGiftCard(
    BuildContext context, {
    required String paperWalletSeed,
    String? amountRaw,
    String? memo,
  }) async {
    // final ProcessResponse resp = await sl.get<AccountService>().requestSend(
    //     StateContainer.of(context).wallet!.representative,
    //     StateContainer.of(context).wallet!.frontier,
    //     widget.amountRaw,
    //     widget.destination,
    //     StateContainer.of(context).wallet!.address,
    //     NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!),
    //     max: widget.maxSend);

    final String paperWalletAccount = NanoUtil.seedToAddress(paperWalletSeed, 0);

    // StateContainer.of(context).wallet!.frontier = resp.hash;
    // StateContainer.of(context).wallet!.accountBalance += BigInt.parse(widget.amountRaw!);

    final BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        //canonicalUrl: '',
        title: 'Nautilus Gift Card',
        contentDescription: 'Get the app to open this gift card!',
        keywords: ['Nautilus', "Gift Card"],
        publiclyIndex: true,
        locallyIndex: true,
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata('seed', paperWalletSeed)
          ..addCustomMetadata('address', paperWalletAccount)
          ..addCustomMetadata('memo', memo ?? "")
          ..addCustomMetadata('senderAddress', StateContainer.of(context).wallet!.address) // TODO: sign these:
          ..addCustomMetadata('signature', "")
          ..addCustomMetadata('nonce', "")
          ..addCustomMetadata('amount_raw', amountRaw));

    final BranchLinkProperties lp = BranchLinkProperties(
        //alias: 'flutterplugin', //define link url,
        channel: 'nautilusapp',
        feature: 'gift',
        stage: 'new share');

    final BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    return response;
  }

  Future<bool> handleResponse(
    BuildContext context, {
    required bool success,
    required String destination,
    required String amountRaw,
    required String hash,
    required String paperWalletSeed,
    String? localCurrency,
    String? link,
    String? memo,
  }) async {
    if (success) {
      // create a local memo object to show the gift card creation details:
      const Uuid uuid = Uuid();
      final TXData newGiftTXData = TXData(
        from_address: StateContainer.of(context).wallet!.address,
        to_address: destination,
        amount_raw: amountRaw,
        uuid: "LOCAL:${uuid.v4()}",
        block: hash,
        record_type: RecordTypes.GIFT_LOAD,
        status: StatusTypes.CREATE_SUCCESS,
        metadata: paperWalletSeed + RecordTypes.SEPARATOR + link!,
        is_acknowledged: false,
        is_fulfilled: false,
        is_request: false,
        is_memo: false,
        request_time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        memo: memo,
        height: 0,
      );
      // add it to the database:
      await sl.get<DBHelper>().addTXData(newGiftTXData);
      await StateContainer.of(context).updateTXMemos();

      // Show complete
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      StateContainer.of(context).requestUpdate();

      Sheets.showAppHeightNineSheet(
          context: context,
          closeOnTap: false,
          removeUntilHome: true,
          widget: GenerateCompleteSheet(
            amountRaw: amountRaw,
            destination: destination,
            localAmount: localCurrency,
            link: link,
            walletSeed: paperWalletSeed,
          ));
      return true;
    } else {
      // attempt to refund the transaction?!:
      await AppTransferOverviewSheet().startAutoTransfer(context, paperWalletSeed, StateContainer.of(context).wallet);

      // create a local memo object to show the gift card creation details:
      const Uuid uuid = Uuid();
      final TXData newGiftTXData = TXData(
        from_address: StateContainer.of(context).wallet!.address,
        to_address: destination,
        amount_raw: amountRaw,
        uuid: "LOCAL:${uuid.v4()}",
        block: hash,
        record_type: RecordTypes.GIFT_LOAD,
        status: StatusTypes.CREATE_FAILED,
        metadata: paperWalletSeed + RecordTypes.SEPARATOR + StatusTypes.CREATE_FAILED,
        request_time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        memo: memo,
        height: 0,
      );
      // add it to the database:
      await sl.get<DBHelper>().addTXData(newGiftTXData);
      await StateContainer.of(context).updateTXMemos();
      return false;
    }
  }
}