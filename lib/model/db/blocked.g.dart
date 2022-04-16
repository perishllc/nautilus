// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Blocked _$UserFromJson(Map<String, dynamic> json) => Blocked(
      username: json['name'] as String,
      address: json['address'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$BlockedToJson(Blocked instance) => <String, dynamic>{
      'name': instance.username,
      'address': instance.address,
      'name': instance.name,
    };
