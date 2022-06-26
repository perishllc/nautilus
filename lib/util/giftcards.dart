import 'package:flutter/cupertino.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';

import 'nanoutil.dart';

final BigInt rawPerNano = BigInt.from(10).pow(30);
final BigInt rawPerNyano = BigInt.from(10).pow(24);

class GiftCards {
  Future<BranchResponse> createGiftCard(
    BuildContext context, {
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

    final String paperWalletSeed = NanoSeeds.generateSeed();
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
}
