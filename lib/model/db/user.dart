import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(ignore: true)
  int id;
  @JsonKey(name: 'name')
  String username;
  @JsonKey(name: 'address')
  String address;
  @JsonKey(name: 'expires')
  String expiration;
  @JsonKey(name: 'representative')
  bool representative;
  @JsonKey(name: 'blocked')
  bool blocked;
  // @JsonKey(ignore: true)
  // String monkeyPath;
  // @JsonKey(ignore: true)
  // Widget monkeyWidget;
  // @JsonKey(ignore: true)
  // Widget monkeyWidgetLarge;

  User({@required this.username, @required this.address, this.expiration, this.representative, this.blocked});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        username: json["name"] as String,
        address: json["address"] as String,
        expiration: json["expires"] as String,
        representative: json["representative"] as bool,
        blocked: json["blocked"] as bool);
  }
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool operator ==(o) => o is User && o.username == username && o.address == address;
  int get hashCode => hash2(username.hashCode, address.hashCode);
}
