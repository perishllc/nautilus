import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/network/model/record_types.dart';
import 'package:wallet_flutter/network/model/status_types.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/ui/gift/gift_qr_sheet.dart';
import 'package:wallet_flutter/ui/home/card_actions.dart';
import 'package:wallet_flutter/ui/subs/payment_history.dart';
import 'package:wallet_flutter/ui/users/add_blocked.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/routes.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';

class PaymentDetailsSheet extends StatefulWidget {
  const PaymentDetailsSheet({this.txDetails}) : super();
  final TXData? txDetails;

  @override
  PaymentDetailsSheetState createState() => PaymentDetailsSheetState();
}

class PaymentDetailsSheetState extends State<PaymentDetailsSheet> {
  // // Current state references
  // bool _linkCopied = false;
  // // Timer reference so we can cancel repeated events
  // Timer? _linkCopiedTimer;
  // Current state references
  bool _seedCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _seedCopiedTimer;
  // address copied
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  @override
  Widget build(BuildContext context) {
    // check if recipient of the request
    // also check if the request is fulfilled
    bool isUnfulfilledPayableRequest = false;
    bool isUnacknowledgedSendableRequest = false;
    bool resendableMemo = false;
    bool isGiftLoad = false;

    final TXData txDetails = widget.txDetails!;

    final String? walletAddress = StateContainer.of(context).wallet!.address;

    if (walletAddress == txDetails.to_address) {
      txDetails.is_acknowledged = true;
    }

    if (walletAddress == txDetails.to_address && txDetails.is_request && !txDetails.is_fulfilled) {
      isUnfulfilledPayableRequest = true;
    }
    if (walletAddress == txDetails.from_address && txDetails.is_request && !txDetails.is_acknowledged) {
      isUnacknowledgedSendableRequest = true;
    }

    String? walletSeed;
    String? sharableLink;

    if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
      isGiftLoad = true;

      // Get the wallet seed by splitting the metadata by :
      final List<String> metadataList = txDetails.metadata!.split(RecordTypes.SEPARATOR);
      walletSeed = metadataList[0];
      sharableLink = metadataList[1];
    }

    String? addressToCopy = txDetails.to_address;
    if (txDetails.to_address == StateContainer.of(context).wallet!.address) {
      addressToCopy = txDetails.from_address;
    }

    if (txDetails.is_memo) {
      if (txDetails.status == StatusTypes.CREATE_FAILED) {
        resendableMemo = true;
      }
      if (!txDetails.is_acknowledged && txDetails.memo!.isNotEmpty && !isGiftLoad) {
        resendableMemo = true;
      }
    }

    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Handlebars.horizontal(
                  context,
                  margin: const EdgeInsets.only(top: 10, bottom: 24),
                ),
                // A row for View Details button
                if (!isGiftLoad && !txDetails.is_message)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, Z.of(context).viewTX, Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () async {
                        await UIUtil.showBlockExplorerWebview(context, txDetails.block);
                      }),
                    ],
                  ),
                if (!isGiftLoad && !txDetails.is_message && addressToCopy != null)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).viewPaymentHistory, Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () async {
                        Sheets.showAppHeightEightSheet(
                          context: context,
                          widget: PaymentHistorySheet(address: addressToCopy!),
                          animationDurationMs: 175,
                        );
                      }),
                    ],
                  ),
                // A row for Copy Address Button
                if (!isGiftLoad)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // Copy Address Button
                          _addressCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY_OUTLINE,
                          _addressCopied ? Z.of(context).addressCopied : Z.of(context).copyAddress,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        Clipboard.setData(ClipboardData(text: addressToCopy));
                        if (mounted) {
                          setState(() {
                            // Set copied style
                            _addressCopied = true;
                          });
                        }
                        if (_addressCopiedTimer != null) {
                          _addressCopiedTimer!.cancel();
                        }
                        _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                          if (mounted) {
                            setState(() {
                              _addressCopied = false;
                            });
                          }
                        });
                      }),
                    ],
                  ),
                // Mark as paid / unpaid button for requests
                if (txDetails.is_request)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // Share Address Button
                          AppButtonType.PRIMARY_OUTLINE,
                          !txDetails.is_fulfilled ? Z.of(context).markAsPaid : Z.of(context).markAsUnpaid,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        // update the tx in the db:
                        if (txDetails.is_fulfilled) {
                          await sl.get<DBHelper>().changeTXFulfillmentStatus(txDetails.uuid, false);
                        } else {
                          await sl.get<DBHelper>().changeTXFulfillmentStatus(txDetails.uuid, true);
                        }
                        // setState(() {});
                        if (!mounted) return;
                        await StateContainer.of(context).updateSolids();
                        if (!mounted) return;
                        await StateContainer.of(context).updateUnified(true);
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),

                // pay this request button:
                if (isUnfulfilledPayableRequest)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).payRequest, Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                        CardActions.payTX(context, txDetails);
                      }),
                    ],
                  ),

                // block this user from sending you requests:
                if (txDetails.is_request && StateContainer.of(context).wallet!.address != txDetails.from_address)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).blockUser, Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                        Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: AddBlockedSheet(
                              address: txDetails.from_address,
                            ));
                      }),
                    ],
                  ),

                // re-send request button:
                if (isUnacknowledgedSendableRequest)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).sendRequestAgain,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        // send the request again:
                        CardActions.resendRequest(context, txDetails);
                      }),
                    ],
                  ),
                // re-send memo button
                if (resendableMemo)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // Share Address Button
                          AppButtonType.PRIMARY_OUTLINE,
                          Z.of(context).resendMemo,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        CardActions.resendMemo(context, txDetails);
                      }),
                    ],
                  ),
                // delete this request button
                if (txDetails.is_request)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).deleteRequest, Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
                        sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
                        StateContainer.of(context).updateSolids();
                        StateContainer.of(context).updateUnified(false);
                      }),
                    ],
                  ),
                if (isGiftLoad)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // show link QR
                          AppButtonType.PRIMARY,
                          Z.of(context).showLinkOptions,
                          Dimens.BUTTON_COMPACT_LEFT_DIMENS, onPressed: () async {
                        final Widget qrWidget = SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: await UIUtil.getQRImage(context, sharableLink!));
                        Sheets.showAppHeightEightSheet(
                            context: context, widget: GiftQRSheet(link: sharableLink, qrWidget: qrWidget));
                      }),
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, Z.of(context).viewTX, Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
                          onPressed: () async {
                        await UIUtil.showBlockExplorerWebview(context, txDetails.block);
                      }),
                    ],
                  ),
                if (isGiftLoad)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // copy seed button
                          _seedCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY_OUTLINE,
                          _seedCopied ? Z.of(context).seedCopiedShort : Z.of(context).copySeed,
                          Dimens.BUTTON_BOTTOM_EXCEPTION_DIMENS, onPressed: () {
                        Clipboard.setData(ClipboardData(text: walletSeed));
                        if (!mounted) return;
                        setState(() {
                          // Set copied style
                          _seedCopied = true;
                        });
                        if (_seedCopiedTimer != null) {
                          _seedCopiedTimer!.cancel();
                        }
                        _seedCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                          if (!mounted) return;
                          setState(() {
                            _seedCopied = false;
                          });
                        });
                      }),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
