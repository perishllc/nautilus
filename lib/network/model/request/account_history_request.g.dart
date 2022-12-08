// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHistoryRequest _$AccountHistoryRequestFromJson(
        Map<String, dynamic> json) =>
    AccountHistoryRequest(
      action: json['action'] as String?,
      account: json['account'] as String?,
      count: json['count'] as int?,
      raw: json['raw'] as bool?,
      head: json['head'] as String?,
    );

Map<String, dynamic> _$AccountHistoryRequestToJson(
    AccountHistoryRequest instance) {
  final val = <String, dynamic>{
    'action': instance.action,
    'account': instance.account,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('count', instance.count);
  writeNotNull('head', instance.head);
  val['raw'] = instance.raw;
  return val;
}
