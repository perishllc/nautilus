import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/model/method.dart';

part 'pay_item.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class PayItem {
  PayItem();

  factory PayItem.fromJson(Map<String, dynamic> json) => _$PayItemFromJson(json);

  @JsonKey(name: 'methods')
  late List<Method> methods;

  @JsonKey(name: 'account', defaultValue: "")
  late String account;

  @JsonKey(name: 'amount', defaultValue: "")
  late String amount;

  @JsonKey(name: 'label', defaultValue: "")
  late String label;

  @JsonKey(name: 'message', defaultValue: "")
  late String message;

  @JsonKey(name: 'signature', defaultValue: "")
  late String signature;

  @JsonKey(name: 'metadata', defaultValue: {})
  Map<String, String?>? metadata;

  @JsonKey(name: 'exact', defaultValue: true)
  late bool exact;

  @JsonKey(name: 'work', defaultValue: true)
  late bool work;

  @JsonKey(name: 'reuse', defaultValue: false)
  late bool reuse;

  bool isValid() {
    if (account.isEmpty) {
      return false;
    }

    if (amount.isEmpty) {
      return false;
    }

    if (methods.isEmpty) {
      return false;
    }

    return true;
  }
}
