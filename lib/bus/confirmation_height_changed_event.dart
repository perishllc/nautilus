import 'package:event_taxi/event_taxi.dart';

class ConfirmationHeightChangedEvent implements Event {

  ConfirmationHeightChangedEvent({this.confirmationHeight});
  final int? confirmationHeight;
}