import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/model/method.dart';

part 'auth_item.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class AuthItem {

  factory AuthItem.fromJson(Map<String, dynamic> json) => _$AuthItemFromJson(json);

  @JsonKey(name: 'methods')
  late List<Method> methods;

  @JsonKey(name: 'label')
  String? label;

  @JsonKey(name: 'format')
  late List<String> format;

  @JsonKey(name: 'separator')
  late String separator;

  @JsonKey(name: 'reuse')
  bool reuse = false;

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
