// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountInfoResponse _$AccountInfoResponseFromJson(Map<String, dynamic> json) =>
    AccountInfoResponse(
      frontier: json['frontier'] as String?,
      openBlock: json['open_block'] as String?,
      representativeBlock: json['representative_block'] as String?,
      balance: json['balance'] as String?,
      blockCount: _toInt(json['block_count'] as String?),
      confirmationHeight: _toInt(json['confirmation_height'] as String?),
    );

Map<String, dynamic> _$AccountInfoResponseToJson(
        AccountInfoResponse instance) =>
    <String, dynamic>{
      'frontier': instance.frontier,
      'open_block': instance.openBlock,
      'representative_block': instance.representativeBlock,
      'balance': instance.balance,
      'block_count': instance.blockCount,
      'confirmation_height': instance.confirmationHeight,
    };
