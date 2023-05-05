import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/request/actions.dart';
import 'package:wallet_flutter/network/model/base_request.dart';

part 'payment_ack.g.dart';

@JsonSerializable()
class PaymentACK extends BaseRequest {
  @JsonKey(name: 'action')
  String? action;

  @JsonKey(name: 'uuid')
  String? uuid;

  @JsonKey(name: 'account')
  String? account;

  @JsonKey(name: 'requesting_account')
  String? requesting_account;

  @JsonKey(name: 'sub_action')
  String? sub_action;

  PaymentACK({String? action, String? uuid, String? account, String? requesting_account, String? sub_action}) : super() {
    this.action = Actions.PAYMENT_ACK;
    this.uuid = uuid ?? "";
    this.account = account ?? "";
    this.requesting_account = requesting_account ?? "";
    this.sub_action = sub_action ?? "";
  }

  factory PaymentACK.fromJson(Map<String, dynamic> json) => _$PaymentACKFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentACKToJson(this);
}
