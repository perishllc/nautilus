import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/available_themes.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/themes.dart';
import 'package:wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class IntroWelcomePage extends StatefulWidget {
  @override
  IntroWelcomePageState createState() => IntroWelcomePageState();
}

class IntroWelcomePageState extends State<IntroWelcomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isDarkModeEnabled =
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    // post frame callback:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool openedDialog = false;

      // If the system can show an authorization request dialog
      if (Platform.isIOS) {
        if (await sl.get<SharedPrefsUtil>().getTrackingEnabled() == false ||
            await AppTrackingTransparency.trackingAuthorizationStatus ==
                TrackingStatus.notDetermined) {
          // Show a custom explainer dialog before the system dialog
          await AppDialogs.showInfoDialog(
            context,
            Z.of(context).trackingHeader,
            Z.of(context).askTracking,
            closeText: Z.of(context).continueButton.toUpperCase(),
            barrierDismissible: false,
            onPressed: () async {
              bool trackingEnabled = false;
              if (Platform.isIOS) {
                trackingEnabled = await AppTrackingTransparency
                        .requestTrackingAuthorization() ==
                    TrackingStatus.authorized;
              } else {
                trackingEnabled =
                    (await AppDialogs.showTrackingDialog(context))!;
              }
              await sl
                  .get<SharedPrefsUtil>()
                  .setTrackingEnabled(trackingEnabled);
              FlutterBranchSdk.disableTracking(!trackingEnabled);
            },
          );
        }
      }

      // TODO: re-enable with a different message:
      // // check every 500ms if there's a giftcard:
      // timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) async {
      //   if (!mounted) return;
      //   if (!openedDialog && StateContainer.of(context).gift != null) {
      //     openedDialog = true;
      //     timer?.cancel();

      //     AppDialogs.showConfirmDialog(
      //       context,
      //       Z.of(context).giftAlert,
      //       Z.of(context).askSkipSetup,
      //       Z.of(context).ok,
      //       () async {
      //         setState(() {
      //           StateContainer.of(context).introSkiped = true;
      //         });

      //         await skipIntro();
      //       },
      //       cancelText: Z.of(context).noThanks,
      //       cancelAction: () {
      //         // do nothing:
      //       },
      //       barrierDismissible: false,
      //     );
      //   }
      // });
    });

    // var magic = Magic.instance;
    // var token = await magic.auth.loginWithMagicLink(email: textController.text);
  }

  Future<void> _themeDialog() async {
    final ThemeOptions? selection = await showAppDialog<ThemeOptions>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
      ThemeSetting _curThemeSetting =
          await sl.get<SharedPrefsUtil>().getTheme();
      if (_curThemeSetting != ThemeSetting(selection)) {
        sl
            .get<SharedPrefsUtil>()
            .setTheme(ThemeSetting(selection))
            .then((void result) {
          setState(() {
            StateContainer.of(context).updateTheme(ThemeSetting(selection));
            _curThemeSetting = ThemeSetting(selection);
          });
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final Color? primaryColor = StateContainer.of(context).curTheme.primary;
    final bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
          minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.035,
            top: MediaQuery.of(context).size.height * 0.10,
          ),
          child: Column(
            children: <Widget>[
              // A widget that holds welcome animation + paragraph
              Expanded(
                child: Flex(
                  direction: landscape ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: landscape
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    //Container for the animation
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      margin: const EdgeInsets.only(bottom: 30),
                      height: 200,
                      child: SvgPicture.asset("assets/logo.svg",
                          color: primaryColor),
                    ),

                    // LottieBuilder.asset(
                    //   "assets/animations/whale.json",
                    //   width: 100,
                    //   height: 100,
                    //   fit: BoxFit.cover,
                    // ),

                    SizedBox(
                      width: landscape
                          ? MediaQuery.of(context).size.width / 2
                          : MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topCenter,
                                margin: const EdgeInsets.only(top: 20),
                                color: StateContainer.of(context).curTheme.text,
                                width: landscape
                                    ? MediaQuery.of(context).size.width / 2
                                    : MediaQuery.of(context).size.width,
                                height: 80,
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.zero,
                                width: landscape
                                    ? MediaQuery.of(context).size.width / 2
                                    : MediaQuery.of(context).size.width,
                                height: 100,
                                child: TextLiquidFill(
                                  text: CaseChange.toUpperCase(
                                      NonTranslatable.appName, context),
                                  waveColor: primaryColor ??
                                      NautilusTheme.nautilusBlue,
                                  boxBackgroundColor: StateContainer.of(context)
                                      .curTheme
                                      .backgroundDark!,
                                  textStyle: const TextStyle(
                                      fontSize: 60.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  boxHeight: 100,
                                  boxWidth: double.infinity,
                                  loadDuration: const Duration(seconds: 3),
                                  waveDuration: const Duration(seconds: 3),
                                  loadUntil: 0.5,
                                ),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                margin: const EdgeInsets.only(top: 90),
                                color: StateContainer.of(context)
                                    .curTheme
                                    .backgroundDark,
                                width: landscape
                                    ? MediaQuery.of(context).size.width / 2
                                    : MediaQuery.of(context).size.width,
                                height: 15,
                              ),
                            ],
                          ),
                          // Container for the paragraph
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: smallScreen(context) ? 30 : 40,
                                vertical: 20),
                            child: AutoSizeText(
                              Z
                                  .of(context)
                                  .welcomeTextLogin
                                  .replaceAll("%1", NonTranslatable.appName),
                              style: AppStyles.textStyleParagraph(context),
                              maxLines: 2,
                              stepGranularity: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // end
                  ],
                ),
              ),

              //A column with "New Wallet" and "Import Wallet" buttons
              Column(
                children: <Widget>[
                  // Container(
                  //   margin: const EdgeInsets.only(right: 28),
                  //   alignment: Alignment.centerRight,
                  //   child: DayNightSwitcherIcon(
                  //     isDarkModeEnabled: isDarkModeEnabled,
                  //     onStateChanged: (bool enabled) {
                  //       setState(() {
                  //         isDarkModeEnabled = enabled;
                  //         if (!isDarkModeEnabled) {
                  //           StateContainer.of(context).updateTheme(ThemeSetting(ThemeOptions.INDIUM));
                  //         } else {
                  //           StateContainer.of(context).updateTheme(ThemeSetting(ThemeOptions.NAUTILUS));
                  //         }
                  //       });
                  //     },
                  //   ),
                  // ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 16, right: 28),
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(
                      backgroundColor:
                          StateContainer.of(context).curTheme.successDark,
                      onPressed: () {
                        _themeDialog();
                      },
                      child: Icon(
                        AppIcons.theme,
                        size: 32,
                        color: StateContainer.of(context).curTheme.text,
                      ),
                    ),
                  ),

                  // Row(
                  //   children: <Widget>[
                  //     AppButton.buildAppButton(
                  //         context, AppButtonType.PRIMARY, Z.of(context).loginOrRegisterHeader, Dimens.BUTTON_TOP_DIMENS,
                  //         instanceKey: const Key("get_started_button"), onPressed: () {
                  //       Navigator.of(context).pushNamed('/intro_login');
                  //     }),
                  //   ],
                  // ),

                  // Row(
                  //   children: <Widget>[
                  //     AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                  //         Z.of(context).continueWithoutLogin, Dimens.BUTTON_BOTTOM_DIMENS,
                  //         instanceKey: const Key("new_existing_button"), onPressed: () {
                  //       Navigator.of(context).pushNamed('/intro_new_existing');
                  //     }),
                  //   ],
                  // ),

                  Row(
                    children: <Widget>[
                      // New Wallet Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY,
                          Z.of(context).newWallet, Dimens.BUTTON_TOP_DIMENS,
                          instanceKey: const Key("new_wallet_button"),
                          onPressed: () {
                        Navigator.of(context).pushNamed('/intro_backup_safety');
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Import Wallet Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY_OUTLINE,
                          Z.of(context).importWallet,
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pushNamed('/intro_import');
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> skipIntro() async {
    // set random representative as the default:
    // TODO: disabled because mynano.ninja is down:
    // final List<NinjaNode>? nodes = await NinjaAPI.getVerifiedNodes();
    // if (nodes != null && nodes.isNotEmpty) {
    //   final Random random = Random();
    //   final NinjaNode randomNode = nodes[random.nextInt(nodes.length)];
    //   sl.get<SharedPrefsUtil>().setRepresentative(randomNode.account);
    //   AppWallet.defaultRepresentative = randomNode.account!;
    // }
    await sl.get<DBHelper>().dropAccounts();
    await sl.get<Vault>().setSeed(NanoSeeds.generateSeed());
    if (!mounted) return;
    // Update wallet
    final String seed = await StateContainer.of(context).getSeed();
    if (!mounted) return;
    await NanoUtil().loginAccount(seed, context);

    const String DEFAULT_PIN = "000000";

    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<Vault>().writePin(DEFAULT_PIN);
    final PriceConversion conversion =
        await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home', (Route<dynamic> route) => false,
        arguments: conversion);
  }

  Future<void> handleBranchGift() async {
    await showDialog<int>(
        barrierDismissible: false,
        context: context,
        barrierColor: StateContainer.of(context).curTheme.barrier,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              Z.of(context).giftAlert,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("${Z.of(context).importGiftIntro}\n\n",
                    style: AppStyles.textStyleParagraph(context)),
              ],
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    Z.of(context).close,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              )
            ],
          );
        });
  }
}
