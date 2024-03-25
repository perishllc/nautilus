import 'package:json_annotation/json_annotation.dart';

part 'n2_node.g.dart';

double? _toDouble(num v) {
  return double.tryParse(v.toString());
}

BigInt _toBigInt(num v) {
  return BigInt.from(v);
}

/// Represent a node that is returned from the MyNanoNinja API
@JsonSerializable()
class N2Node {

  N2Node({this.weight, this.uptime, this.score, this.account, this.alias});

  factory N2Node.fromJson(Map<String, dynamic> json) => _$N2NodeFromJson(json);

  @JsonKey(name: 'uptime')
  String? uptime;
  
  @JsonKey(name: 'weight', fromJson: _toDouble)
  double? weight;

  @JsonKey(name: 'score')
  int? score;

  @JsonKey(name: 'rep_address')
  String? account;

  @JsonKey(name: 'alias')
  String? alias;
  Map<String, dynamic> toJson() => _$N2NodeToJson(this);
}
