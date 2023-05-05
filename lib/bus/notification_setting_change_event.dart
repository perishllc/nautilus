import 'package:event_taxi/event_taxi.dart';

class NotificationSettingChangeEvent implements Event {
  bool isOn;

  NotificationSettingChangeEvent({required this.isOn}) : super();
}
