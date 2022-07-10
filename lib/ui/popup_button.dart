import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/user_data_util.dart';

class AppPopupButton extends StatefulWidget {
  @override
  _AppPopupButtonState createState() => _AppPopupButtonState();
}

class _AppPopupButtonState extends State<AppPopupButton> {
  double scanButtonSize = 0;
  double popupMarginBottom = 0;
  bool isScrolledUpEnough = false;
  bool firstTime = true;
  bool isSendButtonColorPrimary = true;
  Color? popupColor = Colors.transparent;

  bool? animationOpen;

  void _showMantaAnimation() {
    animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.MANTA, onPoppedCallback: () => animationOpen = false);
  }

  @override
  void initState() {
    super.initState();
    animationOpen = false;
  }

  Future<void> scanAndHandlResult() async {
    final dynamic? scanResult = await Navigator.pushNamed(context, '/before_scan_screen');
    if (!mounted) {
      return;
    }
    // Parse scan data and route appropriately
    if (scanResult == null) {
      UIUtil.showSnackbar(AppLocalization.of(context)!.qrInvalidAddress, context);
    } else if (!QRScanErrs.ERROR_LIST.contains(scanResult)) {
      // Is a URI
      final Address address = Address(scanResult as String?);
      if (address.address == null) {
        UIUtil.showSnackbar(AppLocalization.of(context)!.qrInvalidAddress, context);
      } else {
        // See if this address belongs to a contact
        final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(address.address!);
        if (!mounted) {
          return;
        }
        // If amount is present, fill it and go to SendConfirm
        final BigInt? amountBigInt = address.amount != null ? BigInt.tryParse(address.amount!) : null;
        bool sufficientBalance = false;
        if (amountBigInt != null && amountBigInt < BigInt.from(10).pow(24)) {
          UIUtil.showSnackbar(
              AppLocalization.of(context)!.minimumSend.replaceAll("%1", "0.000001").replaceAll("%2", StateContainer.of(context).currencyMode), context);
        } else if (amountBigInt != null && StateContainer.of(context).wallet!.accountBalance > amountBigInt) {
          sufficientBalance = true;
        }
        if (amountBigInt != null && sufficientBalance) {
          // Go to confirm sheet
          Sheets.showAppHeightNineSheet(
              context: context, widget: SendConfirmSheet(amountRaw: address.amount!, destination: address.address!, contactName: user?.getDisplayName()));
        } else {
          // Go to send sheet
          Sheets.showAppHeightNineSheet(
              context: context,
              widget: SendSheet(localCurrency: StateContainer.of(context).curCurrency, user: user, address: address.address, quickSendAmount: address.amount));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Hero(
          tag: 'scanButton',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            height: scanButtonSize,
            width: scanButtonSize,
            decoration: BoxDecoration(
              color: popupColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              AppIcons.scan,
              size: scanButtonSize < 60 ? scanButtonSize / 1.8 : 33,
              color: StateContainer.of(context).curTheme.background,
            ),
          ),
        ),
        // Send Button
        GestureDetector(
          onVerticalDragStart: (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.accountBalance > BigInt.zero)
              ? (DragStartDetails value) {
                  setState(() {
                    popupColor = StateContainer.of(context).curTheme.primary;
                  });
                }
              : (DragStartDetails value) {},
          onVerticalDragEnd: (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.accountBalance > BigInt.zero)
              ? (DragEndDetails value) {
                  isSendButtonColorPrimary = true;
                  firstTime = true;
                  if (isScrolledUpEnough) {
                    setState(() {
                      popupColor = Colors.white;
                    });
                    scanAndHandlResult();
                  }
                  isScrolledUpEnough = false;
                  setState(() {
                    scanButtonSize = 0;
                  });
                }
              : (DragEndDetails value) {},
          onVerticalDragUpdate: (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.accountBalance > BigInt.zero)
              ? (DragUpdateDetails dragUpdateDetails) {
                  if (dragUpdateDetails.localPosition.dy < -60) {
                    isScrolledUpEnough = true;
                    if (firstTime) {
                      sl.get<HapticUtil>().success();
                    }
                    firstTime = false;
                    setState(() {
                      popupColor = StateContainer.of(context).curTheme.success;
                      isSendButtonColorPrimary = true;
                    });
                  } else {
                    isScrolledUpEnough = false;
                    popupColor = StateContainer.of(context).curTheme.primary;
                    isSendButtonColorPrimary = false;
                  }
                  // Swiping below the starting limit
                  if (dragUpdateDetails.localPosition.dy >= 0) {
                    setState(() {
                      scanButtonSize = 0;
                      popupMarginBottom = 0;
                    });
                  } else if (dragUpdateDetails.localPosition.dy > -60) {
                    setState(() {
                      scanButtonSize = dragUpdateDetails.localPosition.dy * -1;
                      popupMarginBottom = 5 + scanButtonSize / 3;
                    });
                  } else {
                    setState(() {
                      scanButtonSize = 60 + ((dragUpdateDetails.localPosition.dy * -1) - 60) / 30;
                      popupMarginBottom = 5 + scanButtonSize / 3;
                    });
                  }
                }
              : (DragUpdateDetails dragUpdateDetails) {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
            ),
            height: 55,
            width: (UIUtil.getDrawerAwareScreenWidth(context) - 42).abs() / 2,
            margin: EdgeInsetsDirectional.only(start: 7, top: popupMarginBottom, end: 14.0),
            child: TextButton(
              key: const Key("home_send_button"),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                backgroundColor: StateContainer.of(context).wallet != null /*&& StateContainer.of(context).wallet.accountBalance > BigInt.zero*/
                    ? isSendButtonColorPrimary
                        ? StateContainer.of(context).curTheme.primary
                        : StateContainer.of(context).curTheme.success
                    : StateContainer.of(context).curTheme.primary60,
                primary: StateContainer.of(context).wallet != null /*&& StateContainer.of(context).wallet.accountBalance > BigInt.zero*/
                    ? StateContainer.of(context).curTheme.background40
                    : Colors.transparent,
                // highlightColor: StateContainer.of(context).wallet != null /*&& StateContainer.of(context).wallet.accountBalance > BigInt.zero*/
                //     ? StateContainer.of(context).curTheme.background40
                //     : Colors.transparent,
                // splashColor: StateContainer.of(context).wallet != null /*&& StateContainer.of(context).wallet.accountBalance > BigInt.zero*/
                //     ? StateContainer.of(context).curTheme.background40
                //     : Colors.transparent,
              ),
              onPressed: () {
                if (StateContainer.of(context).wallet != null /*&& StateContainer.of(context).wallet.accountBalance > BigInt.zero*/) {
                  Sheets.showAppHeightNineSheet(context: context, widget: SendSheet(localCurrency: StateContainer.of(context).curCurrency));
                }
              },
              child: AutoSizeText(
                AppLocalization.of(context)!.send,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleButtonPrimary(context),
                maxLines: 1,
                stepGranularity: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
