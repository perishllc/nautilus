import 'package:flutter/material.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/setting_item.dart';

enum AuthMethod { PIN, BIOMETRICS, NONE }

/// Represent the available authentication methods our app supports
class AuthenticationMethod extends SettingSelectionItem {
  AuthMethod method;

  AuthenticationMethod(this.method);

  String getDisplayName(BuildContext context) {
    switch (method) {
      case AuthMethod.BIOMETRICS:
        return Z.of(context).biometricsMethod;
      case AuthMethod.PIN:
        return Z.of(context).pinMethod;
      case AuthMethod.NONE:
        return Z.of(context).noneMethod;
      default:
        return Z.of(context).pinMethod;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return method.index;
  }
}