import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/setting_item.dart';

enum UnlockOption { YES, NO }

/// Represent authenticate to open setting
class UnlockSetting extends SettingSelectionItem {
  UnlockOption setting;

  UnlockSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case UnlockOption.YES:
        return Z.of(context).yes;
      case UnlockOption.NO:
      default:
        return Z.of(context).no;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}