// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_work_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandoffWorkResponse _$HandoffWorkResponseFromJson(Map<String, dynamic> json) =>
    HandoffWorkResponse()
      ..work = json['work'] as String?
      ..frontier = json['frontier'] as String?
      ..difficulty = json['difficulty'] as String?;

Map<String, dynamic> _$HandoffWorkResponseToJson(
        HandoffWorkResponse instance) =>
    <String, dynamic>{
      'work': instance.work,
      'frontier': instance.frontier,
      'difficulty': instance.difficulty,
    };
