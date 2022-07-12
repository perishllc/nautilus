import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'method.g.dart';

// Object to represent block handoff method:
@JsonSerializable()
class Method {
  
  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'url', includeIfNull: false)
  String? url;

  Method({required this.type, this.url});

  factory Method.fromJson(Map<String, dynamic> json) => _$MethodFromJson(json);
  Map<String, dynamic> toJson() => _$MethodToJson(this);
}
