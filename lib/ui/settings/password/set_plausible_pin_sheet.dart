import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class SetPlausiblePinSheet extends StatefulWidget {
  _SetPlausiblePinSheetState createState() => _SetPlausiblePinSheetState();
}

class _SetPlausiblePinSheetState extends State<SetPlausiblePinSheet> {
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
            Handlebars.horizontal(context),
            // The main widget that holds the header, text fields, and submit button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // The header
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: 10, start: 10, end: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 60,
                          height: 60,
                        ),
                        Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            CaseChange.toUpperCase(Z.of(context).setPin, context),
                            style: AppStyles.textStyleHeader(context),
                            minFontSize: 12,
                            stepGranularity: 0.1,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          height: 60,
                          // padding: const EdgeInsets.only(top: 25, right: 20),
                          child: AppDialogs.infoButton(
                            context,
                            () {
                              AppDialogs.showInfoDialog(
                                context,
                                Z.of(context).plausibleInfoHeader,
                                Z.of(context).plausibleSheetInfo,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // The paragraph
                  Container(
                    margin: EdgeInsetsDirectional.only(
                        start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 16.0),
                    child: AutoSizeText(
                      Z.of(context).plausibleDeniabilityParagraph,
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
                              padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                              focusNode: createPasswordFocusNode,
                              controller: createPasswordController,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [LengthLimitingTextInputFormatter(6)],
                              keyboardType: TextInputType.number,
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
                              hintText: Z.of(context).createPinHint,
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
                              onSubmitted: (text) {
                                confirmPasswordFocusNode!.requestFocus();
                              },
                            ),
                            // Confirm Password Text Field
                            AppTextField(
                              topMargin: 20,
                              padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                              focusNode: confirmPasswordFocusNode,
                              controller: confirmPasswordController,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [LengthLimitingTextInputFormatter(6)],
                              keyboardType: TextInputType.number,
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
                              hintText: Z.of(context).confirmPinHint,
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
                        context, AppButtonType.PRIMARY, Z.of(context).setPin, Dimens.BUTTON_TOP_DIMENS,
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
    final String? seed = await sl.get<Vault>().getSeed();
    final String? currentPin = await sl.get<Vault>().getPin();
    if (!mounted) return;
    if (createPasswordController!.text.isEmpty || confirmPasswordController!.text.isEmpty) {
      setState(() {
        passwordError = Z.of(context).pinBlank;
      });
    } else if (createPasswordController!.text != confirmPasswordController!.text) {
      setState(() {
        passwordError = Z.of(context).pinsDontMatch;
      });
    } else if (currentPin != null && currentPin.isNotEmpty && currentPin == confirmPasswordController!.text) {
      // prevent the user from setting the plausible pin to the same thing as their real pin:
      setState(() {
        passwordError = Z.of(context).invalidPin;
      });
    } else {
      await sl.get<Vault>().writePlausiblePin(confirmPasswordController!.text);
      if (!mounted) return;
      UIUtil.showSnackbar(Z.of(context).setPinSuccess, context);
      Navigator.pop(context);
    }
  }
}
