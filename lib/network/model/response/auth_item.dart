import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/model/method.dart';

part 'auth_item.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class AuthItem {
  AuthItem();
  factory AuthItem.fromJson(Map<String, dynamic> json) => _$AuthItemFromJson(json);

  @JsonKey(name: 'methods')
  late List<Method> methods;

  @JsonKey(name: 'account')
  late String account;

  @JsonKey(name: 'amount')
  String? amount;

  @JsonKey(name: 'reuse')
  bool reuse = false;

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
