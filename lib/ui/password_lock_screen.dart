import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/fcm_update_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class AppPasswordLockScreen extends StatefulWidget {
  @override
  _AppPasswordLockScreenState createState() => _AppPasswordLockScreenState();
}

class _AppPasswordLockScreenState extends State<AppPasswordLockScreen> {
  FocusNode? enterPasswordFocusNode;
  TextEditingController? enterPasswordController;

  String? passwordError;

  @override
  void initState() {
    super.initState();
    enterPasswordFocusNode = FocusNode();
    enterPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: TapOutsideUnfocus(
            child: Container(
          color: StateContainer.of(context).curTheme.backgroundDark,
          width: double.infinity,
          child: SafeArea(
            minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035,
            ),
            child: Column(
              children: <Widget>[
                // Logout button
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 16, top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: StateContainer.of(context).curTheme.text15,
                          padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          // highlightColor: StateContainer.of(context).curTheme.text15,
                          // splashColor: StateContainer.of(context).curTheme.text30,
                        ),
                        onPressed: () {
                          AppDialogs.showConfirmDialog(context, CaseChange.toUpperCase(Z.of(context).warning, context),
                              Z.of(context).logoutDetail, Z.of(context).logoutAction.toUpperCase(), () {
                            // Show another confirm dialog
                            AppDialogs.showConfirmDialog(context, Z.of(context).logoutAreYouSure, Z.of(context).logoutReassurance,
                                CaseChange.toUpperCase(Z.of(context).yes, context), () {
                              // Unsubscribe from notifications
                              sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((_) {
                                FirebaseMessaging.instance.getToken().then((String? fcmToken) {
                                  EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
                                  // Delete all data
                                  sl.get<Vault>().deleteAll().then((_) {
                                    sl.get<SharedPrefsUtil>().deleteAll().then((result) {
                                      StateContainer.of(context).logOut();
                                      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                                    });
                                  });
                                });
                              });
                            });
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(AppIcons.logout, size: 16, color: StateContainer.of(context).curTheme.text),
                            Container(
                              margin: const EdgeInsetsDirectional.only(start: 4),
                              child: Text(Z.of(context).logout, style: AppStyles.textStyleLogoutButton(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
                      child: Icon(
                        AppIcons.lock,
                        size: 80,
                        color: StateContainer.of(context).curTheme.primary,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        CaseChange.toUpperCase(Z.of(context).locked, context),
                        style: AppStyles.textStyleHeaderColored(context),
                      ),
                    ),
                    Expanded(
                        child: KeyboardAvoider(
                            duration: Duration.zero,
                            autoScroll: true,
                            focusPadding: 40,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                              // Enter your password Text Field
                              AppTextField(
                                topMargin: 30,
                                padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                                focusNode: enterPasswordFocusNode,
                                controller: enterPasswordController,
                                textInputAction: TextInputAction.go,
                                autofocus: true,
                                onChanged: (String newText) {
                                  if (passwordError != null) {
                                    setState(() {
                                      passwordError = null;
                                    });
                                  }
                                },
                                onSubmitted: (String value) async {
                                  FocusScope.of(context).unfocus();
                                  await validateAndDecrypt();
                                },
                                hintText: Z.of(context).enterPasswordHint,
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.0,
                                  color: StateContainer.of(context).curTheme.primary,
                                  fontFamily: "NunitoSans",
                                ),
                              ),
                              // Error Container
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
                )),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).unlock, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () async {
                      await validateAndDecrypt();
                    }),
                  ],
                )
              ],
            ),
          ),
        )));
  }

  Future<void> validateAndDecrypt() async {
    try {
      final String decryptedSeed = NanoHelpers.byteToHex(NanoCrypt.decrypt(await sl.get<Vault>().getSeed(), enterPasswordController!.text));
      StateContainer.of(context).setEncryptedSecret(NanoHelpers.byteToHex(NanoCrypt.encrypt(decryptedSeed, await sl.get<Vault>().getSessionKey())));
      _goHome();
    } catch (e) {
      if (mounted) {
        setState(() {
          passwordError = Z.of(context).invalidPassword;
        });
      }
    }
  }

  Future<void> _goHome() async {
    if (StateContainer.of(context).wallet != null) {
      StateContainer.of(context).reconnect();
    } else {
      await NanoUtil().loginAccount(await StateContainer.of(context).getSeed(), context);
    }
    StateContainer.of(context).requestUpdate();
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    Navigator.of(context).pushNamedAndRemoveUntil('/home_transition', (Route<dynamic> route) => false, arguments: conversion);
  }
}
