// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayItem _$PayItemFromJson(Map<String, dynamic> json) => PayItem()
  ..methods = (json['methods'] as List<dynamic>)
      .map((e) => Method.fromJson(e as Map<String, dynamic>))
      .toList()
  ..account = json['account'] as String? ?? ''
  ..amount = json['amount'] as String? ?? ''
  ..label = json['label'] as String? ?? ''
  ..message = json['message'] as String? ?? ''
  ..signature = json['signature'] as String? ?? ''
  ..exact = json['exact'] as bool? ?? true
  ..work = json['work'] as bool? ?? true
  ..reuse = json['reuse'] as bool? ?? false;

Map<String, dynamic> _$PayItemToJson(PayItem instance) => <String, dynamic>{
      'methods': instance.methods,
      'account': instance.account,
      'amount': instance.amount,
      'label': instance.label,
      'message': instance.message,
      'signature': instance.signature,
      'exact': instance.exact,
      'work': instance.work,
      'reuse': instance.reuse,
    };
