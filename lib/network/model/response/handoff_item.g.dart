// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandoffItem _$HandoffItemFromJson(Map<String, dynamic> json) => HandoffItem()
  ..methods = (json['methods'] as List<dynamic>)
      .map((e) => Method.fromJson(e as Map<String, dynamic>))
      .toList()
  ..account = json['account'] as String
  ..amount = json['amount'] as String?
  ..exact = json['exact'] as bool
  ..work = json['work'] as bool
  ..reuse = json['reuse'] as bool;

Map<String, dynamic> _$HandoffItemToJson(HandoffItem instance) =>
    <String, dynamic>{
      'methods': instance.methods,
      'account': instance.account,
      'amount': instance.amount,
      'exact': instance.exact,
      'work': instance.work,
      'reuse': instance.reuse,
    };
