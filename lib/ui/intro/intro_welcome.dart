import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';

class IntroWelcomePage extends StatefulWidget {
  @override
  IntroWelcomePageState createState() => IntroWelcomePageState();
}

class IntroWelcomePageState extends State<IntroWelcomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //Container for the animation
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 30,
                      ),
                      // Width/Height ratio for the animation is needed because BoxFit is not working as expected
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 4 / 8,
                      // width: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: Image(image: AssetImage("assets/logo.png")),
                      ),
                    ),

                    Container(
                      color: Colors.white,
                      // padding: EdgeInsets.zero,
                      // padding: const EdgeInsets.only(top: 5, bottom: 5),
                      // width: double.infinity,
                      width: MediaQuery.of(context).size.width,
                      child: TextLiquidFill(
                        text: "NAUTILUS",
                        waveColor: Colors.blueAccent,
                        boxBackgroundColor: Colors.black,
                        textStyle: const TextStyle(
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                        ),
                        boxHeight: 100.0,
                        boxWidth: double.infinity,
                        loadDuration: const Duration(seconds: 3),
                        waveDuration: const Duration(seconds: 3),
                        loadUntil: 0.5,
                      ),
                    ),
                    //Container for the paragraph
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 30 : 40, vertical: 20),
                      child: AutoSizeText(
                        AppLocalization.of(context).welcomeTextUpdated,
                        style: AppStyles.textStyleParagraph(context),
                        maxLines: 4,
                        stepGranularity: 0.5,
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
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).newWallet, Dimens.BUTTON_TOP_DIMENS,
                          instanceKey: const Key("new_wallet_button"), onPressed: () {
                        Navigator.of(context).pushNamed('/intro_backup_safety');
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Import Wallet Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).importWallet, Dimens.BUTTON_BOTTOM_DIMENS,
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
}
