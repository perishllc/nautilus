import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/network/model/request/actions.dart';
import 'package:nautilus_wallet_flutter/network/model/base_request.dart';

part 'payment_memo.g.dart';

@JsonSerializable()
class PaymentMemo extends BaseRequest {
  @JsonKey(name: 'action')
  String action;

  @JsonKey(name: 'account')
  String account;

  @JsonKey(name: 'requesting_account')
  String requesting_account;

  @JsonKey(name: 'request_signature')
  String request_signature;

  @JsonKey(name: 'request_nonce')
  String request_nonce;

  @JsonKey(name: 'memo')
  String memo;

  @JsonKey(name: 'block')
  String block;

  // @JsonKey(name: 'username')
  // String username;

  PaymentMemo(
      {String action,
      String account,
      String requesting_account,
      String request_signature,
      String request_nonce,
      String memo,
      String block})
      : super() {
    this.action = Actions.PAYMENT_MEMO;
    this.account = account ?? "";
    this.requesting_account = requesting_account ?? "";
    this.request_signature = request_signature ?? "";
    this.request_nonce = request_nonce ?? "";
    this.memo = memo ?? "";
    this.block = block ?? "";
  }

  factory PaymentMemo.fromJson(Map<String, dynamic> json) => _$PaymentMemoFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMemoToJson(this);
}
