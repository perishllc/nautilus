import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/available_block_explorer.dart';
import 'package:wallet_flutter/model/available_language.dart';

class ZsDelegate extends LocalizationsDelegate<Z> {
  const ZsDelegate(this.languageSetting);

  final LanguageSetting languageSetting;

  @override
  bool isSupported(Locale locale) {
    return languageSetting != null;
  }

  @override
  Future<Z> load(Locale locale) {
    if (languageSetting.language == AvailableLanguage.DEFAULT) {
      return Z.load(locale);
    }
    return Z.load(Locale(languageSetting.getLocaleString()));
  }

  @override
  bool shouldReload(LocalizationsDelegate<Z> old) {
    return true;
  }
}

class NonTranslatable {
  /// -- NON-TRANSLATABLE ITEMS
  static String getBlockExplorerUrl(String? hash, AvailableBlockExplorer explorer) {
    switch (explorer.explorer) {
      case AvailableBlockExplorerEnum.NANOCOMMUNITY:
        return "https://nano.community/$hash";
      case AvailableBlockExplorerEnum.NANOLOOKER:
        return "https://nanolooker.com/block/$hash";
      case AvailableBlockExplorerEnum.BLOCKLATTICE:
        return "https://blocklattice.io/block/$hash";
      case AvailableBlockExplorerEnum.NANEXPLORER:
        return "https://nanexplorer.com/explorer/block/$hash";
      case AvailableBlockExplorerEnum.NANOCAFE:
        return "https://nanocafe.cc/$hash";
      case AvailableBlockExplorerEnum.NANOBROWSE:
      default:
        return "https://nanobrowse.com/block/$hash";
    }
  }

  static String getAccountExplorerUrl(String? account, AvailableBlockExplorer explorer) {
    switch (explorer.explorer) {
      case AvailableBlockExplorerEnum.NANOCOMMUNITY:
        return "https://nano.community/$account";
      case AvailableBlockExplorerEnum.NANOLOOKER:
        return "https://nanolooker.com/account/$account";
      case AvailableBlockExplorerEnum.NANOLOOKER:
        return "https://nanolooker.com/account/$account";
      case AvailableBlockExplorerEnum.BLOCKLATTICE:
        return "https://blocklattice.io/account/$account";
      case AvailableBlockExplorerEnum.NANEXPLORER:
        return "https://nanexplorer.com/explorer/account/$account";
      case AvailableBlockExplorerEnum.NANOCAFE:
        return "https://nanocafe.cc/$account";
      case AvailableBlockExplorerEnum.NANOBROWSE:
      default:
        return "https://nanobrowse.com/account/$account";
    }
  }

  static String get discordUrl {
    return "https://chat.perish.co";
  }

  static String get discord {
    return "Discord";
  }

  static String get nautilusNodeUrl {
    return "https://node.nautilus.io";
  }

  static String get eulaUrl {
    return "https://nautilus.io/eula";
  }

  static String get privacyUrl {
    return "https://nautilus.io/privacy";
  }

  static String get nanocafe {
    return "nanocafe.cc";
  }

  static String get redeemforme {
    return "redeemfor.me";
  }

  static String get luckynano {
    return "luckynano.com";
  }

  static String get playnano {
    return "playnano.online";
  }

  static String get nanswap {
    return "nanswap.com";
  }

  static String get onramper {
    return "onramper";
  }

  static String get cryptovision {
    return "cryptovision.live";
  }

  static String get wenano {
    return "WeNano";
  }

  static String get promoLink {
    return "https://nautilus.io/promo";
  }

  static String get genericStoreLink {
    return "https://nautilus.io";
  }

  static String get hcaptchaUrl {
    return "https://nautilus.io/hcaptcha";
  }

  static String get appName {
    return "Nautilus";
  }

  static String currencyName = "Nano";
  static String currencyPrefix = "nano_";
  static String currencyUriPrefix = "nano";
  static int accountType = 1;

  static String get nano {
    return "Nano";
  }

  static String get monero {
    return "Monero";
  }

  static String get perseeve {
    return "Perseeve";
  }
}
