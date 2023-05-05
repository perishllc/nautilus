import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/user.dart';

class BlockedRemovedEvent implements Event {
  BlockedRemovedEvent({this.user});

  final User? user;
}
