// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'funding_response_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FundingResponseItem _$FundingResponseItemFromJson(Map<String, dynamic> json) =>
    FundingResponseItem(
      id: json['id'] as int?,
      active: json['active'] as bool?,
      priority: json['priority'] as String?,
      title: json['title'] as String?,
      shortDescription: json['short_description'] as String?,
      longDescription: json['long_description'] as String?,
      goalAmountRaw: json['goal_amount_raw'] as String?,
      currentAmountRaw: json['current_amount_raw'] as String?,
      address: json['address'] as String?,
      link: json['link'] as String?,
      timestamp: json['timestamp'] as int?,
      showOnIos: json['show_on_ios'] as bool?,
    );

Map<String, dynamic> _$FundingResponseItemToJson(
        FundingResponseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'priority': instance.priority,
      'title': instance.title,
      'short_description': instance.shortDescription,
      'long_description': instance.longDescription,
      'goal_amount_raw': instance.goalAmountRaw,
      'current_amount_raw': instance.currentAmountRaw,
      'address': instance.address,
      'link': instance.link,
      'timestamp': instance.timestamp,
      'show_on_ios': instance.showOnIos,
    };
