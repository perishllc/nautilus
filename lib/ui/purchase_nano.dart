import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/app_icons.dart';

class PurchaseNanoScreen extends StatefulWidget {
  @override
  _PurchaseNanoScreenState createState() => _PurchaseNanoScreenState();
}

class _PurchaseNanoScreenState extends State<PurchaseNanoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                          child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: StateContainer.of(context).curTheme.text15,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                padding: EdgeInsets.zero,
                                // highlightColor: StateContainer.of(context).curTheme.text15,
                                // splashColor: StateContainer.of(context).curTheme.text15,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
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
                    // Container(
                    //   margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 15.0),
                    //   alignment: Alignment.centerLeft,
                    //   child: Column(
                    //     children: <Widget>[
                    //       AutoSizeText(
                    //         Z.of(context).secretInfo,
                    //         style: AppStyles.textStyleParagraph(context),
                    //         maxLines: 5,
                    //         stepGranularity: 0.5,
                    //       ),
                    //       Container(
                    //         margin: EdgeInsetsDirectional.only(top: 15),
                    //         child: AutoSizeText(
                    //           Z.of(context).secretWarning,
                    //           style: AppStyles.textStyleParagraphPrimary(context),
                    //           maxLines: 4,
                    //           stepGranularity: 0.5,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),

              // Next Screen Button
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).gotItButton, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
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
