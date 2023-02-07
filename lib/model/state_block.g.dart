// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StateBlock _$StateBlockFromJson(Map<String, dynamic> json) => StateBlock(
      previous: json['previous'] as String?,
      representative: json['representative'] as String?,
      balance: json['balance'] as String?,
      link: json['link'] as String?,
      account: json['account'] as String?,
      work: json['work'] as String?,
    )
      ..type = json['type'] as String?
      ..subType = json['subtype'] as String?
      ..signature = json['signature'] as String?
      ..linkAsAccount = json['link_as_account'] as String?;

Map<String, dynamic> _$StateBlockToJson(StateBlock instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'subtype': instance.subType,
    'previous': instance.previous,
    'account': instance.account,
    'representative': instance.representative,
    'balance': instance.balance,
    'link': StateBlock._toJsonLink(instance.link),
    'signature': instance.signature,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('work', instance.work);
  writeNotNull('link_as_account', instance.linkAsAccount);
  return val;
}
