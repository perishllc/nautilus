import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/blake2b.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class ChangeMagicSeedSheet extends StatefulWidget {
  @override
  _ChangeMagicSeedSheetState createState() => _ChangeMagicSeedSheetState();
}

class _ChangeMagicSeedSheetState extends State<ChangeMagicSeedSheet> {
  FocusNode? confirmPasswordFocusNode;
  TextEditingController? confirmPasswordController;

  String? passwordError;

  late bool passwordsMatch;

  @override
  void initState() {
    super.initState();
    passwordsMatch = false;
    confirmPasswordFocusNode = FocusNode();
    confirmPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
        child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            Handlebars.horizontal(context),
            // The main widget that holds the header, text fields, and submit button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // The header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(
                      //   width: 60,
                      //   height: 60,
                      // ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              CaseChange.toUpperCase(Z.of(context).changeSeed, context),
                              style: AppStyles.textStyleHeader(context),
                              minFontSize: 12,
                              stepGranularity: 0.1,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   width: 60,
                      //   height: 60,
                      //   // padding: const EdgeInsets.only(top: 25, right: 20),
                      //   child: AppDialogs.infoButton(
                      //     context,
                      //     () {
                      //       AppDialogs.showInfoDialog(context, Z.of(context).plausibleInfoHeader, Z.of(context).plausibleSheetInfo);
                      //     },
                      //   ),
                      // ),
                      // const SizedBox(
                      //   width: 60,
                      //   height: 60,
                      // ),
                    ],
                  ),
                  // The paragraph
                  Container(
                    margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 16.0),
                    child: AutoSizeText(
                      Z.of(context).changeSeedParagraph,
                      style: AppStyles.textStyleParagraph(context),
                      maxLines: 5,
                      stepGranularity: 0.5,
                    ),
                  ),
                  Expanded(
                      child: KeyboardAvoider(
                          duration: Duration.zero,
                          autoScroll: true,
                          focusPadding: 40,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                            // Confirm Password Text Field
                            AppTextField(
                              topMargin: 20,
                              padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                              focusNode: confirmPasswordFocusNode,
                              controller: confirmPasswordController,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [],
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              autocorrect: false,
                              onChanged: (String newText) {
                                if (passwordError != null) {
                                  setState(() {
                                    passwordError = null;
                                  });
                                }
                              },
                              hintText: Z.of(context).setPassword,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                color: passwordsMatch
                                    ? StateContainer.of(context).curTheme.primary
                                    : StateContainer.of(context).curTheme.text,
                                fontFamily: "NunitoSans",
                              ),
                            ),
                            // Error Text
                            Container(
                              alignment: AlignmentDirectional.center,
                              margin: const EdgeInsets.only(top: 3),
                              child: Text(passwordError == null ? "" : passwordError!,
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

            // Set Password Button
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context, AppButtonType.PRIMARY, Z.of(context).changeSeed, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      await submitAndEncrypt();
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> submitAndEncrypt() async {
    // final String? curPin = await sl.get<Vault>().getPin();
    if (!mounted) return;
    if (confirmPasswordController!.text.isEmpty) {
      setState(() {
        passwordError = Z.of(context).passwordBlank;
      });
      return;
    }

    // password requirements:

    // password must be at least 8 characters:
    if (confirmPasswordController!.text.length < 8) {
      setState(() {
        passwordError = Z.of(context).passwordTooShort;
      });
      return;
    }

    // make sure password contains a number:
    if (!confirmPasswordController!.text.contains(RegExp(r"[0-9]"))) {
      setState(() {
        passwordError = Z.of(context).passwordNumber;
      });
      return;
    }

    // make sure password contains an uppercase and lowercase letter:
    if (!confirmPasswordController!.text.contains(RegExp(r"[a-z]")) ||
        !confirmPasswordController!.text.contains(RegExp(r"[A-Z]"))) {
      setState(() {
        passwordError = Z.of(context).passwordCapitalLetter;
      });
      return;
    }

    // delete the old key if it exists:

    final Magic magic = Magic.instance;
    final String key = await magic.user.getIdToken();
    final Uint8List decodedKey = base64.decode(key);
    final String stringKey = utf8.decode(decodedKey);
    final List<dynamic> didToken = jsonDecode(stringKey) as List<dynamic>;
    final Map<String, dynamic> claim = jsonDecode(didToken[1] as String) as Map<String, dynamic>;
    final String issuer = claim["iss"] as String;

    // get identifier:
    final String hashedPassword =
        NanoHelpers.byteToHex(blake2b(Uint8List.fromList(utf8.encode(confirmPasswordController!.text))));
    final String fullIdentifier = "$issuer:$hashedPassword";

    if (!mounted) return;

    Navigator.of(context).pushNamed("/intro_import",
        arguments: <String, String>{"fullIdentifier": fullIdentifier, "password": confirmPasswordController!.text});
  }
}
