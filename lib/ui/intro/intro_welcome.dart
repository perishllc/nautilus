import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';

class IntroWelcomePage extends StatefulWidget {
  @override
  _IntroWelcomePageState createState() => _IntroWelcomePageState();
}

class _IntroWelcomePageState extends State<IntroWelcomePage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (context, constraints) => SafeArea(
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
                    SizedBox(
                      // Width/Height ratio for the animation is needed because BoxFit is not working as expected
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 5 / 8,
                      child: const Center(
                        child: Image(image: AssetImage("assets/logo-square.png")),
                      ),
                    ),
                    
                    Container(
                      color: Colors.white,
                      // padding: EdgeInsets.zero,
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      width: double.infinity,
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
                        AppLocalization.of(context)!.welcomeText,
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
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context)!.newWallet, Dimens.BUTTON_TOP_DIMENS,
                          instanceKey: const Key("new_wallet_button"), onPressed: () {
                        Navigator.of(context).pushNamed('/intro_backup_safety');
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Import Wallet Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context)!.importWallet, Dimens.BUTTON_BOTTOM_DIMENS,
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
