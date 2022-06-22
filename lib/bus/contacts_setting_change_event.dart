import 'package:event_taxi/event_taxi.dart';

class ContactsSettingChangeEvent implements Event {
  bool isOn;

  ContactsSettingChangeEvent({required this.isOn}) : super();
}
