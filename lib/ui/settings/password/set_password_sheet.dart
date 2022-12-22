import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
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

class SetPasswordSheet extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SetPasswordSheetState createState() => _SetPasswordSheetState();
}

class _SetPasswordSheetState extends State<SetPasswordSheet> {
  FocusNode? createPasswordFocusNode;
  TextEditingController? createPasswordController;
  FocusNode? confirmPasswordFocusNode;
  TextEditingController? confirmPasswordController;

  String? passwordError;

  late bool passwordsMatch;

  @override
  void initState() {
    super.initState();
    passwordsMatch = false;
    createPasswordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
    createPasswordController = TextEditingController();
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
              margin: EdgeInsets.only(top: 10),
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
                    margin: EdgeInsetsDirectional.only(top: 10, start: 60, end: 60),
                    child: Column(
                      children: <Widget>[
                        AutoSizeText(
                          CaseChange.toUpperCase(Z.of(context).createPasswordSheetHeader, context),
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
                      Z.of(context).passwordWillBeRequiredToOpenParagraph.replaceAll("%1", NonTranslatable.appName),
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
                            // Create a Password Text Field
                            AppTextField(
                              topMargin: 30,
                              padding: EdgeInsetsDirectional.only(start: 16, end: 16),
                              focusNode: createPasswordFocusNode,
                              controller: createPasswordController,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              autocorrect: false,
                              onChanged: (String newText) {
                                if (passwordError != null) {
                                  setState(() {
                                    passwordError = null;
                                  });
                                }
                                if (confirmPasswordController!.text == createPasswordController!.text) {
                                  if (mounted) {
                                    setState(() {
                                      passwordsMatch = true;
                                    });
                                  }
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      passwordsMatch = false;
                                    });
                                  }
                                }
                              },
                              hintText: Z.of(context).createPasswordHint,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                color: passwordsMatch ? StateContainer.of(context).curTheme.primary : StateContainer.of(context).curTheme.text,
                                fontFamily: "NunitoSans",
                              ),
                              onSubmitted: (String text) {
                                confirmPasswordFocusNode!.requestFocus();
                              },
                            ),
                            // Confirm Password Text Field
                            AppTextField(
                              topMargin: 20,
                              padding: EdgeInsetsDirectional.only(start: 16, end: 16),
                              focusNode: confirmPasswordFocusNode,
                              controller: confirmPasswordController,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              autocorrect: false,
                              onChanged: (String newText) {
                                if (passwordError != null) {
                                  setState(() {
                                    passwordError = null;
                                  });
                                }
                                if (confirmPasswordController!.text == createPasswordController!.text) {
                                  if (mounted) {
                                    setState(() {
                                      passwordsMatch = true;
                                    });
                                  }
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      passwordsMatch = false;
                                    });
                                  }
                                }
                              },
                              hintText: Z.of(context).confirmPasswordHint,
                              keyboardType: TextInputType.text,
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
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).setPassword, Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () async {
                      await submitAndEncrypt();
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

  Future<void> submitAndEncrypt() async {
    String? seed = await sl.get<Vault>().getSeed();
    if (createPasswordController!.text.isEmpty || confirmPasswordController!.text.isEmpty) {
      if (mounted) {
        setState(() {
          passwordError = Z.of(context).passwordBlank;
        });
      }
    } else if (createPasswordController!.text != confirmPasswordController!.text) {
      if (mounted) {
        setState(() {
          passwordError = Z.of(context).passwordsDontMatch;
        });
      }
    } else if (seed == null || !NanoUtil.isValidSeed(seed)) {
      Navigator.pop(context);
      UIUtil.showSnackbar(Z.of(context).encryptionFailedError, context);
    } else {
      String encryptedSeed = NanoHelpers.byteToHex(NanoCrypt.encrypt(seed, confirmPasswordController!.text));
      await sl.get<Vault>().setSeed(encryptedSeed);
      StateContainer.of(context).setEncryptedSecret(NanoHelpers.byteToHex(NanoCrypt.encrypt(seed, await sl.get<Vault>().getSessionKey())));
      UIUtil.showSnackbar(Z.of(context).setPasswordSuccess, context);
      Navigator.pop(context);
    }
  }
}
