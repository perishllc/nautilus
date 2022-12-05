import 'package:flutter/widgets.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/styles.dart';

enum TransactionStateOptions { UNCONFIRMED, CONFIRMED, FAILED, UNACKNOWLEDGED, UNREAD, FULFILLED, UNFULFILLED, PAID, UNPAID, FAILED_MSG, NOT_SENT, RECEIVABLE }

class TransactionStateTag extends StatelessWidget {

  const TransactionStateTag({super.key, this.transactionState});
  
  final TransactionStateOptions? transactionState;

  String getStateText(BuildContext context, TransactionStateOptions? state) {
    switch (state) {
      case TransactionStateOptions.UNCONFIRMED:
        return Z.of(context).unconfirmed;
      case TransactionStateOptions.CONFIRMED:
        return "tag";
      case TransactionStateOptions.FAILED:
        return Z.of(context).failed;
      case TransactionStateOptions.UNACKNOWLEDGED:
        return Z.of(context).unacknowledged;
      case TransactionStateOptions.UNREAD:
        return Z.of(context).unread;
      case TransactionStateOptions.PAID:
        return Z.of(context).paid;
      case TransactionStateOptions.UNPAID:
        return Z.of(context).unpaid;
      case TransactionStateOptions.FAILED_MSG:
        return Z.of(context).failedMessage;
      case TransactionStateOptions.NOT_SENT:
        return Z.of(context).notSent;
      case TransactionStateOptions.RECEIVABLE:
        return Z.of(context).receivable;
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
