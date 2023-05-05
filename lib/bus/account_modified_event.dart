import 'package:event_taxi/event_taxi.dart';
import 'package:wallet_flutter/model/db/account.dart';

class AccountModifiedEvent implements Event {
  AccountModifiedEvent({this.account, this.deleted = false, this.created = false});
  final Account? account;
  final bool deleted;
  final bool created;
}
