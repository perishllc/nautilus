import 'dart:async';
import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as cont;
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/contacts_setting_change_event.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/bus/notification_setting_change_event.dart';
import 'package:nautilus_wallet_flutter/bus/payments_home_event.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/authentication_method.dart';
import 'package:nautilus_wallet_flutter/model/available_block_explorer.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/model/available_language.dart';
import 'package:nautilus_wallet_flutter/model/available_themes.dart';
import 'package:nautilus_wallet_flutter/model/contacts_setting.dart';
import 'package:nautilus_wallet_flutter/model/currency_mode_setting.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/model/device_lock_timeout.dart';
import 'package:nautilus_wallet_flutter/model/device_unlock_option.dart';
import 'package:nautilus_wallet_flutter/model/funding_setting.dart';
import 'package:nautilus_wallet_flutter/model/min_raw_setting.dart';
import 'package:nautilus_wallet_flutter/model/natricon_option.dart';
import 'package:nautilus_wallet_flutter/model/notification_setting.dart';
import 'package:nautilus_wallet_flutter/model/nyanicon_option.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/network/model/response/funding_response_item.dart';
import 'package:nautilus_wallet_flutter/sensitive.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/accounts/accounts_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/backupseed_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/blocked_widget.dart';
import 'package:nautilus_wallet_flutter/ui/settings/changerepresentative_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/contacts_widget.dart';
import 'package:nautilus_wallet_flutter/ui/settings/disable_password_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/set_password_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/set_plausible_pin_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/settings/settings_list_item.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_complete_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/transfer/transfer_overview_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/formatters.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/animations.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/draggable_scrollbar.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/funding_message_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/funding_messages_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_card.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/remote_message_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/security.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/util/biometrics.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/ninja/api.dart';
import 'package:nautilus_wallet_flutter/util/ninja/ninja_node.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:package_info/package_info.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsSheet extends StatefulWidget {
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _contactsController;
  AnimationController? _blockedController;
  late AnimationController _securityController;
  late Animation<Offset> _contactsOffsetFloat;
  late Animation<Offset> _blockedOffsetFloat;
  late Animation<Offset> _securityOffsetFloat;
  late ScrollController _scrollController;

  String versionString = "";

  final Logger log = sl.get<Logger>();
  bool _hasBiometrics = false;
  AuthenticationMethod _curAuthMethod = AuthenticationMethod(AuthMethod.BIOMETRICS);
  NotificationSetting _curNotificiationSetting = NotificationSetting(NotificationOptions.ON);
  ContactsSetting _curContactsSetting = ContactsSetting(ContactsOptions.OFF);
  ContactsSetting _curUnopenedWarningSetting = ContactsSetting(ContactsOptions.ON);
  NatriconSetting _curNatriconSetting = NatriconSetting(NatriconOptions.ON);
  NyaniconSetting _curNyaniconSetting = NyaniconSetting(NyaniconOptions.ON);
  FundingSetting _curFundingSetting = FundingSetting(FundingOptions.SHOW);
  MinRawSetting _curMinRawSetting = MinRawSetting(MinRawOptions.OFF);
  CurrencyModeSetting _curCurrencyModeSetting = CurrencyModeSetting(CurrencyModeOptions.NANO);
  UnlockSetting _curUnlockSetting = UnlockSetting(UnlockOption.NO);
  LockTimeoutSetting _curTimeoutSetting = LockTimeoutSetting(LockTimeoutOption.ONE);
  ThemeSetting _curThemeSetting = ThemeSetting(ThemeOptions.NAUTILUS);

  late bool _loadingAccounts;

  bool? _contactsOpen;
  bool? _blockedOpen;
  late bool _securityOpen;

  // Called if transfer fails
  void transferError() {
    Navigator.of(context).pop();
    UIUtil.showSnackbar(AppLocalization.of(context)!.transferError, context);
  }

  Future<bool> _getContactsPermissions() async {
    // reloading prefs:
    await sl.get<SharedPrefsUtil>().reload();
    final bool contactsOn = await sl.get<SharedPrefsUtil>().getContactsOn();

    // ask for contacts permission:
    if (!contactsOn) {
      final bool contactsEnabled = await cont.FlutterContacts.requestPermission();
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
        _curNotificiationSetting = notificationsOn ? NotificationSetting(NotificationOptions.ON) : NotificationSetting(NotificationOptions.OFF);
      });
    });
    // Get contacts show setting:
    sl.get<SharedPrefsUtil>().getContactsOn().then((bool contactsOn) {
      setState(() {
        _curContactsSetting = contactsOn ? ContactsSetting(ContactsOptions.ON) : ContactsSetting(ContactsOptions.OFF);
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

    _scrollController = ScrollController();

    _contactsOffsetFloat = Tween<Offset>(begin: const Offset(1.1, 0), end: const Offset(0, 0)).animate(_contactsController!);
    _securityOffsetFloat = Tween<Offset>(begin: const Offset(1.1, 0), end: const Offset(0, 0)).animate(_securityController);
    _blockedOffsetFloat = Tween<Offset>(begin: const Offset(1.1, 0), end: const Offset(0, 0)).animate(_blockedController!);
    // Version string
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        versionString = "v${packageInfo.version}";
      });
    });
  }

  StreamSubscription<TransferConfirmEvent>? _transferConfirmSub;
  StreamSubscription<TransferCompleteEvent>? _transferCompleteSub;
  StreamSubscription<NotificationSettingChangeEvent>? _notificationSettingChangeSub;
  StreamSubscription<ContactsSettingChangeEvent>? _contactsSettingChangeSub;

  void _registerBus() {
    // Ready to go to transfer confirm
    _transferConfirmSub = EventTaxiImpl.singleton().registerTo<TransferConfirmEvent>().listen((TransferConfirmEvent event) {
      Sheets.showAppHeightNineSheet(
          context: context,
          widget: AppTransferConfirmSheet(
            privKeyBalanceMap: event.balMap,
            errorCallback: transferError,
          ));
    });
    // Ready to go to transfer complete
    _transferCompleteSub = EventTaxiImpl.singleton().registerTo<TransferCompleteEvent>().listen((TransferCompleteEvent event) {
      StateContainer.of(context).requestUpdate();
      AppTransferCompleteSheet(getRawAsThemeAwareAmount(context, event.amount.toString())).mainBottomSheet(context);
    });
    // notification setting changed:
    _notificationSettingChangeSub = EventTaxiImpl.singleton().registerTo<NotificationSettingChangeEvent>().listen((NotificationSettingChangeEvent event) {
      setState(() {
        _curNotificiationSetting = event.isOn ? NotificationSetting(NotificationOptions.ON) : NotificationSetting(NotificationOptions.OFF);
      });
    });
    // contacts setting changed:
    _contactsSettingChangeSub = EventTaxiImpl.singleton().registerTo<ContactsSettingChangeEvent>().listen((ContactsSettingChangeEvent event) {
      setState(() {
        _curContactsSetting = event.isOn ? ContactsSetting(ContactsOptions.ON) : ContactsSetting(ContactsOptions.OFF);
      });
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
            title: Text(
              AppLocalization.of(context)!.authMethod,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.BIOMETRICS);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.biometricsMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.PIN);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.pinMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case AuthMethod.PIN:
        sl.get<SharedPrefsUtil>().setAuthMethod(AuthenticationMethod(AuthMethod.PIN)).then((result) {
          setState(() {
            _curAuthMethod = AuthenticationMethod(AuthMethod.PIN);
          });
        });
        break;
      case AuthMethod.BIOMETRICS:
        sl.get<SharedPrefsUtil>().setAuthMethod(AuthenticationMethod(AuthMethod.BIOMETRICS)).then((result) {
          setState(() {
            _curAuthMethod = AuthenticationMethod(AuthMethod.BIOMETRICS);
          });
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
            title: Text(
              AppLocalization.of(context)!.notifications,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NotificationOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case NotificationOptions.ON:
        sl.get<SharedPrefsUtil>().setNotificationsOn(true).then((result) {
          EventTaxiImpl.singleton().fire(NotificationSettingChangeEvent(isOn: true));
          FirebaseMessaging.instance.requestPermission();
          FirebaseMessaging.instance.getToken().then((String? fcmToken) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
          });
        });
        break;
      case NotificationOptions.OFF:
        sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((result) {
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
            title: Text(
              AppLocalization.of(context)!.contactsHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.off,
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
            title:             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.unopenedWarningHeader,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                AppDialogs.infoButton(
                  context,
                  () {
                    AppDialogs.showInfoDialog(context, AppLocalization.of(context)!.unopenedWarningHeader, AppLocalization.of(context)!.unopenedWarningInfo);
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ContactsOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.off,
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
      await sl.get<SharedPrefsUtil>().setUnopenedWarningOn(true);
    } else {
      await sl.get<SharedPrefsUtil>().setUnopenedWarningOn(false);
    }
    setState(() {
      _curUnopenedWarningSetting = ContactsSetting(picked);
    });
  }

  Future<void> _fundingDialog() async {
    final FundingOptions? picked = await showDialog<FundingOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context)!.fundingBannerHeader,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, FundingOptions.HIDE);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.hide,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, FundingOptions.SHOW);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.show,
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

    if (picked == FundingOptions.SHOW) {
      await sl.get<SharedPrefsUtil>().setFundingOn(true);
    } else {
      await sl.get<SharedPrefsUtil>().setFundingOn(false);
    }
    setState(() {
      _curFundingSetting = FundingSetting(picked);
    });
  }

  Future<void> _nyaniconDialog() async {
    switch (await showDialog<NyaniconOptions>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context)!.nyanicon,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NyaniconOptions.ON);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.onStr,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, NyaniconOptions.OFF);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.off,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case NyaniconOptions.ON:
        sl.get<SharedPrefsUtil>().setUseNyanicon(true).then((result) {
          setState(() {
            StateContainer.of(context).setNyaniconOn(true);
            _curNyaniconSetting = NyaniconSetting(NyaniconOptions.ON);
          });
        });
        break;
      case NyaniconOptions.OFF:
        sl.get<SharedPrefsUtil>().setUseNyanicon(false).then((result) {
          setState(() {
            StateContainer.of(context).setNyaniconOn(false);
            _curNyaniconSetting = NyaniconSetting(NyaniconOptions.OFF);
          });
        });
        break;
      default:
        break;
    }
  }

  Future<String?> _onrampDialog() async {
    final String onramper_url =
        "https://widget.onramper.com?apiKey=${Sensitive.ONRAMPER_API_KEY}&color=4080D7&onlyCryptos=NANO&defaultCrypto=NANO&&darkMode=true";
    final String moonpay_url = "https://buy.moonpay.com/?currencyCode=xno&colorCode=%234080D7";
    final String simplex_url = "https://buy.chainbits.com";

    final String? choice = await showDialog<String>(
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context)!.onramp,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, simplex_url);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.simplex,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, onramper_url);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.onramper,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: StateContainer.of(context).wallet!.address));
                  UIUtil.showSnackbar(AppLocalization.of(context)!.addressCopied, context, durationMs: 1500);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.copyWalletAddressToClipboard,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        });

    return choice;
  }

  List<Widget> _buildMinRawOptions() {
    final List<Widget> ret = [];
    for (final MinRawOptions value in MinRawOptions.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    final List<Widget> ret = [];
    for (final CurrencyModeOptions value in CurrencyModeOptions.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.receiveMinimum,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                AppDialogs.infoButton(
                  context,
                  () {
                    AppDialogs.showInfoDialog(context, AppLocalization.of(context)!.receiveMinimumHeader, AppLocalization.of(context)!.receiveMinimumInfo);
                  },
                )
              ],
            ),
            children: _buildMinRawOptions(),
          );
        });

    final String raw_value = MinRawSetting(chosen).getRaw();
    sl.get<SharedPrefsUtil>().setMinRawReceive(raw_value).then((result) {
      setState(() {
        StateContainer.of(context).setMinRawReceive(raw_value);
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.currencyMode,
                  style: AppStyles.textStyleDialogHeader(context),
                ),
                AppDialogs.infoButton(
                  context,
                  () {
                    AppDialogs.showInfoDialog(context, AppLocalization.of(context)!.currencyModeHeader, AppLocalization.of(context)!.currencyModeInfo);
                  },
                )
              ],
            ),
            children: _buildCurrencyModeOptions(),
          );
        });

    final String currency_mode = CurrencyModeSetting(chosen).getDisplayName();
    sl.get<SharedPrefsUtil>().setCurrencyMode(currency_mode).then((result) {
      setState(() {
        StateContainer.of(context).setCurrencyMode(currency_mode);
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
              AppLocalization.of(context)!.lockAppSetting,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, UnlockOption.NO);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.no,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, UnlockOption.YES);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context)!.yes,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case UnlockOption.YES:
        sl.get<SharedPrefsUtil>().setLock(true).then((result) {
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.YES);
          });
        });
        break;
      case UnlockOption.NO:
        sl.get<SharedPrefsUtil>().setLock(false).then((result) {
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
    final List<Widget> ret = [];
    for (final AvailableCurrencyEnum value in AvailableCurrencyEnum.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context)!.currency,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildCurrencyOptions(),
          );
        });
    if (selection != null) {
      sl.get<SharedPrefsUtil>().setCurrency(AvailableCurrency(selection)).then((result) {
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
    final List<Widget> ret = [];
    for (final AvailableLanguage value in AvailableLanguage.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context)!.language,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildLanguageOptions(),
          );
        });
    if (selection != null) {
      sl.get<SharedPrefsUtil>().setLanguage(LanguageSetting(selection)).then((result) {
        if (StateContainer.of(context).curLanguage.language != selection) {
          setState(() {
            StateContainer.of(context).updateLanguage(LanguageSetting(selection));
          });
        }
      });
    }
  }

  List<Widget> _buildExplorerOptions() {
    final List<Widget> ret = [];
    for (final AvailableBlockExplorerEnum value in AvailableBlockExplorerEnum.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Text(
                AppLocalization.of(context)!.blockExplorer,
                style: AppStyles.textStyleDialogHeader(context),
              ),
              AppDialogs.infoButton(context, () {
                AppDialogs.showInfoDialog(context, AppLocalization.of(context)!.blockExplorerHeader, AppLocalization.of(context)!.blockExplorerInfo);
              }),
            ]),
            children: _buildExplorerOptions(),
          );
        });
    if (selection != null) {
      sl.get<SharedPrefsUtil>().setBlockExplorer(AvailableBlockExplorer(selection)).then((result) {
        if (StateContainer.of(context).curBlockExplorer.explorer != selection) {
          setState(() {
            StateContainer.of(context).updateBlockExplorer(AvailableBlockExplorer(selection));
          });
        }
      });
    }
  }

  List<Widget> _buildLockTimeoutOptions() {
    final List<Widget> ret = [];
    for (final LockTimeoutOption value in LockTimeoutOption.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context)!.autoLockHeader,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildLockTimeoutOptions(),
          );
        });
    sl.get<SharedPrefsUtil>().setLockTimeout(LockTimeoutSetting(selection)).then((result) {
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
    final List<Widget> ret = [];
    for (final ThemeOptions value in ThemeOptions.values) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context)!.themeHeader,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildThemeOptions(),
          );
        });
    if (selection != null) {
      if (_curThemeSetting != ThemeSetting(selection)) {
        sl.get<SharedPrefsUtil>().setTheme(ThemeSetting(selection)).then((result) {
          setState(() {
            StateContainer.of(context).updateTheme(ThemeSetting(selection));
            _curThemeSetting = ThemeSetting(selection);
          });
        });
      }
    }
  }

  Future<bool> _onBackButtonPressed() async {
    if (_contactsOpen!) {
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
    } else if (_blockedOpen!) {
      setState(() {
        _blockedOpen = false;
      });
      _blockedController!.reverse();
      return false;
    }
    return true;
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
            SlideTransition(position: _contactsOffsetFloat, child: ContactsList(_contactsController, _contactsOpen)),
            SlideTransition(position: _blockedOffsetFloat, child: BlockedList(_blockedController, _blockedOpen)),
            SlideTransition(position: _securityOffsetFloat, child: buildSecurityMenu(context)),
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

    return ListView(
      padding: const EdgeInsets.only(top: 15.0),
      controller: _scrollController,
      children: [
        // Active Alerts, Remote Message Card
        if (StateContainer.of(context).settingsAlert != null)
          Container(
            padding: const EdgeInsetsDirectional.only(
              start: 12,
              end: 12,
              bottom: 20,
            ),
            child: RemoteMessageCard(
              alert: StateContainer.of(context).settingsAlert,
              onPressed: () {
                Sheets.showAppHeightEightSheet(
                  context: context,
                  widget: RemoteMessageSheet(
                    alert: StateContainer.of(context).settingsAlert,
                    hasDismissButton: false,
                  ),
                );
              },
            ),
          ),
        if (!Platform.isIOS &&
            StateContainer.of(context).fundingAlerts != null &&
            StateContainer.of(context).fundingAlerts!.isNotEmpty &&
            _curFundingSetting.setting == FundingOptions.SHOW)
          Container(
            padding: const EdgeInsetsDirectional.only(
              start: 12,
              end: 12,
              bottom: 20,
            ),
            child: FundingMessageCard(
              title: AppLocalization.of(context)!.donateToSupport,
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
        if (Platform.isIOS && StateContainer.of(context).fundingAlerts != null && _curFundingSetting.setting == FundingOptions.SHOW)
          Container(
            padding: const EdgeInsetsDirectional.only(
              start: 12,
              end: 12,
              bottom: 20,
            ),
            child: FundingMessageCard(
              title: AppLocalization.of(context)!.donateToSupport,
              shortDescription: AppLocalization.of(context)!.supportDevelopment,
              hideAmounts: true,
              hideProgressBar: true,
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
          child: Text(AppLocalization.of(context)!.featured,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w100, color: StateContainer.of(context).curTheme.text60)),
        ),
        // Divider(
        //   height: 2,
        //   color: StateContainer.of(context).curTheme.text15,
        // ),
        // AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context).home, AppIcons.home, onPressed: () {
        //   Navigator.of(context).pushNamed("/home_transition");
        // }),
        // Divider(
        //   height: 2,
        //   color: StateContainer.of(context).curTheme.text15,
        // ),
        // AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context).payments, AppIcons.money_bill_alt, onPressed: () {
        //   Navigator.of(context).pushNamed("/payments_page");
        // }),
        // TODO: Add back later:
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.purchaseNano, AppIcons.coins, onPressed: () async {
          // Navigator.of(context).pushNamed("/purchase_nano");
          final String? choice = await _onrampDialog();
          if (choice != null) {
            await UIUtil.showWebview(context, choice);
          }
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.registerUsername, AppIcons.at, onPressed: () {
          Navigator.of(context).pushNamed("/register_username");
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.createGiftCard, AppIcons.export_icon, onPressed: () {
          Navigator.of(context).pushNamed("/gift_paper_wallet");
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 30.0, top: 20, bottom: 10),
          child: Text(AppLocalization.of(context)!.preferences,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w100, color: StateContainer.of(context).curTheme.text60)),
        ),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
            context, AppLocalization.of(context)!.changeCurrency, StateContainer.of(context).curCurrency, AppIcons.currency, _currencyDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
            context, AppLocalization.of(context)!.language, StateContainer.of(context).curLanguage, AppIcons.language, _languageDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
            context, AppLocalization.of(context)!.notifications, _curNotificiationSetting, AppIcons.notifications, _notificationsDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
            context, AppLocalization.of(context)!.showContacts, _curContactsSetting, AppIcons.addcontact, _contactsDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
            context, AppLocalization.of(context)!.showUnopenedWarning, _curUnopenedWarningSetting, AppIcons.warning, _unopenedWarningDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(context, AppLocalization.of(context)!.themeHeader, _curThemeSetting, AppIcons.theme, _themeDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.securityHeader, AppIcons.security, onPressed: () {
          setState(() {
            _securityOpen = true;
          });
          _securityController.forward();
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
            context, AppLocalization.of(context)!.receiveMinimum, _curMinRawSetting, AppIcons.less_than_equal, _minRawDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
            context, AppLocalization.of(context)!.currencyMode, _curCurrencyModeSetting, AppIcons.currency, _currencyModeDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
          context,
          AppLocalization.of(context)!.blockExplorer,
          StateContainer.of(context).curBlockExplorer,
          AppIcons.search,
          _explorerDialog,
        ),
        AppSettings.buildSettingsListItemDoubleLine(
            context, AppLocalization.of(context)!.showFunding, _curFundingSetting, AppIcons.money_bill_wave, _fundingDialog),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 30.0, top: 20.0, bottom: 10.0),
          child: Text(AppLocalization.of(context)!.manage,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w100, color: StateContainer.of(context).curTheme.text60)),
        ),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.contactsHeader, AppIcons.contact, onPressed: () async {
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
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.blockedHeader, AppIcons.block, onPressed: () {
          setState(() {
            _blockedOpen = true;
          });
          _blockedController!.forward();
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.backupSecretPhrase, AppIcons.backupseed, onPressed: () async {
          // Authenticate
          final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
          final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
          if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
            try {
              final bool authenticated = await sl.get<BiometricUtil>().authenticateWithBiometrics(context, AppLocalization.of(context)!.fingerprintSeedBackup);
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
              AppDialogs.showConfirmDialog(
                  context,
                  "Error",
                  error.toString(),
                  "Copy to clipboard",
                  () {
                    Clipboard.setData(ClipboardData(text: error.toString()));
                  },
                  cancelText: "Close",
                  cancelAction: () {
                    Navigator.of(context).pop();
                  });
              await authenticateWithPin();
            }
          } else {
            await authenticateWithPin();
          }
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.settingsTransfer, AppIcons.transferfunds, onPressed: () {
          AppTransferOverviewSheet().mainBottomSheet(context);
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.changeRepAuthenticate, AppIcons.changerepresentative, onPressed: () {
          AppChangeRepresentativeSheet().mainBottomSheet(context);
          if (!StateContainer.of(context).nanoNinjaUpdated) {
            NinjaAPI.getVerifiedNodes().then((List<NinjaNode>? result) {
              if (result != null) {
                StateContainer.of(context).updateNinjaNodes(result);
              }
            });
          }
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.shareNautilus, AppIcons.share, onPressed: () {
          Share.share("Check out Nautilus - NANO Wallet for iOS and Android https://nautiluswallet.app");
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.resetDatabase, AppIcons.trashcan, onPressed: () async {
          AppDialogs.showConfirmDialog(context, AppLocalization.of(context)!.resetDatabase, AppLocalization.of(context)!.resetDatabaseConfirmation,
              CaseChange.toUpperCase(AppLocalization.of(context)!.yes, context), () async {
            // push animation to prevent early exit:
            bool animationOpen = true;
            AppAnimation.animationLauncher(context, AnimationType.GENERIC, onPoppedCallback: () => animationOpen = false);

            // sleep to flex the animation a bit:
            await Future.delayed(const Duration(milliseconds: 500));

            // Delete the database
            try {
              await sl.get<DBHelper>().nukeDatabase();
            } catch (error) {
              log.d("Error resetting database: $error");
            }

            // re-populate the users table
            try {
              await sl.get<DBHelper>().fetchNanoToUsernames();
            } catch (error) {
              log.d("Error fetching usernames: $error");
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
            final String seed = await StateContainer.of(context).getSeed();
            await NanoUtil().loginAccount(seed, context);
            await StateContainer.of(context).resetRecentlyUsedAccounts();
            final Account? mainAccount = await sl.get<DBHelper>().getSelectedAccount(seed);
            StateContainer.of(context).updateWallet(account: mainAccount!);
            // force users list to update on the home page:
            EventTaxiImpl.singleton().fire(ContactModifiedEvent());
            EventTaxiImpl.singleton().fire(PaymentsHomeEvent(items: []));
            StateContainer.of(context).updateUnified(true);
            EventTaxiImpl.singleton().fire(AccountChangedEvent(account: mainAccount, delayPop: true));

            // EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: mainAccount));
            // if (animationOpen && mounted) {
            //   Navigator.of(context).pop();
            // }
          }, cancelText: CaseChange.toUpperCase(AppLocalization.of(context)!.no, context));
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.logout, AppIcons.logout, onPressed: () {
          AppDialogs.showConfirmDialog(context, CaseChange.toUpperCase(AppLocalization.of(context)!.warning, context),
              AppLocalization.of(context)!.logoutDetail, AppLocalization.of(context)!.logoutAction.toUpperCase(), () {
            // Show another confirm dialog
            AppDialogs.showConfirmDialog(context, AppLocalization.of(context)!.logoutAreYouSure, AppLocalization.of(context)!.logoutReassurance,
                CaseChange.toUpperCase(AppLocalization.of(context)!.yes, context), () {
              // Unsubscribe from notifications
              sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((_) async {
                try {
                  final String? fcmToken = await FirebaseMessaging.instance.getToken();
                  EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
                  EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
                } catch (e) {}
                try {
                  // Delete all data
                  sl.get<Vault>().deleteAll().then((_) {
                    sl.get<SharedPrefsUtil>().deleteAll().then((result) {
                      StateContainer.of(context).logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                    });
                  });
                } catch (e) {}
              });
            });
          });
        }),
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Column(
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Text(versionString, style: AppStyles.textStyleVersion(context)),
                //     Text(" | ", style: AppStyles.textStyleVersion(context)),
                //     GestureDetector(
                //         onTap: () {
                //           Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                //             return UIUtil.showWebview(context, AppLocalization.of(context).privacyUrl);
                //           }));
                //         },
                //         child: Text(AppLocalization.of(context).privacyPolicy, style: AppStyles.textStyleVersionUnderline(context))),
                //     Text(" | ", style: AppStyles.textStyleVersion(context)),
                //     GestureDetector(
                //         onTap: () {
                //           Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                //             return UIUtil.showWebview(context, AppLocalization.of(context).eulaUrl);
                //           }));
                //         },
                //         child: Text(AppLocalization.of(context).eula, style: AppStyles.textStyleVersionUnderline(context))),
                //   ],
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     GestureDetector(
                //         onTap: () async {
                //           Uri uri = Uri.parse(AppLocalization.of(context).discordUrl);
                //           if (await canLaunchUrl(uri)) {
                //             await launchUrl(uri);
                //           }
                //         },
                //         child: Text(AppLocalization.of(context).discord, style: AppStyles.textStyleVersionUnderline(context))),
                //     Text(" | ", style: AppStyles.textStyleVersion(context)),
                //     GestureDetector(
                //         onTap: () async {
                //           await AppDialogs.showChangeLog(context);
                //         },
                //         child: Text(AppLocalization.of(context).changeLog, style: AppStyles.textStyleVersionUnderline(context))),
                //   ],
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(versionString, style: AppStyles.textStyleVersion(context)),
                    Text(" | ", style: AppStyles.textStyleVersion(context)),
                    GestureDetector(
                        onTap: () async {
                          await AppDialogs.showChangeLog(context);
                        },
                        child: Text(AppLocalization.of(context)!.changeLog, style: AppStyles.textStyleVersionUnderline(context))),
                    Text(" | ", style: AppStyles.textStyleVersion(context)),
                    GestureDetector(
                        onTap: () async {
                          final Uri uri = Uri.parse(AppLocalization.of(context)!.discordUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: Text(AppLocalization.of(context)!.discord, style: AppStyles.textStyleVersionUnderline(context))),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () async {
                          await UIUtil.showWebview(context, AppLocalization.of(context)!.privacyUrl);
                        },
                        child: Text(AppLocalization.of(context)!.privacyPolicy, style: AppStyles.textStyleVersionUnderline(context))),
                    Text(" | ", style: AppStyles.textStyleVersion(context)),
                    GestureDetector(
                        onTap: () async {
                          await UIUtil.showWebview(context, AppLocalization.of(context)!.eulaUrl);
                        },
                        child: Text(AppLocalization.of(context)!.eula, style: AppStyles.textStyleVersionUnderline(context))),
                    Text(" | ", style: AppStyles.textStyleVersion(context)),
                    GestureDetector(
                        onTap: () async {
                          await UIUtil.showWebview(context, AppLocalization.of(context)!.nautilusNodeUrl);
                        },
                        child: Text(AppLocalization.of(context)!.nodeStatus, style: AppStyles.textStyleVersionUnderline(context))),
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
                                    StateContainer.of(context).wallet!.watchOnly ? AppIcons.search : AppIcons.accountwallet,
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
                                    primary: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                    padding: EdgeInsets.zero,
                                    // highlightColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                    // splashColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                  ),
                                  child: const SizedBox(
                                    width: 60,
                                    height: 45,
                                  ),
                                  onPressed: () {
                                    AccountDetailsSheet(StateContainer.of(context).selectedAccount!).mainBottomSheet(context);
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
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: Icon(
                                      StateContainer.of(context).recentLast!.watchOnly ? AppIcons.search : AppIcons.accountwallet,
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
                                          primary: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                          padding: EdgeInsets.zero,
                                          // highlightColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                          // splashColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                        ),
                                        onPressed: () {
                                          sl.get<DBHelper>().changeAccount(StateContainer.of(context).recentLast).then((_) {
                                            EventTaxiImpl.singleton().fire(AccountChangedEvent(account: StateContainer.of(context).recentLast, delayPop: true));
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
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: Icon(
                                      StateContainer.of(context).recentSecondLast!.watchOnly ? AppIcons.search : AppIcons.accountwallet,
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
                                        child: Text(StateContainer.of(context).recentSecondLast!.getShortName().toUpperCase(),
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
                                        child: Text(StateContainer.of(context).recentSecondLast!.getShortName().toUpperCase(),
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
                                          padding: EdgeInsets.zero,
                                          primary: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                          // highlightColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                          // splashColor: StateContainer.of(context).curTheme.backgroundDark!.withOpacity(0.75),
                                        ),
                                        onPressed: () {
                                          sl.get<DBHelper>().changeAccount(StateContainer.of(context).recentSecondLast).then((_) {
                                            EventTaxiImpl.singleton()
                                                .fire(AccountChangedEvent(account: StateContainer.of(context).recentSecondLast, delayPop: true));
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
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                                primary: _loadingAccounts ? Colors.transparent : StateContainer.of(context).curTheme.text30,
                                // splashColor: _loadingAccounts ? Colors.transparent : StateContainer.of(context).curTheme.text30,
                                // highlightColor: _loadingAccounts ? Colors.transparent : StateContainer.of(context).curTheme.text15,
                              ),
                              onPressed: () async {
                                if (!_loadingAccounts) {
                                  setState(() {
                                    _loadingAccounts = true;
                                  });
                                  String seed = await StateContainer.of(context).getSeed();
                                  List<Account> accounts = await sl.get<DBHelper>().getAccounts(seed);
                                  setState(() {
                                    _loadingAccounts = false;
                                  });
                                  Sheets.showAppHeightNineSheet(context: context, widget: AppAccountsSheet(accounts: accounts));
                                }
                              },
                              child: Icon(AppIcons.accountswitcher,
                                  size: 36,
                                  color: _loadingAccounts ? StateContainer.of(context).curTheme.primary60 : StateContainer.of(context).curTheme.primary),
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
                        padding: const EdgeInsets.all(4.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                        primary: StateContainer.of(context).curTheme.text30,
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
                            StateContainer.of(context).wallet?.username ?? Address(StateContainer.of(context).wallet!.address).getShortFirstPart() ?? "",
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
                    scrollbarColor: StateContainer.of(context).curTheme.primary!,
                    child: _buildSettingsList(),
                  ),
                  // List Top Gradient End
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 20.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [StateContainer.of(context).curTheme.backgroundDark!, StateContainer.of(context).curTheme.backgroundDark00!],
                          begin: const AlignmentDirectional(0.5, -1.0),
                          end: const AlignmentDirectional(0.5, 1.0),
                        ),
                      ),
                    ),
                  ), // List Top Gradient End
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSecurityMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: [
          BoxShadow(color: StateContainer.of(context).curTheme.barrierWeakest!, offset: const Offset(-5, 0), blurRadius: 20),
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
              margin: const EdgeInsets.only(bottom: 10.0, top: 5),
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
                              primary: StateContainer.of(context).curTheme.text15,
                              backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: const EdgeInsets.all(8.0),
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
                        AppLocalization.of(context)!.securityHeader,
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
                  children: [
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
                      child: Text(AppLocalization.of(context)!.preferences,
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w100, color: StateContainer.of(context).curTheme.text60)),
                    ),
                    // Authentication Method
                    if (_hasBiometrics)
                      Divider(
                        height: 2,
                        color: StateContainer.of(context).curTheme.text15,
                      ),
                    if (_hasBiometrics)
                      AppSettings.buildSettingsListItemDoubleLine(
                          context, AppLocalization.of(context)!.authMethod, _curAuthMethod, AppIcons.fingerprint, _authMethodDialog),
                    // Authenticate on Launch
                    if (StateContainer.of(context).encryptedSecret == null)
                      Column(children: <Widget>[
                        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                        AppSettings.buildSettingsListItemDoubleLine(
                            context, AppLocalization.of(context)!.lockAppSetting, _curUnlockSetting, AppIcons.lock, _lockDialog),
                      ]),
                    // Authentication Timer
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                      context,
                      AppLocalization.of(context)!.autoLockHeader,
                      _curTimeoutSetting,
                      AppIcons.timer,
                      _lockTimeoutDialog,
                      disabled: _curUnlockSetting.setting == UnlockOption.NO && StateContainer.of(context).encryptedSecret == null,
                    ),
                    // Encrypt option
                    if (StateContainer.of(context).encryptedSecret == null)
                      Column(children: <Widget>[
                        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                        AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.setWalletPassword, AppIcons.walletpassword,
                            onPressed: () {
                          Sheets.showAppHeightNineSheet(context: context, widget: SetPasswordSheet());
                        })
                      ])
                    else
                      Column(children: <Widget>[
                        Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                        AppSettings.buildSettingsListItemSingleLine(
                            context, AppLocalization.of(context)!.disableWalletPassword, AppIcons.walletpassworddisabled, onPressed: () {
                          Sheets.showAppHeightNineSheet(context: context, widget: DisablePasswordSheet());
                        }),
                      ]),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                    Column(children: <Widget>[
                      Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                      AppSettings.buildSettingsListItemSingleLine(context, AppLocalization.of(context)!.setPlausibleDeniabilityPin, AppIcons.walletpassword,
                          onPressed: () {
                        Sheets.showAppHeightNineSheet(context: context, widget: SetPlausiblePinSheet());
                      }, disabled: _curAuthMethod.method != AuthMethod.PIN || StateContainer.of(context).encryptedSecret != null),
                    ]),
                    Divider(height: 2, color: StateContainer.of(context).curTheme.text15),
                  ],
                ),
                // List Top Gradient End
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 20.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [StateContainer.of(context).curTheme.backgroundDark!, StateContainer.of(context).curTheme.backgroundDark00!],
                        begin: const AlignmentDirectional(0.5, -1.0),
                        end: const AlignmentDirectional(0.5, 1.0),
                      ),
                    ),
                  ),
                ), //List Top Gradient End
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
    final bool? auth = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        plausiblePin: plausiblePin,
        description: AppLocalization.of(context)!.pinSeedBackup,
      );
    }));
    if (auth != null && auth) {
      await Future.delayed(const Duration(milliseconds: 200));
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
