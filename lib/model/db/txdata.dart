// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/model/address.dart';

part 'txdata.g.dart';

@JsonSerializable()
class TXData {

  TXData(
      {this.from_address,
      this.to_address,
      this.amount_raw,
      this.is_request = false,
      this.request_time,
      this.is_fulfilled = false,
      this.fulfillment_time,
      this.block,
      this.link,
      this.memo_enc,
      this.is_memo = false,
      this.is_message = false,
      this.is_tx = false,
      this.memo,
      this.uuid,
      this.is_acknowledged = false,
      this.height,
      this.send_height,
      this.recv_height,
      this.record_type,
      this.sub_type,
      this.metadata,
      this.status,
      int? id});

  factory TXData.fromJson(Map<String, dynamic> json) {
    return TXData(
        from_address: json["from_address"] as String?,
        to_address: json["to_address"] as String?,
        amount_raw: json["amount_raw"] as String?,
        is_request: json["is_request"] as bool,
        request_time: json["request_time"] as int?,
        is_fulfilled: json["is_fulfilled"] as bool,
        fulfillment_time: json["fulfillment_time"] as int?,
        block: json["block"] as String?,
        link: json["link"] as String?,
        memo_enc: json["memo_enc"] as String?,
        is_memo: json["is_memo"] as bool,
        is_message: json["is_message"] as bool,
        is_tx: json["is_tx"] as bool,
        memo: json["memo"] as String?,
        uuid: json["uuid"] as String?,
        is_acknowledged: json["is_acknowledged"] as bool,
        height: json["height"] as int?,
        send_height: json["send_height"] as int?,
        recv_height: json["recv_height"] as int?,
        record_type: json["record_type"] as String?,
        sub_type: json["sub_type"] as String?,
        metadata: json["metadata"] as String?,
        status: json["status"] as String?);
  }
  @JsonKey(ignore: true)
  int? id;
  @JsonKey(name: 'block')
  String? block;
  @JsonKey(name: 'link')
  String? link;
  @JsonKey(name: 'memo_enc')
  String? memo_enc;
  @JsonKey(name: 'is_memo')
  bool is_memo;
  @JsonKey(name: 'is_message')
  bool is_message;
  @JsonKey(name: 'is_tx')
  bool is_tx;
  @JsonKey(name: 'from_address')
  String? from_address;
  @JsonKey(name: 'to_address')
  String? to_address;
  @JsonKey(name: 'amount_raw')
  String? amount_raw;
  @JsonKey(name: 'is_request')
  bool is_request;
  @JsonKey(name: 'request_time')
  int? request_time;
  @JsonKey(name: 'is_fulfilled')
  bool is_fulfilled;
  @JsonKey(name: 'fulfillment_time')
  int? fulfillment_time;
  @JsonKey(name: 'memo')
  String? memo;
  @JsonKey(name: 'uuid')
  String? uuid;
  @JsonKey(name: 'is_acknowledged')
  bool is_acknowledged;
  @JsonKey(name: 'height')
  int? height;
  @JsonKey(name: 'send_height')
  int? send_height;
  @JsonKey(name: 'recv_height')
  int? recv_height;
  @JsonKey(name: 'record_type')
  String? record_type;
  @JsonKey(name: 'sub_type')
  String? sub_type;
  @JsonKey(name: 'metadata')
  String? metadata;
  @JsonKey(name: 'status')
  String? status;

  String? getShortString(bool isRecipient) {
    if (isRecipient) {
      return Address(from_address).getShortString();
    } else {
      return Address(to_address).getShortString();
    }
  }

  String? getShorterString(bool isRecipient) {
    if (isRecipient) {
      return Address(from_address).getShorterString();
    } else {
      return Address(to_address).getShorterString();
    }
  }

  bool isRecipient(String? address) {
    return to_address == address;
  }

  String getAccount(bool isRecipient) {
    return isRecipient ? (from_address ?? "") : (to_address ?? "");
  }

  bool isSolid() {
    return is_message || is_request || is_tx;
  }

  bool isDeletable() {
    return is_message || is_request;
  }

  bool operator ==(o) =>
      o is TXData &&
      o.height == height &&
      o.send_height == send_height &&
      o.recv_height == recv_height &&
      o.uuid == uuid &&
      o.is_fulfilled == is_fulfilled &&
      o.is_request == is_request &&
      o.from_address == from_address &&
      o.to_address == to_address &&
      o.amount_raw == amount_raw &&
      o.request_time == request_time &&
      o.fulfillment_time == fulfillment_time &&
      o.block == block &&
      o.link == link &&
      o.memo_enc == memo_enc &&
      o.is_memo == is_memo &&
      o.is_message == is_message &&
      o.is_tx == is_tx &&
      o.memo == memo &&
      o.is_acknowledged == is_acknowledged &&
      o.record_type == record_type &&
      o.sub_type == sub_type &&
      o.metadata == metadata &&
      o.status == status;

  Map<String, dynamic> toJson() => _$TXDataToJson(this);

  // bool operator ==(o) => o is User && o.username == username && o.address == address;
  // int get hashCode => hash2(username.hashCode, address.hashCode);
}



// TXData _$TXDataFromJson(Map<String, dynamic> json) => TXData(
//       from_address: json['from_address'] as String?,
//       to_address: json['to_address'] as String?,
//       amount_raw: json['amount_raw'] as String?,
//       is_request: json['is_request'] as bool,
//       request_time: json['request_time'] as int?,
//       is_fulfilled: json['is_fulfilled'] as bool,
//       fulfillment_time: json['fulfillment_time'] as int?,
//       block: json['block'] as String?,
//       link: json['link'] as String?,
//       is_memo: json['is_memo'] as bool,
//       is_message: json['is_message'] as bool,
//       is_tx: json['is_tx'] as bool,
//       memo: json['memo'] as String?,
//       memo_enc: json['memo_enc'] as String?,
//       uuid: json['uuid'] as String?,
//       is_acknowledged: json['is_acknowledged'] as bool,
//       height: json['height'] as int?,
//       send_height: json['send_height'] as int?,
//       recv_height: json['recv_height'] as int?,
//       record_type: json['record_type'] as String?,
//       metadata: json['metadata'] as String?,
//       status: json['status'] as String?,
//     );

// Map<String, dynamic> _$TXDataToJson(TXData instance) => <String, dynamic>{
//       'from_address': instance.from_address,
//       'to_address': instance.to_address,
//       'amount_raw': instance.amount_raw,
//       'is_request': instance.is_request,
//       'request_time': instance.request_time,
//       'is_fulfilled': instance.is_fulfilled,
//       'fulfillment_time': instance.fulfillment_time,
//       'block': instance.block,
//       'link': instance.link,
//       'is_memo': instance.is_memo,
//       'is_message': instance.is_message,
//       'is_tx': instance.is_tx,
//       'memo': instance.memo,
//       'memo_enc': instance.memo_enc,
//       'uuid': instance.uuid,
//       'is_acknowledged': instance.is_acknowledged,
//       'height': instance.height,
//       'send_height': instance.send_height,
//       'recv_height': instance.recv_height,
//       'record_type': instance.record_type,
//       'metadata': instance.metadata,
//       'status': instance.status,
//     };