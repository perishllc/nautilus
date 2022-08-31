import 'package:event_taxi/event_taxi.dart';

class XMREvent implements Event {

  XMREvent({this.type = "", this.message = ""});
  
  final String type;
  final String message;
}
