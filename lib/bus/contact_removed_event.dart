import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/user.dart';

class ContactRemovedEvent implements Event {
  final User? contact;

  ContactRemovedEvent({this.contact});
}