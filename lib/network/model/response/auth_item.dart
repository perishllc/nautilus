import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/model/method.dart';

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

  @JsonKey(name: 'nonce', required: true)
  late String nonce;

  @JsonKey(name: 'timestamp', required: true)
  late int timestamp;

  @JsonKey(name: 'address', required: true)
  late String address;

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

    if (separator.isEmpty) {
      return false;
    }

    return true;
  }
}
