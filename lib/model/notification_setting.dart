import 'package:flutter/material.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/setting_item.dart';

enum NotificationOptions { ON, OFF }

/// Represent notification on/off setting
class NotificationSetting extends SettingSelectionItem {
  NotificationOptions setting;

  NotificationSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case NotificationOptions.ON:
        return Z.of(context).onStr;
      case NotificationOptions.OFF:
      default:
        return Z.of(context).off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}