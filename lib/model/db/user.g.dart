// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['name'] as String?,
      address: json['address'] as String?,
      expiration: json['expires'] as String?,
      representative: json['representative'] as bool,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.username,
      'address': instance.address,
      'expires': instance.expiration,
      'representative': instance.representative,
    };
