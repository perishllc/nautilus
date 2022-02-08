import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/network/model/request/actions.dart';
import 'package:nautilus_wallet_flutter/network/model/base_request.dart';

part 'payment_request.g.dart';

@JsonSerializable()
class PaymentRequest extends BaseRequest {
  @JsonKey(name: 'action')
  String action;

  @JsonKey(name: 'account')
  String account;

  @JsonKey(name: 'count', includeIfNull: false)
  int count;

  PaymentRequest({String action, String account, int count}) : super() {
    this.action = Actions.ACCOUNT_HISTORY;
    this.account = account ?? "";
    this.count = count ?? 3000;
  }

  factory PaymentRequest.fromJson(Map<String, dynamic> json) => _$PaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}
