import 'dart:core';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/model/method.dart';
import 'package:nautilus_wallet_flutter/model/state_block.dart';

// Object to represent block handoff structure
@JsonSerializable()
class Handoff {
  StateBlock? block;

  List<Method> methods;

  /// The generated code assumes these values exist in JSON.
  final String firstName, lastName;

  /// The generated code below handles if the corresponding JSON value doesn't
  /// exist or is empty.
  final DateTime? dateOfBirth;

  Handoff({this.block, required this.lastName, this.dateOfBirth});

  String? _address;
  String? _amount;
  String? _username;
  // String? _

  // Handoff(String? value) {
  //   _parseAddressString(value);
  // }

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
      value = value.toLowerCase();
      _address = NanoAccounts.findAccountInString(NanoAccountType.NANO, value.replaceAll("\n", ""));
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

          if (uri.queryParameters['handoff'] != null) {}
        }
      }
    }
  }
}
