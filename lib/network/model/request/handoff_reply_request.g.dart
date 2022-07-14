// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_reply_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandoffReplyRequest _$HandoffReplyRequestFromJson(Map<String, dynamic> json) =>
    HandoffReplyRequest(
      block: json['block'] == null
          ? null
          : StateBlock.fromJson(json['block'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HandoffReplyRequestToJson(
        HandoffReplyRequest instance) =>
    <String, dynamic>{
      'block': instance.block,
    };
