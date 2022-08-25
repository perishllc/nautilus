// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_reply_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthReplyRequest _$AuthReplyRequestFromJson(Map<String, dynamic> json) =>
    AuthReplyRequest(
      account: json['account'] as String?,
      signature: json['signature'] as String?,
      signed: json['signed'] as String?,
      formatted: json['formatted'] as String?,
      message: json['message'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$AuthReplyRequestToJson(AuthReplyRequest instance) =>
    <String, dynamic>{
      'account': instance.account,
      'signature': instance.signature,
      'signed': instance.signed,
      'formatted': instance.formatted,
      'message': instance.message,
      'label': instance.label,
    };
