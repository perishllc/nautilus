import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/base_request.dart';

part 'auth_reply_request.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class AuthReplyRequest extends BaseRequest {

  AuthReplyRequest({this.account, this.signature, this.signed, this.formatted, this.message, this.label});

  factory AuthReplyRequest.fromJson(Map<String, dynamic> json) => _$AuthReplyRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthReplyRequestToJson(this);

  @JsonKey(name: "account")
  String? account;

  @JsonKey(name: "signature")
  String? signature;

  @JsonKey(name: "signed")
  String? signed;

  @JsonKey(name: "formatted")
  String? formatted;

  @JsonKey(name: "message")
  String? message;

  @JsonKey(name: "label")
  String? label;
}
