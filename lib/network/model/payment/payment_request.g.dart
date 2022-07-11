// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      action: json['action'] as String?,
      account: json['account'] as String?,
      amount_raw: json['amount_raw'] as String?,
      requesting_account: json['requesting_account'] as String?,
      request_signature: json['request_signature'] as String?,
      request_nonce: json['request_nonce'] as String?,
      memo_enc: json['memo_enc'] as String?,
      local_uuid: json['local_uuid'] as String?,
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'account': instance.account,
      'amount_raw': instance.amount_raw,
      'requesting_account': instance.requesting_account,
      'request_signature': instance.request_signature,
      'request_nonce': instance.request_nonce,
      'memo_enc': instance.memo_enc,
      'local_uuid': instance.local_uuid,
    };
