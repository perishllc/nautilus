import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/util/encrypt.dart';
import 'package:wallet_flutter/util/random_util.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Singleton for keystore access methods in android/iOS
class Vault {
  static const String seedKey = 'fkalium_seed';
  static const String encryptionKey = 'fkalium_secret_phrase';
  static const String pinKey = 'fkalium_pin';
  static const String plausiblePinKey = 'fnautilus_plausible_pin';
  static const String sessionKey = 'fencsess_key';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<bool> legacy() async {
    return sl.get<SharedPrefsUtil>().useLegacyStorage();
  }

  // Re-usable
  Future<String?> _write(String key, String? value) async {
    if (await legacy()) {
      await setEncrypted(key, value);
    } else {
      await secureStorage.write(key: key, value: value);
    }
    return value;
  }

  Future<String?> _read(String key, {String? defaultValue}) async {
    if (await legacy()) {
      return getEncrypted(key);
    }
    return await secureStorage.read(key: key) ?? defaultValue;
  }

  Future<void> deleteAll() async {
    if (await legacy()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(encryptionKey);
      await prefs.remove(seedKey);
      await prefs.remove(pinKey);
      await prefs.remove(plausiblePinKey);
      await prefs.remove(sessionKey);
      return;
    }
    return secureStorage.deleteAll();
  }

  // Specific keys
  Future<String?> getSeed() async {
    return _read(seedKey);
  }

  Future<String?> setSeed(String? seed) async {
    return _write(seedKey, seed);
  }

  Future<void> deleteSeed() async {
    if (await legacy()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(seedKey);
    }
    return secureStorage.delete(key: seedKey);
  }

  Future<String?> getEncryptionPhrase() async {
    return _read(encryptionKey);
  }

  Future<String?> writeEncryptionPhrase(String secret) async {
    return _write(encryptionKey, secret);
  }

  /// Used to keep the seed in-memory in the session without being plaintext
  Future<String> getSessionKey() async {
    String? key = await _read(sessionKey);
    key ??= await updateSessionKey();
    return key;
  }

  Future<String> updateSessionKey() async {
    final String key = RandomUtil.generateEncryptionSecret(25);
    await writeSessionKey(key);
    return key;
  }

  Future<String?> writeSessionKey(String key) async {
    return _write(sessionKey, key);
  }

  Future<void> deleteEncryptionPhrase() async {
    if (await legacy()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(encryptionKey);
    }
    return secureStorage.delete(key: encryptionKey);
  }

  Future<String?> getPin() async {
    return _read(pinKey);
  }

  Future<String?> writePin(String pin) async {
    return _write(pinKey, pin);
  }

  Future<void> deletePin() async {
    if (await legacy()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(pinKey);
    }
    return secureStorage.delete(key: pinKey);
  }

  Future<String?> getPlausiblePin() async {
    return _read(plausiblePinKey);
  }

  Future<String?> writePlausiblePin(String pin) async {
    return _write(plausiblePinKey, pin);
  }

  Future<void> deletePlausiblePin() async {
    if (await legacy()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(plausiblePinKey);
    }
    return secureStorage.delete(key: plausiblePinKey);
  }

  // For encrypted data
  Future<void> setEncrypted(String key, String? value) async {
    final String? secret = await getSecret();
    if (secret == null) return;
    // Decrypt and return
    final Salsa20Encryptor encrypter = Salsa20Encryptor(
        secret.substring(0, secret.length - 8),
        secret.substring(secret.length - 8));
    // Encrypt and save
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, encrypter.encrypt(value!));
  }

  Future<String?> getEncrypted(String key) async {
    final String? secret = await getSecret();
    if (secret == null) return null;
    // Decrypt and return
    final Salsa20Encryptor encrypter = Salsa20Encryptor(
        secret.substring(0, secret.length - 8),
        secret.substring(secret.length - 8));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encrypted = prefs.get(key) as String?;
    if (encrypted == null) return null;
    return encrypter.decrypt(encrypted);
  }

  static const MethodChannel _channel = MethodChannel('fappchannel');

  Future<String?> getSecret() async {
    return _channel.invokeMethod('getSecret');
  }
}
