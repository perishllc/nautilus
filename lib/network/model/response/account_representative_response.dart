import 'package:json_annotation/json_annotation.dart';

part 'account_representative_response.g.dart';

int? _toInt(String? v) => v == null ? 0 : int.tryParse(v);

@JsonSerializable()
class AccountRepresentativeResponse {
  @JsonKey(name: 'representative')
  String? representative;

  AccountRepresentativeResponse({this.representative}) : super();

  factory AccountRepresentativeResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountRepresentativeResponseFromJson(json);
      
  Map<String, dynamic> toJson() => _$AccountRepresentativeResponseToJson(this);
}
