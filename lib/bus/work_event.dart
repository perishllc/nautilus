import 'package:event_taxi/event_taxi.dart';

class WorkEvent implements Event {

  WorkEvent({this.type = "", this.currentHash = "", this.value = "", this.subtype = ""});
  
  final String type;
  final String currentHash;
  final String value;
  final String subtype;
}