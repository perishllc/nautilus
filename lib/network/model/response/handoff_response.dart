import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
part 'handoff_response.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class HandoffResponse {
  HandoffResponse();
  factory HandoffResponse.fromJson(Map<String, dynamic> json) => _$HandoffResponseFromJson(json);

  @JsonKey(name: 'status')
  int? status;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'label')
  String? label;

  @JsonKey(name: 'data', includeIfNull: false)
  Map<String, String>? data;

}
