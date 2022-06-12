import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';

class UserRemovedEvent implements Event {
  final User? user;

  UserRemovedEvent({this.user});
}
