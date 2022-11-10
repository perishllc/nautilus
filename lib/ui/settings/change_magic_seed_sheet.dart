import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:magic_sdk/magic_sdk.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:nautilus_wallet_flutter/util/blake2b.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';

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
            // Sheet handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 5,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.text20,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
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
                              CaseChange.toUpperCase(AppLocalization.of(context).changeSeed, context),
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
                      //       AppDialogs.showInfoDialog(context, AppLocalization.of(context).plausibleInfoHeader, AppLocalization.of(context).plausibleSheetInfo);
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
                    margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 16.0),
                    child: AutoSizeText(
                      AppLocalization.of(context).changeSeedParagraph,
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
                              hintText: AppLocalization.of(context).setPassword,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                color: passwordsMatch ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.text,
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
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).changeSeed, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      await submitAndEncrypt();
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
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
        passwordError = AppLocalization.of(context).passwordBlank;
      });
      return;
    }

    // password requirements:

    // password must be at least 8 characters:
    if (confirmPasswordController!.text.length < 8) {
      setState(() {
        passwordError = AppLocalization.of(context).passwordTooShort;
      });
      return;
    }

    // make sure password contains a number:
    if (!confirmPasswordController!.text.contains(RegExp(r"[0-9]"))) {
      setState(() {
        passwordError = AppLocalization.of(context).passwordNumber;
      });
      return;
    }

    // make sure password contains an uppercase and lowercase letter:
    if (!confirmPasswordController!.text.contains(RegExp(r"[a-z]")) || !confirmPasswordController!.text.contains(RegExp(r"[A-Z]"))) {
      setState(() {
        passwordError = AppLocalization.of(context).passwordCapitalLetter;
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
    final String hashedPassword = NanoHelpers.byteToHex(blake2b(NanoHelpers.hexToBytes(confirmPasswordController!.text)));
    final String fullIdentifier = "$issuer$hashedPassword";

    if (!mounted) return;

    Navigator.of(context).pushNamed("/intro_import", arguments: <String, String>{"fullIdentifier": fullIdentifier, "password": confirmPasswordController!.text});
  }
}
