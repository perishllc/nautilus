import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/gift/gift_qr_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:share_plus/share_plus.dart';

class GenerateCompleteSheet extends StatefulWidget {
  const GenerateCompleteSheet(
      {this.amountRaw,
      this.destination,
      this.contactName,
      this.localAmount,
      this.link = "",
      this.walletSeed = "",
      this.memo = ""})
      : super();

  final String? amountRaw;
  final String? destination;
  final String? contactName;
  final String? localAmount;
  final String link;
  final String walletSeed;
  final String memo;

  @override
  GenerateCompleteSheetState createState() => GenerateCompleteSheetState();
}

class GenerateCompleteSheetState extends State<GenerateCompleteSheet> {
  // Current state references
  bool _linkCopied = false;
  bool _messageCopied = false;
  bool _seedCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _messageCopiedTimer;
  Timer? _linkCopiedTimer;
  Timer? _seedCopiedTimer;

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  //************ Enter Memo Container Method ************//
  //*******************************************************//
  Widget getMessageEditor() {
    return AppTextField(
      focusNode: _messageFocusNode,
      bottomMargin: 20,
      controller: _messageController,
      cursorColor: StateContainer.of(context).curTheme.primary,
      inputFormatters: [
        LengthLimitingTextInputFormatter(255),
      ],
      textInputAction: TextInputAction.done,
      maxLines: null,
      autocorrect: false,
      // hintText: _memoHint ?? Z.of(context).enterMemo,
      fadeSuffixOnCondition: true,
      style: TextStyle(
        color: StateContainer.of(context).curTheme.text60,
        fontSize: AppFontSizes.small,
        height: 1.2,
        fontWeight: FontWeight.w100,
        fontFamily: 'OverpassMono',
      ),
      onChanged: (String text) {
        setState(() {}); // forces address container to respect the memo's status (empty or not empty)
        // nothing for now
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.link.isNotEmpty && _messageController.text.isEmpty) {
      _messageController.text =
          "${Z.of(context).defaultGiftMessage.replaceAll("%1", NonTranslatable.appName).replaceAll("%2", NonTranslatable.currencyName)} ${widget.link}";
    }
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            Handlebars.horizontal(context),
            // Success tick (icon)
            GestureDetector(
              onTap: () {
                // Clear focus of our fields when tapped in this empty space
                _messageFocusNode.unfocus();
              },
              child: Container(
                alignment: AlignmentDirectional.center,
                margin: const EdgeInsets.only(top: 20),
                child: Icon(AppIcons.success, size: 100, color: StateContainer.of(context).curTheme.success),
              ),
            ),
            //A main container that holds the amount, address and "SENT TO" texts
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Clear focus of our fields when tapped in this empty space
                  _messageFocusNode.unfocus();
                },
                child: KeyboardAvoider(
                  duration: Duration.zero,
                  autoScroll: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Container for the "LOADED" text
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            // "SENT TO" text
                            Text(
                              CaseChange.toUpperCase(Z.of(context).loaded, context),
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
                      // Container for the Amount Text
                      Container(
                        margin: EdgeInsets.only(
                            top: 10.0,
                            bottom: 10,
                            left: MediaQuery.of(context).size.width * 0.105,
                            right: MediaQuery.of(context).size.width * 0.105),
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
                      getMessageEditor(),
                      Container(
                        alignment: AlignmentDirectional.center,
                        child: Text(Z.of(context).tapMessageToEdit,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: StateContainer.of(context).curTheme.primary,
                              fontFamily: "NunitoSans",
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // CLOSE Button
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // copy message Button
                        _messageCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                        _messageCopied ? Z.of(context).messageCopied : Z.of(context).copyMessage,
                        Dimens.BUTTON_COMPACT_LEFT_DIMENS, onPressed: () {
                      Clipboard.setData(ClipboardData(text: _messageController.text));
                      setState(() {
                        // Set copied style
                        _messageCopied = true;
                      });
                      if (_messageCopiedTimer != null) {
                        _messageCopiedTimer!.cancel();
                      }
                      _messageCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                        setState(() {
                          _messageCopied = false;
                        });
                      });
                    }),
                    AppButton.buildAppButton(
                        context,
                        // share message button
                        AppButtonType.PRIMARY_OUTLINE,
                        Z.of(context).shareMessage,
                        Dimens.BUTTON_COMPACT_RIGHT_DIMENS, onPressed: () {
                      Share.share(_messageController.text);
                    }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // show link QR
                        AppButtonType.PRIMARY,
                        Z.of(context).showLinkOptions,
                        Dimens.BUTTON_BOTTOM_EXCEPTION_DIMENS, onPressed: () async {
                      final Widget qrWidget = SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: await UIUtil.getQRImage(context, widget.link));
                      Sheets.showAppHeightEightSheet(
                          context: context, widget: GiftQRSheet(link: widget.link, qrWidget: qrWidget));
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
