import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
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
  @JsonKey(name: 'frequency')
  String frequency;

  Subscription({
    required this.label,
    this.active = false,
    this.autopay = false,
    this.paid = false,
    required this.amount_raw,
    required this.address,
    this.id,
    required this.frequency,
  });

  // factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
  // Map<String, dynamic> toJson() => _$SubscriptionToJson(this);

  // bool operator ==(o) => o is Subscription && o.name == name && o.http_url == http_url && o.ws_url == ws_url;
  // int get hashCode => hash2(name.hashCode, name.hashCode);

}
