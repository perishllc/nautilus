import 'dart:async';
import 'dart:math';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/util/exceptions.dart';
import 'package:oktoast/oktoast.dart';

enum ThreeLineAddressTextType { PRIMARY60, PRIMARY, SUCCESS, SUCCESS_FULL }

enum OneLineAddressTextType { PRIMARY60, PRIMARY, SUCCESS }

class UIUtil {
  static Widget threeLineAddressText(BuildContext context, String address,
      {ThreeLineAddressTextType type = ThreeLineAddressTextType.PRIMARY, String? contactName}) {
    final String stringPartOne = address.substring(0, 12);
    final String stringPartTwo = address.substring(12, 22);
    final String stringPartThree = address.substring(22, 44);
    final String stringPartFour = address.substring(44, 59);
    final String stringPartFive = address.substring(59);
    switch (type) {
      case ThreeLineAddressTextType.PRIMARY60:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressPrimary60(context),
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.textStyleAddressText60(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: AppStyles.textStyleAddressText60(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: AppStyles.textStyleAddressText60(context),
                  ),
                  TextSpan(text: stringPartFive, style: AppStyles.textStyleAddressPrimary60(context)),
                ],
              ),
            )
          ],
        );
      case ThreeLineAddressTextType.PRIMARY:
        Widget contactWidget;
        if (contactName != null) {
          contactWidget = RichText(textAlign: TextAlign.center, text: TextSpan(text: contactName, style: AppStyles.textStyleAddressPrimary(context)));
        } else {
          contactWidget = const SizedBox();
        }
        return Column(
          children: <Widget>[
            contactWidget,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressPrimary(context),
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressPrimary(context),
                  ),
                ],
              ),
            )
          ],
        );
      case ThreeLineAddressTextType.SUCCESS:
        Widget contactWidget;
        if (contactName != null) {
          contactWidget = RichText(textAlign: TextAlign.center, text: TextSpan(text: contactName, style: AppStyles.textStyleAddressSuccess(context)));
        } else {
          contactWidget = const SizedBox();
        }
        return Column(
          children: <Widget>[
            contactWidget,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                ],
              ),
            )
          ],
        );
      case ThreeLineAddressTextType.SUCCESS_FULL:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                ],
              ),
            )
          ],
        );
      default:
        throw UIException("Invalid threeLineAddressText Type $type");
    }
  }

  static Widget oneLineAddressText(BuildContext context, String address, {OneLineAddressTextType type = OneLineAddressTextType.PRIMARY}) {
    final String stringPartOne = address.substring(0, 12);
    final String stringPartFive = address.substring(59);
    switch (type) {
      case OneLineAddressTextType.PRIMARY60:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressPrimary60(context),
                  ),
                  TextSpan(
                    text: "...",
                    style: AppStyles.textStyleAddressText60(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressPrimary60(context),
                  ),
                ],
              ),
            ),
          ],
        );
      case OneLineAddressTextType.PRIMARY:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressPrimary(context),
                  ),
                  TextSpan(
                    text: "...",
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressPrimary(context),
                  ),
                ],
              ),
            ),
          ],
        );
      case OneLineAddressTextType.SUCCESS:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                  TextSpan(
                    text: "...",
                    style: AppStyles.textStyleAddressText90(context),
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.textStyleAddressSuccess(context),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        throw UIException("Invalid oneLineAddressText Type $type");
    }
  }

  static Widget threeLineSeedText(BuildContext context, String address, {TextStyle? textStyle}) {
    textStyle = textStyle ?? AppStyles.textStyleSeed(context);
    final String stringPartOne = address.substring(0, 22);
    final String stringPartTwo = address.substring(22, 44);
    final String stringPartThree = address.substring(44, 64);
    return Column(
      children: <Widget>[
        Text(
          stringPartOne,
          style: textStyle,
        ),
        Text(
          stringPartTwo,
          style: textStyle,
        ),
        Text(
          stringPartThree,
          style: textStyle,
        ),
      ],
    );
  }

  static Future<void> showBlockExplorerWebview(BuildContext context, String? hash) async {
    cancelLockEvent();
    final InAppBrowser browser = InAppBrowser();
    final options = InAppBrowserClassOptions(
        crossPlatform: InAppBrowserOptions(
          hideUrlBar: true,
          toolbarTopBackgroundColor: StateContainer.of(context).curTheme.primary,
        ),
        inAppWebViewGroupOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));
    final String url = AppLocalization.of(context)!.getBlockExplorerUrl(hash, StateContainer.of(context).curBlockExplorer);
    await browser.openUrlRequest(urlRequest: URLRequest(url: Uri.parse(url)), options: options);
  }

  static Future<void> showAccountWebview(BuildContext context, String? account) async {
    cancelLockEvent();
    final InAppBrowser browser = InAppBrowser();
    final options = InAppBrowserClassOptions(
        crossPlatform: InAppBrowserOptions(
          hideUrlBar: true,
          toolbarTopBackgroundColor: StateContainer.of(context).curTheme.primary,
        ),
        inAppWebViewGroupOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));
    final String url = AppLocalization.of(context)!.getAccountExplorerUrl(account, StateContainer.of(context).curBlockExplorer);
    await browser.openUrlRequest(urlRequest: URLRequest(url: Uri.parse(url)), options: options);
  }

  static Future<void> showWebview(BuildContext context, String url) async {
    cancelLockEvent();
    final InAppBrowser browser = InAppBrowser();
    final options = InAppBrowserClassOptions(
        crossPlatform: InAppBrowserOptions(
          hideUrlBar: true,
          toolbarTopBackgroundColor: StateContainer.of(context).curTheme.primary,
        ),
        inAppWebViewGroupOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));
    await browser.openUrlRequest(urlRequest: URLRequest(url: Uri.parse(url)), options: options);
  }

  static double drawerWidth(BuildContext context) {
    if (MediaQuery.of(context).size.width < 375) {
      return MediaQuery.of(context).size.width * 0.94;
    } else {
      // cap drawer width
      return min(MediaQuery.of(context).size.width * 0.85, 325);
    }
  }

  static double tabletDrawerWidth(BuildContext context) {
    if (isTablet(context)) {
      return drawerWidth(context);
    } else {
      return 0;
    }
  }

  static bool isTablet(BuildContext context) {
    return min(MediaQuery.of(context).size.width * 0.85, 300) == 300;
  }

  static void showSnackbar(String content, BuildContext context, {int durationMs = 2500}) {
    showToastWidget(
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.05, horizontal: 14),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          width: MediaQuery.of(context).size.width - 30,
          decoration: BoxDecoration(
            color: StateContainer.of(context).curTheme.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: StateContainer.of(context).curTheme.barrier!, offset: const Offset(0, 15), blurRadius: 30, spreadRadius: -5),
            ],
          ),
          child: Text(
            content,
            style: AppStyles.textStyleSnackbar(context),
            textAlign: TextAlign.start,
          ),
        ),
      ),
      dismissOtherToast: true,
      duration: Duration(milliseconds: durationMs),
    );
  }

  static StreamSubscription<dynamic>? _lockDisableSub;

  static Future<void> cancelLockEvent() async {
    // Cancel auto-lock event, usually if we are launching another intent
    if (_lockDisableSub != null) {
      _lockDisableSub!.cancel();
    }
    EventTaxiImpl.singleton().fire(DisableLockTimeoutEvent(disable: true));
    final Future<dynamic> delayed = Future.delayed(const Duration(seconds: 10));
    delayed.then((_) {
      return true;
    });
    _lockDisableSub = delayed.asStream().listen((_) {
      EventTaxiImpl.singleton().fire(DisableLockTimeoutEvent(disable: false));
    });
  }

  static bool smallScreen(BuildContext context) {
    if (MediaQuery.of(context).size.height < 667)
      return true;
    else
      return false;
  }

  static String getNatriconURL(String address, String nonce) {
    final String adjustedNonce = nonce == "" ? "" : "&nonce=$nonce";
    return "https://natricon.com/api/v1/nano?svc=natrium&outline=true&outlineColor=white&address=$address$adjustedNonce";
  }
}
