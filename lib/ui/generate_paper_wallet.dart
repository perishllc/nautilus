import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';

import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';

// import 'package:flare_flutter/flare_actor.dart';
// import 'package:nautilus_wallet_flutter/dimens.dart';
// import 'package:nautilus_wallet_flutter/localization.dart';
// import 'package:nautilus_wallet_flutter/model/vault.dart';
// import 'package:nautilus_wallet_flutter/service_locator.dart';
// import 'package:nautilus_wallet_flutter/styles.dart';
// import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';

class GeneratePaperWalletScreen extends StatefulWidget {
  @override
  _GeneratePaperWalletScreenState createState() => _GeneratePaperWalletScreenState();
}

class _GeneratePaperWalletScreenState extends State<GeneratePaperWalletScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  String paper_wallet_seed;
  String paper_wallet_account;

  @override
  void initState() {
    super.initState();

    paper_wallet_seed = NanoSeeds.generateSeed();
    paper_wallet_account = NanoUtil.seedToAddress(paper_wallet_seed, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (context, constraints) => SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              //A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Back Button
                        Container(
                          margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 15 : 20),
                          height: 50,
                          width: 50,
                          child: FlatButton(
                              highlightColor: StateContainer.of(context).curTheme.text15,
                              splashColor: StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(0.0),
                              child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                      ],
                    ),
                    // Safety icon
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40,
                        top: 15,
                      ),
                      child: Icon(
                        AppIcons.security,
                        size: 60,
                        color: StateContainer.of(context).curTheme.primary,
                      ),
                    ),
                    // The header
                    Container(
                      margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40,
                        end: smallScreen(context) ? 30 : 40,
                        top: 10,
                      ),
                      alignment: AlignmentDirectional(-1, 0),
                      child: AutoSizeText(
                        "TODO!",
                        style: AppStyles.textStyleHeaderColored(context),
                        stepGranularity: 0.1,
                        maxLines: 1,
                        minFontSize: 12,
                      ),
                    ),
                    // The paragraph
                    Container(
                      margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 15.0),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: <Widget>[
                          // AutoSizeText(
                          //   AppLocalization.of(context).secretInfo,
                          //   style: AppStyles.textStyleParagraph(context),
                          //   maxLines: 5,
                          //   stepGranularity: 0.5,
                          // ),
                          Container(
                            margin: EdgeInsetsDirectional.only(top: 15),
                            child: Text("$paper_wallet_seed $paper_wallet_account"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Next Screen Button
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).gotItButton, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
              //       Navigator.of(context).pushNamed('/intro_backup', arguments: StateContainer.of(context).encryptedSecret);
              //     }),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
