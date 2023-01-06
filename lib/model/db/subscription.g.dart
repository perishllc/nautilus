// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
      name: json['name'] as String,
      active: json['active'] as bool? ?? false,
      amount_raw: json['amount_raw'] as String,
      address: json['address'] as String,
      frequency: json['frequency'] as String,
    );

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'name': instance.name,
      'active': instance.active,
      'amount_raw': instance.amount_raw,
      'address': instance.address,
      'frequency': instance.frequency,
    };
