// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'n2_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

N2Node _$N2NodeFromJson(Map<String, dynamic> json) => N2Node(
      weight: _toDouble(json['weight'] as num),
      uptime: json['uptime'] as String?,
      score: json['score'] as int?,
      account: json['rep_address'] as String?,
      alias: json['alias'] as String?,
    );

Map<String, dynamic> _$N2NodeToJson(N2Node instance) => <String, dynamic>{
      'uptime': instance.uptime,
      'weight': instance.weight,
      'score': instance.score,
      'rep_address': instance.account,
      'alias': instance.alias,
    };
