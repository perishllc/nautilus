import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/model/setting_item.dart';

enum AvailableBlockExplorerEnum { NANOCOMMUNITY, NANOLOOKER, NANOCRAWLER, NANOCAFE  }

/// Represent the available authentication methods our app supports
class AvailableBlockExplorer extends SettingSelectionItem {
  AvailableBlockExplorerEnum explorer;

  AvailableBlockExplorer(this.explorer);

  String getDisplayName(BuildContext context) {
    switch (explorer) {
      case AvailableBlockExplorerEnum.NANOCRAWLER:
        return "nanocrawler.cc";
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
