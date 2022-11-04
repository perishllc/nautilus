import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/network/auth_service.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/security.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';

class IntroMagicPassword extends StatefulWidget {
  const IntroMagicPassword({this.encryptedSeed, this.identifier});
  final String? encryptedSeed;
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
                          widget.encryptedSeed == null ? AppLocalization.of(context).createAPasswordHeader : AppLocalization.of(context).enterPasswordHint,
                          maxLines: 3,
                          stepGranularity: 0.5,
                          style: AppStyles.textStyleHeaderColored(context),
                        ),
                      ),
                      // The paragraph
                      // Container(
                      //   margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 16.0),
                      //   child: AutoSizeText(
                      //     AppLocalization.of(context).passwordWillBeRequiredToOpenParagraph,
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
                                // Create a Password Text Field
                                if (widget.encryptedSeed == null)
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
                                    hintText: AppLocalization.of(context).createPasswordHint,
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
                                  hintText: widget.encryptedSeed == null
                                      ? AppLocalization.of(context).confirmPasswordHint
                                      : AppLocalization.of(context).enterPasswordHint,
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

                //A column with "Next" and "Go Back" buttons
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Next Button
                        AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).nextButton, Dimens.BUTTON_TOP_DIMENS,
                            onPressed: () async {
                          await submitAndEncrypt();
                        }),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        // Go Back Button
                        AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).goBackButton, Dimens.BUTTON_BOTTOM_DIMENS,
                            onPressed: () {
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
    if ((createPasswordController!.text.isEmpty && widget.encryptedSeed == null) || confirmPasswordController!.text.isEmpty) {
      if (mounted) {
        setState(() {
          passwordError = AppLocalization.of(context).passwordBlank;
        });
      }
      return;
    }
    if (widget.encryptedSeed == null && createPasswordController!.text != confirmPasswordController!.text) {
      if (mounted) {
        setState(() {
          passwordError = AppLocalization.of(context).passwordsDontMatch;
        });
      }
      return;
    }
    if (widget.encryptedSeed != null) {
      // final String encryptedSeed = NanoHelpers.byteToHex(NanoCrypt.encrypt(widget.seed, confirmPasswordController!.text));

      // decrypt the seed using the password:
      final String decryptedSeed = NanoHelpers.byteToHex(NanoCrypt.decrypt(widget.encryptedSeed, confirmPasswordController!.text));

      await sl.get<Vault>().setSeed(decryptedSeed);

      // re-encrypt the seed with password:
      // final String reEncryptedSeed = NanoHelpers.byteToHex(NanoCrypt.encrypt(decryptedSeed, confirmPasswordController!.text));
      // await sl.get<Vault>().setSeed(reEncryptedSeed);
      if (!mounted) return;
      // also encrypt the seed with the session key:
      // StateContainer.of(context).setEncryptedSecret(NanoHelpers.byteToHex(NanoCrypt.encrypt(decryptedSeed, await sl.get<Vault>().getSessionKey())));
      await sl.get<DBHelper>().dropAccounts();
      if (!mounted) return;
      await NanoUtil().loginAccount(decryptedSeed, context);
      if (!mounted) return;
      skipPin();
      return;
    }

    // Generate a new seed, encrypt, and upload to the seed backup endpoint:
    final String seed = NanoSeeds.generateSeed();
    final String encryptedSeed = NanoHelpers.byteToHex(NanoCrypt.encrypt(seed, confirmPasswordController!.text));
    // await sl.get<Vault>().setSeed(encryptedSeed);
    await sl.get<Vault>().setSeed(seed);
    if (!mounted) return;
    // Also encrypt it with the session key, so user doesnt need password to sign blocks within the app
    // StateContainer.of(context).setEncryptedSecret(NanoHelpers.byteToHex(NanoCrypt.encrypt(seed, await sl.get<Vault>().getSessionKey())));

    if (!mounted) return;
    // Update wallet
    await NanoUtil().loginAccount(await StateContainer.of(context).getSeed(), context);
    if (!mounted) return;
    // upload encrypted seed to seed backup endpoint:
    await sl.get<AuthService>().setEncryptedSeed(widget.identifier!, encryptedSeed);
    skipPin();
  }

  Future<void> skipPin() async {
    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
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
}
