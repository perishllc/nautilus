import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:wallet_flutter/service_locator.dart';

// AccountService singleton
class AuthService {
  // Constructor
  AuthService() {}

  // Server Connection Strings
  static String BASE_SERVER_ADDRESS = "nautilus.perish.co";
  // static const String DEV_SERVER_ADDRESS = "node-local.perish.co:5076";
  static const String DEV_SERVER_ADDRESS = "35.139.167.170:5076";
  static String HTTP_PROTO = "https://";
  static String WS_PROTO = "wss://";

  static String HTTP_URL = "nautilus.perish.co";
  static String WS_URL = "nautilus.perish.co";

  // auth:
  static String AUTH_SERVER = "https://auth.perish.co";

  final Logger log = sl.get<Logger>();

  // curl --request GET 'https://auth.perish.co/seed-backup/:id'

  // curl --request POST 'https://auth.perish.co/seed-backup/:id'

  Future<String?> getEncryptedSeed(String identifier) async {
    try {
      final http.Response resp = await http.get(
        Uri.parse("$AUTH_SERVER/seed-backup/$identifier"),
        headers: {"Accept": "application/json"},
      );
      if (resp.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> json = jsonDecode(resp.body) as Map<String, dynamic>;
      return json["encrypted_seed"] as String?;
    } catch (e) {
      log.e(e);
      return null;
    }
  }

  Future<bool> setEncryptedSeed(String identifier, String encryptedSeed) async {
    final http.Response resp = await http.post(
      Uri.parse("$AUTH_SERVER/seed-backup"),
      headers: {"Accept": "application/json"},
      body: json.encode(
        <String, String>{
          "identifier": identifier,
          "encrypted_seed": encryptedSeed,
        },
      ),
    );

    if (resp.statusCode != 200) {
      return false;
    }

    return true;
  }

  Future<bool> entryExists(String identifier) async {
    try {
      final http.Response resp = await http.get(
        Uri.parse("$AUTH_SERVER/seed-exists/$identifier"),
        headers: <String, String>{"Accept": "application/json"},
      );
      if (resp.body.contains("not_found")) {
        return false;
      }
      return true;
    } catch (e) {
      log.e(e);
      return true;
    }
  }

  Future<bool> deleteEncryptedSeed(String fullIdentifier) async {
    try {
      final http.Response resp = await http.get(
        Uri.parse("$AUTH_SERVER/delete-seed/$fullIdentifier"),
        headers: {"Accept": "application/json"},
      );
      if (resp.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      log.e(e);
      return false;
    }
  }
}
