import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/network/model/request/actions.dart';
import 'package:nautilus_wallet_flutter/network/model/base_request.dart';

part 'payment_ack.g.dart';

@JsonSerializable()
class PaymentACK extends BaseRequest {
  @JsonKey(name: 'action')
  String action;

  @JsonKey(name: 'uuid')
  String uuid;

  @JsonKey(name: 'account')
  String account;

  PaymentACK({String action, String uuid, String account}) : super() {
    this.action = Actions.PAYMENT_ACK;
    this.uuid = uuid ?? "";
    this.account = account ?? "";
  }

  factory PaymentACK.fromJson(Map<String, dynamic> json) => _$PaymentACKFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentACKToJson(this);
}
