import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/network/auth_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/widgets/animations.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';

class IntroLoginPage extends StatefulWidget {
  const IntroLoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IntroLoginPageState createState() => _IntroLoginPageState();
}

class _IntroLoginPageState extends State<IntroLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode emailFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  String? emailError;

  final Magic magic = Magic.instance;

  Future<void> loginFunction({required String email}) async {
    try {
      final String key = await magic.auth.loginWithMagicLink(email: emailController.text);
      bool animationOpen = true;
      if (!mounted) return;
      AppAnimation.animationLauncher(context, AnimationType.GENERIC, onPoppedCallback: () => animationOpen = false);

      final Uint8List decodedKey = base64.decode(key);
      final String stringKey = utf8.decode(decodedKey);

      final List<dynamic> didToken = jsonDecode(stringKey) as List<dynamic>;
      final Map<String, dynamic> claim = jsonDecode(didToken[1] as String) as Map<String, dynamic>;
      final String issuer = claim["iss"] as String;

      final bool entryExists = await sl.get<AuthService>().entryExists(issuer);
      if (!mounted) return;

      if (animationOpen) {
        Navigator.of(context).pop();
      }
      Navigator.of(context).pushNamed('/intro_magic_password', arguments: <String, dynamic>{"entryExists": entryExists, "issuer": issuer});
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        body: TapOutsideUnfocus(
            child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
            minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
            child: Column(
              children: <Widget>[
                //A widget that holds the header, the paragraph and Back Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      // The header
                      Container(
                        margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 10,
                        ),
                        alignment: AlignmentDirectional.centerStart,
                        child: AutoSizeText(
                          Z.of(context).loginOrRegisterHeader,
                          maxLines: 3,
                          stepGranularity: 0.5,
                          style: AppStyles.textStyleHeaderColored(context),
                        ),
                      ),
                      // The paragraph
                      // TODO:
                      // Container(
                      //   margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 16.0),
                      //   child: AutoSizeText(
                      //     Z.of(context).passwordWillBeRequiredToOpenParagraph,
                      //     style: AppStyles.textStyleParagraph(context),
                      //     maxLines: 5,
                      //     stepGranularity: 0.5,
                      //   ),
                      // ),
                      Expanded(
                          child: KeyboardAvoider(
                              duration: Duration.zero,
                              autoScroll: true,
                              focusPadding: 40,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                // Create an email Text Field
                                AppTextField(
                                  topMargin: 30,
                                  // padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                                  focusNode: emailFocusNode,
                                  controller: emailController,
                                  textInputAction: TextInputAction.done,
                                  maxLines: 1,
                                  autocorrect: false,
                                  onChanged: (String newText) {
                                    if (emailError != null) {
                                      setState(() {
                                        emailError = null;
                                      });
                                    }
                                  },
                                  hintText: Z.of(context).enterEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  textAlign: TextAlign.center,
                                  // style: TextStyle(
                                  //   fontWeight: FontWeight.w700,
                                  //   fontSize: 16.0,
                                  //   // color: passwordsMatch ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.text,
                                  //   fontFamily: "NunitoSans",
                                  // ),
                                ),
                                // Error Text
                                Container(
                                  alignment: AlignmentDirectional.center,
                                  margin: const EdgeInsets.only(top: 3),
                                  child: Text(emailError == null ? "" : emailError!,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: StateContainer.of(context).curTheme.primary,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                              ])))
                    ],
                  ),
                ),

                //A column with "Next" and "Go Back" buttons
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Next Button
                        AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).nextButton, Dimens.BUTTON_BOTTOM_DIMENS,
                            onPressed: () async {
                          loginFunction(email: emailController.text);
                        }),
                      ],
                    ),
                    // Row(
                    //   children: <Widget>[
                    //     // Go Back Button
                    //     AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).goBackButton, Dimens.BUTTON_BOTTOM_DIMENS,
                    //         onPressed: () {
                    //       Navigator.of(context).pop();
                    //     }),
                    //   ],
                    // ),
                  ],
                ),
              ],
            ),
          ),
        )));
  }
}
