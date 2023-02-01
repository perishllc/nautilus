// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_response_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHistoryResponseItem _$AccountHistoryResponseItemFromJson(
        Map<String, dynamic> json) =>
    AccountHistoryResponseItem(
      type: json['type'] as String?,
      subtype: json['subtype'] as String?,
      account: json['account'] as String?,
      amount: json['amount'] as String?,
      hash: json['hash'] as String?,
      height: _toInt(json['height'] as String?),
      link: json['link'] as String?,
      local_timestamp: _toInt(json['local_timestamp'] as String?),
      confirmed: _toBool(json['confirmed'] as String?),
    );

Map<String, dynamic> _$AccountHistoryResponseItemToJson(
        AccountHistoryResponseItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'subtype': instance.subtype,
      'account': instance.account,
      'amount': instance.amount,
      'hash': instance.hash,
      'height': instance.height,
      'link': instance.link,
      'confirmed': instance.confirmed,
      'local_timestamp': instance.local_timestamp,
    };
