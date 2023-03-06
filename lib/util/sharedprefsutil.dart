import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/available_block_explorer.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/available_language.dart';
import 'package:wallet_flutter/model/available_themes.dart';
import 'package:wallet_flutter/model/currency_mode_setting.dart';
import 'package:wallet_flutter/model/device_lock_timeout.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/model/wallet.dart';
import 'package:wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/util/deviceutil.dart';
import 'package:wallet_flutter/util/encrypt.dart';
import 'package:wallet_flutter/util/random_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Price conversion preference values
enum PriceConversion { CURRENCY, NONE, HIDDEN }

enum ChartStatus { WEEK, MONTH, NINETY, ALL, HIDDEN }

/// Singleton wrapper for shared preferences
class SharedPrefsUtil {
  // Keys
  static const String first_launch_key = 'fkalium_first_launch';
  static const String seed_backed_up_key = 'fkalium_seed_backup';
  static const String app_uuid_key = 'fkalium_app_uuid';
  static const String price_conversion = 'fkalium_price_conversion_pref';
  static const String auth_method = 'fkalium_auth_method';
  static const String cur_currency = 'fkalium_currency_pref';
  static const String cur_language = 'fkalium_language_pref';
  static const String cur_theme = 'fkalium_theme_pref';
  static const String cur_explorer = 'fkalium_cur_explorer_pref';
  static const String user_representative = 'fkalium_user_rep'; // For when non-opened accounts have set a representative
  static const String firstcontact_added = 'fkalium_first_c_added';
  static const String notification_enabled = 'fkalium_notification_on';
  static const String contacts_enabled = 'fnautilus_contacts_on';
  static const String unopened_warning = 'fnautilus_unopened_warning';
  static const String funding_enabled = 'fnautilus_funding_on';
  static const String lock_kalium = 'fkalium_lock_dev';
  static const String kalium_lock_timeout = 'fkalium_lock_timeout';
  static const String has_shown_root_warning = 'fkalium_root_warn'; // If user has seen the root/jailbreak warning yet
  // For maximum pin attempts
  static const String pin_attempts = 'fkalium_pin_attempts';
  static const String pin_lock_until = 'fkalium_lock_duraton';
  // For certain keystore incompatible androids
  static const String use_legacy_storage = 'fkalium_legacy_storage';
  // Caching ninja API response
  static const String ninja_api_cache = 'fkalium_ninja_api_cache';
  // Natricon setting
  static const String use_natricon = 'fnautilus_use_natricon';
  // Nyanicon setting
  static const String use_nyanicon = 'fnautilus_use_nyanicon';
  // currency / nyano mode:
  static const String currency_mode = 'fnautilus_currency_mode';
  // spam prevention min-RAW for receives
  static const String min_raw_receive = 'fnautilus_min_raw_receive';
  // last time we checked for updates:
  static const String last_napi_users_check = 'fnautilus_last_napi_users_check';
  // store app version (for showing the change log):
  static const String app_version = 'fnautilus_app_version';
  // tracking permissions:
  static const String tracking_enabled = 'fnautilus_tracking_enabled';

  // xmr settings / data:
  // xmr on:
  static const String xmr_enabled = 'fnautilus_xmr_enabled';
  // xmr restore height:
  static const String xmr_restore_height = 'fnautilus_xmr_restore_height';
  // xmr wallet data:
  static const String xmr_wallet_data = 'fnautilus_xmr_wallet_data';

  // key derivation method:
  static const String key_derivation = 'fnautilus_key_derivation';

  // pro sub status (whether they have paid):
  static const String pro_sub_status = 'fnautilus_pro_sub_status';
  // whether they should automatically renew:
  static const String pro_renew_active = 'fnautilus_pro_renew_active';

  // RPC settings:
  // static const String http_url = 'fnautilus_http_url';
  // static const String ws_url = 'fnautilus_ws_url';
  static const String node_index = 'fnautilus_node_index';



  // For plain-text data
  Future<void> set(String key, dynamic value) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is String) {
      sharedPreferences.setString(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    }
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(key) ?? defaultValue;
  }

  Future<void> reload() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
  }

  /// Set a key with an expiry, expiry is in seconds
  Future<void> setWithExpiry(String key, dynamic value, int expiry) async {
    int expiryVal;
    if (expiry != -1) {
      final DateTime now = DateTime.now().toUtc();
      final DateTime expired = now.add(Duration(seconds: expiry));
      expiryVal = expired.millisecondsSinceEpoch;
    } else {
      expiryVal = expiry;
    }
    // ignore: always_specify_types
    final Map<String, dynamic> msg = {'data': value, 'expiry': expiryVal};
    final String serialized = json.encode(msg);
    await set(key, serialized);
  }

  /// Set a key with absolute expiry, expiry is in seconds
  Future<void> setWithAbsoluteExpiry(String key, dynamic value, int expiry) async {
    int expiryVal;
    if (expiry != -1) {
      expiryVal = expiry * 1000;
    } else {
      expiryVal = expiry;
    }
    // ignore: always_specify_types
    final Map<String, dynamic> msg = {'data': value, 'expiry': expiryVal};
    final String serialized = json.encode(msg);
    await set(key, serialized);
  }

  /// Get a key that has an expiry
  Future<dynamic> getWithExpiry(String key) async {
    final String? val = await get(key, defaultValue: null) as String?;
    if (val == null) {
      return null;
    }
    final Map<String, dynamic> msg = json.decode(val) as Map<String, dynamic>;
    if (msg['expiry'] != -1) {
      final DateTime expired = DateTime.fromMillisecondsSinceEpoch(msg['expiry'] as int);
      if (DateTime.now().toUtc().difference(expired).inMinutes > 0) {
        await remove(key);
        return null;
      }
    }
    return msg['data'];
  }

  Future<bool> remove(String key) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.remove(key);
  }

  // For encrypted data
  Future<void> setEncrypted(String key, String value) async {
    // Retrieve/Generate encryption password
    String? secret = await sl.get<Vault>().getEncryptionPhrase();
    if (secret == null) {
      secret = "${RandomUtil.generateEncryptionSecret(16)}:${RandomUtil.generateEncryptionSecret(8)}";
      await sl.get<Vault>().writeEncryptionPhrase(secret);
    }
    // Encrypt and save
    final Salsa20Encryptor encrypter = Salsa20Encryptor(secret.split(":")[0], secret.split(":")[1]);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, encrypter.encrypt(value));
  }

  Future<String?> getEncrypted(String key) async {
    final String? secret = await sl.get<Vault>().getEncryptionPhrase();
    if (secret == null) {
      return null;
    }
    // Decrypt and return
    final Salsa20Encryptor encrypter = Salsa20Encryptor(secret.split(":")[0], secret.split(":")[1]);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encrypted = prefs.get(key) as String?;
    if (encrypted == null) {
      return null;
    }
    return encrypter.decrypt(encrypted);
  }

  // Key-specific helpers
  Future<void> setSeedBackedUp(bool value) async {
    return set(seed_backed_up_key, value);
  }

  Future<bool?> getSeedBackedUp() async {
    return await get(seed_backed_up_key, defaultValue: false) as bool?;
  }

  Future<void> setHasSeenRootWarning() async {
    return set(has_shown_root_warning, true);
  }

  Future<bool> getHasSeenRootWarning() async {
    return await get(has_shown_root_warning, defaultValue: false) as bool;
  }

  Future<void> setFirstLaunch() async {
    return set(first_launch_key, false);
  }

  Future<bool> getFirstLaunch() async {
    return await get(first_launch_key, defaultValue: true) as bool;
  }

  Future<void> setFirstContactAdded(bool value) async {
    return set(firstcontact_added, value);
  }

  Future<bool> getFirstContactAdded() async {
    return await get(firstcontact_added, defaultValue: false) as bool;
  }

  Future<void> setAppVersion(String value) async {
    return set(app_version, value);
  }

  Future<String> getAppVersion() async {
    return await get(app_version, defaultValue: "1.0.0") as String;
  }

  Future<void> setUuid(String uuid) async {
    return setEncrypted(app_uuid_key, uuid);
  }

  Future<String?> getUuid() async {
    return getEncrypted(app_uuid_key);
  }

  Future<void> setPriceConversion(PriceConversion conversion) async {
    return set(price_conversion, conversion.index);
  }

  Future<PriceConversion> getPriceConversion() async {
    return PriceConversion.values[(await get(price_conversion, defaultValue: PriceConversion.CURRENCY.index) as int)];
  }

  Future<void> setAuthMethod(AuthenticationMethod method) async {
    return set(auth_method, method.getIndex());
  }

  Future<AuthenticationMethod> getAuthMethod() async {
    return AuthenticationMethod(
        AuthMethod.values[(await get(auth_method, defaultValue: AuthMethod.BIOMETRICS.index) as int)]);
  }

  Future<void> setCurrency(AvailableCurrency currency) async {
    return set(cur_currency, currency.getIndex());
  }

  Future<AvailableCurrency> getCurrency(Locale deviceLocale) async {
    return AvailableCurrency(AvailableCurrencyEnum.values[
        (await get(cur_currency, defaultValue: AvailableCurrency.getBestForLocale(deviceLocale).currency.index)
            as int)]);
  }

  Future<void> setLanguage(LanguageSetting language) async {
    return set(cur_language, language.getIndex());
  }

  Future<LanguageSetting> getLanguage() async {
    return LanguageSetting(
        AvailableLanguage.values[await get(cur_language, defaultValue: AvailableLanguage.DEFAULT.index) as int]);
  }

  Future<void> setTheme(ThemeSetting theme) async {
    return set(cur_theme, theme.getIndex());
  }

  Future<void> setBlockExplorer(AvailableBlockExplorer explorer) async {
    return set(cur_explorer, explorer.getIndex());
  }

  Future<AvailableBlockExplorer> getBlockExplorer() async {
    return AvailableBlockExplorer(AvailableBlockExplorerEnum
        .values[(await get(cur_explorer, defaultValue: AvailableBlockExplorerEnum.NANOLOOKER.index) as int)]);
  }

  Future<ThemeSetting> getTheme() async {
    final bool isDarkMode = SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
    final int defaultValue = isDarkMode ? ThemeOptions.NAUTILUS.index : ThemeOptions.INDIUM.index;
    return ThemeSetting(ThemeOptions.values[(await get(cur_theme, defaultValue: defaultValue) as int)]);
  }

  Future<void> setRepresentative(String? rep) async {
    return set(user_representative, rep);
  }

  Future<String> getRepresentative() async {
    return await get(user_representative, defaultValue: AppWallet.defaultRepresentative) as String;
  }

  Future<void> setNotificationsOn(bool value) async {
    return set(notification_enabled, value);
  }

  Future<bool> getNotificationsOn() async {
    final bool defaultValue;
    // Notifications off by default on iOS,
    if (Platform.isIOS) {
      defaultValue = false;
    } else {
      // as of android 13 we must ask for permission to send notifications:
      if (await DeviceUtil.isAndroid13OrGreater()) {
        defaultValue = false;
      } else {
        defaultValue = true;
      }
    }
    return await get(notification_enabled, defaultValue: defaultValue) as bool;
  }

  // If notifications have been set by user/app
  Future<bool> getNotificationsSet() async {
    if (await get(notification_enabled, defaultValue: null) == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> setContactsOn(bool value) async {
    return set(contacts_enabled, value);
  }

  Future<bool> getContactsOn() async {
    // Contacts false by default
    return await get(contacts_enabled, defaultValue: false) as bool;
  }

  // If contacts have been set by user/app
  Future<bool> getContactsSet() async {
    if (await get(contacts_enabled, defaultValue: null) == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> setUnopenedWarningOn(bool value) async {
    return set(unopened_warning, value);
  }

  Future<bool> getUnopenedWarningOn() async {
    // Contacts false by default
    return await get(unopened_warning, defaultValue: true) as bool;
  }

  // If contacts have been set by user/app
  Future<bool> getUnopenedWarningSet() async {
    if (await get(unopened_warning, defaultValue: null) == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> setFundingOn(bool value) async {
    return set(funding_enabled, value);
  }

  Future<bool> getFundingOn() async {
    // funding false by default
    return await get(funding_enabled, defaultValue: true) as bool;
  }

  Future<bool> getXmrEnabled() async {
    return await get(xmr_enabled, defaultValue: false) as bool;
  }

  Future<void> setXmrEnabled(bool value) async {
    return set(xmr_enabled, value);
  }

  Future<bool> getTrackingEnabled() async {
    bool defaultValue = false;
    if (Platform.isAndroid) {
      defaultValue = true;
    }
    return await get(tracking_enabled, defaultValue: defaultValue) as bool;
  }

  Future<void> setTrackingEnabled(bool value) async {
    return set(tracking_enabled, value);
  }

  Future<void> setLock(bool value) async {
    return set(lock_kalium, value);
  }

  Future<bool> getLock() async {
    return await get(lock_kalium, defaultValue: false) as bool;
  }

  Future<void> setLockTimeout(LockTimeoutSetting setting) async {
    return set(kalium_lock_timeout, setting.getIndex());
  }

  Future<LockTimeoutSetting> getLockTimeout() async {
    return LockTimeoutSetting(
        LockTimeoutOption.values[await get(kalium_lock_timeout, defaultValue: LockTimeoutOption.ONE.index) as int]);
  }

  // Locking out when max pin attempts exceeded
  Future<int> getLockAttempts() async {
    return await get(pin_attempts, defaultValue: 0) as int;
  }

  Future<void> incrementLockAttempts() async {
    await set(pin_attempts, (await getLockAttempts()) + 1);
  }

  Future<void> resetLockAttempts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(pin_attempts);
    await prefs.remove(pin_lock_until);
  }

  Future<bool> shouldLock() async {
    if (await get(pin_lock_until) != null || (await getLockAttempts()) >= 5) {
      return true;
    }
    return false;
  }

  Future<void> updateLockDate() async {
    final int attempts = await getLockAttempts();
    if (attempts >= 20) {
      // 4+ failed attempts
      await set(
          pin_lock_until, DateFormat.yMd().add_jms().format(DateTime.now().toUtc().add(const Duration(hours: 24))));
    } else if (attempts >= 15) {
      // 3 failed attempts
      await set(
          pin_lock_until, DateFormat.yMd().add_jms().format(DateTime.now().toUtc().add(const Duration(minutes: 15))));
    } else if (attempts >= 10) {
      // 2 failed attempts
      await set(
          pin_lock_until, DateFormat.yMd().add_jms().format(DateTime.now().toUtc().add(const Duration(minutes: 5))));
    } else if (attempts >= 5) {
      await set(
          pin_lock_until, DateFormat.yMd().add_jms().format(DateTime.now().toUtc().add(const Duration(minutes: 1))));
    }
  }

  Future<DateTime?> getLockDate() async {
    final String? lockDateStr = await get(pin_lock_until) as String?;
    if (lockDateStr == null) {
      return null;
    }
    return DateFormat.yMd().add_jms().parseUtc(lockDateStr);
  }

  Future<bool> useLegacyStorage() async {
    return await get(use_legacy_storage, defaultValue: false) as bool;
  }

  Future<void> setUseLegacyStorage() async {
    await set(use_legacy_storage, true);
  }

  Future<String?> getNinjaAPICache() async {
    return await get(ninja_api_cache, defaultValue: null) as String?;
  }

  Future<void> setNinjaAPICache(String data) async {
    await set(ninja_api_cache, data);
  }

  Future<String> getLastNapiUsersCheck() async {
    return await get(last_napi_users_check, defaultValue: "0") as String;
  }

  Future<void> setLastNapiUsersCheck(String data) async {
    await set(last_napi_users_check, data);
  }

  Future<void> setUseNatricon(bool useNatricon) async {
    return set(use_natricon, useNatricon);
  }

  Future<bool> getUseNatricon() async {
    return await get(use_natricon, defaultValue: false) as bool;
  }

  Future<void> setUseNyanicon(bool useNyanicon) async {
    return set(use_nyanicon, useNyanicon);
  }

  Future<bool> getUseNyanicon() async {
    return await get(use_nyanicon, defaultValue: false) as bool;
  }

  Future<void> setMinRawReceive(String minRawReceive) async {
    return set(min_raw_receive, minRawReceive);
  }

  Future<String> getMinRawReceive() async {
    return await get(min_raw_receive, defaultValue: "0") as String;
  }

  Future<String> getCurrencyMode() async {
    return await get(currency_mode, defaultValue: CurrencyModeSetting(CurrencyModeOptions.NANO).getDisplayName())
        as String;
  }

  Future<void> setCurrencyMode(String currencyMode) async {
    return set(currency_mode, currencyMode);
  }

  Future<void> dismissAlert(AlertResponseItem alert) async {
    await setWithExpiry("alert_${alert.id}", alert.id, -1);
  }

  Future<void> dismissAlertForWeek(AlertResponseItem alert) async {
    await setWithExpiry("alert_${alert.id}", alert.id, 604800);
  }

  Future<void> markAlertRead(AlertResponseItem alert) async {
    await setWithExpiry("alertread_${alert.id}", alert.id, -1);
  }

  Future<bool> alertIsRead(AlertResponseItem alert) async {
    final int? exists = await getWithExpiry("alertread_${alert.id}") as int?;
    if (exists == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> shouldShowAlert(AlertResponseItem alert) async {
    final int? exists = await getWithExpiry("alert_${alert.id}") as int?;
    if (exists == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> setXmrRestoreHeight(int height) async {
    return set(xmr_restore_height, height);
  }

  Future<int> getXmrRestoreHeight() async {
    return await get(xmr_restore_height, defaultValue: 0) as int;
  }

  Future<void> setXmrWalletData(String data) async {
    return set(xmr_wallet_data, data);
  }

  Future<String?> getXmrWalletData() async {
    return await get(xmr_wallet_data, defaultValue: null) as String?;
  }

  Future<void> setKeyDerivationMethod(String data) async {
    return set(key_derivation, data);
  }

  Future<String> getKeyDerivationMethod() async {
    return await get(key_derivation, defaultValue: "standard") as String;
  }

  // check again in a month:
  Future<void> setProStatus({int? relativeExpireTime, int? absoluteExpireTime}) async {
    if (relativeExpireTime != null) {
      return setWithExpiry(pro_sub_status, true, relativeExpireTime);
    } else if (absoluteExpireTime != null) {
      return setWithAbsoluteExpiry(pro_sub_status, true, absoluteExpireTime);
    } else {
      throw Exception("setProStatus requires either relative or absolute expire time");
    }
  }

  Future<bool> getProStatus() async {
    bool? proStatus = await getWithExpiry(pro_sub_status) as bool?;
    proStatus ??= false;
    return proStatus;
  }

  Future<void> setProRenewActive(bool active) async {
    return set(pro_renew_active, active);
  }

  Future<bool> getRenewActive() async {
    return await get(pro_renew_active, defaultValue: false) as bool;
  }

  // TODO:
  // Future<bool> alreadyDonated( alert) async {
  //   final int? exists = await getWithExpiry("alert_${alert.id}") as int?;
  //   if (exists == null) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  Future<void> setNodeIndex(int nodeIndex) async {
    return set(node_index, nodeIndex);
  }

  Future<int> getNodeIndex() async {
    return await get(node_index, defaultValue: 0) as int;
  }

  // For logging out
  Future<void> deleteAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(seed_backed_up_key);
    await prefs.remove(app_uuid_key);
    await prefs.remove(price_conversion);
    await prefs.remove(user_representative);
    await prefs.remove(cur_currency);
    await prefs.remove(auth_method);
    await prefs.remove(notification_enabled);
    await prefs.remove(contacts_enabled);
    await prefs.remove(unopened_warning);
    await prefs.remove(funding_enabled);
    await prefs.remove(lock_kalium);
    await prefs.remove(pin_attempts);
    await prefs.remove(pin_lock_until);
    await prefs.remove(kalium_lock_timeout);
    await prefs.remove(has_shown_root_warning);
    await prefs.remove(use_natricon);
    await prefs.remove(use_nyanicon);
    await prefs.remove(min_raw_receive);
    await prefs.remove(currency_mode);
    await prefs.remove(last_napi_users_check);
    await prefs.remove(ninja_api_cache);
    await prefs.remove(firstcontact_added);
    await prefs.remove(xmr_enabled);
    await prefs.remove(xmr_restore_height);
    await prefs.remove(xmr_wallet_data);
    await prefs.remove(key_derivation);
    await prefs.remove(cur_theme);
    await prefs.remove(pro_sub_status);
    await prefs.remove(pro_renew_active);

    // don't remove this preference since it's annoying when you log out:
    // await prefs.remove(tracking_enabled);
    // remove the dismissals of any important alerts:
    await prefs.remove("alert_4040");
    await prefs.remove("alert_4041");
    await prefs.remove("alert_4042");
    await prefs.remove("alert_4043");
  }
}
