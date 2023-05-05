import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

part 'work_source.g.dart';

class WorkSourceTypes {
  static const String NONE = "none";
  static const String NODE = "node";
  static const String URL = "url";
  static const String LOCAL = "local";
}

@JsonSerializable()
class WorkSource {
  @JsonKey(ignore: true)
  int? id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'url')
  String? url;
  @JsonKey(name: 'type')
  String type;
  @JsonKey(name: 'selected')
  bool selected;

  WorkSource({required this.name, required this.type, required this.selected, this.url, this.id});

  // factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
  // Map<String, dynamic> toJson() => _$NodeToJson(this);

  // bool operator ==(o) => o is Node && o.name == name && o.http_url == http_url && o.ws_url == ws_url;
  // int get hashCode => hash2(name.hashCode, name.hashCode);

}
