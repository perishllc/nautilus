import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'sub_item.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class SubItem {
  SubItem();

  factory SubItem.fromJson(Map<String, dynamic> json) => _$SubItemFromJson(json);

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

  @JsonKey(name: 'frequency', defaultValue: "")
  late String frequency;

  bool isValid() {
    if (account.isEmpty) {
      return false;
    }

    if (amount.isEmpty) {
      return false;
    }

    if (frequency.isEmpty) {
      return false;
    }

    return true;
  }
}
