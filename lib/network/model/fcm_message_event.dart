import 'package:event_taxi/event_taxi.dart';

class FcmMessageEvent implements Event {
  dynamic data;

  FcmMessageEvent({this.data}) : super();
}
