import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:share_plus/share_plus.dart';

class GenerateCompleteSheet extends StatefulWidget {
  final String? amountRaw;
  final String? destination;
  final String? contactName;
  final String? localAmount;
  final String? sharableLink;
  final String? walletSeed;

  GenerateCompleteSheet({this.amountRaw, this.destination, this.contactName, this.localAmount, this.sharableLink, this.walletSeed}) : super();

  _GenerateCompleteSheetState createState() => _GenerateCompleteSheetState();
}

class _GenerateCompleteSheetState extends State<GenerateCompleteSheet> {
  // Current state references
  bool _linkCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _linkCopiedTimer;
  // Current state references
  bool _seedCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _seedCopiedTimer;

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
                    alignment: AlignmentDirectional.center,
                    margin: const EdgeInsets.only(bottom: 25),
                    child: Icon(AppIcons.success, size: 100, color: StateContainer.of(context).curTheme.success),
                  ),
                  // Container for the Amount Text
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
                          CaseChange.toUpperCase(AppLocalization.of(context)!.loadedInto, context),
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
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: UIUtil.threeLineAddressText(context, widget.destination!, type: ThreeLineAddressTextType.SUCCESS, contactName: widget.contactName)),
                ],
              ),
            ),

            // CLOSE Button
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // Share Address Button
                          _linkCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                          _linkCopied ? AppLocalization.of(context)!.linkCopied : AppLocalization.of(context)!.copyLink,
                          Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                        // Navigator.of(context).pop();
                        Clipboard.setData(new ClipboardData(text: widget.sharableLink));
                        setState(() {
                          // Set copied style
                          _linkCopied = true;
                        });
                        if (_linkCopiedTimer != null) {
                          _linkCopiedTimer!.cancel();
                        }
                        _linkCopiedTimer = new Timer(const Duration(milliseconds: 800), () {
                          setState(() {
                            _linkCopied = false;
                          });
                        });
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // copy seed button
                          _seedCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                          _seedCopied ? AppLocalization.of(context)!.seedCopied : AppLocalization.of(context)!.copySeed,
                          Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                        Clipboard.setData(new ClipboardData(text: widget.walletSeed));
                        setState(() {
                          // Set copied style
                          _seedCopied = true;
                        });
                        if (_seedCopiedTimer != null) {
                          _seedCopiedTimer!.cancel();
                        }
                        _seedCopiedTimer = new Timer(const Duration(milliseconds: 800), () {
                          setState(() {
                            _seedCopied = false;
                          });
                        });
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // share link button
                          AppButtonType.PRIMARY,
                          AppLocalization.of(context)!.shareLink,
                          Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                        Share.share(widget.sharableLink!);
                      }),
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
