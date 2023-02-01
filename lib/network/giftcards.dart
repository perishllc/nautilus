import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/network/model/record_types.dart';
import 'package:wallet_flutter/network/model/status_types.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/ui/gift/gift_complete_sheet.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/numberutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../util/nanoutil.dart';

final BigInt rawPerNano = BigInt.from(10).pow(30);
final BigInt rawPerNyano = BigInt.from(10).pow(24);

class GiftCards {
  static const String SERVER_ADDRESS_GIFT = "https://meta.perish.co/gift";

  Future<BranchResponse<dynamic>> createGiftCard(
    BuildContext context, {
    required String paperWalletSeed,
    String? amountRaw,
    String? memo,
    bool requireCaptcha = false,
  }) async {
    final String paperWalletAccount = NanoUtil.seedToAddress(paperWalletSeed, 0);

    String giftDescription = "Get the app to open this gift card!";

    final BigInt amountBigInt = BigInt.parse(amountRaw ?? "0");
    if (amountBigInt > BigInt.parse("1000000000000000000000000000000")) {
      // more than 1 NANO:
      final BigInt rawPerNano = BigInt.from(10).pow(30);
      final String formattedAmount = NumberUtil.getRawAsUsableString(amountRaw, rawPerNano);
      giftDescription = "Someone sent you $formattedAmount NANO! Get the app to open this gift card!";
    }

    final BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch/giftcard/$paperWalletAccount',
        //canonicalUrl: '',
        title: "Nautilus Wallet",
        contentDescription: giftDescription,
        keywords: ['Nautilus', "Gift Card"],
        publiclyIndex: false,
        locallyIndex: true,
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata('seed', paperWalletSeed)
          ..addCustomMetadata('address', paperWalletAccount)
          ..addCustomMetadata('memo', memo ?? "")
          ..addCustomMetadata('signature', "")
          ..addCustomMetadata('nonce', "")
          ..addCustomMetadata('from_address', StateContainer.of(context).wallet!.address) // TODO: sign these:
          ..addCustomMetadata('require_captcha', requireCaptcha)
          ..addCustomMetadata('amount_raw', amountRaw));

    final BranchLinkProperties lp = BranchLinkProperties(
        //alias: 'flutterplugin', //define link url,
        channel: 'nautilusapp',
        feature: 'gift',
        stage: 'new share');

    final BranchResponse<dynamic> response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    return response;
  }

  Future<String?> _getDeviceUUID() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        return iosDeviceInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        late String androidId;
        const AndroidId androidIdPlugin = AndroidId();

        androidId = await androidIdPlugin.getId() ?? "failed";
        if (androidId == "failed") {
          return null;
        }

        return androidId;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<dynamic> createSplitGiftCard({
    String? seed,
    String? requestingAccount,
    String? splitAmountRaw,
    String? memo,
    bool requireCaptcha = false,
  }) async {
    final String? appCheckToken = await FirebaseAppCheck.instance.getToken();
    if (appCheckToken == null) {
      return {
        "error": "Something went wrong",
      };
    }
    final http.Response response = await http.post(
      Uri.parse(SERVER_ADDRESS_GIFT),
      headers: {"Content-type": "application/json", "X-Firebase-AppCheck": appCheckToken},
      body: json.encode(
        <String, dynamic>{
          "action": "gift_split_create",
          "seed": seed,
          "requesting_account": requestingAccount,
          "split_amount_raw": splitAmountRaw,
          "memo": memo,
          "require_captcha": requireCaptcha,
        },
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"success": false, "error": "Something went wrong"};
    }
  }

  Future<dynamic> giftCardInfo({
    String? giftUUID,
    String? requestingAccount,
  }) async {
    final String? appCheckToken = await FirebaseAppCheck.instance.getToken();
    if (appCheckToken == null) {
      return {
        "error": "Something went wrong",
      };
    }
    final http.Response response = await http.post(Uri.parse(SERVER_ADDRESS_GIFT),
        headers: {"Content-type": "application/json", "X-Firebase-AppCheck": appCheckToken},
        body: json.encode(
          {
            "action": "gift_info",
            "gift_uuid": giftUUID,
            "requesting_account": requestingAccount,
            "requesting_device_uuid": await _getDeviceUUID(),
          },
        ));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "something went wrong"};
    }
  }

  Future<dynamic> giftCardClaim({
    String? giftUUID,
    String? requestingAccount,
    String? hcaptchaToken,
  }) async {
    final String? appCheckToken = await FirebaseAppCheck.instance.getToken();
    if (appCheckToken == null) {
      return {
        "error": "Something went wrong",
      };
    }
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String runningVersion = packageInfo.version;
    final http.Response response = await http.post(Uri.parse(SERVER_ADDRESS_GIFT),
        headers: {
          "Content-type": "application/json",
          "X-Firebase-AppCheck": appCheckToken,
          "app-version": runningVersion,
          "hcaptcha-token": hcaptchaToken ?? ""
        },
        body: json.encode(
          {
            "action": "gift_claim",
            "gift_uuid": giftUUID,
            "requesting_account": requestingAccount,
            "requesting_device_uuid": await _getDeviceUUID(),
          },
        ));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "something went wrong: ${response.body}"};
    }
  }

  // Future<String> createSplitGiftCardLink(BuildContext context,
  //     {required String paperWalletSeed, String? amountRaw, String? splitAmountRaw, String? memo}) async {
  //   final String paperWalletAccount = NanoUtil.seedToAddress(paperWalletSeed, 0);

  //   sl<AccountService>().createSplitGiftCard(seed: paperWalletSeed, requestingAccount: paperWalletAccount, memo: memo, splitAmountRaw: splitAmountRaw);

  //   // final String paperWalletAccount = NanoUtil.seedToAddress(paperWalletSeed, 0);

  //   // final BranchUniversalObject buo = BranchUniversalObject(
  //   //     canonicalIdentifier: 'flutter/branch',
  //   //     //canonicalUrl: '',
  //   //     title: 'Nautilus Gift Card',
  //   //     contentDescription: 'Get the app to open this gift card!',
  //   //     keywords: ['Nautilus', "Gift Card"],
  //   //     publiclyIndex: true,
  //   //     locallyIndex: true,
  //   //     contentMetadata: BranchContentMetaData()
  //   //       ..addCustomMetadata('seed', paperWalletSeed)
  //   //       ..addCustomMetadata('address', paperWalletAccount)
  //   //       ..addCustomMetadata('memo', memo ?? "")
  //   //       ..addCustomMetadata('senderAddress', StateContainer.of(context).wallet!.address) // TODO: sign these:
  //   //       ..addCustomMetadata('signature', "")
  //   //       ..addCustomMetadata('nonce', "")
  //   //       ..addCustomMetadata('amount_raw', amountRaw));

  //   // final BranchLinkProperties lp = BranchLinkProperties(
  //   //     //alias: 'flutterplugin', //define link url,
  //   //     channel: 'nautilusapp',
  //   //     feature: 'gift',
  //   //     stage: 'new share');

  //   // final BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
  //   // return response;
  //   return "";
  // }

  Future<bool> handleResponse(
    BuildContext context, {
    required bool success,
    required String destination,
    required String amountRaw,
    required String paperWalletSeed,
    String? hash,
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
      Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
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
