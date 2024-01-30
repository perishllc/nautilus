// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthItem _$AuthItemFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['timestamp', 'account', 'method'],
  );
  return AuthItem()
    ..label = json['label'] as String? ?? ''
    ..message = json['message'] as String? ?? ''
    ..signature = json['signature'] as String? ?? ''
    ..timestamp = json['timestamp'] as int
    ..account = json['account'] as String
    ..method = Method.fromJson(json['method'] as Map<String, dynamic>)
    ..separator = json['separator'] as String? ?? ':';
}

Map<String, dynamic> _$AuthItemToJson(AuthItem instance) => <String, dynamic>{
      'label': instance.label,
      'message': instance.message,
      'signature': instance.signature,
      'timestamp': instance.timestamp,
      'account': instance.account,
      'method': instance.method,
      'separator': instance.separator,
    };
