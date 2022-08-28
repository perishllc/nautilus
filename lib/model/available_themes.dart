import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/themes.dart';
import 'package:nautilus_wallet_flutter/model/setting_item.dart';

enum ThemeOptions { NAUTILUS, TITANIUM, INDIUM, NEPTUNIUM, THORIUM, CARBON, PURPELIUM, MONOCHROME, MIDNIGHT, PERISHABLE }

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
      // case ThemeOptions.NYANO:
      //   return "Nyano";
      case ThemeOptions.THORIUM:
        return "Thorium";
      case ThemeOptions.NEPTUNIUM:
        return "Neptunium";
      case ThemeOptions.INDIUM:
        return "Indium";
      case ThemeOptions.TITANIUM:
        return "Titanium";
      case ThemeOptions.MONOCHROME:
        return "Monochrome";
      case ThemeOptions.MIDNIGHT:
        return "Midnight";
      case ThemeOptions.PERISHABLE:
        return "Perishable";
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
      // case ThemeOptions.NYANO:
      //   return NyanoTheme();
      case ThemeOptions.THORIUM:
        return ThoriumTheme();
      case ThemeOptions.NEPTUNIUM:
        return NeptuniumTheme();
      case ThemeOptions.INDIUM:
        return IndiumTheme();
      case ThemeOptions.TITANIUM:
        return TitaniumTheme();
      case ThemeOptions.MONOCHROME:
        return MonochromeTheme();
      case ThemeOptions.PERISHABLE:
        return PerishableTheme();
      case ThemeOptions.MIDNIGHT:
        return MidnightTheme();
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
