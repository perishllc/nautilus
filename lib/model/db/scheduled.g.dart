// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scheduled _$ScheduledFromJson(Map<String, dynamic> json) => Scheduled(
      label: json['label'] as String,
      active: json['active'] as bool? ?? false,
      autopay: json['autopay'] as bool? ?? false,
      paid: json['paid'] as bool? ?? false,
      amount_raw: json['amount_raw'] as String,
      address: json['address'] as String,
      timestamp: json['timestamp'] as int,
    );

Map<String, dynamic> _$ScheduledToJson(Scheduled instance) => <String, dynamic>{
      'label': instance.label,
      'active': instance.active,
      'autopay': instance.autopay,
      'paid': instance.paid,
      'amount_raw': instance.amount_raw,
      'address': instance.address,
      'timestamp': instance.timestamp,
    };
