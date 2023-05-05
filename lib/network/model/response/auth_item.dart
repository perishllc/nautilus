import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/model/method.dart';
import 'package:wallet_flutter/network/model/auth_types.dart';

part 'auth_item.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class AuthItem {
  AuthItem();
  factory AuthItem.fromJson(Map<String, dynamic> json) => _$AuthItemFromJson(json);

  @JsonKey(name: 'label', defaultValue: "")
  late String label;

  @JsonKey(name: 'message', defaultValue: "")
  late String message;

  @JsonKey(name: 'signature', defaultValue: "")
  late String signature;

  @JsonKey(name: 'nonce', required: true)
  late String nonce;

  @JsonKey(name: 'timestamp', required: true)
  late int timestamp;

  @JsonKey(name: 'account', required: true)
  late String account;

  @JsonKey(name: 'format', required: true)
  late List<String> format;

  @JsonKey(name: 'methods', required: true)
  late List<Method> methods;

  @JsonKey(name: 'separator', defaultValue: ":")
  late String separator;

  // @JsonKey(name: 'reuse')
  // bool reuse = false;

  bool isValid() {
    if (methods.isEmpty) {
      return false;
    }

    if (format.isEmpty) {
      return false;
    }
    
    // make sure format contains a nonce and timestamp:
    if (!format.contains(AuthTypes.NONCE) || !format.contains(AuthTypes.TIMESTAMP)) {
      return false;
    }

    if (separator.isEmpty) {
      return false;
    }

    return true;
  }

  String constructSignature() {
    String signature = "";

    for (final String authType in format) {
      switch (authType) {
        case AuthTypes.ACCOUNT:
          signature += account + separator;
          break;
        case AuthTypes.MESSAGE:
          signature += message + separator;
          break;
        case AuthTypes.LABEL:
          signature += label + separator;
          break;
        case AuthTypes.TIMESTAMP:
          final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
          signature += secondsSinceEpoch.toString() + separator;
          break;
        case AuthTypes.NONCE:
          signature += nonce + separator;
          break;
      }
    }

    // remove the last separator:
    signature = signature.substring(0, signature.length - separator.length);

    return signature;
  }
}
