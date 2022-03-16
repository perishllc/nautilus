// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'txdata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TXData _$TXDataFromJson(Map<String, dynamic> json) => TXData(
      from_address: json['from_address'] as String?,
      to_address: json['to_address'] as String?,
      amount_raw: json['amount_raw'] as String?,
      is_request: json['is_request'] as bool?,
      request_time: json['request_time'] as String?,
      is_fulfilled: json['is_fulfilled'] as bool?,
      fulfillment_time: json['fulfillment_time'] as String?,
      block: json['block'] as String?,
      memo: json['memo'] as String?,
      uuid: json['uuid'] as String?,
      is_acknowledged: json['is_acknowledged'] as bool?,
      height: json['height'] as int?,
    );

Map<String, dynamic> _$TXDataToJson(TXData instance) => <String, dynamic>{
      'from_address': instance.from_address,
      'to_address': instance.to_address,
      'amount_raw': instance.amount_raw,
      'is_request': instance.is_request,
      'request_time': instance.request_time,
      'is_fulfilled': instance.is_fulfilled,
      'fulfillment_time': instance.fulfillment_time,
      'block': instance.block,
      'memo': instance.memo,
      'uuid': instance.uuid,
      'is_acknowledged': instance.is_acknowledged,
      'height': instance.height,
    };
