// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthItem _$AuthItemFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['nonce', 'timestamp', 'address', 'format', 'methods'],
  );
  return AuthItem()
    ..label = json['label'] as String? ?? ''
    ..message = json['message'] as String? ?? ''
    ..nonce = json['nonce'] as String
    ..timestamp = json['timestamp'] as int
    ..address = json['address'] as String
    ..format =
        (json['format'] as List<dynamic>).map((e) => e as String).toList()
    ..methods = (json['methods'] as List<dynamic>)
        .map((e) => Method.fromJson(e as Map<String, dynamic>))
        .toList()
    ..separator = json['separator'] as String? ?? ':';
}

Map<String, dynamic> _$AuthItemToJson(AuthItem instance) => <String, dynamic>{
      'label': instance.label,
      'message': instance.message,
      'nonce': instance.nonce,
      'timestamp': instance.timestamp,
      'address': instance.address,
      'format': instance.format,
      'methods': instance.methods,
      'separator': instance.separator,
    };
