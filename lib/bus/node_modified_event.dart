import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/node.dart';

class NodeModifiedEvent implements Event {
  NodeModifiedEvent({this.node, this.deleted = false, this.created = false});
  final Node? node;
  final bool deleted;
  final bool created;
}
