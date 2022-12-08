import 'package:json_annotation/json_annotation.dart';

part 'block_info_item.g.dart';

/// For running in an isolate, needs to be top-level function
BlockInfoItem blockInfoItemFromJson(Map<dynamic, dynamic> json) {
  return BlockInfoItem.fromJson(json as Map<String, dynamic>);
}

@JsonSerializable()
class BlockInfoItem {
  @JsonKey(name: 'block_account')
  String? blockAccount;

  @JsonKey(name: 'amount')
  String? amount;

  @JsonKey(name: 'balance')
  String? balance;

  @JsonKey(name: 'receivable')
  String? receivable;

  @JsonKey(name: 'source_account')
  String? sourceAccount;

  @JsonKey(name: 'contents')
  String? contents;
  
  @JsonKey(name: 'confirmed')
  String? confirmed;

  BlockInfoItem({this.blockAccount, this.amount, this.balance, this.receivable, this.sourceAccount, this.contents, this.confirmed});

  factory BlockInfoItem.fromJson(Map<String, dynamic> json) => _$BlockInfoItemFromJson(json);
  Map<String, dynamic> toJson() => _$BlockInfoItemToJson(this);
}
