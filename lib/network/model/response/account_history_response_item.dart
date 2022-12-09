import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/model/address.dart';

part 'account_history_response_item.g.dart';

int? _toInt(String? v) => v == null ? 0 : int.tryParse(v);

@JsonSerializable()
class AccountHistoryResponseItem {
  @JsonKey(name: 'type')
  String? type;

  @JsonKey(name: 'subtype')
  String? subtype;

  @JsonKey(name: 'account')
  String? account;

  @JsonKey(name: 'amount')
  String? amount;

  @JsonKey(name: 'hash')
  String? hash;

  @JsonKey(name: 'height', fromJson: _toInt)
  int? height;

  @JsonKey(name: 'link')
  String? link;

  @JsonKey(ignore: true)
  bool? confirmed;

  @JsonKey(name: 'local_timestamp', fromJson: _toInt)
  int? local_timestamp;

  AccountHistoryResponseItem(
      {String? type,
      String? subtype,
      String? account,
      String? amount,
      String? hash,
      int? height,
      String? link,
      int? local_timestamp,
      this.confirmed}) {
    this.type = type;
    this.subtype = subtype;
    this.account = account;
    this.amount = amount;
    this.hash = hash;
    this.height = height;
    this.link = link;
    this.local_timestamp = local_timestamp;
  }

  String? getShortString() {
    return Address(account).getShortString();
  }

  String? getShorterString() {
    return Address(account).getShorterString();
  }

  String? getShortestString() {
    return Address(account).getShortestString();
  }

  factory AccountHistoryResponseItem.fromJson(Map<String, dynamic> json) => _$AccountHistoryResponseItemFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHistoryResponseItemToJson(this);

  bool operator ==(o) => o is AccountHistoryResponseItem && o.hash == hash;
  int get hashCode => hash.hashCode;
}
