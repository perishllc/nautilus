// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_reply_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandoffReplyRequest _$HandoffReplyRequestFromJson(Map<String, dynamic> json) =>
    HandoffReplyRequest()
      ..methods = (json['methods'] as List<dynamic>)
          .map((e) => Method.fromJson(e as Map<String, dynamic>))
          .toList()
      ..account = json['account'] as String
      ..amount = json['amount'] as String?
      ..exact = json['exact'] as bool
      ..work = json['work'] as bool
      ..reuse = json['reuse'] as bool
      ..block = json['block'] == null
          ? null
          : StateBlock.fromJson(json['block'] as Map<String, dynamic>);

Map<String, dynamic> _$HandoffReplyRequestToJson(
        HandoffReplyRequest instance) =>
    <String, dynamic>{
      'methods': instance.methods,
      'account': instance.account,
      'amount': instance.amount,
      'exact': instance.exact,
      'work': instance.work,
      'reuse': instance.reuse,
      'block': instance.block,
    };
