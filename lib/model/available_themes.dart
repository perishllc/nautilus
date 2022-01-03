import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/themes.dart';
import 'package:nautilus_wallet_flutter/model/setting_item.dart';

enum ThemeOptions { NAUTILUS, TITANIUM, INDIUM, NEPTUNIUM, THORIUM, CARBON, PURPELIUM, NYAN }

/// Represent notification on/off setting
class ThemeSetting extends SettingSelectionItem {
  ThemeOptions theme;

  ThemeSetting(this.theme);

  String getDisplayName(BuildContext context) {
    switch (theme) {
      case ThemeOptions.CARBON:
        return "Carbon";
      case ThemeOptions.PURPELIUM:
        return "Purpelium";
      case ThemeOptions.NYAN:
        return "Nyan";
      case ThemeOptions.THORIUM:
        return "Thorium";
      case ThemeOptions.NEPTUNIUM:
        return "Neptunium";
      case ThemeOptions.INDIUM:
        return "Indium";
      case ThemeOptions.TITANIUM:
        return "Titanium";
      case ThemeOptions.NAUTILUS:
      default:
        return "Nautilus";
    }
  }

  BaseTheme getTheme() {
    switch (theme) {
      case ThemeOptions.CARBON:
        return CarbonTheme();
      case ThemeOptions.PURPELIUM:
        return PurpeliumTheme();
      case ThemeOptions.NYAN:
        return NyanTheme();
      case ThemeOptions.THORIUM:
        return ThoriumTheme();
      case ThemeOptions.NEPTUNIUM:
        return NeptuniumTheme();
      case ThemeOptions.INDIUM:
        return IndiumTheme();
      case ThemeOptions.TITANIUM:
        return TitaniumTheme();
      case ThemeOptions.NAUTILUS:
      default:
        return NautilusTheme();
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return theme.index;
  }
}
