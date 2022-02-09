import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/setting_item.dart';

enum MinRawOptions { OFF, NYANO, TEN_NYANO, HUNDRED_NYANO, THOUSAND_NYANO, TEN_THOUSAND_NYANO, HUNDRED_THOUSAND_NYANO }

/// Represent natricon on/off setting
class MinRawSetting extends SettingSelectionItem {
  MinRawOptions setting;

  MinRawSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case MinRawOptions.OFF:
        return AppLocalization.of(context).off;
      case MinRawOptions.NYANO:
        // todo: localize;
        return '1 nyano';
      case MinRawOptions.TEN_NYANO:
        return '10 nyano';
      case MinRawOptions.HUNDRED_NYANO:
        return '100 nyano';
      case MinRawOptions.THOUSAND_NYANO:
        return '1,000 nyano';
      case MinRawOptions.TEN_THOUSAND_NYANO:
        return '10,000 nyano';
      case MinRawOptions.HUNDRED_THOUSAND_NYANO:
        return '100,000 nyano';
      default:
        return AppLocalization.of(context).off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}
