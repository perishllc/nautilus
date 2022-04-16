import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/model/db/blocked.dart';

class BlockedModifiedEvent implements Event {
  final Blocked blocked;

  BlockedModifiedEvent({this.blocked});
}
