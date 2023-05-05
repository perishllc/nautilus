import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/model/state_block.dart';
import 'package:wallet_flutter/network/model/base_request.dart';

part 'handoff_reply_request.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class HandoffReplyRequest extends BaseRequest {

  HandoffReplyRequest({this.block, this.message, this.label, this.metadata});

  factory HandoffReplyRequest.fromJson(Map<String, dynamic> json) => _$HandoffReplyRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HandoffReplyRequestToJson(this);


  @JsonKey(name: "block")
  StateBlock? block;

  @JsonKey(name: "message")
  String? message;

  @JsonKey(name: "label")
  String? label;

  @JsonKey(name: "metadata")
  Map<String, String?>? metadata;
}
