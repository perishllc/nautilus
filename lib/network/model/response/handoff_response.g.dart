// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandoffResponse _$HandoffResponseFromJson(Map<String, dynamic> json) =>
    HandoffResponse()
      ..status = json['status'] as int?
      ..message = json['message'] as String?
      ..label = json['label'] as String?
      ..data = (json['data'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      );

Map<String, dynamic> _$HandoffResponseToJson(HandoffResponse instance) {
  final val = <String, dynamic>{
    'status': instance.status,
    'message': instance.message,
    'label': instance.label,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', instance.data);
  return val;
}
