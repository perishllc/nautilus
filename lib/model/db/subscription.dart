import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

// part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
  @JsonKey(ignore: true)
  int? id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'index')
  int index;
  @JsonKey(name: 'active')
  bool active;
  @JsonKey(name: 'amount_raw')
  String amount_raw;
  @JsonKey(name: 'address')
  String address;
  @JsonKey(name: 'day_of_month')
  int day_of_month;

  Subscription({
    required this.name,
    this.active = false,
    required this.amount_raw,
    required this.address,
    this.id,
    this.index = 0,
    this.day_of_month = 0,
  });

  // factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
  // Map<String, dynamic> toJson() => _$SubscriptionToJson(this);

  // bool operator ==(o) => o is Subscription && o.name == name && o.http_url == http_url && o.ws_url == ws_url;
  // int get hashCode => hash2(name.hashCode, name.hashCode);

}
