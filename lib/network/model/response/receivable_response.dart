import 'package:json_annotation/json_annotation.dart';

import 'package:wallet_flutter/network/model/response/receivable_response_item.dart';

part 'receivable_response.g.dart';

/// For running in an isolate, needs to be top-level function
ReceivableResponse receivableResponseFromJson(Map<dynamic, dynamic> json) {
  return ReceivableResponse.fromJson(json as Map<String, dynamic>);
} 

@JsonSerializable()
class ReceivableResponse {
  @JsonKey(name:"blocks")
  Map<String, ReceivableResponseItem>? blocks;

  @JsonKey(ignore: true)
  String? account;

  ReceivableResponse({this.blocks});

  factory ReceivableResponse.fromJson(Map<String, dynamic> json) => _$ReceivableResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReceivableResponseToJson(this);
}