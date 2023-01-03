// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
      name: json['name'] as String,
      http_url: json['http_url'] as String,
      ws_url: json['ws_url'] as String,
      selected: json['selected'] as bool,
    );

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      'name': instance.name,
      'http_url': instance.http_url,
      'ws_url': instance.ws_url,
      'selected': instance.selected,
    };
