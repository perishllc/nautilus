import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/base_request.dart';

part 'subscribe_option.g.dart';

@JsonSerializable()
class SubscribeOption extends BaseRequest {


  SubscribeOption({this.accounts}) : super();

  factory SubscribeOption.fromJson(Map<String, dynamic> json) => _$SubscribeOptionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SubscribeOptionToJson(this);

  @JsonKey(name: 'accounts', includeIfNull: false)
  List<String>? accounts;
  
}
