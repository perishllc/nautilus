import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/network/model/response/auth_item.dart';
import 'package:wallet_flutter/network/model/response/pay_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/auth/auth_confirm_sheet.dart';
import 'package:wallet_flutter/ui/handoff/handoff_confirm_sheet.dart';
import 'package:wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/user_data_util.dart';

class AppPopupButton extends StatefulWidget {
  const AppPopupButton({this.enabled = true}) : super();

  @override
  AppPopupButtonState createState() => AppPopupButtonState();

  final bool enabled;
}

class AppPopupButtonState extends State<AppPopupButton> {
  double scanButtonSize = 0;
  double popupMarginBottom = 0;
  bool isScrolledUpEnough = false;
  bool firstTime = true;
  bool isSendButtonColorPrimary = true;
  Color? popupColor = Colors.transparent;

  bool? animationOpen;

  @override
  void initState() {
    super.initState();
    animationOpen = false;
  }

  Future<void> scanAndHandleResult() async {
    final dynamic scanResult = await Navigator.pushNamed(context, "/before_scan_screen");
    if (!mounted) return;
    if (scanResult == null) {
      return;
    }

    if (scanResult is String && QRScanErrs.ERROR_LIST.contains(scanResult)) {
      if (scanResult == QRScanErrs.PERMISSION_DENIED) {
        UIUtil.showSnackbar(Z.of(context).qrInvalidPermissions, context);
      } else if (scanResult == QRScanErrs.UNKNOWN_ERROR) {
        UIUtil.showSnackbar(Z.of(context).qrUnknownError, context);
      }
      return;
    } else if (scanResult is Address) {
      // Is a URI
      final Address address = scanResult;
      if (address.address == null) {
        UIUtil.showSnackbar(Z.of(context).qrInvalidAddress, context);
        return;
      }
      // See if this address belongs to a contact
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(address.address!);
      if (!mounted) return;
      // If amount is present, fill it and go to SendConfirm
      final BigInt? amountBigInt = address.amount != null ? BigInt.tryParse(address.amount!) : null;
      bool sufficientBalance = false;
      if (amountBigInt != null && StateContainer.of(context).wallet!.accountBalance > amountBigInt) {
        sufficientBalance = true;
      }
      if (amountBigInt != null && sufficientBalance) {
        // Go to confirm sheet
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendConfirmSheet(
                amountRaw: address.amount!, destination: address.address!, contactName: user?.getDisplayName()));
      } else {
        // Go to send sheet
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(
                localCurrency: StateContainer.of(context).curCurrency,
                user: user,
                address: address.address,
                quickSendAmount: address.amount));
      }
    } else {
      SendSheetHelpers.handleScanResult(context, scanResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool disableSend = (StateContainer.of(context).wallet?.watchOnly) ?? false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Hero(
          tag: "scanButton",
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            height: scanButtonSize,
            width: scanButtonSize,
            decoration: BoxDecoration(
              color: popupColor,
              borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS),
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
          onVerticalDragStart: (StateContainer.of(context).wallet !=
                  null /*&& StateContainer.of(context).wallet!.accountBalance > BigInt.zero*/)
              ? (DragStartDetails value) {
                  setState(() {
                    popupColor = StateContainer.of(context).curTheme.primary;
                  });
                }
              : (DragStartDetails value) {},
          onVerticalDragEnd: (StateContainer.of(context).wallet !=
                  null /*&& StateContainer.of(context).wallet!.accountBalance > BigInt.zero*/)
              ? (DragEndDetails value) {
                  isSendButtonColorPrimary = true;
                  firstTime = true;
                  if (isScrolledUpEnough) {
                    setState(() {
                      popupColor = Colors.white;
                    });
                    scanAndHandleResult();
                  }
                  isScrolledUpEnough = false;
                  setState(() {
                    scanButtonSize = 0;
                  });
                }
              : (DragEndDetails value) {},
          onVerticalDragUpdate: (StateContainer.of(context).wallet !=
                  null /* && StateContainer.of(context).wallet!.accountBalance > BigInt.zero*/)
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
              borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
            ),
            height: 55,
            width: (UIUtil.getDrawerAwareScreenWidth(context) - 42).abs() / 2,
            margin: EdgeInsetsDirectional.only(start: 7, top: popupMarginBottom, end: 14.0),
            child: TextButton(
              key: const Key("home_send_button"),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
                backgroundColor: StateContainer.of(context).wallet != null && !disableSend && widget.enabled
                    ? isSendButtonColorPrimary
                        ? StateContainer.of(context).curTheme.primary
                        : StateContainer.of(context).curTheme.success
                    : StateContainer.of(context).curTheme.primary60,
                foregroundColor: StateContainer.of(context).wallet != null && widget.enabled
                    ? StateContainer.of(context).curTheme.background40
                    : Colors.transparent,
              ),
              onPressed: () {
                if (StateContainer.of(context).wallet != null && !disableSend) {
                  Sheets.showAppHeightNineSheet(
                      context: context, widget: SendSheet(localCurrency: StateContainer.of(context).curCurrency));
                }
                if (disableSend) {
                  UIUtil.showSnackbar(Z.of(context).watchOnlySendDisabled, context);
                }
              },
              child: AutoSizeText(
                Z.of(context).send,
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
