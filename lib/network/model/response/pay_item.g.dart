// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayItem _$PayItemFromJson(Map<String, dynamic> json) => PayItem()
  ..method = Method.fromJson(json['method'] as Map<String, dynamic>)
  ..account = json['account'] as String? ?? ''
  ..amount = json['amount'] as String? ?? ''
  ..label = json['label'] as String? ?? ''
  ..message = json['message'] as String? ?? ''
  ..signature = json['signature'] as String? ?? ''
  ..metadata = (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String?),
      ) ??
      {}
  ..exact = json['exact'] as bool? ?? true
  ..work = json['work'] as bool? ?? true;

Map<String, dynamic> _$PayItemToJson(PayItem instance) => <String, dynamic>{
      'method': instance.method,
      'account': instance.account,
      'amount': instance.amount,
      'label': instance.label,
      'message': instance.message,
      'signature': instance.signature,
      'metadata': instance.metadata,
      'exact': instance.exact,
      'work': instance.work,
    };
