import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:percent_indicator/percent_indicator.dart';

class FundingMessageCard extends StatefulWidget {

  const FundingMessageCard({
    this.alert,
    this.onPressed,
    this.title,
    this.goalAmountRaw,
    this.currentAmountRaw,
    this.shortDescription,
    this.showDesc = true,
    this.showTimestamp = true,
    this.hasBg = true,
    this.hideAmounts = false,
    this.hideProgressBar = false,
  });
  
  final AlertResponseItem? alert;
  final Function? onPressed;
  final bool showDesc;
  final bool showTimestamp;
  final bool hasBg;
  final String? goalAmountRaw;
  final String? currentAmountRaw;
  final String? shortDescription;
  final String? title;
  final bool hideAmounts;
  final bool hideProgressBar;

  @override
  _FundingMessageCardState createState() => _FundingMessageCardState();
}

class _FundingMessageCardState extends State<FundingMessageCard> {
  Widget getAmountWidget(String amountRaw) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "",
        children: [
          displayCurrencySymbol(
            context,
            AppStyles.textStyleParagraphPrimary(context),
          ),
          TextSpan(
            text: getRawAsThemeAwareFormattedAmount(context, amountRaw),
            style: AppStyles.textStyleParagraphPrimary(context),
          ),
          TextSpan(
            text: getThemeAwareRawAccuracy(context, amountRaw),
            style: AppStyles.textStyleParagraphPrimary(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Decimal goalAmount = Decimal.parse(widget.goalAmountRaw ?? '0');
    Decimal currentAmount = Decimal.parse(widget.currentAmountRaw ?? '0');
    double percentFunded = 0;
    if (goalAmount != Decimal.zero) {
      percentFunded = (currentAmount / goalAmount).toDouble();
    }

    // so that the progress bar still shows something if the current amount is 0
    // so that the progress bar doesn't go past 100%
    double minFundedPercent = min(max(percentFunded, 0.1), 1.0);

    return Container(
      decoration: BoxDecoration(
        color: widget.hasBg ? StateContainer.of(context).curTheme.success!.withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 2,
          color: StateContainer.of(context).curTheme.success!,
        ),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.success!.withOpacity(0.15), padding: EdgeInsets.zero,
          // highlightColor: StateContainer.of(context).curTheme.success!.withOpacity(0.15),
          // splashColor: StateContainer.of(context).curTheme.success!.withOpacity(0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: widget.onPressed as void Function()?,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Container(
                  margin: EdgeInsetsDirectional.only(
                    bottom: widget.shortDescription != null && (widget.showDesc || widget.alert!.title == null) ? 4 : 0,
                  ),
                  child: Text(
                    widget.title!,
                    style: AppStyles.remoteMessageCardTitle(context),
                  ),
                ),
              if (widget.shortDescription != null && (widget.showDesc || widget.alert!.title == null))
                Container(
                  margin: const EdgeInsetsDirectional.only(
                    bottom: 4,
                  ),
                  child: Text(
                    widget.shortDescription!,
                    style: AppStyles.remoteMessageCardShortDescription(context),
                  ),
                ),
              if (!widget.hideAmounts && widget.currentAmountRaw != null && widget.goalAmountRaw != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    getAmountWidget(widget.currentAmountRaw!),
                    getAmountWidget(widget.goalAmountRaw!),
                  ],
                ),
              if (!widget.hideProgressBar)
                LinearPercentIndicator(
                  // width: 200.0,
                  lineHeight: 24.0,
                  curve: Curves.easeOut,
                  percent: minFundedPercent,
                  center: Text(
                    "${(percentFunded * 100).toStringAsFixed(2)}%",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFontSizes.small,
                      color: StateContainer.of(context).curTheme.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  backgroundColor: StateContainer.of(context).curTheme.text15,
                  // progressColor: StateContainer.of(context).curTheme.success,
                  linearGradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.2, 0.5, 0.9].map((double e) => e * (1 / minFundedPercent)).toList(),
                    colors: [
                      StateContainer.of(context).curTheme.error!,
                      StateContainer.of(context).curTheme.warning!,
                      StateContainer.of(context).curTheme.success!,
                    ],
                  ),
                  // trailing: getAmountWidget(widget.goalAmountRaw ?? "0"),
                  barRadius: const Radius.circular(100),
                  padding: EdgeInsets.zero,
                  animateFromLastPercent: true,
                  animation: true,
                  animationDuration: 2500,
                ),
              // if (widget.alert!.timestamp != null && widget.showTimestamp)
              //   Container(
              //     margin: const EdgeInsetsDirectional.only(
              //       top: 6,
              //       bottom: 2,
              //     ),
              //     padding: const EdgeInsetsDirectional.only(start: 10, end: 10, top: 2, bottom: 2),
              //     decoration: BoxDecoration(
              //       color: StateContainer.of(context).curTheme.text05,
              //       borderRadius: const BorderRadius.all(
              //         Radius.circular(100),
              //       ),
              //       border: Border.all(
              //         color: StateContainer.of(context).curTheme.text10!,
              //       ),
              //     ),
              //     child: Text(
              //       "${DateTime.fromMillisecondsSinceEpoch(widget.alert!.timestamp!).toUtc().toString().substring(0, 16)} UTC",
              //       style: AppStyles.remoteMessageCardTimestamp(context),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
