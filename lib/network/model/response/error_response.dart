import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

@JsonSerializable()
class ErrorResponse {
  @JsonKey(name: 'error')
  String? error;
  @JsonKey(name: 'details')
  String? details;

  ErrorResponse({String? error, String? details}) {
    this.error = error;
    this.details = details;
  }

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}
