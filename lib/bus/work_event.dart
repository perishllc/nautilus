import 'package:event_taxi/event_taxi.dart';

class WorkEvent implements Event {

  WorkEvent({this.type = "", this.message = ""});
  
  final String type;
  final String message;
}