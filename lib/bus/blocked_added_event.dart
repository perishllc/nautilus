import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/model/db/blocked.dart';

class BlockedAddedEvent implements Event {
  final Blocked blocked;

  BlockedAddedEvent({this.blocked});
}
