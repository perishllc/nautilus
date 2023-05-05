import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'handoff_work_response.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class HandoffWorkResponse {
  HandoffWorkResponse();
  factory HandoffWorkResponse.fromJson(Map<String, dynamic> json) => _$HandoffWorkResponseFromJson(json);

  @JsonKey(name: 'work')
  String? work;

  @JsonKey(name: 'frontier')
  String? frontier;

  @JsonKey(name: 'difficulty')
  String? difficulty;

  bool isValid() {
    return true;
  }
}
