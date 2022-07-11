// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMessage _$PaymentMessageFromJson(Map<String, dynamic> json) =>
    PaymentMessage(
      action: json['action'] as String?,
      account: json['account'] as String?,
      requesting_account: json['requesting_account'] as String?,
      request_signature: json['request_signature'] as String?,
      request_nonce: json['request_nonce'] as String?,
      memo_enc: json['memo_enc'] as String?,
      local_uuid: json['local_uuid'] as String?,
    );

Map<String, dynamic> _$PaymentMessageToJson(PaymentMessage instance) =>
    <String, dynamic>{
      'action': instance.action,
      'account': instance.account,
      'requesting_account': instance.requesting_account,
      'request_signature': instance.request_signature,
      'request_nonce': instance.request_nonce,
      'memo_enc': instance.memo_enc,
      'local_uuid': instance.local_uuid,
    };
