import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/network/model/response/funding_response_item.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:wallet_flutter/ui/widgets/funding_message_card.dart';
import 'package:wallet_flutter/ui/widgets/funding_specific_sheet.dart';
import 'package:wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class FundingMessagesSheet extends StatefulWidget {
  const FundingMessagesSheet({this.alerts, this.hasDismissButton = true}) : super();
  final List<FundingResponseItem>? alerts;
  final bool hasDismissButton;

  @override
  // ignore: library_private_types_in_public_api
  _FundingMessagesSheetState createState() => _FundingMessagesSheetState();
}

class _FundingMessagesSheetState extends State<FundingMessagesSheet> {
  ScrollController _scrollController = ScrollController();

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
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
                Column(
                  children: <Widget>[
                    Handlebars.horizontal(context),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          // Header
                          AutoSizeText(
                            CaseChange.toUpperCase(Z.of(context).fundingHeader, context),
                            style: AppStyles.textStyleHeader(context),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    DraggableScrollbar(
                      controller: _scrollController,
                      scrollbarColor: StateContainer.of(context).curTheme.primary,
                      scrollbarTopMargin: 16,
                      scrollbarBottomMargin: 32,
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsetsDirectional.only(top: 12, bottom: 12),
                        children: _buildFundingAlerts(context, widget.alerts),
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
          ],
        ));
  }

  List<Widget> _buildFundingAlerts(BuildContext context, List<FundingResponseItem>? alerts) {
    List<Widget> ret = [];

    if (alerts == null) {
      return [];
    }

    if (!Platform.isIOS) {
      for (final FundingResponseItem alert in alerts) {
        ret.add(
          Container(
            padding: const EdgeInsetsDirectional.only(
              start: 12,
              end: 12,
              bottom: 20,
            ),
            child: FundingMessageCard(
              title: alert.title,
              shortDescription: alert.shortDescription,
              goalAmountRaw: alert.goalAmountRaw,
              currentAmountRaw: alert.currentAmountRaw,
              onPressed: () {
                Sheets.showAppHeightEightSheet(
                  context: context,
                  widget: FundingSpecificSheet(
                    alert: alert,
                    hasDismissButton: false,
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    if (Platform.isIOS) {
      // add text saying we can't show more alerts on iOS:
      ret.add(
        Container(
          padding: const EdgeInsetsDirectional.only(
            start: 12,
            end: 12,
            bottom: 20,
          ),
          child: Text(
            Z.of(context).iosFundingMessage.replaceAll("%1", NonTranslatable.appName),
            style: AppStyles.textStyleParagraphPrimary(context),
          ),
        ),
      );
    }

    return ret;
  }
}
