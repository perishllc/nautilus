import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:devicelocale/devicelocale.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/bus/payments_home_event.dart';
import 'package:wallet_flutter/bus/tx_update_event.dart';
import 'package:wallet_flutter/bus/unified_home_event.dart';
import 'package:wallet_flutter/bus/xmr_event.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/available_block_explorer.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/available_language.dart';
import 'package:wallet_flutter/model/available_themes.dart';
import 'package:wallet_flutter/model/currency_mode_setting.dart';
import 'package:wallet_flutter/model/db/account.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/model/wallet.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/metadata_service.dart';
import 'package:wallet_flutter/network/model/block_types.dart';
import 'package:wallet_flutter/network/model/fcm_message_event.dart';
import 'package:wallet_flutter/network/model/request/fcm_update_request.dart';
import 'package:wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:wallet_flutter/network/model/response/account_history_response.dart';
import 'package:wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:wallet_flutter/network/model/response/account_info_response.dart';
import 'package:wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:wallet_flutter/network/model/response/callback_response.dart';
import 'package:wallet_flutter/network/model/response/error_response.dart';
import 'package:wallet_flutter/network/model/response/funding_response_item.dart';
import 'package:wallet_flutter/network/model/response/process_response.dart';
import 'package:wallet_flutter/network/model/response/receivable_response.dart';
import 'package:wallet_flutter/network/model/response/receivable_response_item.dart';
import 'package:wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:wallet_flutter/network/model/status_types.dart';
import 'package:wallet_flutter/network/username_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/themes.dart';
import 'package:wallet_flutter/util/box.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/ninja/api.dart';
import 'package:wallet_flutter/util/ninja/ninja_node.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // print("Handling a background message");
  // dumb hack since the event bus doesn't work properly in background isolates or w/e:
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  List<String>? backgroundMessages = prefs.getStringList('background_messages');
  backgroundMessages ??= [];
  backgroundMessages.add(jsonEncode(message.data));
  await prefs.setStringList('background_messages', backgroundMessages);
}

Future<void> firebaseMessagingForegroundHandler(RemoteMessage message) async {
  // print("Handling a foreground message");
  EventTaxiImpl.singleton().fire(FcmMessageEvent(data: message.data));
}

class _InheritedStateContainer extends InheritedWidget {
  // You must pass through a child and your state.
  // ignore: use_super_parameters
  const _InheritedStateContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);
  // Data is your entire state. In our case just 'User'
  final StateContainerState data;

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}

class StateContainer extends StatefulWidget {
  const StateContainer({required this.child});

  final Widget child;

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()!.data;
  }

  @override
  StateContainerState createState() => StateContainerState();
}

/// App InheritedWidget
/// This is where we handle the global state and also where
/// we interact with the server and make requests/handle+propagate responses
///
/// Basically the central hub behind the entire app
class StateContainerState extends State<StateContainer> {
  final Logger log = sl.get<Logger>();

  // Minimum receive = 0.000001 NANO
  // String receiveThreshold = BigInt.from(10).pow(24).toString();
  String? receiveThreshold = "0";
  // min raw for receive
  // String minRawReceive = "0";

  // maximum number of queued messages before we just instantly update the UI:
  static const int MAX_SEQUENTIAL_UPDATES = 5;

  AppWallet? wallet;
  String currencyLocale = "en_US";
  Locale deviceLocale = const Locale('en', 'US');
  AvailableCurrency curCurrency = AvailableCurrency(AvailableCurrencyEnum.USD);
  LanguageSetting curLanguage = LanguageSetting(AvailableLanguage.DEFAULT);
  AvailableBlockExplorer curBlockExplorer = AvailableBlockExplorer(AvailableBlockExplorerEnum.NANOLOOKER);

  BaseTheme curTheme =
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark ? NautilusTheme() : IndiumTheme();
  bool nyanoMode = false;
  String currencyMode = CurrencyModeSetting(CurrencyModeOptions.NANO).getDisplayName();
  // Currently selected account
  Account? selectedAccount = Account(id: 1, name: "AB", index: 0, lastAccess: 0, selected: true);
  // Two most recently used accounts
  Account? recentLast;
  Account? recentSecondLast;

  // xmr:
  String xmrAddress = "";
  int? xmrRestoreHeight;
  bool xmrEnabled = true;
  String? xmrWalletData;
  String xmrFee = "";
  String xmrBalance = "0";
  final InAppLocalhostServer localhostServer = InAppLocalhostServer();

  // Natricon / Nyanicon settings
  bool? natriconOn = false;
  bool? nyaniconOn = false;
  Map<String, String> natriconNonce = <String, String>{};
  Map<String, String> nyaniconNonce = <String, String>{};

  // Active alert
  // AlertResponseItem? activeAlert;
  // AlertResponseItem? settingsAlert;
  List<AlertResponseItem> activeAlerts = <AlertResponseItem>[];
  List<AlertResponseItem> settingsAlerts = <AlertResponseItem>[];
  List<FundingResponseItem>? fundingAlerts;
  bool activeAlertIsRead = true;

  // If callback is locked
  bool _locked = false;

  // Initial deep link
  String? initialDeepLink;
  // Deep link changes
  StreamSubscription? _deepLinkSub;
  // branch subscription:
  StreamSubscription<Map>? _branchSub;

  List<String?> receivableRequests = [];
  List<String?> alreadyReceived = [];

  // List of Verified Nano Ninja Nodes
  bool nanoNinjaUpdated = false;
  List<NinjaNode> nanoNinjaNodes = [];

  // gifts!
  // TODO: turn into a map:
  Map<String, dynamic>? gift;
  bool introSkiped = false;

  // When wallet is encrypted
  String? encryptedSecret;

  void resetGift() {
    gift = null;
  }

  void updateNinjaNodes(List<NinjaNode> list) {
    setState(() {
      nanoNinjaNodes = list;
    });
  }

  void updateNatriconNonce(String address, int nonce) {
    setState(() {
      natriconNonce[address] = nonce.toString();
    });
  }

  void updateNyaniconNonce(String address, int nonce) {
    setState(() {
      nyaniconNonce[address] = nonce.toString();
    });
  }

  // void updateActiveAlert(AlertResponseItem? active, AlertResponseItem? settingsAlert) {
  //   setState(() {
  //     activeAlert = active;
  //     if (settingsAlert != null) {
  //       this.settingsAlert = settingsAlert;
  //     } else {
  //       this.settingsAlert = null;
  //       activeAlertIsRead = true;
  //     }
  //   });
  // }

  void addActiveOrSettingsAlert(AlertResponseItem? active, AlertResponseItem? settingsAlert) {
    setState(() {
      if (active != null) {
        // if this is alert 4041 (connection warning) and 4040 is in the stack, remove it:
        if (active.id == 4041 && activeAlerts.any((AlertResponseItem element) => element.id == 4040)) {
          activeAlerts.removeWhere((AlertResponseItem element) => element.id == 4040);
        }

        // disallow duplicates:
        if (!activeAlerts.any((AlertResponseItem element) => element.id == active.id)) {
          activeAlerts.add(active);
        }
      }
      if (settingsAlert != null) {
        // disallow duplicates:
        if (!settingsAlerts.any((AlertResponseItem element) => element.id == settingsAlert.id)) {
          settingsAlerts.add(settingsAlert);
        }
      }
    });
  }

  void removeActiveOrSettingsAlert(AlertResponseItem? active, AlertResponseItem? settingsAlert) {
    setState(() {
      if (active != null) {
        activeAlerts.remove(active);
      }
      if (settingsAlert != null) {
        settingsAlerts.remove(settingsAlert);
      }
    });
  }

  void updateFundingAlerts(List<FundingResponseItem>? alerts) {
    // if (Platform.isIOS) {
    //   // filter out alerts that can't be shown on iOS:
    //   alerts = alerts?.where((FundingResponseItem item) {
    //     return item.showOnIos ?? false;
    //   }).toList();
    // }
    setState(() {
      fundingAlerts = alerts;
    });
  }

  void setAlertRead() {
    setState(() {
      activeAlertIsRead = true;
    });
  }

  void setAlertUnread() {
    setState(() {
      activeAlertIsRead = false;
    });
  }

  Future<void> updateSolids() async {
    if (wallet != null && wallet!.address != null && Address(wallet!.address).isValid()) {
      final List<TXData> solids = await sl.get<DBHelper>().getAccountSpecificSolids(wallet!.address);
      // check for duplicates and remove:
      final Set<String?> uuids = <String?>{};
      final List<int?> idsToRemove = <int?>[];
      for (final TXData solid in solids) {
        if (!uuids.contains(solid.uuid)) {
          uuids.add(solid.uuid);
        } else {
          log.d("detected duplicate TXData! removing...");
          idsToRemove.add(solid.id);
          await sl.get<DBHelper>().deleteTXDataByID(solid.id);
        }
      }
      for (final int? id in idsToRemove) {
        solids.removeWhere((TXData element) => element.id == id);
      }
      setState(() {
        wallet!.solids = solids;
      });
      EventTaxiImpl.singleton().fire(PaymentsHomeEvent(items: wallet!.solids));
    }
  }

  Future<void> updateTXMemos() async {
    EventTaxiImpl.singleton().fire(TXUpdateEvent());
  }

  // Future<void> updateTransactionData() async {
  //   if (wallet != null && wallet.address != null && Address(wallet.address).isValid()) {
  //     var transactions = await sl.get<DBHelper>().getAccountSpecificTXData(wallet.address);
  //     setState(() {
  //       // this.wallet.transactions = transactions;
  //       // EventTaxiImpl.singleton().fire(PaymentsHomeEvent(items: wallet.transactions));
  //     });
  //   }
  // }

  Future<void> handleStoredMessages(FcmMessageEvent event) async {
    if (event.data != null) {
      handleMessage(event.data);
    }

    if (event.message_list != null) {
      bool delayUpdate = false;
      if (event.message_list!.length > MAX_SEQUENTIAL_UPDATES) {
        delayUpdate = true;
      }
      for (final String strMsg in event.message_list!) {
        final dynamic msg = jsonDecode(strMsg);
        await handleMessage(msg, delay_update: delayUpdate);
        // sleep between updates if there are more than 1 and < max to make the UI feel snappier / show the animation:
        if (event.message_list!.length > 1 && !delayUpdate) {
          await Future<dynamic>.delayed(const Duration(milliseconds: 600));
        }
      }
      if (delayUpdate) {
        // update the state:
        await updateSolids();
        await updateTXMemos();
        await updateUnified(true);
      }
    }
  }

  Future<void> updateUnified(bool fastUpdate) async {
    if (wallet != null && wallet!.address != null && Address(wallet!.address).isValid()) {
      EventTaxiImpl.singleton().fire(UnifiedHomeEvent(fastUpdate: fastUpdate));
    }
  }

  Future<void> checkAndUpdateAlerts() async {
    // Get active alert
    try {
      String localeString = (await sl.get<SharedPrefsUtil>().getLanguage()).getLocaleString();
      if (localeString == "DEFAULT") {
        final List<Locale> languageLocales = await Devicelocale.preferredLanguagesAsLocales;
        if (languageLocales.isNotEmpty) {
          localeString = languageLocales[0].languageCode;
        }
      }
      final AlertResponseItem? alert = await sl.get<MetadataService>().getAlert(localeString);
      if (alert == null) {
        // updateActiveAlert(null, null);
        return;
      } else if (await sl.get<SharedPrefsUtil>().shouldShowAlert(alert)) {
        // See if we should display this one again
        if (alert.link == null || await sl.get<SharedPrefsUtil>().alertIsRead(alert)) {
          setAlertRead();
        } else {
          setAlertUnread();
        }
        addActiveOrSettingsAlert(alert, alert);
      } else {
        if (alert.link == null || await sl.get<SharedPrefsUtil>().alertIsRead(alert)) {
          setAlertRead();
        } else {
          setAlertUnread();
        }
        addActiveOrSettingsAlert(null, alert);
      }
    } catch (e) {
      log.e("Error retrieving alert", e);
      return;
    }
  }

  Future<void> checkAndUpdateFundingAlerts() async {
    // Get active donation alert
    try {
      String localeString = (await sl.get<SharedPrefsUtil>().getLanguage()).getLocaleString();
      if (localeString == "DEFAULT") {
        final List<Locale> languageLocales = await Devicelocale.preferredLanguagesAsLocales;
        if (languageLocales.isNotEmpty) {
          localeString = languageLocales[0].languageCode;
        }
      }
      final List<FundingResponseItem>? fundingAlerts = await sl.get<MetadataService>().getFunding(localeString);
      updateFundingAlerts(fundingAlerts);
    } catch (e) {
      log.e("Error retrieving funding", e);
      return;
    }
  }

  Future<void> checkBranchConnection() async {
    // check if we can reach the branch server:
    final AlertResponseItem branchAlert = AlertResponseItem(
      id: 4040,
      active: true,
      // can't get localized strings in this context: :/
      // TODO: find a way, but as a temp fix for the settings drawer, we need to put in something:
      // title: Z.of(context).branchConnectErrorTitle,
      // shortDescription: Z.of(context).branchConnectErrorShortDesc,
      // longDescription: Z.of(context).branchConnectErrorLongDesc,
      title: "Connection Warning",
      shortDescription: "Error: can't reach Branch API",
      longDescription:
          "We can't seem to reach the Branch API, this is usually cause by some sort of network issue or VPN blocking the connection.\n\n You should still be able to use the app as normal, however sending and receiving gift cards may not work.",
      dismissable: true,
    );
    try {
      final http.Response response =
          await http.get(Uri.parse("https://branch.io"), headers: {'Content-type': 'application/json'});

      // we only care to show this if branch is unreachable but our backend is:
      final bool connected = await sl.get<AccountService>().isConnected();
      if (connected && response.statusCode != 200) {
        addActiveOrSettingsAlert(branchAlert, null);
      }
    } catch (e) {
      log.e("Error connecting to branch.io", e);
      addActiveOrSettingsAlert(branchAlert, null);
      return;
    }
  }

  Future<void> checkAndCacheNinjaAPIResponse() async {
    List<NinjaNode>? nodes;
    if ((await sl.get<SharedPrefsUtil>().getNinjaAPICache()) == null) {
      nodes = await NinjaAPI.getVerifiedNodes();
      if (nodes != null) {
        setState(() {
          nanoNinjaNodes = nodes!;
          nanoNinjaUpdated = true;
        });
      }
    } else {
      nodes = await NinjaAPI.getCachedVerifiedNodes();
      if (nodes != null) {
        setState(() {
          nanoNinjaNodes = nodes!;
          nanoNinjaUpdated = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Register RxBus
    _registerBus();
    // Set currency locale here for the UI to access
    sl.get<SharedPrefsUtil>().getCurrency(deviceLocale).then((AvailableCurrency currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    // Get default language setting
    sl.get<SharedPrefsUtil>().getLanguage().then((LanguageSetting language) {
      setState(() {
        curLanguage = language;
      });
    });
    // Get theme default
    sl.get<SharedPrefsUtil>().getTheme().then((ThemeSetting theme) {
      updateTheme(theme);
    });
    // Get default block explorer
    sl.get<SharedPrefsUtil>().getBlockExplorer().then((AvailableBlockExplorer explorer) {
      setState(() {
        curBlockExplorer = explorer;
      });
    });
    // Get initial deep link
    getInitialLink().then((String? initialLink) {
      setState(() {
        initialDeepLink = initialLink;
      });
    });
    // Cache ninja API if we don't already have it
    checkAndCacheNinjaAPIResponse();
    // Update alert
    checkAndUpdateAlerts();
    // Get funding alerts
    checkAndUpdateFundingAlerts();
    // make sure we can reach branch.io
    checkBranchConnection();
    // Get natricon pref
    sl.get<SharedPrefsUtil>().getUseNatricon().then((bool useNatricon) {
      setNatriconOn(useNatricon);
    });
    // Get nyanicon pref
    sl.get<SharedPrefsUtil>().getUseNyanicon().then((bool useNyanicon) {
      setNyaniconOn(useNyanicon);
    });
    // Get min raw receive pref
    sl.get<SharedPrefsUtil>().getMinRawReceive().then((String minRaw) {
      setMinRawReceive(minRaw);
    });
    // Get currency mode pref
    sl.get<SharedPrefsUtil>().getCurrencyMode().then((String currencyMode) {
      setCurrencyMode(currencyMode);
    });
    // Get xmr restore height:
    sl.get<SharedPrefsUtil>().getXmrRestoreHeight().then((int height) {
      setXmrRestoreHeight(height);
    });
    // Get xmr enabled:
    sl.get<SharedPrefsUtil>().getXmrEnabled().then((bool enabled) {
      setXmrEnabled(enabled);
    });
    // restore payments from the cache
    updateSolids();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );
  }

  // Subscriptions
  StreamSubscription<ConnStatusEvent>? _connStatusSub;
  StreamSubscription<SubscribeEvent>? _subscribeEventSub;
  StreamSubscription<PriceEvent>? _priceEventSub;
  StreamSubscription<CallbackEvent>? _callbackSub;
  StreamSubscription<ErrorEvent>? _errorSub;
  StreamSubscription<FcmUpdateEvent>? _fcmUpdateSub;
  StreamSubscription<FcmMessageEvent>? _fcmMessageSub;
  StreamSubscription<AccountModifiedEvent>? _accountModifiedSub;
  StreamSubscription<XMREvent>? _xmrSub;

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  // Register RX event listenerss
  void _registerBus() {
    _subscribeEventSub = EventTaxiImpl.singleton().registerTo<SubscribeEvent>().listen((SubscribeEvent event) {
      handleSubscribeResponse(event.response!);
    });
    _priceEventSub = EventTaxiImpl.singleton().registerTo<PriceEvent>().listen((PriceEvent event) {
      // PriceResponse's get pushed periodically, it wasn't a request we made so don't pop the queue
      // handle the null case in debug mode:
      if (wallet != null) {
        setState(() {
          wallet!.localCurrencyPrice = event.response!.price?.toString() ?? wallet!.localCurrencyPrice;
          wallet!.xmrPrice = event.response!.xmrPrice.toString();
        });
      }
    });
    _connStatusSub = EventTaxiImpl.singleton().registerTo<ConnStatusEvent>().listen((ConnStatusEvent event) {
      if (event.status == ConnectionStatus.CONNECTED) {
        requestUpdate();
      } else if (event.status == ConnectionStatus.DISCONNECTED && !sl.get<AccountService>().suspended) {
        sl.get<AccountService>().initCommunication();
      }
    });
    _callbackSub = EventTaxiImpl.singleton().registerTo<CallbackEvent>().listen((CallbackEvent event) {
      handleCallbackResponse(event.response);
    });
    _errorSub = EventTaxiImpl.singleton().registerTo<ErrorEvent>().listen((ErrorEvent event) {
      handleErrorResponse(event.response!);
    });
    _fcmUpdateSub = EventTaxiImpl.singleton().registerTo<FcmUpdateEvent>().listen((FcmUpdateEvent event) {
      if (wallet == null) return;
      sl.get<SharedPrefsUtil>().getNotificationsOn().then((bool enabled) {
        sl.get<MetadataService>().makeNotificationsRequest(
              FcmUpdateRequest(
                account: wallet!.address,
                fcmToken: event.token,
                enabled: enabled,
              ),
            );
      });
    });
    _fcmMessageSub = EventTaxiImpl.singleton().registerTo<FcmMessageEvent>().listen((FcmMessageEvent event) async {
      handleStoredMessages(event);
    });
    // Account has been deleted or name changed
    _accountModifiedSub =
        EventTaxiImpl.singleton().registerTo<AccountModifiedEvent>().listen((AccountModifiedEvent event) {
      if (!event.deleted) {
        if (event.account!.index == selectedAccount!.index) {
          setState(() {
            selectedAccount!.name = event.account!.name;
          });
        } else {
          updateRecentlyUsedAccounts();
        }
      } else {
        // Remove account
        updateRecentlyUsedAccounts().then((_) {
          if (event.account!.index == selectedAccount!.index && recentLast != null) {
            sl.get<DBHelper>().changeAccount(recentLast);
            setState(() {
              selectedAccount = recentLast;
            });
            EventTaxiImpl.singleton().fire(AccountChangedEvent(account: recentLast, noPop: true));
          } else if (event.account!.index == selectedAccount!.index && recentSecondLast != null) {
            sl.get<DBHelper>().changeAccount(recentSecondLast);
            setState(() {
              selectedAccount = recentSecondLast;
            });
            EventTaxiImpl.singleton().fire(AccountChangedEvent(account: recentSecondLast, noPop: true));
          } else if (event.account!.index == selectedAccount!.index) {
            getSeed().then((String seed) {
              sl.get<DBHelper>().getMainAccount(seed).then((Account? mainAccount) {
                sl.get<DBHelper>().changeAccount(mainAccount);
                setState(() {
                  selectedAccount = mainAccount;
                });
                EventTaxiImpl.singleton().fire(AccountChangedEvent(account: mainAccount, noPop: true));
              });
            });
          }
        });
        updateRecentlyUsedAccounts();
      }
      // check account for a username:
      if (StateContainer.of(context).wallet?.address != null && mounted) {
        sl.get<UsernameService>().checkAddressDebounced(
              context,
              StateContainer.of(context).wallet!.address!,
            );
      }
    });
    // Deep link has been updated
    _deepLinkSub = linkStream.listen((String? link) {
      setState(() {
        initialDeepLink = link;
      });
    });

    // branch deep links:
    _branchSub = FlutterBranchSdk.initSession().listen((Map data) {
      // TODO: investigate:
      if (data.containsKey("+clicked_branch_link") && data["+clicked_branch_link"] == true) {
        // check if they were gifted a wallet:
        if (data.containsKey("~feature") && (data["~feature"] == "gift" || data["~feature"] == "splitgift")) {
          // if (data["+match_guaranteed"] == true) {
          // setup the auto load wallet:
          setState(() {
            gift = <String, dynamic>{
              "seed": data["seed"] as String? ?? "",
              "amount_raw": data["amount_raw"] as String? ?? "",
              "address": data["address"] as String? ?? "",
              "from_address": data["from_address"] as String? ?? "",
              "memo": data["memo"] as String? ?? "",
              "require_captcha": data["require_captcha"] == "True",
              "uuid": data["gift_uuid"] as String? ?? "",
            };
          });
          // }
        }
      }
    }, onError: (dynamic error) {
      final PlatformException platformException = error as PlatformException;
      log.d('InitSession error: ${platformException.code} - ${platformException.message}');
    });

    // xmr:
    _xmrSub = EventTaxiImpl.singleton().registerTo<XMREvent>().listen((XMREvent event) {
      if (event.type == "primary_address") {
        setState(() {
          xmrAddress = event.message;
        });
      }
      if (event.type == "update_restore_height") {
        final int? height = int.tryParse(event.message);
        if (height == null) {
          log.e("Failed to parse restore height");
          return;
        }
        setXmrRestoreHeight(height);
      }
      if (event.type == "update_fee") {
        setState(() {
          xmrFee = event.message;
        });
      }
      if (event.type == "update_balance") {
        setState(() {
          xmrBalance = event.message;
        });
      }
    });
  }

  void _destroyBus() {
    if (_connStatusSub != null) {
      _connStatusSub!.cancel();
    }
    if (_subscribeEventSub != null) {
      _subscribeEventSub!.cancel();
    }
    if (_priceEventSub != null) {
      _priceEventSub!.cancel();
    }
    if (_callbackSub != null) {
      _callbackSub!.cancel();
    }
    if (_errorSub != null) {
      _errorSub!.cancel();
    }
    if (_fcmUpdateSub != null) {
      _fcmUpdateSub!.cancel();
    }
    if (_fcmMessageSub != null) {
      _fcmMessageSub!.cancel();
    }
    if (_accountModifiedSub != null) {
      _accountModifiedSub!.cancel();
    }
    if (_deepLinkSub != null) {
      _deepLinkSub!.cancel();
    }
    if (_branchSub != null) {
      _branchSub!.cancel();
    }
  }

  // Update the global wallet instance with a new address
  Future<void> updateWallet({required Account account}) async {
    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    // final String address = NanoUtil.seedToAddress(await getSeed(), account.index!);
    final String address = await NanoUtil.uniSeedToAddress(await getSeed(), account.index!, derivationMethod);

    account.address = account.address ?? address;
    bool watchOnly = false;
    if (account.address != address || account.watchOnly) {
      watchOnly = true;
    }
    selectedAccount = account;
    updateRecentlyUsedAccounts();
    // get user if it exists:
    // check address for a username:

    if (mounted) {
      try {
        await sl.get<UsernameService>().checkAddressDebounced(
              context,
              account.address!,
            );
      } catch (e) {
        log.v("couldn't check address for username: $e");
      }
    }

    // TODO: make username a setting if there are multiple:
    final User? user = await sl.get<DBHelper>().getUserWithAddress(account.address!);
    String? walletUsername;
    if (user != null) {
      walletUsername = user.getDisplayName();
    }
    setState(() {
      wallet = AppWallet(
        address: account.address,
        user: user,
        username: walletUsername,
        watchOnly: watchOnly,
        loading: true,
      );
      requestUpdate();
      updateSolids();
    });
  }

  Future<void> updateRecentlyUsedAccounts() async {
    final List<Account> otherAccounts = await sl.get<DBHelper>().getRecentlyUsedAccounts(await getSeed());
    if (otherAccounts.isNotEmpty) {
      if (otherAccounts.length > 1) {
        setState(() {
          recentLast = otherAccounts[0];
          recentSecondLast = otherAccounts[1];
        });
      } else {
        setState(() {
          recentLast = otherAccounts[0];
          recentSecondLast = null;
        });
      }
    } else {
      setState(() {
        recentLast = null;
        recentSecondLast = null;
      });
    }
  }

  Future<void> resetRecentlyUsedAccounts() async {
    setState(() {
      recentLast = null;
      recentSecondLast = null;
    });
  }

  Future<void> resetApp(BuildContext context) async {
    // Delete the database
    try {
      await sl.get<DBHelper>().nukeDatabase();
    } catch (error) {
      log.d("Error resetting database: $error");
    }

    // delete preferences:
    await sl.get<SharedPrefsUtil>().deleteAll();

    // add the donations contact:
    await sl.get<SharedPrefsUtil>().setFirstContactAdded(true);
    final User donationsContact = User(
        nickname: "NautilusDonations",
        address: "nano_38713x95zyjsqzx6nm1dsom1jmm668owkeb9913ax6nfgj15az3nu8xkx579",
        type: UserTypes.CONTACT);
    await sl.get<DBHelper>().saveContact(donationsContact);

    // set the "has asked for contacts" flag so it doesn't ask again:
    await sl.get<SharedPrefsUtil>().setContactsOn(false);

    // re-add account index 0 and switch the account to it:
    if (!mounted) return;
    final String seed = await StateContainer.of(context).getSeed();
    if (!mounted) return;
    await NanoUtil().loginAccount(seed, context);
    if (!mounted) return;
    await StateContainer.of(context).resetRecentlyUsedAccounts();
    final Account? mainAccount = await sl.get<DBHelper>().getSelectedAccount(seed);
    if (!mounted) return;
    StateContainer.of(context).updateWallet(account: mainAccount!);
    // force users list to update on the home page:
    EventTaxiImpl.singleton().fire(ContactModifiedEvent());
    EventTaxiImpl.singleton().fire(PaymentsHomeEvent(items: <TXData>[]));

    StateContainer.of(context).updateUnified(true);
    EventTaxiImpl.singleton().fire(AccountChangedEvent(account: mainAccount, delayPop: true));

    // EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: mainAccount));
    // if (animationOpen && mounted) {
    //   Navigator.of(context).pop();
    // }
  }

  // Change language
  void updateLanguage(LanguageSetting language) {
    if (curLanguage.language != language.language) {
      checkAndUpdateAlerts();
      checkAndUpdateFundingAlerts();
    }
    setState(() {
      curLanguage = language;
    });
  }

  // Change block explorer
  void updateBlockExplorer(AvailableBlockExplorer explorer) {
    setState(() {
      curBlockExplorer = explorer;
    });
  }

  // Set encrypted secret
  void setEncryptedSecret(String secret) {
    setState(() {
      encryptedSecret = secret;
    });
  }

  // Reset encrypted secret
  void resetEncryptedSecret() {
    setState(() {
      encryptedSecret = null;
    });
  }

  // Change theme
  void updateTheme(ThemeSetting theme) {
    setState(() {
      curTheme = theme.getTheme();
    });
  }

  // Change natricon setting
  void setNatriconOn(bool? natriconOn) {
    setState(() {
      this.natriconOn = natriconOn;
    });
  }

  // Change nyanicon setting
  void setNyaniconOn(bool? nyaniconOn) {
    setState(() {
      this.nyaniconOn = nyaniconOn;
    });
  }

  // Change min raw setting
  void setMinRawReceive(String? minRaw) {
    setState(() {
      receiveThreshold = minRaw;
    });
  }

  // Change currency mode setting
  void setCurrencyMode(String currencyMode) {
    setState(() {
      this.currencyMode = currencyMode;
      nyanoMode = this.currencyMode == CurrencyModeSetting(CurrencyModeOptions.NYANO).getDisplayName();
    });
  }

  // set xmr restore height:
  void setXmrRestoreHeight(int height) {
    setState(() {
      xmrRestoreHeight = height;
    });
    EventTaxiImpl.singleton().fire(XMREvent(type: "set_restore_height", message: height.toString()));
  }

  // show / hide xmr section setting
  void setXmrEnabled(bool enabled) {
    setState(() {
      xmrEnabled = enabled;
    });
    if (!enabled) {
      EventTaxiImpl.singleton().fire(XMREvent(type: "mode_change", message: "nano"));
    }
    // start/stop web server for xmr:
    if (enabled && !localhostServer.isRunning()) {
      localhostServer.start();
    }
    if (!enabled && localhostServer.isRunning()) {
      localhostServer.close();
    }
  }

  void disconnect() {
    sl.get<AccountService>().reset(suspend: true);
  }

  void reconnect() {
    sl.get<AccountService>().initCommunication(unsuspend: true);
  }

  void lockCallback() {
    _locked = true;
  }

  void unlockCallback() {
    _locked = false;
  }

  ///
  /// When an error is returned from server
  ///
  Future<void> handleErrorResponse(ErrorResponse errorResponse) async {
    sl.get<AccountService>().processQueue();
    if (errorResponse.error == null) {
      return;
    }
  }

  /// Handle account_subscribe response
  void handleSubscribeResponse(SubscribeResponse response) {
    // get the preference for the receive threshold:
    sl.get<SharedPrefsUtil>().getMinRawReceive().then((String? minRaw) {
      receiveThreshold = minRaw;
      // Combat spam by raising minimum receive if receivable block count is large enough
      // only override the user preference if it was set to 0 (default)
      if (response.receivableCount != null && response.receivableCount! > 50 && minRaw == "0") {
        // Bump min receive to 0.05 NANO
        receiveThreshold = BigInt.from(5).pow(28).toString();
      }
    });
    // Set currency locale here for the UI to access
    sl.get<SharedPrefsUtil>().getCurrency(deviceLocale).then((AvailableCurrency currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    // Server gives us a UUID for future requests on subscribe
    if (response.uuid != null) {
      sl.get<SharedPrefsUtil>().setUuid(response.uuid!);
    }
    EventTaxiImpl.singleton().fire(ConfirmationHeightChangedEvent(confirmationHeight: response.confirmationHeight));
    setState(() {
      wallet!.loading = false;
      wallet!.frontier = response.frontier;
      wallet!.representative = response.representative ?? AppWallet.defaultRepresentative;
      wallet!.representativeBlock = response.representativeBlock;
      wallet!.openBlock = response.openBlock;
      wallet!.blockCount = response.blockCount;
      wallet!.confirmationHeight = response.confirmationHeight!;
      if (response.balance == null) {
        wallet!.accountBalance = BigInt.from(0);
      } else {
        wallet!.accountBalance = BigInt.tryParse(response.balance!)!;
      }
      wallet!.localCurrencyPrice = response.price.toString();
      wallet!.xmrPrice = response.xmrPrice.toString();
      sl.get<AccountService>().pop();
      sl.get<AccountService>().processQueue();
    });
  }

  void stopLoading() {
    requestUpdate();
    setState(() {
      wallet!.loading = false;
      sl.get<AccountService>().pop();
      sl.get<AccountService>().processQueue();
    });
  }

  /// Handle callback response
  /// Typically this means we need to pocket transactions
  Future<void> handleCallbackResponse(CallbackResponse? resp) async {
    if (_locked) {
      return;
    }
    log.d("Received callback ${json.encode(resp!.toJson())}");
    if (resp.isSend != "true") {
      sl.get<AccountService>().processQueue();
      return;
    }
    final ReceivableResponseItem receivableItem =
        ReceivableResponseItem(hash: resp.hash, source: resp.account, amount: resp.amount);
    final String? receivedHash = await handleReceivableItem(receivableItem, link_as_account: resp.block!.linkAsAccount);
    if (receivedHash != null) {
      final AccountHistoryResponseItem histItem = AccountHistoryResponseItem(
          type: BlockTypes.STATE,
          subtype: BlockTypes.RECEIVE,
          account: resp.account,
          amount: resp.amount,
          hash: receivedHash,
          link: resp.hash,
          local_timestamp: DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond);
      log.d("Received histItem ${json.encode(histItem.toJson())}");
      if (!wallet!.history.contains(histItem)) {
        setState(() {
          // TODO: not necessarily the best way to handle this, should get real height:
          histItem.height = wallet!.confirmationHeight + 1;
          wallet!.confirmationHeight += 1;
          wallet!.history.insert(0, histItem);
          wallet!.accountBalance += BigInt.parse(resp.amount!);
          // Send list to home screen
          EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: wallet!.history));
          updateUnified(false);
        });
      }
    }
  }

  Future<String?> handleReceivableItem(ReceivableResponseItem? item, {String? link_as_account}) async {
    if (receivableRequests.contains(item?.hash)) {
      return null;
    }
    receivableRequests.add(item?.hash);
    final BigInt? amountBigInt = BigInt.tryParse(item!.amount!);
    sl.get<Logger>().d("Handling ${item.hash} receivable");
    if (amountBigInt != null) {
      // don't process if under the receive threshold:
      if (amountBigInt < BigInt.parse(receiveThreshold!)) {
        receivableRequests.remove(item.hash);
        log.d("Blocked send from address: ${item.source} because it's below the receive threshold");
        return null;
      }
      // don't process if the user / address is blocked:
      if (await sl.get<DBHelper>().blockedExistsWithAddress(item.source!)) {
        receivableRequests.remove(item.hash);
        log.d("Blocked send from address: ${item.source} because they're blocked");
        return null;
      }
    }

    // if there's no user for this address, check if one exists on the block chain:

    if (link_as_account != null && mounted) {
      await sl.get<UsernameService>().checkAddressDebounced(context, link_as_account);
    }

    if (wallet!.watchOnly && link_as_account != null && link_as_account == wallet!.address) {
      // add to home screen w/o trying to receive it:
      final AccountHistoryResponseItem histItem = AccountHistoryResponseItem(
          account: wallet!.address,
          amount: item.amount,
          confirmed: true,
          local_timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          hash: item.hash,
          height: wallet!.confirmationHeight + 1,
          subtype: BlockTypes.RECEIVE,
          type: BlockTypes.RECEIVE); // special to watch only mode -> tx.record_type
      if (!wallet!.history.contains(histItem)) {
        setState(() {
          wallet!.confirmationHeight += 1;
          wallet!.history.insert(0, histItem);
          EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: wallet!.history));
          updateUnified(false);
        });
      }
      return null;
    }

    // are we on the wrong account?
    if (link_as_account != null && link_as_account != wallet!.address) {
      // we aren't on the current account for this receive:
      log.d("Receive is for a different account: $link_as_account");
      // HANDLE IT: 😔

      final AccountInfoResponse accountResp = await sl.get<AccountService>().getAccountInfo(link_as_account);
      final String seed = await getSeed();
      Account? correctAccount;
      final List<Account> accounts = await sl.get<DBHelper>().getAccounts(seed);
      for (int i = 0; i < accounts.length; i++) {
        if (accounts[i].address == link_as_account) {
          correctAccount = accounts[i];
          break;
        }
      }

      if (correctAccount == null) {
        log.d("Could not find account for $link_as_account");
        receivableRequests.remove(item.hash);
        return null;
      }

      final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
      final String privKey = await NanoUtil.uniSeedToPrivate(seed, correctAccount.index!, derivationMethod);

      // publish open:
      if (accountResp.openBlock == null) {
        sl.get<Logger>().d("Handling ${item.hash} as open");
        try {
          final ProcessResponse resp =
              await sl.get<AccountService>().requestOpen(item.amount, item.hash, link_as_account, privKey);
          wallet!.openBlock = resp.hash;
          wallet!.frontier = resp.hash;
          receivableRequests.remove(item.hash);
          alreadyReceived.add(item.hash);
          // don't add to history list since we're not on the current account
          // return resp.hash;
          return null;
        } catch (e) {
          receivableRequests.remove(item.hash);
          sl.get<Logger>().e("Error creating open", e);
        }
      } else {
        try {
          final ProcessResponse resp = await sl.get<AccountService>().requestReceive(
              wallet!.representative, accountResp.frontier, item.amount, item.hash, link_as_account, privKey);
          // wallet.frontier = resp.hash;
          receivableRequests.remove(item.hash);
          alreadyReceived.add(item.hash);
        } catch (e) {
          receivableRequests.remove(item.hash);
          sl.get<Logger>().e("Error creating receive", e);
        }
      }

      // receive any other receivables first?:
      //{
      // BigInt totalTransferred = BigInt.zero;
      // AccountBalanceItem balanceItem = new AccountBalanceItem();
      // // Get frontiers first
      // if (!accountResp.unopened) {
      //   balanceItem.frontier = accountResp.frontier;
      // }
      // // Receive receivable blocks
      // ReceivableResponse pr = await sl.get<AccountService>().getReceivable(link_as_account, 20);
      // Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks;
      // for (String hash in receivableBlocks.keys) {
      //   ReceivableResponseItem item = receivableBlocks[hash];
      //   if (balanceItem.frontier != null) {
      //     ProcessResponse resp = await sl
      //         .get<AccountService>()
      //         .requestReceive(AppWallet.defaultRepresentative, balanceItem.frontier, item.amount, hash, link_as_account, balanceItem.privKey);
      //     if (resp.hash != null) {
      //       balanceItem.frontier = resp.hash;
      //       totalTransferred += BigInt.parse(item.amount);
      //     }
      //   } else {
      //     ProcessResponse resp = await sl.get<AccountService>().requestOpen(item.amount, hash, link_as_account, balanceItem.privKey);
      //     if (resp.hash != null) {
      //       balanceItem.frontier = resp.hash;
      //       totalTransferred += BigInt.parse(item.amount);
      //     }
      //   }
      //   // Hack that waits for blocks to be confirmed
      //   await Future<dynamic>.delayed(const Duration(milliseconds: 300));
      // }
      //}

      // don't add to the history view since we're on the wrong account:
      return null;
      // throw Exception("Not on the correct account to receive this");
    } else if (wallet!.openBlock == null) {
      // Publish open
      sl.get<Logger>().d("Handling ${item.hash} as open");
      try {
        final ProcessResponse resp =
            await sl.get<AccountService>().requestOpen(item.amount, item.hash, wallet!.address, await _getPrivKey());
        wallet!.openBlock = resp.hash;
        wallet!.frontier = resp.hash;
        receivableRequests.remove(item.hash);
        alreadyReceived.add(item.hash);
        return resp.hash;
      } catch (e) {
        receivableRequests.remove(item.hash);
        sl.get<Logger>().e("Error creating open", e);
      }
    } else {
      // Publish receive
      sl.get<Logger>().d("Handling ${item.hash} as receive");

      try {
        final ProcessResponse resp = await sl.get<AccountService>().requestReceive(
            wallet!.representative, wallet!.frontier, item.amount, item.hash, wallet!.address, await _getPrivKey());

        wallet!.frontier = resp.hash;
        receivableRequests.remove(item.hash);
        alreadyReceived.add(item.hash);
        return resp.hash;
      } catch (e) {
        receivableRequests.remove(item.hash);
        sl.get<Logger>().e("Error creating receive", e);
      }
    }
    return null;
  }

  /// Request balances for accounts in our database
  Future<void> _requestBalances() async {
    final List<Account> accounts = await sl.get<DBHelper>().getAccounts(await getSeed());

    if (accounts.isEmpty) {
      return;
    }

    final List<String> addressToRequest = <String>[];
    for (final Account account in accounts) {
      if (account.address != null) {
        addressToRequest.add(account.address!);
      }
    }

    final AccountsBalancesResponse resp = await sl.get<AccountService>().requestAccountsBalances(addressToRequest);
    sl.get<DBHelper>().getAccounts(await getSeed()).then((List<Account> accounts) {
      for (final Account account in accounts) {
        resp.balances!.forEach((String address, AccountBalanceItem balance) {
          final String combinedBalance =
              (BigInt.tryParse(balance.balance!)! + BigInt.tryParse(balance.receivable!)!).toString();
          if (address == account.address && combinedBalance != account.balance) {
            sl.get<DBHelper>().updateAccountBalance(account, combinedBalance);
          }
        });
      }
    });
  }

  Future<void> requestUpdate({bool receivable = true}) async {
    if (wallet == null || wallet?.address == null || !Address(wallet!.address).isValid()) {
      return;
    }
    
    final String? uuid = await sl.get<SharedPrefsUtil>().getUuid();
    String? fcmToken;
    bool? notificationsEnabled;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      notificationsEnabled = await sl.get<SharedPrefsUtil>().getNotificationsOn();
    } catch (e) {
      fcmToken = null;
      notificationsEnabled = false;
    }
    sl.get<AccountService>().clearQueue();
    sl.get<AccountService>().queueRequest(SubscribeRequest(
          account: wallet!.address,
          currency: curCurrency.getIso4217Code(),
          uuid: uuid,
          fcmToken: fcmToken,
          notificationEnabled: notificationsEnabled,
        ));
    sl.get<AccountService>().processQueue();
    // Request account history

    // Choose correct blockCount to minimize bandwidth
    // This can still be improved because history excludes change/open, blockCount doesn't
    // Get largest count we have + 5 (just a safe-buffer)
    int count = 500;
    if (wallet!.history != null && wallet!.history.length > 1) {
      count = 50;
    }
    try {
      final AccountHistoryResponse resp =
          await sl.get<AccountService>().requestAccountHistory(wallet!.address, count: count, raw: true);
      _requestBalances();
      bool postedToHome = false;
      // Iterate list in reverse (oldest to newest block)
      for (final AccountHistoryResponseItem item in resp.history!) {
        // If current list doesn't contain this item, insert it and the rest of the items in list and exit loop
        if (!wallet!.history.contains(item)) {
          const int startIndex = 0; // Index to start inserting into the list
          int lastIndex = resp.history!.indexWhere((AccountHistoryResponseItem item) => wallet!.history.contains(
              item)); // Last index of historyResponse to insert to (first index where item exists in wallet history)
          lastIndex = lastIndex <= 0 ? resp.history!.length : lastIndex;
          setState(() {
            wallet!.history.insertAll(0, resp.history!.getRange(startIndex, lastIndex));
            // Send list to home screen
            EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: wallet!.history));
          });
          if ((lastIndex - startIndex) > MAX_SEQUENTIAL_UPDATES) {
            await updateUnified(true);
          } else {
            await updateUnified(false);
          }
          postedToHome = true;
          break;
        }
      }
      setState(() {
        wallet!.historyLoading = false;
      });
      // just in case we didn't post to home screen
      if (!postedToHome) {
        EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: wallet!.history));
        await updateUnified(false);
      }

      sl.get<AccountService>().pop();
      sl.get<AccountService>().processQueue();
      // Receive receivables
      if (receivable) {
        receivableRequests.clear();
        final ReceivableResponse receivableResp = await sl
            .get<AccountService>()
            .getReceivable(wallet!.address, max(wallet!.blockCount ?? 0, 10), threshold: receiveThreshold);

        // remove any receivables in the wallet history that are not in the receivable response:
        if (wallet!.watchOnly) {
          // check for duplicates in the wallet history:
          final List<String?> receivableHashes =
              receivableResp.blocks!.values.map((ReceivableResponseItem block) => block.hash).toList();
          final List<AccountHistoryResponseItem> toRemove = [];
          for (final AccountHistoryResponseItem histItem in wallet!.history) {
            if (histItem.type == BlockTypes.RECEIVE) {
              if (!receivableHashes.contains(histItem.hash)) {
                toRemove.add(histItem);
              }
            }
          }
          if (toRemove.isNotEmpty) {
            setState(() {
              toRemove.forEach(wallet!.history.remove);
            });
            EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: wallet!.history));
            await updateUnified(false);
          }
        }

        // don't process receives for watch-only accounts:
        if (!wallet!.watchOnly) {
          // for unfulfilled payments:
          final List<TXData> unfulfilledPayments = await sl.get<DBHelper>().getUnfulfilledTXs();

          // Initiate receive/open request for each receivable
          for (final String hash in receivableResp.blocks!.keys) {
            final ReceivableResponseItem? receivableResponseItem = receivableResp.blocks![hash];
            receivableResponseItem?.hash = hash;
            final String? receivedHash = await handleReceivableItem(receivableResponseItem);
            if (receivedHash != null) {
              // payments:
              // check to see if this fulfills a payment request:

              for (int i = 0; i < unfulfilledPayments.length; i++) {
                final TXData txData = unfulfilledPayments[i];
                // check destination of this request is where we're sending to:
                // check to make sure we made the request:
                // check to make sure the amounts are the same:
                if (txData.from_address == wallet!.address &&
                    txData.to_address == receivableResponseItem!.source &&
                    txData.amount_raw == receivableResponseItem.amount &&
                    txData.is_fulfilled == false) {
                  // this is the payment we're fulfilling
                  // update the TXData to be fulfilled
                  await sl.get<DBHelper>().changeTXFulfillmentStatus(txData.uuid, true);
                  // update the ui to reflect the change in the db:
                  await updateSolids();
                  await updateUnified(true);
                  break;
                }
              }

              final AccountHistoryResponseItem histItem = AccountHistoryResponseItem(
                  type: BlockTypes.STATE,
                  subtype: BlockTypes.RECEIVE,
                  account: receivableResponseItem!.source,
                  amount: receivableResponseItem.amount,
                  hash: receivedHash,
                  link: receivableResponseItem.hash,
                  local_timestamp: DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond);
              if (!wallet!.history.contains(histItem)) {
                setState(() {
                  // TODO: not necessarily the best way to handle this, should get real height:
                  histItem.height = wallet!.confirmationHeight + 1;
                  wallet!.confirmationHeight += 1;
                  wallet!.history.insert(0, histItem);
                  wallet!.accountBalance += BigInt.parse(receivableResponseItem.amount!);
                  // Send list to home screen
                  EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: wallet!.history));
                  updateUnified(false);
                });
              }
            }
          }
        }
      }
    } catch (e) {
      // TODO handle account history error
      log.e("account_history e", e);
    }
  }

  Future<void> requestSubscribe() async {
    if (wallet != null && wallet!.address != null && Address(wallet!.address).isValid()) {
      final String? uuid = await sl.get<SharedPrefsUtil>().getUuid();
      String? fcmToken;
      bool? notificationsEnabled;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        notificationsEnabled = await sl.get<SharedPrefsUtil>().getNotificationsOn();
      } catch (e) {
        fcmToken = null;
        notificationsEnabled = false;
      }
      sl.get<AccountService>().removeSubscribeHistoryReceivableFromQueue();
      sl.get<AccountService>().queueRequest(SubscribeRequest(
          account: wallet!.address,
          currency: curCurrency.getIso4217Code(),
          uuid: uuid,
          fcmToken: fcmToken,
          notificationEnabled: notificationsEnabled));
      sl.get<AccountService>().processQueue();
    }
  }

  Future<String> decryptMessageCurrentAccount(String memoEnc, String? fromAddress, String? toAddress) async {
    // decrypt the memo:
    Account? correctAccount;
    // find the right account index:
    if (selectedAccount!.address == toAddress) {
      correctAccount = selectedAccount;
    } else {
      final String seed = await getSeed();
      final List<Account> accounts = await sl.get<DBHelper>().getAccounts(seed);
      for (int i = 0; i < accounts.length; i++) {
        if (accounts[i].address == toAddress) {
          correctAccount = accounts[i];
          break;
        }
      }
    }

    if (correctAccount == null) {
      log.d("failed to decrypt memo!");
      return "Decryption failed: account not found!";
    }

    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    final String privKey = await NanoUtil.uniSeedToPrivate(
      await getSeed(),
      correctAccount.index!,
      derivationMethod,
    );
    try {
      return Box.decrypt(memoEnc, fromAddress!, privKey);
    } catch (error) {
      log.d("failed to decrypt memo!");
      return "Decryption failed: ${error.toString()}";
    }
  }

  Future<void> handlePaymentRequest(dynamic data, {bool delay_update = false}) async {
    log.d("handling payment_request from: ${data['requesting_account']} : ${data['account']}");
    final String? amountRaw = data['amount_raw'] as String?;
    final String? requestingAccount = data['requesting_account'] as String?;
    final String? memoEnc = data['memo_enc'] as String?;
    final int? requestTime = int.tryParse(data['request_time'] as String);
    final String? toAddress = data['account'] as String?;
    final String uuid = data['uuid'] as String;
    final String? localUuid = data['local_uuid'] as String?;

    if (wallet == null || wallet!.address == null || !Address(wallet!.address).isValid()) {
      throw Exception("wallet or wallet.address is null!");
    }

    final int currentBlockHeightInList = wallet!.history.isNotEmpty ? (wallet!.history[0].height! + 1) : 1;
    final String? lastBlockHash = wallet!.history.isNotEmpty ? wallet?.history[0].hash : null;

    final TXData txData = TXData(
      amount_raw: amountRaw,
      is_request: true,
      is_memo: false,
      is_message: false,
      from_address: requestingAccount,
      to_address: toAddress,
      is_fulfilled: false,
      request_time: requestTime,
      block: lastBlockHash,
      uuid: uuid,
      is_acknowledged: false,
      height: currentBlockHeightInList,
    );

    // decrypt the memo:
    if (memoEnc != null && memoEnc.isNotEmpty) {
      txData.memo = await decryptMessageCurrentAccount(memoEnc, requestingAccount, toAddress);
    }

    // check if exists in db:
    final TXData? existingTXData = await sl.get<DBHelper>().getTXDataByUUID(uuid);
    if (existingTXData != null) {
      // update with the new info:
      existingTXData.is_acknowledged = true;
      existingTXData.request_time = requestTime;
      log.v("replacing TXData");
      await sl.get<DBHelper>().replaceTXDataByUUID(existingTXData);
    } else {
      log.v("adding TXData to db");
      // add it since it doesn't exist:
      await sl.get<DBHelper>().addTXData(txData);
    }

    // check for the local uuid just in case:
    if (localUuid != null && localUuid.isNotEmpty && localUuid.contains("LOCAL")) {
      final TXData? localTXData = await sl.get<DBHelper>().getTXDataByUUID(localUuid);
      if (localTXData != null) {
        // remove it:
        await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      }
    }

    if (!delay_update) {
      await updateSolids();
      await updateUnified(false);
    }

    // send acknowledgement to server / requester:
    await sl.get<MetadataService>().requestACK(uuid, requestingAccount, wallet!.address);
  }

  Future<void> handlePaymentMessage(dynamic data, {bool delay_update = false}) async {
    log.d("handling payment_message from: ${data['requesting_account']} : ${data['account']}");
    final String? amountRaw = data['amount_raw'] as String?;
    final String? requestingAccount = data['requesting_account'] as String?;
    final String? memoEnc = data['memo_enc'] as String?;
    final int? requestTime = int.tryParse(data['request_time'] as String);
    final String? toAddress = data['account'] as String?;
    final String uuid = data['uuid'] as String;
    final String? localUuid = data['local_uuid'] as String?;

    if (wallet == null || wallet!.address == null || !Address(wallet!.address).isValid()) {
      throw Exception("wallet or wallet.address is null!");
    }

    final int currentBlockHeightInList = wallet!.history.isNotEmpty ? (wallet!.history[0].height! + 1) : 1;
    final String? lastBlockHash = wallet!.history.isNotEmpty ? wallet?.history[0].hash : null;

    final TXData txData = TXData(
      amount_raw: amountRaw,
      is_request: false,
      is_memo: false,
      is_message: true,
      from_address: requestingAccount,
      to_address: toAddress,
      is_fulfilled: false,
      request_time: requestTime,
      block: lastBlockHash,
      uuid: uuid,
      is_acknowledged: false,
      height: currentBlockHeightInList,
    );

    // decrypt the memo:
    if (memoEnc != null && memoEnc.isNotEmpty) {
      final String memo = await decryptMessageCurrentAccount(memoEnc, requestingAccount, toAddress);
      if (memo != null) {
        txData.memo = memo;
      } else {
        // TODO: figure out how to get localized string here:
        txData.memo = "Decryption Error!";
        txData.memo_enc = memoEnc;
      }
    }

    // check if exists in db:
    final TXData? existingTXData = await sl.get<DBHelper>().getTXDataByUUID(uuid);
    if (existingTXData != null) {
      // update with the new info:
      existingTXData.is_acknowledged = true;
      existingTXData.request_time = requestTime;
      log.v("replacing TXData");
      await sl.get<DBHelper>().replaceTXDataByUUID(existingTXData);
    } else {
      log.v("adding TXData to db");
      // add it since it doesn't exist:
      await sl.get<DBHelper>().addTXData(txData);
    }

    // check for the local uuid just in case:
    if (localUuid != null && localUuid.isNotEmpty && localUuid.contains("LOCAL")) {
      final TXData? localTXData = await sl.get<DBHelper>().getTXDataByUUID(localUuid);
      if (localTXData != null) {
        // remove it:
        await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      }
    }

    if (!delay_update) {
      await updateSolids();
      await updateUnified(false);
    }
    // send acknowledgement to server / requester:
    await sl.get<MetadataService>().requestACK(uuid, requestingAccount, wallet!.address);
  }

  Future<void> handlePaymentRecord(dynamic data, {bool delay_update = false}) async {
    sl.get<Logger>().v("handling payment_record from: ${data['requesting_account']} : ${data['account']}");
    final String? amountRaw = data['amount_raw'] as String?;
    final String? requestingAccount = data['requesting_account'] as String?;
    final String? memoEnc = data['memo_enc'] as String?;
    final int requestTime = int.parse(data['request_time'] as String);
    final String? toAddress = data['account'] as String?;
    final String? block = data['block'] as String?;
    final String? uuid = data['uuid'] as String?;
    final String? localUuid = data['local_uuid'] as String?;

    if (data.containsKey("is_request") as bool) {
      if (wallet != null && wallet!.address != null && Address(wallet!.address).isValid()) {
        TXData? txData;
        TXData? oldTXData;

        // we have to check if this payment is already in the db:
        txData = await sl.get<DBHelper>().getTXDataByUUID(uuid!);
        if (txData != null) {
          log.v("replacing existing txData for record!");
          // this payment is already in the db:
          // merge the two TXData objects;
          final TXData newTXInfo = txData;
          newTXInfo.amount_raw = amountRaw;
          newTXInfo.from_address = requestingAccount;
          newTXInfo.to_address = toAddress;

          // newTXInfo.block = block;// don't overwrite the block
          // newTXInfo.memo = memo;
          newTXInfo.request_time = requestTime;

          if (memoEnc != null && memoEnc.isNotEmpty) {
            final String memo = await decryptMessageCurrentAccount(memoEnc, requestingAccount, toAddress);
            if (memo != null) {
              newTXInfo.memo = memo;
            } else {
              // TODO: figure out how to get localized string here:
              newTXInfo.memo = "Decryption Error!";
              newTXInfo.memo_enc = memoEnc;
            }
          }

          await sl.get<DBHelper>().replaceTXDataByUUID(newTXInfo);
        }

        // is this from us? if so we need to check for the local version of this payment_request:

        // check if this is a local payment_request:
        if (localUuid != null && localUuid.isNotEmpty && localUuid.contains("LOCAL")) {
          oldTXData = await sl.get<DBHelper>().getTXDataByUUID(localUuid);

          // if (requesting_account == wallet.address) {
          // var transactions = await sl.get<DBHelper>().getAccountSpecificRequests(wallet.address);
          // // go through the list and see if any of them happened within the last 5 minutes:
          // // make sure all other fields match, too:

          // print("${wallet.address} : ${to_address} : ${amount_raw}");
          // for (var tx in transactions) {
          //   // make sure we only delete local requests that were within the last 5 minutes:
          //   if (tx.uuid.contains("LOCAL")) {
          //     // print("${tx.from_address} : ${tx.to_address} : ${tx.amount_raw} : ${tx.uuid}");
          //     // make sure this is the request we made:
          //     if (tx.from_address == wallet.address && tx.to_address == to_address && tx.amount_raw == amount_raw) {
          //       if (DateTime.parse(tx.request_time).isAfter(DateTime.now().subtract(Duration(minutes: 5)))) {
          //         // this is a duplicate payment record, delete it:
          //         oldTXData = tx;
          //         // print("found a local payment record that is within the last 5 minutes");
          //         break;
          //       }
          //     }
          //   }
          // }

          if (oldTXData != null) {
            log.v("removing old txData!");
            // remove the old tx by the uuid:
            await sl.get<DBHelper>().deleteTXDataByUUID(oldTXData.uuid!);

            // if we didn't replace an existing txData, add it to the db:
            if (txData == null) {
              // add it since it doesn't exist:
              log.v("adding payment_record : request to db");
              oldTXData.uuid = uuid;
              oldTXData.request_time = requestTime;
              oldTXData.status = StatusTypes.CREATE_SUCCESS;
              await sl.get<DBHelper>().addTXData(oldTXData);
            }
          }
        }

        // we didn't replace a txData??
        if (txData == null && oldTXData == null) {
          // log.d("adding txData to the database!");
          throw Exception("\n\n@@@@@@@@this shouldn't happen!@@@@@@@@@@\n\n");
        }
        if (!delay_update) {
          await updateSolids();
          await updateUnified(true);
        }
      }
    }

    if (data.containsKey("is_message") as bool) {
      if (wallet != null && wallet!.address != null && Address(wallet!.address).isValid()) {
        TXData? txData;
        TXData? oldTXData;

        // we have to check if this payment is already in the db:
        txData = await sl.get<DBHelper>().getTXDataByUUID(uuid!);
        if (txData != null) {
          sl.get<Logger>().v("replacing existing txData for record!");
          // this payment is already in the db:
          // merge the two TXData objects;
          final TXData newTXInfo = txData;
          newTXInfo.amount_raw = amountRaw;
          newTXInfo.from_address = requestingAccount;
          newTXInfo.to_address = toAddress;
          // newTXInfo.block = block;// don't overwrite the block
          // newTXInfo.memo = memo;
          newTXInfo.request_time = requestTime;

          if (memoEnc != null && memoEnc.isNotEmpty) {
            final String memo = await decryptMessageCurrentAccount(memoEnc, requestingAccount, toAddress);
            if (memo != null) {
              newTXInfo.memo = memo;
            } else {
              // TODO: figure out how to get localized string here:
              newTXInfo.memo = "Decryption Error!";
              newTXInfo.memo_enc = memoEnc;
            }
          }

          await sl.get<DBHelper>().replaceTXDataByUUID(newTXInfo);
        }

        // is this from us? if so we need to check for the local version of this payment_request:

        // check if this is a local payment_request:
        if (localUuid != null && localUuid.isNotEmpty && localUuid.contains("LOCAL")) {
          oldTXData = await sl.get<DBHelper>().getTXDataByUUID(localUuid);

          if (oldTXData != null) {
            log.v("removing old txData : message");
            // remove the old tx by the uuid:
            await sl.get<DBHelper>().deleteTXDataByUUID(oldTXData.uuid!);

            // if we didn't replace an existing txData, add it to the db:
            if (txData == null) {
              // add it since it doesn't exist:
              log.v("adding payment_record : message to db");
              oldTXData.uuid = uuid;
              oldTXData.request_time = requestTime;
              oldTXData.status = StatusTypes.CREATE_SUCCESS;
              await sl.get<DBHelper>().addTXData(oldTXData);
            }
          }
        }

        // we didn't replace a txData??
        if (txData == null && oldTXData == null) {
          // log.d("adding txData to the database!");
          log.e("\@@@@@@@@this shouldn't happen!@@@@@@@@@@");
        }
        if (!delay_update) {
          await updateSolids();
          await updateUnified(true);
        }
      }
    }

    if (data.containsKey("is_memo") as bool) {
      // check if exists in db:
      TXData? existingTXData = await sl.get<DBHelper>().getTXDataByBlock(block);

      if (existingTXData == null) {
        // check if there is a local payment_memo since we didn't find it by block:
        // this case probably only happens on a slow network connection, if at all:
        if (localUuid != null && localUuid.isNotEmpty && localUuid.contains("LOCAL")) {
          log.v("memo block wasn't found while processing payment_record!");
          existingTXData = await sl.get<DBHelper>().getTXDataByUUID(localUuid);
        }
      }

      if (existingTXData != null) {
        // print("memo block exists");
        // delete local version and add new one:
        // existingTXData.memo = memo;
        existingTXData.block = block;
        // remove the local one if it exists:
        if (existingTXData.uuid!.contains("LOCAL")) {
          log.d("removing the local txData for this memo: ${existingTXData.uuid}");
          await sl.get<DBHelper>().deleteTXDataByUUID(existingTXData.uuid!);
          await sl.get<DBHelper>().deleteTXDataByBlock(existingTXData.block!);
          // add the new one and change the uuid to be not local:
          existingTXData.uuid = uuid;
          existingTXData.status = "sent";
          await sl.get<DBHelper>().addTXData(existingTXData);
        } else {
          log.d("updating the txData for this memo");
          // we updated the other fields up above, so we don't need to update them here:
          // TODO: should check to make sure uuid matches:
          await sl.get<DBHelper>().replaceTXDataByUUID(existingTXData);
        }
      } else {
        throw Exception("no txData found for this memo in payment record!");
      }
    }
  }

  Future<void> handlePaymentMemo(dynamic data, {bool delay_update = false}) async {
    log.d("handling payment_memo from: ${data['requesting_account']} : ${data['account']}");
    // String amount_raw = data['amount_raw'];
    final String? requestingAccount = data['requesting_account'] as String?;
    final String? toAddress = data['account'] as String?;
    final String? memoEnc = data['memo_enc'] as String?;
    final String? block = data['block'] as String?;
    final int? height = data['height'] as int?;
    final String? uuid = data['uuid'] as String?;
    final String? localUuid = data['local_uuid'] as String?;

    final TXData txData = TXData(
      // amount_raw: amount_raw,
      is_request: false,
      is_memo: true,
      from_address: requestingAccount,
      to_address: toAddress,
      is_fulfilled: true,
      block: block,
      link: null,
      uuid: uuid,
      is_acknowledged: false,
      height: height,
    );

    // attempt to decrypt the memo:
    if (memoEnc != null && memoEnc.isNotEmpty) {
      final String memo = await decryptMessageCurrentAccount(memoEnc, requestingAccount, toAddress);
      if (memo != null) {
        txData.memo = memo;
      } else {
        // TODO: figure out how to get localized string here:
        txData.memo = "Decryption Error!";
        txData.memo_enc = memoEnc;
      }
    }

    bool found = false;
    // loop through our tx history to find the first matching block:
    for (final AccountHistoryResponseItem histItem in wallet!.history) {
      if (histItem.link == block) {
        // found a matching transaction, so set the block to that:
        txData.link = histItem.hash;
        found = true;
        break;
      }
    }

    // check if exists in db:
    final TXData? existingTXData = await sl.get<DBHelper>().getTXDataByUUID(uuid!);
    if (existingTXData != null) {
      sl.get<Logger>().v("memo txData exists");
      // update with the new info:
      existingTXData.block = txData.block;
      if (found) {
        existingTXData.link = txData.link;
      }
      existingTXData.is_acknowledged = true;
      // just in case:
      existingTXData.to_address = txData.to_address;
      existingTXData.from_address = txData.from_address;
      await sl.get<DBHelper>().replaceTXDataByUUID(existingTXData);
    } else {
      sl.get<Logger>().v("adding memo txData to the database!");
      // TODO: check for duplicates and remove them:
      // add it since it doesn't exist in the db:
      await sl.get<DBHelper>().addTXData(txData);
    }

    // check for local_uuid just incase:
    if (localUuid != null && localUuid.isNotEmpty && localUuid.contains("LOCAL")) {
      // check if there is a local payment_memo:
      final TXData? localTXData = await sl.get<DBHelper>().getTXDataByUUID(localUuid);
      if (localTXData != null) {
        // delete the local one:
        await sl.get<DBHelper>().deleteTXDataByUUID(localUuid);
      }
    }

    if (!delay_update) {
      await updateSolids();
      await updateTXMemos();
    }

    // send acknowledgement to server / requester:
    await sl.get<MetadataService>().requestACK(uuid, requestingAccount, wallet!.address);
  }

  Future<void> handlePaymentACK(dynamic data, {bool delay_update = false}) async {
    sl.get<Logger>().v("handling payment_ack from: ${data['requesting_account']}");
    sl.get<Logger>().v("handling payment_ack");
    final String? amountRaw = data['amount_raw'] as String?;
    final String? requestingAccount = data['requesting_account'] as String?;
    final String? memo = data['memo'] as String?;
    final String? toAddress = data['account'] as String?;
    final String uuid = data['uuid'] as String;
    final String? block = data['block'] as String?;
    final String? isAcknowledged = data['is_acknowledged'] as String?;
    final int? height = data['height'] as int?;

    // sleep to prevent animations from overlapping:
    // await Future<dynamic>.delayed(Duration(seconds: 2));

    // set acknowledged to true:
    final TXData? txData = await sl.get<DBHelper>().getTXDataByUUID(uuid);
    if (txData != null) {
      await sl.get<DBHelper>().changeTXAckStatus(uuid, true);
      sl.get<Logger>().v("changed ack status!: $uuid");
    } else {
      sl.get<Logger>().d("we didn't have a txData for this payment ack!: $uuid");
    }
    if (!delay_update) {
      await updateSolids();
      await updateTXMemos();
      await updateUnified(true);
    }
  }

  Future<void> handleMessage(dynamic data, {bool delay_update = false}) async {
    // handle an incoming payment request:
    if (data.containsKey("payment_request") as bool) {
      await handlePaymentRequest(data, delay_update: delay_update);
    }

    if (data.containsKey("payment_message") as bool) {
      await handlePaymentMessage(data, delay_update: delay_update);
    }

    // handle an incoming memo:
    if (data.containsKey("payment_memo") as bool) {
      await handlePaymentMemo(data, delay_update: delay_update);
    }

    // payment records are essentially server copies of local txData:
    if (data.containsKey("payment_record") as bool) {
      await handlePaymentRecord(data, delay_update: delay_update);
    }

    if (data.containsKey("payment_ack") as bool) {
      await handlePaymentACK(data, delay_update: delay_update);
    }
  }

  void logOut() {
    setState(() {
      wallet = AppWallet();
      encryptedSecret = null;
      xmrAddress = "";
      xmrFee = "";
      xmrRestoreHeight = 0;
    });
    sl.get<DBHelper>().dropAccounts();
    sl.get<AccountService>().clearQueue();
  }

  Future<String> _getPrivKey() async {
    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    final String seed = await getSeed();
    return NanoUtil.uniSeedToPrivate(seed, selectedAccount!.index!, derivationMethod);
  }

  Future<String> getSeed() async {
    String? seed;
    if (encryptedSecret != null) {
      seed = NanoHelpers.byteToHex(NanoCrypt.decrypt(encryptedSecret, await sl.get<Vault>().getSessionKey()));
    } else {
      seed = await sl.get<Vault>().getSeed();
    }
    return seed!;
  }

  // Simple build method that just passes this state through
  // your InheritedWidget
  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}
