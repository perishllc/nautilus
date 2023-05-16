import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import 'package:quiver/strings.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/node_changed_event.dart';
import 'package:wallet_flutter/bus/node_modified_event.dart';
import 'package:wallet_flutter/bus/sub_modified_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/node.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/list_model.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/block_types.dart';
import 'package:wallet_flutter/network/model/record_types.dart';
import 'package:wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:wallet_flutter/network/model/status_types.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/home/card_actions.dart';
import 'package:wallet_flutter/ui/home/payment_details_sheet.dart';
import 'package:wallet_flutter/ui/settings/node/add_node_sheet.dart';
import 'package:wallet_flutter/ui/settings/node/node_details_sheet.dart';
import 'package:wallet_flutter/ui/subs/add_sub_sheet.dart';
import 'package:wallet_flutter/ui/subs/sub_details_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:wallet_flutter/ui/widgets/example_cards.dart';
import 'package:wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/ui/widgets/transaction_state_tag.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class PaymentHistorySheet extends StatefulWidget {
  const PaymentHistorySheet({super.key, required this.address});

  final String address;

  @override
  PaymentHistorySheetState createState() => PaymentHistorySheetState();
}

class PaymentHistorySheetState extends State<PaymentHistorySheet> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();

  List<User> _users = <User>[];
  String? _displayName;

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _unifiedListKeyMap = <String, GlobalKey<AnimatedListState>>{};
  final Map<String, ListModel<dynamic>> _unifiedListMap = <String, ListModel<dynamic>>{};

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  void initState() {
    super.initState();
    _registerBus();

    sl.get<DBHelper>().getUsers().then((List<User> users) {
      setState(() {
        _users = users;
      });
      for (final User user in _users) {
        if (user.address == widget.address) {
          setState(() {
            _displayName = user.getDisplayName()!;
          });
        }
        break;
      }
    });
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _registerBus() {}

  void _destroyBus() {}

  Widget _buildUnifiedCard(TXData txDetails, Animation<double> animation, String displayName, BuildContext context) {
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
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.success,
          icon: Icons.send,
          label: label,
          onPressed: (BuildContext context) async {
            if (!mounted) return;
            await CardActions.payTX(context, txDetails);
            if (!mounted) return;
            await Slidable.of(context)!.close();
          }));
    }

    // reply button:
    if (txDetails.is_message && txDetails.isRecipient(walletAddress)) {
      slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.success,
          icon: Icons.send,
          label: Z.of(context).reply,
          onPressed: (BuildContext context) async {
            if (!mounted) return;
            await CardActions.payTX(context, txDetails);
            if (!mounted) return;
            await Slidable.of(context)!.close();
          }));
    }

    // retry buttons:
    if (!txDetails.is_acknowledged) {
      if (txDetails.is_request) {
        slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: Z.of(context).retry,
            onPressed: (BuildContext context) async {
              if (!mounted) return;
              await CardActions.resendRequest(context, txDetails);
              if (!mounted) return;
              await Slidable.of(context)!.close();
            }));
      } else if (txDetails.is_memo) {
        slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: Z.of(context).retry,
            onPressed: (BuildContext context) async {
              if (!mounted) return;
              await CardActions.resendMemo(context, txDetails);
              if (!mounted) return;
              await Slidable.of(context)!.close();
            }));
      } else if (txDetails.is_message) {
        // TODO: resend message
        slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: Z.of(context).retry,
            onPressed: (BuildContext context) async {
              if (!mounted) return;
              await CardActions.resendMessage(context, txDetails);
              if (!mounted) return;
              await Slidable.of(context)!.close();
            }));
      }
    }

    if (txDetails.is_request || txDetails.is_message) {
      slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.background!,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: Z.of(context).delete,
          onPressed: (BuildContext context) async {
            if (txDetails.uuid != null) {
              await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
            }
            if (!mounted) return;
            await StateContainer.of(context).updateSolids();
            if (!mounted) return;
            await StateContainer.of(context).updateUnified(false);
            if (!mounted) return;
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
                  backgroundColor: StateContainer.of(context).curTheme.backgroundDarkest,
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
                                    term: "",
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
                                            term: "",
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
                                      term: "",
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
                                  term: "",
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
                                  term: "",
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
  } // Payment Card End

  TXData convertHistItemToTXData(AccountHistoryResponseItem histItem, {TXData? txDetails}) {
    TXData converted = TXData();
    if (txDetails != null) {
      converted = txDetails;
    }
    converted.amount_raw ??= histItem.amount;

    if (histItem.subtype == BlockTypes.SEND) {
      converted.to_address ??= histItem.account;
    } else if (histItem.subtype == BlockTypes.RECEIVE) {
      converted.from_address ??= histItem.account;
    }

    converted.from_address ??= histItem.account;
    converted.to_address ??= histItem.account;

    converted.block ??= histItem.hash;
    converted.request_time ??= histItem.local_timestamp!;

    if (histItem.confirmed != null) {
      converted.is_fulfilled = histItem.confirmed!; // confirmation status
    } else {
      converted.is_fulfilled = true; // default to true as it cannot be null
    }
    converted.height ??= histItem.height!; // block height
    converted.record_type ??= histItem.type; // transaction type
    converted.sub_type ??= histItem.subtype; // transaction subtype

    if (isNotEmpty(txDetails?.memo)) {
      converted.is_memo = true;
    } else {
      converted.is_acknowledged = true;
    }
    converted.is_tx = true;
    return converted;
  }

  // Used to build list items that haven't been removed.
  Widget _buildUnifiedItem(BuildContext context, int index, Animation<double> animation) {
    // if (index < StateContainer.of(context).activeAlerts.length && StateContainer.of(context).activeAlerts.isNotEmpty) {
    //   return _buildRemoteMessageCard(StateContainer.of(context).activeAlerts[index]);
    // }
    // if (index == 0 && _noSearchResults) {
    //   return ExampleCards.noSearchResultsCard(context);
    // }

    // if (_loadingMore) {
    //   final int maxLen = _unifiedListMap[ADR]!.length + StateContainer.of(context).activeAlerts.length;
    //   if (index == maxLen - 1) {
    //     return ExampleCards.loadingCard(context);
    //   }
    // }

    final List<AccountHistoryResponseItem> historyList = StateContainer.of(context).wallet!.history;

    // get the indexth item in the list where account == widget.address:
    AccountHistoryResponseItem? indexedItem;

    int curIndex = 0;
    for (int i = 0; i < historyList.length; i++) {
      if (historyList[i].account == widget.address) {
        if (curIndex == index) {
          indexedItem = historyList[i];
          break;
        }
        curIndex++;
      }
    }

    // fail safe, should never happen:
    if (indexedItem == null) {
      return const SizedBox();
    }

    final TXData txDetails = convertHistItemToTXData(indexedItem);

    final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
    final String account = txDetails.getAccount(isRecipient);
    String displayName = "";
    if (txDetails.memo?.isNotEmpty ?? false) {
      displayName = Address(account).getShortestString() ?? "";
    } else {
      displayName = Address(account).getShortString() ?? "";
    }

    // check if there's a username:
    for (final User user in _users) {
      if (user.address == account) {
        displayName = user.getDisplayName()!;
      }
    }

    return _buildUnifiedCard(txDetails, animation, displayName, context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                  ),
                  Column(
                    children: <Widget>[
                      Handlebars.horizontal(
                        context,
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              CaseChange.toUpperCase(Z.of(context).paymentHistory, context),
                              style: AppStyles.textStyleHeader(context),
                              maxLines: 1,
                              stepGranularity: 0.1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // show the text: Between A and B: where A and B are the two accounts: widget.address and StateContainer.of(context).wallet!.address:
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5),
                        // width:
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          text: StateContainer.of(context).selectedAccount!.name,
                                          style: TextStyle(
                                            color: StateContainer.of(context).curTheme.text60,
                                            fontSize: AppFontSizes.small,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "NunitoSans",
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                          text: StateContainer.of(context).wallet?.username ??
                                              Address(StateContainer.of(context).wallet!.address).getShortFirstPart(),
                                          style: TextStyle(
                                            color: StateContainer.of(context).curTheme.text60,
                                            fontSize: AppFontSizes.small,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "NunitoSans",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.sync_alt,
                                    size: 24,
                                    color: StateContainer.of(context).curTheme.primary60,
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  alignment: Alignment.centerRight,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: _displayName ?? Address(widget.address).getShortFirstPart(),
                                      style: TextStyle(
                                        color: StateContainer.of(context).curTheme.text60,
                                        fontSize: AppFontSizes.small,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: AppDialogs.infoButton(
                      context,
                      () {},
                    ),
                  ),
                ],
              ),
              // A list containing accounts
              Expanded(
                  key: expandedKey,
                  child: Stack(
                    children: <Widget>[
                      // _getUnifiedListWidget(context),
                      DraggableScrollbar(
                        controller: _scrollController,
                        scrollbarColor: StateContainer.of(context).curTheme.primary,
                        scrollbarTopMargin: 10.0,
                        scrollbarBottomMargin: 20.0,
                        child: AnimatedList(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          // key: _unifiedListKeyMap[ADR],
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
                          initialItemCount: StateContainer.of(context)
                              .wallet!
                              .history
                              .where((AccountHistoryResponseItem element) =>
                                  element.account == StateContainer.of(context).wallet!.address)
                              .length,
                          // initialItemCount: StateContainer.of(context).wallet!.history.length,
                          // _unifiedListMap[ADR]!.length + StateContainer.of(context).activeAlerts.length,
                          itemBuilder: _buildUnifiedItem,
                        ),
                      ),
                      ListGradient(
                        height: 20,
                        top: true,
                        color: StateContainer.of(context).curTheme.backgroundDark!,
                      ),
                      ListGradient(
                        height: 20,
                        top: false,
                        color: StateContainer.of(context).curTheme.backgroundDark!,
                      ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              //A row with Add Sub button
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY_OUTLINE,
                    Z.of(context).close,
                    Dimens.BUTTON_TOP_DIMENS,
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Subscription sub, StateSetter setState, int index) {
    return Column(
      children: <Widget>[
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Slidable(
            closeOnScroll: true,
            endActionPane: _getSlideActionsForSub(context, sub, setState),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: StateContainer.of(context).curTheme.text15,
                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),

              // highlightColor: StateContainer.of(context).curTheme.text15,
              // splashColor: StateContainer.of(context).curTheme.text15,
              // padding: EdgeInsets.all(0.0),
              onPressed: () {
                Sheets.showAppHeightEightSheet(
                  context: context,
                  widget: SubDetailsSheet(sub: sub),
                  animationDurationMs: 175,
                );
              },
              child: SizedBox(
                height: 70.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Selected indicator
                    // Container(
                    //   height: 70,
                    //   width: 6,
                    //   color: sub.active ? StateContainer.of(context).curTheme.primary : Colors.transparent,
                    // ),
                    // Icon, Account Name, Address and Amount
                    Expanded(
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 20, end: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        margin: EdgeInsets.zero,
                                        child: Icon(
                                          sub.active ? Icons.paid : Icons.money_off,
                                          color: sub.active
                                              ? StateContainer.of(context).curTheme.success
                                              : StateContainer.of(context).curTheme.error,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Account name and address
                                Container(
                                  width: (MediaQuery.of(context).size.width - 116) * 0.9,
                                  // width: (MediaQuery.of(context).size.width - 200),
                                  margin: const EdgeInsetsDirectional.only(start: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Account name
                                      AutoSizeText(
                                        sub.label,
                                        style: TextStyle(
                                          fontFamily: "NunitoSans",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                          color: StateContainer.of(context).curTheme.text,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 1,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                      ),
                                      // http_url + ws_url
                                      AutoSizeText(
                                        Address(sub.address).getShortString()!,
                                        style: TextStyle(
                                          fontFamily: "OverpassMono",
                                          fontWeight: FontWeight.w100,
                                          fontSize: 14.0,
                                          color: StateContainer.of(context).curTheme.text60,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 0.1,
                                        maxLines: 1,
                                      ),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          text: "",
                                          children: [
                                            TextSpan(
                                              text: getThemeAwareRawAccuracy(context, sub.amount_raw),
                                              style: AppStyles.textStyleParagraphPrimary(context),
                                            ),
                                            displayCurrencySymbol(
                                              context,
                                              AppStyles.textStyleParagraphPrimary(context),
                                            ),
                                            TextSpan(
                                              text: getRawAsThemeAwareFormattedAmount(context, sub.amount_raw),
                                              style: AppStyles.textStyleParagraphPrimary(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Handlebars.vertical(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        // if (index == widget.history.length - 1)
        //   Divider(
        //     height: 2,
        //     color: StateContainer.of(context).curTheme.text15,
        //   ),
      ],
    );
  }

  ActionPane _getSlideActionsForSub(BuildContext context, Subscription sub, StateSetter setState) {
    final List<Widget> actions = <Widget>[];

    actions.add(SlidableAction(
        autoClose: false,
        borderRadius: BorderRadius.circular(5.0),
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
        foregroundColor: StateContainer.of(context).curTheme.primary,
        icon: Icons.edit,
        label: Z.of(context).edit,
        onPressed: (BuildContext context) async {
          await Future<dynamic>.delayed(const Duration(milliseconds: 250));
          if (!mounted) return;
          // Sheets.showAppHeightEightSheet(
          //   context: context,
          //   widget: SubDetailsSheet(sub: sub),
          //   animationDurationMs: 175,
          // );
          await Slidable.of(context)!.close();
        }));

    actions.add(
      SlidableAction(
        autoClose: false,
        borderRadius: BorderRadius.circular(5.0),
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
        foregroundColor: StateContainer.of(context).curTheme.error60,
        icon: Icons.delete,
        label: Z.of(context).delete,
        onPressed: (BuildContext context) {},
      ),
    );

    return ActionPane(
      motion: const ScrollMotion(),
      extentRatio: 0.5,
      children: actions,
    );
  }
}
