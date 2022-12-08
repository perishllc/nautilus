import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/network/metadata_service.dart';
import 'package:nautilus_wallet_flutter/network/model/block_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/funding_messages_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDialogs {
  static void showConfirmDialog(BuildContext context, String title, String content, String buttonText, Function onPressed,
      {String? cancelText, Function? cancelAction, bool barrierDismissible = true}) {
    cancelText ??= Z.of(context).cancel.toUpperCase();

    showAppDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AppAlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title,
            style: AppStyles.textStyleButtonPrimaryOutline(context),
          ),
          content: Text(content, style: AppStyles.textStyleParagraph(context)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(12),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  cancelText!,
                  textAlign: TextAlign.center,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(12),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
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

  static Future<bool> waitableConfirmDialog(BuildContext context, String title, String content, String buttonText,
      {String? cancelText, bool barrierDismissible = true}) async {
    cancelText ??= Z.of(context).cancel.toUpperCase();

    final bool res = await showAppDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AppAlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title,
            style: AppStyles.textStyleButtonPrimaryOutline(context),
          ),
          content: Text(content, style: AppStyles.textStyleParagraph(context)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(12),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  cancelText!,
                  textAlign: TextAlign.center,
                  style: AppStyles.textStyleDialogButtonText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(12),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: AppStyles.textStyleDialogButtonText(context),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) as bool;
    return res;
  }

  static Future<bool> proCheck(BuildContext context, {bool shouldShowDialog = true}) async {
    // // first check if pro is enabled
    // final bool isSubbed = await StateContainer.of(context).isSubscribed(context);
    // if (isSubbed) return true;

    // // search through the wallet history to see if we paid to the pro address:
    // bool hasPaid = false;
    // bool lifetime = false;
    // int paidTimestamp = 0;
    // final List<AccountHistoryResponseItem>? history = StateContainer.of(context).wallet?.history;
    // if (history != null && history.isNotEmpty) {
    //   for (final AccountHistoryResponseItem histItem in history) {
    //     if (histItem.subtype == BlockTypes.SEND && histItem.account == MetadataService.PRO_PAYMENT_ADDRESS) {
    //       if (BigInt.parse(histItem.amount!) >= BigInt.parse(MetadataService.PRO_PAYMENT_MONTHLY_COST)) {
    //         if (BigInt.parse(histItem.amount!) >= BigInt.parse(MetadataService.PRO_PAYMENT_LIFETIME_COST)) {
    //           lifetime = true;
    //         }
    //         hasPaid = true;
    //         paidTimestamp = histItem.local_timestamp ?? 0;
    //         break;
    //       }
    //     }
    //   }
    // }
    // const int monthInSecs = 2628000;
    // final int nowInSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // if (lifetime) {
    //   final int farFuture = nowInSecs + (100 * 365 * 24 * 60 * 60);
    //   sl.get<SharedPrefsUtil>().setProStatus(absoluteExpireTime: farFuture);
    //   return true;
    // }

    // if (hasPaid) {
    //   bool paymentWasRecent = false;
    //   if (paidTimestamp > 0) {
    //     final int monthFromPayment = paidTimestamp + monthInSecs;
    //     // make sure the payment was made within the last month
    //     if (nowInSecs - paidTimestamp < monthInSecs) {
    //       sl.get<SharedPrefsUtil>().setProStatus(absoluteExpireTime: monthFromPayment);
    //       paymentWasRecent = true;
    //     }
    //   } else {
    //     // If we don't have a timestamp, we can't be sure if the payment was recent,
    //     // so just set it to be a month from now:
    //     sl.get<SharedPrefsUtil>().setProStatus(relativeExpireTime: monthInSecs);
    //     paymentWasRecent = true;
    //   }
    //   if (paymentWasRecent) {
    //     return true;
    //   }
    // }

    if (!shouldShowDialog) return false;

    bool recurring = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (BuildContext context) {
        
        return StatefulBuilder(

          builder: (BuildContext context, setState) {

            return AppAlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                Z.of(context).proSubRequiredHeader,
                style: AppStyles.textStyleButtonPrimaryOutline(context),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                Text(
                  Z.of(context).proSubRequiredParagraph,
                  style: AppStyles.textStyleParagraph(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      value: recurring,
                      activeColor: StateContainer.of(context).curTheme.primary,
                      onChanged: (bool? value) {
                        setState(() {
                          recurring = !recurring;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          recurring = !recurring;
                        });
                      },
                      child: Text(
                        Z.of(context).autoRenewSub,
                        style: AppStyles.textStyleParagraph(context),
                      ),
                    ),
                  ],
                ),
              ]),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    // padding: const EdgeInsets.all(12),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      Z.of(context).noThanks,
                      textAlign: TextAlign.center,
                      style: AppStyles.textStyleDialogButtonText(context),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
                if (Platform.isIOS)
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: Text(
                        Z.of(context).subscribeWithApple,
                        textAlign: TextAlign.center,
                        style: AppStyles.textStyleDialogButtonText(context),
                      ),
                    ),
                    onPressed: () async {
                      final InAppPurchase _iap = InAppPurchase.instance;
                      if (!(await _iap.isAvailable())) return;
                      const Set<String> ids = <String>{"pro_sub_1_month_pass"};
                      final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
                      if (response.notFoundIDs.isNotEmpty) {
                        // Handle the error.
                      }
                      List<ProductDetails> products = response.productDetails;

                      sl.get<Logger>().d("products: $products");

                      // Navigator.of(context).pop();
                    },
                  ),
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    // padding: const EdgeInsets.all(12),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      Z.of(context).subscribeButton,
                      textAlign: TextAlign.center,
                      style: AppStyles.textStyleDialogButtonText(context),
                    ),
                  ),
                  onPressed: () async {
                    // Go to send with address
                    await Future<void>.delayed(const Duration(milliseconds: 1000), () {
                      Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                      Sheets.showAppHeightNineSheet(
                        context: context,
                        widget: SendSheet(
                          localCurrency: StateContainer.of(context).curCurrency,
                          address: MetadataService.PRO_PAYMENT_ADDRESS,
                          quickSendAmount: MetadataService.PRO_PAYMENT_MONTHLY_COST,
                        ),
                      );
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );


    if (recurring) {
      await sl.get<SharedPrefsUtil>().setProRenewActive(true);
    }

    return false;
  }

  static Future<void> showInfoDialog(
    BuildContext context,
    String title,
    String content, {
    bool barrierDismissible = true,
    String? closeText,
    Function? onPressed,
    bool scrollable = false,
  }) async {
    closeText ??= Z.of(context).close.toUpperCase();
    final ScrollController _scrollController = ScrollController();
    await showDialog(
      barrierColor: StateContainer.of(context).curTheme.barrier,
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AppAlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title,
            style: AppStyles.textStyleButtonPrimaryOutline(context),
          ),
          // content: Text(content, style: AppStyles.textStyleParagraph(context)),
          content: scrollable
              ? DraggableScrollbar(
                  controller: _scrollController,
                  scrollbarColor: StateContainer.of(context).curTheme.primary,
                  scrollbarTopMargin: 2.0,
                  scrollbarBottomMargin: 2.0,
                  scrollbarHeight: 30,
                  scrollbarHideAfterDuration: Duration.zero,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Text(
                      content,
                      style: AppStyles.textStyleParagraph(context),
                    ),
                  ),
                )
              : Text(
                  content,
                  style: AppStyles.textStyleParagraph(context),
                ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.all(12),
              ),
              child: Text(
                closeText!,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleDialogButtonText(context).copyWith(fontSize: AppFontSizes.smallest),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  await onPressed();
                }
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

  static Widget infoButton(BuildContext context, void Function()? onPressed, {IconData icon = AppIcons.info, Key? key}) {
    // A container for the info button
    return SizedBox(
      width: 50,
      height: 50,
      // margin: EdgeInsetsDirectional.only(),
      child: TextButton(
        key: key,
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.text15,
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          padding: const EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 24, color: StateContainer.of(context).curTheme.text),
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
  //               Z.of(context).close.toUpperCase(),
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
    String changeLogMarkdown = await DefaultAssetBundle.of(context).loadString("assets/CHANGELOG.md");
    final ScrollController scrollController = ScrollController();

    // replace the first h2 with an h1:
    // this is so it doesn't have the top margin of the other h2's
    changeLogMarkdown = changeLogMarkdown.replaceFirst(RegExp(r'#'), "");

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) => material.Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(Z.of(context).changeLog, textAlign: TextAlign.center, style: AppStyles.textStyleDialogHeader(context)),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 300, maxHeight: 400),
                    child: DraggableScrollbar(
                      controller: scrollController,
                      scrollbarTopMargin: 0,
                      scrollbarBottomMargin: 0,
                      scrollbarColor: StateContainer.of(context).curTheme.primary,
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
                          Future<void>.delayed(const Duration(milliseconds: 1000), () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                            Sheets.showAppHeightNineSheet(
                                context: context,
                                widget: FundingMessagesSheet(
                                  alerts: StateContainer.of(context).fundingAlerts,
                                  hasDismissButton: false,
                                ));
                          });
                        },
                        child: Text(
                          Z.of(context).supportTheDeveloper,
                          style: TextStyle(
                            fontSize: AppFontSizes.medium,
                            color: StateContainer.of(context).curTheme.primary,
                          ),
                        ),
                      ),
                      TextButton(
                        key: const Key("changelog_dismiss_button"),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(Z.of(context).dismiss, style: AppStyles.textStyleDialogOptions(context)),
                      ),
                    ]),
                  ),
                ],
              ),
            ));
  }

  static Future<bool?> showTrackingDialog(BuildContext context, [bool dismissable = false]) async {
    final bool? option = await showDialog<bool>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        barrierDismissible: dismissable,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Z.of(context).trackingHeader,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                AppDialogs.infoButton(
                  context,
                  () {
                    AppDialogs.showInfoDialog(context, Z.of(context).trackingHeader, Z.of(context).trackingWarningBodyLong);
                  },
                )
              ],
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });
    return option;
  }
}
