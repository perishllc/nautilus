import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/available_block_explorer.dart';
import 'package:nautilus_wallet_flutter/model/available_language.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  final LanguageSetting languageSetting;

  const AppLocalizationsDelegate(this.languageSetting);

  @override
  bool isSupported(Locale locale) {
    return languageSetting != null;
  }

  @override
  Future<AppLocalization> load(Locale locale) {
    if (languageSetting.language == AvailableLanguage.DEFAULT) {
      return AppLocalization.load(locale);
    }
    return AppLocalization.load(Locale(languageSetting.getLocaleString()));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return true;
  }
}

class NonTranslatable {
  /// -- NON-TRANSLATABLE ITEMS
  static String getBlockExplorerUrl(String? hash, AvailableBlockExplorer explorer) {
    if (explorer.explorer == AvailableBlockExplorerEnum.NANOCOMMUNITY) {
      return "https://nano.community/$hash";
    } else if (explorer.explorer == AvailableBlockExplorerEnum.NANOLOOKER) {
      return "https://nanolooker.com/block/$hash";
    } else if (explorer.explorer == AvailableBlockExplorerEnum.NANOCAFE) {
      return "https://nanocafe.cc/$hash";
    }
    return "https://nanocrawler.cc/explorer/block/$hash";
  }

  static String getAccountExplorerUrl(String? account, AvailableBlockExplorer explorer) {
    if (explorer.explorer == AvailableBlockExplorerEnum.NANOCOMMUNITY) {
      return "https://nano.community/$account";
    } else if (explorer.explorer == AvailableBlockExplorerEnum.NANOLOOKER) {
      return "https://nanolooker.com/account/$account";
    } else if (explorer.explorer == AvailableBlockExplorerEnum.NANOCAFE) {
      return "https://nanocafe.cc/$account";
    }
    return "https://nanocrawler.cc/explorer/account/$account";
  }

  static String get discordUrl {
    return "https://chat.perish.co";
  }

  static String get discord {
    return "Discord";
  }

  static String get nautilusNodeUrl {
    return "https://node.perish.co";
  }

  static String get eulaUrl {
    return "https://perish.co/nautilus/eula.html";
  }

  static String get privacyUrl {
    return "https://perish.co/nautilus/privacy.html";
  }

  static String get nanocafe {
    return "nanocafe.cc";
  }

  static String get redeemforme {
    return "redeemfor.me";
  }

  static String get nanswap {
    return "nanswap.com";
  }

  static String get promoLink {
    return "https://perish.co/promo";
  }

  static String get genericStoreLink {
    return "https://nautiluswallet.app";
  }

  static String get hcaptchaUrl {
    return "https://perish.co/hcaptcha";
  }

  static String get nautilus {
    return "Nautilus";
  }

  static String get nano {
    return "Nano";
  }

  static String get monero {
    return "Monero";
  }
}
