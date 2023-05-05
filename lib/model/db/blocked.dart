import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

part 'blocked.g.dart';

@JsonSerializable()
class Blocked {
  @JsonKey(ignore: true)
  int? id;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'username')
  String? username;
  @JsonKey(name: 'address')
  String? address;
  // @JsonKey(ignore: true)
  // String monkeyPath;
  // @JsonKey(ignore: true)
  // Widget monkeyWidget;
  // @JsonKey(ignore: true)
  // Widget monkeyWidgetLarge;

  Blocked({this.username, this.address, this.name});

  factory Blocked.fromJson(Map<String, dynamic> json) {
    return Blocked(username: json["username"] as String?, address: json["address"] as String?, name: json["name"] as String?);
  }
  Map<String, dynamic> toJson() => _$BlockedToJson(this);

  bool operator ==(o) => o is Blocked && o.username == username && o.address == address;
  int get hashCode => hash2(username.hashCode, address.hashCode);
}
