import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

part 'node.g.dart';

@JsonSerializable()
class Node {
  @JsonKey(ignore: true)
  int? id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'http_url')
  String http_url;
  @JsonKey(name: 'ws_url')
  String ws_url;
  @JsonKey(name: 'selected')
  bool selected;

  Node({required this.name, required this.http_url, required this.ws_url, required this.selected, this.id});

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
  Map<String, dynamic> toJson() => _$NodeToJson(this);

  bool operator ==(o) => o is Node && o.name == name && o.http_url == http_url && o.ws_url == ws_url;
  int get hashCode => hash2(name.hashCode, name.hashCode);

}
