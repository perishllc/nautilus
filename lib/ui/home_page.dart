// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:keframe/keframe.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/blocked_modified_event.dart';
import 'package:nautilus_wallet_flutter/bus/deep_link_event.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/bus/payments_home_event.dart';
import 'package:nautilus_wallet_flutter/bus/tx_update_event.dart';
import 'package:nautilus_wallet_flutter/bus/unified_home_event.dart';
import 'package:nautilus_wallet_flutter/bus/xmr_event.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/localize.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/list_model.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/giftcards.dart';
import 'package:nautilus_wallet_flutter/network/metadata_service.dart';
import 'package:nautilus_wallet_flutter/network/model/block_types.dart';
import 'package:nautilus_wallet_flutter/network/model/fcm_message_event.dart';
import 'package:nautilus_wallet_flutter/network/model/record_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/auth_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/pay_item.dart';
import 'package:nautilus_wallet_flutter/network/model/status_types.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/auth/auth_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/handoff/handoff_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/home/card_actions.dart';
import 'package:nautilus_wallet_flutter/ui/home/market_card.dart';
import 'package:nautilus_wallet_flutter/ui/home/payment_details_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/home/top_card.dart';
import 'package:nautilus_wallet_flutter/ui/popup_button.dart';
import 'package:nautilus_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/receive/receive_xmr_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/settings_drawer.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/custom_monero.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/example_cards.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/hcaptcha.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/reactive_refresh.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/transaction_state_tag.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiver/strings.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:substring_highlight/substring_highlight.dart';

// ignore: must_be_immutable
class AppHomePage extends StatefulWidget {
  AppHomePage({this.priceConversion}) : super();
  PriceConversion? priceConversion;

  @override
  AppHomePageState createState() => AppHomePageState();
}

class AppHomePageState extends State<AppHomePage> with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Logger log = sl.get<Logger>();

  // Controller for placeholder card animations
  late AnimationController _placeholderCardAnimationController;
  late AnimationController _loadMoreAnimationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _emptyAnimation;
  late bool _animationDisposed;

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, List<AccountHistoryResponseItem>> _historyListMap = <String, List<AccountHistoryResponseItem>>{};

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, List<TXData>> _solidsListMap = <String, List<TXData>>{};

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _unifiedListKeyMap = <String, GlobalKey<AnimatedListState>>{};
  final Map<String, ListModel<dynamic>> _unifiedListMap = <String, ListModel<dynamic>>{};

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  List<dynamic> _moneroHistoryList = <dynamic>[];
  // final Map<String, GlobalKey<AnimatedListState>> _moneroListKeyMap = <String, GlobalKey<AnimatedListState>>{};
  // final Map<String, ListModel<dynamic>> _moneroListMap = <String, ListModel<dynamic>>{};
  GlobalKey<AnimatedListState>? _moneroListKey = GlobalKey<AnimatedListState>();
  GlobalKey<AnimatedListState>? _moneroListKeyAlert;
  late ListModel<dynamic>? _moneroList;

  // used to associate memos with blocks so we don't have search on every re-render:
  final Map<String, TXData> _txDetailsMap = {};

  // search bar text controller:
  final TextEditingController _searchController = TextEditingController();
  bool _searchOpen = false;
  bool _noSearchResults = false;
  bool _xmrNoSearchResults = false;

  // List of contacts (Store it so we only have to query the DB once for transaction cards)
  // List<User> _contacts = [];
  // List<User> _blocked = [];
  List<User> _users = <User>[];
  // List<TXData> _txData = [];
  List<TXData> _txRecords = <TXData>[];

  // "infinite scroll":
  late ScrollController _scrollController;
  int initialMaxHistItems = 100;
  int _maxHistItems = 100;
  int _trueMaxHistItems = 10000;
  bool _loadingMore = false;
  late ScrollController _xmrScrollController;
  late TabController _tabController;

  bool _isRefreshing = false;
  bool _lockDisabled = false; // whether we should avoid locking the app
  bool _lockTriggered = false;

  // FCM instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 5,
    googlePlayIdentifier: 'co.perish.nautiluswallet',
    appStoreIdentifier: '1615775960',
  );

  // confetti:
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;

  // receive disabled?:
  bool _receiveDisabled = false;
  bool _xmrSRDisabled = true;
  String _currentMode = "nano";

  int _selectedIndex = 1;

  Future<void> _switchToAccount(String account) async {
    final List<Account> accounts = await sl.get<DBHelper>().getAccounts(await StateContainer.of(context).getSeed());
    if (!mounted) return;
    for (final Account acc in accounts) {
      if (acc.address == account && acc.address != StateContainer.of(context).wallet!.address) {
        await sl.get<DBHelper>().changeAccount(acc);
        EventTaxiImpl.singleton().fire(AccountChangedEvent(account: acc, delayPop: true));
      }
    }
  }

  /// Notification includes which account its for, automatically switch to it if they're entering app from notification
  Future<void> _chooseCorrectAccountFromNotification(dynamic message) async {
    if (message.containsKey("account") as bool) {
      final String? account = message['account'] as String?;
      if (account != null) {
        await _switchToAccount(account);
      }
    }
  }

  Future<void> getNotificationPermissions() async {
    bool notificationsAllowed = false;
    try {
      final NotificationSettings _throwSettings =
          await _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
      // might help on android 13?:
      final NotificationSettings settings =
          await _firebaseMessaging.getNotificationSettings(); // TODO: remove this line
      if (settings.alert == AppleNotificationSetting.enabled ||
          settings.badge == AppleNotificationSetting.enabled ||
          settings.sound == AppleNotificationSetting.enabled ||
          settings.authorizationStatus == AuthorizationStatus.authorized) {
        final bool beenSet = await sl.get<SharedPrefsUtil>().getNotificationsSet();
        if (!beenSet) {
          notificationsAllowed = true;
          sl.get<SharedPrefsUtil>().setNotificationsOn(true);
        }
        _firebaseMessaging.getToken().then((String? token) {
          if (token != null) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
          }
        });
      } else {
        sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((_) {
          _firebaseMessaging.getToken().then((String? token) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
          });
        });
      }
      final String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
      }
    } catch (e) {
      sl.get<SharedPrefsUtil>().setNotificationsOn(false);
    }
    if (!await sl.get<SharedPrefsUtil>().getNotificationsOn() && !notificationsAllowed) {
      showNotificationWarning();
    }
  }

  Future<void> getTrackingPermissions() async {
    // check if we have tracking permissions on iOS:
    if (Platform.isIOS) {
      final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined || status == TrackingStatus.denied) {
        await showTrackingWarning();

        // update the setting if there's a mismatch:
        if (await sl.get<SharedPrefsUtil>().getTrackingEnabled()) {
          await sl.get<SharedPrefsUtil>().setTrackingEnabled(false);
        }
      }
    } else {
      // the setting is just a user preference on android:
      if (!await sl.get<SharedPrefsUtil>().getTrackingEnabled()) {
        await showTrackingWarning();
      }
    }
  }

  Future<void> _introSkippedMessage() async {
    StateContainer.of(context).introSkiped = false;
    AppDialogs.showInfoDialog(
      context,
      AppLocalization.of(context).introSkippedWarningHeader,
      AppLocalization.of(context).introSkippedWarningContent,
      barrierDismissible: false,
    );
  }

  Future<void> handleBranchGift(dynamic gift) async {
    if (gift == null || !mounted) {
      return;
    }

    Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

    final String seed = gift["seed"] as String;
    final String memo = gift["memo"] as String;
    String amountRaw = gift["amount_raw"] as String;
    final String fromAddress = gift["from_address"] as String;
    final String giftUUID = gift["uuid"] as String;
    final bool requireCaptcha = gift["require_captcha"] as bool;

    if (amountRaw.isEmpty) {
      amountRaw = "0";
    }

    final String supposedAmount = getRawAsThemeAwareAmount(context, amountRaw);

    String? userOrFromAddress;

    // change address to username if it exists:
    final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(fromAddress);
    if (!mounted) return;
    if (user != null) {
      userOrFromAddress = user.getDisplayName();
    } else {
      userOrFromAddress = fromAddress;
    }

    bool shouldShowEmptyDialog = false;

    // try {
    BigInt balance = BigInt.parse(amountRaw);

    if (giftUUID.isEmpty) {
      // check if there's actually any nano to claim:
      if (seed.isNotEmpty) {
        balance = await AppTransferOverviewSheet().getGiftCardBalance(context, seed);
      }
      if (!mounted) return;

      if (balance != BigInt.zero) {
        final String actualAmount = getRawAsThemeAwareFormattedAmount(context, balance.toString());
        // show dialog with option to refund to sender:
        switch (await showDialog<int>(
            barrierDismissible: false,
            context: context,
            barrierColor: StateContainer.of(context).curTheme.barrier,
            builder: (BuildContext context) {
              return AlertDialog(
                actionsPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: Text(
                  AppLocalization.of(context).giftAlert,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text("${AppLocalization.of(context).importGift}\n\n", style: AppStyles.textStyleParagraph(context)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context).giftFrom}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: "${userOrFromAddress!}\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                    if (memo.isNotEmpty)
                      Text(
                        "${AppLocalization.of(context).giftMessage}: $memo\n",
                        style: AppStyles.textStyleParagraph(context),
                      ),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context).giftAmount}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: <InlineSpan>[
                          TextSpan(
                            text: getThemeAwareRawAccuracy(context, balance.toString()),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: actualAmount,
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.end,
                actions: <Widget>[
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Text(
                      AppLocalization.of(context).refund,
                      style: AppStyles.textStyleDialogOptions(context),
                    ),
                  ),
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Text(
                      AppLocalization.of(context).receive,
                      style: AppStyles.textStyleDialogOptions(context),
                    ),
                  ),
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 2);
                    },
                    child: Text(
                      AppLocalization.of(context).close,
                      style: AppStyles.textStyleDialogOptions(context),
                    ),
                  )
                ],
              );
            })) {
          case 2:
            break;
          case 1:
            // transfer to this wallet:
            String? hcaptchaToken;
            if (requireCaptcha) {
              await AppDialogs.showInfoDialog(
                context,
                AppLocalization.of(context).captchaWarning,
                AppLocalization.of(context).captchaWarningBody,
                barrierDismissible: false,
                closeText: CaseChange.toUpperCase(AppLocalization.of(context).ok, context),
              );
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute<dynamic>(builder: (BuildContext context) {
                  return HCaptcha((String code) => hcaptchaToken = code);
                }),
              );
            }
            if (!mounted) return;

            // not really worth actually checking the captcha, just send the gift anyway:

            // await AppTransferConfirmSheet().createState().autoProcessWallets(privKeyBalanceMap, StateContainer.of(context).wallet);
            await AppTransferOverviewSheet().startAutoTransfer(context, seed, StateContainer.of(context).wallet!);
            break;
          case 0:
            // refund the gift:
            await AppTransferOverviewSheet().startAutoRefund(
              context,
              seed,
              fromAddress,
            );
            break;
        }
        if (!mounted) return;
        if (StateContainer.of(context).introSkiped) {
          // sleep for a few seconds so it doesn't feel too jarring:
          await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
          _introSkippedMessage();
        }
        return;
      } else {
        shouldShowEmptyDialog = true;
      }
    } else {
      // GIFT UUID is not empty, so we're dealing with gift card v2:
      // check if there's actually any nano to claim:
      final String requestingAccount = StateContainer.of(context).wallet!.address!;
      final dynamic res =
          await sl.get<GiftCards>().giftCardInfo(giftUUID: giftUUID, requestingAccount: requestingAccount);
      if (!mounted) return;
      final String actualAmount = getRawAsThemeAwareFormattedAmount(context, balance.toString());
      if (!mounted) return;
      if (res["error"] != null) {
        shouldShowEmptyDialog = true;
      } else if (res["success"] != null) {
        // show alert:
        // show dialog with option to refund to sender:
        switch (await showDialog<int>(
            barrierDismissible: false,
            context: context,
            barrierColor: StateContainer.of(context).curTheme.barrier,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                actionsPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                title: Text(
                  AppLocalization.of(context).giftAlert,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text("${AppLocalization.of(context).importGiftv2}\n\n",
                        style: AppStyles.textStyleParagraph(context)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context).giftFrom}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: "${userOrFromAddress!}\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                    if (memo.isNotEmpty)
                      Text(
                        "${AppLocalization.of(context).giftMessage}: $memo\n",
                        style: AppStyles.textStyleParagraph(context),
                      ),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context).giftAmount}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: getThemeAwareRawAccuracy(context, balance.toString()),
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                          displayCurrencySymbol(
                            context,
                            AppStyles.textStyleParagraphPrimary(context),
                          ),
                          TextSpan(
                            text: actualAmount,
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.end,
                actions: <Widget>[
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Text(
                      AppLocalization.of(context).receive,
                      style: AppStyles.textStyleDialogOptions(context),
                    ),
                  ),
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Text(
                      AppLocalization.of(context).close,
                      style: AppStyles.textStyleDialogOptions(context),
                    ),
                  )
                ],
              );
            })) {
          case 0:
            // transfer to this wallet:

            String? hcaptchaToken;

            if (requireCaptcha) {
              await AppDialogs.showInfoDialog(
                context,
                AppLocalization.of(context).captchaWarning,
                AppLocalization.of(context).captchaWarningBody,
                barrierDismissible: false,
                closeText: CaseChange.toUpperCase(AppLocalization.of(context).ok, context),
              );
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute<dynamic>(builder: (BuildContext context) {
                  return HCaptcha((String code) => hcaptchaToken = code);
                }),
              );
            }
            if (!mounted) return;

            // show loading animation for ~5 seconds:
            // push animation to prevent early exit:
            bool animationOpen = true;
            AppAnimation.animationLauncher(context, AnimationType.GENERIC,
                onPoppedCallback: () => animationOpen = false);
            // sleep to flex the animation a bit:
            await Future<dynamic>.delayed(const Duration(milliseconds: 1500));

            final dynamic res = await sl
                .get<GiftCards>()
                .giftCardClaim(giftUUID: giftUUID, requestingAccount: requestingAccount, hcaptchaToken: hcaptchaToken);
            if (!mounted) return;

            if (res["error"] != null) {
              // something went wrong, show error:
              UIUtil.showSnackbar(AppLocalization.of(context).errorProcessingGiftCard, context, durationMs: 4000);
            } else if (res["success"] != null) {
              // show success:
              UIUtil.showSnackbar(AppLocalization.of(context).giftProcessSuccess, context, durationMs: 4000);
            }

            if (animationOpen) {
              // animation is still open, so we need to close it:
              if (!mounted) return;
              Navigator.pop(context);
            }

            break;
          case 1:
            // close
            break;
        }
        if (!mounted) return;
        if (StateContainer.of(context).introSkiped) {
          // sleep for a few seconds so it doesn't feel too jarring:
          await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
          _introSkippedMessage();
        }
        return;
      }
    }

    if (!mounted) return;

    // show alert that the gift is empty:
    if (shouldShowEmptyDialog) {
      await showDialog<bool>(
          context: context,
          barrierColor: StateContainer.of(context).curTheme.barrier,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text(
                AppLocalization.of(context).giftAlertEmpty,
                style: AppStyles.textStyleDialogHeader(context),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text("${AppLocalization.of(context).importGiftEmpty}\n\n",
                      style: AppStyles.textStyleParagraph(context)),
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "${AppLocalization.of(context).giftFrom}: ",
                      style: AppStyles.textStyleParagraph(context),
                      children: [
                        TextSpan(
                          text: "${userOrFromAddress!}\n",
                          style: AppStyles.textStyleParagraphPrimary(context),
                        ),
                      ],
                    ),
                  ),
                  if (memo.isNotEmpty)
                    Text(
                      "${AppLocalization.of(context).giftMessage}: $memo\n",
                      style: AppStyles.textStyleParagraph(context),
                    ),
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "${AppLocalization.of(context).giftAmount}: ",
                      style: AppStyles.textStyleParagraph(context),
                      children: [
                        TextSpan(
                          text: getThemeAwareRawAccuracy(context, amountRaw),
                          style: AppStyles.textStyleParagraphPrimary(context),
                        ),
                        displayCurrencySymbol(
                          context,
                          AppStyles.textStyleParagraphPrimary(context),
                        ),
                        TextSpan(
                          text: supposedAmount,
                          style: AppStyles.textStyleParagraphPrimary(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                AppSimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      AppLocalization.of(context).ok,
                      style: AppStyles.textStyleDialogOptions(context),
                    ),
                  ),
                )
              ],
            );
          });
    }
    if (!mounted) return;
    if (StateContainer.of(context).introSkiped) {
      // sleep for a few seconds so it doesn't feel too jarring:
      await Future<dynamic>.delayed(const Duration(milliseconds: 4000));
      _introSkippedMessage();
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    WidgetsBinding.instance.addObserver(this);
    // _addSampleContact();
    _updateUsers();
    // _updateTXData();
    // infinite scroll:
    _scrollController = ScrollController();
    _xmrScrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      final String mode = _tabController.index == 0 ? "nano" : "monero";
      if (_currentMode != mode) {
        setState(() {
          _currentMode = mode;
        });
        EventTaxiImpl.singleton().fire(XMREvent(type: "mode_change", message: mode));
      }

      if (_currentMode == "nano") {
        if (!_receiveDisabled) {
          if (StateContainer.of(context).wallet?.address == null ||
              StateContainer.of(context).wallet!.address!.isEmpty) {
            setState(() {
              _receiveDisabled = true;
            });
          }
        } else {
          if (StateContainer.of(context).wallet?.address != null &&
              StateContainer.of(context).wallet!.address!.isNotEmpty) {
            setState(() {
              _receiveDisabled = false;
            });
          }
        }
      } else if (_currentMode == "monero") {
        if (!_xmrSRDisabled && StateContainer.of(context).xmrAddress.isEmpty ||
            _xmrSRDisabled && StateContainer.of(context).xmrAddress.isNotEmpty) {
          setState(() {
            _xmrSRDisabled = !_xmrSRDisabled;
          });
        }
      }
    });
    // Setup placeholder animation and start
    _animationDisposed = false;
    _placeholderCardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _placeholderCardAnimationController.addListener(_animationControllerListener);
    _loadMoreAnimationController = AnimationController(vsync: this);
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    // setup blank animation controller:
    _emptyAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    _opacityAnimation.addStatusListener(_animationStatusListener);
    _placeholderCardAnimationController.forward();

    _moneroListKey = GlobalKey<AnimatedListState>();
    _moneroList = ListModel<dynamic>(listKey: _moneroListKey!);
    // Register handling of push notifications
    // *only triggers when tapped!*:
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      try {
        await _chooseCorrectAccountFromNotification(message.data);
        // await _processPaymentRequestNotification(message.data);
      } catch (error) {
        log.e("Error processing push notification: $error");
      }
    });

    // ask to rate the app:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (!mounted) return;
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: AppLocalization.of(context).rateTheApp,
          message: AppLocalization.of(context).rateTheAppDescription,
          rateButton: AppLocalization.of(context).rate,
          noButton: AppLocalization.of(context).noThanks,
          laterButton: AppLocalization.of(context).maybeLater,
          listener: (RateMyAppDialogButton button) {
            // The button click listener (useful if you want to cancel the click event).
            switch (button) {
              case RateMyAppDialogButton.rate:
                break;
              case RateMyAppDialogButton.later:
                break;
              case RateMyAppDialogButton.no:
                break;
            }
            return true; // Return false if you want to cancel the click event.
          },
          ignoreNativeDialog: Platform.isAndroid,
          dialogStyle: const DialogStyle(
            dialogShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          ), // Custom dialog styles.
          // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
          onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
          // This one allows you to change the default dialog content.
          // contentBuilder: (context, defaultContent) => content,
          // This one allows you to use your own buttons.
          // actionsBuilder: (context) => [],
        );
      }

      // first launch:
      final bool isFirstLaunch = !(await sl.get<SharedPrefsUtil>().getFirstContactAdded());
      if (!mounted) return;

      // Setup notifications
      // skip if we just opened a gift card:
      if (!StateContainer.of(context).introSkiped) {
        await getNotificationPermissions();
      }

      await getTrackingPermissions();

      if (!mounted) return;

      // show changelog?

      // don't show the changelog on first launch:
      if (!StateContainer.of(context).introSkiped && !isFirstLaunch) {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        final String runningVersion = packageInfo.version;
        final String lastVersion = await sl.get<SharedPrefsUtil>().getAppVersion();
        if (runningVersion != lastVersion) {
          await sl.get<SharedPrefsUtil>().setAppVersion(runningVersion);
          if (!mounted) return;
          await AppDialogs.showChangeLog(context);
          if (!mounted) return;

          // also force a username update:
          StateContainer.of(context).checkAndUpdateNanoToUsernames(true);
        }
      }

      // are we not connected after ~5 seconds?
      Future<dynamic>.delayed(const Duration(seconds: 5), () async {
        if (!mounted) return;
        final bool connected = await sl.get<AccountService>().isConnected();
        showConnectionWarning(!connected);
      });

      // listen for nfc tag events:
      listenForNFC();

      // add donations contact:
      _addSampleContact();
    });
    // confetti:
    _confettiControllerLeft = ConfettiController(duration: const Duration(milliseconds: 150));
    _confettiControllerRight = ConfettiController(duration: const Duration(milliseconds: 150));
  }

  Future<void> showConnectionWarning(bool showWarning) async {
    final AlertResponseItem alert = AlertResponseItem(
      id: 4041,
      active: true,
      title: AppLocalization.of(context).connectionWarning,
      shortDescription: AppLocalization.of(context).connectionWarningBodyShort,
      longDescription: AppLocalization.of(context).connectionWarningBodyLong,
      dismissable: false,
    );
    if (showWarning) {
      // ignore the dismissal of the alert, since it's the highest priority:
      StateContainer.of(context).addActiveOrSettingsAlert(alert, null);
      if (StateContainer.of(context).wallet!.loading) {
        setState(() {
          StateContainer.of(context).wallet!.loading = false;
          StateContainer.of(context).wallet!.unifiedLoading = false;
          StateContainer.of(context).wallet!.historyLoading = false;
        });
      }
    } else {
      StateContainer.of(context).removeActiveOrSettingsAlert(alert, null);
    }
    return;
  }

  Future<void> showNotificationWarning() async {
    final AlertResponseItem alert = AlertResponseItem(
      id: 4042,
      active: true,
      title: AppLocalization.of(context).notificationWarning,
      shortDescription: AppLocalization.of(context).notificationWarningBodyShort,
      longDescription: AppLocalization.of(context).notificationWarningBodyLong,
    );
    // don't show if already dismissed:
    // if (await sl.get<SharedPrefsUtil>().shouldShowAlert(alert)) {
    StateContainer.of(context).addActiveOrSettingsAlert(alert, null);
    // }
    return;
  }

  Future<void> showTrackingWarning() async {
    final AlertResponseItem alert = AlertResponseItem(
      id: 4043,
      active: true,
      title: AppLocalization.of(context).trackingWarning,
      shortDescription: AppLocalization.of(context).trackingWarningBodyShort,
      longDescription: AppLocalization.of(context).trackingWarningBodyLong,
      dismissable: true,
    );
    // don't show if already dismissed:
    if (await sl.get<SharedPrefsUtil>().shouldShowAlert(alert)) {
      StateContainer.of(context).addActiveOrSettingsAlert(alert, null);
    }
    return;
  }

  void _animationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        _placeholderCardAnimationController.forward();
        break;
      case AnimationStatus.completed:
        _placeholderCardAnimationController.reverse();
        break;
      default:
        return;
    }
  }

  void _animationControllerListener() {
    setState(() {});
  }

  void _startAnimation() {
    if (_animationDisposed) {
      _animationDisposed = false;
      _placeholderCardAnimationController.addListener(_animationControllerListener);
      _opacityAnimation.addStatusListener(_animationStatusListener);
      _placeholderCardAnimationController.forward();
    }
  }

  void _disposeAnimation() {
    if (!_animationDisposed) {
      _animationDisposed = true;
      _opacityAnimation.removeStatusListener(_animationStatusListener);
      _placeholderCardAnimationController.removeListener(_animationControllerListener);
      _placeholderCardAnimationController.stop();
    }
  }

  Future<void> listenForNFC() async {
    final bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable || Platform.isIOS) {
      return;
    }

    // Start Session
    NfcManager.instance.startSession(
      // alertMessage: "Scan",
      onError: (NfcError error) async {
        log.d("onError: ${error.message}");
      },
      pollingOptions: Set()..add(NfcPollingOption.iso14443),
      onDiscovered: (NfcTag tag) async {
        // Do something with an NfcTag instance.
        final Ndef? ndef = Ndef.from(tag);
        if (ndef?.cachedMessage != null && ndef!.cachedMessage!.records.isNotEmpty) {
          Uint8List payload = ndef.cachedMessage!.records[0].payload;

          if (payload.length < 3) {
            return;
          }

          if (payload[0] == 0x00) {
            payload = payload.sublist(1);
            handleDeepLink(utf8.decode(payload));
          } else {
            // try anyways?
            handleDeepLink(utf8.decode(payload));
          }
        }
      },
    );
  }

  // Add donations contact if it hasnt already been added
  Future<void> _addSampleContact() async {
    final bool contactAdded = await sl.get<SharedPrefsUtil>().getFirstContactAdded();
    if (!contactAdded) {
      const String nautilusDonationsNickname = "NautilusDonations";
      await sl.get<SharedPrefsUtil>().setFirstContactAdded(true);
      final User donationsContact = User(
          nickname: nautilusDonationsNickname,
          address: "nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579",
          // username: "nautilus",
          type: UserTypes.CONTACT);
      await sl.get<DBHelper>().saveContact(donationsContact);
    }
  }

  void _updateUsers() {
    sl.get<DBHelper>().getUsers().then((List<User> users) {
      setState(() {
        _users = users;
      });
    });
  }

  Future<void> _updateTXDetailsMap(String? account) async {
    final List<TXData> data = await sl.get<DBHelper>().getAccountSpecificTXData(account);
    if (!mounted) return;
    setState(() {
      _txRecords = data;
      _txDetailsMap.clear();
    });
    for (final TXData tx in _txRecords) {
      if (tx.isSolid() && (isEmpty(tx.block) || isEmpty(tx.link))) {
        // set to the last block:
        final String? lastBlockHash = StateContainer.of(context).wallet!.history.isNotEmpty
            ? StateContainer.of(context).wallet!.history[0].hash
            : null;
        if (isEmpty(tx.block) && StateContainer.of(context).wallet!.address == tx.from_address) {
          tx.block = lastBlockHash;
        }
        if (isEmpty(tx.link) && StateContainer.of(context).wallet!.address == tx.to_address) {
          tx.link = lastBlockHash;
        }
        // save to db:
        sl.get<DBHelper>().replaceTXDataByUUID(tx);
      }
      // if unacknowledged, we're the recipient, and not local, ACK it:
      if (tx.is_acknowledged == false &&
          tx.to_address == StateContainer.of(context).wallet!.address &&
          !tx.uuid!.contains("LOCAL")) {
        log.v("ACKNOWLEDGING TX_DATA: ${tx.uuid}");
        tx.is_acknowledged = true;
        sl.get<DBHelper>().replaceTXDataByUUID(tx);
        sl.get<MetadataService>().requestACK(tx.uuid, tx.from_address, tx.to_address);
      }
      if (tx.is_memo && isEmpty(tx.link) && isNotEmpty(tx.block)) {
        if (_historyListMap[StateContainer.of(context).wallet!.address] != null) {
          // find if there's a matching link:
          // for (var histItem in StateContainer.of(context).wallet.history) {
          for (final AccountHistoryResponseItem histItem
              in _historyListMap[StateContainer.of(context).wallet!.address]!) {
            if (histItem.link == tx.block) {
              tx.link = histItem.hash;
              // save to db:
              sl.get<DBHelper>().replaceTXDataByUUID(tx);
              break;
            }
          }
        }
      }

      if (tx.record_type == RecordTypes.GIFT_LOAD) {
        if (isNotEmpty(tx.metadata)) {
          bool shouldUpdate = false;
          if (tx.request_time == null) {
            shouldUpdate = true;
          } else if (DateTime.fromMillisecondsSinceEpoch(tx.request_time! * 1000)
              .isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
            shouldUpdate = true;
          }
          if (shouldUpdate) {
            tx.request_time = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
            final String balanceRaw = await getGiftBalance(tx.to_address);

            if (balanceRaw.isNotEmpty) {
              final List<String> metadata = tx.metadata!.split(RecordTypes.SEPARATOR);
              if (metadata.length > 2) {
                metadata[2] = balanceRaw;
              } else if (metadata.length == 2) {
                metadata.add(balanceRaw);
              }
              tx.metadata = metadata.join(RecordTypes.SEPARATOR);
              // save to db:
              sl.get<DBHelper>().replaceTXDataByUUID(tx);
            }
          }
        }
      }

      // only applies to non-solids (i.e. memos / gifts):
      if (!tx.isSolid()) {
        setState(() {
          if (isNotEmpty(tx.block) && tx.from_address == account) {
            _txDetailsMap[tx.block!] = tx;
          } else if (isNotEmpty(tx.link) && tx.to_address == account) {
            _txDetailsMap[tx.link!] = tx;
          }
        });
      }
    }
  }

  StreamSubscription<ConfirmationHeightChangedEvent>? _confirmEventSub;
  StreamSubscription<HistoryHomeEvent>? _historySub;
  StreamSubscription<TXUpdateEvent>? _txUpdatesSub;
  StreamSubscription<PaymentsHomeEvent>? _solidsSub;
  StreamSubscription<UnifiedHomeEvent>? _unifiedSub;
  StreamSubscription<ContactModifiedEvent>? _contactModifiedSub;
  StreamSubscription<BlockedModifiedEvent>? _blockedModifiedSub;
  StreamSubscription<DisableLockTimeoutEvent>? _disableLockSub;
  StreamSubscription<AccountChangedEvent>? _switchAccountSub;
  StreamSubscription<DeepLinkEvent>? _deepLinkEventSub;
  StreamSubscription<XMREvent>? _xmrSub;

  void _registerBus() {
    _historySub = EventTaxiImpl.singleton().registerTo<HistoryHomeEvent>().listen((HistoryHomeEvent event) {
      updateHistoryList(event.items);
      // update tx memo's a second later since it could arrive late:
      Future<void>.delayed(const Duration(seconds: 1), () {
        _updateTXDetailsMap(StateContainer.of(context).wallet?.address);
      });
      // handle deep links:
      if (StateContainer.of(context).initialDeepLink != null) {
        handleDeepLink(StateContainer.of(context).initialDeepLink);
        StateContainer.of(context).initialDeepLink = null;
      }
    });
    _txUpdatesSub = EventTaxiImpl.singleton().registerTo<TXUpdateEvent>().listen((TXUpdateEvent event) {
      if (StateContainer.of(context).wallet?.address != null) {
        _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
      }
    });
    _solidsSub = EventTaxiImpl.singleton().registerTo<PaymentsHomeEvent>().listen((PaymentsHomeEvent event) {
      final List<TXData>? newSolids = event.items;
      if (newSolids == null || _solidsListMap[StateContainer.of(context).wallet!.address] == null) {
        return;
      }
      setState(() {
        _solidsListMap[StateContainer.of(context).wallet!.address!] = newSolids;
      });
    });
    _unifiedSub = EventTaxiImpl.singleton().registerTo<UnifiedHomeEvent>().listen((UnifiedHomeEvent event) {
      if (_isRefreshing) {
        setState(() {
          _isRefreshing = false;
        });
      }
      generateUnifiedList(fastUpdate: event.fastUpdate);
    });
    _contactModifiedSub =
        EventTaxiImpl.singleton().registerTo<ContactModifiedEvent>().listen((ContactModifiedEvent event) {
      setState(() {
        _updateUsers();
      });
    });
    // _blockedModifiedSub = EventTaxiImpl.singleton().registerTo<BlockedModifiedEvent>().listen((BlockedModifiedEvent event) {
    //   _updateBlocked();
    // });
    // Hackish event to block auto-lock functionality
    _disableLockSub =
        EventTaxiImpl.singleton().registerTo<DisableLockTimeoutEvent>().listen((DisableLockTimeoutEvent event) {
      if (event.disable!) {
        cancelLockEvent();
      }
      _lockDisabled = event.disable!;
    });
    // User changed account
    _switchAccountSub = EventTaxiImpl.singleton().registerTo<AccountChangedEvent>().listen((AccountChangedEvent event) {
      setState(() {
        _maxHistItems = initialMaxHistItems; // reset max history items
        _startAnimation();
        StateContainer.of(context).wallet!.loading = true;
        StateContainer.of(context).updateWallet(account: event.account!);
        currentConfHeight = -1;
      });
      if (event.delayPop) {
        Future<dynamic>.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
        });
      } else if (!event.noPop) {
        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      }
    });
    // Handle subscribe
    _confirmEventSub = EventTaxiImpl.singleton()
        .registerTo<ConfirmationHeightChangedEvent>()
        .listen((ConfirmationHeightChangedEvent event) {
      updateConfirmationHeights(event.confirmationHeight);
    });
    // deep link scan:
    _deepLinkEventSub = EventTaxiImpl.singleton().registerTo<DeepLinkEvent>().listen((DeepLinkEvent event) {
      handleDeepLink(event.link);
    });
    // xmr:
    _xmrSub = EventTaxiImpl.singleton().registerTo<XMREvent>().listen((XMREvent event) {
      if (event.type == "update_transfers") {
        final List<dynamic> transfers = jsonDecode(event.message) as List<dynamic>;
        _moneroHistoryList = transfers;

        if (StateContainer.of(context).wallet?.xmrLoading ?? false) {
          setState(() {
            StateContainer.of(context).wallet!.xmrLoading = false;
          });
        }
      }
    });
  }

  void _destroyBus() {
    if (_historySub != null) {
      _historySub!.cancel();
    }
    if (_contactModifiedSub != null) {
      _contactModifiedSub!.cancel();
    }
    if (_blockedModifiedSub != null) {
      _blockedModifiedSub!.cancel();
    }
    if (_disableLockSub != null) {
      _disableLockSub!.cancel();
    }
    if (_switchAccountSub != null) {
      _switchAccountSub!.cancel();
    }
    if (_confirmEventSub != null) {
      _confirmEventSub!.cancel();
    }
    if (_txUpdatesSub != null) {
      _txUpdatesSub!.cancel();
    }
    if (_solidsSub != null) {
      _solidsSub!.cancel();
    }
    if (_unifiedSub != null) {
      _unifiedSub!.cancel();
    }
    if (_xmrSub != null) {
      _xmrSub!.cancel();
    }
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
    // _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _xmrScrollController.dispose();
    _tabController.dispose();
    _placeholderCardAnimationController.dispose();
    _loadMoreAnimationController.dispose();
    // confetti:
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();

    NfcManager.instance.stopSession();

    super.dispose();
  }

  Future<void> _loadMore() async {
    if ((_historyListMap[StateContainer.of(context).wallet!.address]?.isEmpty ?? true) ||
        (StateContainer.of(context).wallet?.loading ?? true)) {
      return;
    }

    if (_trueMaxHistItems >= _maxHistItems) {
      setState(() {
        _loadingMore = true;
      });

      // random delay between 500ms and 1.5s:
      Future<void>.delayed(Duration(milliseconds: 250 + Random().nextInt(500)), () async {
        _maxHistItems += 35;
        await generateUnifiedList(fastUpdate: true);
        setState(() {
          _loadingMore = false;
        });
      });
    }
  }

  int currentConfHeight = -1;

  void updateConfirmationHeights(int? confirmationHeight) {
    setState(() {
      currentConfHeight = confirmationHeight! + 1;
    });
    if (!_historyListMap.containsKey(StateContainer.of(context).wallet!.address)) {
      return;
    }
    final List<int> unconfirmedUpdate = <int>[];
    final List<int> confirmedUpdate = <int>[];
    for (int i = 0; i < _historyListMap[StateContainer.of(context).wallet!.address]!.length; i++) {
      if ((_historyListMap[StateContainer.of(context).wallet!.address]![i].confirmed == null ||
              _historyListMap[StateContainer.of(context).wallet!.address]![i].confirmed!) &&
          _historyListMap[StateContainer.of(context).wallet!.address]![i].height != null &&
          confirmationHeight! < _historyListMap[StateContainer.of(context).wallet!.address]![i].height!) {
        unconfirmedUpdate.add(i);
      } else if ((_historyListMap[StateContainer.of(context).wallet!.address]![i].confirmed == null ||
              !_historyListMap[StateContainer.of(context).wallet!.address]![i].confirmed!) &&
          _historyListMap[StateContainer.of(context).wallet!.address]![i].height != null &&
          confirmationHeight! >= _historyListMap[StateContainer.of(context).wallet!.address]![i].height!) {
        confirmedUpdate.add(i);
      }
    }
    setState(() {
      for (final int index in unconfirmedUpdate) {
        _historyListMap[StateContainer.of(context).wallet!.address]![index].confirmed = false;
      }
      for (final int index in confirmedUpdate) {
        _historyListMap[StateContainer.of(context).wallet!.address]![index].confirmed = true;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle websocket connection when app is in background
    // terminate it to be eco-friendly
    switch (state) {
      case AppLifecycleState.paused:
        setAppLockEvent();
        StateContainer.of(context).disconnect();
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        cancelLockEvent();
        StateContainer.of(context).reconnect();
        // handle deep links:
        if (/*!StateContainer.of(context).wallet!.loading && */ StateContainer.of(context).initialDeepLink != null &&
            !_lockTriggered) {
          handleDeepLink(StateContainer.of(context).initialDeepLink);
          StateContainer.of(context).initialDeepLink = null;
        }
        if (StateContainer.of(context).gift != null && !_lockTriggered) {
          handleBranchGift(StateContainer.of(context).gift);
          StateContainer.of(context).resetGift();
        }
        // handle pending background events:
        if (StateContainer.of(context).wallet?.loading == false && !_lockTriggered) {
          handleReceivableBackgroundMessages();
        }

        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  // To lock and unlock the app
  StreamSubscription<dynamic>? lockStreamListener;

  Future<void> setAppLockEvent() async {
    if (((await sl.get<SharedPrefsUtil>().getLock()) || StateContainer.of(context).encryptedSecret != null) &&
        !_lockDisabled) {
      if (lockStreamListener != null) {
        lockStreamListener!.cancel();
      }
      final Future<dynamic> delayed = Future.delayed((await sl.get<SharedPrefsUtil>().getLockTimeout()).getDuration());
      delayed.then((_) {
        return true;
      });
      lockStreamListener = delayed.asStream().listen((_) {
        try {
          StateContainer.of(context).resetEncryptedSecret();
        } catch (e) {
          log.w("Failed to reset encrypted secret when locking ${e.toString()}");
        } finally {
          _lockTriggered = true;
          Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        }
      });
    }
  }

  Future<void> cancelLockEvent() async {
    if (lockStreamListener != null) {
      lockStreamListener!.cancel();
    }
  }

  Future<void> _refresh() async {
    // start refresh
    setState(() {
      _isRefreshing = true;
    });
    sl.get<HapticUtil>().success();
    // Hide refresh indicator after 2.5 seconds
    Future<dynamic>.delayed(const Duration(milliseconds: 2500), () {
      setState(() {
        _isRefreshing = false;
      });
    });
    if (_currentMode == "nano") {
      await StateContainer.of(context).requestUpdate();
      if (!mounted) return;
      // queries the db for account specific solids:
      await StateContainer.of(context).updateSolids();
      // _updateTXData();

      if (!mounted) return;
      // for memos:
      await _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
    } else {
      EventTaxiImpl.singleton().fire(XMREvent(type: "xmr_reload"));
      EventTaxiImpl.singleton().fire(XMREvent(type: "update_status", message: "loading"));
      setState(() {
        StateContainer.of(context).wallet!.xmrLoading = true;
      });
    }

    // are we not connected after ~5 seconds?
    await Future<dynamic>.delayed(const Duration(seconds: 8));
    final bool connected = await sl.get<AccountService>().isConnected();
    showConnectionWarning(!connected);
    // await generateUnifiedList(fastUpdate: false);
    // setState(() {});
  }

  ///
  /// Because there's nothing convenient like DiffUtil, some manual logic
  /// to determine the differences between two lists and to add new items.
  ///
  /// Depends on == being overriden in the AccountHistoryResponseItem class
  ///
  /// Required to do it this way for the animation
  ///
  void updateHistoryList(List<AccountHistoryResponseItem>? newList) {
    if (newList == null || newList.isEmpty || _historyListMap[StateContainer.of(context).wallet!.address] == null) {
      return;
    }

    _historyListMap[StateContainer.of(context).wallet!.address!] = newList;

    // Re-subscribe if missing data
    if (StateContainer.of(context).wallet!.loading) {
      StateContainer.of(context).requestSubscribe();
    } else {
      updateConfirmationHeights(StateContainer.of(context).wallet!.confirmationHeight);
    }
  }

  /// Desired relation | Result
  /// -------------------------------------------
  ///           a < b  | Returns a negative value.
  ///           a == b | Returns 0.
  ///           a > b  | Returns a positive value.
  ///
  int defaultSortComparison(dynamic a, dynamic b) {
    final int propertyA = a.height as int? ?? 0;
    final int propertyB = b.height as int? ?? 0;

    // both are AccountHistoryResponseItems:
    if (a is AccountHistoryResponseItem && b is AccountHistoryResponseItem) {
      if (propertyA < propertyB) {
        return 1;
      } else if (propertyA > propertyB) {
        return -1;
      } else {
        return 0;
      }
      // if both are TXData, sort by request time:
    } else if (a is TXData && b is TXData) {
      int aTime;
      int bTime;
      try {
        aTime = a.request_time!;
      } catch (e) {
        aTime = 0;
      }
      try {
        bTime = b.request_time!;
      } catch (e) {
        bTime = 0;
      }

      if (aTime < bTime) {
        return 1;
      } else if (aTime > bTime) {
        return -1;
      } else {
        return 0;
      }
    }

    if (propertyA < propertyB) {
      return 1;
    } else if (propertyA > propertyB) {
      return -1;
    } else if (propertyA == propertyB) {
      // ensure the request shows up lower in the list?:
      if (a is TXData && b is AccountHistoryResponseItem) {
        return 1;
      } else if (a is AccountHistoryResponseItem && b is TXData) {
        return -1;
      } else {
        return 0;
      }
    }
    return 0;
  }

  int amountSortComparison(dynamic a, dynamic b) {
    final String propertyA = a?.amount as String? ?? a?.amount_raw as String? ?? "";
    final String propertyB = b?.amount as String? ?? b?.amount_raw as String? ?? "";
    if (propertyA == "" || propertyB == "") {
      // messages don't have amounts:
      return 0;
    }

    final BigInt numA = BigInt.parse(propertyA);
    final BigInt numB = BigInt.parse(propertyB);
    if (numA < numB) {
      return 1;
    } else if (numA > numB) {
      return -1;
    } else if (numA == numB) {
      return 0;
    }

    return 0;
  }

  Future<void> generateMoneroList({bool fastUpdate = false}) async {
    ListModel<dynamic>? ULM = _moneroList;
    // if (StateContainer.of(context).activeAlert != null) {
    //   ULM = _unifiedListMap["${StateContainer.of(context).wallet!.address}alert"];
    // }
    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      ULM = _moneroList; // todo: use the alert list
    }

    if (_moneroHistoryList == null || ULM == null) {
      return;
    }

    if (ULM.length > 0) {
      log.d("generating unified list! fastUpdate: $fastUpdate");
    }

    // this isn't performant but w/e
    List<dynamic> unifiedList = [];
    List<int> removeIndices = [];

    // combine history and payments:
    // List<AccountHistoryResponseItem> historyList = StateContainer.of(context).wallet!.history!;
    // List<TXData> solidsList = StateContainer.of(context).wallet!.solids!;
    // final List<AccountHistoryResponseItem> historyList = _historyListMap[StateContainer.of(context).wallet!.address]!;
    // final List<TXData> solidsList = _solidsListMap[StateContainer.of(context).wallet!.address]!;

    // for (var tx in solidsList) {
    //   print("memo: ${tx.memo} is_request: ${tx.is_request}");
    // }

    // add tx's to the unified list:
    // unifiedList.addAll(historyList);
    // unifiedList.addAll(solidsList);
    // don't process change or openblocks:
    // unifiedList =
    //     List<dynamic>.from(historyList.where((AccountHistoryResponseItem element) => ![BlockTypes.CHANGE, BlockTypes.OPEN].contains(element.subtype)).toList());

    unifiedList = _moneroHistoryList;

    if (!mounted) return;

    bool overrideSort = false;

    // filter by search results:
    if (_searchController.text.isNotEmpty) {
      removeIndices = [];
      final String lowerCaseSearch = _searchController.text.toLowerCase();

      // override the sorting algo if the search is numeric:
      overrideSort = double.tryParse(lowerCaseSearch) != null;

      for (final dynamic dynamicItem in unifiedList) {
        bool shouldRemove = true;

        if (dynamicItem is SizedBox) continue;

        final TXData txDetails = dynamicItem is TXData
            ? dynamicItem
            : convertHistItemToTXData(dynamicItem as AccountHistoryResponseItem,
                txDetails: _txDetailsMap[dynamicItem.hash]);
        final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
        final String account = txDetails.getAccount(isRecipient);
        String displayName = Address(account).getShortestString() ?? "";

        // check if there's a username:
        for (final User user in _users) {
          if (user.address == account.replaceAll("xrb_", "nano_")) {
            displayName = user.getDisplayName()!;
            break;
          }
        }

        String? amountStr;
        int? localTimestamp;

        if (txDetails.request_time != null) {
          localTimestamp = txDetails.request_time;
        }

        if (txDetails.amount_raw != null && txDetails.amount_raw!.isNotEmpty) {
          amountStr = getRawAsThemeAwareAmount(context, txDetails.amount_raw);
          if (txDetails.is_request) {
            if (isRecipient) {
              if (AppLocalization.of(context).request.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            } else {
              if (AppLocalization.of(context).asked.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            }
          }
        }

        if (txDetails.is_tx) {
          if (txDetails.sub_type == BlockTypes.SEND) {
            if (AppLocalization.of(context).sent.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
          if (txDetails.sub_type == BlockTypes.RECEIVE) {
            if (AppLocalization.of(context).received.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
        }

        if (localTimestamp != null) {
          final String timeStr = getTimeAgoString(context, localTimestamp);
          if (timeStr.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (amountStr != null && amountStr.contains(lowerCaseSearch)) {
          shouldRemove = false;
        }
        if (isNotEmpty(txDetails.memo)) {
          if (txDetails.memo!.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
          if (AppLocalization.of(context).loaded.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (isNotEmpty(displayName)) {
          if (displayName.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        } else if (account.toLowerCase().contains(lowerCaseSearch)) {
          shouldRemove = false;
        }

        if (shouldRemove) {
          removeIndices.add(unifiedList.indexOf(dynamicItem));
        }
      }

      for (int i = removeIndices.length - 1; i >= 0; i--) {
        unifiedList.removeAt(removeIndices[i]);
      }
    }

    // sort by timestamp
    // should already be sorted but:
    // needed to sort payment requests by request time from each other:
    // if (!overrideSort) {
    //   unifiedList.sort(defaultSortComparison);
    // } else {
    //   unifiedList.sort(amountSortComparison);
    // }

    final bool noSearchResults = unifiedList.isEmpty && _searchController.text.isNotEmpty;

    if (noSearchResults) {
      unifiedList.add(const SizedBox());
    }

    if (noSearchResults != _xmrNoSearchResults) {
      setState(() {
        _xmrNoSearchResults = noSearchResults;
      });
    }

    // create a list of indices to remove:
    removeIndices = [];

    // remove anything that's not supposed to be there anymore:
    ULM.items.where((dynamic item) => !unifiedList.contains(item)).forEach((dynamic dynamicItem) {
      removeIndices.add(ULM!.items.indexOf(dynamicItem));
    });
    // mark anything out of place or not in the unified list as to be removed:
    if (_searchController.text.isNotEmpty) {
      ULM.items
          .where((dynamic item) => ULM!.items.indexOf(item) != (unifiedList.indexOf(item)))
          .forEach((dynamic dynamicItem) {
        removeIndices.add(ULM!.items.indexOf(dynamicItem));
      });
    }
    // ensure uniqueness and must be sorted to prevent an index error:
    removeIndices = removeIndices.toSet().toList();
    removeIndices.sort((int a, int b) => a.compareTo(b));

    // remove from the listmap:
    for (int i = removeIndices.length - 1; i >= 0; i--) {
      // don't set state since we don't need it to re-render just yet:
      // also it will throw an error because the list can be empty and the builder will get upset:
      ULM.removeAt(removeIndices[i], _buildUnifiedItem, instant: true);
    }

    // insert unifiedList into listmap:
    unifiedList.where((dynamic item) => !ULM!.items.contains(item)).forEach((dynamic dynamicItem) {
      int index = unifiedList.indexOf(dynamicItem);
      if (dynamicItem == null) {
        return;
      }
      index = max(min(index, ULM!.length), 0);
      setState(() {
        ULM!.insertAt(dynamicItem, index, instant: fastUpdate);
      });
    });

    // ready to be rendered:
    // if (StateContainer.of(context).wallet!.xmrLoading) {
    //   setState(() {
    //     // _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
    //     StateContainer.of(context).wallet!.xmrLoading = false;
    //   });
    // }
  }

  Future<void> generateUnifiedList({bool fastUpdate = false}) async {
    ListModel<dynamic>? ULM = _unifiedListMap[StateContainer.of(context).wallet!.address];

    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      ULM = _unifiedListMap["${StateContainer.of(context).wallet!.address}alert"];
    }

    if (_historyListMap[StateContainer.of(context).wallet!.address] == null ||
        _solidsListMap[StateContainer.of(context).wallet!.address] == null ||
        ULM == null) {
      return;
    }

    if (ULM.length > 0) {
      // log.d("generating unified list! fastUpdate: $fastUpdate");
    }

    // this isn't performant but w/e
    List<dynamic> unifiedList = [];
    List<int> removeIndices = [];

    // combine history and payments:
    // List<AccountHistoryResponseItem> historyList = StateContainer.of(context).wallet!.history!;
    // List<TXData> solidsList = StateContainer.of(context).wallet!.solids!;
    final List<AccountHistoryResponseItem> historyList = _historyListMap[StateContainer.of(context).wallet!.address]!;
    final List<TXData> solidsList = _solidsListMap[StateContainer.of(context).wallet!.address]!;

    // for (var tx in solidsList) {
    //   print("memo: ${tx.memo} is_request: ${tx.is_request}");
    // }

    // add tx's to the unified list:
    // unifiedList.addAll(historyList);
    // unifiedList.addAll(solidsList);
    // don't process change or openblocks:
    unifiedList = List<dynamic>.from(historyList
        .where((AccountHistoryResponseItem element) => ![BlockTypes.CHANGE, BlockTypes.OPEN].contains(element.subtype))
        .toList());
    // only work with the first _maxHistItems:
    _trueMaxHistItems = unifiedList.length;
    unifiedList = unifiedList.sublist(0, min(unifiedList.length, _maxHistItems));

    final Set<String?> uuids = {};
    final List<int?> idsToRemove = [];
    for (final TXData req in solidsList) {
      if (!uuids.contains(req.uuid)) {
        uuids.add(req.uuid);
      } else {
        log.e("detected duplicate TXData2! removing...");
        idsToRemove.add(req.id);
        await sl.get<DBHelper>().deleteTXDataByID(req.id);
        if (!mounted) return;
      }
    }
    for (final int? id in idsToRemove) {
      solidsList.removeWhere((TXData element) => element.id == id);
    }

    if (!mounted) return;

    // go through each item in the solidsList and insert it into the unifiedList at the matching block:
    for (int i = 0; i < solidsList.length; i++) {
      int? index;
      int? height;

      // if the block is null, give it one:
      if (solidsList[i].block == null) {
        final String? lastBlockHash = StateContainer.of(context).wallet!.history.isNotEmpty
            ? StateContainer.of(context).wallet!.history[0].hash
            : null;
        solidsList[i].block = lastBlockHash;
        await sl.get<DBHelper>().replaceTXDataByUUID(solidsList[i]);
      }
      if (!mounted) return;

      // find the index of the item in the unifiedList:
      for (int j = 0; j < unifiedList.length; j++) {
        // skip already inserted items:
        if (unifiedList[j] is TXData) {
          continue;
        }
        // remove from the list if it's a change block:
        // just in case:
        if ([BlockTypes.CHANGE, BlockTypes.OPEN].contains(unifiedList[j].subtype)) {
          unifiedList.removeAt(j);
          j--;
          continue;
        }
        final String histItemHash = unifiedList[j].hash as String;

        if (histItemHash == solidsList[i].block || histItemHash == solidsList[i].link) {
          index = j;
          height = unifiedList[j].height + 1 as int;
          break;
        }
      }

      // found an index to insert at:
      if (index != null) {
        solidsList[i].height = height;
        unifiedList.insert(index, solidsList[i]);
      } else {
        // throw Exception("Couldn't find index to insert Solid at!");
        // just insert at the top?
        // TODO: not necessarily the best way to handle this, should get real height:
        // wallet!.confirmationHeight += 1;
        solidsList[i].height = StateContainer.of(context).wallet!.confirmationHeight + 1;
        unifiedList.insert(0, solidsList[i]);
      }
    }

    if (!mounted) return;

    bool overrideSort = false;

    // filter by search results:
    if (_searchController.text.isNotEmpty) {
      removeIndices = [];
      final String lowerCaseSearch = _searchController.text.toLowerCase();

      // override the sorting algo if the search is numeric:
      overrideSort = double.tryParse(lowerCaseSearch) != null;

      for (final dynamic dynamicItem in unifiedList) {
        bool shouldRemove = true;

        final TXData txDetails = dynamicItem is TXData
            ? dynamicItem
            : convertHistItemToTXData(dynamicItem as AccountHistoryResponseItem,
                txDetails: _txDetailsMap[dynamicItem.hash]);
        final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
        final String account = txDetails.getAccount(isRecipient);

        String displayName = Address(account).getShortestString() ?? "";

        // check if there's a username:
        for (final User user in _users) {
          if (user.address == account.replaceAll("xrb_", "nano_")) {
            displayName = user.getDisplayName()!;
            break;
          }
        }

        String? amountStr;
        int? localTimestamp;

        if (txDetails.request_time != null) {
          localTimestamp = txDetails.request_time;
        }

        if (txDetails.amount_raw != null && txDetails.amount_raw!.isNotEmpty) {
          amountStr = getRawAsThemeAwareAmount(context, txDetails.amount_raw);
          if (txDetails.is_request) {
            if (isRecipient) {
              if (AppLocalization.of(context).request.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            } else {
              if (AppLocalization.of(context).asked.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            }
          }
        }

        if (txDetails.is_tx) {
          if (txDetails.sub_type == BlockTypes.SEND) {
            if (AppLocalization.of(context).sent.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
          if (txDetails.sub_type == BlockTypes.RECEIVE) {
            if (AppLocalization.of(context).received.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
        }

        if (localTimestamp != null) {
          final String timeStr = getTimeAgoString(context, localTimestamp);
          if (timeStr.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (amountStr != null && amountStr.contains(lowerCaseSearch)) {
          shouldRemove = false;
        }
        if (isNotEmpty(txDetails.memo)) {
          if (txDetails.memo!.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
          if (AppLocalization.of(context).loaded.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        }

        if (isNotEmpty(displayName)) {
          if (displayName.toLowerCase().contains(lowerCaseSearch)) {
            shouldRemove = false;
          }
        } else if (account.toLowerCase().contains(lowerCaseSearch)) {
          shouldRemove = false;
        }

        if (shouldRemove) {
          removeIndices.add(unifiedList.indexOf(dynamicItem));
        }
      }

      for (int i = removeIndices.length - 1; i >= 0; i--) {
        unifiedList.removeAt(removeIndices[i]);
      }
    }

    // sort by timestamp
    // should already be sorted but:
    // needed to sort payment requests by request time from each other:
    if (!overrideSort) {
      unifiedList.sort(defaultSortComparison);
    } else {
      unifiedList.sort(amountSortComparison);
    }

    final bool noSearchResults = unifiedList.isEmpty && _searchController.text.isNotEmpty;

    if (noSearchResults) {
      unifiedList.add(const SizedBox());
    }

    if (noSearchResults != _noSearchResults) {
      setState(() {
        _noSearchResults = noSearchResults;
      });
    }

    // create a list of indices to remove:
    removeIndices = <int>[];

    // remove anything that's not supposed to be there anymore:
    ULM.items.where((dynamic item) => !unifiedList.contains(item)).forEach((dynamic dynamicItem) {
      removeIndices.add(ULM!.items.indexOf(dynamicItem));
    });
    // mark anything out of place or not in the unified list as to be removed:
    if (_searchController.text.isNotEmpty) {
      ULM.items.where((item) => ULM!.items.indexOf(item) != (unifiedList.indexOf(item))).forEach((dynamic dynamicItem) {
        removeIndices.add(ULM!.items.indexOf(dynamicItem));
      });
    }
    // ensure uniqueness and must be sorted to prevent an index error:
    removeIndices = removeIndices.toSet().toList();
    removeIndices.sort((int a, int b) => a.compareTo(b));

    // remove from the listmap:
    for (int i = removeIndices.length - 1; i >= 0; i--) {
      // don't set state since we don't need it to re-render just yet:
      // also it will throw an error because the list can be empty and the builder will get upset:
      ULM.removeAt(removeIndices[i], _buildUnifiedItem, instant: true);
    }

    // insert unifiedList into listmap:
    unifiedList.where((dynamic item) => !ULM!.items.contains(item)).forEach((dynamic dynamicItem) {
      int index = unifiedList.indexOf(dynamicItem);
      if (dynamicItem == null) {
        return;
      }
      index = max(min(index, ULM!.length), 0);
      setState(() {
        ULM!.insertAt(dynamicItem, index, instant: fastUpdate);
      });
    });

    // ready to be rendered:
    if (StateContainer.of(context).wallet!.unifiedLoading) {
      setState(() {
        _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
        StateContainer.of(context).wallet!.unifiedLoading = false;
      });
    }
  }

  Future<void> handleDeepLink(String? link) async {
    log.d("handling deep link: $link");
    if (link == null || link.isEmpty) {
      return;
    }

    if (link.contains("confetti")) {
      Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      await Future<dynamic>.delayed(const Duration(milliseconds: 150));
      _confettiControllerLeft.play();
      _confettiControllerRight.play();
      setState(() {});
    }

    if (!mounted) return;

    final dynamic result = uriParser(link);

    if (result == null) {
      return;
    }

    if (result is Address && result.isValid()) {
      final Address address = result;
      String? amount;
      bool sufficientBalance = false;
      if (address.amount != null) {
        final BigInt? amountBigInt = BigInt.tryParse(address.amount!);
        // Require minimum 1 raw to send, and make sure sufficient balance
        if (amountBigInt != null && amountBigInt >= BigInt.from(10).pow(24)) {
          if (StateContainer.of(context).wallet!.accountBalance > amountBigInt) {
            sufficientBalance = true;
          }
          amount = address.amount;
        }
      }
      // See if a contact
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(address.address!);
      // Remove any other screens from stack
      if (!mounted) return;
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      if (amount != null && sufficientBalance) {
        // Go to send confirm with amount
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendConfirmSheet(
                amountRaw: amount, destination: address.address!, contactName: user?.getDisplayName()));
      } else {
        // Go to send with address
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(
                localCurrency: StateContainer.of(context).curCurrency,
                user: user,
                address: address.address,
                quickSendAmount: amount));
      }
    } else if (result is PayItem) {
      // handle block handoff:
      final PayItem payItem = result;
      // See if this address belongs to a contact or username
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(payItem.account);

      // check if the user has enough balance to send this amount:
      // If balance is insufficient show error:
      final BigInt? amountBigInt = BigInt.tryParse(payItem.amount);
      if (StateContainer.of(context).wallet!.accountBalance < amountBigInt!) {
        UIUtil.showSnackbar(AppLocalization.of(context).insufficientBalance, context);
        return;
      }

      // if payItem.exact is false, we should allow the user to change the amount to send to >= amount
      if (!payItem.exact && mounted) {
        // TODO:
        log.d("PayItem exact is false: unsupported handoff flow!");
        return;
      }

      // Go to confirm sheet:
      Sheets.showAppHeightNineSheet(
          context: context,
          widget: HandoffConfirmSheet(
            payItem: payItem,
            destination: user?.address ?? payItem.account,
            contactName: user?.getDisplayName(),
          ));
    } else if (result is AuthItem) {
      // handle auth handoff:
      final AuthItem authItem = result;
      // See if this address belongs to a contact or username
      final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(authItem.account);

      // Go to confirm sheet:
      Sheets.showAppHeightNineSheet(
        context: context,
        widget: AuthConfirmSheet(
          authItem: authItem,
          destination: user?.address ?? authItem.account,
          contactName: user?.getDisplayName(),
        ),
      );
    }
  }

  // handle receivable messages
  Future<void> handleReceivableBackgroundMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final List<String>? backgroundMessages = prefs.getStringList("background_messages");
    // process the message now that we're in the foreground:

    if (!mounted) return;

    if (backgroundMessages != null) {
      // EventTaxiImpl.singleton().fire(FcmMessageEvent(message_list: backgroundMessages));
      await StateContainer.of(context).handleStoredMessages(FcmMessageEvent(message_list: backgroundMessages));
      // clear the storage since we just processed it:
      await prefs.remove("background_messages");
    }
  }

  Widget _buildMainColumnView(BuildContext context) {
    if (_currentMode == "nano") {
      if (_receiveDisabled &&
          StateContainer.of(context).wallet?.address != null &&
          StateContainer.of(context).wallet!.address!.isNotEmpty) {
        setState(() {
          _receiveDisabled = false;
        });
      }
    }
    if (_currentMode == "monero") {
      if (_xmrSRDisabled && StateContainer.of(context).xmrAddress.isNotEmpty) {
        setState(() {
          _xmrSRDisabled = false;
        });
      }
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  TopCard(
                    scaffoldKey: _scaffoldKey,
                    opacityAnimation: _opacityAnimation,
                    child: _buildSearchbarAnimation(),
                  ),
                  // MarketCard(
                  //   scaffoldKey: _scaffoldKey,
                  //   localCurrency: StateContainer.of(context).curCurrency,
                  //   opacityAnimation: _opacityAnimation,
                  // ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: 20),
                  ),
                  if (StateContainer.of(context).xmrEnabled)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      child: TabBar(
                        controller: _tabController,
                        indicatorWeight: 2,
                        indicatorColor: StateContainer.of(context).curTheme.primary,
                        indicatorPadding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        isScrollable: false,
                        splashBorderRadius: const BorderRadius.all(Radius.circular(15)),
                        tabs: <Widget>[
                          Tab(
                            child: Container(
                              margin: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: Text(
                                NonTranslatable.nano,
                                textAlign: TextAlign.center,
                                style: AppStyles.textStyleTransactionWelcome(context),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              margin: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: Text(
                                NonTranslatable.monero,
                                textAlign: TextAlign.center,
                                style: AppStyles.textStyleTransactionWelcome(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  // load xmr tab immediately if enabled to speed up the syncing process:
                  if (StateContainer.of(context).xmrEnabled)
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        const CustomMonero(),
                        Container(
                            width: 2, height: 2, color: StateContainer.of(context).curTheme.background?.withOpacity(1)),
                      ],
                    ),

                  Expanded(
                    child: (StateContainer.of(context).xmrEnabled)
                        ? TabBarView(
                            controller: _tabController,
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  _getUnifiedListWidget(context),
                                  ListGradient(
                                    height: 10,
                                    top: true,
                                    color: StateContainer.of(context).curTheme.background!,
                                  ),
                                  ListGradient(
                                    height: 20,
                                    top: false,
                                    color: StateContainer.of(context).curTheme.background!,
                                  ),
                                ],
                              ),
                              Stack(
                                children: <Widget>[
                                  _getMoneroListWidget(context),
                                  ListGradient(
                                    height: 10,
                                    top: true,
                                    color: StateContainer.of(context).curTheme.background!,
                                  ),
                                  ListGradient(
                                    height: 20,
                                    top: false,
                                    color: StateContainer.of(context).curTheme.background!,
                                  ),
                                  // TextButton(
                                  //   onPressed: () async {
                                  //     Sheets.showAppHeightEightSheet(context: context, widget: SetRestoreHeightSheet());
                                  //   },
                                  //   child: Text(
                                  //     "Set Restore Height/local",
                                  //     textAlign: TextAlign.center,
                                  //     style: AppStyles.textStyleButtonPrimary(context),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          )
                        : Stack(
                            children: <Widget>[
                              _getUnifiedListWidget(context),
                              ListGradient(
                                height: 10,
                                top: true,
                                color: StateContainer.of(context).curTheme.background!,
                              ),
                              ListGradient(
                                height: 20,
                                top: false,
                                color: StateContainer.of(context).curTheme.background!,
                              ),
                            ],
                          ),
                  ),
                  SizedBox(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                  ),
                ],
              ),

              if (_currentMode == "nano")
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS),
                        boxShadow: <BoxShadow>[StateContainer.of(context).curTheme.boxShadowButton!],
                      ),
                      height: 55,
                      width: (UIUtil.getDrawerAwareScreenWidth(context) - 42).abs() / 2,
                      margin: const EdgeInsetsDirectional.only(start: 14, top: 0.0, end: 7.0),
                      // margin: EdgeInsetsDirectional.only(start: 7.0, top: 0.0, end: 7.0),
                      child: TextButton(
                        key: const Key("home_receive_button"),
                        style: TextButton.styleFrom(
                          backgroundColor: !_receiveDisabled
                              ? StateContainer.of(context).curTheme.primary
                              : StateContainer.of(context).curTheme.primary60,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
                          foregroundColor:
                              !_receiveDisabled ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                        ),
                        child: AutoSizeText(
                          AppLocalization.of(context).request,
                          textAlign: TextAlign.center,
                          style: AppStyles.textStyleButtonPrimary(context),
                          maxLines: 1,
                          stepGranularity: 0.5,
                        ),
                        onPressed: () async {
                          if (_receiveDisabled) {
                            return;
                          }

                          final String data = "nano:${StateContainer.of(context).wallet!.address}";
                          final Widget qrWidget = SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: await UIUtil.getQRImage(context, data),
                          );
                          if (!mounted) return;
                          Sheets.showAppHeightNineSheet(
                              context: context,
                              widget: ReceiveSheet(
                                localCurrency: StateContainer.of(context).curCurrency,
                                address: StateContainer.of(context).wallet!.address,
                                qrWidget: qrWidget,
                              ));
                        },
                      ),
                    ),
                    const AppPopupButton(moneroEnabled: false, enabled: true),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS),
                        boxShadow: <BoxShadow>[StateContainer.of(context).curTheme.boxShadowButton!],
                      ),
                      height: 55,
                      width: (UIUtil.getDrawerAwareScreenWidth(context) - 42).abs() / 2,
                      margin: const EdgeInsetsDirectional.only(start: 14, top: 0.0, end: 7.0),
                      // margin: EdgeInsetsDirectional.only(start: 7.0, top: 0.0, end: 7.0),
                      child: TextButton(
                        key: const Key("home_receive_button"),
                        style: TextButton.styleFrom(
                          backgroundColor: !_xmrSRDisabled
                              ? StateContainer.of(context).curTheme.primary
                              : StateContainer.of(context).curTheme.primary60,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
                          foregroundColor:
                              !_xmrSRDisabled ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                        ),
                        child: AutoSizeText(
                          AppLocalization.of(context).receive,
                          textAlign: TextAlign.center,
                          style: AppStyles.textStyleButtonPrimary(context),
                          maxLines: 1,
                          stepGranularity: 0.5,
                        ),
                        onPressed: () async {
                          if (_xmrSRDisabled) {
                            return;
                          }

                          final String data = "monero:${StateContainer.of(context).xmrAddress}";
                          final Widget qrWidget = SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: await UIUtil.getQRImage(context, data),
                          );
                          if (!mounted) return;
                          Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: ReceiveXMRSheet(
                              address: StateContainer.of(context).xmrAddress,
                              qrWidget: qrWidget,
                              localCurrency: StateContainer.of(context).curCurrency,
                            ),
                          );
                        },
                      ),
                    ),
                    AppPopupButton(moneroEnabled: true, enabled: !_xmrSRDisabled),
                  ],
                ),

              // confetti: LEFT
              Align(
                alignment: Alignment.centerLeft,
                child: ConfettiWidget(
                  blastDirectionality: BlastDirectionality.explosive,
                  confettiController: _confettiControllerLeft,
                  blastDirection: -pi / 3,
                  emissionFrequency: 0.02,
                  // numberOfParticles: 30,
                  numberOfParticles: 40,
                  maxBlastForce: 60,
                  minBlastForce: 10,
                  // strokeWidth: 1,
                  gravity: 0.3,
                ),
              ),
              // confetti: RIGHT
              Align(
                alignment: Alignment.centerRight,
                child: ConfettiWidget(
                  blastDirectionality: BlastDirectionality.explosive,
                  confettiController: _confettiControllerRight,
                  blastDirection: -2 * pi / 3,
                  emissionFrequency: 0.02,
                  // numberOfParticles: 30,
                  numberOfParticles: 40,
                  maxBlastForce: 60,
                  minBlastForce: 10,
                  gravity: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          topLeft: Radius.circular(32),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag),
              label: AppLocalization.of(context).shopButton,
              backgroundColor: StateContainer.of(context).curTheme.warning,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocalization.of(context).homeButton,
              backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business),
              label: AppLocalization.of(context).businessButton,
              backgroundColor: StateContainer.of(context).curTheme.warning,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: StateContainer.of(context).curTheme.primary,
          unselectedItemColor: StateContainer.of(context).curTheme.text,
          onTap: (int index) {
            if (_selectedIndex == index) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // handle branch gift if it exists:
    if (StateContainer.of(context).gift != null && !_lockTriggered) {
      handleBranchGift(StateContainer.of(context).gift);
      StateContainer.of(context).resetGift();
    }

    /* MOBILE MODE */
    if (!UIUtil.isTablet(context)) {
      return Scaffold(
        drawerEdgeDragWidth: 180,
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: StateContainer.of(context).curTheme.background,
        drawerScrimColor: StateContainer.of(context).curTheme.barrierWeaker,
        drawer: SizedBox(
          width: UIUtil.drawerWidth(context),
          child: Drawer(
            child: SettingsSheet(),
          ),
        ),
        body: SafeArea(
          minimum: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.045,
              bottom: /*MediaQuery.of(context).size.height * 0.035*/ MediaQuery.of(context).size.height * 0.02),
          child: _buildMainColumnView(context),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      );
    }
    /* TABLET MODE */
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.background,
      body: SafeArea(
        minimum: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.045, /*bottom: MediaQuery.of(context).size.height * 0.035*/
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: UIUtil.drawerWidth(context),
              child: Drawer(
                child: SettingsSheet(),
              ),
            ),
            Container(
              width: UIUtil.getDrawerAwareScreenWidth(context),
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
              child: _buildMainColumnView(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildRemoteMessageCard(AlertResponseItem? alert) {
    if (alert == null) {
      return const SizedBox();
    }
    if (alert.id == 4040) {
      alert.title = AppLocalization.of(context).branchConnectErrorTitle;
      alert.shortDescription = AppLocalization.of(context).branchConnectErrorShortDesc;
      alert.longDescription = AppLocalization.of(context).branchConnectErrorLongDesc;
      // alert.dismissable = false;
    }
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 4),
      child: RemoteMessageCard(
        alert: alert,
        onPressed: () {
          Sheets.showAppHeightEightSheet(
            context: context,
            widget: RemoteMessageSheet(
              alert: alert,
            ),
          );
        },
      ),
    );
  }

  // Dummy Transaction Card
  Widget _buildDummyTXCard(BuildContext context,
      {required bool is_recipient,
      String? memo,
      String? amount_raw,
      String? displayName,
      bool? is_tx,
      bool? is_message,
      bool? is_memo,
      bool? is_request,
      bool is_acknowledged = true,
      bool is_fulfilled = true,
      int timestamp = 0}) {
    final TXData txData = TXData();

    if (amount_raw != null) {
      txData.amount_raw = amount_raw;
    }
    if (is_tx != null) {
      txData.is_tx = is_tx;
    }
    if (is_message != null) {
      txData.is_message = is_message;
    }
    if (isNotEmpty(memo)) {
      txData.is_memo = true;
      txData.memo = memo;
    }
    if (is_request != null) {
      txData.is_request = is_request;
    }
    if (is_acknowledged != null) {
      txData.is_acknowledged = is_acknowledged;
    }
    if (is_fulfilled != null) {
      txData.is_fulfilled = is_fulfilled;
    }
    if (timestamp != 0) {
      txData.request_time = timestamp;
    }

    if (is_recipient) {
      txData.to_address = StateContainer.of(context).wallet!.address;
      if (txData.is_tx) {
        txData.sub_type = BlockTypes.RECEIVE;
      }
    } else {
      txData.to_address = "";
      if (txData.is_tx) {
        txData.sub_type = BlockTypes.SEND;
      }
    }

    return _buildUnifiedCard(txData, _emptyAnimation, displayName!, context);
  }

  Widget _buildSearchbarAnimation() {
    return SearchBarAnimation(
      // isOriginalAnimation: false,
      // textEditingController: _searchController,
      // cursorColour: StateContainer.of(context).curTheme.primary,
      // isSearchBoxOnRightSide: !Bidi.isRtlLanguage(),
      // buttonWidget: Icon(
      //   Icons.search,
      //   size: 26,
      //   color: StateContainer.of(context).curTheme.text,
      // ),
      // secondaryButtonWidget: Icon(
      //   Icons.close,
      //   size: 20,
      //   color: StateContainer.of(context).curTheme.text,
      // ),
      // trailingWidget: Icon(
      //   Icons.search,
      //   size: 20,
      //   color: StateContainer.of(context).curTheme.primary,
      // ),
      // buttonColour: StateContainer.of(context).curTheme.backgroundDark, // icon background color
      // hintTextColour: StateContainer.of(context).curTheme.text30,
      // searchBoxColour: StateContainer.of(context).curTheme.backgroundDark, // background of the searchbox itself
      // enableBoxShadow: false,
      isOriginalAnimation: false,
      textEditingController: _searchController,
      cursorColour: StateContainer.of(context).curTheme.primary,
      isSearchBoxOnRightSide: !Bidi.isRtlLanguage(),
      buttonIcon: AppIcons.search,
      trailingIcon: AppIcons.search,
      buttonColour: StateContainer.of(context).curTheme.backgroundDark, // icon background color
      buttonIconColour: StateContainer.of(context).curTheme.text, // icon color
      hintTextColour: StateContainer.of(context).curTheme.text30,
      searchBoxColour: StateContainer.of(context).curTheme.backgroundDark, // background of the searchbox itself
      trailingIconColour: StateContainer.of(context).curTheme.primary, // on the left after opening the search box
      secondaryButtonIconColour: StateContainer.of(context).curTheme.text,
      enableBoxShadow: false,
      enableButtonBorder: false,
      enableButtonShadow: false,
      durationInMilliSeconds: 300,
      enableKeyboardFocus: true,
      enteredTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppFontSizes.small,
        color: StateContainer.of(context).curTheme.text,
        fontFamily: "NunitoSans",
      ),
      textAlignToRight: false,
      onChanged: (String value) async {
        setState(() {});
        await generateUnifiedList(fastUpdate: true);
      },
      onCollapseComplete: () async {
        setState(() {
          _searchOpen = false;
          _searchController.text = "";
        });
        await generateUnifiedList(fastUpdate: true);
      },
      onExpansionComplete: () async {
        setState(() {
          _searchOpen = true;
          _searchController.text = "";
        });
        await generateUnifiedList(fastUpdate: true);
      },
      enableBoxBorder: true,
      searchBoxBorderColour: StateContainer.of(context).curTheme.text,
      hintText: _searchOpen ? AppLocalization.of(context).searchHint : "",
    );
  }

  Future<String> getGiftBalance(String? address) async {
    if (address == null) {
      return "";
    }

    try {
      final AccountsBalancesResponse res = await sl<AccountService>().requestAccountsBalances([address]);
      if (res.balances?[address]?.balance == null) {
        return "";
      }

      BigInt? balance = BigInt.tryParse(res.balances![address]!.balance!);
      final BigInt? receivable = BigInt.tryParse(res.balances![address]!.receivable!);

      if (balance == null || receivable == null) {
        return "";
      }
      balance = balance + receivable;
      return balance.toString();
    } catch (e) {
      sl<Logger>().e("Error getting gift balance: $e");
      return "";
    }
  }

// Transaction Card/List Item
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
          itemText = AppLocalization.of(context).request;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = AppLocalization.of(context).asked;
          icon = AppIcons.call_received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        }
      } else if (txDetails.is_message) {
        if (txDetails.isRecipient(walletAddress)) {
          itemText = AppLocalization.of(context).received;
          icon = AppIcons.call_received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          itemText = AppLocalization.of(context).sent;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.text60;
        }
      }
    } else if (txDetails.is_tx) {
      if (isGift) {
        if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
          itemText = AppLocalization.of(context).loaded;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else if (txDetails.record_type == RecordTypes.GIFT_OPEN) {
          itemText = AppLocalization.of(context).opened;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          throw Exception("something went wrong with gift type");
        }
      } else {
        if (txDetails.sub_type == BlockTypes.SEND) {
          itemText = AppLocalization.of(context).sent;
          icon = AppIcons.sent;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = AppLocalization.of(context).received;
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
      if (_currentMode == "nano") {
        if ((!txDetails.is_fulfilled) ||
            (currentConfHeight > -1 && txDetails.height != null && txDetails.height! > currentConfHeight)) {
          transactionState = TransactionStateOptions.UNCONFIRMED;
        }
      } else {
        if (!txDetails.is_fulfilled) {
          transactionState = TransactionStateOptions.UNCONFIRMED;
        }
      }

      // watch only: receivable:
      if (txDetails.record_type == BlockTypes.RECEIVE) {
        transactionState = TransactionStateOptions.RECEIVABLE;
      }
    }

    final List<Widget> slideActions = [];
    String? label;
    if (txDetails.is_tx) {
      label = AppLocalization.of(context).send;
    } else {
      if (txDetails.is_request && txDetails.isRecipient(walletAddress)) {
        label = AppLocalization.of(context).pay;
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
          label: AppLocalization.of(context).reply,
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
            label: AppLocalization.of(context).retry,
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
            label: AppLocalization.of(context).retry,
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
            label: AppLocalization.of(context).retry,
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
          label: AppLocalization.of(context).delete,
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
                  backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                onPressed: () {
                  Sheets.showAppHeightEightSheet(
                      context: context, widget: PaymentDetailsSheet(txDetails: txDetails), animationDurationMs: 175);
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
                                    term: _searchController.text,
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
                                            term: _searchController.text,
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
                                      term: _searchController.text,
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
                                  term: _searchController.text,
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

                              // TRANSACTION STATE TAG
                              if (transactionState != null)
                                // ignore: avoid_unnecessary_containers
                                Container(
                                  // margin: const EdgeInsetsDirectional.only(
                                  //     // top: 10,
                                  //     ),
                                  child: TransactionStateTag(transactionState: transactionState),
                                ),

                              if (txDetails.request_time != null)
                                SubstringHighlight(
                                  caseSensitive: false,
                                  words: false,
                                  term: _searchController.text,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // handle bars:
            if (slideEnabled)
              Container(
                width: 4,
                height: 30,
                margin: const EdgeInsets.only(right: 22),
                decoration: BoxDecoration(
                  color: StateContainer.of(context).curTheme.text45,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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

  TXData convertMoneroHistItemToTXData(dynamic histItem, {TXData? txDetails}) {
    TXData converted = TXData();
    if (txDetails != null) {
      converted = txDetails;
    }
    histItem = histItem["state"];

    // transfer:

    final dynamic tx = histItem["tx"]["state"];

    if (tx["isIncoming"] as bool) {
      converted.sub_type = BlockTypes.RECEIVE;
      converted.to_address = StateContainer.of(context).xmrAddress;
      converted.from_address = histItem["address"] as String;
      converted.amount_raw = histItem["amount"] as String;
    } else if (tx["isOutgoing"] as bool) {
      converted.sub_type = BlockTypes.SEND;
      converted.from_address = StateContainer.of(context).xmrAddress;
      converted.to_address = histItem["addresses"][0] as String;
      converted.amount_raw = histItem["amount"] as String;
    }

    // convert to xmr amount:
    converted.amount_raw = (BigInt.parse(converted.amount_raw!) * NumberUtil.convertXMRtoNano).toString();

    converted.block ??= tx["hash"] as String;
    // converted.request_time ??= tx["block"]["state"]["timestamp"] as int;
    // converted.height ??= tx["block"]["state"]["height"] as int;
    if (tx["block"] != null) {
      converted.request_time ??= tx["block"]["state"]["timestamp"] as int?;
      converted.height ??= tx["block"]["state"]["height"] as int?;
    }

    if (tx["isConfirmed"] != null) {
      converted.is_fulfilled = tx["isConfirmed"] as bool; // confirmation status
    } else {
      converted.is_fulfilled = true; // default to true as it cannot be null
    }
    // converted.height ??= histItem.height!; // block height

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
    if (index < StateContainer.of(context).activeAlerts.length && StateContainer.of(context).activeAlerts.isNotEmpty) {
      return _buildRemoteMessageCard(StateContainer.of(context).activeAlerts[index]);
    }
    if (index == 0 && _noSearchResults) {
      return ExampleCards.noSearchResultsCard(context);
    }

    int localIndex = index;
    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      localIndex -= StateContainer.of(context).activeAlerts.length;
    }

    String ADR = StateContainer.of(context).wallet!.address!;
    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      ADR += "alert";
    }

    if (_loadingMore) {
      final int maxLen = _unifiedListMap[ADR]!.length + StateContainer.of(context).activeAlerts.length;
      if (index == maxLen - 1) {
        return ExampleCards.loadingCard(context);
      }
    }

    final dynamic indexedItem = _unifiedListMap[ADR]![localIndex];
    if (indexedItem is SizedBox) return indexedItem;

    final TXData txDetails = indexedItem is TXData
        ? indexedItem
        : convertHistItemToTXData(indexedItem as AccountHistoryResponseItem,
            txDetails: _txDetailsMap[indexedItem.hash]);
    final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
    final String account = txDetails.getAccount(isRecipient);
    String displayName = Address(account).getShortestString() ?? "";

    // check if there's a username:
    for (final User user in _users) {
      if (user.address == account.replaceAll("xrb_", "nano_")) {
        displayName = user.getDisplayName()!;
        break;
      }
    }

    return _buildUnifiedCard(txDetails, animation, displayName, context);
  }

  // Used to build list items that haven't been removed.
  Widget _buildMoneroItem(BuildContext context, int index, Animation<double> animation) {
    if (index < StateContainer.of(context).activeAlerts.length && StateContainer.of(context).activeAlerts.isNotEmpty) {
      return _buildRemoteMessageCard(StateContainer.of(context).activeAlerts[index]);
    }
    if (index == 0 && _xmrNoSearchResults) {
      return ExampleCards.noSearchResultsCard(context);
    }

    int localIndex = index;
    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      localIndex -= StateContainer.of(context).activeAlerts.length;
    }

    ListModel? list;

    final String ADR = StateContainer.of(context).wallet!.address!;

    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      list = _moneroList;
    } else {
      list = _moneroList; // todo:
    }

    final dynamic indexedItem = list![localIndex];
    final TXData txDetails = indexedItem is TXData
        ? indexedItem
        : convertMoneroHistItemToTXData(indexedItem /*, txDetails: _txDetailsMap[indexedItem.hash]*/);
    final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).xmrAddress);
    // final String displayName = txDetails.getShortestString(isRecipient) ?? "";
    final String account = txDetails.getAccount(isRecipient);
    String displayName = "${account.substring(0, 9)}\n...${account.substring(account.length - 6)}";
    // // check if there's a username:
    for (final User user in _users) {
      if (user.address == account.replaceAll("xrb_", "nano_")) {
        displayName = user.getDisplayName()!;
        break;
      }
    }

    return _buildUnifiedCard(txDetails, animation, displayName, context);
  }

  Widget _getMoneroListWidget(BuildContext context) {
    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.historyLoading == false) {
      // Setup history list
      if (_moneroHistoryList == null) {
        setState(() {
          _moneroHistoryList = <dynamic>[];
        });
      }

      GlobalKey<AnimatedListState>? listKey;
      ListModel? list;
      if (StateContainer.of(context).activeAlerts.isNotEmpty) {
        listKey = _moneroListKeyAlert;
        list = _moneroList; // todo:
      } else {
        listKey = _moneroListKey;
        list = _moneroList;
      }

      // Setup unified list
      if (_moneroListKey == null) {
        _moneroListKey = GlobalKey<AnimatedListState>();
        setState(() {
          _moneroList = ListModel<dynamic>(
            listKey: listKey!,
            initialItems: <dynamic>[],
          );
        });
      }

      if (StateContainer.of(context).wallet!.xmrLoading || (list != null && list.length == 0)) {
        generateMoneroList(fastUpdate: true);
      }
    }

    if (StateContainer.of(context).wallet == null ||
        StateContainer.of(context).wallet!.loading ||
        (StateContainer.of(context).wallet!.xmrLoading && StateContainer.of(context).xmrEnabled)) {
      // Loading Animation
      return ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _xmrScrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "10244000", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Received", "100,00000", "@fosse1234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "14500000", "12345678912345671234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "12,51200", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Received", "1,45300", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "100,00000", "12345678912345671234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Received", "24,00000", "12345678912345671234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "1,00000", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "1,00000", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "1,00000", "123456789121234"),
            ],
          ));
    } else if (!StateContainer.of(context).wallet!.unifiedLoading) {
      _disposeAnimation();
    }

    if (_moneroList == null || _moneroList!.length == 0) {
      final List<Widget> activeAlerts = <Widget>[];
      // for (final AlertResponseItem alert in StateContainer.of(context).activeAlerts) {
      //   activeAlerts.add(_buildRemoteMessageCard(alert));
      // }
      return DraggableScrollbar(
        controller: _scrollController,
        scrollbarColor: StateContainer.of(context).curTheme.primary!,
        scrollbarTopMargin: 10.0,
        scrollbarBottomMargin: 20.0,
        child: ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              // REMOTE MESSAGE CARDS
              if (StateContainer.of(context).activeAlerts.isNotEmpty)
                Column(
                  children: activeAlerts,
                ),
              ExampleCards.welcomeTransactionCard(context, true),
              _buildDummyTXCard(
                context,
                amount_raw: "30000000000000000000000000000000",
                displayName: AppLocalization.of(context).exampleRecRecipient,
                memo: AppLocalization.of(context).exampleRecRecipientMessage,
                is_recipient: true,
                is_tx: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60),
              ),
              _buildDummyTXCard(
                context,
                amount_raw: "50000000000000000000000000000000",
                displayName: AppLocalization.of(context).examplePayRecipient,
                memo: AppLocalization.of(context).examplePayRecipientMessage,
                is_recipient: false,
                is_tx: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 1),
              ),
            ],
          ),
        ),
      );
    }

    return DraggableScrollbar(
      controller: _xmrScrollController,
      scrollbarColor: StateContainer.of(context).curTheme.primary!,
      scrollbarTopMargin: 10.0,
      scrollbarBottomMargin: 20.0,
      child: ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
        child: AnimatedList(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _xmrScrollController,
          primary: false,
          key: _moneroListKey,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          initialItemCount: _moneroList!.length,
          itemBuilder: _buildMoneroItem,
        ),
      ),
    );
  }

  // Return widget for list
  Widget _getUnifiedListWidget(BuildContext context) {
    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.historyLoading == false) {
      // Setup history list
      if (!_historyListMap.containsKey("${StateContainer.of(context).wallet!.address}")) {
        setState(() {
          _historyListMap.putIfAbsent(
              StateContainer.of(context).wallet!.address!, () => StateContainer.of(context).wallet!.history);
        });
      }
      // Setup payments list
      if (!_solidsListMap.containsKey("${StateContainer.of(context).wallet!.address}")) {
        setState(() {
          _solidsListMap.putIfAbsent(
              StateContainer.of(context).wallet!.address!, () => StateContainer.of(context).wallet!.solids);
        });
      }

      String ADR = StateContainer.of(context).wallet!.address!;
      if (StateContainer.of(context).activeAlerts.isNotEmpty) {
        ADR = "${ADR}alert";
      }
      // Setup unified list
      if (!_unifiedListKeyMap.containsKey(ADR)) {
        _unifiedListKeyMap.putIfAbsent(ADR, () => GlobalKey<AnimatedListState>());
        setState(() {
          _unifiedListMap.putIfAbsent(
            ADR,
            () => ListModel<dynamic>(
              listKey: _unifiedListKeyMap[ADR]!,
              initialItems: StateContainer.of(context).wallet!.unified,
            ),
          );
        });
      }

      if (StateContainer.of(context).wallet!.unifiedLoading ||
          (_unifiedListMap[ADR] != null && _unifiedListMap[ADR]!.length == 0)) {
        generateUnifiedList(fastUpdate: true);
      }
    }

    // Loading Animation
    if (StateContainer.of(context).wallet == null ||
        StateContainer.of(context).wallet!.loading ||
        StateContainer.of(context).wallet!.unifiedLoading) {
      return ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "10244000", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Received", "100,00000", "@fosse1234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "14500000", "12345678912345671234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "12,51200", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Received", "1,45300", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "100,00000", "12345678912345671234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Received", "24,00000", "12345678912345671234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "1,00000", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "1,00000", "123456789121234"),
              ExampleCards.loadingTransactionCard(
                  context, _opacityAnimation.value, "Sent", "1,00000", "123456789121234"),
            ],
          ));
      // TODO: animation for xmr list
      // } else if (!StateContainer.of(context).xmrEnabled || !StateContainer.of(context).wallet!.xmrLoading) {
    } else {
      _disposeAnimation();
    }

    // welcome cards:
    if (StateContainer.of(context).wallet!.history.isEmpty && StateContainer.of(context).wallet!.solids.isEmpty) {
      final List<Widget> activeAlerts = <Widget>[];
      for (final AlertResponseItem alert in StateContainer.of(context).activeAlerts) {
        activeAlerts.add(_buildRemoteMessageCard(alert));
      }
      return DraggableScrollbar(
        controller: _scrollController,
        scrollbarColor: StateContainer.of(context).curTheme.primary!,
        scrollbarTopMargin: 10.0,
        scrollbarBottomMargin: 20.0,
        child: ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              // REMOTE MESSAGE CARDS
              if (StateContainer.of(context).activeAlerts.isNotEmpty)
                Column(
                  children: activeAlerts,
                ),
              ExampleCards.welcomeTransactionCard(context),
              _buildDummyTXCard(
                context,
                amount_raw: "30000000000000000000000000000000",
                displayName: AppLocalization.of(context).exampleRecRecipient,
                memo: AppLocalization.of(context).exampleRecRecipientMessage,
                is_recipient: true,
                is_tx: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60),
              ),
              _buildDummyTXCard(
                context,
                amount_raw: "50000000000000000000000000000000",
                displayName: AppLocalization.of(context).examplePayRecipient,
                memo: AppLocalization.of(context).examplePayRecipientMessage,
                is_recipient: false,
                is_tx: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 1),
              ),
              ExampleCards.welcomePaymentCardTwo(context),

              _buildDummyTXCard(
                context,
                amount_raw: "10000000000000000000000000000000",
                displayName: AppLocalization.of(context).examplePaymentTo,
                memo: AppLocalization.of(context).examplePaymentFulfilledMemo,
                is_recipient: false,
                is_request: true,
                is_fulfilled: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 5),
              ),
              _buildDummyTXCard(
                context,
                amount_raw: "2000000000000000000000000000000000",
                displayName: AppLocalization.of(context).examplePaymentFrom,
                memo: AppLocalization.of(context).examplePaymentReceivableMemo,
                is_recipient: true,
                is_request: true,
                is_fulfilled: false,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 7),
              ),
              _buildDummyTXCard(
                context,
                displayName: AppLocalization.of(context).examplePaymentTo,
                memo: AppLocalization.of(context).examplePaymentMessage,
                is_recipient: true,
                is_message: true,
                is_fulfilled: false,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 9),
              ),
            ],
          ),
        ),
      );
    }

    String ADR = StateContainer.of(context).wallet!.address!;

    if (StateContainer.of(context).activeAlerts.isNotEmpty) {
      ADR += "alert";
      // Setup unified list
      if (!_unifiedListKeyMap.containsKey(ADR)) {
        _unifiedListKeyMap.putIfAbsent(ADR, () => GlobalKey<AnimatedListState>());
        setState(() {
          _unifiedListMap.putIfAbsent(
            StateContainer.of(context).wallet!.address!,
            () => ListModel<dynamic>(
              listKey: _unifiedListKeyMap[ADR]!,
              initialItems: StateContainer.of(context).wallet!.unified,
            ),
          );
        });
      }
    }
    // return DraggableScrollbar(
    //   controller: _scrollController,
    //   scrollbarColor: StateContainer.of(context).curTheme.primary!,
    //   scrollbarTopMargin: 10.0,
    //   scrollbarBottomMargin: 20.0,
    //   child: ReactiveRefreshIndicator(
    //     backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
    //     onRefresh: _refresh,
    //     isRefreshing: _isRefreshing,
    //     child: AnimatedList(
    //       physics: const AlwaysScrollableScrollPhysics(),
    //       controller: _scrollController,
    //       key: _unifiedListKeyMap[ADR],
    //       padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
    //       initialItemCount: _unifiedListMap[ADR]!.length + StateContainer.of(context).activeAlerts.length,
    //       itemBuilder: _buildUnifiedItem,
    //     ),
    //   ),
    // );

    final Widget placeholder = ExampleCards.placeholderCard(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (!_loadingMore && (_scrollController.position.extentAfter <= 30)) {
          _loadMore();
        }
        return true;
      },
      child: DraggableScrollbar(
        controller: _scrollController,
        scrollbarColor: StateContainer.of(context).curTheme.primary!,
        scrollbarTopMargin: 10.0,
        scrollbarBottomMargin: 20.0,
        child: ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: AnimatedList(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            primary: false,
            key: _unifiedListKeyMap[ADR],
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            initialItemCount: _unifiedListMap[ADR]!.length + StateContainer.of(context).activeAlerts.length,
            itemBuilder: (BuildContext context, int index, Animation<double> animation) {
              if (_loadingMore) {
                final int maxLen = _unifiedListMap[ADR]!.length + StateContainer.of(context).activeAlerts.length;
                if (index == maxLen - 1) {
                  return ExampleCards.loadingCard(context);
                  // return ExampleCards.loadingCardAdvanced(context, _loadMoreAnimationController);
                }
              }
              return FrameSeparateWidget(
                index: index,
                placeHolder: placeholder,
                // placeHolder: Container(
                //   color: index.isEven ? Colors.red : Colors.blue,
                //   height: 65,
                // ),
                child: _buildUnifiedItem(context, index, animation),
              );
            },
          ),
        ),
      ),
    );
  }
}
