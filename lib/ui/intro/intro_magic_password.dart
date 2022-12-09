import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/auth_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/blake2b.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:web3dart/crypto.dart';

class IntroMagicPassword extends StatefulWidget {
  const IntroMagicPassword({this.entryExists = false, this.identifier});
  final bool entryExists;
  final String? identifier;

  @override
  _IntroMagicPasswordState createState() => _IntroMagicPasswordState();
}

class _IntroMagicPasswordState extends State<IntroMagicPassword> {
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
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        body: TapOutsideUnfocus(
            child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
            minimum: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
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
                          !widget.entryExists
                              ? Z.of(context).createAPasswordHeader
                              : Z.of(context).enterPasswordHint,
                          maxLines: 3,
                          stepGranularity: 0.5,
                          style: AppStyles.textStyleHeaderColored(context),
                        ),
                      ),
                      // The paragraph
                      Container(
                        margin: EdgeInsetsDirectional.only(
                            start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 16.0),
                        child: AutoSizeText(
                          Z.of(context).passwordDisclaimer,
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
                                if (!widget.entryExists)
                                  AppTextField(
                                    topMargin: 30,
                                    padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
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
                                      color: passwordsMatch
                                          ? StateContainer.of(context).curTheme.primary
                                          : StateContainer.of(context).curTheme.text,
                                      fontFamily: "NunitoSans",
                                    ),
                                    onSubmitted: (String text) {
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
                                  hintText: !widget.entryExists
                                      ? Z.of(context).confirmPasswordHint
                                      : Z.of(context).enterPasswordHint,
                                  keyboardType: TextInputType.text,
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
                                  margin: EdgeInsetsDirectional.only(
                                      top: 8,
                                      start: smallScreen(context) ? 30 : 40,
                                      end: smallScreen(context) ? 30 : 40),
                                  child: Text(passwordError == null ? "" : passwordError!,
                                      textAlign: TextAlign.center,
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
                        AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY,
                            widget.entryExists
                                ? Z.of(context).loginButton
                                : Z.of(context).registerButton,
                            Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                          await submitAndEncrypt();
                        }),
                      ],
                    ),
                    if (widget.entryExists)
                      Row(
                        children: <Widget>[
                          // Next Button
                          AppButton.buildAppButton(
                              context,
                              AppButtonType.PRIMARY_OUTLINE,
                              Z.of(context).resetAccountButton,
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                            if (!checkPasswordRequirements()) {
                              return;
                            }
                            AppDialogs.showConfirmDialog(
                              context,
                              Z.of(context).logoutAreYouSure,
                              Z.of(context).resetAccountParagraph,
                              Z.of(context).imSure,
                              () async {
                                // get the encrypted seed from the auth-service:
                                final String hashedPassword = NanoHelpers.byteToHex(
                                    blake2b(Uint8List.fromList(utf8.encode(confirmPasswordController!.text))));
                                final String fullIdentifier = "${widget.identifier}:$hashedPassword";
                                String? encryptedSeed = await sl.get<AuthService>().getEncryptedSeed(fullIdentifier);
                                // final String encryptedSeed = NanoHelpers.byteToHex(NanoCrypt.encrypt(widget.seed, confirmPasswordController!.text));

                                if (encryptedSeed == null) {
                                  // delete the account if it exists:
                                  await sl.get<AuthService>().deleteEncryptedSeed(fullIdentifier);
                                }

                                // Generate a new seed, encrypt, and upload to the seed backup endpoint:
                                final String seed = NanoSeeds.generateSeed();
                                encryptedSeed =
                                    NanoHelpers.byteToHex(NanoCrypt.encrypt(seed, confirmPasswordController!.text));
                                await sl.get<Vault>().setSeed(seed);
                                if (!mounted) return;
                                // Update wallet
                                await NanoUtil().loginAccount(await StateContainer.of(context).getSeed(), context);
                                if (!mounted) return;
                                // upload encrypted seed to seed backup endpoint:

                                // create the following entry in the database:
                                // {
                                //   identifier: "${identifier}${hashedPassword}",
                                //   encrypted_seed: encryptedSeed,
                                // }
                                await sl.get<AuthService>().setEncryptedSeed(fullIdentifier, encryptedSeed);
                                skipPin();
                              },
                              cancelText: Z.of(context).goBackButton,
                              cancelAction: () {
                                return;
                              },
                            );
                          }),
                        ],
                      )
                    else
                      Row(
                        children: <Widget>[
                          // Go Back Button
                          AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                              Z.of(context).goBackButton, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                            Navigator.of(context).pop();
                          }),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        )));
  }

  Future<void> submitAndEncrypt() async {
    if ((createPasswordController!.text.isEmpty && !widget.entryExists) || confirmPasswordController!.text.isEmpty) {
      if (mounted) {
        setState(() {
          passwordError = Z.of(context).passwordBlank;
        });
      }
      return;
    }
    if (!widget.entryExists && createPasswordController!.text != confirmPasswordController!.text) {
      if (mounted) {
        setState(() {
          passwordError = Z.of(context).passwordsDontMatch;
        });
      }
      return;
    }
    if (widget.entryExists) {
      // get the encrypted seed from the auth-service:
      final String hashedPassword =
          NanoHelpers.byteToHex(blake2b(Uint8List.fromList(utf8.encode(confirmPasswordController!.text))));
      final String fullIdentifier = "${widget.identifier!}:$hashedPassword";
      final String? encryptedSeed = await sl.get<AuthService>().getEncryptedSeed(fullIdentifier);
      // final String encryptedSeed = NanoHelpers.byteToHex(NanoCrypt.encrypt(widget.seed, confirmPasswordController!.text));

      if (encryptedSeed == null) {
        if (mounted) {
          setState(() {
            passwordError = Z.of(context).passwordIncorrect;
          });
        }
        return;
      }

      // decrypt the seed using the password:
      String? decryptedSeed;
      try {
        decryptedSeed = NanoHelpers.byteToHex(NanoCrypt.decrypt(encryptedSeed, confirmPasswordController!.text));

        await sl.get<Vault>().setSeed(decryptedSeed);
      } catch (error) {
        if (mounted) {
          setState(() {
            passwordError = Z.of(context).passwordIncorrect;
          });
        }
        return;
      }

      // re-encrypt the seed with password:
      if (!mounted) return;
      // also encrypt the seed with the session key:
      await sl.get<DBHelper>().dropAccounts();
      if (!mounted) return;
      await NanoUtil().loginAccount(decryptedSeed, context);
      if (!mounted) return;
      skipPin();
      return;
    } else {
      if (!mounted) return;
      // password requirements:
      if (!checkPasswordRequirements()) {
        return;
      }
    }

    if (!mounted) return;

    final bool noSeedToImport = await AppDialogs.waitableConfirmDialog(
      context,
      Z.of(context).doYouHaveSeedHeader,
      Z.of(context).doYouHaveSeedBody,
      Z.of(context).continueButton,
      cancelText: Z.of(context).haveSeedToImport,
      barrierDismissible: false,
    );

    final String hashedPassword =
        NanoHelpers.byteToHex(blake2b(Uint8List.fromList(utf8.encode(confirmPasswordController!.text))));
    final String fullIdentifier = "${widget.identifier}:$hashedPassword";

    if (!noSeedToImport) {
      Navigator.of(context).pushNamed("/intro_import",
          arguments: <String, String>{"fullIdentifier": fullIdentifier, "password": confirmPasswordController!.text});
      return;
    }

    // Generate a new seed, encrypt, and upload to the seed backup endpoint:
    final String seed = NanoSeeds.generateSeed();
    final String encryptedSeed = NanoHelpers.byteToHex(NanoCrypt.encrypt(seed, confirmPasswordController!.text));
    await sl.get<Vault>().setSeed(seed);
    if (!mounted) return;
    // Update wallet
    await NanoUtil().loginAccount(await StateContainer.of(context).getSeed(), context);
    if (!mounted) return;
    // upload encrypted seed to seed backup endpoint:

    // create the following entry in the database:
    // {
    //   identifier: "${identifier}${hashedPassword}",
    //   encrypted_seed: encryptedSeed,
    // }
    await sl.get<AuthService>().setEncryptedSeed(fullIdentifier, encryptedSeed);
    skipPin();
  }

  Future<void> skipPin() async {
    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<Vault>().writePin("000000");
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: conversion);
  }

  Future<void> _pinEnteredCallback(String pin) async {
    // final String? pin = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
    //   return PinScreen(
    //     PinOverlayType.NEW_PIN,
    //   );
    // }));
    // if (pin != null && pin.length > 5) {
    //   _pinEnteredCallback(pin);
    // }
    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<Vault>().writePin(pin);
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: conversion);
  }

  bool checkPasswordRequirements() {
    print(confirmPasswordController!.text);
    // password must be at least 8 characters:
    if (confirmPasswordController!.text.length < 8) {
      setState(() {
        passwordError = Z.of(context).passwordTooShort;
      });
      return false;
    }

    // make sure password contains a number:
    if (!confirmPasswordController!.text.contains(RegExp(r"[0-9]"))) {
      setState(() {
        passwordError = Z.of(context).passwordNumber;
      });
      return false;
    }

    // make sure password contains an uppercase and lowercase letter:
    if (!confirmPasswordController!.text.contains(RegExp(r"[a-z]")) ||
        !confirmPasswordController!.text.contains(RegExp(r"[A-Z]"))) {
      setState(() {
        passwordError = Z.of(context).passwordCapitalLetter;
      });
      return false;
    }

    return true;
  }
}
