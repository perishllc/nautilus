import 'package:event_taxi/event_taxi.dart';

class DeepLinkEvent implements Event {

  DeepLinkEvent({this.link});
  final String? link;
}