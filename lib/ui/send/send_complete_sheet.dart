import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/themes.dart';

class SendCompleteSheet extends StatefulWidget {
  final String amountRaw;
  final String destination;
  final String contactName;
  final String localAmount;
  final String memo;

  SendCompleteSheet({this.amountRaw, this.destination, this.contactName, this.localAmount, this.memo}) : super();

  _SendCompleteSheetState createState() => _SendCompleteSheetState();
}

class _SendCompleteSheetState extends State<SendCompleteSheet> {
  String amount;
  String destinationAltered;

  @override
  void initState() {
    super.initState();
    // Indicate that this is a special amount if some digits are not displayed
    // todo: fix this:
    // if ((StateContainer.of(context).nyanoMode)) {
    //   // if (NumberUtil.getRawAsNyanoString(widget.amountRaw).replaceAll(",", "") == NumberUtil.getRawAsNyanoString(widget.amountRaw).toString()) {
    //   //   print(NumberUtil.getRawAsUsableString(widget.amountRaw));
    //   //   amount = NumberUtil.getRawAsUsableString(widget.amountRaw);
    //   // } else {
    //   //   amount = NumberUtil.truncateDecimal(NumberUtil.getRawAsNyanoDecimal(widget.amountRaw), digits: 12).toStringAsFixed(12);
    //   // }
    //   amount = NumberUtil.truncateDecimal(NumberUtil.getRawAsNyanoDecimal(widget.amountRaw), digits: 12).toStringAsFixed(12);
    // } else {
    //   if (NumberUtil.getRawAsUsableString(widget.amountRaw).replaceAll(",", "") == NumberUtil.getRawAsUsableDecimal(widget.amountRaw).toString()) {
    //     amount = NumberUtil.getRawAsUsableString(widget.amountRaw);
    //   } else {
    //     amount = NumberUtil.truncateDecimal(NumberUtil.getRawAsUsableDecimal(widget.amountRaw), digits: 6).toStringAsFixed(6) + "~";
    //   }
    // }
    amount = NumberUtil.getRawAsUsableStringPrecise(widget.amountRaw);
    destinationAltered = widget.destination.replaceAll("xrb_", "nano_");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // Sheet handle
            Container(
              margin: EdgeInsets.only(top: 10),
              height: 5,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.text10,
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
                    alignment: AlignmentDirectional(0, 0),
                    margin: EdgeInsets.only(bottom: 25),
                    child: Icon(AppIcons.success, size: 100, color: StateContainer.of(context).curTheme.success),
                  ),
                  // Container for the Amount Text
                  (widget.amountRaw == "0" && widget.memo != null && widget.memo.isNotEmpty)
                      ? // memo text
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
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
                      : Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: StateContainer.of(context).curTheme.backgroundDarkest,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          // Amount text
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '',
                              children: [
                                displayCurrencyAmount(
                                  context,
                                  TextStyle(
                                    color: StateContainer.of(context).curTheme.success,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'NunitoSans',
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      getCurrencySymbol(context) + ((StateContainer.of(context).nyanoMode) ? NumberUtil.getNanoStringAsNyano(amount) : amount),
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.success,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'NunitoSans',
                                  ),
                                ),
                                TextSpan(
                                  text: widget.localAmount != null ? " (${widget.localAmount})" : "",
                                  style: TextStyle(
                                    color: StateContainer.of(context).curTheme.success.withOpacity(0.75),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'NunitoSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  // Container for the "SENT TO" text
                  Container(
                    margin: EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        // "SENT TO" text
                        Text(
                          CaseChange.toUpperCase(AppLocalization.of(context).sentTo, context),
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w700,
                            color: StateContainer.of(context).curTheme.success,
                            fontFamily: 'NunitoSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // The container for the address
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: UIUtil.threeLineAddressText(context, destinationAltered, type: ThreeLineAddressTextType.SUCCESS, contactName: widget.contactName)),
                ],
              ),
            ),

            // CLOSE Button
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.SUCCESS_OUTLINE, CaseChange.toUpperCase(AppLocalization.of(context).close, context),
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
