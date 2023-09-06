import 'package:flutter/material.dart';
import 'package:wallet_flutter/model/setting_item.dart';

enum AvailableBlockExplorerEnum { NANOCOMMUNITY, NANOLOOKER, NANOBROWSE, NANOCAFE  }

/// Represent the available authentication methods our app supports
class AvailableBlockExplorer extends SettingSelectionItem {

  AvailableBlockExplorer(this.explorer);
  AvailableBlockExplorerEnum explorer;

  @override
  String getDisplayName(BuildContext context) {
    switch (explorer) {
      case AvailableBlockExplorerEnum.NANOBROWSE:
        return "nanobrowse.com";
      case AvailableBlockExplorerEnum.NANOLOOKER:
        return "nanolooker.com";
      case AvailableBlockExplorerEnum.NANOCAFE:
        return "nanocafe.cc";
      case AvailableBlockExplorerEnum.NANOCOMMUNITY:
        return "nano.community";
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return explorer.index;
  }
}
