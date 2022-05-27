import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/themes.dart';

/// Main wallet object that's passed around the app via state
class AppWallet {
  // the default is randomized but in case the user is offline during account creation we still need a default:
  static String defaultRepresentative = 'nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579';

  bool _loading; // Whether or not app is initially loading
  bool _historyLoading; // Whether or not we have received initial account history response
  bool _requestsLoading;
  bool _unifiedLoading;
  String _address;
  String _username;
  BigInt _accountBalance;
  String _frontier;
  String _openBlock;
  String _representativeBlock;
  String _representative;
  String _localCurrencyPrice;
  String _btcPrice;
  int _blockCount;
  int confirmationHeight;
  List<AccountHistoryResponseItem> _history;
  List<TXData> _requests;
  List<dynamic> _unified;

  AppWallet(
      {String address,
      String username,
      BigInt accountBalance,
      String frontier,
      String openBlock,
      String representativeBlock,
      String representative,
      String localCurrencyPrice,
      String btcPrice,
      int blockCount,
      List<AccountHistoryResponseItem> history,
      List<TXData> requests,
      bool loading,
      bool historyLoading,
      bool requestsLoading,
      this.confirmationHeight = -1}) {
    this._address = address;
    this._username = username;
    this._accountBalance = accountBalance ?? BigInt.zero;
    this._frontier = frontier;
    this._openBlock = openBlock;
    this._representativeBlock = representativeBlock;
    this._representative = representative;
    this._localCurrencyPrice = localCurrencyPrice ?? "0";
    this._btcPrice = btcPrice ?? "0";
    this._blockCount = blockCount ?? 0;
    this._history = history ?? /*new List<AccountHistoryResponseItem>()*/ [];
    this._requests = requests ?? /*new List<TXData>()*/ [];
    this._unified = unified ?? /*new List<dynamic>();*/ [];
    this._loading = loading ?? true;
    this._historyLoading = historyLoading ?? true;
    this._requestsLoading = requestsLoading ?? true;
    this._unifiedLoading = unifiedLoading ?? true;
  }

  String get address => _address;

  set address(String address) {
    this._address = address;
  }

  String get username => _username;

  set username(String username) {
    this._username = username;
  }

  BigInt get accountBalance => _accountBalance;

  set accountBalance(BigInt accountBalance) {
    this._accountBalance = accountBalance;
  }

  // Get pretty account balance version
  String getAccountBalanceDisplay(BuildContext context) {
    if (accountBalance == null) {
      return "0";
    }

    if (StateContainer.of(context).nyanoMode) {
      return NumberUtil.getRawAsNyanoString(_accountBalance.toString());
    } else {
      return NumberUtil.getRawAsUsableString(_accountBalance.toString());
    }
  }

  String getLocalCurrencyPrice(AvailableCurrency currency, {String locale = "en_US"}) {
    Decimal converted = Decimal.parse(_localCurrencyPrice) * NumberUtil.getRawAsUsableDecimal(_accountBalance.toString());
    return NumberFormat.currency(locale: locale, symbol: currency.getCurrencySymbol()).format(converted.toDouble());
  }

  set localCurrencyPrice(String value) {
    _localCurrencyPrice = value;
  }

  String get localCurrencyConversion {
    return _localCurrencyPrice;
  }

  String get btcPrice {
    Decimal converted = Decimal.parse(_btcPrice) * NumberUtil.getRawAsUsableDecimal(_accountBalance.toString());
    // Show 4 decimal places for BTC price if its >= 0.0001 BTC, otherwise 6 decimals
    if (converted >= Decimal.parse("0.0001")) {
      return new NumberFormat("#,##0.0000", "en_US").format(converted.toDouble());
    } else {
      return new NumberFormat("#,##0.000000", "en_US").format(converted.toDouble());
    }
  }

  set btcPrice(String value) {
    _btcPrice = value;
  }

  String get representative {
    return _representative ?? defaultRepresentative;
  }

  set representative(String value) {
    _representative = value;
  }

  String get representativeBlock => _representativeBlock;

  set representativeBlock(String value) {
    _representativeBlock = value;
  }

  String get openBlock => _openBlock;

  set openBlock(String value) {
    _openBlock = value;
  }

  String get frontier => _frontier;

  set frontier(String value) {
    _frontier = value;
  }

  int get blockCount => _blockCount;

  set blockCount(int value) {
    _blockCount = value;
  }

  List<AccountHistoryResponseItem> get history => _history;

  set history(List<AccountHistoryResponseItem> value) {
    _history = value;
  }

  List<TXData> get requests => _requests;

  set requests(List<TXData> value) {
    _requests = value;
  }

  List<dynamic> get unified => _unified;

  set unified(List<dynamic> value) {
    _unified = value;
  }

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
  }

  bool get historyLoading => _historyLoading;

  set historyLoading(bool value) {
    _historyLoading = value;
  }

  bool get requestsLoading => _requestsLoading;

  set requestsLoading(bool value) {
    _requestsLoading = value;
  }

  bool get unifiedLoading => _unifiedLoading;

  set unifiedLoading(bool value) {
    _unifiedLoading = value;
  }
}
