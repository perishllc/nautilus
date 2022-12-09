import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/user.dart';

class ContactAddedEvent implements Event {
  final User? contact;

  ContactAddedEvent({this.contact});
}