import 'package:event_taxi/event_taxi.dart';

class FcmMessageEvent implements Event {
  dynamic data;
  List<String>? message_list;

  FcmMessageEvent({this.data, this.message_list}) : super();
}
