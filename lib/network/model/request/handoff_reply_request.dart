import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:nautilus_wallet_flutter/model/method.dart';
import 'package:nautilus_wallet_flutter/model/state_block.dart';

part 'handoff_reply_request.g.dart';

// Object to represent block handoff structure
@JsonSerializable()
class HandoffReplyRequest {

  HandoffReplyRequest();
  factory HandoffReplyRequest.fromJson(Map<String, dynamic> json) => _$HandoffReplyRequestFromJson(json);
  
  @JsonKey(name: 'methods')
  late List<Method> methods;

  @JsonKey(name: 'account')
  late String account;

  @JsonKey(name: 'amount')
  String? amount;

  @JsonKey(name: 'exact')
  bool exact = true;

  @JsonKey(name: 'work')
  bool work = true;

  @JsonKey(name: 'reuse')
  bool reuse = false;

  @JsonKey(name: 'block')
  StateBlock? block;
}
