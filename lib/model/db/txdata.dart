import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:quiver/core.dart';

// id INTEGER PRIMARY KEY AUTOINCREMENT,
// block TEXT,
// from_address TEXT,
// to_address TEXT,
// amount_raw TEXT,
// is_request BOOLEAN,
// is_fulfilled BOOLEAN,
// fulfillment_time TEXT,
// memo TEXT

// part 'user.g.dart';

@JsonSerializable()
class TXData {
  @JsonKey(ignore: true)
  int id;
  @JsonKey(name: 'block')
  String block;
  @JsonKey(name: 'from_address')
  String from_address;
  @JsonKey(name: 'to_address')
  String to_address;
  @JsonKey(name: 'amount_raw')
  String amount_raw;
  @JsonKey(name: 'is_request')
  bool is_request;
  @JsonKey(name: 'request_time')
  String request_time;
  @JsonKey(name: 'is_fulfilled')
  bool is_fulfilled;
  @JsonKey(name: 'fulfillment_time')
  String fulfillment_time;
  @JsonKey(name: 'memo')
  String memo;
  @JsonKey(name: 'uuid')
  String uuid;
  @JsonKey(name: 'is_acknowledged')
  bool is_acknowledged;
  @JsonKey(name: 'height')
  int height;

  TXData(
      {@required this.from_address,
      @required this.to_address,
      @required this.amount_raw,
      this.is_request,
      this.request_time,
      this.is_fulfilled,
      this.fulfillment_time,
      this.block,
      this.memo,
      this.uuid,
      this.is_acknowledged,
      this.height,
      int id});

  String getShortString(bool isRecipient) {
    if (isRecipient) {
      return new Address(this.from_address).getShortString();
    } else {
      return new Address(this.to_address).getShortString();
    }
  }

  String getShorterString(isRecipient) {
    if (isRecipient) {
      return new Address(this.from_address).getShorterString();
    } else {
      return new Address(this.to_address).getShorterString();
    }
  }

  factory TXData.fromJson(Map<String, dynamic> json) {
    return TXData(
        from_address: json["from_address"] as String,
        to_address: json["to_address"] as String,
        amount_raw: json["amount_raw"] as String,
        is_request: json["is_request"] as bool,
        request_time: json["request_time"] as String,
        is_fulfilled: json["is_fulfilled"] as bool,
        fulfillment_time: json["fulfillment_time"] as String,
        block: json["block"] as String,
        memo: json["memo"] as String,
        uuid: json["uuid"] as String,
        is_acknowledged: json["is_acknowledged"] as bool,
        height: json["height"] as int);
  }

  // bool operator ==(o) => o is User && o.username == username && o.address == address;
  // int get hashCode => hash2(username.hashCode, address.hashCode);
}
