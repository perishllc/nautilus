import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/firebase_options.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/available_currency.dart';
import 'package:nautilus_wallet_flutter/model/available_language.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/avatar/avatar.dart';
import 'package:nautilus_wallet_flutter/ui/avatar/avatar_change.dart';
import 'package:nautilus_wallet_flutter/ui/before_scan_screen.dart';
import 'package:nautilus_wallet_flutter/ui/generate/generate_paper_wallet.dart';
import 'package:nautilus_wallet_flutter/ui/home_page.dart';
import 'package:nautilus_wallet_flutter/ui/intro/intro_backup_confirm.dart';
import 'package:nautilus_wallet_flutter/ui/intro/intro_backup_safety.dart';
import 'package:nautilus_wallet_flutter/ui/intro/intro_backup_seed.dart';
import 'package:nautilus_wallet_flutter/ui/intro/intro_import_seed.dart';
import 'package:nautilus_wallet_flutter/ui/intro/intro_password.dart';
import 'package:nautilus_wallet_flutter/ui/intro/intro_password_on_launch.dart';
import 'package:nautilus_wallet_flutter/ui/intro/intro_welcome.dart';
import 'package:nautilus_wallet_flutter/ui/lock_screen.dart';
import 'package:nautilus_wallet_flutter/ui/password_lock_screen.dart';
import 'package:nautilus_wallet_flutter/ui/purchase_nano.dart';
import 'package:nautilus_wallet_flutter/ui/register/register_username.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';
import 'package:oktoast/oktoast.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup Service Provide
  setupServiceLocator();
  // Setup logger, only show warning and higher in release mode.
  if (kReleaseMode) {
    Logger.level = Level.warning;
  } else {
    // Logger.level = Level.debug;
    Logger.level = Level.verbose;
  }
  // Setup firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kReleaseMode) {
    // we have to stall for whatever reason in debug mode
    // otherwise the app doesn't start properly (black screen)
    await Future.delayed(const Duration(seconds: 2));
  }
  // Run app
  if (kReleaseMode) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  runApp(StateContainer(child: App()));
}

class App extends StatefulWidget {

  App() : super();

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(StateContainer.of(context).curTheme.statusBar!);
    // final ThemeData theme = ThemeData();
    return OKToast(
      textStyle: AppStyles.textStyleSnackbar(context),
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      child: MaterialApp(
        debugShowCheckedModeBanner: kDebugMode,
        title: 'Nautilus',
        // theme: ThemeData(
        //   dialogBackgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        //   primaryColor: StateContainer.of(context).curTheme.primary,
        //   accentColor: StateContainer.of(context).curTheme.primary10,
        //   backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        //   fontFamily: 'NunitoSans',
        //   brightness: Brightness.dark,
        // ),
        theme: ThemeData(
          dialogBackgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          primaryColor: StateContainer.of(context).curTheme.primary,
          backgroundColor: StateContainer.of(context).curTheme.background,
          fontFamily: 'NunitoSans',
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: StateContainer.of(context).curTheme.primary10,
              brightness: Brightness.dark,
              error: StateContainer.of(context).curTheme.error,
              primary: StateContainer.of(context).curTheme.primary),
        ),
        localizationsDelegates: [
          AppLocalizationsDelegate(StateContainer.of(context).curLanguage),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        locale: StateContainer.of(context).curLanguage.language == AvailableLanguage.DEFAULT ? null : StateContainer.of(context).curLanguage.getLocale(),
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('he', 'IL'), // Hebrew
          Locale('de', 'DE'), // German
          Locale('da'), // Danish
          Locale('bg'), // Bulgarian
          Locale('es'), // Spanish
          Locale('hi'), // Hindi
          Locale('hu'), // Hungarian
          Locale('hi'), // Hindi
          Locale('id'), // Indonesian
          Locale('it'), // Italian
          Locale('ja'), // Japanese
          Locale('ko'), // Korean
          Locale('ms'), // Malay
          Locale('nl'), // Dutch
          Locale('pl'), // Polish
          Locale('pt'), // Portugese
          Locale('ro'), // Romanian
          Locale('ru'), // Russian
          Locale('sl'), // Slovenian
          Locale('sv'), // Swedish
          Locale('tl'), // Tagalog
          Locale('tr'), // Turkish
          Locale('vi'), // Vietnamese
          Locale('ca'), // Catalan
          Locale('uk'), // Ukrainian
          Locale('no'), // Norwegian
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), // Chinese Simplified
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), // Chinese Traditional
          Locale('ar'), // Arabic
          Locale('lv'), // Latvian
          Locale('bn'), // Bengali
          // Currency-default requires country included
          Locale("es", "AR"),
          Locale("en", "AU"),
          Locale("pt", "BR"),
          Locale("en", "CA"),
          Locale("de", "CH"),
          Locale("es", "CL"),
          Locale("zh", "CN"),
          Locale("cs", "CZ"),
          Locale("da", "DK"),
          Locale("fr", "FR"),
          Locale("en", "GB"),
          Locale("zh", "HK"),
          Locale("hu", "HU"),
          Locale("id", "ID"),
          Locale("he", "IL"),
          Locale("hi", "IN"),
          Locale("ja", "JP"),
          Locale("ko", "KR"),
          Locale("es", "MX"),
          Locale("ta", "MY"),
          Locale("en", "NZ"),
          Locale("tl", "PH"),
          Locale("ur", "PK"),
          Locale("pl", "PL"),
          Locale("ru", "RU"),
          Locale("sv", "SE"),
          Locale("zh", "SG"),
          Locale("th", "TH"),
          Locale("tr", "TR"),
          Locale("en", "TW"),
          Locale("es", "VE"),
          Locale("en", "ZA"),
          Locale("en", "US"),
          Locale("es", "AR"),
          Locale("de", "AT"),
          Locale("fr", "BE"),
          Locale("de", "BE"),
          Locale("nl", "BE"),
          Locale("tr", "CY"),
          Locale("et", "EE"),
          Locale("fi", "FI"),
          Locale("fr", "FR"),
          Locale("el", "GR"),
          Locale("es", "AR"),
          Locale("en", "IE"),
          Locale("it", "IT"),
          Locale("es", "AR"),
          Locale("lv", "LV"),
          Locale("lt", "LT"),
          Locale("fr", "LU"),
          Locale("en", "MT"),
          Locale("nl", "NL"),
          Locale("pt", "PT"),
          Locale("sk", "SK"),
          Locale("sl", "SI"),
          Locale("es", "ES"),
          Locale("ar", "AE"), // UAE
          Locale("ar", "SA"), // Saudi Arabia
          Locale("ar", "KW"), // Kuwait
          Locale("uk", "UA"), // Ukraine
          Locale("no", "NO"), // Norway
          Locale("bn", "BD"), // Bangladesh
          Locale("bn", "IN"), // India/Bengali
        ],
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return NoTransitionRoute(
                builder: (_) => Splash(),
                settings: settings,
              );
            case '/home':
              return NoTransitionRoute(
                builder: (_) => AppHomePage(priceConversion: settings.arguments as PriceConversion?),
                settings: settings,
              );
            case '/home_transition':
              return NoPopTransitionRoute(
                builder: (_) => AppHomePage(priceConversion: settings.arguments as PriceConversion?),
                settings: settings,
              );
            case '/intro_welcome':
              return NoTransitionRoute(
                builder: (_) => IntroWelcomePage(),
                settings: settings,
              );
            case '/intro_password_on_launch':
              return MaterialPageRoute(
                builder: (_) => IntroPasswordOnLaunch(seed: settings.arguments as String?),
                settings: settings,
              );
            case '/intro_password':
              return MaterialPageRoute(
                builder: (_) => IntroPassword(seed: settings.arguments as String?),
                settings: settings,
              );
            case '/intro_backup':
              return MaterialPageRoute(
                builder: (_) => IntroBackupSeedPage(encryptedSeed: settings.arguments as String?),
                settings: settings,
              );
            case '/intro_backup_safety':
              return MaterialPageRoute(
                builder: (_) => IntroBackupSafetyPage(),
                settings: settings,
              );
            case '/intro_backup_confirm':
              return MaterialPageRoute(
                builder: (_) => IntroBackupConfirm(),
                settings: settings,
              );
            case '/intro_import':
              return MaterialPageRoute(
                builder: (_) => IntroImportSeedPage(),
                settings: settings,
              );
            case '/lock_screen':
              return NoTransitionRoute(
                builder: (_) => AppLockScreen(),
                settings: settings,
              );
            case '/lock_screen_transition':
              return MaterialPageRoute(
                builder: (_) => AppLockScreen(),
                settings: settings,
              );
            case '/password_lock_screen':
              return NoTransitionRoute(
                builder: (_) => AppPasswordLockScreen(),
                settings: settings,
              );
            case '/avatar_page':
              return PageRouteBuilder(
                  pageBuilder: (BuildContext context, Animation<double> animationIn, Animation<double> animationOut) => AvatarPage(),
                  settings: settings,
                  opaque: false);
            case '/avatar_change_page':
              return MaterialPageRoute(
                builder: (_) => AvatarChangePage(curAddress: StateContainer.of(context).selectedAccount!.address),
                settings: settings,
              );
            case '/before_scan_screen':
              return NoTransitionRoute(
                builder: (_) => BeforeScanScreen(),
                settings: settings,
              );
            // nautilus API routes:
            case '/register_username':
              return NoTransitionRoute(
                builder: (_) => RegisterUsernameScreen(),
                settings: settings,
              );
            // case '/payments_page':
            //   return NoPopTransitionRoute(
            //     builder: (_) => PaymentsPage(),
            //     settings: settings,
            //   );
            case '/purchase_nano':
              return NoTransitionRoute(
                builder: (_) => PurchaseNanoScreen(),
                settings: settings,
              );
            case '/generate_paper_wallet':
              return NoTransitionRoute(
                builder: (_) => GeneratePaperWalletScreen(localCurrency: StateContainer.of(context).curCurrency),
                settings: settings,
              );
            // case '/payments_page':
            //   return NoTransitionRoute(
            //     builder: (_) => PaymentsPage(),
            //     settings: settings,
            //   );
            default:
              return null;
          }
        },
      ),
    );
  }
}

/// Splash
/// Default page route that determines if user is logged in and routes them appropriately.
class Splash extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with WidgetsBindingObserver {
  late bool _hasCheckedLoggedIn;
  late bool _retried;

  bool seedIsEncrypted(String seed) {
    try {
      String salted = NanoHelpers.bytesToUtf8String(NanoHelpers.hexToBytes(seed.substring(0, 16)));
      if (salted == "Salted__") {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> checkLoggedIn() async {
    // Update session key
    await sl.get<Vault>().updateSessionKey();
    // Check if device is rooted or jailbroken, show user a warning informing them of the risks if so
    if (Platform.isIOS || Platform.isAndroid) {
      if (!(await sl.get<SharedPrefsUtil>().getHasSeenRootWarning()) && await FlutterJailbreakDetection.jailbroken) {
        AppDialogs.showConfirmDialog(
            context,
            CaseChange.toUpperCase(AppLocalization.of(context)!.warning, context),
            AppLocalization.of(context)!.rootWarning,
            AppLocalization.of(context)!.iUnderstandTheRisks.toUpperCase(),
            () async {
              await sl.get<SharedPrefsUtil>().setHasSeenRootWarning();
              checkLoggedIn();
            },
            cancelText: AppLocalization.of(context)!.exit.toUpperCase(),
            cancelAction: () {
              if (Platform.isIOS) {
                exit(0);
              } else {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              }
            });
        return;
      }
    }
    if (!_hasCheckedLoggedIn) {
      _hasCheckedLoggedIn = true;
    } else {
      return;
    }
    try {
      // iOS key store is persistent, so if this is first launch then we will clear the keystore
      bool firstLaunch = await sl.get<SharedPrefsUtil>().getFirstLaunch();
      if (firstLaunch) {
        await sl.get<Vault>().deleteAll();
      }
      await sl.get<SharedPrefsUtil>().setFirstLaunch();
      // See if logged in already
      bool isLoggedIn = false;
      bool isEncrypted = false;
      String? seed = await sl.get<Vault>().getSeed();
      String? pin = await sl.get<Vault>().getPin();
      // If we have a seed set, but not a pin - or vice versa
      // Then delete the seed and pin from device and start over.
      // This would mean user did not complete the intro screen completely.
      if (seed != null && pin != null) {
        isLoggedIn = true;
        isEncrypted = seedIsEncrypted(seed);
      } else if (seed != null && pin == null) {
        await sl.get<Vault>().deleteSeed();
      } else if (pin != null && seed == null) {
        await sl.get<Vault>().deletePin();
      }

      if (isLoggedIn) {
        if (isEncrypted) {
          Navigator.of(context).pushReplacementNamed('/password_lock_screen');
        } else if (await sl.get<SharedPrefsUtil>().getLock() || await sl.get<SharedPrefsUtil>().shouldLock()) {
          Navigator.of(context).pushReplacementNamed('/lock_screen');
        } else {
          await NanoUtil().loginAccount(seed, context);
          PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
          Navigator.of(context).pushReplacementNamed('/home', arguments: conversion);
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/intro_welcome');
      }
    } catch (e) {
      /// Fallback secure storage
      /// A very small percentage of users are encountering issues writing to the
      /// Android keyStore using the flutter_secure_storage plugin.
      ///
      /// Instead of telling them they are out of luck, this is an automatic "fallback"
      /// It will generate a 64-byte secret using the native android "bottlerocketstudios" Vault
      /// This secret is used to encrypt sensitive data and save it in SharedPreferences
      if (Platform.isAndroid && e.toString().contains("flutter_secure")) {
        if (!(await sl.get<SharedPrefsUtil>().useLegacyStorage())) {
          await sl.get<SharedPrefsUtil>().setUseLegacyStorage();
          checkLoggedIn();
        }
      } else {
        await sl.get<Vault>().deleteAll();
        await sl.get<SharedPrefsUtil>().deleteAll();
        if (!_retried) {
          _retried = true;
          _hasCheckedLoggedIn = false;
          checkLoggedIn();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hasCheckedLoggedIn = false;
    _retried = false;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => checkLoggedIn());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Account for user changing locale when leaving the app
    switch (state) {
      case AppLifecycleState.paused:
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        setLanguage();
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  void setLanguage() {
    setState(() {
      StateContainer.of(context).deviceLocale = Localizations.localeOf(context);
    });
    sl.get<SharedPrefsUtil>().getLanguage().then((LanguageSetting setting) {
      setState(() {
        StateContainer.of(context).updateLanguage(setting);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This seems to be the earliest place we can retrieve the device Locale
    setLanguage();
    sl.get<SharedPrefsUtil>().getCurrency(StateContainer.of(context).deviceLocale).then((AvailableCurrency currency) {
      StateContainer.of(context).curCurrency = currency;
    });
    return Scaffold(
      backgroundColor: StateContainer.of(context).curTheme.background,
    );
  }
}
