// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      address: json['address'] as String,
      type: json['type'] as String,
      expiration: json['expires'] as String,
      representative: json['representative'] as bool,
      blocked: json['blocked'] as bool,
      last_updated: json['last_updated'] as int,
      aliases: (json['aliases'] as List)?.map((e) => e as String)?.toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'nickname': instance.nickname,
      'address': instance.address,
      'type': instance.type,
      'expires': instance.expiration,
      'representative': instance.representative,
      'blocked': instance.blocked,
      'last_updated': instance.last_updated,
      'aliases': instance.aliases,
    };
