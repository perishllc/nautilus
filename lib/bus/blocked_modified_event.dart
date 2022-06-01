import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/model/db/blocked.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';

class BlockedModifiedEvent implements Event {
  final User blocked;

  BlockedModifiedEvent({this.blocked});
}
