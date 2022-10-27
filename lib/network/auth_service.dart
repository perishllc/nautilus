
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';

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

  static String RPC_URL = "nautilus.perish.co";
  static String WS_URL = "nautilus.perish.co";

  // ignore_for_file: non_constant_identifier_names
  static String SERVER_ADDRESS_WS = "$WS_PROTO$BASE_SERVER_ADDRESS";
  static String SERVER_ADDRESS_HTTP = "$HTTP_PROTO$BASE_SERVER_ADDRESS/api";
  static String SERVER_ADDRESS_ALERTS = "$HTTP_PROTO$BASE_SERVER_ADDRESS/alerts";
  static String SERVER_ADDRESS_FUNDING = "$HTTP_PROTO$BASE_SERVER_ADDRESS/funding";
  static String SERVER_ADDRESS_GIFT = "$HTTP_PROTO$BASE_SERVER_ADDRESS/gift";

  // auth:
  static String AUTH_SERVER = "https://auth.perish.co";

  final Logger log = sl.get<Logger>();




}
