// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubItem _$SubItemFromJson(Map<String, dynamic> json) => SubItem()
  ..account = json['account'] as String? ?? ''
  ..amount = json['amount'] as String? ?? ''
  ..label = json['label'] as String? ?? ''
  ..message = json['message'] as String? ?? ''
  ..signature = json['signature'] as String? ?? ''
  ..metadata = (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String?),
      ) ??
      {}
  ..frequency = json['frequency'] as String? ?? '';

Map<String, dynamic> _$SubItemToJson(SubItem instance) => <String, dynamic>{
      'account': instance.account,
      'amount': instance.amount,
      'label': instance.label,
      'message': instance.message,
      'signature': instance.signature,
      'metadata': instance.metadata,
      'frequency': instance.frequency,
    };
