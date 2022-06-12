import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';

class BlockedModifiedEvent implements Event {
  final User? user;

  BlockedModifiedEvent({this.user});
}
