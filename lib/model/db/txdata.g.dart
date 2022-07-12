// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'txdata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TXData _$TXDataFromJson(Map<String, dynamic> json) => TXData(
      from_address: json['from_address'] as String?,
      to_address: json['to_address'] as String?,
      amount_raw: json['amount_raw'] as String?,
      is_request: json['is_request'] as bool? ?? false,
      request_time: json['request_time'] as int?,
      is_fulfilled: json['is_fulfilled'] as bool? ?? false,
      fulfillment_time: json['fulfillment_time'] as int?,
      block: json['block'] as String?,
      link: json['link'] as String?,
      memo_enc: json['memo_enc'] as String?,
      is_memo: json['is_memo'] as bool? ?? false,
      is_message: json['is_message'] as bool? ?? false,
      is_tx: json['is_tx'] as bool? ?? false,
      memo: json['memo'] as String?,
      uuid: json['uuid'] as String?,
      is_acknowledged: json['is_acknowledged'] as bool? ?? false,
      height: json['height'] as int?,
      send_height: json['send_height'] as int?,
      recv_height: json['recv_height'] as int?,
      record_type: json['record_type'] as String?,
      sub_type: json['sub_type'] as String?,
      metadata: json['metadata'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$TXDataToJson(TXData instance) => <String, dynamic>{
      'block': instance.block,
      'link': instance.link,
      'memo_enc': instance.memo_enc,
      'is_memo': instance.is_memo,
      'is_message': instance.is_message,
      'is_tx': instance.is_tx,
      'from_address': instance.from_address,
      'to_address': instance.to_address,
      'amount_raw': instance.amount_raw,
      'is_request': instance.is_request,
      'request_time': instance.request_time,
      'is_fulfilled': instance.is_fulfilled,
      'fulfillment_time': instance.fulfillment_time,
      'memo': instance.memo,
      'uuid': instance.uuid,
      'is_acknowledged': instance.is_acknowledged,
      'height': instance.height,
      'send_height': instance.send_height,
      'recv_height': instance.recv_height,
      'record_type': instance.record_type,
      'sub_type': instance.sub_type,
      'metadata': instance.metadata,
      'status': instance.status,
    };
