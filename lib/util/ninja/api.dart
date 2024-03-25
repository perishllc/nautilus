import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/util/ninja/n2_node.dart';
import 'package:wallet_flutter/util/ninja/ninja_node.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class N2NodeAPI {
  // static const String API_URL = 'https://mynano.ninja/api';
  static const String API_URL = 'https://rpc.nano.to';

  static Future<String?> getAndCacheAPIResponse() async {
    const String url = '$API_URL';
    try {
      final http.Response response = await http.post(Uri.parse(url),
      headers: AccountService.APP_HEADERS,
      body: json.encode(
        <String, dynamic>{
          "action": "reps",
        },
      ),
      );
      if (response.statusCode != 200) {
        return null;
      }
      await sl.get<SharedPrefsUtil>().setNinjaAPICache(response.body);
      print(response.body);
      return response.body;
    } catch (e) {
      print("reps API error: $e");
      return null;
    }
  }

  /// Get verified nodes, return null if an error occured
  static Future<List<N2Node>?> getVerifiedNodes() async {
    final String? httpResponseBody = await getAndCacheAPIResponse();
    if (httpResponseBody == null) {
      return null;
    }
    try {
      final List<N2Node> nodes =
          (json.decode(httpResponseBody) as List<dynamic>).map((dynamic e) => N2Node.fromJson(e as Map<String, dynamic>)).toList();
      return nodes;
    } catch (error) {
      return null;
    }
  }

  static Future<List<N2Node>?> getCachedVerifiedNodes() async {
    final String? rawJson = await sl.get<SharedPrefsUtil>().getNinjaAPICache();
    if (rawJson == null) {
      return null;
    }
    try {
      final List<N2Node> nodes = (json.decode(rawJson) as List<dynamic>).map((dynamic e) => N2Node.fromJson(e as Map<String, dynamic>)).toList();
      return nodes;
    } catch (error) {
      return null;
    }
  }
}
