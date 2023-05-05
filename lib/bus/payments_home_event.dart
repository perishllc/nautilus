import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
// import 'package:wallet_flutter/network/model/response/account_history_response_item.dart';

class PaymentsHomeEvent implements Event {
  final List<TXData>? items;

  PaymentsHomeEvent({this.items});
}
