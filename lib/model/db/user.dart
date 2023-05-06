import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:quiver/core.dart';

part 'user.g.dart';

class UserTypes {
  static const String UD = "unstoppable_domain";
  static const String ENS = "ethereum_name_service";
  static const String NANO_TO = "nano_to";
  static const String OPENCAP = "opencap";
  static const String CONTACT = "contact";
  static const String ONCHAIN = "onchain";
}

String? lowerStripAddress(String? address) {
  if (address == null) {
    return null;
  }
  return address
      .toLowerCase()
      .replaceAll("xrb_", "")
      .replaceAll("nano_", "")
      .replaceAll("ban_", "")
      .replaceAll(" ", "");
}

String? formatAddress(String? address) {
  if (address == null) {
    return null;
  }
  // nano mode:
  return "nano_${lowerStripAddress(address)}";
}

@JsonSerializable()
class User {
  @JsonKey(ignore: true)
  int? id;
  @JsonKey(name: 'username')
  String? username;
  @JsonKey(name: 'nickname')
  String? nickname;
  @JsonKey(name: 'address')
  String? address;
  // @JsonKey(name: 'address_raw')
  // String? address_raw;
  // String? get address => formatAddress(address_raw);
  // set address(String? value) {
  //   address_raw = lowerStripAddress(value);
  // }

  @JsonKey(name: 'type')
  String? type;
  @JsonKey(name: 'expires')
  String? expiration;
  @JsonKey(name: 'representative')
  bool? representative;
  @JsonKey(name: 'is_blocked')
  bool? is_blocked;
  @JsonKey(name: 'last_updated')
  int? last_updated;
  @JsonKey(name: 'aliases')
  List<String?>? aliases;

  User(
      {this.username,
      this.address,
      this.expiration,
      this.representative,
      this.is_blocked,
      this.type,
      this.last_updated,
      this.nickname,
      this.aliases});

  // Map<String, dynamic> toJson() => _$UserToJson(this);
  // User fromJson() => _$UserFromJson(this);

  factory User.fromJson(Map<String, dynamic> json) {
    final String? username = json['username'] as String? ?? json['name'] as String?;
    return User(
        username: username,
        nickname: (json["nickname"] ?? json["name"]) as String?,
        address: formatAddress((json["address"] ?? json["account"]) as String?),
        type: json["type"] as String?,
        expiration: json["expires"] as String?,
        representative: json["representative"] as bool?,
        is_blocked: json["is_blocked"] as bool?,
        last_updated: json["last_updated"] as int?,
        aliases: json["aliases"] as List<String>?);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'username': username,
      'nickname': nickname,
      'address': address,
      'type': type,
      'expires': expiration,
      'representative': representative,
      'is_blocked': is_blocked,
      'last_updated': last_updated,
      'aliases': aliases,
    };
  }

  String? getDisplayName({bool ignoreNickname = false}) {
    if (nickname != null && nickname!.isNotEmpty && !ignoreNickname) {
      return "★${nickname!}";
    }

    final String? displayName = getDisplayNameWithType(username, type);

    if (displayName == null && nickname != null) {
      // fall back to nickname if username is empty:
      return "★${nickname!}";
    }
    return displayName;
  }

  String? displayNameOrShortestAddress({bool ignoreNickname = false}) {
    String? displayName = getDisplayName(ignoreNickname: ignoreNickname);
    displayName ??= Address(address).getShortestString();
    return displayName;
  }

  static String? getDisplayNameWithType(String? name, String? userType) {
    if (userType == UserTypes.ONCHAIN) {
      return "@${name!}";
    } else if (userType == UserTypes.NANO_TO) {
      return "@${name!}";
    } else {
      return name;
    }
  }

  bool operator ==(o) =>
      o is User && o.username == username && o.address == address && o.type == type && o.nickname == nickname;
  int get hashCode => hash2(username.hashCode, address.hashCode);
}
