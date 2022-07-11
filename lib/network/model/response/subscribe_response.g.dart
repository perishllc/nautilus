// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeResponse _$SubscribeResponseFromJson(Map<String, dynamic> json) =>
    SubscribeResponse()
      ..frontier = json['frontier'] as String?
      ..openBlock = json['open_block'] as String?
      ..representativeBlock = json['representative_block'] as String?
      ..representative = json['representative'] as String?
      ..balance = json['balance'] as String?
      ..blockCount = _toInt(json['block_count'] as String?)
      ..receivable = json['receivable'] as String?
      ..uuid = json['uuid'] as String?
      ..price = _toDouble(json['price'])
      ..btcPrice = _toDouble(json['btc'])
      ..receivableCount = json['receivable_count'] as int?
      ..confirmationHeight = _toInt(json['confirmation_height'] as String?);

Map<String, dynamic> _$SubscribeResponseToJson(SubscribeResponse instance) =>
    <String, dynamic>{
      'frontier': instance.frontier,
      'open_block': instance.openBlock,
      'representative_block': instance.representativeBlock,
      'representative': instance.representative,
      'balance': instance.balance,
      'block_count': instance.blockCount,
      'receivable': instance.receivable,
      'uuid': instance.uuid,
      'price': instance.price,
      'btc': instance.btcPrice,
      'receivable_count': instance.receivableCount,
      'confirmation_height': instance.confirmationHeight,
    };
