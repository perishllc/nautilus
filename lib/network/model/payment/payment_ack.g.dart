// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_ack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentACK _$PaymentACKFromJson(Map<String, dynamic> json) => PaymentACK(
      action: json['action'] as String?,
      uuid: json['uuid'] as String?,
      account: json['account'] as String?,
      requesting_account: json['requesting_account'] as String?,
      sub_action: json['sub_action'] as String?,
    );

Map<String, dynamic> _$PaymentACKToJson(PaymentACK instance) =>
    <String, dynamic>{
      'action': instance.action,
      'uuid': instance.uuid,
      'account': instance.account,
      'requesting_account': instance.requesting_account,
      'sub_action': instance.sub_action,
    };
