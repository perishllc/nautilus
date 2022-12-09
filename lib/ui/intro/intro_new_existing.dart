import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/themes.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class IntroNewExistingPage extends StatefulWidget {
  @override
  IntroNewExistingPageState createState() => IntroNewExistingPageState();
}

class IntroNewExistingPageState extends State<IntroNewExistingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isDarkModeEnabled = SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color? primaryColor = StateContainer.of(context).curTheme.primary;
    final bool landscape = MediaQuery.of(context).orientation == Orientation.landscape;
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
              Row(
                children: [
                  // Back Button
                  Container(
                    // alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 15 : 20),
                    height: 50,
                    width: 50,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: StateContainer.of(context).curTheme.text15,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                  ),
                ],
              ),
              // A widget that holds welcome animation + paragraph
              Expanded(
                child: Flex(
                  direction: landscape ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: landscape ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: <Widget>[
                    //Container for the animation
                    SizedBox(
                      width: landscape ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topCenter,
                                margin: const EdgeInsets.only(top: 20),
                                color: StateContainer.of(context).curTheme.text,
                                width: landscape ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
                                height: 80,
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.zero,
                                width: landscape ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
                                height: 100,
                                child: TextLiquidFill(
                                  text: CaseChange.toUpperCase(NonTranslatable.nautilus, context),
                                  waveColor: primaryColor ?? NautilusTheme.nautilusBlue,
                                  boxBackgroundColor: StateContainer.of(context).curTheme.backgroundDark!,
                                  textStyle: const TextStyle(fontSize: 60.0, fontWeight: FontWeight.bold, color: Colors.white),
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
                                color: StateContainer.of(context).curTheme.backgroundDark,
                                width: landscape ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width,
                                height: 15,
                              ),
                            ],
                          ),

                          // Container for the paragraph
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 30 : 40, vertical: 20),
                            child: AutoSizeText(
                              Z.of(context).welcomeTextWithoutLogin,
                              style: AppStyles.textStyleParagraph(context),
                              maxLines: 4,
                              stepGranularity: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //A column with "New Wallet" and "Import Wallet" buttons
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // New Wallet Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).newWallet, Dimens.BUTTON_TOP_DIMENS,
                          instanceKey: const Key("new_wallet_button"), onPressed: () {
                        Navigator.of(context).pushNamed('/intro_backup_safety');
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Import Wallet Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).importWallet, Dimens.BUTTON_BOTTOM_DIMENS,
                          onPressed: () {
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
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: conversion);
  }
}
