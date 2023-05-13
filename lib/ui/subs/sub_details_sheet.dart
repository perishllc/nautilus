import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/sub_modified_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/network/subscription_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/subs/payment_history.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';

class SubDetailsSheet extends StatefulWidget {
  const SubDetailsSheet({required this.sub}) : super();
  final Subscription sub;

  @override
  SubDetailsSheetState createState() => SubDetailsSheetState();
}

class SubDetailsSheetState extends State<SubDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Handlebars.horizontal(
                  context,
                  margin: const EdgeInsets.only(top: 10, bottom: 24),
                ),
                // A row for pay button
                if (!widget.sub.paid)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, Z.of(context).pay, Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () async {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
                        Sheets.showAppHeightNineSheet(
                          context: context,
                          animationDurationMs: 175,
                          widget: SendSheet(
                            localCurrency: StateContainer.of(context).curCurrency,
                            address: widget.sub.address,
                            quickSendAmount: widget.sub.amount_raw,
                          ),
                        );
                      }),
                    ],
                  ),
                // A row for View Details button
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).viewPaymentHistory,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                      // Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
                      // var history = await sl.get<SubscriptionService>().getPaymentHistory(context, widget.sub);
                      Sheets.showAppHeightEightSheet(
                        context: context,
                        widget: PaymentHistorySheet(address: widget.sub.address),
                        animationDurationMs: 175,
                      );
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                      context,
                      AppButtonType.PRIMARY_OUTLINE,
                      widget.sub.active ? Z.of(context).cancelSub : Z.of(context).activateSub,
                      Dimens.BUTTON_BOTTOM_DIMENS,
                      onPressed: () async {
                        if (!mounted) return;
                        if (await sl.get<SubscriptionService>().toggleSubscriptionActive(context, widget.sub)) {
                          // trigger reload:
                          EventTaxiImpl.singleton().fire(SubModifiedEvent());
                        }
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
