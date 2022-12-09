import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/user.dart';

class UserModifiedEvent implements Event {
  final User? user;

  UserModifiedEvent({this.user});
}
