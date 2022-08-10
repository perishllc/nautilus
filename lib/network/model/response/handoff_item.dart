import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/model/method.dart';

part 'handoff_item.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class HandoffItem {
  
  HandoffItem();

  factory HandoffItem.fromJson(Map<String, dynamic> json) => _$HandoffItemFromJson(json);

  @JsonKey(name: 'methods')
  late List<Method> methods;

  @JsonKey(name: 'account')
  late String account;

  @JsonKey(name: 'amount')
  String? amount;

  @JsonKey(name: 'label')
  String? label;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'exact', defaultValue: true)
  late bool exact;

  @JsonKey(name: 'work', defaultValue: true)
  late bool work;

  @JsonKey(name: 'reuse', defaultValue: false)
  late bool reuse;

  bool isValid() {
    if (account == null || account.isEmpty) {
      return false;
    }

    if (amount == null || amount!.isEmpty) {
      return false;
    }

    if (methods.isEmpty) {
      return false;
    }
    

    return true;

  }
}
