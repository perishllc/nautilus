// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receivable_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceivableRequest _$ReceivableRequestFromJson(Map<String, dynamic> json) =>
    ReceivableRequest(
      action: json['action'] as String? ?? Actions.RECEIVABLE,
      account: json['account'] as String?,
      source: json['source'] as bool? ?? true,
      count: json['count'] as int?,
      threshold: json['threshold'] as String?,
      includeActive: json['include_active'] as bool? ?? true,
    );

Map<String, dynamic> _$ReceivableRequestToJson(ReceivableRequest instance) {
  final val = <String, dynamic>{
    'action': instance.action,
    'account': instance.account,
    'source': instance.source,
    'count': instance.count,
    'include_active': instance.includeActive,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('threshold', instance.threshold);
  return val;
}
