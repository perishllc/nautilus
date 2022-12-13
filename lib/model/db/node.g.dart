// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
      name: json['name'] as String,
      rpc_url: json['rpc_url'] as String,
      ws_url: json['ws_url'] as String,
    );

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      'name': instance.name,
      'rpc_url': instance.rpc_url,
      'ws_url': instance.ws_url,
    };
