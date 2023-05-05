import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/user.dart';

class ContactModifiedEvent implements Event {
  final User? contact;

  ContactModifiedEvent({this.contact});
}