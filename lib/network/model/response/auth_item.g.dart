// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthItem _$AuthItemFromJson(Map<String, dynamic> json) => AuthItem()
  ..methods = (json['methods'] as List<dynamic>)
      .map((e) => Method.fromJson(e as Map<String, dynamic>))
      .toList()
  ..label = json['label'] as String?
  ..format = (json['format'] as List<dynamic>).map((e) => e as String).toList()
  ..separator = json['separator'] as String
  ..reuse = json['reuse'] as bool;

Map<String, dynamic> _$AuthItemToJson(AuthItem instance) => <String, dynamic>{
      'methods': instance.methods,
      'label': instance.label,
      'format': instance.format,
      'separator': instance.separator,
      'reuse': instance.reuse,
    };
