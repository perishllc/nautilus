import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/contacts_setting_change_event.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/bus/notification_setting_change_event.dart';
import 'package:wallet_flutter/bus/payments_home_event.dart';
import 'package:wallet_flutter/bus/xmr_event.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/authentication_method.dart';
import 'package:wallet_flutter/model/available_block_explorer.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/model/available_language.dart';
import 'package:wallet_flutter/model/available_themes.dart';
import 'package:wallet_flutter/model/contacts_setting.dart';
import 'package:wallet_flutter/model/currency_mode_setting.dart';
import 'package:wallet_flutter/model/db/account.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/device_lock_timeout.dart';
import 'package:wallet_flutter/model/device_unlock_option.dart';
import 'package:wallet_flutter/model/funding_setting.dart';
import 'package:wallet_flutter/model/min_raw_setting.dart';
import 'package:wallet_flutter/model/natricon_option.dart';
import 'package:wallet_flutter/model/notification_setting.dart';
import 'package:wallet_flutter/model/nyanicon_option.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:wallet_flutter/network/model/response/funding_response_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:wallet_flutter/ui/accounts/accounts_sheet.dart';
import 'package:wallet_flutter/ui/onboard_sheet.dart';
import 'package:wallet_flutter/ui/settings/backupseed_sheet.dart';
import 'package:wallet_flutter/ui/settings/blocked_widget.dart';
import 'package:wallet_flutter/ui/settings/change_magic_password_sheet.dart';
import 'package:wallet_flutter/ui/settings/change_magic_seed_sheet.dart';
import 'package:wallet_flutter/ui/settings/change_node/change_node_sheet.dart';
import 'package:wallet_flutter/ui/settings/changerepresentative_sheet.dart';
import 'package:wallet_flutter/ui/settings/contacts_widget.dart';
import 'package:wallet_flutter/ui/settings/set_pin_sheet.dart';
import 'package:wallet_flutter/ui/settings/set_plausible_pin_sheet.dart';
import 'package:wallet_flutter/ui/settings/settings_list_item.dart';
import 'package:wallet_flutter/ui/transfer/transfer_complete_sheet.dart';
import 'package:wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:wallet_flutter/ui/widgets/funding_message_card.dart';
import 'package:wallet_flutter/ui/widgets/funding_messages_sheet.dart';
import 'package:wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:wallet_flutter/ui/widgets/remote_message_card.dart';
import 'package:wallet_flutter/ui/widgets/remote_message_sheet.dart';
import 'package:wallet_flutter/ui/widgets/security.dart';
import 'package:wallet_flutter/ui/widgets/set_xmr_restore_height.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/biometrics.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/hapticutil.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/ninja/api.dart';
import 'package:wallet_flutter/util/ninja/ninja_node.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/strings.dart';
import 'package:share_plus/share_plus.dart';

class SettingsSheet extends StatefulWidget {
  @override
  SettingsSheetState createState() => SettingsSheetState();
}

class SettingsSheetState extends State<SettingsSheet> with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _contactsController;
  AnimationController? _blockedController;
  late AnimationController _securityController;
  late AnimationController _moreSettingsController;
  late AnimationController _shareController;
  // late AnimationController _spendNanoController;
  late AnimationController _useNanoController;
  late Animation<Offset> _contactsOffsetFloat;
  late Animation<Offset> _blockedOffsetFloat;
  late Animation<Offset> _securityOffsetFloat;
  late Animation<Offset> _moreSettingsOffsetFloat;
  late Animation<Offset> _shareOffsetFloat;
  // late Animation<Offset> _spendNanoOffsetFloat;
  late Animation<Offset> _useNanoOffsetFloat;
  late ScrollController _scrollController;
  ScrollController _moreSettingsScrollController = ScrollController();
  ScrollController _securityScrollController = ScrollController();

  double _slideOffset = 0.0;

  String versionString = "";

  final Logger log = sl.get<Logger>();
  bool _hasBiometrics = false;
  AuthenticationMethod _curAuthMethod = AuthenticationMethod(AuthMethod.BIOMETRICS);
  NotificationSetting _curNotificiationSetting = NotificationSetting(NotificationOptions.ON);
  ContactsSetting _curContactsSetting = ContactsSetting(ContactsOptions.OFF);
  ContactsSetting _curUnopenedWarningSetting = ContactsSetting(ContactsOptions.ON);
  ContactsSetting _curXmrEnabledSetting = ContactsSetting(ContactsOptions.ON);
  ContactsSetting _curTrackingSetting = ContactsSetting(ContactsOptions.ON);
  NatriconSetting _curNatriconSetting = NatriconSetting(NatriconOptions.ON);
  NyaniconSetting _curNyaniconSetting = NyaniconSetting(NyaniconOptions.ON);
  FundingSetting _curFundingSetting = FundingSetting(FundingOptions.SHOW);
  MinRawSetting _curMinRawSetting = MinRawSetting(MinRawOptions.OFF);
  CurrencyModeSetting _curCurrencyModeSetting = CurrencyModeSetting(CurrencyModeOptions.NANO);
  UnlockSetting _curUnlockSetting = UnlockSetting(UnlockOption.NO);
  LockTimeoutSetting _curTimeoutSetting = LockTimeoutSetting(LockTimeoutOption.ONE);
  ThemeSetting _curThemeSetting = ThemeSetting(ThemeOptions.NAUTILUS);
  int _curXmrRestoreHeight = 0;

  late bool _loadingAccounts;

  late bool _contactsOpen;
  late bool _blockedOpen;
  late bool _securityOpen;
  late bool _moreSettingsOpen;
  late bool _shareOpen;
  // late bool _spendNanoOpen;
  late bool _useNanoOpen;

  bool _loggedInWithMagic = false;
  final Magic magic = Magic.instance;

  // Called if transfer fails
  void transferError() {
    Navigator.of(context).pop();
    UIUtil.showSnackbar(Z.of(context).transferError, context);
  }

  Future<bool> _getContactsPermissions() async {
    // reloading prefs:
    await sl.get<SharedPrefsUtil>().reload();
    final bool contactsOn = await sl.get<SharedPrefsUtil>().getContactsOn();

    // ask for contacts permission:
    if (!contactsOn) {
      // final bool contactsEnabled = await cont.FlutterContacts.requestPermission();
      // ignore: prefer_const_declarations
      final bool contactsEnabled = false;
      await sl.get<SharedPrefsUtil>().setContactsOn(contactsEnabled);
      setState(() {
        _curContactsSetting = ContactsSetting(contactsEnabled ? ContactsOptions.ON : ContactsOptions.OFF);
      });
      EventTaxiImpl.singleton().fire(ContactsSettingChangeEvent(isOn: contactsEnabled));
      return contactsEnabled;
    } else {
      setState(() {
        _curContactsSetting = ContactsSetting(contactsOn ? ContactsOptions.ON : ContactsOptions.OFF);
      });
      EventTaxiImpl.singleton().fire(ContactsSettingChangeEvent(isOn: contactsOn));
      return contactsOn;
    }
  }

  @override
  void initState() {
    super.initState();
    _contactsOpen = false;
    _blockedOpen = false;
    _securityOpen = false;
    _moreSettingsOpen = false;
    _shareOpen = false;
    // _spendNanoOpen = false;
    _useNanoOpen = false;
    _loadingAccounts = false;
    // Determine if they have face or fingerprint enrolled, if not hide the setting
    sl.get<BiometricUtil>().hasBiometrics().then((bool hasBiometrics) {
      // necessary since this is called asynchronously
      if (mounted) {
        setState(() {
          _hasBiometrics = hasBiometrics;
        });
      }
    });
    // Get default auth method setting
    sl.get<SharedPrefsUtil>().getAuthMethod().then((AuthenticationMethod authMethod) {
      setState(() {
        _curAuthMethod = authMethod;
      });
    });
    // Get default unlock settings
    sl.get<SharedPrefsUtil>().getLock().then((bool lock) {
      setState(() {
        _curUnlockSetting = lock ? UnlockSetting(UnlockOption.YES) : UnlockSetting(UnlockOption.NO);
      });
    });
    sl.get<SharedPrefsUtil>().getLockTimeout().then((LockTimeoutSetting lockTimeout) {
      setState(() {
        _curTimeoutSetting = lockTimeout;
      });
    });
    // Get default notification setting
    sl.get<SharedPrefsUtil>().getNotificationsOn().then((bool notificationsOn) {
      setState(() {
        _curNotificiationSetting = notificationsOn
            ? NotificationSetting(NotificationOptions.ON)
            : NotificationSetting(NotificationOptions.OFF);
      });
    });
    // Get contacts show setting:
    sl.get<SharedPrefsUtil>().getContactsOn().then((bool contactsOn) {
      setState(() {
        _curContactsSetting = contactsOn ? ContactsSetting(ContactsOptions.ON) : ContactsSetting(ContactsOptions.OFF);
      });
    });
    // Get unpopened warning setting:
    sl.get<SharedPrefsUtil>().getUnopenedWarningOn().then((bool contactsOn) {
      setState(() {
        _curUnopenedWarningSetting =
            contactsOn ? ContactsSetting(ContactsOptions.ON) : ContactsSetting(ContactsOptions.OFF);
      });
    });
    // Get show monero setting:
    sl.get<SharedPrefsUtil>().getXmrEnabled().then((bool contactsOn) {
      setState(() {
        _curXmrEnabledSetting = contactsOn ? ContactsSetting(ContactsOptions.ON) : ContactsSetting(ContactsOptions.OFF);
      });
    });
    // restore height:
    sl.get<SharedPrefsUtil>().getXmrRestoreHeight().then((int height) {
      setState(() {
        _curXmrRestoreHeight = StateContainer.of(context).xmrRestoreHeight ?? 0;
      });
    });
    // Get tracking authorization:
    sl.get<SharedPrefsUtil>().getTrackingEnabled().then((bool contactsOn) {
      setState(() {
        _curTrackingSetting = contactsOn ? ContactsSetting(ContactsOptions.ON) : ContactsSetting(ContactsOptions.OFF);
      });
    });
    // Get funding setting:
    sl.get<SharedPrefsUtil>().getFundingOn().then((bool fundingOn) {
      setState(() {
        _curFundingSetting = fundingOn ? FundingSetting(FundingOptions.SHOW) : FundingSetting(FundingOptions.HIDE);
      });
    });
    // Get default natricon setting
    sl.get<SharedPrefsUtil>().getUseNatricon().then((bool useNatricon) {
      setState(() {
        _curNatriconSetting = useNatricon ? NatriconSetting(NatriconOptions.ON) : NatriconSetting(NatriconOptions.OFF);
      });
    });
    // Get default nyanicon setting
    sl.get<SharedPrefsUtil>().getUseNyanicon().then((bool useNyanicon) {
      setState(() {
        _curNyaniconSetting = useNyanicon ? NyaniconSetting(NyaniconOptions.ON) : NyaniconSetting(NyaniconOptions.OFF);
      });
    });
    // Get min raw setting
    sl.get<SharedPrefsUtil>().getMinRawReceive().then((String minRawReceive) {
      setState(() {
        switch (minRawReceive) {
          case MinRawSetting.NONE_NYANO:
            _curMinRawSetting = MinRawSetting(MinRawOptions.OFF);
            break;
          case MinRawSetting.ONE_NYANO:
            _curMinRawSetting = MinRawSetting(MinRawOptions.ONE_NYANO);
            break;
          case MinRawSetting.TEN_NYANO:
            _curMinRawSetting = MinRawSetting(MinRawOptions.TEN_NYANO);
            break;
          case MinRawSetting.HUNDRED_NYANO:
            _curMinRawSetting = MinRawSetting(MinRawOptions.HUNDRED_NYANO);
            break;
          case MinRawSetting.THOUSAND_NYANO:
            _curMinRawSetting = MinRawSetting(MinRawOptions.THOUSAND_NYANO);
            break;
          case MinRawSetting.TEN_THOUSAND_NYANO:
            _curMinRawSetting = MinRawSetting(MinRawOptions.TEN_THOUSAND_NYANO);
            break;
          case MinRawSetting.HUNDRED_THOUSAND_NYANO:
            _curMinRawSetting = MinRawSetting(MinRawOptions.HUNDRED_THOUSAND_NYANO);
            break;
        }
      });
    });
    // Get currency mode setting
    sl.get<SharedPrefsUtil>().getCurrencyMode().then((String currencyMode) {
      setState(() {
        switch (currencyMode) {
          case "NANO":
            _curCurrencyModeSetting = CurrencyModeSetting(CurrencyModeOptions.NANO);
            break;
          case "NYANO":
            _curCurrencyModeSetting = CurrencyModeSetting(CurrencyModeOptions.NYANO);
            break;
        }
      });
    });
    // Get default theme settings
    sl.get<SharedPrefsUtil>().getTheme().then((ThemeSetting theme) {
      setState(() {
        _curThemeSetting = theme;
      });
    });
    // Register event bus
    _registerBus();
    // Setup animation controller
    _contactsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // For security menu
    _securityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // For blocked menu
    _blockedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // For more settings menu
    _moreSettingsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // For share menu
    _shareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // // For spend nano menu
    // _spendNanoController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 220),
    // );
    // For use nano menu
    _useNanoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _scrollController = ScrollController();

    _contactsOffsetFloat = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(_contactsController!);
    _securityOffsetFloat = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(_securityController);
    _blockedOffsetFloat = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(_blockedController!);
    _moreSettingsOffsetFloat =
        Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(_moreSettingsController);
    _useNanoOffsetFloat = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(_useNanoController);
    _shareOffsetFloat = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(_shareController);
    // Version string
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        versionString = "v${packageInfo.version}";
      });
    });

    // logged in with magic?
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final Magic magic = Magic.instance;
        if (await magic.user.isLoggedIn()) {
          if (!mounted) return;
          setState(() {
            _loggedInWithMagic = true;
          });
        }
      } catch (e) {
        log.e(e.toString());
      }
    });
  }

  StreamSubscription<TransferConfirmEvent>? _transferConfirmSub;
  StreamSubscription<TransferCompleteEvent>? _transferCompleteSub;
  StreamSubscription<NotificationSettingChangeEvent>? _notificationSettingChangeSub;
  StreamSubscription<ContactsSettingChangeEvent>? _contactsSettingChangeSub;
  StreamSubscription<XMREvent>? _xmrSub;

  void _registerBus() {
    // Ready to go to transfer confirm
    _transferConfirmSub =
        EventTaxiImpl.singleton().registerTo<TransferConfirmEvent>().listen((TransferConfirmEvent event) {
      Sheets.showAppHeightNineSheet(
          context: context,
          widget: AppTransferConfirmSheet(
            privKeyBalanceMap: event.balMap,
            errorCallback: transferError,
          ));
    });
    // Ready to go to transfer complete
    _transferCompleteSub =
        EventTaxiImpl.singleton().registerTo<TransferCompleteEvent>().listen((TransferCompleteEvent event) {
      StateContainer.of(context).requestUpdate();
      AppTransferCompleteSheet(getRawAsThemeAwareAmount(context, event.amount.toString())).mainBottomSheet(context);
    });
    // notification setting changed:
    _notificationSettingChangeSub = EventTaxiImpl.singleton()
        .registerTo<NotificationSettingChangeEvent>()
        .listen((NotificationSettingChangeEvent event) {
      setState(() {
        _curNotificiationSetting =
            event.isOn ? NotificationSetting(NotificationOptions.ON) : NotificationSetting(NotificationOptions.OFF);
      });
    });
    // contacts setting changed:
    _contactsSettingChangeSub =
        EventTaxiImpl.singleton().registerTo<ContactsSettingChangeEvent>().listen((ContactsSettingChangeEvent event) {
      setState(() {
        _curContactsSetting = event.isOn ? ContactsSetting(ContactsOptions.ON) : ContactsSetting(ContactsOptions.OFF);
      });
    });
    // xmr:
    _xmrSub = EventTaxiImpl.singleton().registerTo<XMREvent>().listen((XMREvent event) {
      if (event.type == "set_restore_height") {
        if (!mounted) return;
        setState(() {
          _curXmrRestoreHeight = int.parse(event.message);
        });
      }
    });
  }

  void _destroyBus() {
    if (_transferConfirmSub != null) {
      _transferConfirmSub!.cancel();
    }
    if (_transferCompleteSub != null) {
      _transferCompleteSub!.cancel();
    }
    if (_notificationSettingChangeSub != null) {
      _notificationSettingChangeSub!.cancel();
    }
    if (_contactsSettingChangeSub != null) {
      _contactsSettingChangeSub!.cancel();
    }
  }

  @override
  void dispose() {
    _contactsController!.dispose();
    _securityController.dispose();
    _blockedController!.dispose();
    _destroyBus();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  Future<void> _authMethodDialog() async {
    switch (await showDialog<AuthMethod>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              Z.of(context).authMethod,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.BIOMETRICS);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).biometricsMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.PIN);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).pinMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.NONE);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).noneMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case AuthMethod.PIN:
        // check if pin is set, if not, set it:
        final String? curPin = await sl.get<Vault>().getPin();
        if (isEmpty(curPin)) {
          final String? pin = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
            return PinScreen(
              PinOverlayType.NEW_PIN,
            );
          }));
          if (pin == null || pin.length < 6) {
            return;
          }
          await sl.get<Vault>().writePin(pin);
        }

        await sl.get<SharedPrefsUtil>().setAuthMethod(AuthenticationMethod(AuthMethod.PIN));
        setState(() {
          _curAuthMethod = AuthenticationMethod(AuthMethod.PIN);
        });

        break;
      case AuthMethod.BIOMETRICS:
        await sl.get<SharedPrefsUtil>().setAuthMethod(AuthenticationMethod(AuthMethod.BIOMETRICS));
        setState(() {
          _curAuthMethod = AuthenticationMethod(AuthMethod.BIOMETRICS);
        });
        break;
      case AuthMethod.NONE:
        // can't unlock on NONE:
        if (_curUnlockSetting.setting == UnlockOption.YES) {
          await sl.get<SharedPrefsUtil>().setLock(false);
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.NO);
          });
        }

        await sl.get<SharedPrefsUtil>().setAuthMethod(AuthenticationMethod(AuthMethod.NONE));
        setState(() {
          _curAuthMethod = AuthenticationMethod(AuthMethod.NONE);
        });
        break;
      default:
        break;
    }
  }

  Future<void> _notificationsDialog() async {
    switch (await showDialog<NotificationOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              Z.of(context).notifications,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case NotificationOptions.ON:
        sl.get<SharedPrefsUtil>().setNotificationsOn(true).then((void result) {
          EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: true));
          FirebaseMessaging.instance.requestPermission();
          FirebaseMessaging.instance.getToken().then((String? fcmToken) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
          });
        });
        break;
      case NotificationOptions.OFF:
        sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((void result) {
          EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: false));
          FirebaseMessaging.instance.getToken().then((String? fcmToken) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
          });
        });
        break;
      default:
        break;
    }
  }

  Future<void> _contactsDialog() async {
    final ContactsOptions? picked = await showDialog<ContactsOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              Z.of(context).contactsHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });

    if (picked == null) {
      return;
    }

    if (picked == ContactsOptions.ON) {
      final bool contactsEnabled = await _getContactsPermissions();
      await sl.get<SharedPrefsUtil>().setContactsOn(contactsEnabled);
      EventTaxiImpl.singleton().fire(ContactsSettingChangeEvent(isOn: contactsEnabled));
    } else {
      await sl.get<SharedPrefsUtil>().setContactsOn(false);
      EventTaxiImpl.singleton().fire(ContactsSettingChangeEvent(isOn: false));
    }
  }

  Future<void> _unopenedWarningDialog() async {
    final ContactsOptions? picked = await showDialog<ContactsOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Z.of(context).unopenedWarningHeader,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                AppDialogs.infoButton(
                  context,
                  () {
                    AppDialogs.showInfoDialog(context, Z.of(context).unopenedWarningHeader,
                        Z.of(context).unopenedWarningInfo);
                  },
                )
              ],
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });

    if (picked == null) {
      return;
    }

    await sl.get<SharedPrefsUtil>().setUnopenedWarningOn(picked == ContactsOptions.ON);
    setState(() {
      _curUnopenedWarningSetting = ContactsSetting(picked);
    });
  }

  Future<void> _showMoneroDialog() async {
    final ContactsOptions? picked = await showDialog<ContactsOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Z.of(context).showMoneroHeader,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                AppDialogs.infoButton(
                  context,
                  () {
                    AppDialogs.showInfoDialog(context, Z.of(context).showMoneroHeader,
                        Z.of(context).showMoneroInfo);
                  },
                )
              ],
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });

    if (picked == null) {
      return;
    }

    final bool enabled = picked == ContactsOptions.ON;
    await sl.get<SharedPrefsUtil>().setXmrEnabled(enabled);
    if (!mounted) return;
    StateContainer.of(context).setXmrEnabled(enabled);
    setState(() {
      _curXmrEnabledSetting = ContactsSetting(picked);
    });
  }

  Future<void> _showTrackingDialog() async {
    bool? trackingEnabled;
    if (Platform.isIOS) {
      final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
      if (status == TrackingStatus.authorized) {
        trackingEnabled = true;
      }
    } else {
      trackingEnabled = await AppDialogs.showTrackingDialog(context, true);
    }
    if (trackingEnabled == null) {
      return;
    }
    await sl.get<SharedPrefsUtil>().setTrackingEnabled(trackingEnabled);
    FlutterBranchSdk.disableTracking(!trackingEnabled);

    if (!mounted) return;
    setState(() {
      _curTrackingSetting =
          trackingEnabled! ? ContactsSetting(ContactsOptions.ON) : ContactsSetting(ContactsOptions.OFF);
    });
  }

  Future<void> _fundingDialog() async {
    final FundingOptions? picked = await showDialog<FundingOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              Z.of(context).fundingBannerHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, FundingOptions.HIDE);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).hide,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, FundingOptions.SHOW);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).show,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });

    if (picked == null) {
      return;
    }

    await sl.get<SharedPrefsUtil>().setFundingOn(picked == FundingOptions.SHOW);
    setState(() {
      _curFundingSetting = FundingSetting(picked);
    });
  }

  List<Widget> _buildMinRawOptions() {
    final List<Widget> ret = <Widget>[];
    for (final MinRawOptions value in MinRawOptions.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            MinRawSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    }
    return ret;
  }

  List<Widget> _buildCurrencyModeOptions() {
    final List<Widget> ret = <Widget>[];
    for (final CurrencyModeOptions value in CurrencyModeOptions.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            CurrencyModeSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    }
    return ret;
  }

  Future<void> _minRawDialog() async {
    final MinRawOptions? chosen = await showDialog<MinRawOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Z.of(context).receiveMinimum,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                AppDialogs.infoButton(
                  context,
                  () {
                    AppDialogs.showInfoDialog(context, Z.of(context).receiveMinimumHeader,
                        Z.of(context).receiveMinimumInfo);
                  },
                )
              ],
            ),
            children: _buildMinRawOptions(),
          );
        });

    final String rawValue = MinRawSetting(chosen).getRaw();
    sl.get<SharedPrefsUtil>().setMinRawReceive(rawValue).then((void result) {
      setState(() {
        StateContainer.of(context).setMinRawReceive(rawValue);
        _curMinRawSetting = MinRawSetting(chosen);
      });
    });
  }

  Future<void> _currencyModeDialog() async {
    final CurrencyModeOptions? chosen = await showDialog<CurrencyModeOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  Z.of(context).currencyMode,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                AppDialogs.infoButton(
                  context,
                  () {
                    AppDialogs.showInfoDialog(context, Z.of(context).currencyModeHeader,
                        Z.of(context).currencyModeInfo);
                  },
                )
              ],
            ),
            children: _buildCurrencyModeOptions(),
          );
        });

    final String currencyMode = CurrencyModeSetting(chosen).getDisplayName();
    sl.get<SharedPrefsUtil>().setCurrencyMode(currencyMode).then((void result) {
      setState(() {
        StateContainer.of(context).setCurrencyMode(currencyMode);
        _curCurrencyModeSetting = CurrencyModeSetting(chosen);
      });
    });
  }

  Future<void> _lockDialog() async {
    switch (await showDialog<UnlockOption>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              Z.of(context).lockAppSetting,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, UnlockOption.NO);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).no,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, UnlockOption.YES);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Z.of(context).yes,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case UnlockOption.YES:
        sl.get<SharedPrefsUtil>().setLock(true).then((void result) {
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.YES);
          });
        });
        break;
      case UnlockOption.NO:
        sl.get<SharedPrefsUtil>().setLock(false).then((void result) {
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.NO);
          });
        });
        break;
      default:
        break;
    }
  }

  List<Widget> _buildCurrencyOptions() {
    final List<Widget> ret = <Widget>[];
    for (final AvailableCurrencyEnum value in AvailableCurrencyEnum.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            AvailableCurrency(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    }
    return ret;
  }

  Future<void> _currencyDialog() async {
    final AvailableCurrencyEnum? selection = await showAppDialog<AvailableCurrencyEnum>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                Z.of(context).currency,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildCurrencyOptions(),
          );
        });
    if (selection != null) {
      sl.get<SharedPrefsUtil>().setCurrency(AvailableCurrency(selection)).then((void result) {
        if (StateContainer.of(context).curCurrency.currency != selection) {
          setState(() {
            StateContainer.of(context).curCurrency = AvailableCurrency(selection);
          });
          StateContainer.of(context).requestSubscribe();
        }
      });
    }
  }

  List<Widget> _buildLanguageOptions() {
    final List<Widget> ret = <Widget>[];
    for (final AvailableLanguage value in AvailableLanguage.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            LanguageSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    }
    return ret;
  }

  Future<void> _languageDialog() async {
    final AvailableLanguage? selection = await showAppDialog<AvailableLanguage>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                Z.of(context).language,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildLanguageOptions(),
          );
        });
    if (selection != null) {
      sl.get<SharedPrefsUtil>().setLanguage(LanguageSetting(selection)).then((void result) {
        if (StateContainer.of(context).curLanguage.language != selection) {
          setState(() {
            StateContainer.of(context).updateLanguage(LanguageSetting(selection));
          });
        }
      });
    }
  }

  List<Widget> _buildExplorerOptions() {
    final List<Widget> ret = <Widget>[];
    for (final AvailableBlockExplorerEnum value in AvailableBlockExplorerEnum.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            AvailableBlockExplorer(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    }
    return ret;
  }

  Future<void> _explorerDialog() async {
    final AvailableBlockExplorerEnum? selection = await showAppDialog<AvailableBlockExplorerEnum>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Text(
                Z.of(context).blockExplorer,
                style: AppStyles.textStyleDialogHeader(context),
              ),
              AppDialogs.infoButton(context, () {
                AppDialogs.showInfoDialog(context, Z.of(context).blockExplorerHeader,
                    Z.of(context).blockExplorerInfo);
              }),
            ]),
            children: _buildExplorerOptions(),
          );
        });
    if (selection != null) {
      sl.get<SharedPrefsUtil>().setBlockExplorer(AvailableBlockExplorer(selection)).then((void result) {
        if (StateContainer.of(context).curBlockExplorer.explorer != selection) {
          setState(() {
            StateContainer.of(context).updateBlockExplorer(AvailableBlockExplorer(selection));
          });
        }
      });
    }
  }

  List<Widget> _buildLockTimeoutOptions() {
    final List<Widget> ret = <Widget>[];
    for (final LockTimeoutOption value in LockTimeoutOption.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            LockTimeoutSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    }
    return ret;
  }

  Future<void> _lockTimeoutDialog() async {
    final LockTimeoutOption? selection = await showAppDialog<LockTimeoutOption>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                Z.of(context).autoLockHeader,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildLockTimeoutOptions(),
          );
        });
    sl.get<SharedPrefsUtil>().setLockTimeout(LockTimeoutSetting(selection)).then((void result) {
      if (_curTimeoutSetting.setting != selection) {
        sl.get<SharedPrefsUtil>().setLockTimeout(LockTimeoutSetting(selection)).then((_) {
          setState(() {
            _curTimeoutSetting = LockTimeoutSetting(selection);
          });
        });
      }
    });
  }

  List<Widget> _buildThemeOptions() {
    final List<Widget> ret = <Widget>[];
    for (final ThemeOptions value in ThemeOptions.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            ThemeSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    }
    return ret;
  }

  Future<void> _themeDialog() async {
    final ThemeOptions? selection = await showAppDialog<ThemeOptions>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                Z.of(context).themeHeader,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildThemeOptions(),
          );
        });
    if (selection != null) {
      if (_curThemeSetting != ThemeSetting(selection)) {
        sl.get<SharedPrefsUtil>().setTheme(ThemeSetting(selection)).then((void result) {
          setState(() {
            StateContainer.of(context).updateTheme(ThemeSetting(selection));
            _curThemeSetting = ThemeSetting(selection);
          });
        });
      }
    }
  }

  Future<bool> _onBackButtonPressed() async {
    if (_contactsOpen) {
      setState(() {
        _contactsOpen = false;
      });
      _contactsController!.reverse();
      return false;
    } else if (_securityOpen) {
      setState(() {
        _securityOpen = false;
      });
      _securityController.reverse();
      return false;
    } else if (_blockedOpen) {
      setState(() {
        _blockedOpen = false;
      });
      _blockedController!.reverse();
      return false;
    } else if (_moreSettingsOpen) {
      setState(() {
        _moreSettingsOpen = false;
      });
      _moreSettingsController.reverse();
      return false;
    } else if (_useNanoOpen) {
      setState(() {
        _useNanoOpen = false;
      });
      _useNanoController.reverse();
      return false;
    } else if (_shareOpen) {
      setState(() {
        _shareOpen = false;
      });
      _shareController.reverse();
      return false;
    }
    return true;
  }

  void subMenuDragStart(DragStartDetails details) {
    if (_shareOpen || _moreSettingsOpen || _useNanoOpen || _securityOpen || _blockedOpen || _contactsOpen) {
      _slideOffset = 1.1;
    } else {
      _slideOffset = 0;
    }
  }

  void subMenuDragEnd(DragEndDetails details) {
    AnimationController? controller;
    if (_moreSettingsOpen) {
      controller = _moreSettingsController;
    } else if (_useNanoOpen) {
      controller = _useNanoController;
    } else if (_blockedOpen) {
      controller = _blockedController;
    } else if (_securityOpen) {
      controller = _securityController;
    } else if (_contactsOpen) {
      controller = _contactsController;
    } else if (_shareOpen) {
      controller = _shareController;
    }

    // no menus are open, so don't do anything:
    if (controller == null) {
      return;
    }

    if (_slideOffset > 0.7) {
      controller.fling(velocity: 1);
    } else {
      controller.fling(velocity: -1);
      // we don't call setState since it will trigger a re-render which will cause the animation to be reset before it completes:
      if (_moreSettingsOpen) {
        _moreSettingsOpen = false;
      } else if (_useNanoOpen) {
        _useNanoOpen = false;
      } else if (_blockedOpen) {
        _blockedOpen = false;
      } else if (_securityOpen) {
        _securityOpen = false;
      } else if (_contactsOpen) {
        _contactsOpen = false;
      } else if (_shareOpen) {
        _shareOpen = false;
      }
    }
  }

  void subMenuDragUpdate(DragUpdateDetails details) {
    if (_moreSettingsOpen) {
      _moreSettingsController.value = _slideOffset;
    } else if (_useNanoOpen) {
      _useNanoController.value = _slideOffset;
    } else if (_blockedOpen) {
      _blockedController!.value = _slideOffset;
    } else if (_securityOpen) {
      _securityController.value = _slideOffset;
    } else if (_contactsOpen) {
      _contactsController!.value = _slideOffset;
    } else if (_shareOpen) {
      _shareController.value = _slideOffset;
    }
    _slideOffset -= details.delta.dx / 250;
  }

  @override
  Widget build(BuildContext context) {
    // Drawer in flutter doesn't have a built-in way to push/pop elements
    // on top of it like our Android counterpart. So we can override back button
    // presses and replace the main settings widget with contacts based on a bool

    return WillPopScope(
      onWillPop: _onBackButtonPressed,
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            Container(
              color: StateContainer.of(context).curTheme.backgroundDark,
              constraints: const BoxConstraints.expand(),
            ),
            buildMainSettings(context),
            GestureDetector(
              onHorizontalDragStart: subMenuDragStart,
              onHorizontalDragEnd: subMenuDragEnd,
              onHorizontalDragUpdate: subMenuDragUpdate,
              child: SlideTransition(
                  position: _contactsOffsetFloat, child: ContactsList(_contactsController, _contactsOpen)),
            ),
            GestureDetector(
              onHorizontalDragStart: subMenuDragStart,
              onHorizontalDragEnd: subMenuDragEnd,
              onHorizontalDragUpdate: subMenuDragUpdate,
              child:
                  SlideTransition(position: _blockedOffsetFloat, child: BlockedList(_blockedController, _blockedOpen)),
            ),
            GestureDetector(
              onHorizontalDragStart: subMenuDragStart,
              onHorizontalDragEnd: subMenuDragEnd,
              onHorizontalDragUpdate: subMenuDragUpdate,
              child: SlideTransition(position: _securityOffsetFloat, child: buildSecurityMenu(context)),
            ),
            // GestureDetector(
            //   onHorizontalDragStart: subMenuDragStart,
            //   onHorizontalDragEnd: subMenuDragEnd,
            //   onHorizontalDragUpdate: subMenuDragUpdate,
            //   child: SlideTransition(position: _useNanoOffsetFloat, child: buildUseNanoMenu(context)),
            // ),
            GestureDetector(
              onHorizontalDragStart: subMenuDragStart,
              onHorizontalDragEnd: subMenuDragEnd,
              onHorizontalDragUpdate: subMenuDragUpdate,
              child: SlideTransition(position: _moreSettingsOffsetFloat, child: buildMoreSettingsMenu(context)),
            ),
            GestureDetector(
              onHorizontalDragStart: subMenuDragStart,
              onHorizontalDragEnd: subMenuDragEnd,
              onHorizontalDragUpdate: subMenuDragUpdate,
              child: SlideTransition(position: _shareOffsetFloat, child: buildShareMenu(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    int currentFundingIndex = 0;

    // go through and find the first active funding alert that hasn't met it's goal yet:
    if (StateContainer.of(context).fundingAlerts != null && StateContainer.of(context).fundingAlerts!.isNotEmpty) {
      for (int i = 0; i < StateContainer.of(context).fundingAlerts!.length; i++) {
        if (StateContainer.of(context).fundingAlerts![i] == null) {
          continue;
        }

        final FundingResponseItem fundingAlert = StateContainer.of(context).fundingAlerts![i];

        if (fundingAlert.currentAmountRaw == null || fundingAlert.goalAmountRaw == null) {
          continue;
        }

        final BigInt? currentAmountRaw = BigInt.tryParse(fundingAlert.currentAmountRaw!);
        final BigInt? goalAmountRaw = BigInt.tryParse(fundingAlert.goalAmountRaw!);
        if (currentAmountRaw == null || goalAmountRaw == null) {
          continue;
        }

        if (currentAmountRaw < goalAmountRaw) {
          currentFundingIndex = i;
          break;
        }
      }
    }

    final List<Widget> settingsAlerts = <Widget>[];
    for (final AlertResponseItem alert in StateContainer.of(context).settingsAlerts) {
      settingsAlerts.add(
        Container(
          padding: const EdgeInsetsDirectional.only(
            start: 12,
            end: 12,
            bottom: 20,
          ),
          child: RemoteMessageCard(
            alert: alert,
            onPressed: () {
              Sheets.showAppHeightEightSheet(
                context: context,
                widget: RemoteMessageSheet(
                  alert: alert,
                  hasDismissButton: false,
                ),
              );
            },
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 15.0),
      controller: _scrollController,
      children: <Widget>[
        // Active Alerts, Remote Message Card
        if (StateContainer.of(context).settingsAlerts.isNotEmpty)
          Column(
            children: settingsAlerts,
          ),
        if (StateContainer.of(context).fundingAlerts != null &&
            StateContainer.of(context).fundingAlerts!.isNotEmpty &&
            _curFundingSetting.setting == FundingOptions.SHOW)
          Container(
            padding: const EdgeInsetsDirectional.only(
              start: 12,
              end: 12,
              bottom: 20,
            ),
            child: FundingMessageCard(
              title: Z.of(context).donateToSupport,
              shortDescription: StateContainer.of(context).fundingAlerts![currentFundingIndex].title,
              currentAmountRaw: StateContainer.of(context).fundingAlerts![currentFundingIndex].currentAmountRaw,
              goalAmountRaw: StateContainer.of(context).fundingAlerts![currentFundingIndex].goalAmountRaw,
              hideAmounts: true,
              onPressed: () {
                Sheets.showAppHeightEightSheet(
                  context: context,
                  widget: FundingMessagesSheet(
                    alerts: StateContainer.of(context).fundingAlerts,
                    hasDismissButton: false,
                  ),
                );
              },
            ),
          ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
          child: Text(Z.of(context).featured,
              style: TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.w100, color: StateContainer.of(context).curTheme.text60)),
        ),
        // Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        // AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).home, AppIcons.home, onPressed: () {
        //   Navigator.of(context).pushNamed("/home_transition");
        // }),
        // Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        // AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).payments, AppIcons.money_bill_alt, onPressed: () {
        //   Navigator.of(context).pushNamed("/payments_page");
        // }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        // AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).useNano, AppIcons.coins,
        //     onPressed: () async {
        //   // Navigator.of(context).pushNamed("/purchase_nano");
        //   // final String? choice = await _onrampDialog();
        //   // if (choice != null) {
        //   //   await UIUtil.showWebview(context, choice);
        //   // }
        //   setState(() {
        //     _useNanoOpen = true;
        //   });
        //   _useNanoController.forward();
        // }),
        // Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        // AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).spendNano, AppIcons.coins, onPressed: () async {
        //   Navigator.of(context).pushNamed("/spend_nano");
        // }),
        // Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).registerUsername, AppIcons.at,
            onPressed: () {
          Navigator.of(context).pushNamed("/register_onchain_username");
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        // AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).registerUsername, Icons.tag,
        //     onPressed: () {
        //   Navigator.of(context).pushNamed("/register_nano_to_username");
        // }),
        // Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        // AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).createGiftCard, AppIcons.export_icon, onPressed: () {
        //   Navigator.of(context).pushNamed("/gift_paper_wallet");
        // }),
        // Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        // AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).swapXMR, AppIcons.swapcurrency, onPressed: () {
        //   Navigator.of(context).pushNamed("/swap_xmr");
        // }),
        // Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 30.0, top: 20, bottom: 10),
          child: Text(Z.of(context).preferences,
              style: TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.w100, color: StateContainer.of(context).curTheme.text60)),
        ),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).changeCurrency,
            StateContainer.of(context).curCurrency, AppIcons.currency, _currencyDialog),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).language,
            StateContainer.of(context).curLanguage, AppIcons.language, _languageDialog),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).notifications,
            _curNotificiationSetting, AppIcons.notifications, _notificationsDialog),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemDoubleLine(
            context, Z.of(context).themeHeader, _curThemeSetting, AppIcons.theme, _themeDialog),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemDoubleLine(
          context,
          Z.of(context).blockExplorer,
          StateContainer.of(context).curBlockExplorer,
          AppIcons.search,
          _explorerDialog,
        ),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(
            context, Z.of(context).securityHeader, AppIcons.security, onPressed: () {
          setState(() {
            _securityOpen = true;
          });
          _securityController.forward();
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 30, top: 20, bottom: 10),
          child: Text(Z.of(context).manage,
              style: TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.w100, color: StateContainer.of(context).curTheme.text60)),
        ),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(
            context, Z.of(context).contactsHeader, AppIcons.contact, onPressed: () async {
          // check if contacts have been asked before:
          // reloading prefs to be sure we get the latest value:
          await sl.get<SharedPrefsUtil>().reload();
          final bool contactsSet = await sl.get<SharedPrefsUtil>().getContactsSet();
          if (!contactsSet) {
            await _getContactsPermissions();
          }
          setState(() {
            _contactsOpen = true;
          });
          _contactsController!.forward();
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).blockedHeader, AppIcons.block,
            onPressed: () {
          setState(() {
            _blockedOpen = true;
          });
          _blockedController!.forward();
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(
            context, Z.of(context).backupSecretPhrase, AppIcons.backupseed, onPressed: () async {
          // Authenticate
          final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
          final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
          if (!mounted) return;
          if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
            try {
              final bool authenticated = await sl
                  .get<BiometricUtil>()
                  .authenticateWithBiometrics(context, Z.of(context).fingerprintSeedBackup);
              if (!mounted) return;
              if (authenticated) {
                sl.get<HapticUtil>().fingerprintSucess();
                StateContainer.of(context).getSeed().then((String seed) {
                  Sheets.showAppHeightNineSheet(
                      context: context,
                      widget: AppSeedBackupSheet(
                        seed: seed,
                      ));
                });
              }
            } catch (error) {
              if (!mounted) return;
              AppDialogs.showConfirmDialog(
                  context,
                  "Error",
                  error.toString(),
                  "Copy to clipboard",
                  () {
                    Clipboard.setData(ClipboardData(text: error.toString()));
                  },
                  cancelText: Z.of(context).close,
                  cancelAction: () {
                    Navigator.of(context).pop();
                  });
              await authenticateWithPin();
            }
          } else {
            await authenticateWithPin();
          }
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(
            context, Z.of(context).settingsTransfer, AppIcons.transferfunds, onPressed: () {
          AppTransferOverviewSheet().mainBottomSheet(context);
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).shareNautilus, AppIcons.share,
            onPressed: () {
          setState(() {
            _shareOpen = true;
          });
          _shareController.forward();
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(
            context, Z.of(context).moreSettings, AppIcons.more_horiz, onPressed: () async {
          setState(() {
            _moreSettingsOpen = true;
          });
          _moreSettingsController.forward();
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).logout, AppIcons.logout,
            onPressed: () {
          AppDialogs.showConfirmDialog(context, CaseChange.toUpperCase(Z.of(context).warning, context),
              Z.of(context).logoutDetail, Z.of(context).logoutAction.toUpperCase(), () {
            // Show another confirm dialog
            AppDialogs.showConfirmDialog(
                context,
                Z.of(context).logoutAreYouSure,
                Z.of(context).logoutReassurance,
                CaseChange.toUpperCase(Z.of(context).yes, context), () async {
              // prevent interaction while logging out:
              AppAnimation.animationLauncher(context, AnimationType.GENERIC);

              // Unsubscribe from notifications
              await sl.get<SharedPrefsUtil>().setNotificationsOn(false);
              try {
                final String? fcmToken = await FirebaseMessaging.instance.getToken();
                EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
                EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
              } catch (e) {
                log.e(e.toString());
              }

              try {
                if (_loggedInWithMagic) {
                  await magic.user.logout();
                }
              } catch (e) {
                log.e(e.toString());
              }

              try {
                // Delete all data
                await sl.get<Vault>().deleteAll();
                await sl.get<SharedPrefsUtil>().deleteAll();
                if (!mounted) return;
                StateContainer.of(context).logOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              } catch (e) {
                log.e(e.toString());
              }
            });
          });
        }),
        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
        Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Text(versionString, style: AppStyles.textStyleVersion(context)),
                    AppButton.pillButton(context, versionString, onPressed: () async {
                      await AppDialogs.showChangeLog(context);
                    }),
                    AppButton.pillButton(context, NonTranslatable.discord, onPressed: () async {
                      await UIUtil.showChromeSafariWebview(context, NonTranslatable.discordUrl);
                    }),
                    AppButton.pillButton(context, Z.of(context).nodeStatus, onPressed: () async {
                      await UIUtil.showChromeSafariWebview(context, NonTranslatable.nautilusNodeUrl);
                    }),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppButton.pillButton(context, Z.of(context).privacyPolicy, onPressed: () async {
                      await UIUtil.showChromeSafariWebview(context, NonTranslatable.privacyUrl);
                    }),
                    AppButton.pillButton(context, Z.of(context).eula, onPressed: () async {
                      await UIUtil.showChromeSafariWebview(context, NonTranslatable.eulaUrl);
                    }),
                  ],
                ),
              ],
            )),
      ],
    );
  }

  Widget buildMainSettings(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 30,
        ),
        child: Column(
          children: <Widget>[
            // A container for accounts area
            Container(
              margin: const EdgeInsetsDirectional.only(start: 26.0, end: 20, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Main Account
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 4.0),
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Container(
                                  width: 60,
                                  height: 45,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Icon(
                                    StateContainer.of(context).wallet!.watchOnly
                                        ? AppIcons.search
                                        : AppIcons.accountwallet,
                                    color: StateContainer.of(context).curTheme.success,
                                    size: 45,
                                  )),
                            ),
                            if (!StateContainer.of(context).wallet!.watchOnly)
                              Center(
                                child: Container(
                                  width: 60,
                                  height: 45,
                                  alignment: const AlignmentDirectional(0, 0.3),
                                  child: Text(
                                    StateContainer.of(context).selectedAccount!.getShortName().toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: StateContainer.of(context).curTheme.backgroundDark,
                                      fontSize: 16,
                                      fontFamily: "NunitoSans",
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            Center(
                              child: SizedBox(
                                width: 60,
                                height: 45,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                    padding: EdgeInsets.zero,
                                    // highlightColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                    // splashColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                  ),
                                  child: const SizedBox(
                                    width: 60,
                                    height: 45,
                                  ),
                                  onPressed: () {
                                    AccountDetailsSheet(StateContainer.of(context).selectedAccount!)
                                        .mainBottomSheet(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // A row for other accounts and account switcher
                      Row(
                        children: <Widget>[
                          // Second Account
                          if (StateContainer.of(context).recentLast != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: Icon(
                                      StateContainer.of(context).recentLast!.watchOnly
                                          ? AppIcons.search
                                          : AppIcons.accountwallet,
                                      color: StateContainer.of(context).curTheme.primary,
                                      size: 36,
                                    ),
                                  ),
                                  if (StateContainer.of(context).recentLast!.watchOnly)
                                    Center(
                                      child: Container(
                                        width: 48,
                                        height: 36,
                                        alignment: const AlignmentDirectional(0, 3),
                                        child: Text(StateContainer.of(context).recentLast!.getShortName().toUpperCase(),
                                            style: TextStyle(
                                              color: StateContainer.of(context).curTheme.text,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w800,
                                            )),
                                      ),
                                    )
                                  else
                                    Center(
                                      child: Container(
                                        width: 48,
                                        height: 36,
                                        alignment: const AlignmentDirectional(0, 0.3),
                                        child: Text(StateContainer.of(context).recentLast!.getShortName().toUpperCase(),
                                            style: TextStyle(
                                              color: StateContainer.of(context).curTheme.backgroundDark,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w800,
                                            )),
                                      ),
                                    ),
                                  Center(
                                    child: Container(
                                      width: 48,
                                      height: 36,
                                      color: Colors.transparent,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                          padding: EdgeInsets.zero,
                                          // highlightColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                          // splashColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                        ),
                                        onPressed: () {
                                          sl
                                              .get<DBHelper>()
                                              .changeAccount(StateContainer.of(context).recentLast)
                                              .then((_) {
                                            EventTaxiImpl.singleton().fire(AccountChangedEvent(
                                                account: StateContainer.of(context).recentLast, delayPop: true));
                                          });
                                        },
                                        child: Container(
                                          width: 48,
                                          height: 36,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Third Account
                          if (StateContainer.of(context).recentSecondLast != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: Icon(
                                      StateContainer.of(context).recentSecondLast!.watchOnly
                                          ? AppIcons.search
                                          : AppIcons.accountwallet,
                                      color: StateContainer.of(context).curTheme.primary,
                                      size: 36,
                                    ),
                                  ),
                                  if (!StateContainer.of(context).recentSecondLast!.watchOnly)
                                    Center(
                                      child: Container(
                                        width: 48,
                                        height: 36,
                                        alignment: const AlignmentDirectional(0, 0.3),
                                        child: Text(
                                            StateContainer.of(context).recentSecondLast!.getShortName().toUpperCase(),
                                            style: TextStyle(
                                              color: StateContainer.of(context).curTheme.backgroundDark,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w800,
                                            )),
                                      ),
                                    )
                                  else
                                    Center(
                                      child: Container(
                                        width: 48,
                                        height: 36,
                                        alignment: const AlignmentDirectional(0, 3),
                                        child: Text(
                                            StateContainer.of(context).recentSecondLast!.getShortName().toUpperCase(),
                                            style: TextStyle(
                                              color: StateContainer.of(context).curTheme.text,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w800,
                                            )),
                                      ),
                                    ),
                                  Center(
                                    child: Container(
                                      width: 48,
                                      height: 36,
                                      color: Colors.transparent,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                          padding: EdgeInsets.zero,
                                          // highlightColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                          // splashColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                        ),
                                        onPressed: () {
                                          sl
                                              .get<DBHelper>()
                                              .changeAccount(StateContainer.of(context).recentSecondLast)
                                              .then((_) {
                                            EventTaxiImpl.singleton().fire(AccountChangedEvent(
                                                account: StateContainer.of(context).recentSecondLast, delayPop: true));
                                          });
                                        },
                                        child: Container(
                                          width: 48,
                                          height: 36,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Account switcher
                          Container(
                            height: 36,
                            width: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 6.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    _loadingAccounts ? Colors.transparent : StateContainer.of(context).curTheme.text30,
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                                // splashColor: _loadingAccounts ? Colors.transparent : StateContainer.of(context).curTheme.text30,
                                // highlightColor: _loadingAccounts ? Colors.transparent : StateContainer.of(context).curTheme.text15,
                              ),
                              onPressed: () async {
                                if (!_loadingAccounts) {
                                  setState(() {
                                    _loadingAccounts = true;
                                  });
                                  final String seed = await StateContainer.of(context).getSeed();
                                  final List<Account> accounts = await sl.get<DBHelper>().getAccounts(seed);
                                  setState(() {
                                    _loadingAccounts = false;
                                  });
                                  Sheets.showAppHeightNineSheet(
                                      context: context, widget: AppAccountsSheet(accounts: accounts));
                                }
                              },
                              child: Icon(AppIcons.accountswitcher,
                                  size: 36,
                                  color: _loadingAccounts
                                      ? StateContainer.of(context).curTheme.primary60
                                      : StateContainer.of(context).curTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: StateContainer.of(context).curTheme.text30, padding: const EdgeInsets.all(4.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                        // highlightColor: StateContainer.of(context).curTheme.text15,
                        // splashColor: StateContainer.of(context).curTheme.text30,
                      ),
                      onPressed: () {
                        AccountDetailsSheet(StateContainer.of(context).selectedAccount!).mainBottomSheet(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Main account name
                          Text(
                            StateContainer.of(context).selectedAccount!.name!,
                            style: TextStyle(
                              fontFamily: "NunitoSans",
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: StateContainer.of(context).curTheme.text,
                            ),
                          ),
                          // Main account address
                          Text(
                            StateContainer.of(context).wallet?.username ??
                                Address(StateContainer.of(context).wallet!.address).getShortFirstPart() ??
                                "",
                            style: TextStyle(
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              fontSize: 14.0,
                              color: StateContainer.of(context).curTheme.text60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Settings items
            Expanded(
              child: Stack(
                children: <Widget>[
                  // Settings List
                  DraggableScrollbar(
                    controller: _scrollController,
                    scrollbarTopMargin: 20.0,
                    scrollbarBottomMargin: 0.0,
                    scrollbarColor: StateContainer.of(context).curTheme.primary,
                    child: _buildSettingsList(),
                  ),
                  ListGradient(
                    height: 20,
                    top: true,
                    color: StateContainer.of(context).curTheme.backgroundDark!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSecurityMenu(BuildContext context) {
    bool authLaunchDisabled = false;
    if (_curAuthMethod.method == AuthMethod.NONE && _curUnlockSetting.setting == UnlockOption.NO) {
      authLaunchDisabled = true;
    }
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StateContainer.of(context).curTheme.barrierWeakest!,
            offset: const Offset(-5, 0),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        minimum: const EdgeInsets.only(
          top: 60,
        ),
        child: Column(
          children: <Widget>[
            // Back button and Security Text
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Back button
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.only(right: 10, left: 10),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: StateContainer.of(context).curTheme.text15,
                              backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: const EdgeInsets.all(8),
                              // highlightColor: StateContainer.of(context).curTheme.text15,
                              // splashColor: StateContainer.of(context).curTheme.text15,
                            ),
                            onPressed: () {
                              setState(() {
                                _securityOpen = false;
                              });
                              _securityController.reverse();
                            },
                            child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                      ),
                      // Security Header Text
                      Text(
                        Z.of(context).securityHeader,
                        style: AppStyles.textStyleSettingsHeader(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: Stack(
              children: <Widget>[
                DraggableScrollbar(
                  controller: _securityScrollController,
                  scrollbarTopMargin: 20.0,
                  scrollbarBottomMargin: 0.0,
                  scrollbarColor: StateContainer.of(context).curTheme.primary,
                  child: ListView(
                    controller: _securityScrollController,
                    padding: const EdgeInsets.only(top: 15.0),
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
                        child: Text(Z.of(context).preferences,
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w100,
                                color: StateContainer.of(context).curTheme.text60)),
                      ),
                      // Authentication Method
                      if (_hasBiometrics) Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      if (_hasBiometrics)
                        AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).authMethod,
                            _curAuthMethod, AppIcons.fingerprint, _authMethodDialog),
                      // Authenticate on Launch
                      if (StateContainer.of(context).encryptedSecret == null)
                        Column(children: <Widget>[
                          Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                          AppSettings.buildSettingsListItemDoubleLine(context,
                              Z.of(context).lockAppSetting, _curUnlockSetting, AppIcons.lock, _lockDialog,
                              disabled: authLaunchDisabled),
                        ]),
                      // Authentication Timer
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        Z.of(context).autoLockHeader,
                        _curTimeoutSetting,
                        AppIcons.timer,
                        _lockTimeoutDialog,
                        disabled: _curUnlockSetting.setting == UnlockOption.NO &&
                            StateContainer.of(context).encryptedSecret == null,
                      ),
                      // Encrypt option
                      // if (StateContainer.of(context).encryptedSecret == null)
                      //   Column(children: <Widget>[
                      //     Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      //     AppSettings.buildSettingsListItemSingleLine(context, Z.of(context).setWalletPassword, AppIcons.walletpassword,
                      //         onPressed: () {
                      //       Sheets.showAppHeightNineSheet(context: context, widget: SetPasswordSheet());
                      //     })
                      //   ])
                      // else
                      //   Column(children: <Widget>[
                      //     Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      //     AppSettings.buildSettingsListItemSingleLine(
                      //         context, Z.of(context).disableWalletPassword, AppIcons.walletpassworddisabled, onPressed: () {
                      //       Sheets.showAppHeightNineSheet(context: context, widget: DisablePasswordSheet());
                      //     }),
                      //   ]),
                      Column(children: <Widget>[
                        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                        AppSettings.buildSettingsListItemSingleLine(
                            context, Z.of(context).setPlausibleDeniabilityPin, AppIcons.walletpassword,
                            onPressed: () {
                          Sheets.showAppHeightNineSheet(context: context, widget: SetPlausiblePinSheet());
                        },
                            disabled: _curAuthMethod.method != AuthMethod.PIN ||
                                StateContainer.of(context).encryptedSecret != null),
                      ]),
                      Column(children: <Widget>[
                        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                        AppSettings.buildSettingsListItemSingleLine(
                            context, Z.of(context).changePin, AppIcons.walletpassword, onPressed: () {
                          Sheets.showAppHeightNineSheet(context: context, widget: SetPinSheet());
                        }, disabled: false),
                      ]),
                      if (_loggedInWithMagic)
                        Column(children: <Widget>[
                          Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                          AppSettings.buildSettingsListItemSingleLine(
                              context, Z.of(context).changePassword, AppIcons.walletpassword,
                              onPressed: () {
                            Sheets.showAppHeightNineSheet(context: context, widget: ChangeMagicPasswordSheet());
                          }, disabled: false),
                        ]),
                      if (_loggedInWithMagic)
                        Column(children: <Widget>[
                          Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                          AppSettings.buildSettingsListItemSingleLine(
                              context, Z.of(context).changeSeed, Icons.vpn_key, onPressed: () {
                            Sheets.showAppHeightNineSheet(context: context, widget: ChangeMagicSeedSheet());
                          }, disabled: false),
                        ]),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    ],
                  ),
                ),
                // List Top Gradient End
                ListGradient(
                  height: 20,
                  top: true,
                  color: StateContainer.of(context).curTheme.backgroundDark!,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransactionData() async {
    final List<TXData> transactionData =
        await sl.get<DBHelper>().getAccountSpecificTXData(StateContainer.of(context).wallet!.address);
    if (!mounted) {
      return;
    }

    final List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[];
    for (final TXData txData in transactionData) {
      jsonList.add(txData.toJson());
    }

    final List<AccountHistoryResponseItem> transactionHistory = StateContainer.of(context).wallet!.history;

    for (final AccountHistoryResponseItem histItem in transactionHistory) {
      jsonList.add(histItem.toJson());
    }

    if (jsonList.isEmpty) {
      UIUtil.showSnackbar(Z.of(context).noTXDataExport, context);
      return;
    }

    final DateTime exportTime = DateTime.now();
    final String filename =
        "nautilus_txdata_${exportTime.year}${exportTime.month}${exportTime.day}${exportTime.hour}${exportTime.minute}${exportTime.second}.json";
    final Directory baseDirectory = await getApplicationDocumentsDirectory();
    final File contactsFile = File("${baseDirectory.path}/$filename");
    await contactsFile.writeAsString(json.encode(jsonList));
    UIUtil.cancelLockEvent();
    Share.shareFiles(<String>["${baseDirectory.path}/$filename"]);
  }

  Widget buildMoreSettingsMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StateContainer.of(context).curTheme.barrierWeakest!,
            offset: const Offset(-5, 0),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        minimum: const EdgeInsets.only(
          top: 60,
        ),
        child: Column(
          children: <Widget>[
            // Back button and Security Text
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Back button
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.only(right: 10, left: 10),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: StateContainer.of(context).curTheme.text15,
                              backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: const EdgeInsets.all(8),
                              // highlightColor: StateContainer.of(context).curTheme.text15,
                              // splashColor: StateContainer.of(context).curTheme.text15,
                            ),
                            onPressed: () {
                              setState(() {
                                _moreSettingsOpen = false;
                              });
                              _moreSettingsController.reverse();
                            },
                            child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                      ),
                      // Header Text
                      Text(
                        Z.of(context).moreSettings,
                        style: AppStyles.textStyleSettingsHeader(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: Stack(
              children: <Widget>[
                DraggableScrollbar(
                  controller: _moreSettingsScrollController,
                  scrollbarTopMargin: 20.0,
                  scrollbarBottomMargin: 0.0,
                  scrollbarColor: StateContainer.of(context).curTheme.primary,
                  child: ListView(
                    padding: const EdgeInsets.only(top: 15.0),
                    controller: _moreSettingsScrollController,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
                        child: Text(Z.of(context).preferences,
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w100,
                                color: StateContainer.of(context).curTheme.text60)),
                      ),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).showMoneroHeader,
                          _curXmrEnabledSetting, AppIcons.money_bill_alt, _showMoneroDialog),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemDoubleLine(
                          context, Z.of(context).setXMRRestoreHeight, null, AppIcons.backupseed,
                          overrideSubtitle: _curXmrRestoreHeight.toString(), () async {
                        Sheets.showAppHeightEightSheet(context: context, widget: SetXMRRestoreHeightSheet());
                      }),
                      // Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      // AppSettings.buildSettingsListItemDoubleLine(
                      //     context, Z.of(context).showContacts, _curContactsSetting, AppIcons.addcontact, _contactsDialog),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemDoubleLine(
                          context,
                          Z.of(context).showUnopenedWarning,
                          _curUnopenedWarningSetting,
                          AppIcons.warning,
                          _unopenedWarningDialog),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).showFunding,
                          _curFundingSetting, AppIcons.money_bill_wave, _fundingDialog),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).currencyMode,
                          _curCurrencyModeSetting, AppIcons.currency, _currencyModeDialog),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).receiveMinimum,
                          _curMinRawSetting, AppIcons.less_than_equal, _minRawDialog),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemDoubleLine(context, Z.of(context).trackingHeader,
                          _curTrackingSetting, AppIcons.security, _showTrackingDialog),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 30, top: 20, bottom: 10),
                        child: Text(Z.of(context).manage,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w100,
                                color: StateContainer.of(context).curTheme.text60)),
                      ),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemSingleLine(
                          context, Z.of(context).changeRepAuthenticate, Icons.hub,
                          onPressed: () {
                        Sheets.showAppHeightEightSheet(
                            context: context, widget: ChangeNodeSheet());
                        if (!StateContainer.of(context).nanoNinjaUpdated) {
                          NinjaAPI.getVerifiedNodes().then((List<NinjaNode>? result) {
                            if (result != null) {
                              StateContainer.of(context).updateNinjaNodes(result);
                            }
                          });
                        }
                      }),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemSingleLine(
                          context, Z.of(context).changeRepAuthenticate, AppIcons.changerepresentative,
                          onPressed: () {
                        Sheets.showAppHeightEightSheet(
                            context: context, widget: const AppChangeRepresentativeSheet());
                        if (!StateContainer.of(context).nanoNinjaUpdated) {
                          NinjaAPI.getVerifiedNodes().then((List<NinjaNode>? result) {
                            if (result != null) {
                              StateContainer.of(context).updateNinjaNodes(result);
                            }
                          });
                        }
                      }),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemSingleLine(
                          context, Z.of(context).exportTXData, AppIcons.file_export, onPressed: () async {
                        await _exportTransactionData();
                      }),
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemSingleLine(
                          context, Z.of(context).resetDatabase, AppIcons.trashcan, onPressed: () async {
                        AppDialogs.showConfirmDialog(
                            context,
                            Z.of(context).resetDatabase,
                            Z.of(context).resetDatabaseConfirmation,
                            CaseChange.toUpperCase(Z.of(context).yes, context), () async {
                          // push animation to prevent early exit:
                          bool animationOpen = true;
                          AppAnimation.animationLauncher(context, AnimationType.GENERIC,
                              onPoppedCallback: () => animationOpen = false);

                          // sleep to flex the animation a bit:
                          await Future<dynamic>.delayed(const Duration(milliseconds: 500));

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
                              username: "nautilus",
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
                        }, cancelText: CaseChange.toUpperCase(Z.of(context).no, context));
                      }),
                    ],
                  ),
                ),
                ListGradient(
                  height: 20,
                  top: true,
                  color: StateContainer.of(context).curTheme.backgroundDark!,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget buildUseNanoMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StateContainer.of(context).curTheme.barrierWeakest!,
            offset: const Offset(-5, 0),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        minimum: const EdgeInsets.only(
          top: 60,
        ),
        child: Column(
          children: <Widget>[
            // Back button and Security Text
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Back button
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.only(right: 10, left: 10),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: StateContainer.of(context).curTheme.text15,
                              backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              padding: const EdgeInsets.all(8),
                              // highlightColor: StateContainer.of(context).curTheme.text15,
                              // splashColor: StateContainer.of(context).curTheme.text15,
                            ),
                            onPressed: () {
                              setState(() {
                                _useNanoOpen = false;
                              });
                              _useNanoController.reverse();
                            },
                            child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                      ),
                      // Security Header Text
                      Text(
                        Z.of(context).useNano,
                        style: AppStyles.textStyleSettingsHeader(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: Stack(
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.only(top: 15),
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 30, bottom: 10),
                      child: Text(Z.of(context).getNano,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w100,
                              color: StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    AppSettings.buildSettingsListItemSingleLine(
                      context,
                      Z.of(context).onramper,
                      AppIcons.coins,
                      onPressed: () async {
                        final String url =
                            "https://widget.onramper.com?apiKey=${dotenv.env["ONRAMPER_API_KEY"]!}&color=4080D7&onlyCryptos=NANO&defaultCrypto=NANO&darkMode=${StateContainer.of(context).curTheme.brightness == Brightness.dark}";
                        await UIUtil.showChromeSafariWebview(context, url);
                      },
                      iconOverride: const SizedBox(
                        width: 24,
                        child: Image(
                          fit: BoxFit.fitWidth,
                          image: AssetImage("assets/logos/onramper.png"),
                        ),
                      ),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    AppSettings.buildSettingsListItemSingleLine(
                      context,
                      NonTranslatable.nanocafe,
                      AppIcons.coins,
                      onPressed: () async {
                        const String url = "https://nanocafe.cc/faucet";
                        await UIUtil.showChromeSafariWebview(context, url);
                      },
                      iconOverride: const SizedBox(
                        width: 24,
                        child: Image(
                          fit: BoxFit.fitWidth,
                          image: AssetImage("assets/logos/nanocafe.png"),
                        ),
                      ),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    AppSettings.buildSettingsListItemSingleLine(
                        context, Z.of(context).copyWalletAddressToClipboard, AppIcons.content_copy,
                        onPressed: () {
                      Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address));
                      UIUtil.showSnackbar(Z.of(context).addressCopied, context, durationMs: 1500);
                    }),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    // AppSimpleDialogOption(
                    //   onPressed: () {
                    //     Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address));
                    //     UIUtil.showSnackbar(Z.of(context).addressCopied, context, durationMs: 1500);
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 8),
                    //     child: Text(
                    //       Z.of(context).copyWalletAddressToClipboard,
                    //       style: AppStyles.textStyleDialogOptions(context),
                    //     ),
                    //   ),
                    // ),
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 30, top: 20, bottom: 10),
                      child: Text(Z.of(context).spendNano,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w100,
                              color: StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    AppSettings.buildSettingsListItemSingleLine(
                      context,
                      NonTranslatable.redeemforme,
                      AppIcons.coins,
                      onPressed: () async {
                        const String url = "https://redeemfor.me";
                        await UIUtil.showChromeSafariWebview(context, url);
                      },
                      iconOverride: const SizedBox(
                        width: 24,
                        child: Image(
                          fit: BoxFit.fitWidth,
                          image: AssetImage("assets/logos/redeemforme.png"),
                        ),
                      ),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),

                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 30, top: 20, bottom: 10),
                      child: Text(Z.of(context).exchangeNano,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w100,
                              color: StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    AppSettings.buildSettingsListItemSingleLine(
                      context,
                      NonTranslatable.nanswap,
                      AppIcons.coins,
                      onPressed: () async {
                        const String url = "https://nanswap.com/?ref=nautilus";
                        await UIUtil.showChromeSafariWebview(context, url);
                      },
                      iconOverride: const SizedBox(
                        width: 24,
                        child: Image(
                          fit: BoxFit.fitWidth,
                          image: AssetImage("assets/logos/nanswap.png"),
                        ),
                      ),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                  ],
                ),
                ListGradient(
                  height: 20,
                  top: true,
                  color: StateContainer.of(context).curTheme.backgroundDark!,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget buildShareMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StateContainer.of(context).curTheme.barrierWeakest!,
            offset: const Offset(-5, 0),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        minimum: const EdgeInsets.only(
          top: 60,
        ),
        child: Column(
          children: <Widget>[
            // Back button and Security Text
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Back button
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.only(right: 10, left: 10),
                        child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: StateContainer.of(context).curTheme.text15,
                              backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: const EdgeInsets.all(8),
                              // highlightColor: StateContainer.of(context).curTheme.text15,
                              // splashColor: StateContainer.of(context).curTheme.text15,
                            ),
                            onPressed: () {
                              setState(() {
                                _shareOpen = false;
                              });
                              _shareController.reverse();
                            },
                            child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                      ),
                      // Header Text
                      Text(
                        Z.of(context).share,
                        style: AppStyles.textStyleSettingsHeader(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: Stack(
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.only(top: 15.0),
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
                      child: Text(Z.of(context).social,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color: StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    AppSettings.buildSettingsListItemSingleLine(
                        context, Z.of(context).shareText, AppIcons.share, onPressed: () {
                      Share.share(
                          "${Z.of(context).shareNautilusText} ${NonTranslatable.genericStoreLink}");
                    }),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 30.0, top: 20, bottom: 10),
                      child: Text(Z.of(context).onboarding,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color: StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    AppSettings.buildSettingsListItemSingleLine(
                        context, Z.of(context).promotionalLink, AppIcons.qrcode, onPressed: () async {
                      final Widget qrWidget = SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: await UIUtil.getQRImage(context, NonTranslatable.promoLink));
                      Sheets.showAppHeightNineSheet(
                          context: context,
                          widget: OnboardSheet(
                            link: NonTranslatable.promoLink,
                            qrWidget: qrWidget,
                          ));
                    }),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                  ],
                ),
                ListGradient(
                  height: 20,
                  top: true,
                  color: StateContainer.of(context).curTheme.backgroundDark!,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    final String? expectedPin = await sl.get<Vault>().getPin();
    final String? plausiblePin = await sl.get<Vault>().getPlausiblePin();
    if (!mounted) return;
    final bool? auth = await Navigator.of(context).push(MaterialPageRoute<bool>(builder: (BuildContext context) {
      return PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        plausiblePin: plausiblePin,
        description: Z.of(context).pinSeedBackup,
      );
    }));
    if (auth != null && auth) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      Navigator.of(context).pop();
      StateContainer.of(context).getSeed().then((String seed) {
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: AppSeedBackupSheet(
              seed: seed,
            ));
      });
    }
  }
}
