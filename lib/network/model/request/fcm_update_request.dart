import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/base_request.dart';
import 'package:wallet_flutter/network/model/request/actions.dart';

part 'fcm_update_request.g.dart';

@JsonSerializable()
class FcmUpdateRequest extends BaseRequest {

  FcmUpdateRequest({this.account, this.fcmToken, this.enabled}) : super() {
    action = Actions.FCM_UPDATE;
  }

  factory FcmUpdateRequest.fromJson(Map<String, dynamic> json) => _$FcmUpdateRequestFromJson(json);

  @JsonKey(name:'action')
  String? action;

  @JsonKey(name:'account', includeIfNull: false)
  String? account;

  @JsonKey(name:'fcm_token_v2', includeIfNull: false)
  String? fcmToken;

  @JsonKey(name:'enabled')
  bool? enabled;
  Map<String, dynamic> toJson() => _$FcmUpdateRequestToJson(this);
}