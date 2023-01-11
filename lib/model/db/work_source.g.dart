// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkSource _$WorkSourceFromJson(Map<String, dynamic> json) => WorkSource(
      name: json['name'] as String,
      type: json['type'] as String,
      selected: json['selected'] as bool,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$WorkSourceToJson(WorkSource instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'type': instance.type,
      'selected': instance.selected,
    };
