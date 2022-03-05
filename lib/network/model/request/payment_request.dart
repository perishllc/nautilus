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

  @JsonKey(name: 'amount_raw')
  String amount_raw;

  @JsonKey(name: 'requesting_account')
  String requesting_account;

  @JsonKey(name: 'request_signature')
  String request_signature;

  @JsonKey(name: 'request_nonce')
  String request_nonce;

  @JsonKey(name: 'memo')
  String memo;

  // @JsonKey(name: 'username')
  // String username;

  PaymentRequest({String action, String account, String amount_raw, String requesting_account, String request_signature, String request_nonce, String memo})
      : super() {
    this.action = Actions.REQUEST_PAYMENT;
    this.account = account ?? "";
    this.amount_raw = amount_raw ?? "";
    this.requesting_account = requesting_account ?? "";
    this.request_signature = request_signature ?? "";
    this.request_nonce = request_nonce ?? "";
    this.memo = memo ?? "";
  }

  factory PaymentRequest.fromJson(Map<String, dynamic> json) => _$PaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}
