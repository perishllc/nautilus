// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/blocked_modified_event.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/bus/payments_home_event.dart';
import 'package:nautilus_wallet_flutter/bus/tx_update_event.dart';
import 'package:nautilus_wallet_flutter/bus/unified_home_event.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/list_model.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/block_types.dart';
import 'package:nautilus_wallet_flutter/network/model/fcm_message_event.dart';
import 'package:nautilus_wallet_flutter/network/model/record_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:nautilus_wallet_flutter/network/model/status_types.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/popup_button.dart';
import 'package:nautilus_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/settings_drawer.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/users/add_blocked.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/reactive_refresh.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/transaction_state_tag.dart';
import 'package:nautilus_wallet_flutter/util/box.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quiver/strings.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:uuid/uuid.dart';

class AppHomePage extends StatefulWidget {
  AppHomePage({this.priceConversion}) : super();
  PriceConversion? priceConversion;

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Logger log = sl.get<Logger>();

  // Controller for placeholder card animations
  late AnimationController _placeholderCardAnimationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _emptyAnimation;
  late bool _animationDisposed;

  // Receive card instance
  ReceiveSheet? receive;
  // Request card instance
  // RequestSheet request;

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String?, List<AccountHistoryResponseItem>?> _historyListMap = {};

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  // final Map<String, GlobalKey<AnimatedListState>> _requestsListKeyMap = {};
  // final Map<String, ListModel<TXData>> _paymentsListMap = {};
  final Map<String?, List<TXData>?> _solidsListMap = {};

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _unifiedListKeyMap = {};
  final Map<String?, ListModel<dynamic>> _unifiedListMap = {};

  // used to associate memos with blocks so we don't have search on every re-render:
  final Map<String?, TXData> _txDetailsMap = {};

  // search bar text controller:
  final TextEditingController _searchController = TextEditingController();
  bool _searchOpen = false;
  bool _noSearchResults = false;

  // List of contacts (Store it so we only have to query the DB once for transaction cards)
  // List<User> _contacts = [];
  // List<User> _blocked = [];
  List<User> _users = [];
  // List<TXData> _txData = [];
  List<TXData> _txRecords = [];

  // infinite scroll:
  late ScrollController _scrollController;

  // Price conversion state (BTC, NANO, NONE)
  PriceConversion? _priceConversion;

  bool _isRefreshing = false;
  bool _lockDisabled = false; // whether we should avoid locking the app
  bool _lockTriggered = false;

  // Main card height
  double? mainCardHeight;
  double settingsIconMarginTop = 5;
  // FCM instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // card time format:
  // String CARD_TIME_FORMAT = "MMM d, h:mm a";
  String CARD_TIME_FORMAT = "MMM dd, HH:mm";

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 5,
    googlePlayIdentifier: 'co.perish.nautiluswallet',
    appStoreIdentifier: '1615775960',
  );

  Future<void> _switchToAccount(String account) async {
    final List<Account> accounts = await sl.get<DBHelper>().getAccounts(await StateContainer.of(context).getSeed());
    for (Account acc in accounts) {
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
    try {
      final NotificationSettings settings = await _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
      if (settings.alert == AppleNotificationSetting.enabled ||
          settings.badge == AppleNotificationSetting.enabled ||
          settings.sound == AppleNotificationSetting.enabled ||
          settings.authorizationStatus == AuthorizationStatus.authorized) {
        sl.get<SharedPrefsUtil>().getNotificationsSet().then((bool beenSet) {
          if (!beenSet) {
            sl.get<SharedPrefsUtil>().setNotificationsOn(true);
          }
        });
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
  }

  Future<void> _branchGiftDialog(String seed, String? memo, String? amountRaw, String senderAddress) async {
    final String supposedAmount = getRawAsThemeAwareAmount(context, amountRaw);

    String? userOrSendAddress;

    // change address to username if it exists:
    final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(senderAddress);
    if (user != null) {
      userOrSendAddress = user.getDisplayName();
    } else {
      userOrSendAddress = senderAddress;
    }

    // check if there's actually any nano to claim:
    final BigInt balance = await AppTransferOverviewSheet().getGiftCardBalance(context, seed);
    try {
      if (balance != BigInt.zero) {
        final String actualAmount = getRawAsThemeAwareAmount(context, balance.toString());
        // show dialog with option to refund to sender:
        switch (await showDialog<int>(
            barrierDismissible: false,
            context: context,
            barrierColor: StateContainer.of(context).curTheme.barrier,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalization.of(context)!.giftAlert,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text("${AppLocalization.of(context)!.importGift}\n\n", style: AppStyles.textStyleParagraph(context)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context)!.giftFrom}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: "${userOrSendAddress!}\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                    if (memo != null && memo.isNotEmpty)
                      Text(
                        "${AppLocalization.of(context)!.giftMessage}: $memo\n",
                        style: AppStyles.textStyleParagraph(context),
                      ),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context)!.giftAmount}: ",
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppLocalization.of(context)!.refund,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  ),
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppLocalization.of(context)!.receive,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  ),
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 2);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppLocalization.of(context)!.close,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  )
                ],
              );
            })) {
          case 2:
            break;
          case 1:
            // transfer to this wallet:
            // await AppTransferConfirmSheet().createState().autoProcessWallets(privKeyBalanceMap, StateContainer.of(context).wallet);
            await AppTransferOverviewSheet().startAutoTransfer(context, seed, StateContainer.of(context).wallet);
            break;
          case 0:
            // refund the gift:
            await AppTransferOverviewSheet().startAutoRefund(
              context,
              seed,
              senderAddress,
            );
            break;
        }
      } else {
        if (!mounted) {
          return;
        }
        // show alert that the gift is empty:
        await showDialog<bool>(
            context: context,
            barrierColor: StateContainer.of(context).curTheme.barrier,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalization.of(context)!.giftAlertEmpty,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text("${AppLocalization.of(context)!.importGiftEmpty}\n\n", style: AppStyles.textStyleParagraph(context)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context)!.giftFrom}: ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: "${userOrSendAddress!}\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                    if (memo != null && memo.isNotEmpty)
                      Text(
                        "${AppLocalization.of(context)!.giftMessage}: $memo\n",
                        style: AppStyles.textStyleParagraph(context),
                      ),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "${AppLocalization.of(context)!.giftAmount}: ",
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
                        AppLocalization.of(context)!.ok,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  )
                ],
              );
            });
      }
    } catch (e) {
      log.d("Error processing gift card: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    WidgetsBinding.instance.addObserver(this);
    if (widget.priceConversion != null) {
      _priceConversion = widget.priceConversion;
    } else {
      _priceConversion = PriceConversion.CURRENCY;
    }
    // Main Card Size
    if (_priceConversion == PriceConversion.CURRENCY) {
      mainCardHeight = 80;
      settingsIconMarginTop = 15;
    } else if (_priceConversion == PriceConversion.NONE) {
      mainCardHeight = 64;
      settingsIconMarginTop = 7;
    } else if (_priceConversion == PriceConversion.HIDDEN) {
      mainCardHeight = 64;
      settingsIconMarginTop = 7;
    }
    _addSampleContact();
    _updateUsers();
    // _updateTXData();
    // infinite scroll:
    _scrollController = ScrollController()..addListener(_scrollListener);
    // Setup placeholder animation and start
    _animationDisposed = false;
    _placeholderCardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _placeholderCardAnimationController.addListener(_animationControllerListener);
    _opacityAnimation = Tween(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    // setup blank animation controller:
    _emptyAnimation = Tween(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    _opacityAnimation.addStatusListener(_animationStatusListener);
    _placeholderCardAnimationController.forward();
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
    // Setup notification
    getNotificationPermissions();

    // ask to rate the app:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (mounted && rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: AppLocalization.of(context)!.rateTheApp,
          message: AppLocalization.of(context)!.rateTheAppDescription,
          rateButton: AppLocalization.of(context)!.rate,
          noButton: AppLocalization.of(context)!.noThanks,
          laterButton: AppLocalization.of(context)!.maybeLater,
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
          dialogStyle: const DialogStyle(), // Custom dialog styles.
          // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
          onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
          // This one allows you to change the default dialog content.
          // contentBuilder: (context, defaultContent) => content,
          // This one allows you to use your own buttons.
          // actionsBuilder: (context) => [],
        );
      }

      // show changelog?
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String runningVersion = packageInfo.version;
      final String? lastVersion = await sl.get<SharedPrefsUtil>().getAppVersion();
      if (runningVersion != lastVersion) {
        await sl.get<SharedPrefsUtil>().setAppVersion(runningVersion);
        await AppDialogs.showChangeLog(context);

        // also force a username update:
        StateContainer.of(context).checkAndUpdateNanoToUsernames(true);
      }
    });
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

  /// Add donations contact if it hasnt already been added
  Future<void> _addSampleContact() async {
    final bool contactAdded = await sl.get<SharedPrefsUtil>().getFirstContactAdded();
    if (!contactAdded) {
      final bool addressExists = await sl.get<DBHelper>().contactExistsWithAddress("nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579");
      if (addressExists) {
        return;
      }
      final bool nameExists = await sl.get<DBHelper>().contactExistsWithName("NautilusDonations");
      if (nameExists) {
        return;
      }
      await sl.get<SharedPrefsUtil>().setFirstContactAdded(true);
      final User donationsContact = User(
          nickname: "NautilusDonations",
          address: "nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579",
          username: "nautilus",
          type: UserTypes.CONTACT);
      await sl.get<DBHelper>().saveContact(donationsContact);
    }
  }

  // void _updateContacts() {
  //   sl.get<DBHelper>().getContacts().then((List<User> contacts) {
  //     setState(() {
  //       _contacts = contacts;
  //     });
  //   });
  // }

  // void _updateBlocked() {
  //   sl.get<DBHelper>().getBlocked().then((List<User> blocked) {
  //     setState(() {
  //       _blocked = blocked;
  //     });
  //   });
  // }

  void _updateUsers() {
    sl.get<DBHelper>().getUsers().then((List<User> users) {
      setState(() {
        _users = users;
      });
    });
  }

  // void _updateTXData() {
  //   sl.get<DBHelper>().getTXData().then((List<TXData> txData) {
  //     setState(() {
  //       _txData = txData;
  //     });
  //   });
  // }

  void _updateTXDetailsMap(String? account) {
    sl.get<DBHelper>().getAccountSpecificTXData(account).then((List<TXData> data) {
      setState(() {
        _txRecords = data;
        _txDetailsMap.clear();
        for (TXData tx in _txRecords) {
          if (tx.isSolid() && (isEmpty(tx.block) || isEmpty(tx.link))) {
            // set to the last block:
            final String? lastBlockHash = StateContainer.of(context).wallet!.history!.isNotEmpty ? StateContainer.of(context).wallet!.history![0].hash : null;
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
          if (tx.is_acknowledged == false && tx.to_address == StateContainer.of(context).wallet!.address && !tx.uuid!.contains("LOCAL")) {
            log.v("ACKNOWLEDGING TX_DATA: ${tx.uuid}");
            sl.get<AccountService>().requestACK(tx.uuid, tx.from_address, tx.to_address);
          }
          if (tx.is_memo && isEmpty(tx.link) && isNotEmpty(tx.block)) {
            if (_historyListMap[StateContainer.of(context).wallet!.address] != null) {
              // find if there's a matching link:
              // for (var histItem in StateContainer.of(context).wallet.history) {
              for (AccountHistoryResponseItem histItem in _historyListMap[StateContainer.of(context).wallet!.address]!) {
                if (histItem.link == tx.block) {
                  tx.link = histItem.hash;
                  // save to db:
                  sl.get<DBHelper>().replaceTXDataByUUID(tx);
                  break;
                }
              }
            }
          }

          // only applies to non-solids (i.e. memos):
          if (!tx.isSolid()) {
            if (isNotEmpty(tx.block) && tx.from_address == account) {
              _txDetailsMap[tx.block] = tx;
            } else if (isNotEmpty(tx.link) && tx.to_address == account) {
              _txDetailsMap[tx.link] = tx;
            }
          }
        }
      });
    });
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

  void _registerBus() {
    _historySub = EventTaxiImpl.singleton().registerTo<HistoryHomeEvent>().listen((HistoryHomeEvent event) {
      updateHistoryList(event.items);
      // // update tx memo's
      // if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet.address != null) {
      //   _updateTXDetailsMap(StateContainer.of(context).wallet.address);
      // }
      // handle deep links:
      if (StateContainer.of(context).initialDeepLink != null) {
        handleDeepLink(StateContainer.of(context).initialDeepLink);
        StateContainer.of(context).initialDeepLink = null;
      }
    });
    _txUpdatesSub = EventTaxiImpl.singleton().registerTo<TXUpdateEvent>().listen((TXUpdateEvent event) {
      if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.address != null) {
        _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
      }
    });
    _solidsSub = EventTaxiImpl.singleton().registerTo<PaymentsHomeEvent>().listen((PaymentsHomeEvent event) {
      final List<TXData>? newSolids = event.items;
      if (newSolids == null || _solidsListMap[StateContainer.of(context).wallet!.address] == null) {
        return;
      }
      setState(() {
        _solidsListMap[StateContainer.of(context).wallet!.address] = newSolids;
      });
    });
    _unifiedSub = EventTaxiImpl.singleton().registerTo<UnifiedHomeEvent>().listen((UnifiedHomeEvent event) {
      generateUnifiedList(fastUpdate: event.fastUpdate);
    });
    _contactModifiedSub = EventTaxiImpl.singleton().registerTo<ContactModifiedEvent>().listen((ContactModifiedEvent event) {
      setState(() {
        _updateUsers();
      });
    });
    // _blockedModifiedSub = EventTaxiImpl.singleton().registerTo<BlockedModifiedEvent>().listen((BlockedModifiedEvent event) {
    //   _updateBlocked();
    // });
    // Hackish event to block auto-lock functionality
    _disableLockSub = EventTaxiImpl.singleton().registerTo<DisableLockTimeoutEvent>().listen((DisableLockTimeoutEvent event) {
      if (event.disable!) {
        cancelLockEvent();
      }
      _lockDisabled = event.disable!;
    });
    // User changed account
    _switchAccountSub = EventTaxiImpl.singleton().registerTo<AccountChangedEvent>().listen((AccountChangedEvent event) {
      setState(() {
        // todo: figure out if setState on statecontainer props does anything:
        // StateContainer.of(context).wallet!.loading = true;
        // StateContainer.of(context).wallet!.historyLoading = true;
        // StateContainer.of(context).wallet!.unifiedLoading = true;
        _startAnimation();
        StateContainer.of(context).updateWallet(account: event.account!);
        currentConfHeight = -1;
      });
      paintQrCode(address: event.account!.address);
      if (event.delayPop) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
        });
      } else if (!event.noPop) {
        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      }
    });
    // Handle subscribe
    _confirmEventSub = EventTaxiImpl.singleton().registerTo<ConfirmationHeightChangedEvent>().listen((ConfirmationHeightChangedEvent event) {
      updateConfirmationHeights(event.confirmationHeight);
    });
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _placeholderCardAnimationController.dispose();
    super.dispose();
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
  }

  void _scrollListener() {
    // print(_scrollController.position.extentAfter);
    // if (_scrollController.position.extentAfter < 500) {
    //   // check if the oldest item is the initial block:
    //   if (_historyListMap[StateContainer.of(context).wallet!.address] != null && _historyListMap[StateContainer.of(context).wallet!.address]!.isNotEmpty) {
    //     final List<AccountHistoryResponseItem> histList = _historyListMap[StateContainer.of(context).wallet!.address]!;

    //     // histList[0] is the most recent block with the highest height (120)
    //     // histList[1] is the second most recent block with the next highest height (119)
    //     // histList[120] is the oldest block with the lowest height (1)

    //     if (histList[histList.length - 1].height! > 1) {
    //       // we don't have all of the blocks yet, so we need to fetch more
    //       // TODO: implement this
    //       // StateContainer.of(context).requestUpdate(start: StateContainer.of(context).wallet.history.length, count: 50);
    //     }
    //   }
    // }
  }

  int currentConfHeight = -1;

  void updateConfirmationHeights(int? confirmationHeight) {
    setState(() {
      currentConfHeight = confirmationHeight! + 1;
    });
    if (!_historyListMap.containsKey(StateContainer.of(context).wallet!.address)) {
      return;
    }
    final List<int> unconfirmedUpdate = [];
    final List<int> confirmedUpdate = [];
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
    unconfirmedUpdate.forEach((int index) {
      setState(() {
        _historyListMap[StateContainer.of(context).wallet!.address]![index].confirmed = false;
      });
    });
    confirmedUpdate.forEach((int index) {
      setState(() {
        _historyListMap[StateContainer.of(context).wallet!.address]![index].confirmed = true;
      });
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
        if (!StateContainer.of(context).wallet!.loading! && StateContainer.of(context).initialDeepLink != null && !_lockTriggered) {
          handleDeepLink(StateContainer.of(context).initialDeepLink);
          StateContainer.of(context).initialDeepLink = null;
        }
        // branch gift:
        if (!StateContainer.of(context).wallet!.loading! && StateContainer.of(context).giftedWallet == true && !_lockTriggered) {
          StateContainer.of(context).giftedWallet = false;
          handleBranchGift();
        }
        // handle pending background events:
        if (!StateContainer.of(context).wallet!.loading! && !_lockTriggered) {
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
    if (((await sl.get<SharedPrefsUtil>().getLock()) || StateContainer.of(context).encryptedSecret != null) && !_lockDisabled) {
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
    Future.delayed(const Duration(milliseconds: 2500), () {
      setState(() {
        _isRefreshing = false;
      });
    });
    await StateContainer.of(context).requestUpdate();
    // queries the db for account specific solids:
    await StateContainer.of(context).updateSolids();
    // _updateTXData();
    // for memos:
    _updateTXDetailsMap(StateContainer.of(context).wallet!.address);

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

    _historyListMap[StateContainer.of(context).wallet!.address] = newList;

    // Re-subscribe if missing data
    if (StateContainer.of(context).wallet!.loading!) {
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

  void renderQueueOld() {
    // if (!overrideRenderQueue) {
    //   // check the render queue:
    //   if (_renderQueue.length > 0) {
    //     // push to the renderQueue and return:
    //     setState(() {
    //       _renderQueue.add(fastUpdate);
    //     });
    //     print("@@@@@@@@@@@@@@@@@@@@@@@@@@");
    //     return;
    //   }
    //   // push to the render queue, we're the first to render:
    //   setState(() {
    //     _renderQueue.add(fastUpdate);
    //   });
    // }

    //     // done with this render, see if there's another in the queue:
    // if (_renderQueue.length > 0) {
    //   // if this was a slow render then the next must be after at least 2.5 seconds:
    //   // if this was a fast render then the next must be after at least 0.5 seconds
    //   Duration timeBetweenRenders = fastUpdate ? RENDER_QUEUE_SHORT : RENDER_QUEUE_LONG;
    //   print("START");
    //   Timer(const Duration(seconds: 10), () async {
    //     print("END");
    //     if (mounted) {
    //       // we just rendered so pop the last element of the list:
    //       setState(() {
    //         _renderQueue.removeLast();
    //       });
    //       if (_renderQueue.isNotEmpty) {
    //         generateUnifiedList(fastUpdate: _renderQueue.last, overrideRenderQueue: true);
    //       }
    //     }
    //   });
    // }
  }

  Future<void> generateUnifiedList({bool fastUpdate = false}) async {
    if (_historyListMap[StateContainer.of(context).wallet!.address] == null ||
        _solidsListMap[StateContainer.of(context).wallet!.address] == null ||
        _unifiedListMap[StateContainer.of(context).wallet!.address] == null) {
      return;
    }

    if (_unifiedListMap[StateContainer.of(context).wallet!.address]!.length > 0) {
      log.d("generating unified list! fastUpdate: $fastUpdate");
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
    // don't process change blocks:
    unifiedList = List<dynamic>.from(historyList.where((AccountHistoryResponseItem element) => element.type != BlockTypes.CHANGE).toList());

    final Set<String?> uuids = {};
    final List<int?> idsToRemove = [];
    for (TXData req in solidsList) {
      if (!uuids.contains(req.uuid)) {
        uuids.add(req.uuid);
      } else {
        log.d("detected duplicate TXData2! removing...");
        idsToRemove.add(req.id);
        await sl.get<DBHelper>().deleteTXDataByID(req.id);
      }
    }
    for (int? id in idsToRemove) {
      solidsList.removeWhere((TXData element) => element.id == id);
    }

    // go through each item in the solidsList and insert it into the unifiedList at the matching block:
    for (int i = 0; i < solidsList.length; i++) {
      int? index;
      int? height;

      // if the block is null, give it one:
      if (solidsList[i].block == null) {
        final String? lastBlockHash = StateContainer.of(context).wallet!.history!.isNotEmpty ? StateContainer.of(context).wallet!.history![0].hash : null;
        solidsList[i].block = lastBlockHash;
        await sl.get<DBHelper>().replaceTXDataByUUID(solidsList[i]);
      }

      // find the index of the item in the unifiedList:
      for (int j = 0; j < unifiedList.length; j++) {
        // skip already inserted items:
        if (unifiedList[j] is TXData) {
          continue;
        }
        // remove from the list if it's a change block:
        // just in case:
        if (unifiedList[j].type == BlockTypes.CHANGE) {
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

    bool overrideSort = false;

    // filter by search results:
    if (_searchController.text.isNotEmpty) {
      removeIndices = [];
      final String lowerCaseSearch = _searchController.text.toLowerCase();

      // override the sorting algo if the search is numeric:
      overrideSort = double.tryParse(lowerCaseSearch) != null;

      unifiedList.forEach((dynamicItem) {
        bool shouldRemove = true;

        final TXData txDetails = dynamicItem is TXData
            ? dynamicItem
            : convertHistItemToTXData(dynamicItem as AccountHistoryResponseItem, txDetails: _txDetailsMap[dynamicItem.hash]);
        final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
        String displayName = txDetails.getShortestString(isRecipient)!;

        // check if there's a username:
        final String account = txDetails.getAccount(isRecipient);
        for (User user in _users) {
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
              if (AppLocalization.of(context)!.request.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            } else {
              if (AppLocalization.of(context)!.asked.toLowerCase().contains(lowerCaseSearch)) {
                shouldRemove = false;
              }
            }
          }
        }

        if (txDetails.is_tx) {
          if (txDetails.record_type == BlockTypes.SEND) {
            if (AppLocalization.of(context)!.sent.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
          if (txDetails.record_type == BlockTypes.RECEIVE) {
            if (AppLocalization.of(context)!.received.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
        }

        if (localTimestamp != null) {
          final String timeStr = DateFormat(CARD_TIME_FORMAT).format(DateTime.fromMillisecondsSinceEpoch(localTimestamp * 1000));
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
          if (AppLocalization.of(context)!.loaded.toLowerCase().contains(lowerCaseSearch)) {
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
      });

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

    final bool areThereNoSearchResults = unifiedList.isEmpty && _searchController.text.isNotEmpty;

    if (areThereNoSearchResults != _noSearchResults) {
      setState(() {
        _noSearchResults = areThereNoSearchResults;
      });
      // not sure why this gets the state to update, but nothing else will :/
      await sl.get<AccountService>().dummyAPICall();
    }

    // create a list of indices to remove:
    removeIndices = [];
    // remove anything that's not supposed to be there anymore:
    _unifiedListMap[StateContainer.of(context).wallet!.address]!.items.where((item) => !unifiedList.contains(item)).forEach((dynamicItem) {
      removeIndices.add(_unifiedListMap[StateContainer.of(context).wallet!.address]!.items.indexOf(dynamicItem));
    });
    // mark anything out of place or not in the unified list as to be removed:
    if (_searchController.text.isNotEmpty) {
      _unifiedListMap[StateContainer.of(context).wallet!.address]!
          .items
          .where((item) => _unifiedListMap[StateContainer.of(context).wallet!.address]!.items.indexOf(item) != (unifiedList.indexOf(item)))
          .forEach((dynamicItem) {
        removeIndices.add(_unifiedListMap[StateContainer.of(context).wallet!.address]!.items.indexOf(dynamicItem));
      });
    }
    // ensure uniqueness and must be sorted to prevent an index error:
    removeIndices = removeIndices.toSet().toList();
    removeIndices.sort((int a, int b) => a.compareTo(b));

    // remove from the listmap:
    for (int i = removeIndices.length - 1; i >= 0; i--) {
      // don't set state since we don't need it to re-render just yet:
      // also it will throw an error because the list can be empty and the builder will get upset:
      _unifiedListMap[StateContainer.of(context).wallet!.address]!.removeAt(removeIndices[i], _buildUnifiedItem, instant: true);
    }

    // insert unifiedList into listmap:
    unifiedList.where((item) => !_unifiedListMap[StateContainer.of(context).wallet!.address]!.items.contains(item)).forEach((dynamicItem) {
      int index = unifiedList.indexOf(dynamicItem);
      if (dynamicItem == null) {
        return;
      }
      index = max(min(index, _unifiedListMap[StateContainer.of(context).wallet!.address]!.length), 0);
      setState(() {
        _unifiedListMap[StateContainer.of(context).wallet!.address]!.insertAt(dynamicItem, index, instant: fastUpdate);
      });
    });

    // ready to be rendered:
    if (StateContainer.of(context).wallet!.unifiedLoading!) {
      setState(() {
        _updateTXDetailsMap(StateContainer.of(context).wallet!.address);
        StateContainer.of(context).wallet!.unifiedLoading = false;
      });
    }

    if (_isRefreshing) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> handleDeepLink(String? link) async {
    log.d("handleDeepLink: $link");
    final Address address = Address(link);
    if (address.isValid()) {
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
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      if (amount != null && sufficientBalance) {
        // Go to send confirm with amount
        Sheets.showAppHeightNineSheet(
            context: context, widget: SendConfirmSheet(amountRaw: amount, destination: address.address!, contactName: user?.getDisplayName()));
      } else {
        // Go to send with address
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(localCurrency: StateContainer.of(context).curCurrency, user: user, address: address.address, quickSendAmount: amount));
      }
    }
  }

  // branch deep link gift:
  Future<void> handleBranchGift() async {
    if (StateContainer.of(context).giftedWallet && StateContainer.of(context).wallet != null) {
      StateContainer.of(context).giftedWallet = false;

      Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      _branchGiftDialog(StateContainer.of(context).giftedWalletSeed, StateContainer.of(context).giftedWalletMemo,
          StateContainer.of(context).giftedWalletAmountRaw, StateContainer.of(context).giftedWalletSenderAddress);
    }
  }

  // handle receivable messages
  Future<void> handleReceivableBackgroundMessages() async {
    if (StateContainer.of(context).wallet != null) {
      log.d("NOW");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final List<String>? backgroundMessages = prefs.getStringList('background_messages');
      // process the message now that we're in the foreground:

      if (backgroundMessages != null) {
        // EventTaxiImpl.singleton().fire(FcmMessageEvent(message_list: backgroundMessages));
        await StateContainer.of(context).handleStoredMessages(FcmMessageEvent(message_list: backgroundMessages));
        // clear the storage since we just processed it:
        await prefs.remove('background_messages');
      }
    }
  }

  void paintQrCode({String? address}) {
    final QrPainter painter = QrPainter(
      data: "nano:${address ?? StateContainer.of(context).wallet!.address!}",
      version: 9,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    if (MediaQuery.of(context).size.width == 0) {
      return;
    }
    painter.toImageData(MediaQuery.of(context).size.width).then((ByteData? byteData) {
      setState(() {
        receive = ReceiveSheet(
          localCurrency: StateContainer.of(context).curCurrency,
          address: StateContainer.of(context).wallet!.address,
          qrWidget: SizedBox(width: MediaQuery.of(context).size.width / 2.675, child: Image.memory(byteData!.buffer.asUint8List())),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create QR ahead of time because it improves performance this way
    if (receive == null && StateContainer.of(context).wallet != null) {
      paintQrCode();
    }

    // handle branch gift if it exists:
    handleBranchGift();

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
          minimum: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.045, bottom: MediaQuery.of(context).size.height * 0.035),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    //Everything else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Main Card
                        _buildMainCard(context, _scaffoldKey),
                        //Main Card End
                        //Transactions Text
                        Container(
                          margin: const EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 26.0, 0.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                CaseChange.toUpperCase(AppLocalization.of(context)!.transactions, context),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w100,
                                  color: StateContainer.of(context).curTheme.text,
                                ),
                              ),
                            ],
                          ),
                        ), //Transactions Text End
                        //Transactions List
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              _getUnifiedListWidget(context),
                              //List Top Gradient End
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: 10.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [StateContainer.of(context).curTheme.background00!, StateContainer.of(context).curTheme.background!],
                                      begin: const AlignmentDirectional(0.5, 1.0),
                                      end: const AlignmentDirectional(0.5, -1.0),
                                    ),
                                  ),
                                ),
                              ), // List Top Gradient End
                              //List Bottom Gradient
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 30.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [StateContainer.of(context).curTheme.background00!, StateContainer.of(context).curTheme.background!],
                                      begin: const AlignmentDirectional(0.5, -1),
                                      end: const AlignmentDirectional(0.5, 0.5),
                                    ),
                                  ),
                                ),
                              ), //List Bottom Gradient End
                            ],
                          ),
                        ), //Transactions List End
                        //Buttons background
                        SizedBox(
                          height: 55,
                          width: MediaQuery.of(context).size.width,
                        ), //Buttons background
                      ],
                    ),
                    // Buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
                          ),
                          height: 55,
                          width: (MediaQuery.of(context).size.width - 42 - UIUtil.tabletDrawerWidth(context)).abs() / 2,
                          margin: const EdgeInsetsDirectional.only(start: 14, top: 0.0, end: 7.0),
                          // margin: EdgeInsetsDirectional.only(start: 7.0, top: 0.0, end: 7.0),
                          child: TextButton(
                            key: const Key("home_receive_button"),
                            style: TextButton.styleFrom(
                              backgroundColor: receive != null ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.primary60,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              primary: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                              // highlightColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                              // splashColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                            ),
                            child: AutoSizeText(
                              AppLocalization.of(context)!.receive,
                              textAlign: TextAlign.center,
                              style: AppStyles.textStyleButtonPrimary(context),
                              maxLines: 1,
                              stepGranularity: 0.5,
                            ),
                            onPressed: () {
                              if (receive == null) {
                                return;
                              }
                              Sheets.showAppHeightNineSheet(context: context, widget: receive!);
                            },
                          ),
                        ),
                        AppPopupButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
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
          minimum: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.045, bottom: MediaQuery.of(context).size.height * 0.035),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: UIUtil.drawerWidth(context),
                child: Drawer(
                  child: SettingsSheet(),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - (UIUtil.drawerWidth(context)),
                height: MediaQuery.of(context).size.height,
                child: Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      //Everything else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //Main Card
                          _buildMainCard(context, _scaffoldKey),
                          //Main Card End
                          //Transactions Text
                          Container(
                            margin: const EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 26.0, 0.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  CaseChange.toUpperCase(AppLocalization.of(context)!.transactions, context),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w100,
                                    color: StateContainer.of(context).curTheme.text,
                                  ),
                                ),
                              ],
                            ),
                          ), //Transactions Text End
                          //Transactions List
                          Expanded(
                            child: Stack(
                              children: <Widget>[
                                // _getUnifiedListWidget(context),
                                _getUnifiedListWidget(context),
                                //List Top Gradient End
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    height: 10.0,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [StateContainer.of(context).curTheme.background00!, StateContainer.of(context).curTheme.background!],
                                        begin: const AlignmentDirectional(0.5, 1.0),
                                        end: const AlignmentDirectional(0.5, -1.0),
                                      ),
                                    ),
                                  ),
                                ), // List Top Gradient End
                                //List Bottom Gradient
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 30.0,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [StateContainer.of(context).curTheme.background00!, StateContainer.of(context).curTheme.background!],
                                        begin: const AlignmentDirectional(0.5, -1),
                                        end: const AlignmentDirectional(0.5, 0.5),
                                      ),
                                    ),
                                  ),
                                ), //List Bottom Gradient End
                              ],
                            ),
                          ), //Transactions List End
                          //Buttons background
                          SizedBox(
                            height: 55,
                            width: MediaQuery.of(context).size.width,
                          ), //Buttons background
                        ],
                      ),

                      // Send / Receive Buttons
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton!],
                            ),
                            height: 55,
                            // width: (MediaQuery.of(context).size.width - 42).abs() / 2,
                            width: (MediaQuery.of(context).size.width - 42 - (UIUtil.drawerWidth(context))).abs() / 2,
                            margin: const EdgeInsetsDirectional.only(start: 14, top: 0.0, end: 7.0),
                            // margin: EdgeInsetsDirectional.only(start: 7.0, top: 0.0, end: 7.0),
                            child: TextButton(
                              key: const Key("home_receive_button"),
                              style: TextButton.styleFrom(
                                backgroundColor: receive != null ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.primary60,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                primary: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                                // highlightColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                                // splashColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                              ),
                              child: AutoSizeText(
                                AppLocalization.of(context)!.receive,
                                textAlign: TextAlign.center,
                                style: AppStyles.textStyleButtonPrimary(context),
                                maxLines: 1,
                                stepGranularity: 0.5,
                              ),
                              onPressed: () {
                                if (receive == null) {
                                  return;
                                }
                                Sheets.showAppHeightNineSheet(context: context, widget: receive!);
                              },
                            ),
                          ),
                          AppPopupButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildRemoteMessageCard(AlertResponseItem? alert) {
    if (alert == null) {
      return const SizedBox();
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

  Widget _buildNoSearchResultsCard(BuildContext context) {
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
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
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
                    text: AppLocalization.of(context)!.noSearchResults,
                    style: AppStyles.textStyleTransactionWelcome(context),
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

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
        txData.record_type = BlockTypes.RECEIVE;
      }
    } else {
      txData.to_address = "";
      if (txData.is_tx) {
        txData.record_type = BlockTypes.SEND;
      }
    }

    return _buildUnifiedCard(txData, _emptyAnimation, displayName!, context);
  } //Dummy Transaction Card End

  // Welcome Card
  TextSpan _getExampleHeaderSpan(BuildContext context) {
    String workingStr;
    if (StateContainer.of(context).selectedAccount == null || StateContainer.of(context).selectedAccount!.index == 0) {
      workingStr = AppLocalization.of(context)!.exampleCardIntro;
    } else {
      workingStr = AppLocalization.of(context)!.newAccountIntro;
    }
    if (!workingStr.contains("NANO")) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    // Colorize NANO
    final List<String> splitStr = workingStr.split("NANO");
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
          text: "NANO",
          style: AppStyles.textStyleTransactionWelcomePrimary(context),
        ),
        TextSpan(
          text: splitStr[1],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
      ],
    );
  }

  Widget _buildWelcomeTransactionCard(BuildContext context) {
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
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: _getExampleHeaderSpan(context),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  Widget _buildWelcomePaymentCardTwo(BuildContext context) {
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
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  text: TextSpan(
                    text: AppLocalization.of(context)!.examplePaymentExplainer,
                    style: AppStyles.textStyleTransactionWelcome(context),
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  // Loading Transaction Card
  Widget _buildLoadingTransactionCard(String type, String amount, String address, BuildContext context) {
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
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          primary: StateContainer.of(context).curTheme.text15,
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
                      opacity: _opacityAnimation.value,
                      child: Container(margin: const EdgeInsetsDirectional.only(end: 16.0), child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
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
                                opacity: _opacityAnimation.value,
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
                                    fontFamily: "NunitoSans", color: Colors.transparent, fontSize: AppFontSizes.smallest, fontWeight: FontWeight.w600),
                              ),
                              Opacity(
                                opacity: _opacityAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.primary20,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    amount,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontFamily: "NunitoSans", color: Colors.transparent, fontSize: AppFontSizes.smallest - 3, fontWeight: FontWeight.w600),
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
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: Stack(
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
                              opacity: _opacityAnimation.value,
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
  } // Loading Transaction Card End

  Widget _buildSearchbarAnimation() {
    return SearchBarAnimation(
      isOriginalAnimation: false,
      textEditingController: _searchController,
      cursorColour: StateContainer.of(context).curTheme.primary,
      isSearchBoxOnRightSide: true,
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
      // textAlignToRight: StateContainer.of(context).
      durationInMilliSeconds: 300,
      enableKeyboardFocus: true,
      enteredTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppFontSizes.small,
        color: StateContainer.of(context).curTheme.text,
        fontFamily: 'NunitoSans',
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
      hintText: _searchOpen ? AppLocalization.of(context)!.searchHint : "",
    );
  }

  //Main Card
  Widget _buildMainCard(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow!],
      ),
      margin: EdgeInsets.only(left: 14.0, right: 14.0, top: MediaQuery.of(context).size.height * 0.005),
      child: Stack(
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 80.0,
              height: mainCardHeight,
              alignment: AlignmentDirectional.topStart,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: EdgeInsetsDirectional.only(top: settingsIconMarginTop, start: 5),
                height: 50,
                width: 50,
                child: !UIUtil.isTablet(context)
                    ? TextButton(
                        key: const Key("home_settings_button"),
                        style: TextButton.styleFrom(
                          primary: StateContainer.of(context).curTheme.text15,
                          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                          // highlightColor: StateContainer.of(context).curTheme.text15,
                          // splashColor: StateContainer.of(context).curTheme.text15,
                        ),
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                        child: Stack(
                          children: [
                            Icon(
                              AppIcons.settings,
                              color: StateContainer.of(context).curTheme.text,
                              size: 24,
                            ),
                            if (!StateContainer.of(context).activeAlertIsRead)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.backgroundDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: StateContainer.of(context).curTheme.success,
                                      shape: BoxShape.circle,
                                    ),
                                    height: 11,
                                    width: 11,
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: mainCardHeight,
              child: _getBalanceWidget(),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 80,
              height: mainCardHeight,
            ),
          ]),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: mainCardHeight,
            // height: mainCardHeight == 64 ? 60 : 74,
            margin: const EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            // padding: EdgeInsets.all(0.0),
            padding: const EdgeInsets.only(bottom: 2), // covers the top of the balance text in the currency widget
            child: _buildSearchbarAnimation(),
          ),
        ],
      ),
    );
  } //Main Card

  // Get balance display
  Widget _getBalanceWidget() {
    if (StateContainer.of(context).wallet == null || StateContainer.of(context).wallet!.loading!) {
      // Placeholder for balance text
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_priceConversion == PriceConversion.CURRENCY)
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                const Text(
                  "1234567",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "NunitoSans", fontSize: AppFontSizes.small, fontWeight: FontWeight.w600, color: Colors.transparent),
                ),
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.text20,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      "1234567",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: "NunitoSans", fontSize: AppFontSizes.small - 3, fontWeight: FontWeight.w600, color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
          Container(
            constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width - 225 - UIUtil.tabletDrawerWidth(context)).abs()),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                const AutoSizeText(
                  "1234567",
                  style: TextStyle(fontFamily: "NunitoSans", fontSize: AppFontSizes.largestc, fontWeight: FontWeight.w900, color: Colors.transparent),
                  maxLines: 1,
                  stepGranularity: 0.1,
                  minFontSize: 1,
                ),
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.primary60,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const AutoSizeText(
                      "1234567",
                      style: TextStyle(fontFamily: "NunitoSans", fontSize: AppFontSizes.largestc - 8, fontWeight: FontWeight.w900, color: Colors.transparent),
                      maxLines: 1,
                      stepGranularity: 0.1,
                      minFontSize: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_priceConversion == PriceConversion.CURRENCY)
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                const Text(
                  "1234567",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "NunitoSans", fontSize: AppFontSizes.small, fontWeight: FontWeight.w600, color: Colors.transparent),
                ),
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.text20,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      "1234567",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: "NunitoSans", fontSize: AppFontSizes.small - 3, fontWeight: FontWeight.w600, color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
        ],
      );
    }
    // Balance texts
    return GestureDetector(
      onTap: () {
        if (_priceConversion == PriceConversion.CURRENCY) {
          // Hide prices
          setState(() {
            _priceConversion = PriceConversion.NONE;
            mainCardHeight = 64;
            settingsIconMarginTop = 7;
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.NONE);
        } else if (_priceConversion == PriceConversion.NONE) {
          // Cyclce to hidden
          setState(() {
            _priceConversion = PriceConversion.HIDDEN;
            mainCardHeight = 64;
            settingsIconMarginTop = 7;
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.HIDDEN);
        } else if (_priceConversion == PriceConversion.HIDDEN) {
          // Cycle to CURRENCY price
          setState(() {
            mainCardHeight = 80;
            settingsIconMarginTop = 15;
          });
          Future.delayed(const Duration(milliseconds: 150), () {
            setState(() {
              _priceConversion = PriceConversion.CURRENCY;
            });
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.CURRENCY);
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: (MediaQuery.of(context).size.width - 190 - UIUtil.tabletDrawerWidth(context)).abs(),
        color: Colors.transparent,
        child: _priceConversion == PriceConversion.HIDDEN
            ?
            // Nano logo
            Center(child: Icon(AppIcons.nanologo, size: 32, color: StateContainer.of(context).curTheme.primary))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_priceConversion == PriceConversion.CURRENCY)
                    Text(
                        StateContainer.of(context)
                            .wallet!
                            .getLocalCurrencyBalance(context, StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale),
                        textAlign: TextAlign.center,
                        style: AppStyles.textStyleCurrencyAlt(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width - 205).abs()),
                        child: AutoSizeText.rich(
                          TextSpan(
                            children: [
                              if (_priceConversion == PriceConversion.CURRENCY)
                                displayCurrencySymbol(context, AppStyles.textStyleCurrency(context))
                              else
                                displayCurrencySymbol(context, AppStyles.textStyleCurrencySmaller(context)),
                              // Main balance text
                              TextSpan(
                                text: getRawAsThemeAwareFormattedAmount(context, StateContainer.of(context).wallet?.accountBalance.toString()),
                                style: _priceConversion == PriceConversion.CURRENCY
                                    ? AppStyles.textStyleCurrency(context)
                                    : AppStyles.textStyleCurrencySmaller(
                                        context,
                                      ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          style: TextStyle(fontSize: _priceConversion == PriceConversion.CURRENCY ? 28 : 22),
                          stepGranularity: 0.1,
                          minFontSize: 1,
                          maxFontSize: _priceConversion == PriceConversion.CURRENCY ? 28 : 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                ],
              ),
      ),
    );
  }

  // TX / Card Action functions:
  static Future<void> resendRequest(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.REQUEST, onPoppedCallback: () => animationOpen = false);

    bool sendFailed = false;

    // send the request again:
    final String privKey = NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!);
    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid = NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData requestTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: true,
      is_memo: false,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(requestTXData);

    try {
      // encrypt the memo if it's not empty:
      String? encryptedMemo;
      if (txDetails.memo != null && txDetails.memo!.isNotEmpty) {
        encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      }
      await sl.get<AccountService>().requestPayment(
          txDetails.to_address, txDetails.amount_raw, StateContainer.of(context).wallet!.address, signature, nonceHex, encryptedMemo, localUuid);
    } catch (error) {
      sl.get<Logger>().v("Error encrypting memo: $error");
      sendFailed = true;
    }

    // if the memo send failed delete the object:
    if (sendFailed) {
      sl.get<Logger>().v("request send failed, deleting TXData object");
      // remove failed txdata from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // sleep for 2 seconds so the animation finishes otherwise the UX is weird:
      await Future.delayed(const Duration(seconds: 2));
      // show error:
      UIUtil.showSnackbar(AppLocalization.of(context)!.requestSendError, context, durationMs: 5000);
    } else {
      // delete the old request by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(AppLocalization.of(context)!.requestSentButNotReceived, context, durationMs: 5000);
    }
    await StateContainer.of(context).updateSolids();
    await StateContainer.of(context).updateTXMemos();
    await StateContainer.of(context).updateUnified(false);

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> resendMemo(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.SEND_MESSAGE, onPoppedCallback: () => animationOpen = false);

    bool memoSendFailed = false;

    // send the memo again:
    final String privKey = NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!);
    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid = NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData memoTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: false,
      is_memo: true,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(memoTXData);

    try {
      // encrypt the memo:
      final String encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      await sl.get<AccountService>().sendTXMemo(txDetails.to_address!, StateContainer.of(context).wallet!.address!, txDetails.amount_raw, signature, nonceHex,
          encryptedMemo, txDetails.block, localUuid);
    } catch (e) {
      memoSendFailed = true;
    }

    // if the memo send failed delete the object:
    if (memoSendFailed) {
      sl.get<Logger>().v("memo send failed, deleting TXData object");
      // remove from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // sleep for 2 seconds so the animation finishes otherwise the UX is weird:
      await Future.delayed(const Duration(seconds: 2));
      // show error:
      UIUtil.showSnackbar(AppLocalization.of(context)!.sendMemoError, context, durationMs: 5000);
    } else {
      // delete the old memo by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(AppLocalization.of(context)!.memoSentButNotReceived, context, durationMs: 5000);
      await StateContainer.of(context).updateTXMemos();
    }

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> resendMessage(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.SEND_MESSAGE, onPoppedCallback: () => animationOpen = false);

    bool sendFailed = false;

    // send the message again:
    final String privKey = NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount!.index!);
    // get epoch time as hex:
    final int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String nonceHex = secondsSinceEpoch.toRadixString(16);
    final String signature = NanoSignatures.signBlock(nonceHex, privKey);

    // check validity locally:
    final String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet!.address!);
    final bool isValid = NanoSignatures.validateSig(nonceHex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    const Uuid uuid = Uuid();
    final String localUuid = "LOCAL:${uuid.v4()}";
    final TXData messageTXData = TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: localUuid,
      block: txDetails.block,
      is_acknowledged: false,
      is_fulfilled: false,
      is_request: false,
      is_memo: false,
      is_message: true,
      // request_time: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      request_time: txDetails.request_time,
      memo: txDetails.memo, // store unencrypted memo
      height: txDetails.height,
    );
    // add it to the database:
    await sl.get<DBHelper>().addTXData(messageTXData);

    try {
      // encrypt the memo if it's not empty:
      String? encryptedMemo;
      if (txDetails.memo != null && txDetails.memo!.isNotEmpty) {
        encryptedMemo = Box.encrypt(txDetails.memo!, txDetails.to_address!, privKey);
      }
      await sl
          .get<AccountService>()
          .sendTXMessage(txDetails.to_address!, StateContainer.of(context).wallet!.address!, signature, nonceHex, encryptedMemo!, localUuid);
    } catch (error) {
      sl.get<Logger>().v("Error encrypting memo: $error");
      sendFailed = true;
    }

    // if the memo send failed delete the object:
    if (sendFailed) {
      sl.get<Logger>().v("request send failed, deleting TXData object");
      // remove failed txdata from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      // sleep for 2 seconds so the animation finishes otherwise the UX is weird:
      await Future.delayed(const Duration(seconds: 2));
      // show error:
      UIUtil.showSnackbar(AppLocalization.of(context)!.sendMemoError, context, durationMs: 5000);
    } else {
      // delete the old request by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(AppLocalization.of(context)!.memoSentButNotReceived, context, durationMs: 5000);
    }
    await StateContainer.of(context).updateSolids();
    await StateContainer.of(context).updateUnified(false);

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> payTX(BuildContext context, TXData txDetails) async {
    String? address;
    if (txDetails.is_request || txDetails.is_memo) {
      if (txDetails.to_address == StateContainer.of(context).wallet!.address) {
        address = txDetails.from_address;
      } else {
        address = txDetails.to_address;
      }
    } else {
      // address = item.account;
      address = txDetails.from_address;
    }
    // See if a contact
    final User? user = await sl.get<DBHelper>().getUserOrContactWithAddress(address!);
    String? quickSendAmount = txDetails.amount_raw;
    // a bit of a hack since send sheet doesn't have a way to tell if we're in nyano mode on creation:
    if (StateContainer.of(context).nyanoMode) {
      quickSendAmount = "${quickSendAmount!}000000";
    }

    // Go to send with address
    await Sheets.showAppHeightNineSheet(
        context: context,
        widget: SendSheet(
          localCurrency: StateContainer.of(context).curCurrency,
          address: address,
          quickSendAmount: quickSendAmount,
          user: user,
        ));
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

    if (txDetails.record_type == RecordTypes.GIFT_ACK || txDetails.record_type == RecordTypes.GIFT_OPEN || txDetails.record_type == RecordTypes.GIFT_LOAD) {
      isGift = true;
    }

    // set icon color:
    if (txDetails.is_message || txDetails.is_request) {
      if (txDetails.is_request) {
        if (txDetails.isRecipient(walletAddress)) {
          itemText = AppLocalization.of(context)!.request;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = AppLocalization.of(context)!.asked;
          icon = AppIcons.call_received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        }
      } else if (txDetails.is_message) {
        if (txDetails.isRecipient(walletAddress)) {
          itemText = AppLocalization.of(context)!.received;
          icon = AppIcons.call_received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          itemText = AppLocalization.of(context)!.sent;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.text60;
        }
      }
    } else if (txDetails.is_tx) {
      if (isGift) {
        if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
          itemText = AppLocalization.of(context)!.loaded;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else if (txDetails.record_type == RecordTypes.GIFT_OPEN) {
          itemText = AppLocalization.of(context)!.opened;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          throw Exception("something went wrong with gift type");
        }
      } else {
        if (txDetails.record_type == BlockTypes.SEND) {
          itemText = AppLocalization.of(context)!.sent;
          icon = AppIcons.sent;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = AppLocalization.of(context)!.received;
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
      iconColor = StateContainer.of(context).curTheme.error60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.error60!.withOpacity(0.2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if (txDetails.is_fulfilled && (txDetails.is_request || txDetails.is_message)) {
      iconColor = StateContainer.of(context).curTheme.success60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.success60!.withOpacity(0.2),
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if (!txDetails.is_acknowledged && (txDetails.is_request || txDetails.is_message)) {
      iconColor = StateContainer.of(context).curTheme.error60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.error60!.withOpacity(0.2),
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
        transactionState = TransactionStateOptions.NOT_SENT;
      }
    }

    if (txDetails.is_tx) {
      // if ((item.confirmed != null && !item.confirmed!) || (currentConfHeight > -1 && item.height != null && item.height! > currentConfHeight)) {
      //   transactionState = TransactionStateOptions.UNCONFIRMED;
      // }
      if ((!txDetails.is_fulfilled) || (currentConfHeight > -1 && txDetails.height != null && txDetails.height! > currentConfHeight)) {
        transactionState = TransactionStateOptions.UNCONFIRMED;
      }
    }

    final List<Widget> slideActions = [];
    String? label;
    if (txDetails.is_tx) {
      label = AppLocalization.of(context)!.send;
    } else {
      if (txDetails.is_request && txDetails.isRecipient(walletAddress)) {
        label = AppLocalization.of(context)!.pay;
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
            // sleep for a bit to give the ripple effect time to finish
            await Future.delayed(const Duration(milliseconds: 250));
            await payTX(context, txDetails);
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
          label: AppLocalization.of(context)!.reply,
          onPressed: (BuildContext context) async {
            // sleep for a bit to give the ripple effect time to finish
            await Future.delayed(const Duration(milliseconds: 250));
            await payTX(context, txDetails);
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
            label: AppLocalization.of(context)!.retry,
            onPressed: (BuildContext context) async {
              // sleep for a bit to give the ripple effect time to finish
              await Future.delayed(const Duration(milliseconds: 250));
              await resendRequest(context, txDetails);
              await Slidable.of(context)!.close();
            }));
      } else if (txDetails.is_memo) {
        slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.background!,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: AppLocalization.of(context)!.retry,
            onPressed: (BuildContext context) async {
              // sleep for a bit to give the ripple effect time to finish
              await Future.delayed(const Duration(milliseconds: 250));
              await resendMemo(context, txDetails);
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
            label: AppLocalization.of(context)!.retry,
            onPressed: (BuildContext context) async {
              // sleep for a bit to give the ripple effect time to finish
              await Future.delayed(const Duration(milliseconds: 250));
              await resendMessage(context, txDetails);
              await Slidable.of(context)!.close();
            }));
      }
    }

    if (txDetails.is_request || txDetails.is_message) {
      slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: AppLocalization.of(context)!.delete,
          onPressed: (BuildContext context) async {
            // sleep for a bit to give the ripple effect time to finish
            await Future.delayed(const Duration(milliseconds: 250));
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
      child: _SizeTransitionNoClip(
        sizeFactor: animation,
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: [
            Container(
              margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.backgroundDark,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [setShadow!],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: StateContainer.of(context).curTheme.text15,
                  backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                onPressed: () {
                  Sheets.showAppHeightEightSheet(context: context, widget: PaymentDetailsSheet(txDetails: txDetails), animationDurationMs: 175);
                },
                child: Center(
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
                            children: [
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
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (txDetails.memo != null)
                          Expanded(
                            // constraints: BoxConstraints(maxWidth: 105),
                            // width: MediaQuery.of(context).size.width / 4.3,
                            // constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 4),
                            // padding: EdgeInsets.only(left: 10, right: 10),
                            // child: Text(
                            //   txDetails.memo,
                            //   textAlign: TextAlign.start,
                            //   style: AppStyles.textStyleTransactionMemo(context),
                            //   maxLines: 16,
                            //   overflow: TextOverflow.visible,
                            // ),
                            child: SubstringHighlight(
                                caseSensitive: false,
                                maxLines: 16,
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
                                  text: DateFormat(CARD_TIME_FORMAT).format(DateTime.fromMillisecondsSinceEpoch(txDetails.request_time! * 1000)),
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
                  color: StateContainer.of(context).curTheme.text,
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

    // if (histItem.type == BlockTypes.SEND) {
    //   converted.to_address ??= histItem.account;
    // } else if (histItem.type == BlockTypes.RECEIVE) {
    //   converted.from_address ??= histItem.account;
    // }

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
    converted.sub_type ??= histItem.type; // transaction subtype

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
    if (index == 0 && StateContainer.of(context).activeAlert != null) {
      return _buildRemoteMessageCard(StateContainer.of(context).activeAlert);
    }
    int localIndex = index;
    if (StateContainer.of(context).activeAlert != null) {
      localIndex -= 1;
    }

    final dynamic indexedItem = _unifiedListMap[StateContainer.of(context).wallet!.address]![localIndex];
    final TXData txDetails =
        indexedItem is TXData ? indexedItem : convertHistItemToTXData(indexedItem as AccountHistoryResponseItem, txDetails: _txDetailsMap[indexedItem.hash]);
    final bool isRecipient = txDetails.isRecipient(StateContainer.of(context).wallet!.address);
    String displayName = txDetails.getShortestString(isRecipient) ?? "";

    // check if there's a username:
    final String account = txDetails.getAccount(isRecipient);
    for (User user in _users) {
      if (user.address == account.replaceAll("xrb_", "nano_")) {
        displayName = user.getDisplayName()!;
        break;
      }
    }

    return _buildUnifiedCard(txDetails, animation, displayName, context);
  }

  // Return widget for list
  Widget _getUnifiedListWidget(BuildContext context) {
    if (_noSearchResults) {
      return ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          children: <Widget>[
            _buildNoSearchResultsCard(context),
          ],
        ),
      );
    }

    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet!.historyLoading == false) {
      // Setup history list
      if (!_historyListMap.containsKey("${StateContainer.of(context).wallet!.address}")) {
        setState(() {
          _historyListMap.putIfAbsent(StateContainer.of(context).wallet!.address, () => StateContainer.of(context).wallet!.history);
        });
      }
      // Setup payments list
      if (!_solidsListMap.containsKey("${StateContainer.of(context).wallet!.address}")) {
        setState(() {
          _solidsListMap.putIfAbsent(StateContainer.of(context).wallet!.address, () => StateContainer.of(context).wallet!.solids);
        });
      }
      // Setup unified list
      if (!_unifiedListKeyMap.containsKey("${StateContainer.of(context).wallet!.address}")) {
        _unifiedListKeyMap.putIfAbsent("${StateContainer.of(context).wallet!.address}", () => GlobalKey<AnimatedListState>());
        setState(() {
          _unifiedListMap.putIfAbsent(
            StateContainer.of(context).wallet!.address,
            () => ListModel<dynamic>(
              listKey: _unifiedListKeyMap["${StateContainer.of(context).wallet!.address}"]!,
              initialItems: StateContainer.of(context).wallet!.unified,
            ),
          );
        });
      }

      if (StateContainer.of(context).wallet!.unifiedLoading! ||
          (_unifiedListMap[StateContainer.of(context).wallet!.address] != null && _unifiedListMap[StateContainer.of(context).wallet!.address]!.length == 0)) {
        generateUnifiedList(fastUpdate: true);
      }
    }

    if (StateContainer.of(context).wallet == null || StateContainer.of(context).wallet!.loading! || StateContainer.of(context).wallet!.unifiedLoading!) {
      // Loading Animation
      return ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              _buildLoadingTransactionCard("Sent", "10244000", "123456789121234", context),
              _buildLoadingTransactionCard("Received", "100,00000", "@bbedwards1234", context),
              _buildLoadingTransactionCard("Sent", "14500000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Sent", "12,51200", "123456789121234", context),
              _buildLoadingTransactionCard("Received", "1,45300", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "100,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Received", "24,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard("Sent", "1,00000", "123456789121234", context),
            ],
          ));
    } else if (StateContainer.of(context).wallet!.history!.isEmpty && StateContainer.of(context).wallet!.solids!.isEmpty) {
      _disposeAnimation();
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
            controller: _scrollController,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              // REMOTE MESSAGE CARD
              if (StateContainer.of(context).activeAlert != null) _buildRemoteMessageCard(StateContainer.of(context).activeAlert),
              _buildWelcomeTransactionCard(context),
              _buildDummyTXCard(
                context,
                amount_raw: "30000000000000000000000000000000",
                displayName: AppLocalization.of(context)!.exampleRecRecipient,
                memo: AppLocalization.of(context)!.exampleRecRecipientMessage,
                is_recipient: true,
                is_tx: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60),
              ),
              _buildDummyTXCard(
                context,
                amount_raw: "50000000000000000000000000000000",
                displayName: AppLocalization.of(context)!.examplePayRecipient,
                memo: AppLocalization.of(context)!.examplePayRecipientMessage,
                is_recipient: false,
                is_tx: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 1),
              ),
              _buildWelcomePaymentCardTwo(context),

              _buildDummyTXCard(
                context,
                amount_raw: "10000000000000000000000000000000",
                displayName: AppLocalization.of(context)!.examplePaymentTo,
                memo: AppLocalization.of(context)!.examplePaymentFulfilledMemo,
                is_recipient: false,
                is_request: true,
                is_fulfilled: true,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 5),
              ),
              _buildDummyTXCard(
                context,
                amount_raw: "2000000000000000000000000000000000",
                displayName: AppLocalization.of(context)!.examplePaymentFrom,
                memo: AppLocalization.of(context)!.examplePaymentReceivableMemo,
                is_recipient: true,
                is_request: true,
                is_fulfilled: false,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 7),
              ),
              _buildDummyTXCard(
                context,
                displayName: AppLocalization.of(context)!.examplePaymentTo,
                memo: AppLocalization.of(context)!.examplePaymentMessage,
                is_recipient: true,
                is_message: true,
                is_fulfilled: false,
                timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - (60 * 60 * 24 * 9),
              ),
            ],
          ),
        ),
      );
    } else {
      _disposeAnimation();
    }

    if (StateContainer.of(context).activeAlert != null) {
      // Setup unified list
      if (!_unifiedListKeyMap.containsKey("${StateContainer.of(context).wallet!.address}alert")) {
        _unifiedListKeyMap.putIfAbsent("${StateContainer.of(context).wallet!.address}alert", () => GlobalKey<AnimatedListState>());
        setState(() {
          _isRefreshing = false;
          _unifiedListMap.putIfAbsent(
            StateContainer.of(context).wallet!.address,
            () => ListModel<dynamic>(
              listKey: _unifiedListKeyMap["${StateContainer.of(context).wallet!.address}alert"]!,
              initialItems: StateContainer.of(context).wallet!.unified,
            ),
          );
        });
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
          child: AnimatedList(
            controller: _scrollController,
            key: _unifiedListKeyMap["${StateContainer.of(context).wallet!.address}alert"],
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            initialItemCount: _unifiedListMap[StateContainer.of(context).wallet!.address]!.length + 1,
            itemBuilder: _buildUnifiedItem,
          ),
        ),
      );
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
        child: AnimatedList(
          // physics: BouncingScrollPhysics(), // iOS
          controller: _scrollController,
          key: _unifiedListKeyMap[StateContainer.of(context).wallet!.address!],
          padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          initialItemCount: _unifiedListMap[StateContainer.of(context).wallet!.address]!.length,
          itemBuilder: _buildUnifiedItem,
        ),
      ),
    );
  }
}

/// This is used so that the elevation of the container is kept and the
/// drop shadow is not clipped.
///
class _SizeTransitionNoClip extends AnimatedWidget {
  const _SizeTransitionNoClip({required Animation<double> sizeFactor, this.child}) : super(listenable: sizeFactor);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      widthFactor: null,
      heightFactor: (listenable as Animation<double>).value,
      child: child,
    );
  }
}

class PaymentDetailsSheet extends StatefulWidget {
  const PaymentDetailsSheet({this.txDetails}) : super();
  final TXData? txDetails;

  @override
  _PaymentDetailsSheetState createState() => _PaymentDetailsSheetState();
}

class _PaymentDetailsSheetState extends State<PaymentDetailsSheet> {
  // Current state references
  bool _linkCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _linkCopiedTimer;
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
    const bool isGift = false;

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
                // A row for View Details button
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context)!.viewDetails, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () async {
                      await UIUtil.showBlockExplorerWebview(context, txDetails.block);
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
                          _addressCopied ? AppLocalization.of(context)!.addressCopied : AppLocalization.of(context)!.copyAddress,
                          Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
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
                          !txDetails.is_fulfilled ? AppLocalization.of(context)!.markAsPaid : AppLocalization.of(context)!.markAsUnpaid,
                          Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () async {
                        // update the tx in the db:
                        if (txDetails.is_fulfilled) {
                          await sl.get<DBHelper>().changeTXFulfillmentStatus(txDetails.uuid, false);
                        } else {
                          await sl.get<DBHelper>().changeTXFulfillmentStatus(txDetails.uuid, true);
                        }
                        // setState(() {});
                        await StateContainer.of(context).updateSolids();
                        await StateContainer.of(context).updateUnified(true);
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),

                // pay this request button:
                if (isUnfulfilledPayableRequest)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context)!.payRequest, Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                        _AppHomePageState.payTX(context, txDetails);
                      }),
                    ],
                  ),

                // block this user from sending you requests:
                if (txDetails.is_request && StateContainer.of(context).wallet!.address != txDetails.from_address)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context)!.blockUser, Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
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
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context)!.sendRequestAgain, Dimens.BUTTON_TOP_EXCEPTION_DIMENS,
                          onPressed: () async {
                        // send the request again:
                        _AppHomePageState.resendRequest(context, txDetails);
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
                          AppLocalization.of(context)!.resendMemo,
                          Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () async {
                        _AppHomePageState.resendMemo(context, txDetails);
                      }),
                    ],
                  ),
                // delete this request button
                if (txDetails.is_request)
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context)!.deleteRequest, Dimens.BUTTON_TOP_EXCEPTION_DIMENS,
                          onPressed: () {
                        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
                        sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid!);
                        StateContainer.of(context).updateSolids();
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
                          _seedCopied ? AppLocalization.of(context)!.seedCopied : AppLocalization.of(context)!.copySeed,
                          Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                        Clipboard.setData(ClipboardData(text: walletSeed));
                        setState(() {
                          // Set copied style
                          _seedCopied = true;
                        });
                        if (_seedCopiedTimer != null) {
                          _seedCopiedTimer!.cancel();
                        }
                        _seedCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                          setState(() {
                            _seedCopied = false;
                          });
                        });
                      }),
                    ],
                  ),
                if (isGiftLoad)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          // copy link button
                          _linkCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY_OUTLINE,
                          _linkCopied ? AppLocalization.of(context)!.linkCopied : AppLocalization.of(context)!.copyLink,
                          Dimens.BUTTON_COMPACT_LEFT_DIMENS, onPressed: () {
                        Clipboard.setData(ClipboardData(text: sharableLink));
                        setState(() {
                          // Set copied style
                          _linkCopied = true;
                        });
                        if (_linkCopiedTimer != null) {
                          _linkCopiedTimer!.cancel();
                        }
                        _linkCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                          setState(() {
                            _linkCopied = false;
                          });
                        });
                      }),
                      AppButton.buildAppButton(
                          context,
                          // share link button
                          AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context)!.shareLink,
                          Dimens.BUTTON_COMPACT_RIGHT_DIMENS, onPressed: () {
                        Share.share(sharableLink!);
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
