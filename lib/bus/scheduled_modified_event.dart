import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/scheduled.dart';

class ScheduledModifiedEvent implements Event {
  ScheduledModifiedEvent({this.scheduled, this.deleted = false, this.created = false});
  final Scheduled? scheduled;
  final bool deleted;
  final bool created;
}
