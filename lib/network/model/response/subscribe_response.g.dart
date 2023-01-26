// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeResponse _$SubscribeResponseFromJson(Map<String, dynamic> json) =>
    SubscribeResponse()
      ..account = json['account'] as String?
      ..amount = json['amount'] as String?
      ..hash = json['hash'] as String?
      ..confirmationType = json['confirmation_type'] as String?
      ..block = json['block'] == null
          ? null
          : StateBlock.fromJson(json['block'] as Map<String, dynamic>);

Map<String, dynamic> _$SubscribeResponseToJson(SubscribeResponse instance) =>
    <String, dynamic>{
      'account': instance.account,
      'amount': instance.amount,
      'hash': instance.hash,
      'confirmation_type': instance.confirmationType,
      'block': instance.block,
    };
