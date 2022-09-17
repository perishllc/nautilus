import 'package:json_annotation/json_annotation.dart';

part 'price_response.g.dart';

int? _toInt(String v) => int.tryParse(v);

double? _toDouble(v) {
  return double.tryParse(v.toString());
}

@JsonSerializable()
class PriceResponse {
  @JsonKey(name: 'currency')
  String? currency;

  @JsonKey(name: 'price', fromJson: _toDouble)
  double? price;

  @JsonKey(name: 'xmr', fromJson: _toDouble)
  double? xmrPrice;

  PriceResponse();

  factory PriceResponse.fromJson(Map<String, dynamic> json) => _$PriceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PriceResponseToJson(this);
}
