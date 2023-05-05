import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';

class ExampleCards {
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
}
