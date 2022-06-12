import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/model/db/blocked.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';

class BlockedRemovedEvent implements Event {
  final User? user;

  BlockedRemovedEvent({this.user});
}
