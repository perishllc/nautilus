import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/subscription.dart';

class SubsChangedEvent implements Event {
  SubsChangedEvent({this.subs});
  final List<Subscription>? subs;
}
