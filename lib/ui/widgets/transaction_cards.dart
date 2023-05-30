import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:quiver/strings.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/network/model/block_types.dart';
import 'package:wallet_flutter/network/model/record_types.dart';
import 'package:wallet_flutter/network/model/status_types.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/home/card_actions.dart';
import 'package:wallet_flutter/ui/home/payment_details_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/ui/widgets/transaction_state_tag.dart';

class TXCards {
  // Welcome Card
  static TextSpan _getExampleHeaderSpan(BuildContext context, [bool xmr = false]) {
    String workingStr;
    if (StateContainer.of(context).selectedAccount == null || StateContainer.of(context).selectedAccount!.index == 0) {
      workingStr = Z.of(context).exampleCardIntro;
    } else {
      workingStr = Z.of(context).newAccountIntro;
    }
    workingStr = workingStr
        .replaceAll("%1", NonTranslatable.appName)
        .replaceAll("%2", NonTranslatable.currencyName.toUpperCase());

    if (!workingStr.contains("NANO") && !workingStr.contains("XMR")) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }

    final String word = xmr ? "XMR" : "NANO";

    // Colorize NANO/XMR
    final List<String> splitStr = workingStr.split(NonTranslatable.currencyName.toUpperCase());
    if (splitStr.length != 2) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    return TextSpan(
      text: '',
      children: [
        TextSpan(
          text: splitStr[0],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
        TextSpan(
          text: word,
          style: AppStyles.textStyleTransactionWelcomePrimary(context),
        ),
        TextSpan(
          text: splitStr[1],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
      ],
    );
  }

  static Widget welcomeTransactionCard(BuildContext context, [bool xmr = false]) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: <BoxShadow>[StateContainer.of(context).curTheme.boxShadow!],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: _getExampleHeaderSpan(context, xmr),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget welcomePaymentCardTwo(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  text: TextSpan(
                    text: Z.of(context).examplePaymentExplainer,
                    style: AppStyles.textStyleTransactionWelcome(context),
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  // Loading Transaction Card
  static Widget loadingTransactionCard(
      BuildContext context, double opacity, String type, String amount, String address) {
    String text;
    IconData icon;
    Color? iconColor;
    if (type == "Sent") {
      text = "Senttt";
      icon = AppIcons.dotfilled;
      iconColor = StateContainer.of(context).curTheme.text20;
    } else {
      text = "Receiveddd";
      icon = AppIcons.dotfilled;
      iconColor = StateContainer.of(context).curTheme.primary20;
    }
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.text15,
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: EdgeInsets.zero,
        ),
        // splashColor: StateContainer.of(context).curTheme.text15,
        // highlightColor: StateContainer.of(context).curTheme.text15,
        // splashColor: StateContainer.of(context).curTheme.text15,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Transaction Icon
                    Opacity(
                      opacity: opacity,
                      child: Container(
                          margin: const EdgeInsetsDirectional.only(end: 16.0),
                          child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    SizedBox(
                      width: UIUtil.getDrawerAwareScreenWidth(context) / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Transaction Type Text
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: <Widget>[
                              Text(
                                text,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontFamily: "NunitoSans",
                                  fontSize: AppFontSizes.small,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.transparent,
                                ),
                              ),
                              Opacity(
                                opacity: opacity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.text45,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontFamily: "NunitoSans",
                                      fontSize: AppFontSizes.small - 4,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Amount Text
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: <Widget>[
                              Text(
                                amount,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontFamily: "NunitoSans",
                                  color: Colors.transparent,
                                  fontSize: AppFontSizes.smallest,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Opacity(
                                opacity: opacity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.primary20,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    amount,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontFamily: "NunitoSans",
                                      color: Colors.transparent,
                                      fontSize: AppFontSizes.smallest - 3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Address Text
                SizedBox(
                  width: UIUtil.getDrawerAwareScreenWidth(context) / 2.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: <Widget>[
                          Text(
                            address,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: AppFontSizes.smallest,
                              fontFamily: 'OverpassMono',
                              fontWeight: FontWeight.w100,
                              color: Colors.transparent,
                            ),
                          ),
                          Opacity(
                            opacity: opacity,
                            child: Container(
                              decoration: BoxDecoration(
                                color: StateContainer.of(context).curTheme.text20,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                address,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: AppFontSizes.smallest - 3,
                                  fontFamily: 'OverpassMono',
                                  fontWeight: FontWeight.w100,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget placeholderCard(BuildContext context) {
    const String text = "Senttt";
    const IconData icon = AppIcons.dotfilled;
    final Color? iconColor = StateContainer.of(context).curTheme.text20;
    const String amount = "10244000";
    const String address = "123456789121234";
    const double opacity = 1;
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: StateContainer.of(context).curTheme.text15,
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Transaction Icon
                    Opacity(
                      opacity: opacity,
                      child: Container(
                          margin: const EdgeInsetsDirectional.only(end: 16.0),
                          child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    SizedBox(
                      width: UIUtil.getDrawerAwareScreenWidth(context) / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Transaction Type Text
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: <Widget>[
                              const Text(
                                text,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "NunitoSans",
                                  fontSize: AppFontSizes.small,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.transparent,
                                ),
                              ),
                              Opacity(
                                opacity: opacity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.text45,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    text,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: "NunitoSans",
                                      fontSize: AppFontSizes.small - 4,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Amount Text
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: <Widget>[
                              const Text(
                                amount,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "NunitoSans",
                                  color: Colors.transparent,
                                  fontSize: AppFontSizes.smallest,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Opacity(
                                opacity: opacity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.primary20,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    amount,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: "NunitoSans",
                                      color: Colors.transparent,
                                      fontSize: AppFontSizes.smallest - 3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Address Text
                SizedBox(
                  width: UIUtil.getDrawerAwareScreenWidth(context) / 2.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: <Widget>[
                          const Text(
                            address,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: AppFontSizes.smallest,
                              fontFamily: 'OverpassMono',
                              fontWeight: FontWeight.w100,
                              color: Colors.transparent,
                            ),
                          ),
                          Opacity(
                            opacity: opacity,
                            child: Container(
                              decoration: BoxDecoration(
                                color: StateContainer.of(context).curTheme.text20,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                address,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: AppFontSizes.smallest - 3,
                                  fontFamily: 'OverpassMono',
                                  fontWeight: FontWeight.w100,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // no search results:
  static Widget noSearchResultsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: Z.of(context).noSearchResults,
                    style: AppStyles.textStyleTransactionWelcome(context),
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget loadingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      height: 65,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[
        CircularProgressIndicator(),
      ]),
    );
  }

  static Widget loadingCardAdvanced(BuildContext context, AnimationController customController) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      height: 65,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        LottieBuilder.asset(
          AppAnimation.getAnimationFilePath(AnimationType.GENERIC),
          width: 60,
          height: 60,
          controller: customController,
          onLoaded: (LottieComposition composition) {
            customController.duration = composition.duration;
            customController.repeat();
          },
        ),
      ]),
    );
  }

  static Widget unifiedCard(TXData txDetails, Animation<double> animation, String displayName, BuildContext context,
      String searchControllerText) {
    late String itemText;
    IconData? icon;
    Color? iconColor;

    bool isGift = false;
    final String? walletAddress = StateContainer.of(context).wallet!.address;

    if (txDetails.is_message) {
      // just in case:
      txDetails.amount_raw = null;
    }

    if (txDetails.isRecipient(walletAddress)) {
      txDetails.is_acknowledged = true;
    }

    if (txDetails.record_type == RecordTypes.GIFT_ACK ||
        txDetails.record_type == RecordTypes.GIFT_OPEN ||
        txDetails.record_type == RecordTypes.GIFT_LOAD) {
      isGift = true;
    }

    // set icon color:
    if (txDetails.is_message || txDetails.is_request) {
      if (txDetails.is_request) {
        if (txDetails.isRecipient(walletAddress)) {
          itemText = Z.of(context).request;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = Z.of(context).asked;
          icon = AppIcons.call_received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        }
      } else if (txDetails.is_message) {
        if (txDetails.isRecipient(walletAddress)) {
          itemText = Z.of(context).received;
          icon = AppIcons.call_received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          itemText = Z.of(context).sent;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.text60;
        }
      }
    } else if (txDetails.is_tx) {
      if (isGift) {
        if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
          itemText = Z.of(context).loaded;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else if (txDetails.record_type == RecordTypes.GIFT_OPEN) {
          itemText = Z.of(context).opened;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          throw Exception("something went wrong with gift type");
        }
      } else {
        if (txDetails.sub_type == BlockTypes.SEND) {
          itemText = Z.of(context).sent;
          icon = AppIcons.sent;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = Z.of(context).received;
          icon = AppIcons.received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        }
      }
    }

    BoxShadow? setShadow;

    // set box shadow color:
    if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
      // normal tx:
      setShadow = StateContainer.of(context).curTheme.boxShadow;
    } else if (txDetails.status == StatusTypes.CREATE_FAILED) {
      if (txDetails.is_request || txDetails.is_message) {
        iconColor = StateContainer.of(context).curTheme.error60;
        setShadow = BoxShadow(
          color: StateContainer.of(context).curTheme.error60!.withOpacity(0.2),
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 1,
        );
      } else {
        iconColor = StateContainer.of(context).curTheme.warning60;
        setShadow = BoxShadow(
          color: StateContainer.of(context).curTheme.warning60!.withOpacity(0.2),
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 1,
        );
      }
    } else if (txDetails.is_fulfilled && (txDetails.is_request || txDetails.is_message)) {
      iconColor = StateContainer.of(context).curTheme.success60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.success60!.withOpacity(0.2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if (!txDetails.is_acknowledged && (txDetails.is_request || txDetails.is_message)) {
      iconColor = StateContainer.of(context).curTheme.warning60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.warning60!.withOpacity(0.2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if ((!txDetails.is_acknowledged && !txDetails.is_tx) || (txDetails.is_request && !txDetails.is_fulfilled)) {
      iconColor = StateContainer.of(context).curTheme.warning60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.warning60!.withOpacity(0.2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else {
      // normal transaction:
      setShadow = StateContainer.of(context).curTheme.boxShadow;
    }

    bool slideEnabled = false;
    // valid wallet:
    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.accountBalance > BigInt.zero) {
      // does it make sense to make it slideable?
      // if (isPaymentRequest && isRecipient && !txDetails.is_fulfilled) {
      //   slideEnabled = true;
      // }
      if (txDetails.is_request && !txDetails.is_fulfilled) {
        slideEnabled = true;
      }
      if (txDetails.is_tx && !isGift) {
        slideEnabled = true;
      }
      if (txDetails.is_message) {
        slideEnabled = true;
      }
    }

    TransactionStateOptions? transactionState;

    if (txDetails.record_type != RecordTypes.GIFT_LOAD) {
      if (txDetails.is_request) {
        if (txDetails.is_fulfilled) {
          transactionState = TransactionStateOptions.PAID;
        } else {
          transactionState = TransactionStateOptions.UNPAID;
        }
      }
      if (!txDetails.is_acknowledged) {
        transactionState = TransactionStateOptions.UNREAD;
      }

      if (txDetails.status == StatusTypes.CREATE_FAILED) {
        if (txDetails.is_request || txDetails.is_message) {
          transactionState = TransactionStateOptions.NOT_SENT;
        } else {
          transactionState = TransactionStateOptions.FAILED_MSG;
        }
      }
    }

    if (txDetails.is_tx) {
      final int currentConfHeight = StateContainer.of(context).wallet?.confirmationHeight ?? 0;
      if ((!txDetails.is_fulfilled) ||
          (currentConfHeight > -1 && txDetails.height != null && txDetails.height! > currentConfHeight)) {
        transactionState = TransactionStateOptions.UNCONFIRMED;
      }

      // watch only: receivable:
      if (txDetails.record_type == BlockTypes.RECEIVE) {
        transactionState = TransactionStateOptions.RECEIVABLE;
      }
    }

    final List<Widget> slideActions = [];
    String? label;
    if (txDetails.is_tx) {
      label = Z.of(context).send;
    } else {
      if (txDetails.is_request && txDetails.isRecipient(walletAddress)) {
        label = Z.of(context).pay;
      }
    }

    // payment request / pay button:
    if (label != null) {
      slideActions.add(SlidableAction(
          autoClose: false,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.success,
          icon: Icons.send,
          label: label,
          onPressed: (BuildContext context) async {
            await CardActions.payTX(context, txDetails);
            await Slidable.of(context)!.close();
          }));
    }

    // reply button:
    if (txDetails.is_message && txDetails.isRecipient(walletAddress)) {
      slideActions.add(SlidableAction(
          autoClose: false,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.success,
          icon: Icons.send,
          label: Z.of(context).reply,
          onPressed: (BuildContext context) async {
            await CardActions.payTX(context, txDetails);
            await Slidable.of(context)!.close();
          }));
    }

    // retry buttons:
    if (!txDetails.is_acknowledged) {
      if (txDetails.is_request) {
        slideActions.add(SlidableAction(
            autoClose: false,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: Z.of(context).retry,
            onPressed: (BuildContext context) async {
              await CardActions.resendRequest(context, txDetails);
              await Slidable.of(context)!.close();
            }));
      } else if (txDetails.is_memo) {
        slideActions.add(SlidableAction(
            autoClose: false,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: Z.of(context).retry,
            onPressed: (BuildContext context) async {
              await CardActions.resendMemo(context, txDetails);
              await Slidable.of(context)!.close();
            }));
      } else if (txDetails.is_message) {
        // TODO: resend message
        slideActions.add(SlidableAction(
            autoClose: false,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: Z.of(context).retry,
            onPressed: (BuildContext context) async {
              await CardActions.resendMessage(context, txDetails);
              await Slidable.of(context)!.close();
            }));
      }
    }

    if (txDetails.is_request || txDetails.is_message) {
      slideActions.add(SlidableAction(
          autoClose: false,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: Z.of(context).delete,
          onPressed: (BuildContext context) async {
            if (txDetails.uuid != null) {
              await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
            }
            await StateContainer.of(context).updateSolids();
            await StateContainer.of(context).updateUnified(false);
            await Slidable.of(context)!.close();
          }));
    }

    final ActionPane actionPane = ActionPane(
      motion: const ScrollMotion(),
      extentRatio: slideActions.length * 0.2,
      children: slideActions,
    );

    const double cardHeight = 65;

    return Slidable(
      enabled: slideEnabled,
      endActionPane: actionPane,
      child: SizeTransitionNoClip(
        sizeFactor: animation,
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: <Widget>[
            Container(
              margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.backgroundDark,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [setShadow!],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: StateContainer.of(context).curTheme.text15,
                  backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                onPressed: () {
                  Sheets.showAppHeightEightSheet(
                    context: context,
                    widget: PaymentDetailsSheet(txDetails: txDetails),
                    animationDurationMs: 175,
                  );
                },
                child: Center(
                  // ignore: avoid_unnecessary_containers
                  child: Container(
                    // constraints: const BoxConstraints(
                    //   minHeight: cardHeight,
                    //   maxHeight: cardHeight+10,
                    // ),
                    // padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                    // padding: const EdgeInsets.only(top: 14.0, bottom: 14.0, left: 20.0),
                    // padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                    // padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: cardHeight,
                            // maxHeight: cardHeight+20,
                          ),
                          margin: const EdgeInsetsDirectional.only(start: 20.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsetsDirectional.only(end: 16.0),
                                child: Icon(
                                  icon,
                                  color: iconColor,
                                  size: 20,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SubstringHighlight(
                                    caseSensitive: false,
                                    words: false,
                                    term: searchControllerText,
                                    text: itemText,
                                    textAlign: TextAlign.start,
                                    textStyle: AppStyles.textStyleTransactionType(context),
                                    textStyleHighlight: TextStyle(
                                        fontFamily: "NunitoSans",
                                        fontSize: AppFontSizes.small,
                                        fontWeight: FontWeight.w600,
                                        color: StateContainer.of(context).curTheme.warning60),
                                  ),
                                  if (!txDetails.is_message && !isEmpty(txDetails.amount_raw))
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          getThemeAwareRawAccuracy(context, txDetails.amount_raw),
                                          style: AppStyles.textStyleTransactionAmount(context),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.start,
                                          text: TextSpan(
                                            text: "",
                                            children: [
                                              displayCurrencySymbol(
                                                context,
                                                AppStyles.textStyleTransactionAmount(context),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SubstringHighlight(
                                            caseSensitive: false,
                                            words: false,
                                            term: searchControllerText,
                                            text: getRawAsThemeAwareFormattedAmount(context, txDetails.amount_raw),
                                            textAlign: TextAlign.start,
                                            textStyle: AppStyles.textStyleTransactionAmount(context),
                                            textStyleHighlight: TextStyle(
                                                fontFamily: "NunitoSans",
                                                color: StateContainer.of(context).curTheme.warning60,
                                                fontSize: AppFontSizes.smallest,
                                                fontWeight: FontWeight.w600)),
                                        if (isGift &&
                                            txDetails.record_type == RecordTypes.GIFT_LOAD &&
                                            txDetails.metadata!.split(RecordTypes.SEPARATOR).length > 2)
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                " : ",
                                                style: AppStyles.textStyleTransactionAmount(context),
                                              ),
                                              Text(
                                                getThemeAwareRawAccuracy(
                                                    context, txDetails.metadata!.split(RecordTypes.SEPARATOR)[2]),
                                                style: AppStyles.textStyleTransactionAmount(context),
                                              ),
                                              RichText(
                                                textAlign: TextAlign.start,
                                                text: TextSpan(
                                                  text: "",
                                                  children: <InlineSpan>[
                                                    displayCurrencySymbol(
                                                      context,
                                                      AppStyles.textStyleTransactionAmount(context),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                getRawAsThemeAwareFormattedAmount(
                                                    context, txDetails.metadata!.split(RecordTypes.SEPARATOR)[2]),
                                                style: AppStyles.textStyleTransactionAmount(context),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   constraints: const BoxConstraints(
                        //     minHeight: 10,
                        //     maxHeight: 100,
                        //   ),
                        //   child: Text(
                        //     "asdadad",
                        //     style: AppStyles.textStyleTransactionAmount(context),
                        //   ),
                        // ),
                        if (txDetails.memo != null && txDetails.memo!.isNotEmpty)
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 10,
                                maxHeight: 100,
                              ),
                              child: SingleChildScrollView(
                                child: Column(children: <Widget>[
                                  SubstringHighlight(
                                      caseSensitive: false,
                                      term: searchControllerText,
                                      text: txDetails.memo!,
                                      textAlign: TextAlign.center,
                                      textStyle: AppStyles.textStyleTransactionMemo(context),
                                      textStyleHighlight: TextStyle(
                                        fontSize: AppFontSizes.smallest,
                                        fontFamily: 'OverpassMono',
                                        fontWeight: FontWeight.w100,
                                        color: StateContainer.of(context).curTheme.warning60,
                                      ),
                                      words: false),
                                ]),
                              ),
                            ),
                          ),
                        Container(
                          // width: MediaQuery.of(context).size.width / 4.0,
                          // constraints: const BoxConstraints(maxHeight: cardHeight),
                          margin: const EdgeInsetsDirectional.only(end: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SubstringHighlight(
                                  caseSensitive: false,
                                  maxLines: 5,
                                  term: searchControllerText,
                                  text: displayName,
                                  textAlign: TextAlign.right,
                                  textStyle: AppStyles.textStyleTransactionAddress(context),
                                  textStyleHighlight: TextStyle(
                                    fontSize: AppFontSizes.smallest,
                                    fontFamily: 'OverpassMono',
                                    fontWeight: FontWeight.w100,
                                    color: StateContainer.of(context).curTheme.warning60,
                                  ),
                                  words: false),

                              if (txDetails.request_time != null)
                                SubstringHighlight(
                                  caseSensitive: false,
                                  words: false,
                                  term: searchControllerText,
                                  text: getTimeAgoString(context, txDetails.request_time!),
                                  textAlign: TextAlign.start,
                                  textStyle: TextStyle(
                                      fontFamily: "OverpassMono",
                                      fontSize: AppFontSizes.smallest,
                                      fontWeight: FontWeight.w600,
                                      color: StateContainer.of(context).curTheme.text30),
                                  textStyleHighlight: TextStyle(
                                      fontFamily: "OverpassMono",
                                      fontSize: AppFontSizes.smallest,
                                      fontWeight: FontWeight.w600,
                                      color: StateContainer.of(context).curTheme.warning30),
                                ),
                              // TRANSACTION STATE TAG
                              if (transactionState != null)
                                // ignore: avoid_unnecessary_containers
                                Container(
                                  // margin: const EdgeInsetsDirectional.only(
                                  //     // top: 10,
                                  //     ),
                                  child: TransactionStateTag(transactionState: transactionState),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (slideEnabled) Handlebars.vertical(context),
          ],
        ),
      ),
    );
  }
}
