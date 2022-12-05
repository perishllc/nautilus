import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/bus/fcm_update_event.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/authentication_method.dart';
import 'package:nautilus_wallet_flutter/model/vault.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/util/routes.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/security.dart';
import 'package:nautilus_wallet_flutter/util/biometrics.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:nautilus_wallet_flutter/util/sharedprefsutil.dart';

class AppLockScreen extends StatefulWidget {
  @override
  _AppLockScreenState createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _showUnlockButton = false;
  bool _showLock = false;
  bool _lockedOut = true;
  String _countDownTxt = "";

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

  Widget _buildPinScreen(BuildContext context, String? expectedPin, [String? plausiblePin]) {
    return PinScreen(PinOverlayType.ENTER_PIN,
        isUnlockAction: true,
        expectedPin: expectedPin,
        plausiblePin: plausiblePin,
        description: Z.of(context).unlockPin,
        pinScreenBackgroundColor: StateContainer.of(context).curTheme.backgroundDark);
  }

  String _formatCountDisplay(int count) {
    if (count <= 60) {
      // Seconds only
      String secondsStr = count.toString();
      if (count < 10) {
        secondsStr = "0$secondsStr";
      }
      return "00:$secondsStr";
    } else if (count > 60 && count <= 3600) {
      // Minutes:Seconds
      String minutesStr = "";
      final int minutes = count ~/ 60;
      if (minutes < 10) {
        minutesStr = "0$minutes";
      } else {
        minutesStr = minutes.toString();
      }
      String secondsStr = "";
      final int seconds = count % 60;
      if (seconds < 10) {
        secondsStr = "0$seconds";
      } else {
        secondsStr = seconds.toString();
      }
      return "$minutesStr:$secondsStr";
    } else {
      // Hours:Minutes:Seconds
      String hoursStr = "";
      final int hours = count ~/ 3600;
      if (hours < 10) {
        hoursStr = "0$hours";
      } else {
        hoursStr = hours.toString();
      }
      count = count % 3600;
      String minutesStr = "";
      final int minutes = count ~/ 60;
      if (minutes < 10) {
        minutesStr = "0$minutes";
      } else {
        minutesStr = minutes.toString();
      }
      String secondsStr = "";
      final int seconds = count % 60;
      if (seconds < 10) {
        secondsStr = "0$seconds";
      } else {
        secondsStr = seconds.toString();
      }
      return "$hoursStr:$minutesStr:$secondsStr";
    }
  }

  Future<void> _runCountdown(int count) async {
    if (count >= 1) {
      if (mounted) {
        setState(() {
          _showUnlockButton = true;
          _showLock = true;
          _lockedOut = true;
          _countDownTxt = _formatCountDisplay(count);
        });
      }
      Future<void>.delayed(const Duration(seconds: 1), () {
        _runCountdown(count - 1);
      });
    } else {
      if (mounted) {
        setState(() {
          _lockedOut = false;
        });
      }
    }
  }

  Future<void> authenticateWithBiometrics() async {
    final bool authenticated = await sl.get<BiometricUtil>().authenticateWithBiometrics(context, Z.of(context).unlockBiometrics);
    if (authenticated) {
      _goHome();
    } else {
      setState(() {
        _showUnlockButton = true;
      });
    }
  }

  Future<void> authenticateWithPinOrPlausible({bool transitions = false}) async {
    final String? expectedPin = await sl.get<Vault>().getPin();
    final String? plausiblePin = await sl.get<Vault>().getPlausiblePin();
    bool auth = false;
    if (transitions) {
      auth = await Navigator.of(context).push(
            MaterialPageRoute<bool>(builder: (BuildContext context) {
              return _buildPinScreen(context, expectedPin, plausiblePin);
            }),
          ) ??
          false;
    } else {
      auth = await Navigator.of(context).push(
            NoPushTransitionRoute<bool>(builder: (BuildContext context) {
              return _buildPinScreen(context, expectedPin, plausiblePin);
            }),
          ) ??
          false;
    }
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _showUnlockButton = true;
        _showLock = true;
      });
    }
    if (auth) {
      _goHome();
    }
  }

  Future<void> _authenticate({bool transitions = false}) async {
    // Test if user is locked out
    // Get duration of lockout
    final DateTime? lockUntil = await sl.get<SharedPrefsUtil>().getLockDate();
    if (lockUntil == null) {
      await sl.get<SharedPrefsUtil>().resetLockAttempts();
    } else {
      final int countDown = lockUntil.difference(DateTime.now().toUtc()).inSeconds;
      // They're not allowed to attempt
      if (countDown > 0) {
        _runCountdown(countDown);
        return;
      }
    }
    setState(() {
      _lockedOut = false;
    });
    final AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
    final bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
    if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
      setState(() {
        _showLock = true;
        _showUnlockButton = true;
      });
      try {
        await authenticateWithBiometrics();
      } catch (e) {
        await authenticateWithPinOrPlausible(transitions: transitions);
      }
    } else {
      await authenticateWithPinOrPlausible(transitions: transitions);
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
                              // highlightColor: StateContainer.of(context).curTheme.text15,
                              // splashColor: StateContainer.of(context).curTheme.text30,
                            ),
                            onPressed: () {
                              AppDialogs.showConfirmDialog(context, CaseChange.toUpperCase(Z.of(context).warning, context),
                                  Z.of(context).logoutDetail, Z.of(context).logoutAction.toUpperCase(), () {
                                // Show another confirm dialog
                                AppDialogs.showConfirmDialog(context, Z.of(context).logoutAreYouSure,
                                    Z.of(context).logoutReassurance, CaseChange.toUpperCase(Z.of(context).yes, context), () {
                                  // Unsubscribe from notifications
                                  sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((_) {
                                    FirebaseMessaging.instance.getToken().then((String? fcmToken) {
                                      EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: fcmToken));
                                      // Delete all data
                                      sl.get<Vault>().deleteAll().then((_) {
                                        sl.get<SharedPrefsUtil>().deleteAll().then((void result) {
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
                      child: _showLock
                          ? Column(
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
                              ],
                            )
                          : const SizedBox(),
                    ),
                    if (_lockedOut)
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        margin: const EdgeInsets.symmetric(horizontal: 50),
                        child: Text(
                          Z.of(context).tooManyFailedAttempts,
                          style: AppStyles.textStyleErrorMedium(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_showUnlockButton)
                      Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              context, AppButtonType.PRIMARY, _lockedOut ? _countDownTxt : Z.of(context).unlock, Dimens.BUTTON_BOTTOM_DIMENS,
                              onPressed: () {
                            if (!_lockedOut) {
                              _authenticate(transitions: true);
                            }
                          }, disabled: _lockedOut),
                        ],
                      ),
                  ],
                ))));
  }
}
