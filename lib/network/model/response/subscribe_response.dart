import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/model/state_block.dart';

part 'subscribe_response.g.dart';

int? _toInt(String? v) => v == null ? 0 : int.tryParse(v);

double? _toDouble(v) {
  return double.tryParse(v.toString());
}

/// For running in an isolate, needs to be top-level function
SubscribeResponse subscribeResponseFromJson(Map<dynamic, dynamic> json) {
  return SubscribeResponse.fromJson(json as Map<String, dynamic>);
}

@JsonSerializable()
class SubscribeResponse {

  SubscribeResponse();

  factory SubscribeResponse.fromJson(Map<String, dynamic> json) => _$SubscribeResponseFromJson(json);
  
  // @JsonKey(name: 'frontier')
  // String? frontier;

  // @JsonKey(name: 'open_block')
  // String? openBlock;

  // @JsonKey(name: 'representative_block')
  // String? representativeBlock;

  // @JsonKey(name: 'representative')
  // String? representative;

  // // Balance in RAW
  // @JsonKey(name: 'balance')
  // String? balance;

  // @JsonKey(name: 'block_count', fromJson: _toInt)
  // int? blockCount;

  // @JsonKey(name: 'receivable')
  // String? receivable;

  // // Server provides a uuid for each connection
  // @JsonKey(name: 'uuid')
  // String? uuid;

  // @JsonKey(name: 'price', fromJson: _toDouble)
  // double? price;

  // @JsonKey(name: 'xmr', fromJson: _toDouble)
  // double? xmrPrice;

  // @JsonKey(name: 'receivable_count')
  // int? receivableCount;

  // @JsonKey(name: 'confirmation_height', fromJson: _toInt)
  // int? confirmationHeight;

  @JsonKey(name: 'account')
  String? account;

  @JsonKey(name: 'amount')
  String? amount;

  @JsonKey(name: 'hash')
  String? hash;

  @JsonKey(name: 'confirmation_type')
  String? confirmationType;

  @JsonKey(name: 'block')
  StateBlock? block;

  Map<String, dynamic> toJson() => _$SubscribeResponseToJson(this);
}
