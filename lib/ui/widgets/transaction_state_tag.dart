import 'package:flutter/widgets.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/accounts/accounts_sheet.dart';

enum TransactionStateOptions { UNCONFIRMED, CONFIRMED, FAILED, UNACKNOWLEDGED, UNREAD, FULFILLED, UNFULFILLED, PAID, UNPAID, FAILED_MSG, NOT_SENT }

class TransactionStateTag extends StatelessWidget {
  final TransactionStateOptions? transactionState;

  TransactionStateTag({Key? key, this.transactionState}) : super(key: key);

  String getStateText(BuildContext context, TransactionStateOptions? state) {
    switch (state) {
      case TransactionStateOptions.UNCONFIRMED:
        return AppLocalization.of(context)!.unconfirmed;
      case TransactionStateOptions.CONFIRMED:
        return "tag";
      case TransactionStateOptions.FAILED:
        return AppLocalization.of(context)!.failed;
      case TransactionStateOptions.UNACKNOWLEDGED:
        return AppLocalization.of(context)!.unacknowledged;
      case TransactionStateOptions.UNREAD:
        return AppLocalization.of(context)!.unread;
      case TransactionStateOptions.PAID:
        return AppLocalization.of(context)!.paid;
      case TransactionStateOptions.UNPAID:
        return AppLocalization.of(context)!.unpaid;
      case TransactionStateOptions.FAILED_MSG:
        return AppLocalization.of(context)!.failedMessage;
      case TransactionStateOptions.NOT_SENT:
        return AppLocalization.of(context)!.notSent;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(6, 2, 6, 2),
      child: Text(
        getStateText(context, this.transactionState),
        style: AppStyles.tagText(context),
      ),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.text10,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
