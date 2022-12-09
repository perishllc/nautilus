import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/util/ninja/ninja_node.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class NinjaAPI {
  static const String API_URL = 'https://mynano.ninja/api';

  static Future<String?> getAndCacheAPIResponse() async {
    const String url = '$API_URL/accounts/verified';
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return null;
      }
      await sl.get<SharedPrefsUtil>().setNinjaAPICache(response.body);
      return response.body;
    } catch (e) {
      print("MyNanoNinja API error: $e");
      return null;
    }
  }

  /// Get verified nodes, return null if an error occured
  static Future<List<NinjaNode>?> getVerifiedNodes() async {
    final String? httpResponseBody = await getAndCacheAPIResponse();
    if (httpResponseBody == null) {
      return null;
    }

    try {
      final List<NinjaNode> ninjaNodes =
          (json.decode(httpResponseBody) as List<dynamic>).map((dynamic e) => NinjaNode.fromJson(e as Map<String, dynamic>)).toList();
      return ninjaNodes;
    } catch (error) {
      return null;
    }
  }

  static Future<List<NinjaNode>?> getCachedVerifiedNodes() async {
    final String? rawJson = await sl.get<SharedPrefsUtil>().getNinjaAPICache();
    if (rawJson == null) {
      return null;
    }
    try {
      final List<NinjaNode> ninjaNodes = (json.decode(rawJson) as List<dynamic>).map((dynamic e) => NinjaNode.fromJson(e as Map<String, dynamic>)).toList();
      return ninjaNodes;
    } catch (error) {
      return null;
    }
  }
}
