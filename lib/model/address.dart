import 'dart:convert';
import 'dart:core';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/network/model/response/handoff_item.dart';

// Object to represent an account address or address URI, and provide useful utilities

dynamic uriParser(String value) {
  String? finAmount;
  final String? finAddress = NanoAccounts.findAccountInString(NanoAccountType.NANO, value.toLowerCase().replaceAll("\n", ""));
  HandoffItem? finHandoffItem;

  final split = value.split(':');
  if (split.length > 1) {
    final Uri? uri = Uri.tryParse(value);

    if (uri != null) {
      if (uri.queryParameters['amount'] != null) {
        final BigInt? amount = BigInt.tryParse(uri.queryParameters['amount']!);
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
          finHandoffItem = HandoffItem.fromJson(jsonDecode(decodedHandoff) as Map<String, dynamic>);
        } catch (error) {
          print(error);
        }
      }

      if (uri.queryParameters['handoff'] != null) {
        // base64 decode the string:
        String encodedHandoff = uri.queryParameters['handoff'] as String;
        encodedHandoff = encodedHandoff.replaceAll(RegExp(r"\s+\b|\b\s"), "");
        // attempt to recover from bad base64 encoding:
        if (encodedHandoff.length % 4 != 0) {
          encodedHandoff += "=" * (4 - encodedHandoff.length % 4);
        }
        final String decodedHandoff = utf8.decode(base64Url.decode(encodedHandoff));
        try {
          finHandoffItem = HandoffItem.fromJson(jsonDecode(decodedHandoff) as Map<String, dynamic>);
        } catch (error) {
          print(error);
        }
      }
    }

    if (finHandoffItem != null) {
      // grab the amount from the uri if not present in the JSON block:
      if (finAmount != null && finHandoffItem.amount == null) {
        finHandoffItem.amount = finAmount;
      }
      return finHandoffItem;
    }

    if (finAddress != null) {
      return Address.fromFields(address: finAddress, amount: finAmount);
    }

    // something went wrong, return null:
    return null;
  }
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

  bool isValid() {
    return address == null ? false : NanoAccounts.isValid(NanoAccountType.NANO, address!);
  }

  void _parseAddressString(String? value) {
    if (value != null) {
      address = NanoAccounts.findAccountInString(NanoAccountType.NANO, value.toLowerCase().replaceAll("\n", ""));
      final split = value.split(':');
      if (split.length > 1) {
        final Uri? uri = Uri.tryParse(value);
        if (uri != null) {
          if (uri.queryParameters['amount'] != null) {
            final BigInt? bigAmount = BigInt.tryParse(uri.queryParameters['amount']!);
            if (amount != null) {
              amount = bigAmount.toString();
            }
          }
        }
      }
    }
  }
}
