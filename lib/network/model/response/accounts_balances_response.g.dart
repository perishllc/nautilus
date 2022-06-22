// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_balances_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountsBalancesResponse _$AccountsBalancesResponseFromJson(Map<String, dynamic> json) {
  late AccountsBalancesResponse resp;

  try {
    resp = AccountsBalancesResponse(
      balances: (json['balances'] as Map<String, dynamic>?)?.map(
        (String k, e) => MapEntry(k, /*e == null ? null : */ AccountBalanceItem.fromJson(e as Map<String, dynamic>)),
      ),
    );
  } catch (e) {
    if (json['balances'] as String == "") {
      // response is an empty string:
    }
    resp = AccountsBalancesResponse(
      balances: <String, AccountBalanceItem>{},
    );
  }
  return resp;
}

Map<String, dynamic> _$AccountsBalancesResponseToJson(AccountsBalancesResponse instance) => <String, dynamic>{
      'balances': instance.balances,
    };
