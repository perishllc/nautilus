// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Blocked _$BlockedFromJson(Map<String, dynamic> json) => Blocked(
      username: json['username'] as String?,
      address: json['address'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$BlockedToJson(Blocked instance) => <String, dynamic>{
      'name': instance.name,
      'username': instance.username,
      'address': instance.address,
    };
