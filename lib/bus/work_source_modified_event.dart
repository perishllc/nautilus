import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/work_source.dart';

class WorkSourceModifiedEvent implements Event {
  WorkSourceModifiedEvent({this.workSource, this.deleted = false, this.created = false});
  final WorkSource? workSource;
  final bool deleted;
  final bool created;
}
