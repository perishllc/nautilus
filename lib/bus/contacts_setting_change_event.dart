import 'package:event_taxi/event_taxi.dart';

class ContactsSettingChangeEvent implements Event {
  ContactsSettingChangeEvent({required this.isOn}) : super();
  final bool isOn;
}
