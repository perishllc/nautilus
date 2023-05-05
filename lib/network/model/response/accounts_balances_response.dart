import 'package:json_annotation/json_annotation.dart';

import 'package:wallet_flutter/network/model/response/account_balance_item.dart';

part 'accounts_balances_response.g.dart';

/// For running in an isolate, needs to be top-level function
AccountsBalancesResponse accountsBalancesResponseFromJson(Map<dynamic, dynamic> json) {
  return AccountsBalancesResponse.fromJson(json as Map<String, dynamic>);
} 

@JsonSerializable()
class AccountsBalancesResponse {
  @JsonKey(name:'balances')
  Map<String, AccountBalanceItem>? balances;

  AccountsBalancesResponse({this.balances});

  factory AccountsBalancesResponse.fromJson(json) => _$AccountsBalancesResponseFromJson(json as Map<String, dynamic>);
  Map<String, dynamic> toJson() => _$AccountsBalancesResponseToJson(this);
}