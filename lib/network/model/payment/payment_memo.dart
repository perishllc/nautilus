import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/request/actions.dart';
import 'package:wallet_flutter/network/model/base_request.dart';

part 'payment_memo.g.dart';

@JsonSerializable()
class PaymentMemo extends BaseRequest {
  @JsonKey(name: 'action')
  String? action;

  @JsonKey(name: 'account')
  String? account;

  @JsonKey(name: 'requesting_account')
  String? requesting_account;

  @JsonKey(name: 'request_signature')
  String? request_signature;

  @JsonKey(name: 'request_nonce')
  String? request_nonce;

  @JsonKey(name: 'memo_enc')
  String? memo_enc;

  @JsonKey(name: 'block')
  String? block;

  @JsonKey(name: 'local_uuid')
  String? local_uuid;

  // @JsonKey(name: 'username')
  // String username;

  PaymentMemo({String? action, String? account, String? requesting_account, String? request_signature, String? request_nonce, String? memo_enc, String? block, String? local_uuid})
      : super() {
    this.action = Actions.PAYMENT_MEMO;
    this.account = account ?? "";
    this.requesting_account = requesting_account ?? "";
    this.request_signature = request_signature ?? "";
    this.request_nonce = request_nonce ?? "";
    this.memo_enc = memo_enc ?? "";
    this.block = block ?? "";
    this.local_uuid = local_uuid ?? "";
  }

  factory PaymentMemo.fromJson(Map<String, dynamic> json) => _$PaymentMemoFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMemoToJson(this);
}
