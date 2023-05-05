import 'package:json_annotation/json_annotation.dart';

part 'receivable_response_item.g.dart';

@JsonSerializable()
class ReceivableResponseItem {
  @JsonKey(name: "source")
  String? source;

  // raw-value of the transaction
  @JsonKey(name: "amount")
  String? amount;

  @JsonKey(name: "hash")
  String? hash;

  ReceivableResponseItem({this.source, this.amount, this.hash});

  factory ReceivableResponseItem.fromJson(Map<String, dynamic> json) => _$ReceivableResponseItemFromJson(json);
  Map<String, dynamic> toJson() => _$ReceivableResponseItemToJson(this);
}
