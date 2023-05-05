import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/subscription.dart';

class SubModifiedEvent implements Event {
  SubModifiedEvent({this.sub, this.deleted = false, this.created = false});
  final Subscription? sub;
  final bool deleted;
  final bool created;
}
