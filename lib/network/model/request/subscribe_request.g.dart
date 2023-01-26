// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeRequest _$SubscribeRequestFromJson(Map<String, dynamic> json) =>
    SubscribeRequest(
      action: json['action'] as String? ?? Actions.SUBSCRIBE,
      topic: json['topic'] as String? ?? "confirmation",
      account: json['account'] as String?,
      ack: json['ack'] as bool? ?? true,
      fcmToken: json['fcm_token_v2'] as String?,
      notificationEnabled: json['notification_enabled'] as bool?,
      options: json['options'] == null
          ? null
          : SubscribeOption.fromJson(json['options'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscribeRequestToJson(SubscribeRequest instance) {
  final val = <String, dynamic>{
    'action': instance.action,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('topic', instance.topic);
  writeNotNull('account', instance.account);
  writeNotNull('ack', instance.ack);
  writeNotNull('fcm_token_v2', instance.fcmToken);
  writeNotNull('notification_enabled', instance.notificationEnabled);
  writeNotNull('options', instance.options);
  return val;
}
