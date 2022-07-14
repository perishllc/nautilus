// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthItem _$AuthItemFromJson(Map<String, dynamic> json) => AuthItem()
  ..methods = (json['methods'] as List<dynamic>)
      .map((e) => Method.fromJson(e as Map<String, dynamic>))
      .toList()
  ..account = json['account'] as String
  ..amount = json['amount'] as String?
  ..reuse = json['reuse'] as bool;

Map<String, dynamic> _$AuthItemToJson(AuthItem instance) => <String, dynamic>{
      'methods': instance.methods,
      'account': instance.account,
      'amount': instance.amount,
      'reuse': instance.reuse,
    };
