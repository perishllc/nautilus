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
  ..label = json['label'] as String?
  ..message = json['message'] as String?
  ..exact = json['exact'] as bool? ?? true
  ..work = json['work'] as bool? ?? true
  ..reuse = json['reuse'] as bool? ?? false;

Map<String, dynamic> _$HandoffItemToJson(HandoffItem instance) =>
    <String, dynamic>{
      'methods': instance.methods,
      'account': instance.account,
      'amount': instance.amount,
      'label': instance.label,
      'message': instance.message,
      'exact': instance.exact,
      'work': instance.work,
      'reuse': instance.reuse,
    };
