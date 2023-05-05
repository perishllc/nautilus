import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:intl/intl.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:wallet_flutter/util/numberutil.dart';

/// Main wallet object that's passed around the app via state
class AppWallet {
  // AppWallet({
  //   this.address,
  //   this.user,
  //   this.username,
  //   this.frontier,
  //   this.openBlock,
  //   this.representativeBlock,
  //   this.blockCount,
  //   this.watchOnly = false,
  //   this.confirmationHeight = -1,
  //   this.loading = true,
  //   this.xmrLoading = true,
  //   this.historyLoading = true,
  //   this.solidsLoading = true,
  //   this.unifiedLoading = true,
  //   // this.representative = nautilusRepresentative,
  //   this.localCurrencyPrice = "0",
  //   this.xmrPrice = "0",
  //   BigInt? accountBalance,
  //   List<AccountHistoryResponseItem>? history,
  //   List<TXData>? solids,
  //   List<dynamic>? unified,
  // })  : accountBalance = accountBalance ?? BigInt.zero,
  //       history = history ?? [],
  //       solids = solids ?? [],
  //       unified = unified ?? [];

  AppWallet({
    this.address,
    this.user,
    this.username,
    this.frontier,
    this.openBlock,
    this.representativeBlock,
    this.blockCount,
    this.watchOnly = false,
    this.confirmationHeight = -1,
    this.loading = true,
    this.xmrLoading = true,
    this.historyLoading = true,
    this.solidsLoading = true,
    this.unifiedLoading = true,
    this.representative = "",
    this.localCurrencyPrice = "0",
    this.xmrPrice = "0",
    BigInt? accountBalance,
    List<AccountHistoryResponseItem>? history,
    List<TXData>? solids,
    List<dynamic>? unified,
  })  : accountBalance = accountBalance ?? BigInt.zero,
        history = history ?? [],
        solids = solids ?? [],
        unified = unified ?? [] {
    if (representative.isEmpty) {
      if (NonTranslatable.accountType == NanoAccountType.NANO) {
        representative = AppWallet.nautilusRepresentative;
      } else {
        representative = AppWallet.potasiusRepresentative;
      }
    }
  }

  // the default is randomized but in case the user is offline during account creation we still need a default:
  static String defaultRepresentative =
      "${NonTranslatable.currencyPrefix}38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579";
  static const String nautilusRepresentative = "nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579";
  static const String potasiusRepresentative = "ban_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579";

  bool loading; // Whether or not app is initially loading
  bool historyLoading; // Whether or not we have received initial account history response
  bool xmrLoading;
  bool solidsLoading;
  bool unifiedLoading;
  bool watchOnly;
  BigInt accountBalance;
  String? address;
  User? user;
  String? username;
  String? frontier;
  String? openBlock;
  String? representativeBlock;
  String representative;
  String localCurrencyPrice;
  String? xmrPrice;
  int? blockCount;
  int confirmationHeight;
  List<AccountHistoryResponseItem> history;
  List<TXData> solids;
  List<dynamic> unified;

  String getLocalCurrencyBalance(BuildContext context, AvailableCurrency currency, {String locale = "en_US"}) {
    final BigInt rawPerCur =
        (NonTranslatable.accountType == NanoAccountType.NANO) ? NumberUtil.rawPerNano : NumberUtil.rawPerBanano;

    final Decimal converted =
        Decimal.parse(localCurrencyPrice) * NumberUtil.getRawAsDecimal(accountBalance.toString(), rawPerCur);
    return NumberFormat.currency(locale: locale, symbol: currency.getCurrencySymbol()).format(converted.toDouble());
  }

  String? get localCurrencyConversion {
    return localCurrencyPrice;
  }
}
