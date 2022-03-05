// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_ack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentACK _$PaymentACKFromJson(Map<String, dynamic> json) {
  return PaymentACK(
    action: json['action'] as String,
    uuid: json['uuid'] as String,
    requesting_account: json['requesting_account'] as String,
  );
}

Map<String, dynamic> _$PaymentACKToJson(PaymentACK instance) {
  final val = <String, dynamic>{
    'action': instance.action,
    'uuid': instance.uuid,
    'requesting_account': instance.requesting_account,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  return val;
}
