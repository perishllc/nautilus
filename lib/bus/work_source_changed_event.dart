import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/work_source.dart';

class WorkSourceChangedEvent implements Event {

  WorkSourceChangedEvent({this.workSource, this.delayPop = false, this.noPop = false});
  
  final WorkSource? workSource;
  final bool delayPop;
  final bool noPop;
}
