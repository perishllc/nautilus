import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';

class SendXMRCompleteSheet extends StatefulWidget {
  const SendXMRCompleteSheet({required this.amountRaw, required this.destination, this.contactName, this.localAmount, this.memo = ""}) : super();
  final String amountRaw;
  final String destination;
  final String? contactName;
  final String? localAmount;
  final String memo;

  @override
  _SendXMRCompleteSheetState createState() => _SendXMRCompleteSheetState();
}

class _SendXMRCompleteSheetState extends State<SendXMRCompleteSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
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
            //A main container that holds the amount, address and "SENT TO" texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Success tick (icon)
                  Container(
                    alignment: AlignmentDirectional.center,
                    margin: const EdgeInsets.only(bottom: 25),
                    child: Icon(AppIcons.success, size: 100, color: StateContainer.of(context).curTheme.success),
                  ),
                  // Container for the Amount Text
                  if (widget.amountRaw == "0" && widget.memo.isNotEmpty)
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: StateContainer.of(context).curTheme.backgroundDarkest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          widget.memo,
                          style: AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.center,
                        ))
                  else
                    Container(
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      // Amount text
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "",
                          children: [
                            TextSpan(
                              text: getThemeAwareRawAccuracy(context, widget.amountRaw),
                              style: AppStyles.textStyleParagraphSuccess(context),
                            ),
                            displayCurrencySymbol(
                              context,
                              AppStyles.textStyleParagraphSuccess(context),
                            ),
                            TextSpan(
                              text: getRawAsThemeAwareAmount(context, widget.amountRaw),
                              style: AppStyles.textStyleParagraphSuccess(context),
                            ),
                            TextSpan(
                              text: widget.localAmount != null ? " (${widget.localAmount})" : "",
                              style: AppStyles.textStyleParagraphSuccess(context).copyWith(
                                color: StateContainer.of(context).curTheme.success!.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Container for the "SENT TO" text
                  Container(
                    margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        // "SENT TO" text
                        Text(
                          CaseChange.toUpperCase(Z.of(context).sentTo, context),
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w700,
                            color: StateContainer.of(context).curTheme.success,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                      ],
                    ),
                  ),
                  // The container for the address
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: UIUtil.threeLineAddressText(context, widget.destination, type: ThreeLineAddressTextType.SUCCESS, contactName: widget.contactName)),
                ],
              ),
            ),

            // CLOSE Button
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context, AppButtonType.SUCCESS_OUTLINE, CaseChange.toUpperCase(Z.of(context).close, context), Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
