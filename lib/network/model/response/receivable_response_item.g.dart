// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receivable_response_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceivableResponseItem _$ReceivableResponseItemFromJson(
        Map<String, dynamic> json) =>
    ReceivableResponseItem(
      source: json['source'] as String?,
      amount: json['amount'] as String?,
      hash: json['hash'] as String?,
    );

Map<String, dynamic> _$ReceivableResponseItemToJson(
        ReceivableResponseItem instance) =>
    <String, dynamic>{
      'source': instance.source,
      'amount': instance.amount,
      'hash': instance.hash,
    };
