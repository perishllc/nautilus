import 'package:flutter/material.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/setting_item.dart';

enum ContactsOptions { ON, OFF }

/// Represent notification on/off setting
class ContactsSetting extends SettingSelectionItem {
  ContactsOptions setting;

  ContactsSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case ContactsOptions.ON:
        return Z.of(context).onStr;
      case ContactsOptions.OFF:
      default:
        return Z.of(context).off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}