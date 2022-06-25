// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_balance_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBalanceItem _$AccountBalanceItemFromJson(Map<String, dynamic> json) {
  return AccountBalanceItem(
    balance: json['balance'] as String?,
    receivable: json['receivable'] as String?,
  );
}

Map<String, dynamic> _$AccountBalanceItemToJson(AccountBalanceItem instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'receivable': instance.receivable,
    };
