// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_ack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentACK _$PaymentACKFromJson(Map<String, dynamic> json) {
  return PaymentACK(
    action: json['action'] as String,
    uuid: json['uuid'] as String,
    account: json['account'] as String,
  );
}

Map<String, dynamic> _$PaymentACKToJson(PaymentACK instance) {
  final val = <String, dynamic>{
    'action': instance.action,
    'uuid': instance.uuid,
    'account': instance.account,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  return val;
}
