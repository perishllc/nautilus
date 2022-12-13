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
  @JsonKey(name: 'rpc_url')
  String rpc_url;
  @JsonKey(name: 'ws_url')
  String ws_url;

  Node({required this.name, required this.rpc_url, required this.ws_url});

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
  Map<String, dynamic> toJson() => _$NodeToJson(this);

  bool operator ==(o) => o is Node && o.name == name && o.rpc_url == rpc_url && o.ws_url == ws_url;
  int get hashCode => hash2(name.hashCode, name.hashCode);

}
