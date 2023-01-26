import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/request/actions.dart';
import 'package:wallet_flutter/network/model/base_request.dart';

part 'account_representative_request.g.dart';

@JsonSerializable()
class AccountRepresentativeRequest extends BaseRequest {
  AccountRepresentativeRequest({String? action, String? account}) : super() {
    this.action = Actions.ACCOUNT_REPRESENTATIVE;
    this.account = account;
  }

  @JsonKey(name: 'action')
  String? action;

  @JsonKey(name: 'account')
  String? account;

  factory AccountRepresentativeRequest.fromJson(Map<String, dynamic> json) => _$AccountRepresentativeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AccountRepresentativeRequestToJson(this);
}
