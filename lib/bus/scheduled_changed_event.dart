import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/scheduled.dart';

class ScheduledChangedEvent implements Event {
  ScheduledChangedEvent({this.scheduled});
  final List<Scheduled>? scheduled;
}
