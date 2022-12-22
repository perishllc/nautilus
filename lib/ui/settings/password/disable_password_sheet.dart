import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/nanoutil.dart';

class DisablePasswordSheet extends StatefulWidget {
  _DisablePasswordSheetState createState() => _DisablePasswordSheetState();
}

class _DisablePasswordSheetState extends State<DisablePasswordSheet> {
  FocusNode? passwordFocusNode;
  TextEditingController? passwordController;

  String? passwordError;

  @override
  void initState() {
    super.initState();
    passwordFocusNode = FocusNode();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
        child: LayoutBuilder(
      builder: (context, constraints) => SafeArea(
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
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: 10, start: 60, end: 60),
                    child: Column(
                      children: <Widget>[
                        AutoSizeText(
                          CaseChange.toUpperCase(Z.of(context).disablePasswordSheetHeader, context),
                          style: AppStyles.textStyleHeader(context),
                          minFontSize: 12,
                          stepGranularity: 0.1,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  // The paragraph
                  Container(
                    margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 16.0),
                    child: AutoSizeText(
                      Z.of(context).passwordNoLongerRequiredToOpenParagraph.replaceAll("%1", NonTranslatable.appName),
                      style: AppStyles.textStyleParagraph(context),
                      maxLines: 5,
                      stepGranularity: 0.5,
                    ),
                  ),
                  // Text field
                  Expanded(
                      child: KeyboardAvoider(
                          duration: Duration.zero,
                          autoScroll: true,
                          focusPadding: 40,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                            AppTextField(
                              topMargin: 30,
                              padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                              focusNode: passwordFocusNode,
                              controller: passwordController,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              autocorrect: false,
                              onChanged: (String newText) {
                                if (passwordError != null) {
                                  setState(() {
                                    passwordError = null;
                                  });
                                }
                              },
                              hintText: Z.of(context).enterPasswordHint,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                color: StateContainer.of(context).curTheme.text,
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
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).disablePasswordSheetHeader, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      await submitAndDecrypt();
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
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

  Future<void> submitAndDecrypt() async {
    String? encryptedSeed = await sl.get<Vault>().getSeed();
    if (passwordController!.text.isEmpty) {
      if (mounted) {
        setState(() {
          passwordError = Z.of(context).passwordBlank;
        });
      }
    } else {
      try {
        String decryptedSeed = NanoHelpers.byteToHex(NanoCrypt.decrypt(encryptedSeed, passwordController!.text));
        throwIf(!NanoUtil.isValidSeed(decryptedSeed), const FormatException());
        await sl.get<Vault>().setSeed(decryptedSeed);
        StateContainer.of(context).resetEncryptedSecret();
        UIUtil.showSnackbar(Z.of(context).disablePasswordSuccess, context);
        Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          setState(() {
            passwordError = Z.of(context).invalidPassword;
          });
        }
      }
    }
  }
}
