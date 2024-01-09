import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:wallet_flutter/service_locator.dart';

// AccountService singleton
class AnonymousService {
  // Constructor
  AnonymousService() {}

  // Server Connection Strings
  static String BASE_SERVER_ADDRESS = "https://nanonymous.cc/api/v1";

  final Logger log = sl.get<Logger>();
  
  Future<String> getAmountToSendRaw(String? amountRaw) async {
    String url = "$BASE_SERVER_ADDRESS/?feecheck";
    if (amountRaw != null) {
      url += "&amount=$amountRaw";
    }
    print(url);
    try {
      final http.Response resp = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );
      if (resp.statusCode != 200) {
        throw Exception("Error getting nanonymous fee");
      }
      final Map<String, dynamic> json = jsonDecode(resp.body) as Map<String, dynamic>;
      return json["amountToSend"].toString();
    } catch (e) {
      log.e(e);
      return "0.02";
    }
  }

  Future<String> getAddress(String finalAddress, {List<int>? percents, List<int>? delays}) async {
    try {
      String url = "$BASE_SERVER_ADDRESS/?newaddress&address=$finalAddress";

      if (percents != null && percents.isNotEmpty) {
        String percentString = "&percents=";
        for (int i = 0; i < percents.length; i++) {
          percentString += percents[i].toString();
          if (i < percents.length - 1) {
            percentString += ",";
          }
        }
        url += percentString;
      }

      if (delays != null && delays.isNotEmpty) {
        String delayString = "&delays=";
        for (int i = 0; i < delays.length; i++) {
          delayString += delays[i].toString();
          if (i < delays.length - 1) {
            delayString += ",";
          }
        }
        url += delayString;
      }

      final http.Response resp = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );
      if (resp.statusCode != 200) {
        throw Exception("Error getting nanonymous fee");
      }
      final Map<String, dynamic> json = jsonDecode(resp.body) as Map<String, dynamic>;
      return json["address"] as String;
    } catch (e) {
      log.e(e);
      return "0.02";
    }
  }
}
