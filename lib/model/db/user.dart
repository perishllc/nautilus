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
  @JsonKey(name: 'blocked')
  bool blocked;
  @JsonKey(name: 'last_updated')
  int last_updated;
  // @JsonKey(ignore: true)
  // String monkeyPath;
  // @JsonKey(ignore: true)
  // Widget monkeyWidget;
  // @JsonKey(ignore: true)
  // Widget monkeyWidgetLarge;

  User({this.username, @required this.address, this.expiration, this.representative, this.blocked, this.type, this.last_updated, this.nickname});

  factory User.fromJson(Map<String, dynamic> json) {
    String username = json['username'] ?? json['name'];
    return User(
        username: username,
        nickname: json["nickname"] as String,
        address: json["address"] as String,
        type: json["type"] as String,
        expiration: json["expires"] as String,
        representative: json["representative"] as bool,
        blocked: json["blocked"] as bool,
        last_updated: json["last_updated"] as int);
  }
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String getDisplayName() {
    if (nickname != null && nickname.isNotEmpty) {
      return "★" + nickname;
    }

    if (type == UserTypes.NANOTO) {
      return "@" + username;
    } else {
      return username;
    }

    //     } else if (type == UserTypes.CONTACT) {
    //   return "★" + nickname;
    // } else {
    //   return username;
    // }
  }

  bool operator ==(o) => o is User && o.username == username && o.address == address && o.type == type && o.nickname == nickname;
  int get hashCode => hash2(username.hashCode, address.hashCode);
}
