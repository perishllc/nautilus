// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeOption _$SubscribeOptionFromJson(Map<String, dynamic> json) =>
    SubscribeOption(
      accounts: (json['accounts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SubscribeOptionToJson(SubscribeOption instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('accounts', instance.accounts);
  return val;
}
