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
  @JsonKey(name: 'link')
  String link;
  @JsonKey(name: 'memo_enc')
  String memo_enc;
  @JsonKey(name: 'is_memo')
  bool is_memo;
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
  @JsonKey(name: 'send_height')
  int send_height;
  @JsonKey(name: 'recv_height')
  int recv_height;
  @JsonKey(name: 'record_type')
  String record_type;
  @JsonKey(name: 'metadata')
  String metadata;
  @JsonKey(name: 'status')
  String status;

  TXData(
      {this.from_address,
      this.to_address,
      this.amount_raw,
      this.is_request,
      this.request_time,
      this.is_fulfilled,
      this.fulfillment_time,
      this.block,
      this.link,
      this.memo_enc,
      this.is_memo,
      this.memo,
      this.uuid,
      this.is_acknowledged,
      this.height,
      this.send_height,
      this.recv_height,
      this.record_type,
      this.metadata,
      this.status,
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
        link: json["link"] as String,
        memo_enc: json["memo_enc"] as String,
        is_memo: json["is_memo"] as bool,
        memo: json["memo"] as String,
        uuid: json["uuid"] as String,
        is_acknowledged: json["is_acknowledged"] as bool,
        height: json["height"] as int,
        send_height: json["send_height"] as int,
        recv_height: json["recv_height"] as int,
        record_type: json["record_type"] as String,
        metadata: json["metadata"] as String,
        status: json["status"] as String);
  }

  bool operator ==(o) =>
      o is TXData &&
      o.height == height &&
      o.send_height == send_height &&
      o.recv_height == recv_height &&
      o.uuid == uuid &&
      o.is_fulfilled == is_fulfilled &&
      o.is_request == is_request &&
      o.from_address == from_address &&
      o.to_address == to_address &&
      o.amount_raw == amount_raw &&
      o.request_time == request_time &&
      o.fulfillment_time == fulfillment_time &&
      o.block == block &&
      o.link == link &&
      o.memo_enc == memo_enc &&
      o.is_memo == is_memo &&
      o.memo == memo &&
      o.is_acknowledged == is_acknowledged &&
      o.record_type == record_type &&
      o.metadata == metadata &&
      o.status == status;

  // bool operator ==(o) => o is User && o.username == username && o.address == address;
  // int get hashCode => hash2(username.hashCode, address.hashCode);
}
