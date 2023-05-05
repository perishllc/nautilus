import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/request/actions.dart';
import 'package:wallet_flutter/network/model/base_request.dart';

part 'payment_request.g.dart';

@JsonSerializable()
class PaymentRequest extends BaseRequest {
  @JsonKey(name: 'action')
  String? action;

  @JsonKey(name: 'account')
  String? account;

  @JsonKey(name: 'amount_raw')
  String? amount_raw;

  @JsonKey(name: 'requesting_account')
  String? requesting_account;

  @JsonKey(name: 'request_signature')
  String? request_signature;

  @JsonKey(name: 'request_nonce')
  String? request_nonce;

  @JsonKey(name: 'memo_enc')
  String? memo_enc;

  @JsonKey(name: 'local_uuid')
  String? local_uuid;

  PaymentRequest(
      {String? action,
      String? account,
      String? amount_raw,
      String? requesting_account,
      String? request_signature,
      String? request_nonce,
      String? memo_enc,
      String? local_uuid})
      : super() {
    this.action = Actions.PAYMENT_REQUEST;
    this.account = account ?? "";
    this.amount_raw = amount_raw ?? "";
    this.requesting_account = requesting_account ?? "";
    this.request_signature = request_signature ?? "";
    this.request_nonce = request_nonce ?? "";
    this.memo_enc = memo_enc ?? "";
    this.local_uuid = local_uuid ?? "";
  }

  factory PaymentRequest.fromJson(Map<String, dynamic> json) => _$PaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}
