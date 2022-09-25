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
      message: json['message'] as String?,
      label: json['label'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String?),
      ),
    );

Map<String, dynamic> _$HandoffReplyRequestToJson(
        HandoffReplyRequest instance) =>
    <String, dynamic>{
      'block': instance.block,
      'message': instance.message,
      'label': instance.label,
      'metadata': instance.metadata,
    };
