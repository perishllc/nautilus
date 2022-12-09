import 'package:json_annotation/json_annotation.dart';

import 'package:wallet_flutter/network/model/response/receivable_response.dart';

part 'account_balance_item.g.dart';

@JsonSerializable()
class AccountBalanceItem {
  @JsonKey(name: "balance")
  String? balance;

  @JsonKey(name: "receivable")
  String? receivable;

  @JsonKey(ignore: true)
  String? privKey;

  @JsonKey(ignore: true)
  String? frontier;

  @JsonKey(ignore: true)
  ReceivableResponse? receivableResponse;

  AccountBalanceItem({this.balance, this.receivable, this.privKey, this.frontier, this.receivableResponse});

  factory AccountBalanceItem.fromJson(Map<String, dynamic> json) => _$AccountBalanceItemFromJson(json);
  Map<String, dynamic> toJson() => _$AccountBalanceItemToJson(this);
}
