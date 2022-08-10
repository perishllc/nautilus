import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/wallet.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/funding_messages_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDialogs {
  static void showConfirmDialog(
      BuildContext context, String title, String content, String buttonText, Function onPressed,
      {String? cancelText, Function? cancelAction}) {
    cancelText ??= AppLocalization.of(context).cancel.toUpperCase();

    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return AppAlertDialog(
          title: Text(
            title,
            style: AppStyles.textStyleButtonPrimaryOutline(context),
          ),
          content: Text(content, style: AppStyles.textStyleParagraph(context)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                padding: const EdgeInsets.all(12),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  cancelText!,
                  style: AppStyles.textStyleDialogButtonText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (cancelAction != null) {
                  cancelAction();
                }
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                padding: const EdgeInsets.all(12),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  buttonText,
                  style: AppStyles.textStyleDialogButtonText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
            ),
          ],
        );
      },
    );
  }

  static void showInfoDialog(BuildContext context, String title, String content, {bool barrierDismissible = true}) {
    showDialog(
      barrierColor: StateContainer.of(context).curTheme.barrier,
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AppAlertDialog(
          title: Text(
            title,
            style: AppStyles.textStyleButtonPrimaryOutline(context),
          ),
          content: Text(content, style: AppStyles.textStyleParagraph(context)),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalization.of(context).close.toUpperCase(),
                style: AppStyles.textStyleDialogButtonText(context),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Widget infoHeader(BuildContext context, Widget title, void Function()? onPressed) {
    return Row(children: <Widget>[
      title,
      // A container for the info button
      infoButton(context, onPressed),
    ]);
  }

  static Widget infoButton(BuildContext context, void Function()? onPressed) {
    // A container for the info button
    return SizedBox(
      width: 50,
      height: 50,
      // margin: EdgeInsetsDirectional.only(),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: StateContainer.of(context).curTheme.text15,
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          padding: const EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        onPressed: onPressed,
        child: Icon(AppIcons.info, size: 24, color: StateContainer.of(context).curTheme.text),
      ),
    );
  }

  // static void showDialogInfoButton(var context, var title, var content) {
  //   showDialog(
  //     barrierColor: StateContainer.of(context).curTheme.barrier,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AppAlertDialog(
  //         title: Text(
  //           title,
  //           style: AppStyles.textStyleButtonPrimaryOutline(context),
  //         ),
  //         content: content,
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text(
  //               AppLocalization.of(context).close.toUpperCase(),
  //               style: AppStyles.textStyleDialogButtonText(context),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  static Future<void> showChangeLog(BuildContext context) async {
    String changeLogMarkdown = await DefaultAssetBundle.of(context).loadString("CHANGELOG.md");
    final ScrollController scrollController = ScrollController();

    // replace the first h2 with an h1:
    // this is so it doesn't have the top margin of the other h2's
    changeLogMarkdown = changeLogMarkdown.replaceFirst(RegExp(r'#'), "");

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) => material.Dialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              backgroundColor: StateContainer.of(context).curTheme.backgroundDarkest,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(AppLocalization.of(context).changeLog,
                        textAlign: TextAlign.center, style: AppStyles.textStyleDialogHeader(context)),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 300, maxHeight: 400),
                    child: DraggableScrollbar(
                      controller: scrollController,
                      scrollbarTopMargin: 0,
                      scrollbarBottomMargin: 0,
                      scrollbarColor: StateContainer.of(context).curTheme.primary!,
                      child: ListView(
                        controller: scrollController,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: MarkdownBody(
                              data: changeLogMarkdown,
                              shrinkWrap: true,
                              selectable: false,
                              onTapLink: (String text, String? url, String title) async {
                                final Uri uri = Uri.parse(url!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                                  textTheme: TextTheme(
                                bodyText2: TextStyle(
                                  fontSize: AppFontSizes.smallText(context),
                                  fontWeight: FontWeight.w400,
                                  color: StateContainer.of(context).curTheme.text,
                                ),
                              ))).copyWith(
                                h1: TextStyle(
                                  fontSize: AppFontSizes.large(context),
                                  color: StateContainer.of(context).curTheme.success,
                                ),
                                h2: TextStyle(
                                  fontSize: AppFontSizes.large(context),
                                  color: StateContainer.of(context).curTheme.success,
                                ),
                                h2Padding: const EdgeInsets.only(top: 24),
                                h4: TextStyle(
                                  color: StateContainer.of(context).curTheme.warning,
                                ),
                                listBullet: TextStyle(
                                  color: StateContainer.of(context).curTheme.text,
                                ),
                                horizontalRuleDecoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(width: 3, color: StateContainer.of(context).curTheme.text!),
                                  ),
                                ),
                              ),
                              extensionSet: md.ExtensionSet(
                                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                                [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          // Go to send with address
                          Future.delayed(const Duration(milliseconds: 1000), () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                            Sheets.showAppHeightNineSheet(
                                context: context,
                                widget: FundingMessagesSheet(
                                    alerts: StateContainer.of(context).fundingAlerts, hasDismissButton: false));
                          });
                        },
                        child: Text(
                          AppLocalization.of(context).supportTheDeveloper,
                          style: TextStyle(
                            fontSize: AppFontSizes.medium,
                            color: StateContainer.of(context).curTheme.primary,
                          ),
                        ),
                      ),
                      TextButton(
                        key: const Key("changelog_dismiss_button"),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalization.of(context).dismiss,
                            style: AppStyles.textStyleDialogOptions(context)),
                      ),
                    ]),
                  ),
                ],
              ),
            ));
  }
}
