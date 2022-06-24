import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';

/// Main wallet object that's passed around the app via state
class AppWallet {
  // the default is randomized but in case the user is offline during account creation we still need a default:
  static String? defaultRepresentative = 'nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579';
  static String nautilusRepresentative = 'nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579';

  bool? _loading; // Whether or not app is initially loading
  bool? _historyLoading; // Whether or not we have received initial account history response
  bool? _solidsLoading;
  bool? _unifiedLoading;
  String? _address;
  User? _user;
  String? _username;
  late BigInt _accountBalance;
  String? _frontier;
  String? _openBlock;
  String? _representativeBlock;
  String? _representative;
  String? _localCurrencyPrice;
  String? _btcPrice;
  int? _blockCount;
  int confirmationHeight;
  List<AccountHistoryResponseItem>? _history;
  List<TXData>? _solids;
  List<dynamic>? _unified;

  AppWallet(
      {String? address,
      User? user,
      String? username,
      BigInt? accountBalance,
      String? frontier,
      String? openBlock,
      String? representativeBlock,
      String? representative,
      String? localCurrencyPrice,
      String? btcPrice,
      int? blockCount,
      List<AccountHistoryResponseItem>? history,
      List<TXData>? solids,
      bool? loading,
      bool? historyLoading,
      bool? requestsLoading,
      this.confirmationHeight = -1}) {
    this._address = address;
    this._user = user;
    this._username = username;
    this._accountBalance = accountBalance ?? BigInt.zero;
    this._frontier = frontier;
    this._openBlock = openBlock;
    this._representativeBlock = representativeBlock;
    this._representative = representative;
    this._localCurrencyPrice = localCurrencyPrice ?? "0";
    this._btcPrice = btcPrice ?? "0";
    this._blockCount = blockCount ?? 0;
    this._history = history ?? [];
    this._solids = solids ?? [];
    this._unified = unified ?? [];
    this._loading = loading ?? true;
    this._historyLoading = historyLoading ?? true;
    this._solidsLoading = solidsLoading ?? true;
    this._unifiedLoading = unifiedLoading ?? true;
  }

  String? get address => _address;

  set address(String? address) {
    this._address = address;
  }

  String? get username => _username;

  set username(String? username) {
    this._username = username;
  }

  User? get user => _user;

  set user(User? user) {
    this._user = user;
  }

  BigInt get accountBalance => _accountBalance;

  set accountBalance(BigInt accountBalance) {
    this._accountBalance = accountBalance;
  }

  // // Get pretty account balance version
  // String getAccountBalanceDisplay(BuildContext context) {
  //   if (accountBalance == null) {
  //     return "0";
  //   }

  //   if (StateContainer.of(context).nyanoMode) {
  //     return NumberUtil.getRawAsNyanoString(_accountBalance.toString());
  //   } else {
  //     return NumberUtil.getRawAsUsableString(_accountBalance.toString());
  //   }
  // }

  String getLocalCurrencyPrice(BuildContext context, AvailableCurrency currency, {String? locale = "en_US"}) {
    final BigInt rawPerCur = StateContainer.of(context).nyanoMode ? rawPerNyano : rawPerNano;
    // Decimal converted =
    //     Decimal.parse(_localCurrencyPrice!) * NumberUtil.getRawAsUsableDecimal(_accountBalance.toString());
    Decimal converted = Decimal.parse(_btcPrice!) * NumberUtil.getRawAsDecimal(_accountBalance.toString(), rawPerCur);
    return NumberFormat.currency(locale: locale, symbol: currency.getCurrencySymbol()).format(converted.toDouble());
  }

  set localCurrencyPrice(String? value) {
    _localCurrencyPrice = value;
  }

  String? get localCurrencyConversion {
    return _localCurrencyPrice;
  }

  String? get representative {
    return _representative ?? defaultRepresentative;
  }

  set representative(String? value) {
    _representative = value;
  }

  String? get representativeBlock => _representativeBlock;

  set representativeBlock(String? value) {
    _representativeBlock = value;
  }

  String? get openBlock => _openBlock;

  set openBlock(String? value) {
    _openBlock = value;
  }

  String? get frontier => _frontier;

  set frontier(String? value) {
    _frontier = value;
  }

  int? get blockCount => _blockCount;

  set blockCount(int? value) {
    _blockCount = value;
  }

  List<AccountHistoryResponseItem>? get history => _history;

  set history(List<AccountHistoryResponseItem>? value) {
    _history = value;
  }

  List<TXData>? get solids => _solids;

  set solids(List<TXData>? value) {
    _solids = value;
  }

  List<dynamic>? get unified => _unified;

  set unified(List<dynamic>? value) {
    _unified = value;
  }

  bool? get loading => _loading;

  set loading(bool? value) {
    _loading = value;
  }

  bool? get historyLoading => _historyLoading;

  set historyLoading(bool? value) {
    _historyLoading = value;
  }

  bool? get solidsLoading => _solidsLoading;

  set solidsLoading(bool? value) {
    _solidsLoading = value;
  }

  bool? get unifiedLoading => _unifiedLoading;

  set unifiedLoading(bool? value) {
    _unifiedLoading = value;
  }
}
