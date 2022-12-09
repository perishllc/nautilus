import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/request/actions.dart';
import 'package:wallet_flutter/network/model/base_request.dart';

part 'account_history_request.g.dart';

@JsonSerializable()
class AccountHistoryRequest extends BaseRequest {
  @JsonKey(name: 'action')
  String? action;

  @JsonKey(name: 'account')
  String? account;

  @JsonKey(name: 'count', includeIfNull: false)
  int? count;

  @JsonKey(name: 'head', includeIfNull: false)
  String? head;

  @JsonKey(name: 'raw')
  bool? raw;

  AccountHistoryRequest({String? action, String? account, int? count, bool? raw, this.head}) : super() {
    this.action = Actions.ACCOUNT_HISTORY;
    this.account = account ?? "";
    this.count = count ?? 3000;
    this.raw = raw ?? false;
  }

  factory AccountHistoryRequest.fromJson(Map<String, dynamic> json) => _$AccountHistoryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHistoryRequestToJson(this);
}
