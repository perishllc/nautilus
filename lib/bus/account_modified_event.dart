import 'package:event_taxi/event_taxi.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';

class AccountModifiedEvent implements Event {
  final Account? account;
  final bool deleted;
  final bool created;

  AccountModifiedEvent({this.account, this.deleted = false, this.created = false});
}
