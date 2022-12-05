import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/network/model/response/funding_response_item.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';

class FundingSpecificSheet extends StatefulWidget {
  const FundingSpecificSheet({required this.alert, this.hasDismissButton = true}) : super();

  final FundingResponseItem alert;
  final bool hasDismissButton;

  @override
  // ignore: library_private_types_in_public_api
  _FundingSpecificSheetState createState() => _FundingSpecificSheetState();
}

class _FundingSpecificSheetState extends State<FundingSpecificSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the address text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
                //Container for the address text and sheet handle
                Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text20,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.only(top: 15.0),
                    //   constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                    //   child: Column(
                    //     children: <Widget>[
                    //       // Header
                    //       AutoSizeText(
                    //         CaseChange.toUpperCase(Z.of(context).messageHeader, context),
                    //         style: AppStyles.textStyleHeader(context),
                    //         textAlign: TextAlign.center,
                    //         maxLines: 1,
                    //         stepGranularity: 0.1,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(28, 8, 28, 8),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.only(top: 12, bottom: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.alert.timestamp != null)
                            Container(
                              margin: const EdgeInsetsDirectional.only(top: 2, bottom: 6),
                              padding: const EdgeInsetsDirectional.only(start: 10, end: 10, top: 2, bottom: 2),
                              decoration: BoxDecoration(
                                color: StateContainer.of(context).curTheme.text05,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100),
                                ),
                                border: Border.all(
                                  color: StateContainer.of(context).curTheme.text10!,
                                ),
                              ),
                              child: Text(
                                "${DateTime.fromMillisecondsSinceEpoch(widget.alert.timestamp!).toUtc().toString().substring(0, 16)} UTC",
                                style: AppStyles.remoteMessageCardTimestamp(context),
                              ),
                            ),
                          if (widget.alert.title != null)
                            Container(
                              margin: const EdgeInsetsDirectional.only(top: 2, bottom: 2),
                              child: Text(
                                widget.alert.title!,
                                style: AppStyles.remoteMessageCardTitle(context),
                              ),
                            ),
                          if (widget.alert.longDescription != null || widget.alert.shortDescription != null)
                            Container(
                              margin: const EdgeInsetsDirectional.only(top: 16, bottom: 2),
                              child: Text(
                                widget.alert.longDescription != null ? widget.alert.longDescription! : widget.alert.shortDescription!,
                                style: AppStyles.remoteMessageCardShortDescription(context).copyWith(fontSize: AppFontSizes.medium),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ListGradient(
                      height: 12,
                      top: true,
                      color: StateContainer.of(context).curTheme.backgroundDark!,
                    ),
                    ListGradient(
                      height: 36,
                      top: false,
                      color: StateContainer.of(context).curTheme.backgroundDark!,
                    ),
                  ],
                ),
              ),
            ),
            //A column with Copy Address and Share Address buttons
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).donateButton, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      // Go to send with address
                      Future.delayed(const Duration(milliseconds: 1000), () async {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                        Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: SendSheet(
                              localCurrency: StateContainer.of(context).curCurrency,
                              address: widget.alert.address,
                            ));
                      });
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Navigator.pop(context);
                    }),
                  ],
                )
              ],
            ),
          ],
        ));
  }
}
