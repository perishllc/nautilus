import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/network/metadata_service.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/box.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:uuid/uuid.dart';

class CardActions {
  // TX / Card Action functions:
  static Future<void> resendRequest(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.REQUEST, onPoppedCallback: () => animationOpen = false);

    bool sendFailed = false;

    // send the request again:
    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    final String privKey = await NanoUtil.uniSeedToPrivate(
      await StateContainer.of(context).getSeed(),
      StateContainer.of(context).selectedAccount!.index!,
      derivationMethod,
    );

    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid = NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData requestTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: true,
      is_memo: false,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(requestTXData);

    try {
      // encrypt the memo if it's not empty:
      String? encryptedMemo;
      if (txDetails.memo != null && txDetails.memo!.isNotEmpty) {
        encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      }
      await sl.get<MetadataService>().requestPayment(
          txDetails.to_address, txDetails.amount_raw, StateContainer.of(context).wallet!.address, signature, nonceHex, encryptedMemo, localUuid);
    } catch (error) {
      sl.get<Logger>().v("Error encrypting memo: $error");
      sendFailed = true;
    }

    // if the memo send failed delete the object:
    if (sendFailed) {
      sl.get<Logger>().v("request send failed, deleting TXData object");
      // remove failed txdata from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // show error:
      UIUtil.showSnackbar(Z.of(context).requestSendError, context, durationMs: 5000);
    } else {
      // delete the old request by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(Z.of(context).requestSentButNotReceived, context, durationMs: 5000);
    }
    await StateContainer.of(context).updateSolids();
    await StateContainer.of(context).updateTXMemos();
    await StateContainer.of(context).updateUnified(false);

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> resendMemo(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.SEND_MESSAGE, onPoppedCallback: () => animationOpen = false);

    bool memoSendFailed = false;

    // send the memo again:
    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    final String privKey = await NanoUtil.uniSeedToPrivate(
      await StateContainer.of(context).getSeed(),
      StateContainer.of(context).selectedAccount!.index!,
      derivationMethod,
    );

    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid = NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData memoTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: false,
      is_memo: true,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(memoTXData);

    try {
      // encrypt the memo:
      final String encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      await sl.get<MetadataService>().sendTXMemo(txDetails.to_address!, StateContainer.of(context).wallet!.address!, txDetails.amount_raw, signature, nonceHex,
          encryptedMemo, txDetails.block, localUuid);
    } catch (e) {
      memoSendFailed = true;
    }

    // if the memo send failed delete the object:
    if (memoSendFailed) {
      sl.get<Logger>().v("memo send failed, deleting TXData object");
      // remove from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // show error:
      UIUtil.showSnackbar(Z.of(context).sendMemoError, context, durationMs: 5000);
    } else {
      // delete the old memo by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(Z.of(context).memoSentButNotReceived, context, durationMs: 5000);
      await StateContainer.of(context).updateTXMemos();
    }

    Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
  }

  static Future<void> resendMessage(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.SEND_MESSAGE, onPoppedCallback: () => animationOpen = false);

    bool sendFailed = false;

    // send the message again:
    final String privKey = NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!);
    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid = NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData messageTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: false,
      is_memo: false,
      is_message: true,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(messageTXData);

    try {
      // encrypt the memo if it's not empty:
      String? encryptedMemo;
      if (txDetails.memo != null && txDetails.memo!.isNotEmpty) {
        encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      }
      await sl
          .get<MetadataService>()
          .sendTXMessage(txDetails.to_address!, StateContainer.of(context).wallet!.address!, signature, nonceHex, encryptedMemo!, localUuid);
    } catch (error) {
      sl.get<Logger>().v("Error encrypting memo: $error");
      sendFailed = true;
    }

    // if the memo send failed delete the object:
    if (sendFailed) {
      sl.get<Logger>().v("request send failed, deleting TXData object");
      // remove failed txdata from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // show error:
      UIUtil.showSnackbar(Z.of(context).sendMemoError, context, durationMs: 5000);
    } else {
      // delete the old request by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(Z.of(context).memoSentButNotReceived, context, durationMs: 5000);
    }
    await StateContainer.of(context).updateSolids();
    await StateContainer.of(context).updateUnified(false);

    Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
  }

  static Future<void> payTX(BuildContext context, TXData txDetails) async {
    String? address;
    if (txDetails.is_request || txDetails.is_memo) {
      if (txDetails.to_address == StateContainer.of(context).wallet!.address) {
        address = txDetails.from_address;
      } else {
        address = txDetails.to_address;
      }
    } else {
      // address = item.account;
      address = txDetails.from_address;
    }
    // See if a contact
    final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(address!);
    final String? quickSendAmount = txDetails.amount_raw;
    // a bit of a hack since send sheet doesn't have a way to tell if we're in nyano mode on creation:
    // if (StateContainer.of(context).nyanoMode) {
    //   quickSendAmount = "${quickSendAmount!}000000";
    // }

    // Go to send with address
    await Sheets.showAppHeightNineSheet(
        context: context,
        widget: SendSheet(
          localCurrency: StateContainer.of(context).curCurrency,
          address: address,
          quickSendAmount: quickSendAmount,
          user: user,
        ));
  }
}
