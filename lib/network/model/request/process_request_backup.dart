// import 'package:json_annotation/json_annotation.dart';
// import 'package:wallet_flutter/network/model/request/actions.dart';
// import 'package:wallet_flutter/network/model/base_request.dart';

// part 'process_request.g.dart';

// @JsonSerializable()
// class ProcessRequest extends BaseRequest {
//   @JsonKey(name: 'action')
//   String? action;

//   @JsonKey(name: 'block')
//   String? block;

//   // Kalium/Natrium server accepts an optional do_work parameter. If true server will add work to this block for us
//   @JsonKey(name: 'do_work')
//   bool? doWork;

//   @JsonKey(name: 'json_block')
//   bool? json_block;

//   @JsonKey(name: 'subtype')
//   String? subtype;

//   ProcessRequest({this.block, this.doWork = true, this.subtype}) {
//     action = Actions.PROCESS;
//     json_block = true;
//   }

//   factory ProcessRequest.fromJson(Map<String, dynamic> json) => _$ProcessRequestFromJson(json);
//   Map<String, dynamic> toJson() => _$ProcessRequestToJson(this);
// }
