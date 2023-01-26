import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/base_request.dart';
import 'package:wallet_flutter/network/model/request/actions.dart';
import 'package:wallet_flutter/network/model/request/subscribe_option.dart';

part 'subscribe_request.g.dart';

@JsonSerializable()
class SubscribeRequest extends BaseRequest {
  SubscribeRequest({
    this.action = Actions.SUBSCRIBE,
    this.topic = "confirmation",
    this.account,
    this.ack = true,
    this.fcmToken,
    this.notificationEnabled,
    this.options,
  }) : super();

  factory SubscribeRequest.fromJson(Map<String, dynamic> json) => _$SubscribeRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubscribeRequestToJson(this);

  @JsonKey(name: 'action')
  String? action;

  @JsonKey(name: 'topic', includeIfNull: false)
  String? topic;

  @JsonKey(name: 'account', includeIfNull: false)
  String? account;

  @JsonKey(name: 'ack', includeIfNull: false)
  bool? ack;

  @JsonKey(name: 'fcm_token_v2', includeIfNull: false)
  String? fcmToken;

  @JsonKey(name: 'notification_enabled', includeIfNull: false)
  bool? notificationEnabled;

  @JsonKey(name: 'options', includeIfNull: false)
  SubscribeOption? options;
}
