import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

part 'scheduled.g.dart';

@JsonSerializable()
class Scheduled {

  Scheduled({
    this.label = "",
    this.active = false,
    this.autopay = false,
    this.paid = false,
    required this.amount_raw,
    required this.address,
    this.id,
    required this.timestamp,
  });
  
  @JsonKey(ignore: true)
  int? id;
  @JsonKey(name: 'label')
  String label;
  @JsonKey(name: 'active')
  bool active;
  @JsonKey(name: 'autopay')
  bool autopay;
  @JsonKey(name: 'paid')
  bool paid;
  @JsonKey(name: 'amount_raw')
  String amount_raw;
  @JsonKey(name: 'address')
  String address;
  @JsonKey(name: 'timestamp')
  int timestamp;

  // factory Scheduled.fromJson(Map<String, dynamic> json) => _$ScheduledFromJson(json);
  // Map<String, dynamic> toJson() => _$ScheduledToJson(this);

  // bool operator ==(o) => o is Scheduled && o.name == name && o.http_url == http_url && o.ws_url == ws_url;
  // int get hashCode => hash2(name.hashCode, name.hashCode);

}
