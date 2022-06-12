import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';

class UserAddedEvent implements Event {
  final User? user;

  UserAddedEvent({this.user});
}
