import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:logger/logger.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:manta_dart/messages.dart';
import 'package:nautilus_wallet_flutter/bus/payments_home_event.dart';
import 'package:nautilus_wallet_flutter/bus/unified_home_event.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/blocked.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:nautilus_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:nautilus_wallet_flutter/ui/popup_button.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/list_model.dart';
import 'package:nautilus_wallet_flutter/model/db/contact.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/network/model/block_types.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/ui/contacts/add_contact.dart';
import 'package:nautilus_wallet_flutter/ui/request/request_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/settings_drawer.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_manual_entry_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/users/add_blocked.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/list_slidable.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/reactive_refresh.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/transaction_state_tag.dart';
import 'package:nautilus_wallet_flutter/util/manta.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/user_data_util.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:share/share.dart';

class AppHomePage extends StatefulWidget {
  PriceConversion priceConversion;

  AppHomePage({this.priceConversion}) : super();

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin, FlareController {
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
  final Map<String, GlobalKey<AnimatedListState>> _historyListKeyMap = Map();
  // final Map<String, ListModel<AccountHistoryResponseItem>> _historyListMap = Map();
  final Map<String, ListModel<dynamic>> _historyListMap = Map();

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _requestsListKeyMap = Map();
  // final Map<String, ListModel<TXData>> _paymentsListMap = Map();
  final Map<String, ListModel<dynamic>> _requestsListMap = Map();

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _unifiedListKeyMap = Map();
  final Map<String, ListModel<dynamic>> _unifiedListMap = Map();

  // used to associate memos with blocks so we don't have search on every re-render:
  final Map<String, TXData> _txDetailsMap = Map();

  // List of contacts (Store it so we only have to query the DB once for transaction cards)
  List<Contact> _contacts = List();
  List<Blocked> _blocked = List();
  List<User> _users = List();
  List<TXData> _txData = List();
  List<TXData> _txRecords = List();

  // Price conversion state (BTC, NANO, NONE)
  PriceConversion _priceConversion;

  bool _isRefreshing = false;

  bool _isPaymentsRefreshing = false;
  bool _lockDisabled = false; // whether we should avoid locking the app
  bool _lockTriggered = false;

  // Main card height
  double mainCardHeight;
  double settingsIconMarginTop = 5;
  // FCM instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Animation for swiping to send
  ActorAnimation _sendSlideAnimation;
  ActorAnimation _sendSlideReleaseAnimation;
  double _fanimationPosition;
  bool releaseAnimation = false;

  void initialize(FlutterActorArtboard actor) {
    _fanimationPosition = 0.0;
    _sendSlideAnimation = actor.getAnimation("pull");
    _sendSlideReleaseAnimation = actor.getAnimation("release");
  }

  void setViewTransform(Mat2D viewTransform) {}

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if (releaseAnimation) {
      _sendSlideReleaseAnimation.apply(_sendSlideReleaseAnimation.duration * (1 - _fanimationPosition), artboard, 1.0);
    } else {
      _sendSlideAnimation.apply(_sendSlideAnimation.duration * _fanimationPosition, artboard, 1.0);
    }
    return true;
  }

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

  Future<void> _autoImportDialog(String seed) async {
    switch (await showDialog<bool>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalization.of(context).autoImport,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: /*AppLocalization.of(context).importMessage*/ Text(
                "You appear to have a wallet seed in your clipboard, would you like to search it for funds to import to this wallet?"),
            actions: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).no,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).yes,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case true:
        AppTransferOverviewSheet().mainBottomSheet(context, quickSeed: seed);
        break;
      case false:
        break;
    }
  }

  Future<void> _branchGiftDialog(String seed, String memo, String amountRaw, String senderAddress) async {
    String amount = getRawAsThemeAwareAmount(context, amountRaw);

    String userOrSendAddress;

    // change address to username if it exists:
    User user = await sl.get<DBHelper>().getUserWithAddress(senderAddress);
    if (user != null) {
      userOrSendAddress = user.username;
    } else {
      userOrSendAddress = senderAddress;
    }

    // check if there's actually any nano to claim:
    Map<String, AccountBalanceItem> privKeyBalanceMap = await AppTransferOverviewSheet().getGiftCardBalance(context, seed);
    // AppTransferOverviewSheet().startAutoTransfer(context, seed, StateContainer.of(context).wallet);
    try {
      if (privKeyBalanceMap != null) {
        // show dialog with option to refund to sender:
        switch (await showDialog<bool>(
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
                        : Container(),
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
                            text: amount,
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
                        AppLocalization.of(context).refund,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  ),
                  AppSimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        AppLocalization.of(context).receive,
                        style: AppStyles.textStyleDialogOptions(context),
                      ),
                    ),
                  ),
                ],
              );
            })) {
          case true:
            // transfer to this wallet:
            // await AppTransferConfirmSheet().createState().autoProcessWallets(privKeyBalanceMap, StateContainer.of(context).wallet);
            await AppTransferOverviewSheet().startAutoTransfer(context, seed, StateContainer.of(context).wallet);
            break;
          case false:
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
                        : Container(),
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
                            text: amount,
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
      settingsIconMarginTop = 7;
    } else if (_priceConversion == PriceConversion.NONE) {
      mainCardHeight = 64;
      settingsIconMarginTop = 7;
    } else if (_priceConversion == PriceConversion.HIDDEN) {
      mainCardHeight = 64;
      settingsIconMarginTop = 7;
    }
    _addSampleContact();
    _updateContacts();
    _updateUsers();
    _updateTXData();
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
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      try {
        await _chooseCorrectAccountFromNotification(message.data);
        await _processPaymentRequestNotification(message.data);
      } catch (e) {}
    });
    // Setup notification
    getNotificationPermissions();
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
      bool addressExists = await sl.get<DBHelper>().contactExistsWithAddress("nano_37y6iq8m1zx9inwkkcgqh34kqsihzpjfwgp9jir8xpb9jrcwhkmoxpo61f4o");
      if (addressExists) {
        return;
      }
      bool nameExists = await sl.get<DBHelper>().contactExistsWithName("NautilusDonations");
      if (nameExists) {
        return;
      }
      await sl.get<SharedPrefsUtil>().setFirstContactAdded(true);
      Contact c = Contact(name: "NautilusDonations", address: "nano_37y6iq8m1zx9inwkkcgqh34kqsihzpjfwgp9jir8xpb9jrcwhkmoxpo61f4o");
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

  bool isEmptyOrNull(String s) {
    if (s == null || s.isEmpty) {
      return true;
    }
    return false;
  }

  void _updateTXDetailsMap(String account) {
    sl.get<DBHelper>().getAccountSpecificRecords(account).then((data) {
      setState(() {
        _txRecords = data;
        _txDetailsMap.clear();
        for (var tx in _txRecords) {
          if (tx.is_request) {
            continue;
          }
          // if (tx.block != null && tx.block.isNotEmpty) {
          //   _txDetailsMap[tx.block] = tx;
          // }
          print("memo: ${tx.memo} send_block ${tx.send_block} recv_block ${tx.recv_block}");
          if (isEmptyOrNull(tx.recv_block) && tx.send_block != null) {
            // find if there's a matching recv_block:
            for (var histItem in StateContainer.of(context).wallet.history) {
              // print(histItem.link);
              if (histItem.link == tx.send_block) {
                // found match:
                print("found match: ${tx.send_block} ${histItem.link}");
                tx.recv_block = histItem.hash;
                // save to db:
                sl.get<DBHelper>().replaceTXDataByUUID(tx);
                break;
              }
              // if (tx2.send_block == tx.send_block && tx2.recv_block != null) {
              //   _txDetailsMap[tx.send_block] = tx;
              //   break;
              // }
            }
          }

          if (tx.send_block != null && tx.from_address == account) {
            _txDetailsMap[tx.send_block] = tx;
          } else if (tx.recv_block != null && tx.to_address == account) {
            _txDetailsMap[tx.recv_block] = tx;
          }

          // if (tx.memo != null && tx.memo.isNotEmpty && tx.block != null && tx.block.isNotEmpty) {
          //   _memoMap[tx.block] = tx.memo;
          // }
        }
      });
    });
  }

  StreamSubscription<ConfirmationHeightChangedEvent> _confirmEventSub;
  StreamSubscription<HistoryHomeEvent> _historySub;
  StreamSubscription<PaymentsHomeEvent> _paymentsSub;
  StreamSubscription<UnifiedHomeEvent> _unifiedSub;
  StreamSubscription<ContactModifiedEvent> _contactModifiedSub;
  StreamSubscription<DisableLockTimeoutEvent> _disableLockSub;
  StreamSubscription<AccountChangedEvent> _switchAccountSub;

  void _registerBus() {
    _historySub = EventTaxiImpl.singleton().registerTo<HistoryHomeEvent>().listen((event) {
      diffAndUpdateHistoryList(event.items);
      // update tx memo's
      if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet.address != null) {
        _updateTXDetailsMap(StateContainer.of(context).wallet.address);
      }
      setState(() {
        _isRefreshing = false;
      });
      // handle deep links:
      if (StateContainer.of(context).initialDeepLink != null) {
        handleDeepLink(StateContainer.of(context).initialDeepLink);
        StateContainer.of(context).initialDeepLink = null;
      }
    });
    _paymentsSub = EventTaxiImpl.singleton().registerTo<PaymentsHomeEvent>().listen((event) {
      diffAndUpdatePaymentList(event.items);
    });
    _unifiedSub = EventTaxiImpl.singleton().registerTo<UnifiedHomeEvent>().listen((event) {
      generateUnifiedList();
      setState(() {
        _isRefreshing = false;
      });
    });
    _contactModifiedSub = EventTaxiImpl.singleton().registerTo<ContactModifiedEvent>().listen((event) {
      _updateContacts();
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
        StateContainer.of(context).wallet.requestsLoading = true;
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

    // get pending background events:
    ReceivePort _port = ReceivePort();
    IsolateNameServer.registerPortWithName(_port.sendPort, "background_message");
    _port.listen((dynamic data) {
      StateContainer.of(context).handleMessage(data);
    });
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
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
    if (_disableLockSub != null) {
      _disableLockSub.cancel();
    }
    if (_switchAccountSub != null) {
      _switchAccountSub.cancel();
    }
    if (_confirmEventSub != null) {
      _confirmEventSub.cancel();
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
    for (int i = 0; i < _historyListMap[StateContainer.of(context).wallet.address].items.length; i++) {
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
        // handle any pending messages:
        getPendingMessages();

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
    await StateContainer.of(context).updateRequests();
    _updateTXData();
    _updateTXDetailsMap(StateContainer.of(context).wallet.address);
    generateUnifiedList();
    setState(() {});
    // Hide refresh indicator after 2 seconds
    Future.delayed(new Duration(seconds: 2), () {
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
  void diffAndUpdateHistoryList(List<AccountHistoryResponseItem> newList) {
    if (newList == null || newList.length == 0 || _historyListMap[StateContainer.of(context).wallet.address] == null) {
      return;
    }

    _historyListMap[StateContainer.of(context).wallet.address].items.clear();
    _historyListMap[StateContainer.of(context).wallet.address].items.addAll(newList);

    // Re-subscribe if missing data
    if (StateContainer.of(context).wallet.loading) {
      StateContainer.of(context).requestSubscribe();
    } else {
      updateConfirmationHeights(StateContainer.of(context).wallet.confirmationHeight);
    }
  }

  void diffAndUpdatePaymentList(List<TXData> newList) {
    if (newList == null || newList.length == 0 || _requestsListMap[StateContainer.of(context).wallet.address] == null) {
      return;
    }

    _requestsListMap[StateContainer.of(context).wallet.address].items.clear();
    _requestsListMap[StateContainer.of(context).wallet.address].items.addAll(newList);
  }

  /// Desired relation | Result
  /// -------------------------------------------
  ///           a < b  | Returns a negative value.
  ///           a == b | Returns 0.
  ///           a > b  | Returns a positive value.
  ///
  int mySortComparison(dynamic a, dynamic b) {
    int propertyA = a.height;
    int propertyB = b.height;
    if (propertyA == null || propertyB == null) {
      // this shouldn't happen but it does if there's a bug:
      // throw new Exception("Null height in comparison");
      // TODO:
      propertyA = 0;
      propertyB = 0;
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

    if (a is TXData) {
      if (a.send_height != null && a.from_address == StateContainer.of(context).wallet.address) {
        propertyA = a.send_height;
      }
      if (a.recv_height != null && a.to_address == StateContainer.of(context).wallet.address) {
        propertyA = a.recv_height;
      }
    }

    if (b is TXData) {
      if (b.send_height != null && b.from_address == StateContainer.of(context).wallet.address) {
        propertyB = b.send_height;
      }
      if (b.recv_height != null && b.to_address == StateContainer.of(context).wallet.address) {
        propertyB = b.recv_height;
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

  Future<void> generateUnifiedList() async {
    if (_historyListMap[StateContainer.of(context).wallet.address] == null ||
        _requestsListMap[StateContainer.of(context).wallet.address] == null ||
        _unifiedListMap[StateContainer.of(context).wallet.address] == null) {
      return;
    }

    // this isn't performant but w/e
    List<dynamic> unifiedList = [];

    // combine history and payments:
    List<AccountHistoryResponseItem> historyList = StateContainer.of(context).wallet.history;
    List<TXData> requestsList = StateContainer.of(context).wallet.requests;

    // add both to the unified list:
    unifiedList.addAll(historyList);
    unifiedList.addAll(requestsList);

    // sort by timestamp

    unifiedList.sort(mySortComparison);

    // print index:height
    // for (int i = 0; i < unifiedList.length; i++) {
    //   // if (unifiedList[i].hash == "B5D90E90C8B5BB1E67A2B1D3A83B75163211ED4FD361609459D442A300D6893E") {
    //   //   print("first");
    //   //   print("index: ${i} height: ${unifiedList[i].height}");
    //   // }
    //   // if (unifiedList[i].hash == "9E1523555152ADBBE9A7E09761A170D84F9F9EA1194553B9F3637D2E9A57110A") {
    //   //   print("2nd");
    //   //   print("index: ${i} height: ${unifiedList[i].height}");
    //   // }
    //   // print("${i}:${unifiedList[i].amount}:${unifiedList[i].height}");
    //   // _unifiedListMap[StateContainer.of(context).wallet.address].insertAtTop(unifiedList[i]);
    // }

    // create a list of indices to remove:
    List<int> removeIndices = [];
    _unifiedListMap[StateContainer.of(context).wallet.address].items.where((item) => !unifiedList.contains(item)).forEach((dynamicItem) {
      removeIndices.add(_unifiedListMap[StateContainer.of(context).wallet.address].items.indexOf(dynamicItem));
    });

    // remove from the listmap:
    for (int i = removeIndices.length - 1; i >= 0; i--) {
      setState(() {
        _unifiedListMap[StateContainer.of(context).wallet.address].removeAt(removeIndices[i], _buildUnifiedItem);
      });
    }

    // insert unifiedList into listmap:
    unifiedList.where((item) => !_unifiedListMap[StateContainer.of(context).wallet.address].items.contains(item)).forEach((dynamicItem) {
      setState(() {
        int index = unifiedList.indexOf(dynamicItem);
        if (index > -1 && dynamicItem != null) {
          _unifiedListMap[StateContainer.of(context).wallet.address].insertAt(dynamicItem, index);
        }
        // _unifiedListMap[StateContainer.of(context).wallet.address].insertAtTop(dynamicItem);
      });
    });
  }

  Future<void> handleDeepLink(link) async {
    log.d("handleDeepLink: $link");
    Address address = Address(link);
    if (address.isValid()) {
      String amount;
      String contactName;
      bool sufficientBalance = false;
      if (address.amount != null) {
        BigInt amountBigInt = BigInt.tryParse(address.amount);
        // Require minimum 1 rai to send, and make sure sufficient balance
        if (amountBigInt != null && amountBigInt >= BigInt.from(10).pow(24)) {
          if (StateContainer.of(context).wallet.accountBalance > amountBigInt) {
            sufficientBalance = true;
          }
          amount = address.amount;
        }
      }
      // See if a contact
      Contact contact = await sl.get<DBHelper>().getContactWithAddress(address.address);
      if (contact != null) {
        contactName = contact.name;
      }
      // Remove any other screens from stack
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      if (amount != null && sufficientBalance) {
        // Go to send confirm with amount
        Sheets.showAppHeightNineSheet(context: context, widget: SendConfirmSheet(amountRaw: amount, destination: address.address, contactName: contactName));
      } else {
        // Go to send with address
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(
                localCurrency: StateContainer.of(context).curCurrency,
                contact: contact,
                address: address.address,
                quickSendAmount: amount != null ? amount : null));
      }
    } else if (MantaWallet.parseUrl(link) != null) {
      // Manta URI handling
      try {
        _showMantaAnimation();
        // Get manta payment request
        MantaWallet manta = MantaWallet(link);
        PaymentRequestMessage paymentRequest = await MantaUtil.getPaymentDetails(manta);
        if (mantaAnimationOpen) {
          Navigator.of(context).pop();
        }
        MantaUtil.processPaymentRequest(context, manta, paymentRequest);
      } catch (e) {
        if (mantaAnimationOpen) {
          Navigator.of(context).pop();
        }
        UIUtil.showSnackbar(AppLocalization.of(context).mantaError, context);
      }
    }
  }

  // branch deep link gift:
  Future<void> handleBranchGift() async {
    if (StateContainer.of(context).giftedWallet && StateContainer.of(context).wallet != null) {
      StateContainer.of(context).giftedWallet = false;
      _branchGiftDialog(StateContainer.of(context).giftedWalletSeed, StateContainer.of(context).giftedWalletMemo,
          StateContainer.of(context).giftedWalletAmountRaw, StateContainer.of(context).giftedWalletAddress);
    }
  }

  void _showMantaAnimation() {
    mantaAnimationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.MANTA, StateContainer.of(context).curTheme.animationOverlayStrong, StateContainer.of(context).curTheme.animationOverlayMedium,
        onPoppedCallback: () => mantaAnimationOpen = false));
  }

  void paintQrCode({String address}) {
    QrPainter painter = QrPainter(
      data: address == null ? StateContainer.of(context).wallet.address : address,
      version: 6,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
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
      drawerEdgeDragWidth: 200,
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
                      // //Payments Text
                      // Container(
                      //   margin: EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 26.0, 0.0),
                      //   child: Row(
                      //     children: <Widget>[
                      //       Text(
                      //         CaseChange.toUpperCase(AppLocalization.of(context).payments, context),
                      //         textAlign: TextAlign.start,
                      //         style: TextStyle(
                      //           fontSize: 14.0,
                      //           fontWeight: FontWeight.w100,
                      //           color: StateContainer.of(context).curTheme.text,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ), //Payments Text End
                      // //Payments List
                      // Expanded(
                      //   child: Stack(
                      //     children: <Widget>[
                      //       _getPaymentsListWidget(context),
                      //       //List Top Gradient End
                      //       Align(
                      //         alignment: Alignment.topCenter,
                      //         child: Container(
                      //           height: 10.0,
                      //           width: double.infinity,
                      //           decoration: BoxDecoration(
                      //             gradient: LinearGradient(
                      //               colors: [
                      //                 StateContainer.of(context).curTheme.background00,
                      //                 StateContainer.of(context).curTheme.background
                      //               ],
                      //               begin: AlignmentDirectional(0.5, 1.0),
                      //               end: AlignmentDirectional(0.5, -1.0),
                      //             ),
                      //           ),
                      //         ),
                      //       ), // List Top Gradient End
                      //       //List Bottom Gradient
                      //       Align(
                      //         alignment: Alignment.bottomCenter,
                      //         child: Container(
                      //           height: 30.0,
                      //           width: double.infinity,
                      //           decoration: BoxDecoration(
                      //             gradient: LinearGradient(
                      //               colors: [
                      //                 StateContainer.of(context).curTheme.background00,
                      //                 StateContainer.of(context).curTheme.background
                      //               ],
                      //               begin: AlignmentDirectional(0.5, -1),
                      //               end: AlignmentDirectional(0.5, 0.5),
                      //             ),
                      //           ),
                      //         ),
                      //       ), //List Bottom Gradient End
                      //     ],
                      //   ),
                      // ), //Payments List End
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
                        width: (MediaQuery.of(context).size.width - 42) / 2,
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
                  textAlign: TextAlign.center,
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

  //Main Card
  Widget _buildMainCard(BuildContext context, _scaffoldKey) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      margin: EdgeInsets.only(left: 14.0, right: 14.0, top: MediaQuery.of(context).size.height * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
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
            height: mainCardHeight,
            curve: Curves.easeInOut,
            child: _getBalanceWidget(),
          ),
          // natricon
          (StateContainer.of(context).nyanoMode)
              ? (StateContainer.of(context).nyaniconOn
                  ? AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: mainCardHeight == 64 ? 60 : 74,
                      height: mainCardHeight == 64 ? 60 : 74,
                      margin: EdgeInsets.only(right: 2),
                      alignment: Alignment(0, 0),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              // nyanicon
                              child: Hero(
                                tag: "avatar",
                                child: StateContainer.of(context).selectedAccount.address != null
                                    ? Image(image: AssetImage("assets/nyano/images/logos/cat-head-collar-black-1000 × 1180.png"))
                                    : SizedBox(),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              color: Colors.transparent,
                              child: FlatButton(
                                onPressed: () {
                                  // Navigator.of(context).pushNamed('/avatar_page');
                                },
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                highlightColor: StateContainer.of(context).curTheme.text15,
                                splashColor: StateContainer.of(context).curTheme.text15,
                                padding: EdgeInsets.all(0.0),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 80.0,
                      height: mainCardHeight,
                    ))
              : (StateContainer.of(context).natriconOn
                  ? AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: mainCardHeight == 64 ? 60 : 74,
                      height: mainCardHeight == 64 ? 60 : 74,
                      margin: EdgeInsets.only(right: 2),
                      alignment: Alignment(0, 0),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              // natricon
                              child: Hero(
                                tag: "avatar",
                                child: StateContainer.of(context).selectedAccount.address != null
                                    ? SvgPicture.network(
                                        UIUtil.getNatriconURL(StateContainer.of(context).selectedAccount.address,
                                            StateContainer.of(context).getNatriconNonce(StateContainer.of(context).selectedAccount.address)),
                                        key: Key(UIUtil.getNatriconURL(StateContainer.of(context).selectedAccount.address,
                                            StateContainer.of(context).getNatriconNonce(StateContainer.of(context).selectedAccount.address))),
                                        placeholderBuilder: (BuildContext context) => Container(
                                          child: FlareActor(
                                            "legacy_assets/ntr_placeholder_animation.flr",
                                            animation: "main",
                                            fit: BoxFit.contain,
                                            color: StateContainer.of(context).curTheme.primary,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              color: Colors.transparent,
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/avatar_page');
                                },
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                highlightColor: StateContainer.of(context).curTheme.text15,
                                splashColor: StateContainer.of(context).curTheme.text15,
                                padding: EdgeInsets.all(0.0),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 80.0,
                      height: mainCardHeight,
                    ))
        ],
      ),
    );
  } //Main Card

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
            settingsIconMarginTop = 7;
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
        width: MediaQuery.of(context).size.width - 190,
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
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 205),
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
      icon = AppIcons.sent;
    } else {
      text = AppLocalization.of(context).requested;
      icon = AppIcons.received;
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
                  width: MediaQuery.of(context).size.width / 4.3,
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

// Transaction Card/List Item
  Widget _buildUnifiedCard(dynamic item, Animation<double> animation, String displayName, BuildContext context, {TXData txDetails}) {
    String text;
    IconData icon;
    Color iconColor;

    bool isPaymentRequest = item is TXData;
    bool isTransaction = item is AccountHistoryResponseItem;
    bool isRecipient = false;
    bool isGift = false;

    if (isPaymentRequest) {
      isRecipient = StateContainer.of(context).wallet.address == item.to_address;
    }

    if (txDetails != null) {
      if (txDetails.record_type == "gift" ||
          txDetails.record_type == "gift_ack" ||
          txDetails.record_type == "gift_receive" ||
          txDetails.record_type == "gift_load") {
        isGift = true;
      }
    }

    // set icon color:
    if (isPaymentRequest) {
      if (isRecipient) {
        text = AppLocalization.of(context).request;
        icon = AppIcons.call_made;
        iconColor = StateContainer.of(context).curTheme.text60;
      } else {
        text = AppLocalization.of(context).requested;
        icon = AppIcons.call_received;
        iconColor = StateContainer.of(context).curTheme.primary60;
      }
    } else if (isTransaction) {
      if (isGift) {
        if (txDetails.record_type == "gift_load") {
          text = AppLocalization.of(context).loaded;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else if (txDetails.record_type == "gift_receive") {
          text = AppLocalization.of(context).opened;
          icon = AppIcons.transferfunds;
          iconColor = StateContainer.of(context).curTheme.primary60;
        } else {
          throw "something went wrong with gift type";
        }
      } else {
        if (item.type == BlockTypes.SEND) {
          text = AppLocalization.of(context).sent;
          icon = AppIcons.sent;
          iconColor = StateContainer.of(context).curTheme.text60;
        } else {
          text = AppLocalization.of(context).received;
          icon = AppIcons.received;
          iconColor = StateContainer.of(context).curTheme.primary60;
        }
      }
    }

    BoxShadow setShadow;

    // set box shadow color:
    if (isPaymentRequest) {
      if (!item.is_acknowledged && !item.is_fulfilled) {
        iconColor = StateContainer.of(context).curTheme.error60;
        setShadow = BoxShadow(
          color: StateContainer.of(context).curTheme.error60.withOpacity(0.2),
          offset: Offset(0, 0),
          blurRadius: 0,
          spreadRadius: 1,
        );
      } else if (!item.is_fulfilled) {
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
    } else {
      if (txDetails != null && txDetails.memo.isNotEmpty && !isGift) {
        if (txDetails.is_acknowledged) {
          setShadow = BoxShadow(
            color: StateContainer.of(context).curTheme.primary60.withOpacity(0.2),
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 1,
          );
        } else {
          // set warning color if memo isn't acknowledged
          setShadow = BoxShadow(
            color: StateContainer.of(context).curTheme.warning60.withOpacity(0.2),
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 1,
          );
        }
      } else {
        // normal transaction:
        setShadow = StateContainer.of(context).curTheme.boxShadow;
      }
    }

    bool slideEnabled = false;
    // valid wallet:
    if (StateContainer.of(context).wallet != null && StateContainer.of(context).wallet.accountBalance > BigInt.zero) {
      // does it make sense to make it slideable?
      if (isPaymentRequest && isRecipient && !item.is_fulfilled) {
        slideEnabled = true;
      } else if (!isGift) {
        slideEnabled = true;
      }
    }

    if (isPaymentRequest) {
      return Slidable(
        delegate: SlidableScrollDelegate(),
        actionExtentRatio: 0.35,
        movementDuration: Duration(milliseconds: 300),
        enabled: slideEnabled,
        onTriggered: (preempt) {
          if (preempt) {
            setState(() {
              releaseAnimation = true;
            });
          } else {
            // See if a contact
            sl.get<DBHelper>().getContactWithAddress(item.from_address).then((contact) {
              // Go to send with address
              Sheets.showAppHeightNineSheet(
                  context: context,
                  widget: SendSheet(
                    localCurrency: StateContainer.of(context).curCurrency,
                    contact: contact,
                    address: item.from_address,
                    quickSendAmount: item.amount_raw,
                  ));
            });
          }
        },
        onAnimationChanged: (animation) {
          if (animation != null) {
            _fanimationPosition = animation.value;
            if (animation.value == 0.0 && releaseAnimation) {
              setState(() {
                releaseAnimation = false;
              });
            }
          }
        },
        secondaryActions: <Widget>[
          SlideAction(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              margin: EdgeInsetsDirectional.only(end: MediaQuery.of(context).size.width * 0.15, top: 4, bottom: 4),
              child: Container(
                alignment: AlignmentDirectional(-0.5, 0),
                constraints: BoxConstraints.expand(),
                child: FlareActor("legacy_assets/pulltosend_animation.flr",
                    animation: "pull", fit: BoxFit.contain, controller: this, color: StateContainer.of(context).curTheme.primary),
              ),
            ),
          ),
        ],
        child: _SizeTransitionNoClip(
          sizeFactor: animation,
          child: Container(
            margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
            decoration: BoxDecoration(
              color: StateContainer.of(context).curTheme.backgroundDark,
              borderRadius: BorderRadius.circular(10.0),
              // boxShadow: [StateContainer.of(context).curTheme.boxShadow],
              boxShadow: [setShadow],
            ),
            child: FlatButton(
              highlightColor: StateContainer.of(context).curTheme.text15,
              splashColor: StateContainer.of(context).curTheme.text15,
              color: StateContainer.of(context).curTheme.backgroundDark,
              padding: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              onPressed: () {
                Sheets.showAppHeightEightSheet(
                    context: context,
                    widget: PaymentDetailsSheet(
                      block: item.block,
                      from_address: item.from_address,
                      to_address: item.to_address,
                      amount_raw: item.amount_raw,
                      fulfillment_time: item.fulfillment_time,
                      is_fulfilled: item.is_fulfilled,
                      is_request: item.is_request,
                      memo: item.memo,
                      request_time: item.request_time,
                      uuid: item.uuid,
                      is_acknowledged: item.is_acknowledged,
                      height: item.height,
                    ),
                    animationDurationMs: 175);
              },
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
                            // constraints: BoxConstraints(maxWidth: 85),
                            width: MediaQuery.of(context).size.width / 5,
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
                                      displayCurrencyAmount(
                                        context,
                                        AppStyles.textStyleTransactionAmount(
                                          context,
                                          true,
                                        ),
                                      ),
                                      TextSpan(
                                        text: getCurrencySymbol(context) + getRawAsThemeAwareAmount(context, item.amount_raw),
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
                      (item.memo != null)
                          ? Container(
                              // constraints: BoxConstraints(maxWidth: 105),
                              width: MediaQuery.of(context).size.width / 4.3,
                              child: Text(
                                item.memo,
                                textAlign: TextAlign.start,
                                style: AppStyles.textStyleTransactionMemo(context),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Container(),
                      Container(
                        width: MediaQuery.of(context).size.width / 4.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              displayName,
                              textAlign: TextAlign.end,
                              style: AppStyles.textStyleTransactionAddress(context),
                            ),

                            // TRANSACTION STATE TAG
                            // (item.confirmed != null && !item.confirmed) || (currentConfHeight > -1 && item.height != null && item.height > currentConfHeight)
                            //     ? Container(
                            //         margin: EdgeInsetsDirectional.only(
                            //           top: 4,
                            //         ),
                            //         child: TransactionStateTag(transactionState: TransactionStateOptions.UNCONFIRMED),
                            //       )
                            //     : SizedBox()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Slidable(
        delegate: SlidableScrollDelegate(),
        actionExtentRatio: 0.35,
        movementDuration: Duration(milliseconds: 300),
        enabled: slideEnabled,
        onTriggered: (preempt) {
          if (preempt) {
            setState(() {
              releaseAnimation = true;
            });
          } else {
            // See if a contact
            sl.get<DBHelper>().getUserOrContactWithAddress(item.account).then((user) {
              print(item.amount);
              String quickSendAmount = item.amount;
              // a bit of a hack since send sheet doesn't have a way to tell if we're in nyano mode on creation:
              if (StateContainer.of(context).nyanoMode) {
                quickSendAmount = item.amount + "000000";
              }
              if (user is User) {
                // Go to send with user
                Sheets.showAppHeightNineSheet(
                    context: context,
                    widget: SendSheet(
                      localCurrency: StateContainer.of(context).curCurrency,
                      user: user,
                      address: item.account,
                      quickSendAmount: quickSendAmount,
                    ));
              } else if (user is Contact) {
                // Go to send with contact
                Sheets.showAppHeightNineSheet(
                    context: context,
                    widget: SendSheet(
                      localCurrency: StateContainer.of(context).curCurrency,
                      contact: user,
                      address: item.account,
                      quickSendAmount: quickSendAmount,
                    ));
              } else {
                // Go to send with address
                Sheets.showAppHeightNineSheet(
                    context: context,
                    widget: SendSheet(
                      localCurrency: StateContainer.of(context).curCurrency,
                      address: item.account,
                      quickSendAmount: quickSendAmount,
                    ));
              }
            });
          }
        },
        onAnimationChanged: (animation) {
          if (animation != null) {
            _fanimationPosition = animation.value;
            if (animation.value == 0.0 && releaseAnimation) {
              setState(() {
                releaseAnimation = false;
              });
            }
          }
        },
        secondaryActions: <Widget>[
          SlideAction(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              margin: EdgeInsetsDirectional.only(end: MediaQuery.of(context).size.width * 0.15, top: 4, bottom: 4),
              child: Container(
                alignment: AlignmentDirectional(-0.5, 0),
                constraints: BoxConstraints.expand(),
                child: FlareActor("legacy_assets/pulltosend_animation.flr",
                    animation: "pull", fit: BoxFit.contain, controller: this, color: StateContainer.of(context).curTheme.primary),
              ),
            ),
          ),
        ],
        child: _SizeTransitionNoClip(
          sizeFactor: animation,
          child: Container(
            margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
            decoration: BoxDecoration(
              color: StateContainer.of(context).curTheme.backgroundDark,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [setShadow],
            ),
            child: FlatButton(
              highlightColor: StateContainer.of(context).curTheme.text15,
              splashColor: StateContainer.of(context).curTheme.text15,
              color: StateContainer.of(context).curTheme.backgroundDark,
              padding: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              onPressed: () {
                if (txDetails != null) {
                  Sheets.showAppHeightEightSheet(
                      context: context,
                      widget: PaymentDetailsSheet(
                        block: txDetails.block,
                        from_address: txDetails.from_address,
                        to_address: txDetails.to_address,
                        amount_raw: txDetails.amount_raw,
                        fulfillment_time: txDetails.fulfillment_time,
                        is_fulfilled: txDetails.is_fulfilled,
                        is_request: txDetails.is_request,
                        memo: txDetails.memo,
                        request_time: txDetails.request_time,
                        uuid: txDetails.uuid,
                        is_acknowledged: txDetails.is_acknowledged,
                        height: txDetails.height,
                        record_type: txDetails.record_type,
                        status: txDetails.status,
                        metadata: txDetails.metadata,
                        is_gift: isGift,
                      ),
                      animationDurationMs: 175);
                } else {
                  Sheets.showAppHeightEightSheet(
                      context: context,
                      widget: TransactionDetailsSheet(hash: item.hash, address: item.account, displayName: displayName),
                      animationDurationMs: 175);
                }
              },
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
                                      displayCurrencyAmount(
                                        context,
                                        AppStyles.textStyleTransactionAmount(
                                          context,
                                          true,
                                        ),
                                      ),
                                      TextSpan(
                                        text: getCurrencySymbol(context) + getRawAsThemeAwareAmount(context, item.amount ?? "0"),
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
                      txDetails != null && txDetails.memo != null
                          ? Container(
                              // constraints: BoxConstraints(maxWidth: 105),
                              width: MediaQuery.of(context).size.width / 4.3,
                              child: Text(
                                txDetails.memo,
                                textAlign: TextAlign.start,
                                style: AppStyles.textStyleTransactionMemo(context),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : SizedBox(),
                      Container(
                        width: MediaQuery.of(context).size.width / (txDetails != null && txDetails.memo != null ? 4.0 : 2.4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              displayName,
                              textAlign: TextAlign.end,
                              style: AppStyles.textStyleTransactionAddress(context),
                            ),

                            // TRANSACTION STATE TAG
                            (item.confirmed != null && !item.confirmed) || (currentConfHeight > -1 && item.height != null && item.height > currentConfHeight)
                                ? Container(
                                    margin: EdgeInsetsDirectional.only(
                                      top: 4,
                                    ),
                                    child: TransactionStateTag(transactionState: TransactionStateOptions.UNCONFIRMED),
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  } // Payment Card End

  // // Used to build list items that haven't been removed.
  // Widget _buildPaymentItem(BuildContext context, int index, Animation<double> animation) {
  //   if (index == 0 && StateContainer.of(context).activeAlert != null) {
  //     return _buildRemoteMessageCard(StateContainer.of(context).activeAlert);
  //   }
  //   int localIndex = index;
  //   if (StateContainer.of(context).activeAlert != null) {
  //     localIndex -= 1;
  //   }

  //   // print(_paymentsListMap.keys.toList());

  //   bool isRecipient = StateContainer.of(context).wallet.address ==
  //       _paymentsListMap[StateContainer.of(context).wallet.address][localIndex].to_address;

  //   String displayName = smallScreen(context)
  //       ? _paymentsListMap[StateContainer.of(context).wallet.address][localIndex].getShorterString(isRecipient)
  //       : _paymentsListMap[StateContainer.of(context).wallet.address][localIndex].getShortString(isRecipient);
  //   bool matched = false;

  //   String account = isRecipient
  //       ? _paymentsListMap[StateContainer.of(context).wallet.address][localIndex].from_address
  //       : _paymentsListMap[StateContainer.of(context).wallet.address][localIndex].to_address;

  //   // _contacts.forEach((contact) {
  //   for (Contact contact in _contacts) {
  //     if (contact.address == account.replaceAll("xrb_", "nano_")) {
  //       displayName = "★" + contact.name;
  //       matched = true;
  //       break;
  //     }
  //   }
  //   // if still not matched to a contact, check if it's a username
  //   if (!matched) {
  //     // for user in users:
  //     for (User user in _users) {
  //       if (user.address == account.replaceAll("xrb_", "nano_")) {
  //         displayName = "@" + user.username;
  //         break;
  //       }
  //     }
  //   }

  //   return _buildPaymentCard(
  //       _paymentsListMap[StateContainer.of(context).wallet.address][localIndex], animation, displayName, context);
  // }

  // Used to build list items that haven't been removed.
  Widget _buildUnifiedItem(BuildContext context, int index, Animation<double> animation) {
    if (index == 0 && StateContainer.of(context).activeAlert != null) {
      return _buildRemoteMessageCard(StateContainer.of(context).activeAlert);
    }
    int localIndex = index;
    if (StateContainer.of(context).activeAlert != null) {
      localIndex -= 1;
    }

    bool isPayment = _unifiedListMap[StateContainer.of(context).wallet.address][localIndex] is TXData;

    bool isRecipient = false;
    String account = "";
    String displayName;

    if (isPayment) {
      isRecipient = StateContainer.of(context).wallet.address == _unifiedListMap[StateContainer.of(context).wallet.address][localIndex].to_address;
    }

    if (isPayment) {
      displayName = smallScreen(context)
          ? _unifiedListMap[StateContainer.of(context).wallet.address][localIndex].getShorterString(isRecipient)
          : _unifiedListMap[StateContainer.of(context).wallet.address][localIndex].getShortString(isRecipient);
    } else {
      // slight change in structure:
      displayName = smallScreen(context)
          ? _unifiedListMap[StateContainer.of(context).wallet.address][localIndex].getShorterString()
          : _unifiedListMap[StateContainer.of(context).wallet.address][localIndex].getShortString();
    }

    if (isPayment) {
      account = isRecipient
          ? _unifiedListMap[StateContainer.of(context).wallet.address][localIndex].from_address
          : _unifiedListMap[StateContainer.of(context).wallet.address][localIndex].to_address;
    } else {
      // slight change in structure:
      account = _unifiedListMap[StateContainer.of(context).wallet.address][localIndex].account;
    }

    bool matched = false;
    for (Contact contact in _contacts) {
      if (contact.address == account.replaceAll("xrb_", "nano_")) {
        displayName = "★" + contact.name;
        matched = true;
        break;
      }
    }
    // if still not matched to a contact, check if it's a username
    if (!matched) {
      for (User user in _users) {
        if (user.address == account.replaceAll("xrb_", "nano_")) {
          displayName = "@" + user.username;
          break;
        }
      }
    }

    // dynamic userOrContact = sl
    //     .get<DBHelper>()
    //     .getUserOrContactWithAddress(_historyListMap[StateContainer.of(context).wallet.address][localIndex].account.replaceAll("xrb_", "nano_"));
    // if (userOrContact != null) {
    //   if (userOrContact is User) {
    //     displayName = "@" + userOrContact.username;
    //   } else if (userOrContact is Contact) {
    //     displayName = "★" + userOrContact.name;
    //   }
    // }

    // only do this is this is a regular tx:
    // find an associated memo for this tx:
    TXData txDetails;
    if (_unifiedListMap[StateContainer.of(context).wallet.address][localIndex] is AccountHistoryResponseItem) {
      txDetails = _txDetailsMap["${_unifiedListMap[StateContainer.of(context).wallet.address][localIndex].hash}"];
      if (txDetails != null) {
        return _buildUnifiedCard(_unifiedListMap[StateContainer.of(context).wallet.address][localIndex], animation, displayName, context, txDetails: txDetails);
      }
      //   dynamic txData = sl.get<DBHelper>().getTXDataByBlock(_unifiedListMap[StateContainer.of(context).wallet.address][localIndex].hash);
      //   if (txData != null && txData.memo.isNotEmpty) {
      //     return _buildUnifiedCard(_unifiedListMap[StateContainer.of(context).wallet.address][localIndex], animation, displayName, context);
      //   }
    }

    return _buildUnifiedCard(_unifiedListMap[StateContainer.of(context).wallet.address][localIndex], animation, displayName, context);
  }

  // Return widget for list
  Widget _getUnifiedListWidget(BuildContext context) {
    if (StateContainer.of(context).wallet == null || StateContainer.of(context).wallet.unifiedLoading) {
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
          key: _unifiedListKeyMap["${StateContainer.of(context).wallet.address}alert"],
          padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          initialItemCount: _unifiedListMap[StateContainer.of(context).wallet.address].length + 1,
          itemBuilder: _buildUnifiedItem,
        ),
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
      );
    }
    // Setup history list
    if (!_historyListKeyMap.containsKey("${StateContainer.of(context).wallet.address}")) {
      _historyListKeyMap.putIfAbsent("${StateContainer.of(context).wallet.address}", () => GlobalKey<AnimatedListState>());
      setState(() {
        _historyListMap.putIfAbsent(
          StateContainer.of(context).wallet.address,
          () => ListModel<AccountHistoryResponseItem>(
            listKey: _historyListKeyMap["${StateContainer.of(context).wallet.address}"],
            initialItems: StateContainer.of(context).wallet.history,
          ),
        );
      });
    }
    // Setup payments list
    if (!_requestsListKeyMap.containsKey("${StateContainer.of(context).wallet.address}")) {
      _requestsListKeyMap.putIfAbsent("${StateContainer.of(context).wallet.address}", () => GlobalKey<AnimatedListState>());
      setState(() {
        _requestsListMap.putIfAbsent(
          StateContainer.of(context).wallet.address,
          () => ListModel<TXData>(
            listKey: _requestsListKeyMap["${StateContainer.of(context).wallet.address}"],
            initialItems: StateContainer.of(context).wallet.requests,
          ),
        );
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
    generateUnifiedList();
    return ReactiveRefreshIndicator(
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      child: AnimatedList(
        key: _unifiedListKeyMap[StateContainer.of(context).wallet.address],
        padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
        initialItemCount: _unifiedListMap[StateContainer.of(context).wallet.address].length,
        itemBuilder: _buildUnifiedItem,
      ),
      onRefresh: _refresh,
      isRefreshing: _isRefreshing,
    );
  }

  // todo: padding

}

class TransactionDetailsSheet extends StatefulWidget {
  final String hash;
  final String address;
  final String displayName;

  TransactionDetailsSheet({this.hash, this.address, this.displayName}) : super();

  _TransactionDetailsSheetState createState() => _TransactionDetailsSheetState();
}

class _TransactionDetailsSheetState extends State<TransactionDetailsSheet> {
  // Current state references
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  @override
  Widget build(BuildContext context) {
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
                          Clipboard.setData(new ClipboardData(text: widget.address));
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
                            child: !widget.displayName.startsWith("@")
                                ? FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Sheets.showAppHeightNineSheet(context: context, widget: AddContactSheet(address: widget.address));
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                                    child: Icon(AppIcons.addcontact,
                                        size: 35,
                                        color: _addressCopied
                                            ? StateContainer.of(context).curTheme.successDark
                                            : StateContainer.of(context).curTheme.backgroundDark),
                                  )
                                : SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // A row for View Details button
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).viewDetails, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                        return UIUtil.showBlockExplorerWebview(context, widget.hash);
                      }));
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
  // final String hash;
  // final String address;
  // final String displayName;
  final String block;
  final String amount_raw;
  final String from_address;
  final String to_address;
  final bool is_fulfilled;
  final bool is_request;
  final String request_time;
  final String fulfillment_time;
  final String memo;
  final String uuid;
  final bool is_acknowledged;
  final int height;
  final String record_type;
  final bool is_gift;
  final String metadata;
  final String status;

  PaymentDetailsSheet(
      {this.block,
      this.amount_raw,
      this.from_address,
      this.to_address,
      this.is_fulfilled,
      this.is_request,
      this.request_time,
      this.fulfillment_time,
      this.memo,
      this.uuid,
      this.is_acknowledged,
      this.height,
      this.record_type,
      this.is_gift,
      this.metadata,
      this.status})
      : super();

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

  @override
  Widget build(BuildContext context) {
    // check if recipient of the request
    // also check if the request is fulfilled
    bool is_unfulfilled_request = false;
    bool is_unacknowledged_request = false;
    bool is_unacknowledged_memo = false;
    bool is_gift_load = false;
    bool is_gift = false;

    String walletAddress = StateContainer.of(context).wallet.address;
    if (walletAddress == widget.to_address && widget.is_request && !widget.is_fulfilled) {
      is_unfulfilled_request = true;
    }
    if (walletAddress == widget.to_address && widget.is_request && !widget.is_acknowledged) {
      is_unacknowledged_request = true;
    }

    if (!widget.is_acknowledged && !widget.is_request && widget.memo.isNotEmpty) {
      is_unacknowledged_memo = true;
    }

    String walletSeed;
    String sharableLink;
    if (widget.is_gift) {
      if (widget.record_type == "gift_load") {
        is_gift_load = true;

        // Get the wallet seed by splitting the metadata by :
        List<String> metadataList = widget.metadata.split(":");
        walletSeed = metadataList[0];
        sharableLink = metadataList[1];
      }
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
                // A stack for Copy Address and Add Contact buttons
                // Stack(
                //   children: <Widget>[
                //     // A row for Copy Address Button
                //     Row(
                //       children: <Widget>[
                //         AppButton.buildAppButton(
                //             context,
                //             // Share Address Button
                //             _addressCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                //             _addressCopied ? AppLocalization.of(context).addressCopied : AppLocalization.of(context).copyAddress,
                //             Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                //           // Clipboard.setData(new ClipboardData(text: widget.address));
                //           if (mounted) {
                //             setState(() {
                //               // Set copied style
                //               _addressCopied = true;
                //             });
                //           }
                //           if (_addressCopiedTimer != null) {
                //             _addressCopiedTimer.cancel();
                //           }
                //           _addressCopiedTimer = new Timer(const Duration(milliseconds: 800), () {
                //             if (mounted) {
                //               setState(() {
                //                 _addressCopied = false;
                //               });
                //             }
                //           });
                //         }),
                //       ],
                //     ),
                //     // A row for Add Contact Button
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: <Widget>[
                //         Container(
                //           margin: EdgeInsetsDirectional.only(top: Dimens.BUTTON_TOP_EXCEPTION_DIMENS[1], end: Dimens.BUTTON_TOP_EXCEPTION_DIMENS[2]),
                //           child: Container(
                //               height: 55,
                //               width: 55,
                //               // Add Contact Button
                //               child: FlatButton(
                //                 onPressed: () {
                //                   Navigator.of(context).pop();
                //                   // Sheets.showAppHeightNineSheet(context: context, widget: AddContactSheet(address: widget.address));
                //                 },
                //                 splashColor: Colors.transparent,
                //                 highlightColor: Colors.transparent,
                //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                //                 padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                //                 child: Icon(AppIcons.addcontact,
                //                     size: 35,
                //                     color:
                //                         _addressCopied ? StateContainer.of(context).curTheme.successDark : StateContainer.of(context).curTheme.backgroundDark),
                //               )),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),

                // A row for View Details button
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).viewDetails, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                        return UIUtil.showBlockExplorerWebview(context, widget.block);
                      }));
                    }),
                  ],
                ),

                // Mark as paid / unpaid button for requests
                (widget.is_request)
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context,
                              // Share Address Button
                              AppButtonType.PRIMARY_OUTLINE,
                              !widget.is_fulfilled ? AppLocalization.of(context).markAsPaid : AppLocalization.of(context).markAsUnpaid,
                              Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                            // update the tx in the db:
                            if (widget.is_fulfilled) {
                              sl.get<DBHelper>().changeTXFulfillmentStatus(widget.uuid, false);
                            } else {
                              sl.get<DBHelper>().changeTXFulfillmentStatus(widget.uuid, true);
                            }
                            // setState(() {});
                            StateContainer.of(context).updateRequests();
                            Navigator.of(context).pop();
                          }),
                        ],
                      )
                    : Container(),

                // pay this request button:
                is_unfulfilled_request
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).payRequest, Dimens.BUTTON_TOP_EXCEPTION_DIMENS,
                              onPressed: () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                            Sheets.showAppHeightNineSheet(
                                context: context,
                                widget: SendSheet(
                                  localCurrency: StateContainer.of(context).curCurrency,
                                  address: widget.from_address,
                                  quickSendAmount: widget.amount_raw,
                                ));
                          }),
                        ],
                      )
                    : Container(),

                // block this user from sending you requests:
                (!widget.is_gift)
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).blockUser, Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));

                            Sheets.showAppHeightNineSheet(
                                context: context,
                                widget: AddBlockedSheet(
                                  address: widget.from_address,
                                ));

                            // Sheets.showAppHeightNineSheet(
                            //     context: context,
                            //     widget: SendSheet(
                            //       localCurrency: StateContainer.of(context).curCurrency,
                            //       address: widget.from_address,
                            //       quickSendAmount: widget.amount_raw,
                            //     ));
                          }),
                        ],
                      )
                    : Container(),

                is_unacknowledged_request && is_unfulfilled_request
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).sendRequestAgain, Dimens.BUTTON_TOP_EXCEPTION_DIMENS,
                              onPressed: () {
                            // send the request again:
                            // TODO:
                            // String privKey = NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(), StateContainer.of(context).selectedAccount.index);

                            // // get epoch time as hex:
                            // int secondsSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
                            // String nonce_hex = secondsSinceEpoch.toRadixString(16);
                            // String signature = NanoSignatures.signBlock(nonce_hex, privKey);

                            // // check validity locally:
                            // String pubKey = NanoAccounts.extractPublicKey(StateContainer.of(context).wallet?.address);
                            // bool isValid = NanoSignatures.validateSig(nonce_hex, NanoHelpers.hexToBytes(pubKey), NanoHelpers.hexToBytes(signature));
                            // if (!isValid) {
                            //   throw Exception("Invalid signature?!");
                            // }

                            // await sl
                            //     .get<AccountService>()
                            //     .requestPayment(destinationAltered, widget.amountRaw, StateContainer.of(context).wallet.address, signature, nonce_hex, widget.memo);
                          }),
                        ],
                      )
                    : Container(),
                // re-send memo button
                (is_unacknowledged_memo && !widget.is_gift)
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context,
                              // Share Address Button
                              AppButtonType.PRIMARY_OUTLINE,
                              AppLocalization.of(context).resendMemo,
                              Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                            // TODO:
                            // setState(() {});
                            // StateContainer.of(context).updateRequests();
                            // Navigator.of(context).pop();
                          }),
                        ],
                      )
                    : Container(),
                widget.is_request
                    ? Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).deleteRequest, Dimens.BUTTON_TOP_EXCEPTION_DIMENS,
                              onPressed: () {
                            Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
                            sl.get<DBHelper>().deleteTXDataByUuid(widget.uuid);
                            StateContainer.of(context).updateRequests();
                          }),
                        ],
                      )
                    : Container(),
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
                    : Container(),
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
                    : Container(),
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
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// This is used so that the elevation of the container is kept and the
/// drop shadow is not clipped.
///
// class _SizeTransitionNoClip extends AnimatedWidget {
//   final Widget child;

//   const _SizeTransitionNoClip({@required Animation<double> sizeFactor, this.child}) : super(listenable: sizeFactor);

//   @override
//   Widget build(BuildContext context) {
//     return new Align(
//       alignment: const AlignmentDirectional(-1.0, -1.0),
//       widthFactor: null,
//       heightFactor: (this.listenable as Animation<double>).value,
//       child: child,
//     );
//   }
// }
