import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

part 'user.g.dart';

class UserTypes {
  static const String UD = "unstoppable_domain";
  static const String ENS = "ethereum_name_service";
  static const String NANOTO = "nano_to";
  static const String CONTACT = "contact";
}

@JsonSerializable()
class User {
  @JsonKey(ignore: true)
  int id;
  @JsonKey(name: 'username')
  String username;
  @JsonKey(name: 'nickname')
  String nickname;
  @JsonKey(name: 'address')
  String address;
  @JsonKey(name: 'type')
  String type;
  @JsonKey(name: 'expires')
  String expiration;
  @JsonKey(name: 'representative')
  bool representative;
  @JsonKey(name: 'is_blocked')
  bool is_blocked;
  @JsonKey(name: 'last_updated')
  int last_updated;
  @JsonKey(name: 'aliases')
  List<String> aliases;
  // @JsonKey(ignore: true)
  // String monkeyPath;
  // @JsonKey(ignore: true)
  // Widget monkeyWidget;
  // @JsonKey(ignore: true)
  // Widget monkeyWidgetLarge;

  User({this.username, @required this.address, this.expiration, this.representative, this.is_blocked, this.type, this.last_updated, this.nickname, this.aliases});

  factory User.fromJson(Map<String, dynamic> json) {
    String username = json['username'] ?? json['name'];
    return User(
        username: username,
        nickname: json["nickname"] as String,
        address: json["address"] as String,
        type: json["type"] as String,
        expiration: json["expires"] as String,
        representative: json["representative"] as bool,
        is_blocked: json["is_blocked"] as bool,
        last_updated: json["last_updated"] as int,
        aliases: json["aliases"] as List<String>);
  }
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String getDisplayName({bool ignoreNickname = false}) {
    if (nickname != null && nickname.isNotEmpty && !ignoreNickname) {
      return "★" + nickname;
    }

    return getDisplayNameWithType(this.username, this.type);
  }

  static String getDisplayNameWithType(String name, String userType) {
    if (userType == UserTypes.NANOTO) {
      return "@" + name;
    } else {
      return name;
    }
  }

  bool operator ==(o) => o is User && o.username == username && o.address == address && o.type == type && o.nickname == nickname;
  int get hashCode => hash2(username.hashCode, address.hashCode);
}
