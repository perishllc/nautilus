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

  @JsonKey(name: 'timestamp', required: true)
  late int timestamp;

  @JsonKey(name: 'account', required: true)
  late String account;

  @JsonKey(name: 'method', required: true)
  late Method method;

  @JsonKey(name: 'separator', defaultValue: ":")
  late String separator;

  bool isValid() {
    if (method == null) {
      return false;
    }

    if (account.isEmpty) {
      return false;
    }

    if (label.isEmpty) {
      return false;
    }

    if (separator.isEmpty) {
      return false;
    }

    return true;
  }

  String constructSignature() {
    String signature = "";

    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    signature = secondsSinceEpoch.toString() + separator + label + separator + account;
    return signature;
  }
}
