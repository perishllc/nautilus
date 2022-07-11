// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['username'] as String?,
      address: json['address'] as String?,
      expiration: json['expires'] as String?,
      representative: json['representative'] as bool?,
      is_blocked: json['is_blocked'] as bool?,
      type: json['type'] as String?,
      last_updated: json['last_updated'] as int?,
      nickname: json['nickname'] as String?,
      aliases: (json['aliases'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'nickname': instance.nickname,
      'address': instance.address,
      'type': instance.type,
      'expires': instance.expiration,
      'representative': instance.representative,
      'is_blocked': instance.is_blocked,
      'last_updated': instance.last_updated,
      'aliases': instance.aliases,
    };
