import 'package:json_annotation/json_annotation.dart';

part 'funding_response_item.g.dart';

@JsonSerializable()
class FundingResponseItem {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'active')
  bool? active;

  @JsonKey(name: 'priority')
  String? priority;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'short_description')
  String? shortDescription;

  @JsonKey(name: 'long_description')
  String? longDescription;

  @JsonKey(name: 'goal_amount_raw')
  String? goalAmountRaw;

  @JsonKey(name: 'current_amount_raw')
  String? currentAmountRaw;

  @JsonKey(name: 'address')
  String? address;

  @JsonKey(name: 'link')
  String? link;

  @JsonKey(name: 'timestamp')
  int? timestamp;

  @JsonKey(name: 'show_on_ios')
  bool? showOnIos;

  FundingResponseItem({
    this.id,
    this.active,
    this.priority,
    this.title,
    this.shortDescription,
    this.longDescription,
    this.goalAmountRaw,
    this.currentAmountRaw,
    this.address,
    this.link,
    this.timestamp,
    this.showOnIos
  });

  factory FundingResponseItem.fromJson(Map<String, dynamic> json) =>
      _$FundingResponseItemFromJson(json);
  Map<String, dynamic> toJson() => _$FundingResponseItemToJson(this);

  bool operator ==(o) => o is FundingResponseItem && o.id == id;
  int get hashCode => id.hashCode;
}
