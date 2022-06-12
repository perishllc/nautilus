import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/bus/blocked_modified_event.dart';
import 'package:nautilus_wallet_flutter/bus/payments_home_event.dart';
import 'package:nautilus_wallet_flutter/bus/tx_update_event.dart';
import 'package:nautilus_wallet_flutter/bus/unified_home_event.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/fcm_message_event.dart';
import 'package:nautilus_wallet_flutter/network/model/record_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:nautilus_wallet_flutter/network/model/status_types.dart';
import 'package:nautilus_wallet_flutter/ui/popup_button.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/list_model.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/network/model/block_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/ui/contacts/add_contact.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/settings_drawer.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/users/add_blocked.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/reactive_refresh.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/transaction_state_tag.dart';
import 'package:nautilus_wallet_flutter/util/box.dart';
import 'package:nautilus_wallet_flutter/util/manta.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:quiver/strings.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AppHomePage extends StatefulWidget {
  PriceConversion priceConversion;

  AppHomePage({this.priceConversion}) : super();

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Logger log = sl.get<Logger>();

  // Controller for placeholder card animations
  AnimationController _placeholderCardAnimationController;
  Animation<double> _opacityAnimation;
  bool _animationDisposed;

  // Manta
  bool mantaAnimationOpen;

  // Receive card instance
  ReceiveSheet receive;
  // Request card instance
  // RequestSheet request;

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  // final Map<String, GlobalKey<AnimatedListState>> _historyListKeyMap = Map();
  // final Map<String, ListModel<AccountHistoryResponseItem>> _historyListMap = Map();
  // final Map<String, ListModel<AccountHistoryResponseItem>> _historyListMap = Map();
  final Map<String, List<AccountHistoryResponseItem>> _historyListMap = Map();

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  // final Map<String, GlobalKey<AnimatedListState>> _requestsListKeyMap = Map();
  // final Map<String, ListModel<TXData>> _paymentsListMap = Map();
  final Map<String, List<TXData>> _solidsListMap = Map();

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _unifiedListKeyMap = Map();
  final Map<String, ListModel<dynamic>> _unifiedListMap = Map();

  // used to associate memos with blocks so we don't have search on every re-render:
  final Map<String, TXData> _txDetailsMap = Map();

  // search bar text controller:
  TextEditingController _searchController = TextEditingController();
  bool _searchOpen = false;
  bool _noSearchResults = false;

  // List of contacts (Store it so we only have to query the DB once for transaction cards)
  List<User> _contacts = [];
  List<User> _blocked = [];
  List<User> _users = [];
  List<TXData> _txData = [];
  List<TXData> _txRecords = [];

  // infinite scroll:
  ScrollController _scrollController;

  // Price conversion state (BTC, NANO, NONE)
  PriceConversion _priceConversion;

  bool _isRefreshing = false;
  bool _lockDisabled = false; // whether we should avoid locking the app
  bool _lockTriggered = false;

  // Main card height
  double mainCardHeight;
  double settingsIconMarginTop = 5;
  // FCM instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Animation for swiping to send
  double _fanimationPosition;
  bool releaseAnimation = false;

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
    List<Account> accounts = await sl.get<DBHelper>().getAccounts(await StateContainer.of(context).getSeed());
    for (Account a in accounts) {
      if (a.address == account && a.address != StateContainer.of(context).wallet.address) {
        await sl.get<DBHelper>().changeAccount(a);
        EventTaxiImpl.singleton().fire(AccountChangedEvent(account: a, delayPop: true));
      }
    }
  }

  /// Notification includes which account its for, automatically switch to it if they're entering app from notification
  Future<void> _chooseCorrectAccountFromNotification(dynamic message) async {
    if (message.containsKey("account")) {
      String account = message['account'];
      if (account != null) {
        await _switchToAccount(account);
      }
    }
  }

  Future<void> _processPaymentRequestNotification(dynamic data) async {
    log.d("Processing payment request notification");
    if (data.containsKey("payment_request")) {
      String amount_raw = data['amount_raw'];
      String requesting_account = data['requesting_account'];

      // Remove any other screens from stack
      // Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));

      // Go to send with address
      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(
              localCurrency: StateContainer.of(context).curCurrency,
              address: requesting_account,
              quickSendAmount: amount_raw,
            ));
      });
    }
  }

  void getNotificationPermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
      if (settings.alert == AppleNotificationSetting.enabled ||
          settings.badge == AppleNotificationSetting.enabled ||
          settings.sound == AppleNotificationSetting.enabled ||
          settings.authorizationStatus == AuthorizationStatus.authorized) {
        sl.get<SharedPrefsUtil>().getNotificationsSet().then((beenSet) {
          if (!beenSet) {
            sl.get<SharedPrefsUtil>().setNotificationsOn(true);
          }
        });
        _firebaseMessaging.getToken().then((String token) {
          if (token != null) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
          }
        });
      } else {
        sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((_) {
          _firebaseMessaging.getToken().then((String token) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
          });
        });
      }
      String token = await _firebaseMessaging.getToken();
      if (token != null) {
        EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
      }
    } catch (e) {
      sl.get<SharedPrefsUtil>().setNotificationsOn(false);
    }
  }

  Future<void> _branchGiftDialog(String seed, String memo, String amountRaw, String senderAddress) async {
    String supposedAmount = getRawAsThemeAwareAmount(context, amountRaw);

    String userOrSendAddress;

    // change address to username if it exists:
    dynamic user = await sl.get<DBHelper>().getUserOrContactWithAddress(senderAddress);
    if (user != null) {
      userOrSendAddress = user.getDisplayName();
    } else {
      userOrSendAddress = senderAddress;
    }

    // check if there's actually any nano to claim:
    BigInt balance = await AppTransferOverviewSheet().getGiftCardBalance(context, seed);
    try {
      if (balance != BigInt.zero) {
        String actualAmount = getRawAsThemeAwareAmount(context, balance.toString());
        // show dialog with option to refund to sender:
        switch (await showDialog<int>(
            barrierDismissible: false,
            context: context,
            barrierColor: StateContainer.of(context).curTheme.barrier,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalization.of(context).giftAlert,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(AppLocalization.of(context).importGift + "\n\n", style: AppStyles.textStyleParagraph(context)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: AppLocalization.of(context).giftFrom + ": ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: userOrSendAddress + "\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                    (memo != null && memo.isNotEmpty)
                        ? Text(
                            AppLocalization.of(context).giftMessage + ": " + memo + "\n",
                            style: AppStyles.textStyleParagraph(context),
                          )
                        : SizedBox(),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: AppLocalization.of(context).giftAmount + ": ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          displayCurrencyAmount(
                              context,
                              TextStyle(
                                color: StateContainer.of(context).curTheme.primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'NunitoSans',
                                decoration: TextDecoration.lineThrough,
                              ),
                              includeSymbol: true),
                          TextSpan(
                            text: actualAmount,
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  Row(children: [
                    AppSimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context, 0);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          AppLocalization.of(context).refund,
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
                          AppLocalization.of(context).receive,
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
                          AppLocalization.of(context).close,
                          style: AppStyles.textStyleDialogOptions(context),
                        ),
                      ),
                    )
                  ]),
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
        // show alert that the gift is empty:
        await showDialog<bool>(
            context: context,
            barrierColor: StateContainer.of(context).curTheme.barrier,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalization.of(context).giftAlertEmpty,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(AppLocalization.of(context).importGiftEmpty + "\n\n", style: AppStyles.textStyleParagraph(context)),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: AppLocalization.of(context).giftFrom + ": ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          TextSpan(
                            text: userOrSendAddress + "\n",
                            style: AppStyles.textStyleParagraphPrimary(context),
                          ),
                        ],
                      ),
                    ),
                    (memo != null && memo.isNotEmpty)
                        ? Text(
                            AppLocalization.of(context).giftMessage + ": " + memo + "\n",
                            style: AppStyles.textStyleParagraph(context),
                          )
                        : SizedBox(),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: AppLocalization.of(context).giftAmount + ": ",
                        style: AppStyles.textStyleParagraph(context),
                        children: [
                          displayCurrencyAmount(
                              context,
                              TextStyle(
                                color: StateContainer.of(context).curTheme.primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'NunitoSans',
                                decoration: TextDecoration.lineThrough,
                              ),
                              includeSymbol: true),
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
    } catch (e) {
      print("Error processing gift card: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    this.mantaAnimationOpen = false;
    WidgetsBinding.instance.addObserver(this);
    if (widget.priceConversion != null) {
      _priceConversion = widget.priceConversion;
    } else {
      _priceConversion = PriceConversion.BTC;
    }
    // Main Card Size
    if (_priceConversion == PriceConversion.BTC) {
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
    _updateContacts();
    _updateBlocked();
    _updateUsers();
    _updateTXData();
    // infinite scroll:
    _scrollController = ScrollController()..addListener(_scrollListener);
    // Setup placeholder animation and start
    _animationDisposed = false;
    _placeholderCardAnimationController = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _placeholderCardAnimationController.addListener(_animationControllerListener);
    _opacityAnimation = new Tween(begin: 1.0, end: 0.4).animate(
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
      } catch (e) {}
    });
    // Setup notification
    getNotificationPermissions();

    // ask to rate the app:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (mounted && rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: AppLocalization.of(context).rateTheApp,
          message: AppLocalization.of(context).rateTheAppDescription,
          rateButton: AppLocalization.of(context).rate,
          noButton: AppLocalization.of(context).noThanks,
          laterButton: AppLocalization.of(context).maybeLater,
          listener: (button) {
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
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String runningVersion = packageInfo.version;
      String lastVersion = await sl.get<SharedPrefsUtil>().getAppVersion();
      if (runningVersion != lastVersion) {
        await sl.get<SharedPrefsUtil>().setAppVersion(runningVersion);
        await AppDialogs.showChangeLog(context);

        // also force a username update:
        StateContainer.of(context).checkAndCacheNapiDatabases(true);
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
        return null;
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
    bool contactAdded = await sl.get<SharedPrefsUtil>().getFirstContactAdded();
    if (!contactAdded) {
      bool addressExists = await sl.get<DBHelper>().contactExistsWithAddress("nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579");
      if (addressExists) {
        return;
      }
      bool nameExists = await sl.get<DBHelper>().contactExistsWithName("NautilusDonations");
      if (nameExists) {
        return;
      }
      await sl.get<SharedPrefsUtil>().setFirstContactAdded(true);
      User c = User(nickname: "NautilusDonations", address: "nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579");
      await sl.get<DBHelper>().saveContact(c);
    }
  }

  void _updateContacts() {
    sl.get<DBHelper>().getContacts().then((contacts) {
      setState(() {
        _contacts = contacts;
      });
    });
  }

  void _updateBlocked() {
    sl.get<DBHelper>().getBlocked().then((blocked) {
      setState(() {
        _blocked = blocked;
      });
    });
  }

  void _updateUsers() {
    sl.get<DBHelper>().getUsers().then((users) {
      setState(() {
        _users = users;
      });
    });
  }

  void _updateTXData() {
    sl.get<DBHelper>().getTXData().then((txData) {
      setState(() {
        _txData = txData;
      });
    });
  }

  void _updateTXDetailsMap(String account) {
    sl.get<DBHelper>().getAccountSpecificTXData(account).then((data) {
      setState(() {
        _txRecords = data;
        _txDetailsMap.clear();
        for (var tx in _txRecords) {
          if (tx.isSolid() && (isEmpty(tx.block) || isEmpty(tx.link))) {
            // set to the last block:
            String lastBlockHash = StateContainer.of(context).wallet.history.length > 0 ? StateContainer.of(context).wallet.history[0].hash : null;
            if (isEmpty(tx.block) && StateContainer.of(context).wallet.address == tx.from_address) {
              tx.block = lastBlockHash;
            }
            if (isEmpty(tx.link) && StateContainer.of(context).wallet.address == tx.to_address) {
              tx.link = lastBlockHash;
            }
            // save to db:
            sl.get<DBHelper>().replaceTXDataByUUID(tx);
          }
          // if unacknowledged, we're the recipient, and not local, ACK it:
          if (tx.is_acknowledged == false && tx.to_address == StateContainer.of(context).wallet.address && !tx.uuid.contains("LOCAL")) {
            print("ACKNOWLEDGING TX_DATA: ${tx.uuid}");
            sl.get<AccountService>().requestACK(tx.uuid, tx.from_address, tx.to_address);
          }
          if (tx.is_memo && isEmpty(tx.link) && isNotEmpty(tx.block)) {
            if (_historyListMap[StateContainer.of(context).wallet.address] != null) {
              // find if there's a matching link:
              // for (var histItem in StateContainer.of(context).wallet.history) {
              for (var histItem in _historyListMap[StateContainer.of(context).wallet.address]) {
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

  StreamSubscription<ConfirmationHeightChangedEvent> _confirmEventSub;
  StreamSubscription<HistoryHomeEvent> _historySub;
  StreamSubscription<TXUpdateEvent> _txUpdatesSub;
  StreamSubscription<PaymentsHomeEvent> _paymentsSub;
  StreamSubscription<UnifiedHomeEvent> _unifiedSub;
  StreamSubscription<ContactModifiedEvent> _contactModifiedSub;
  StreamSubscription<BlockedModifiedEvent> _blockedModifiedSub;
  StreamSubscription<DisableLockTimeoutEvent> _disableLockSub;
  StreamSubscription<AccountChangedEvent> _switchAccountSub;

  void _registerBus() {
    _historySub = EventTaxiImpl.singleton().registerTo<HistoryHomeEvent>().listen((event) {
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
    _txUpdatesSub = EventTaxiImpl.singleton().registerTo<TXUpdateEvent>().listen((event) {
      if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet.address != null) {
        _updateTXDetailsMap(StateContainer.of(context).wallet.address);
      }
    });
    _paymentsSub = EventTaxiImpl.singleton().registerTo<PaymentsHomeEvent>().listen((event) {
      var newSolids = event.items;
      if (newSolids == null || newSolids.length == 0 || _solidsListMap[StateContainer.of(context).wallet.address] == null) {
        return;
      }
      _solidsListMap[StateContainer.of(context).wallet.address] = newSolids;
    });
    _unifiedSub = EventTaxiImpl.singleton().registerTo<UnifiedHomeEvent>().listen((event) {
      generateUnifiedList(fastUpdate: event.fastUpdate);
    });
    _contactModifiedSub = EventTaxiImpl.singleton().registerTo<ContactModifiedEvent>().listen((event) {
      _updateContacts();
    });
    _blockedModifiedSub = EventTaxiImpl.singleton().registerTo<BlockedModifiedEvent>().listen((event) {
      _updateBlocked();
    });
    // Hackish event to block auto-lock functionality
    _disableLockSub = EventTaxiImpl.singleton().registerTo<DisableLockTimeoutEvent>().listen((event) {
      if (event.disable) {
        cancelLockEvent();
      }
      _lockDisabled = event.disable;
    });
    // User changed account
    _switchAccountSub = EventTaxiImpl.singleton().registerTo<AccountChangedEvent>().listen((event) {
      setState(() {
        StateContainer.of(context).wallet.loading = true;
        StateContainer.of(context).wallet.historyLoading = true;
        StateContainer.of(context).wallet.unifiedLoading = true;
        _startAnimation();
        StateContainer.of(context).updateWallet(account: event.account);
        currentConfHeight = -1;
      });
      paintQrCode(address: event.account.address);
      if (event.delayPop) {
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
        });
      } else if (!event.noPop) {
        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      }
    });
    // Handle subscribe
    _confirmEventSub = EventTaxiImpl.singleton().registerTo<ConfirmationHeightChangedEvent>().listen((event) {
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
      _historySub.cancel();
    }
    if (_contactModifiedSub != null) {
      _contactModifiedSub.cancel();
    }
    if (_blockedModifiedSub != null) {
      _blockedModifiedSub.cancel();
    }
    if (_disableLockSub != null) {
      _disableLockSub.cancel();
    }
    if (_switchAccountSub != null) {
      _switchAccountSub.cancel();
    }
    if (_confirmEventSub != null) {
      _confirmEventSub.cancel();
    }
    if (_txUpdatesSub != null) {
      _txUpdatesSub.cancel();
    }
    if (_paymentsSub != null) {
      _paymentsSub.cancel();
    }
    if (_unifiedSub != null) {
      _unifiedSub.cancel();
    }
  }

  void _scrollListener() {
    // print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter < 500) {
      // check if the oldest item is the initial block:
      if (_historyListMap[StateContainer.of(context).wallet.address] != null && _historyListMap[StateContainer.of(context).wallet.address].length > 0) {
        var histList = _historyListMap[StateContainer.of(context).wallet.address];

        // histList[0] is the most recent block with the highest height (120)
        // histList[1] is the second most recent block with the next highest height (119)
        // histList[120] is the oldest block with the lowest height (1)

        if (histList[histList.length - 1].height > 1) {
          // we don't have all of the blocks yet, so we need to fetch more
          // TODO: implement this
          // StateContainer.of(context).requestUpdate(start: StateContainer.of(context).wallet.history.length, count: 50);
        }
      }
    }
  }

  int currentConfHeight = -1;

  void updateConfirmationHeights(int confirmationHeight) {
    setState(() {
      currentConfHeight = confirmationHeight + 1;
    });
    if (!_historyListMap.containsKey(StateContainer.of(context).wallet.address)) {
      return;
    }
    List<int> unconfirmedUpdate = [];
    List<int> confirmedUpdate = [];
    for (int i = 0; i < _historyListMap[StateContainer.of(context).wallet.address].length; i++) {
      if ((_historyListMap[StateContainer.of(context).wallet.address][i].confirmed == null ||
              _historyListMap[StateContainer.of(context).wallet.address][i].confirmed) &&
          _historyListMap[StateContainer.of(context).wallet.address][i].height != null &&
          confirmationHeight < _historyListMap[StateContainer.of(context).wallet.address][i].height) {
        unconfirmedUpdate.add(i);
      } else if ((_historyListMap[StateContainer.of(context).wallet.address][i].confirmed == null ||
              !_historyListMap[StateContainer.of(context).wallet.address][i].confirmed) &&
          _historyListMap[StateContainer.of(context).wallet.address][i].height != null &&
          confirmationHeight >= _historyListMap[StateContainer.of(context).wallet.address][i].height) {
        confirmedUpdate.add(i);
      }
    }
    unconfirmedUpdate.forEach((index) {
      setState(() {
        _historyListMap[StateContainer.of(context).wallet.address][index].confirmed = false;
      });
    });
    confirmedUpdate.forEach((index) {
      setState(() {
        _historyListMap[StateContainer.of(context).wallet.address][index].confirmed = true;
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
        if (!StateContainer.of(context).wallet.loading && StateContainer.of(context).initialDeepLink != null && !_lockTriggered) {
          handleDeepLink(StateContainer.of(context).initialDeepLink);
          StateContainer.of(context).initialDeepLink = null;
        }
        // branch gift:
        if (!StateContainer.of(context).wallet.loading && StateContainer.of(context).giftedWallet == true && !_lockTriggered) {
          StateContainer.of(context).giftedWallet = false;
          handleBranchGift();
        }
        // handle pending background events:
        if (!StateContainer.of(context).wallet.loading && !_lockTriggered) {
          handlePendingBackgroundMessages();
        }

        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  // To lock and unlock the app
  StreamSubscription<dynamic> lockStreamListener;

  Future<void> setAppLockEvent() async {
    if (((await sl.get<SharedPrefsUtil>().getLock()) || StateContainer.of(context).encryptedSecret != null) && !_lockDisabled) {
      if (lockStreamListener != null) {
        lockStreamListener.cancel();
      }
      Future<dynamic> delayed = new Future.delayed((await sl.get<SharedPrefsUtil>().getLockTimeout()).getDuration());
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
      lockStreamListener.cancel();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });
    sl.get<HapticUtil>().success();
    await StateContainer.of(context).requestUpdate();
    await StateContainer.of(context).updateSolids();
    _updateTXData();
    _updateTXDetailsMap(StateContainer.of(context).wallet.address);
    await generateUnifiedList(fastUpdate: false);
    // setState(() {});
    // Hide refresh indicator after 2.5 seconds
    Future.delayed(new Duration(milliseconds: 2500), () {
      setState(() {
        _isRefreshing = false;
      });
    });
  }

  ///
  /// Because there's nothing convenient like DiffUtil, some manual logic
  /// to determine the differences between two lists and to add new items.
  ///
  /// Depends on == being overriden in the AccountHistoryResponseItem class
  ///
  /// Required to do it this way for the animation
  ///
  void updateHistoryList(List<AccountHistoryResponseItem> newList) {
    if (newList == null || newList.length == 0 || _historyListMap[StateContainer.of(context).wallet.address] == null) {
      return;
    }

    _historyListMap[StateContainer.of(context).wallet.address] = newList;

    // Re-subscribe if missing data
    if (StateContainer.of(context).wallet.loading) {
      StateContainer.of(context).requestSubscribe();
    } else {
      updateConfirmationHeights(StateContainer.of(context).wallet.confirmationHeight);
    }
  }

  /// Desired relation | Result
  /// -------------------------------------------
  ///           a < b  | Returns a negative value.
  ///           a == b | Returns 0.
  ///           a > b  | Returns a positive value.
  ///
  int defaultSortComparison(dynamic a, dynamic b) {
    int propertyA = a.height;
    int propertyB = b.height;
    if (propertyA == null || propertyB == null) {
      // this shouldn't happen but it does if there's a bug:
      throw new Exception("Null height in comparison");
      // TODO:
      // propertyA = 0;
      // propertyB = 0;
    }

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
      if (a is TXData && b is TXData) {
        int a_time;
        int b_time;
        try {
          a_time = int.parse(a.request_time);
        } catch (e) {
          a_time = 0;
        }
        try {
          b_time = int.parse(b.request_time);
        } catch (e) {
          b_time = 0;
        }

        if (a_time < b_time) {
          return 1;
        } else if (a_time > b_time) {
          return -1;
        } else {
          return 0;
        }
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
    String propertyA = (a is AccountHistoryResponseItem)
        ? a.amount
        : (a is TXData)
            ? a.amount_raw
            : "";
    String propertyB = (b is AccountHistoryResponseItem)
        ? b.amount
        : (b is TXData)
            ? b.amount_raw
            : "";
    if (propertyA == "" || propertyB == "") {
      // this shouldn't happen but it does if there's a bug:
      throw new Exception("Null amount in comparison2");
    }

    var numA = BigInt.parse(propertyA);
    var numB = BigInt.parse(propertyB);
    if (numA < numB) {
      return 1;
    } else if (numA > numB) {
      return -1;
    } else if (numA == numB) {
      return 0;
    }

    return 0;
  }

  Future<void> generateUnifiedList({bool fastUpdate = false}) async {
    if (_historyListMap[StateContainer.of(context).wallet.address] == null ||
        _solidsListMap[StateContainer.of(context).wallet.address] == null ||
        _unifiedListMap[StateContainer.of(context).wallet.address] == null) {
      return;
    }

    // this isn't performant but w/e
    List<dynamic> unifiedList = [];
    List<int> removeIndices = [];

    // combine history and payments:
    List<AccountHistoryResponseItem> historyList = StateContainer.of(context).wallet.history;
    List<TXData> solidsList = StateContainer.of(context).wallet.solids;

    // for (var tx in solidsList) {
    //   print("memo: ${tx.memo} is_request: ${tx.is_request}");
    // }

    // add tx's to the unified list:
    // unifiedList.addAll(historyList);
    // unifiedList.addAll(solidsList);
    unifiedList = List<dynamic>.from(historyList.where((element) => element.type != BlockTypes.CHANGE).toList());

    Set uuids = Set();
    List<int> idsToRemove = [];
    for (var req in solidsList) {
      if (!uuids.contains(req.uuid)) {
        uuids.add(req.uuid);
      } else {
        log.d("detected duplicate TXData2! removing...");
        idsToRemove.add(req.id);
        await sl.get<DBHelper>().deleteTXDataByID(req.id);
      }
    }
    for (var id in idsToRemove) {
      solidsList.removeWhere((element) => element.id == id);
    }

    // go through each item in the solidsList and insert it into the unifiedList at the matching block:
    for (int i = 0; i < solidsList.length; i++) {
      int index;
      int height;

      // if the block is null, give it one:
      if (solidsList[i].block == null) {
        String lastBlockHash = StateContainer.of(context).wallet.history.length > 0 ? StateContainer.of(context).wallet.history[0].hash : null;
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
        if (unifiedList[j].type == BlockTypes.CHANGE) {
          unifiedList.removeAt(j);
          j--;
          continue;
        }
        String histItemHash = unifiedList[j].hash;

        // print("${histItemHash} ${solidsList[i].block} ${solidsList[i].link}");

        if (histItemHash == solidsList[i].block || histItemHash == solidsList[i].link) {
          index = j;
          height = unifiedList[j].height + 1;
          break;
        }
      }

      // found an index to insert at:
      if (index != null) {
        solidsList[i].height = height;
        unifiedList.insert(index, solidsList[i]);
      } else if (isEmpty(solidsList[i].block)) {
        // block was null so just insert it at the top?:
        unifiedList.insert(0, solidsList[i]);
      }
    }

    bool override_sort = false;

    // filter by search results:
    if (_searchController.text.isNotEmpty) {
      removeIndices = [];
      String lowerCaseSearch = _searchController.text.toLowerCase();

      // override the sorting algo if the search involves numbers:
      override_sort = double.parse(lowerCaseSearch, (e) => null) != null;

      unifiedList.forEach((dynamicItem) {
        bool shouldRemove = true;

        String displayName;
        String account;
        TXData txDetails;
        var res = getPossibleTXDetails(context, dynamicItem);
        displayName = res[0];
        account = res[1];
        txDetails = res[2];

        String amount_str;

        if (dynamicItem is TXData) {
          txDetails = dynamicItem;

          if (dynamicItem.amount_raw != null && dynamicItem.amount_raw.isNotEmpty) {
            amount_str = getRawAsThemeAwareAmount(context, dynamicItem.amount_raw);
            if (txDetails.is_request) {
              bool is_recipient = StateContainer.of(context).wallet.address == txDetails.to_address;
              if (is_recipient) {
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
        } else if (dynamicItem is AccountHistoryResponseItem) {
          amount_str = getRawAsThemeAwareAmount(context, dynamicItem.amount);
          if (dynamicItem.subtype == BlockTypes.SEND) {
            if (AppLocalization.of(context).sent.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
          if (dynamicItem.subtype == BlockTypes.RECEIVE) {
            if (AppLocalization.of(context).received.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }
        }

        if (amount_str != null && amount_str.contains(lowerCaseSearch)) {
          shouldRemove = false;
        }

        if (txDetails != null) {
          if (isNotEmpty(txDetails.memo)) {
            if (txDetails.memo.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
          }

          if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
            if (AppLocalization.of(context).loaded.toLowerCase().contains(lowerCaseSearch)) {
              shouldRemove = false;
            }
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
    if (!override_sort) {
      unifiedList.sort(defaultSortComparison);
    } else {
      unifiedList.sort(amountSortComparison);
    }

    bool areThereNoSearchResults = (unifiedList.length == 0) && (_searchController.text.isNotEmpty);

    if (areThereNoSearchResults != _noSearchResults) {
      setState(() {
        _noSearchResults = areThereNoSearchResults;
      });
      // not sure why this gets the state to update, but nothing else will :/
      await sl.get<AccountService>().dummyAPICall();
    }

    // create a list of indices to remove:
    removeIndices = [];
    // mark anything out of place or not in the unified list as to be removed:
    _unifiedListMap[StateContainer.of(context).wallet.address].items.where((item) => !unifiedList.contains(item)).forEach((dynamicItem) {
      removeIndices.add(_unifiedListMap[StateContainer.of(context).wallet.address].items.indexOf(dynamicItem));
    });
    if (_searchController.text.isNotEmpty) {
      _unifiedListMap[StateContainer.of(context).wallet.address]
          .items
          .where((item) => (_unifiedListMap[StateContainer.of(context).wallet.address].items.indexOf(item) != (unifiedList.indexOf(item))))
          .forEach((dynamicItem) {
        removeIndices.add(_unifiedListMap[StateContainer.of(context).wallet.address].items.indexOf(dynamicItem));
      });
    }
    // ensure uniqueness and must be sorted to prevent and index error:
    removeIndices = removeIndices.toSet().toList();
    removeIndices.sort((a, b) => a.compareTo(b));

    // remove from the listmap:
    for (int i = removeIndices.length - 1; i >= 0; i--) {
      // don't set state since we don't need it to re-render just yet:
      // also it will throw an error because the list can be empty and the builder will get upset:
      _unifiedListMap[StateContainer.of(context).wallet.address].removeAt(removeIndices[i], _buildUnifiedItem, instant: true);
    }

    // log.d("updating whole list!");

    // insert unifiedList into listmap:
    unifiedList.where((item) => !_unifiedListMap[StateContainer.of(context).wallet.address].items.contains(item)).forEach((dynamicItem) {
      int index = unifiedList.indexOf(dynamicItem);
      if (dynamicItem == null) return;
      index = max(min(index, _unifiedListMap[StateContainer.of(context).wallet.address].length), 0);
      setState(() {
        _unifiedListMap[StateContainer.of(context).wallet.address].insertAt(dynamicItem, index, instant: fastUpdate);
      });
    });

    // ready to be rendered:
    if (StateContainer.of(context).wallet.unifiedLoading) {
      setState(() {
        _updateTXDetailsMap(StateContainer.of(context).wallet.address);
        StateContainer.of(context).wallet.unifiedLoading = false;
      });
    }
  }

  Future<void> handleDeepLink(link) async {
    log.d("handleDeepLink: $link");
    Address address = Address(link);
    if (address.isValid()) {
      String amount;
      bool sufficientBalance = false;
      if (address.amount != null) {
        BigInt amountBigInt = BigInt.tryParse(address.amount);
        // Require minimum 1 raw to send, and make sure sufficient balance
        if (amountBigInt != null && amountBigInt >= BigInt.from(10).pow(24)) {
          if (StateContainer.of(context).wallet.accountBalance > amountBigInt) {
            sufficientBalance = true;
          }
          amount = address.amount;
        }
      }
      // See if a contact
      dynamic user = await sl.get<DBHelper>().getUserOrContactWithAddress(address.address);
      // Remove any other screens from stack
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      if (amount != null && sufficientBalance) {
        // Go to send confirm with amount
        Sheets.showAppHeightNineSheet(
            context: context, widget: SendConfirmSheet(amountRaw: amount, destination: address.address, contactName: user?.getDisplayName()));
      } else {
        // Go to send with address
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(localCurrency: StateContainer.of(context).curCurrency, user: user, address: address.address, quickSendAmount: amount ?? null));
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

  // handle pending messages
  Future<void> handlePendingBackgroundMessages() async {
    if (StateContainer.of(context).wallet != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      var background_messages = prefs.getStringList('background_messages');
      // process the message now that we're in the foreground:

      if (background_messages != null) {
        EventTaxiImpl.singleton().fire(FcmMessageEvent(message_list: background_messages));
        // clear the storage since we just processed it:
        await prefs.remove('background_messages');
      }
    }
  }

  void paintQrCode({String address}) {
    QrPainter painter = QrPainter(
      data: address == null ? StateContainer.of(context).wallet.address : address,
      version: 6,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    if (MediaQuery.of(context).size.width == 0) {
      return;
    }
    painter.toImageData(MediaQuery.of(context).size.width).then((byteData) {
      setState(() {
        receive = ReceiveSheet(
          localCurrency: StateContainer.of(context).curCurrency,
          address: StateContainer.of(context).wallet.address,
          qrWidget: Container(width: MediaQuery.of(context).size.width / 2.675, child: Image.memory(byteData.buffer.asUint8List())),
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
                        margin: EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 26.0, 0.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              CaseChange.toUpperCase(AppLocalization.of(context).transactions, context),
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
                                    colors: [StateContainer.of(context).curTheme.background00, StateContainer.of(context).curTheme.background],
                                    begin: AlignmentDirectional(0.5, 1.0),
                                    end: AlignmentDirectional(0.5, -1.0),
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
                                    colors: [StateContainer.of(context).curTheme.background00, StateContainer.of(context).curTheme.background],
                                    begin: AlignmentDirectional(0.5, -1),
                                    end: AlignmentDirectional(0.5, 0.5),
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
                          boxShadow: [StateContainer.of(context).curTheme.boxShadowButton],
                        ),
                        height: 55,
                        width: (MediaQuery.of(context).size.width - 42).abs() / 2,
                        margin: EdgeInsetsDirectional.only(start: 14, top: 0.0, end: 7.0),
                        // margin: EdgeInsetsDirectional.only(start: 7.0, top: 0.0, end: 7.0),
                        child: FlatButton(
                          key: const Key("receive_button"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                          color: receive != null ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.primary60,
                          child: AutoSizeText(
                            AppLocalization.of(context).receive,
                            textAlign: TextAlign.center,
                            style: AppStyles.textStyleButtonPrimary(context),
                            maxLines: 1,
                            stepGranularity: 0.5,
                          ),
                          onPressed: () {
                            if (receive == null) {
                              return;
                            }
                            Sheets.showAppHeightNineSheet(context: context, widget: receive);
                          },
                          highlightColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                          splashColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                        ),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(5),
                      //     boxShadow: [StateContainer.of(context).curTheme.boxShadowButton],
                      //   ),
                      //   height: 55,
                      //   width: (MediaQuery.of(context).size.width - 42) / 3,
                      //   // margin: EdgeInsetsDirectional.only(start: 14, top: 0.0, end: 7.0),
                      //   margin: EdgeInsetsDirectional.only(start: 0, top: 0.0, end: 0.0),
                      //   child: FlatButton(
                      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      //     color: receive != null ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.primary60,
                      //     child: AutoSizeText(
                      //       AppLocalization.of(context).request,
                      //       textAlign: TextAlign.center,
                      //       style: AppStyles.textStyleButtonPrimary(context),
                      //       maxLines: 1,
                      //       stepGranularity: 0.5,
                      //     ),
                      //     onPressed: () {
                      //       if (request == null) {
                      //         return;
                      //       }
                      //       Sheets.showAppHeightEightSheet(context: context, widget: request);
                      //     },
                      //     highlightColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                      //     splashColor: receive != null ? StateContainer.of(context).curTheme.background40 : Colors.transparent,
                      //   ),
                      // ),
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
  }

  Widget _buildRemoteMessageCard(AlertResponseItem alert) {
    if (alert == null) {
      return SizedBox();
    }
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(14, 4, 14, 4),
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
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: AppLocalization.of(context).noSearchResults,
                    style: AppStyles.textStyleTransactionWelcome(context),
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  // Dummy Transaction Card
  Widget _buildDummyTransactionCard(String type, String amount, String address, BuildContext context) {
    String text;
    IconData icon;
    Color iconColor;
    if (type == AppLocalization.of(context).sent) {
      text = AppLocalization.of(context).sent;
      icon = AppIcons.sent;
      iconColor = StateContainer.of(context).curTheme.text60;
    } else {
      text = AppLocalization.of(context).received;
      icon = AppIcons.received;
      iconColor = StateContainer.of(context).curTheme.primary60;
    }
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: FlatButton(
        onPressed: () {
          return null;
        },
        highlightColor: StateContainer.of(context).curTheme.text15,
        splashColor: StateContainer.of(context).curTheme.text15,
        color: StateContainer.of(context).curTheme.backgroundDark,
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(margin: EdgeInsetsDirectional.only(end: 16.0), child: Icon(icon, color: iconColor, size: 20)),
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            text,
                            textAlign: TextAlign.start,
                            style: AppStyles.textStyleTransactionType(context),
                          ),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: amount + " NANO",
                                  style: AppStyles.textStyleTransactionAmount(
                                    context,
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
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Text(
                    address,
                    textAlign: TextAlign.end,
                    style: AppStyles.textStyleTransactionAddress(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //Dummy Transaction Card End

  // Welcome Card
  TextSpan _getExampleHeaderSpan(BuildContext context) {
    String workingStr;
    if (StateContainer.of(context).selectedAccount == null || StateContainer.of(context).selectedAccount.index == 0) {
      workingStr = AppLocalization.of(context).exampleCardIntro;
    } else {
      workingStr = AppLocalization.of(context).newAccountIntro;
    }
    if (!workingStr.contains("NANO")) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    // Colorize NANO
    List<String> splitStr = workingStr.split("NANO");
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

  // Welcome Card
  TextSpan _getPaymentExampleHeaderSpan(BuildContext context) {
    String workingStr = AppLocalization.of(context).examplePaymentIntro;

    if (!workingStr.contains("NANO")) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    // Colorize NANO
    List<String> splitStr = workingStr.split("NANO");
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
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow],
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
                borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  Widget _buildWelcomePaymentCard(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: _getPaymentExampleHeaderSpan(context),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
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
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.start,
                  // text: _getPaymentExampleHeaderSpan(context),
                  text: TextSpan(
                    text: AppLocalization.of(context).examplePaymentExplainer,
                    style: AppStyles.textStyleTransactionWelcome(context),
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
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
    Color iconColor;
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
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: FlatButton(
        onPressed: () {
          return null;
        },
        highlightColor: StateContainer.of(context).curTheme.text15,
        splashColor: StateContainer.of(context).curTheme.text15,
        color: StateContainer.of(context).curTheme.backgroundDark,
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                      child: Container(margin: EdgeInsetsDirectional.only(end: 16.0), child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Transaction Type Text
                          Container(
                            child: Stack(
                              alignment: AlignmentDirectional(-1, 0),
                              children: <Widget>[
                                Text(
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
                                  opacity: _opacityAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: StateContainer.of(context).curTheme.text45,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
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
                          ),
                          // Amount Text
                          Container(
                            child: Stack(
                              alignment: AlignmentDirectional(-1, 0),
                              children: <Widget>[
                                Text(
                                  amount,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
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
                                      style: TextStyle(
                                          fontFamily: "NunitoSans",
                                          color: Colors.transparent,
                                          fontSize: AppFontSizes.smallest - 3,
                                          fontWeight: FontWeight.w600),
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
                // Address Text
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: Stack(
                          alignment: AlignmentDirectional(1, 0),
                          children: <Widget>[
                            Text(
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
                              opacity: _opacityAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: StateContainer.of(context).curTheme.text20,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
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
      hintText: _searchOpen ? AppLocalization.of(context).searchHint : "",
    );
  }

  //Main Card
  Widget _buildMainCard(BuildContext context, _scaffoldKey) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      margin: EdgeInsets.only(left: 14.0, right: 14.0, top: MediaQuery.of(context).size.height * 0.005),
      child: Stack(
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 80.0,
              height: mainCardHeight,
              alignment: AlignmentDirectional(-1, -1),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: EdgeInsetsDirectional.only(top: settingsIconMarginTop, start: 5),
                height: 50,
                width: 50,
                child: FlatButton(
                  highlightColor: StateContainer.of(context).curTheme.text15,
                  splashColor: StateContainer.of(context).curTheme.text15,
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Stack(
                    children: [
                      Icon(
                        AppIcons.settings,
                        color: StateContainer.of(context).curTheme.text,
                        size: 24,
                      ),
                      !StateContainer.of(context).activeAlertIsRead
                          ?
                          // Unread message dot
                          Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                padding: EdgeInsets.all(3),
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
                          : SizedBox()
                    ],
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: mainCardHeight,
              child: _getBalanceWidget(),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 80,
              height: mainCardHeight,
            ),
          ]),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: mainCardHeight,
            // height: mainCardHeight == 64 ? 60 : 74,
            margin: EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            // padding: EdgeInsets.all(0.0),
            padding: EdgeInsets.only(bottom: 2), // covers the top of the balance text in the currency widget
            child: _buildSearchbarAnimation(),
          ),
        ],
      ),
    );
  } //Main Card

  // // natricon
  // (StateContainer.of(context).nyanoMode)
  //     ? (StateContainer.of(context).nyaniconOn
  //         ? AnimatedContainer(
  //             duration: Duration(milliseconds: 200),
  //             curve: Curves.easeInOut,
  //             width: mainCardHeight == 64 ? 60 : 74,
  //             height: mainCardHeight == 64 ? 60 : 74,
  //             margin: EdgeInsets.only(right: 2),
  //             alignment: Alignment(0, 0),
  //             child: Stack(
  //               children: <Widget>[
  //                 Center(
  //                   child: Container(
  //                     // nyanicon
  //                     child: Hero(
  //                       tag: "avatar",
  //                       child: StateContainer.of(context).selectedAccount.address != null
  //                           ? Image(image: AssetImage("assets/nyano/images/logos/cat-head-collar-black-1000 × 1180.png"))
  //                           : SizedBox(),
  //                     ),
  //                   ),
  //                 ),
  //                 Center(
  //                   child: Container(
  //                     color: Colors.transparent,
  //                     child: FlatButton(
  //                       onPressed: () {
  //                         // Navigator.of(context).pushNamed('/avatar_page');
  //                       },
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  //                       highlightColor: StateContainer.of(context).curTheme.text15,
  //                       splashColor: StateContainer.of(context).curTheme.text15,
  //                       padding: EdgeInsets.all(0.0),
  //                       child: Container(
  //                         color: Colors.transparent,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         : AnimatedContainer(
  //             duration: Duration(milliseconds: 200),
  //             curve: Curves.easeInOut,
  //             width: 80.0,
  //             height: mainCardHeight,
  //           ))
  //     : (StateContainer.of(context).natriconOn
  //         ? AnimatedContainer(
  //             duration: Duration(milliseconds: 200),
  //             curve: Curves.easeInOut,
  //             width: mainCardHeight == 64 ? 60 : 74,
  //             height: mainCardHeight == 64 ? 60 : 74,
  //             margin: EdgeInsets.only(right: 2),
  //             alignment: Alignment(0, 0),
  //             child: Stack(
  //               children: <Widget>[
  //                 Center(
  //                   child: Container(
  //                     // natricon
  //                     child: Hero(
  //                       tag: "avatar",
  //                       child: StateContainer.of(context).selectedAccount.address != null
  //                           ? SvgPicture.network(
  //                               UIUtil.getNatriconURL(StateContainer.of(context).selectedAccount.address,
  //                                   StateContainer.of(context).getNatriconNonce(StateContainer.of(context).selectedAccount.address)),
  //                               key: Key(UIUtil.getNatriconURL(StateContainer.of(context).selectedAccount.address,
  //                                   StateContainer.of(context).getNatriconNonce(StateContainer.of(context).selectedAccount.address))),
  //                               placeholderBuilder: (BuildContext context) => Container(
  //                                 child: FlareActor(
  //                                   "legacy_assets/ntr_placeholder_animation.flr",
  //                                   animation: "main",
  //                                   fit: BoxFit.contain,
  //                                   color: StateContainer.of(context).curTheme.primary,
  //                                 ),
  //                               ),
  //                             )
  //                           : SizedBox(),
  //                     ),
  //                   ),
  //                 ),
  //                 Center(
  //                   child: Container(
  //                     color: Colors.transparent,
  //                     child: FlatButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pushNamed('/avatar_page');
  //                       },
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  //                       highlightColor: StateContainer.of(context).curTheme.text15,
  //                       splashColor: StateContainer.of(context).curTheme.text15,
  //                       padding: EdgeInsets.all(0.0),
  //                       child: Container(
  //                         color: Colors.transparent,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         : AnimatedContainer(
  //             duration: Duration(milliseconds: 200),
  //             curve: Curves.easeInOut,
  //             width: 80.0,
  //             height: mainCardHeight,
  //           ))

  // Get balance display
  Widget _getBalanceWidget() {
    if (StateContainer.of(context).wallet == null || StateContainer.of(context).wallet.loading) {
      // Placeholder for balance text
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _priceConversion == PriceConversion.BTC
                ? Container(
                    child: Stack(
                      alignment: AlignmentDirectional(0, 0),
                      children: <Widget>[
                        Text(
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
                            child: Text(
                              "1234567",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontFamily: "NunitoSans", fontSize: AppFontSizes.small - 3, fontWeight: FontWeight.w600, color: Colors.transparent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 225),
              child: Stack(
                alignment: AlignmentDirectional(0, 0),
                children: <Widget>[
                  AutoSizeText(
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
                      child: AutoSizeText(
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
            _priceConversion == PriceConversion.BTC
                ? Container(
                    child: Stack(
                      alignment: AlignmentDirectional(0, 0),
                      children: <Widget>[
                        Text(
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
                            child: Text(
                              "1234567",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontFamily: "NunitoSans", fontSize: AppFontSizes.small - 3, fontWeight: FontWeight.w600, color: Colors.transparent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
          ],
        ),
      );
    }
    // Balance texts
    return GestureDetector(
      onTap: () {
        if (_priceConversion == PriceConversion.BTC) {
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
          // Cycle to BTC price
          setState(() {
            mainCardHeight = 80;
            settingsIconMarginTop = 15;
          });
          Future.delayed(Duration(milliseconds: 150), () {
            setState(() {
              _priceConversion = PriceConversion.BTC;
            });
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.BTC);
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: (MediaQuery.of(context).size.width - 190).abs(),
        color: Colors.transparent,
        child: _priceConversion == PriceConversion.HIDDEN
            ?
            // Nano logo
            Center(child: Container(child: Icon(AppIcons.nanologo, size: 32, color: StateContainer.of(context).curTheme.primary)))
            : Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _priceConversion == PriceConversion.BTC
                        ? Text(
                            StateContainer.of(context)
                                .wallet
                                .getLocalCurrencyPrice(StateContainer.of(context).curCurrency, locale: StateContainer.of(context).currencyLocale),
                            textAlign: TextAlign.center,
                            style: AppStyles.textStyleCurrencyAlt(context))
                        : SizedBox(height: 0),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width - 205).abs()),
                            child: AutoSizeText.rich(
                              TextSpan(
                                children: [
                                  _priceConversion == PriceConversion.BTC
                                      ? displayCurrencyAmount(context, AppStyles.textStyleCurrency(context, true))
                                      : displayCurrencyAmount(
                                          context,
                                          AppStyles.textStyleCurrencySmaller(
                                            context,
                                            true,
                                          )),
                                  // Main balance text
                                  TextSpan(
                                    text: getCurrencySymbol(context) + StateContainer.of(context).wallet.getAccountBalanceDisplay(context),
                                    style: _priceConversion == PriceConversion.BTC
                                        ? AppStyles.textStyleCurrency(context)
                                        : AppStyles.textStyleCurrencySmaller(
                                            context,
                                          ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              style: TextStyle(fontSize: _priceConversion == PriceConversion.BTC ? 28 : 22),
                              stepGranularity: 0.1,
                              minFontSize: 1,
                              maxFontSize: _priceConversion == PriceConversion.BTC ? 28 : 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0),
                  ],
                ),
              ),
      ),
    );
  }

  // @@@@@@@@@@@@@@@@@@@@@@@@@@@@
  // PAYMENTS
  // @@@@@@@@@@@@@@@@@@@@@@@@@@@@

  // Dummy Payment Card
  Widget _buildDummyPaymentCard(String type, String amount, String address, BuildContext context,
      {bool isFulfilled = false, bool isRequest = false, bool isAcknowleged = false, String memo = ""}) {
    String text;
    IconData icon;
    Color iconColor;

    bool isRecipient = type == AppLocalization.of(context).request;

    if (isRecipient) {
      text = AppLocalization.of(context).request;
      icon = AppIcons.call_made;
    } else {
      text = AppLocalization.of(context).asked;
      icon = AppIcons.call_received;
    }

    BoxShadow setShadow;

    if (!isAcknowleged && !isFulfilled) {
      iconColor = StateContainer.of(context).curTheme.error60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.error60.withOpacity(0.5),
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if (!isFulfilled) {
      iconColor = StateContainer.of(context).curTheme.warning60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.warning60.withOpacity(0.2),
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else {
      iconColor = StateContainer.of(context).curTheme.success60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.success60.withOpacity(0.2),
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 1,
      );
    }

    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        // boxShadow: [StateContainer.of(context).curTheme.boxShadow],
        boxShadow: [setShadow],
      ),
      child: FlatButton(
        onPressed: () {
          return null;
        },
        highlightColor: StateContainer.of(context).curTheme.text15,
        splashColor: StateContainer.of(context).curTheme.text15,
        color: StateContainer.of(context).curTheme.backgroundDark,
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(margin: EdgeInsetsDirectional.only(end: 16.0), child: Icon(icon, color: iconColor, size: 20)),
                    Container(
                      width: MediaQuery.of(context).size.width / 4.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            text,
                            textAlign: TextAlign.start,
                            style: AppStyles.textStyleTransactionType(context),
                          ),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: amount + " NANO",
                                  style: AppStyles.textStyleTransactionAmount(
                                    context,
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
                Container(
                  width: MediaQuery.of(context).size.width / 4.5,
                  child: Text(
                    memo,
                    textAlign: TextAlign.start,
                    style: AppStyles.textStyleTransactionMemo(context),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Text(
                    address,
                    textAlign: TextAlign.end,
                    style: AppStyles.textStyleTransactionAddress(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //Dummy Payment Card End

  Widget getTransactionStateTag(TransactionStateOptions transactionState) {
    if (transactionState != null) {
      return Container(
        margin: EdgeInsetsDirectional.only(
          top: 4,
        ),
        child: TransactionStateTag(transactionState: transactionState),
      );
    } else {
      return SizedBox();
    }
  }

  // TX / Card Action functions:
  static Future<void> resendRequest(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.REQUEST, onPoppedCallback: () => animationOpen = false);

    bool sendFailed = false;

    // send the request again:
    String privKey = NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount.index);
    // get epoch time as hex:
    int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    String nonce_hex = secondsSinceEpoch.toRadixString(16);
    String signature = NanoSignatures.signBlock(nonce_hex, privKey);

    // check validity locally:
    String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet?.address);
    bool isValid = NanoSignatures.validateSig(nonce_hex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    var uuid = Uuid();
    String local_uuid = "LOCAL:" + uuid.v4();
    var requestTXData = new TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: local_uuid,
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
      String encryptedMemo;
      if (txDetails.memo != null && txDetails.memo.isNotEmpty) {
        encryptedMemo = await Box.encrypt(txDetails.memo, txDetails.to_address, privKey);
      }
      await sl.get<AccountService>().requestPayment(
          txDetails.to_address, txDetails.amount_raw, StateContainer.of(context).wallet.address, signature, nonce_hex, encryptedMemo, local_uuid);
    } catch (e) {
      print(e);
      sendFailed = true;
    }

    // if the memo send failed delete the object:
    if (sendFailed) {
      print("request send failed, deleting TXData object");
      // remove failed txdata from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(local_uuid);
      // sleep for 2 seconds so the animation finishes otherwise the UX is weird:
      await Future.delayed(Duration(seconds: 2));
      // show error:
      UIUtil.showSnackbar(AppLocalization.of(context).requestSendError, context, durationMs: 5000);
    } else {
      // delete the old request by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(AppLocalization.of(context).requestSentButNotReceived, context, durationMs: 5000);
    }
    await StateContainer.of(context).updateSolids();
    // hack to get tx memo to update:
    EventTaxiImpl.singleton().fire(TXUpdateEvent());

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> resendMemo(BuildContext context, TXData txDetails) async {
    // show sending animation:
    bool animationOpen = true;
    AppAnimation.animationLauncher(context, AnimationType.SEND_MESSAGE, onPoppedCallback: () => animationOpen = false);

    bool memoSendFailed = false;

    // send the memo again:
    String privKey = NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount.index);
    // get epoch time as hex:
    int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    String nonce_hex = secondsSinceEpoch.toRadixString(16);
    String signature = NanoSignatures.signBlock(nonce_hex, privKey);

    // check validity locally:
    String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet?.address);
    bool isValid = NanoSignatures.validateSig(nonce_hex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
    if (!isValid) {
      throw Exception("Invalid signature?!");
    }

    // create a local memo object:
    var uuid = Uuid();
    String local_uuid = "LOCAL:" + uuid.v4();
    var memoTXData = new TXData(
      from_address: txDetails.from_address,
      to_address: txDetails.to_address,
      amount_raw: txDetails.amount_raw,
      uuid: local_uuid,
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
      String encryptedMemo = await Box.encrypt(txDetails.memo, txDetails.to_address, privKey);
      await sl.get<AccountService>().sendTXMemo(txDetails.to_address, StateContainer.of(context).wallet.address, txDetails.amount_raw, signature, nonce_hex,
          encryptedMemo, txDetails.block, local_uuid);
    } catch (e) {
      memoSendFailed = true;
    }

    // if the memo send failed delete the object:
    if (memoSendFailed) {
      print("memo send failed, deleting TXData object");
      // remove from the database:
      await sl.get<DBHelper>().deleteTXDataByUUID(local_uuid);
      // sleep for 2 seconds so the animation finishes otherwise the UX is weird:
      await Future.delayed(Duration(seconds: 2));
      // show error:
      UIUtil.showSnackbar(AppLocalization.of(context).sendMemoError, context, durationMs: 5000);
    } else {
      // delete the old memo by uuid:
      await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid);
      // memo sent successfully, show success:
      UIUtil.showSnackbar(AppLocalization.of(context).memoSentButNotReceived, context, durationMs: 5000);
      // hack to get tx memo to update:
      EventTaxiImpl.singleton().fire(TXUpdateEvent());
    }

    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
  }

  static Future<void> payTX(BuildContext context, TXData txDetails) async {
    String address;
    if (txDetails.is_request || txDetails.is_memo) {
      if (txDetails.to_address == StateContainer.of(context).wallet.address) {
        address = txDetails.from_address;
      } else {
        address = txDetails.to_address;
      }
    } else {
      // address = item.account;
      address = txDetails.from_address;
    }
    // See if a contact
    var user = await sl.get<DBHelper>().getUserOrContactWithAddress(address);
    String quickSendAmount = txDetails.amount_raw;
    // a bit of a hack since send sheet doesn't have a way to tell if we're in nyano mode on creation:
    if (StateContainer.of(context).nyanoMode) {
      quickSendAmount += "000000";
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
  Widget _buildUnifiedCard(dynamic item, Animation<double> animation, String displayName, BuildContext context, {TXData txDetails}) {
    String itemText;
    IconData icon;
    Color iconColor;

    bool isSolid = item is TXData;
    if (isSolid) {
      txDetails = item;
    }
    bool isTransaction = item is AccountHistoryResponseItem;
    bool isGift = false;
    String walletAddress = StateContainer.of(context).wallet.address;

    // history items:
    if (txDetails == null) {
      txDetails = TXData();
      txDetails.amount_raw = item.amount;
      txDetails.from_address = item.account;
      txDetails.to_address = item.account;
      txDetails.is_acknowledged = true;
      txDetails.block = item.hash;
    }

    if (txDetails.is_message) {
      // just in case:
      txDetails.amount_raw = null;
    } else if (txDetails.is_memo) {
      txDetails.amount_raw = item.amount;
    }

    if (txDetails.isRecipient(walletAddress)) {
      txDetails.is_acknowledged = true;
    }

    if (txDetails.record_type == RecordTypes.GIFT_ACK || txDetails.record_type == RecordTypes.GIFT_OPEN || txDetails.record_type == RecordTypes.GIFT_LOAD) {
      isGift = true;
    }

    // set icon color:
    if (isSolid) {
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
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          itemText = AppLocalization.of(context).sent;
          icon = AppIcons.call_made;
          iconColor = StateContainer.of(context).curTheme.primary60;
        }
      }
    } else if (isTransaction) {
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
          throw "something went wrong with gift type";
        }
      } else {
        if (item.type == BlockTypes.SEND) {
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

    BoxShadow setShadow;

    // set box shadow color:
    if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
      // normal tx:
      setShadow = StateContainer.of(context).curTheme.boxShadow;
    } else if (txDetails.status == StatusTypes.CREATE_FAILED) {
      iconColor = StateContainer.of(context).curTheme.error60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.error60.withOpacity(0.2),
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if (txDetails.is_fulfilled && isSolid) {
      iconColor = StateContainer.of(context).curTheme.success60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.success60.withOpacity(0.2),
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else if ((!txDetails.is_acknowledged) || (txDetails.is_request && !txDetails.is_fulfilled)) {
      iconColor = StateContainer.of(context).curTheme.warning60;
      setShadow = BoxShadow(
        color: StateContainer.of(context).curTheme.warning60.withOpacity(0.2),
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 1,
      );
    } else {
      // normal transaction:
      setShadow = StateContainer.of(context).curTheme.boxShadow;
    }

    bool slideEnabled = false;
    // valid wallet:
    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet.accountBalance > BigInt.zero) {
      // does it make sense to make it slideable?
      // if (isPaymentRequest && isRecipient && !txDetails.is_fulfilled) {
      //   slideEnabled = true;
      // }
      if (txDetails.is_request && !txDetails.is_fulfilled) {
        slideEnabled = true;
      }
      if (isTransaction && !isGift) {
        slideEnabled = true;
      }
      if (txDetails.is_message) {
        slideEnabled = true;
      }
    }

    TransactionStateOptions transactionState;

    if (isTransaction) {
      if ((item.confirmed != null && !item.confirmed) || (currentConfHeight > -1 && item.height != null && item.height > currentConfHeight)) {
        transactionState = TransactionStateOptions.UNCONFIRMED;
      }
    }

    if (txDetails != null) {
      if (txDetails.record_type != RecordTypes.GIFT_LOAD) {
        if (txDetails.status == StatusTypes.CREATE_FAILED) {
          transactionState = TransactionStateOptions.FAILED_MSG;
        }
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
    }

    List<Widget> _slideActions = [];
    // if (isTransaction) {
    String label;
    if (isTransaction) {
      label = AppLocalization.of(context).send;
    } else {
      if (txDetails.is_request && txDetails.isRecipient(walletAddress)) {
        label = AppLocalization.of(context).pay;
      }
    }

    // payment request / pay button:
    if (label != null) {
      _slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          foregroundColor: StateContainer.of(context).curTheme.success,
          icon: Icons.send,
          label: label,
          onPressed: (BuildContext context) async {
            // sleep for a bit to give the ripple effect time to finish
            await Future.delayed(Duration(milliseconds: 250));
            await payTX(context, txDetails);
            await Slidable.of(context).close();
          }));
    }

    // reply button:
    if (txDetails.is_message && txDetails.isRecipient(walletAddress)) {
      _slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          foregroundColor: StateContainer.of(context).curTheme.success,
          icon: Icons.send,
          label: AppLocalization.of(context).reply,
          onPressed: (BuildContext context) async {
            // sleep for a bit to give the ripple effect time to finish
            await Future.delayed(Duration(milliseconds: 250));
            await payTX(context, txDetails);
            await Slidable.of(context).close();
          }));
    }

    // retry buttons:
    if (!txDetails.is_acknowledged) {
      if (txDetails.is_request) {
        _slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: AppLocalization.of(context).retry,
            onPressed: (BuildContext context) async {
              // sleep for a bit to give the ripple effect time to finish
              await Future.delayed(Duration(milliseconds: 250));
              await resendRequest(context, txDetails);
              await Slidable.of(context).close();
            }));
      } else if (txDetails.is_memo) {
        _slideActions.add(SlidableAction(
            autoClose: false,
            borderRadius: BorderRadius.circular(5.0),
            backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
            foregroundColor: StateContainer.of(context).curTheme.warning60,
            icon: Icons.refresh_rounded,
            label: AppLocalization.of(context).retry,
            onPressed: (BuildContext context) async {
              // sleep for a bit to give the ripple effect time to finish
              await Future.delayed(Duration(milliseconds: 250));
              await resendMemo(context, txDetails);
              await Slidable.of(context).close();
            }));
      } else if (txDetails.is_message) {
        // TODO: resend message
        // _slideActions.add(SlidableAction(
        //     autoClose: false,
        //     borderRadius: BorderRadius.circular(5.0),
        //     backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        //     foregroundColor: StateContainer.of(context).curTheme.warning60,
        //     icon: Icons.refresh_rounded,
        //     label: AppLocalization.of(context).retry,
        //     onPressed: (BuildContext context) async {
        //       // sleep for a bit to give the ripple effect time to finish
        //       await Future.delayed(Duration(milliseconds: 250));
        //       await resendMessage(context, txDetails);
        //       await Slidable.of(context).close();
        //     }));
      }
    }

    if (isSolid) {
      _slideActions.add(SlidableAction(
          autoClose: false,
          borderRadius: BorderRadius.circular(5.0),
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          foregroundColor: StateContainer.of(context).curTheme.error60,
          icon: Icons.delete,
          label: AppLocalization.of(context).delete,
          onPressed: (BuildContext context) async {
            // sleep for a bit to give the ripple effect time to finish
            await Future.delayed(Duration(milliseconds: 250));
            await sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid);
            await StateContainer.of(context).updateSolids();
            await StateContainer.of(context).updateUnified(false);
            await Slidable.of(context).close();
          }));
    }

    ActionPane actionPane = ActionPane(
      // motion: const DrawerMotion(),
      // motion: const BehindMotion(),
      // motion: const DrawerMotion(),
      motion: const ScrollMotion(),
      extentRatio: _slideActions.length * 0.2,
      children: _slideActions,
    );

    return Slidable(
      enabled: slideEnabled,
      endActionPane: actionPane,
      child: _SizeTransitionNoClip(
        sizeFactor: animation,
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: [
            Container(
              margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.backgroundDark,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [setShadow],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: StateContainer.of(context).curTheme.text15,
                  backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                  padding: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                onPressed: () {
                  Sheets.showAppHeightEightSheet(context: context, widget: PaymentDetailsSheet(txDetails: txDetails), animationDurationMs: 175);
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                    // padding: const EdgeInsets.only(top: 14.0, bottom: 14.0, left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(margin: EdgeInsetsDirectional.only(end: 16.0), child: Icon(icon, color: iconColor, size: 20)),
                            Container(
                              constraints: BoxConstraints(maxWidth: 85),
                              // width: MediaQuery.of(context).size.width / 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  (!txDetails.is_message && !isEmpty(txDetails.amount_raw))
                                      ? Row(
                                          children: <Widget>[
                                            RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                text: '',
                                                children: [
                                                  displayCurrencyAmount(
                                                    context,
                                                    AppStyles.textStyleTransactionAmount(
                                                      context,
                                                      true,
                                                    ),
                                                    includeSymbol: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SubstringHighlight(
                                                caseSensitive: false,
                                                words: false,
                                                term: _searchController.text,
                                                text: getRawAsThemeAwareAmount(context, txDetails.amount_raw),
                                                textAlign: TextAlign.start,
                                                textStyle: AppStyles.textStyleTransactionAmount(context),
                                                textStyleHighlight: TextStyle(
                                                    fontFamily: "NunitoSans",
                                                    color: StateContainer.of(context).curTheme.warning60,
                                                    fontSize: AppFontSizes.smallest,
                                                    fontWeight: FontWeight.w600)),
                                          ],
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        (txDetails != null && txDetails.memo != null)
                            ? Container(
                                // constraints: BoxConstraints(maxWidth: 105),
                                // width: MediaQuery.of(context).size.width / 4.3,
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 4),
                                padding: EdgeInsets.only(left: 10, right: 10),
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
                                    text: txDetails.memo,
                                    textAlign: TextAlign.start,
                                    textStyle: AppStyles.textStyleTransactionMemo(context),
                                    textStyleHighlight: TextStyle(
                                      fontSize: AppFontSizes.smallest,
                                      fontFamily: 'OverpassMono',
                                      fontWeight: FontWeight.w100,
                                      color: StateContainer.of(context).curTheme.warning60,
                                    ),
                                    words: false),
                              )
                            : SizedBox(),
                        Container(
                          // width: MediaQuery.of(context).size.width / 4.0,
                          constraints: BoxConstraints(maxWidth: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Text(
                              //   displayName,
                              //   maxLines: 5,
                              //   textAlign: TextAlign.end,
                              //   style: AppStyles.textStyleTransactionAddress(context),
                              // ),
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
                              (transactionState != null)
                                  ? Container(
                                      margin: EdgeInsetsDirectional.only(
                                        top: 4,
                                      ),
                                      child: TransactionStateTag(transactionState: transactionState),
                                    )
                                  : SizedBox(),
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
            slideEnabled
                ? Container(
                    width: 4,
                    height: 30,
                    margin: EdgeInsets.only(right: 22),
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.text,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  } // Payment Card End

  List<dynamic> getPossibleTXDetails(BuildContext context, dynamic item) {
    bool isSolid = item is TXData;
    bool isRecipient = false;
    String account = "";
    String displayName;

    if (isSolid) {
      isRecipient = StateContainer.of(context).wallet.address == item.to_address;
    }

    if (isSolid) {
      // displayName =
      // smallScreen(context) ? indexedItem.getShorterString(isRecipient) : indexedItem.getShortString(isRecipient);
      displayName = item.getShortestString(isRecipient);
    } else {
      // slight change in structure:
      // displayName = smallScreen(context) ? indexedItem.getShorterString() : indexedItem.getShortString();
      displayName = item.getShortestString();
    }

    // displayName = displayName.substring(0, 5) + "\n" + displayName.substring(5, displayName.length);

    if (isSolid) {
      account = isRecipient ? item.from_address : item.to_address;
    } else {
      // slight change in structure:
      account = item.account ?? "";
    }

    // check if there's a username:
    for (User user in _users) {
      if (user.address == account.replaceAll("xrb_", "nano_")) {
        displayName = user.getDisplayName();
        break;
      }
    }

    // only do this if this is a regular tx:
    // find an associated memo for this tx:
    TXData txDetails;
    if (item is AccountHistoryResponseItem) {
      txDetails = _txDetailsMap[item.hash];
    }

    return [displayName, account, txDetails];
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

    dynamic indexedItem = _unifiedListMap[StateContainer.of(context).wallet.address][localIndex];
    String displayName;
    // String account;
    TXData txDetails;
    var res = getPossibleTXDetails(context, indexedItem);
    displayName = res[0];
    // account = res[1];
    txDetails = res[2];

    return _buildUnifiedCard(indexedItem, animation, displayName, context, txDetails: txDetails);
  }

  // Return widget for list
  Widget _getUnifiedListWidget(BuildContext context) {
    if (_noSearchResults) {
      return ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          children: <Widget>[
            // REMOTE MESSAGE CARD
            StateContainer.of(context).activeAlert != null ? _buildRemoteMessageCard(StateContainer.of(context).activeAlert) : SizedBox(),
            _buildNoSearchResultsCard(context),
          ],
        ),
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
      );
    }

    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet.historyLoading == false) {
      // Setup history list
      if (!_historyListMap.containsKey("${StateContainer.of(context).wallet.address}")) {
        setState(() {
          _historyListMap.putIfAbsent(StateContainer.of(context).wallet.address, () => StateContainer.of(context).wallet.history);
        });
      }
      // Setup payments list
      if (!_solidsListMap.containsKey("${StateContainer.of(context).wallet.address}")) {
        setState(() {
          _solidsListMap.putIfAbsent(StateContainer.of(context).wallet.address, () => StateContainer.of(context).wallet.solids);
        });
      }
      // Setup unified list
      if (!_unifiedListKeyMap.containsKey("${StateContainer.of(context).wallet.address}")) {
        _unifiedListKeyMap.putIfAbsent("${StateContainer.of(context).wallet.address}", () => GlobalKey<AnimatedListState>());
        setState(() {
          _unifiedListMap.putIfAbsent(
            StateContainer.of(context).wallet.address,
            () => ListModel<dynamic>(
              listKey: _unifiedListKeyMap["${StateContainer.of(context).wallet.address}"],
              initialItems: StateContainer.of(context).wallet.unified,
            ),
          );
        });
      }

      if (StateContainer.of(context).wallet.unifiedLoading ||
          (_unifiedListMap[StateContainer.of(context).wallet.address] != null && _unifiedListMap[StateContainer.of(context).wallet.address].length == 0)) {
        generateUnifiedList(fastUpdate: true);
      }
    }

    if (StateContainer.of(context).wallet == null || StateContainer.of(context).wallet.loading || StateContainer.of(context).wallet.unifiedLoading) {
      // Loading Animation
      return ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
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
    } else if (StateContainer.of(context).wallet.history.length == 0) {
      _disposeAnimation();
      return ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          children: <Widget>[
            // REMOTE MESSAGE CARD
            StateContainer.of(context).activeAlert != null ? _buildRemoteMessageCard(StateContainer.of(context).activeAlert) : SizedBox(),
            _buildWelcomeTransactionCard(context),
            _buildDummyTransactionCard(
                AppLocalization.of(context).sent, AppLocalization.of(context).exampleCardLittle, AppLocalization.of(context).exampleCardTo, context),
            _buildDummyTransactionCard(
                AppLocalization.of(context).received, AppLocalization.of(context).exampleCardLot, AppLocalization.of(context).exampleCardFrom, context),
            // _buildWelcomePaymentCard(context),
            _buildWelcomePaymentCardTwo(context),
            _buildDummyPaymentCard(
                AppLocalization.of(context).asked, AppLocalization.of(context).exampleCardLittle, AppLocalization.of(context).examplePaymentTo, context,
                isAcknowleged: true, isRequest: true, isFulfilled: true, memo: AppLocalization.of(context).examplePaymentFulfilledMemo),
            _buildDummyPaymentCard(
                AppLocalization.of(context).request, AppLocalization.of(context).exampleCardLot, AppLocalization.of(context).examplePaymentFrom, context,
                isAcknowleged: true, memo: AppLocalization.of(context).examplePaymentPendingMemo),
          ],
        ),
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
      );
    } else {
      _disposeAnimation();
    }

    if (StateContainer.of(context).activeAlert != null) {
      // Setup history list
      if (!_unifiedListKeyMap.containsKey("${StateContainer.of(context).wallet.address}alert")) {
        _unifiedListKeyMap.putIfAbsent("${StateContainer.of(context).wallet.address}alert", () => GlobalKey<AnimatedListState>());
        setState(() {
          _unifiedListMap.putIfAbsent(
            StateContainer.of(context).wallet.address,
            () => ListModel<dynamic>(
              listKey: _unifiedListKeyMap["${StateContainer.of(context).wallet.address}alert"],
              initialItems: StateContainer.of(context).wallet.unified,
            ),
          );
        });
      }
      return ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        child: AnimatedList(
          controller: _scrollController,
          key: _unifiedListKeyMap["${StateContainer.of(context).wallet.address}alert"],
          padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          initialItemCount: _unifiedListMap[StateContainer.of(context).wallet.address].length + 1,
          itemBuilder: _buildUnifiedItem,
        ),
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
      );
    }

    return ReactiveRefreshIndicator(
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      child: Scrollbar(
        child: AnimatedList(
          controller: _scrollController,
          key: _unifiedListKeyMap[StateContainer.of(context).wallet.address],
          padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          initialItemCount: _unifiedListMap[StateContainer.of(context).wallet.address].length,
          itemBuilder: _buildUnifiedItem,
        ),
      ),
      onRefresh: _refresh,
      isRefreshing: _isRefreshing,
    );
  }
}

/// This is used so that the elevation of the container is kept and the
/// drop shadow is not clipped.
///
class _SizeTransitionNoClip extends AnimatedWidget {
  final Widget child;

  const _SizeTransitionNoClip({@required Animation<double> sizeFactor, this.child}) : super(listenable: sizeFactor);

  @override
  Widget build(BuildContext context) {
    return new Align(
      alignment: const AlignmentDirectional(-1.0, -1.0),
      widthFactor: null,
      heightFactor: (this.listenable as Animation<double>).value,
      child: child,
    );
  }
}

class PaymentDetailsSheet extends StatefulWidget {
  final TXData txDetails;

  PaymentDetailsSheet({this.txDetails}) : super();

  _PaymentDetailsSheetState createState() => _PaymentDetailsSheetState();
}

class _PaymentDetailsSheetState extends State<PaymentDetailsSheet> {
  // Current state references
  bool _linkCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _linkCopiedTimer;
  // Current state references
  bool _seedCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _seedCopiedTimer;
  // address copied
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  @override
  Widget build(BuildContext context) {
    // check if recipient of the request
    // also check if the request is fulfilled
    bool is_unfulfilled_payable_request = false;
    bool is_unacknowledged_sendable_request = false;
    bool is_unacknowledged_memo = false;
    bool resendable_memo = false;
    bool is_gift_load = false;
    bool is_gift = false;

    var txDetails = widget.txDetails;

    String walletAddress = StateContainer.of(context).wallet.address;

    if (walletAddress == txDetails.to_address) {
      txDetails.is_acknowledged = true;
    }

    if (walletAddress == txDetails.to_address && txDetails.is_request && !txDetails.is_fulfilled) {
      is_unfulfilled_payable_request = true;
    }
    if (walletAddress == txDetails.from_address && txDetails.is_request && !txDetails.is_acknowledged) {
      is_unacknowledged_sendable_request = true;
    }

    if (txDetails.is_memo) {
      if (txDetails.status == StatusTypes.CREATE_FAILED) {
        resendable_memo = true;
      }
      if (!txDetails.is_acknowledged && txDetails.memo.isNotEmpty) {
        is_unacknowledged_memo = true;
        resendable_memo = true;
      }
    }

    String walletSeed;
    String sharableLink;
    // if (widget.is_gift) {}

    if (txDetails.record_type == RecordTypes.GIFT_LOAD) {
      is_gift_load = true;

      // Get the wallet seed by splitting the metadata by :
      List<String> metadataList = txDetails.metadata.split(RecordTypes.SEPARATOR);
      walletSeed = metadataList[0];
      sharableLink = metadataList[1];
    }

    String addressToCopy = txDetails.to_address;
    if (txDetails.to_address == StateContainer.of(context).wallet.address) {
      addressToCopy = txDetails.from_address;
    }

    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                // A row for View Details button
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).viewDetails, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                        return UIUtil.showBlockExplorerWebview(context, txDetails.block);
                      }));
                    }),
                  ],
                ),
                // A stack for Copy Address and Add Contact buttons
                Stack(
                  children: <Widget>[
                    // A row for Copy Address Button
                    Row(
                      children: <Widget>[
                        AppButton.buildAppButton(
                            context,
                            // Share Address Button
                            _addressCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                            _addressCopied ? AppLocalization.of(context).addressCopied : AppLocalization.of(context).copyAddress,
                            Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                          Clipboard.setData(new ClipboardData(text: addressToCopy));
                          if (mounted) {
                            setState(() {
                              // Set copied style
                              _addressCopied = true;
                            });
                          }
                          if (_addressCopiedTimer != null) {
                            _addressCopiedTimer.cancel();
                          }
                          _addressCopiedTimer = new Timer(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              setState(() {
                                _addressCopied = false;
                              });
                            }
                          });
                        }),
                      ],
                    ),
                    // A row for Add Contact Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsetsDirectional.only(top: Dimens.BUTTON_TOP_EXCEPTION_DIMENS[1], end: Dimens.BUTTON_TOP_EXCEPTION_DIMENS[2]),
                          child: Container(
                              height: 55,
                              width: 55,
                              // Add Contact Button
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Sheets.showAppHeightEightSheet(context: context, widget: AddContactSheet(address: addressToCopy));
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                                child: Icon(AppIcons.addcontact,
                                    size: 35,
                                    color:
                                        _addressCopied ? StateContainer.of(context).curTheme.successDark : StateContainer.of(context).curTheme.backgroundDark),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),

                // Mark as paid / unpaid button for requests
                (txDetails.is_request)
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context,
                              // Share Address Button
                              AppButtonType.PRIMARY_OUTLINE,
                              !txDetails.is_fulfilled ? AppLocalization.of(context).markAsPaid : AppLocalization.of(context).markAsUnpaid,
                              Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                            // update the tx in the db:
                            if (txDetails.is_fulfilled) {
                              sl.get<DBHelper>().changeTXFulfillmentStatus(txDetails.uuid, false);
                            } else {
                              sl.get<DBHelper>().changeTXFulfillmentStatus(txDetails.uuid, true);
                            }
                            // setState(() {});
                            StateContainer.of(context).updateSolids();
                            Navigator.of(context).pop();
                          }),
                        ],
                      )
                    : SizedBox(),

                // pay this request button:
                is_unfulfilled_payable_request
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).payRequest, Dimens.BUTTON_TOP_EXCEPTION_DIMENS,
                              onPressed: () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                            _AppHomePageState.payTX(context, txDetails);
                          }),
                        ],
                      )
                    : SizedBox(),

                // block this user from sending you requests:
                (txDetails.is_request && StateContainer.of(context).wallet.address != txDetails.from_address)
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).blockUser, Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                            Sheets.showAppHeightNineSheet(
                                context: context,
                                widget: AddBlockedSheet(
                                  address: txDetails.from_address,
                                ));
                          }),
                        ],
                      )
                    : SizedBox(),

                // re-send request button:
                is_unacknowledged_sendable_request
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).sendRequestAgain, Dimens.BUTTON_TOP_EXCEPTION_DIMENS,
                              onPressed: () async {
                            // send the request again:
                            _AppHomePageState.resendRequest(context, txDetails);
                          }),
                        ],
                      )
                    : SizedBox(),
                // re-send memo button
                (resendable_memo)
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context,
                              // Share Address Button
                              AppButtonType.PRIMARY_OUTLINE,
                              AppLocalization.of(context).resendMemo,
                              Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () async {
                            _AppHomePageState.resendMemo(context, txDetails);
                          }),
                        ],
                      )
                    : SizedBox(),
                // delete this request button
                txDetails.is_request
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).deleteRequest, Dimens.BUTTON_TOP_EXCEPTION_DIMENS,
                              onPressed: () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
                            sl.get<DBHelper>().deleteTXDataByUUID(txDetails.uuid);
                            StateContainer.of(context).updateSolids();
                          }),
                        ],
                      )
                    : SizedBox(),
                is_gift_load
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context,
                              // copy link button
                              _linkCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                              _linkCopied ? AppLocalization.of(context).linkCopied : AppLocalization.of(context).copyLink,
                              Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                            Clipboard.setData(new ClipboardData(text: sharableLink));
                            setState(() {
                              // Set copied style
                              _linkCopied = true;
                            });
                            if (_linkCopiedTimer != null) {
                              _linkCopiedTimer.cancel();
                            }
                            _linkCopiedTimer = new Timer(const Duration(milliseconds: 800), () {
                              setState(() {
                                _linkCopied = false;
                              });
                            });
                          }),
                        ],
                      )
                    : SizedBox(),
                is_gift_load
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context,
                              // copy seed button
                              _seedCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                              _seedCopied ? AppLocalization.of(context).seedCopied : AppLocalization.of(context).copySeed,
                              Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                            Clipboard.setData(new ClipboardData(text: walletSeed));
                            setState(() {
                              // Set copied style
                              _seedCopied = true;
                            });
                            if (_seedCopiedTimer != null) {
                              _seedCopiedTimer.cancel();
                            }
                            _seedCopiedTimer = new Timer(const Duration(milliseconds: 800), () {
                              setState(() {
                                _seedCopied = false;
                              });
                            });
                          }),
                        ],
                      )
                    : SizedBox(),
                is_gift_load
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context,
                              // share link button
                              AppButtonType.PRIMARY,
                              AppLocalization.of(context).shareLink,
                              Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                            Share.share(sharableLink);
                          }),
                        ],
                      )
                    : SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
