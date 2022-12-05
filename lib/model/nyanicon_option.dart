import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/setting_item.dart';

enum NyaniconOptions { ON, OFF }

/// Represent natricon on/off setting
class NyaniconSetting extends SettingSelectionItem {
  NyaniconOptions setting;

  NyaniconSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case NyaniconOptions.ON:
        return Z.of(context).onStr;
      case NyaniconOptions.OFF:
      default:
        return Z.of(context).off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}
