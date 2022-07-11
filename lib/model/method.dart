import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

// Object to represent block handoff method:
@JsonSerializable()
class Method {
  String type;

  @JsonKey(includeIfNull: false)
  String? url;

  Method({required this.type, this.url});
}
