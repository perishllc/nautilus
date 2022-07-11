import 'dart:convert';
import 'dart:core';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/model/handoff.dart';

// Object to represent an account address or address URI, and provide useful utilities
class Address {
  String? _address;
  String? _amount;
  // String? _

  Handoff? _handoff;

  Address(String? value) {
    _parseAddressString(value);
  }

  String? get address => _address;

  String? get amount => _amount;

  String? getShortString() {
    if (_address == null || _address!.length < 64) return null;
    return "${_address!.substring(0, 11)}...${_address!.substring(_address!.length - 6)}";
  }

  String? getShorterString() {
    if (_address == null || _address!.length < 64) return null;
    return "${_address!.substring(0, 9)}...${_address!.substring(_address!.length - 4)}";
  }

  String? getShortestString() {
    if (_address == null || _address!.length < 64) return null;
    return "${_address!.substring(0, 11)}\n...${_address!.substring(_address!.length - 6)}";
  }

  bool isValid() {
    return _address == null ? false : NanoAccounts.isValid(NanoAccountType.NANO, _address!);
  }

  void _parseAddressString(String? value) {
    if (value != null) {
      _address = NanoAccounts.findAccountInString(NanoAccountType.NANO, value.toLowerCase().replaceAll("\n", ""));
      final split = value.split(':');
      if (split.length > 1) {
        final Uri? uri = Uri.tryParse(value);
        if (uri != null) {
          if (uri.queryParameters['amount'] != null) {
            final BigInt? amount = BigInt.tryParse(uri.queryParameters['amount']!);
            if (amount != null) {
              _amount = amount.toString();
            }
          }

          print("AAAAAAAAAAAAAAAAAA");
          print(uri.queryParameters);
          try {
            // if (uri.queryParameters['handoff'] != null) {
            String encodedHandoff = uri.queryParameters['handoff'] as String;
            encodedHandoff = encodedHandoff.replaceAll(RegExp(r"\s+\b|\b\s"), "");
            // base64 decode the string:
            print(uri.queryParameters['handoff']);
            var a = base64Url.decode(encodedHandoff);
            print(a);
            print(utf8.decode(a));
            print("what");
          } catch (error) {
            print("err");
            print(error);
          }
          // }
        }
      }
    }
  }
}
