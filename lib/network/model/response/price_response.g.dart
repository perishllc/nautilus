// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceResponse _$PriceResponseFromJson(Map<String, dynamic> json) =>
    PriceResponse(
      currency: json['currency'] as String?,
      price: _toDouble(json['price']),
    )..xmrPrice = _toDouble(json['xmr']);

Map<String, dynamic> _$PriceResponseToJson(PriceResponse instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'price': instance.price,
      'xmr': instance.xmrPrice,
    };
