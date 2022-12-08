// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_info_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockInfoItem _$BlockInfoItemFromJson(Map<String, dynamic> json) =>
    BlockInfoItem(
      blockAccount: json['block_account'] as String?,
      amount: json['amount'] as String?,
      balance: json['balance'] as String?,
      receivable: json['receivable'] as String?,
      sourceAccount: json['source_account'] as String?,
      contents: json['contents'] as String?,
      confirmed: json['confirmed'] as String?,
    );

Map<String, dynamic> _$BlockInfoItemToJson(BlockInfoItem instance) =>
    <String, dynamic>{
      'block_account': instance.blockAccount,
      'amount': instance.amount,
      'balance': instance.balance,
      'receivable': instance.receivable,
      'source_account': instance.sourceAccount,
      'contents': instance.contents,
      'confirmed': instance.confirmed,
    };
