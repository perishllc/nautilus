import 'dart:convert';
import 'dart:core';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/network/model/response/auth_item.dart';
import 'package:wallet_flutter/network/model/response/pay_item.dart';
import 'package:wallet_flutter/service_locator.dart';

// Object to represent an account address or address URI, and provide useful utilities

dynamic uriParser(String value) {
  String? finAmount;
  final String? finAddress = NanoAccounts.findAccountInString(NanoAccountType.NANO, value.toLowerCase().replaceAll("\n", ""));
  PayItem? finPayItem;
  AuthItem? finAuthItem;

  final List<String> split = value.split(":");
  if (split.length > 1) {
    final Uri? uri = Uri.tryParse(value);

    if (uri != null) {
      if (uri.queryParameters["amount"] != null) {
        final BigInt? amount = BigInt.tryParse(uri.queryParameters["amount"]!);
        if (amount != null) {
          finAmount = amount.toString();
        }
      }

      if (uri.scheme == "nanopay") {
        String encodedHandoff = split[1];
        encodedHandoff = encodedHandoff.replaceAll(RegExp(r"\s+\b|\b\s"), "");
        // attempt to recover from bad base64 encoding:
        if (encodedHandoff.length % 4 != 0) {
          encodedHandoff += "=" * (4 - encodedHandoff.length % 4);
        }
        final String decodedHandoff = utf8.decode(base64Url.decode(encodedHandoff));
        try {
          finPayItem = PayItem.fromJson(jsonDecode(decodedHandoff) as Map<String, dynamic>);
        } catch (error) {
          sl.get<Logger>().e(error);
        }
      }

      if (uri.queryParameters["pay"] != null) {
        // base64 decode the string:
        String? encodedHandoff = uri.queryParameters["pay"];
        if (encodedHandoff == null) return;
        encodedHandoff = encodedHandoff.replaceAll(RegExp(r"\s+\b|\b\s"), "");
        // attempt to recover from bad base64 encoding:
        if (encodedHandoff.length % 4 != 0) {
          encodedHandoff += "=" * (4 - encodedHandoff.length % 4);
        }
        final String decodedHandoff = utf8.decode(base64Url.decode(encodedHandoff));
        try {
          finPayItem = PayItem.fromJson(jsonDecode(decodedHandoff) as Map<String, dynamic>);
        } catch (error) {
          sl.get<Logger>().e(error);
        }
      }

      if (uri.scheme == "nanoauth") {
        String encodedAuth = split[1];
        encodedAuth = encodedAuth.replaceAll(RegExp(r"\s+\b|\b\s"), "");
        // attempt to recover from bad base64 encoding:
        if (encodedAuth.length % 4 != 0) {
          encodedAuth += "=" * (4 - encodedAuth.length % 4);
        }
        final String decodedAuth = utf8.decode(base64Url.decode(encodedAuth));
        try {
          // var decoded = jsonDecode(decodedAuth);
          // print(JsonEncoder.withIndent("  ").convert(decoded));
          finAuthItem = AuthItem.fromJson(jsonDecode(decodedAuth) as Map<String, dynamic>);
        } catch (error) {
          sl.get<Logger>().e(error);
        }
      }

      if (uri.queryParameters["auth"] != null) {
        // base64 decode the string:
        String? encodedAuth = uri.queryParameters["auth"];
        if (encodedAuth == null) return;
        encodedAuth = encodedAuth.replaceAll(RegExp(r"\s+\b|\b\s"), "");
        // attempt to recover from bad base64 encoding:
        if (encodedAuth.length % 4 != 0) {
          encodedAuth += "=" * (4 - encodedAuth.length % 4);
        }
        final String decodedAuth = utf8.decode(base64Url.decode(encodedAuth));
        try {
          finAuthItem = AuthItem.fromJson(jsonDecode(decodedAuth) as Map<String, dynamic>);
        } catch (error) {
          sl.get<Logger>().e(error);
        }
      }
    }

    if (finPayItem != null) {
      // grab the amount from the uri if not present in the JSON block:
      if (finAmount != null && finPayItem.amount == null) {
        finPayItem.amount = finAmount;
      }
      return finPayItem;
    }
    if (finAuthItem != null) {
      return finAuthItem;
    }
  }

  if (finAddress != null) {
    return Address.fromFields(address: finAddress, amount: finAmount);
  }

  // something went wrong, return null:
  return null;
}

class Address {
  Address(String? value) {
    _parseAddressString(value);
  }

  Address.fromFields({this.address, this.amount});

  String? address;
  String? amount;

  String? getShortString() {
    if (address == null || address!.length < 64) {
      return null;
    }
    return "${address!.substring(0, 11)}...${address!.substring(address!.length - 6)}";
  }

  String? getShorterString() {
    if (address == null || address!.length < 64) {
      return null;
    }
    return "${address!.substring(0, 9)}...${address!.substring(address!.length - 4)}";
  }

  String? getShortestString() {
    if (address == null || address!.length < 64) {
      return null;
    }
    return "${address!.substring(0, 11)}\n...${address!.substring(address!.length - 6)}";
  }

  String? getShortFirstPart() {
    if (address == null || address!.length < 64) {
      return null;
    }
    return address!.substring(0, 12);
  }

  String? getUltraShort() {
    if (address == null || address!.length < 64) {
      return null;
    }
    return "${address!.substring(5, 9)}...${address!.substring(address!.length - 4)}";
  }

  bool isValid() {
    if (address == null) {
      return false;
    }
    return NanoAccounts.isValid(NanoAccountType.NANO, address!);
  }

  void _parseAddressString(String? value) {
    if (value != null) {
      address = NanoAccounts.findAccountInString(NanoAccountType.NANO, value.toLowerCase().replaceAll("\n", ""));
      final List<String> split = value.split(":");
      if (split.length > 1) {
        final Uri? uri = Uri.tryParse(value);
        if (uri != null) {
          if (uri.queryParameters["amount"] != null) {
            final BigInt? bigAmount = BigInt.tryParse(uri.queryParameters["amount"]!);
            if (amount != null) {
              amount = bigAmount.toString();
            }
          }
        }
      }
    }
  }
}
