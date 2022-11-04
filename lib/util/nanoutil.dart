import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:convert/convert.dart';
import "package:ed25519_hd_key/ed25519_hd_key.dart";

class NanoUtil {
  static String seedToPrivate(String seed, int index) {
    // return NanoKeys.seedToPrivate(seed, index);
    return NanoHelpers.byteToHex(Ed25519Blake2b.derivePrivkey(NanoHelpers.hexToBytes(seed), index)!).toUpperCase();
  }

  static String createPublicKey(String privateKey) {
    return NanoHelpers.byteToHex(Ed25519Blake2b.getPubkey(NanoHelpers.hexToBytes(privateKey))!);
  }

  static String seedToAddress(String seed, int index) {
    // return NanoAccounts.createAccount(NanoAccountType.NANO, NanoKeys.createPublicKey(seedToPrivate(seed, index)));
    return NanoAccounts.createAccount(NanoAccountType.NANO, createPublicKey(seedToPrivate(seed, index)));
  }

  static String privateKeyToPublicAddress(String privateKey) {
    // return NanoAccounts.createAccount(NanoAccountType.NANO, NanoKeys.createPublicKey(privateKey));
    return NanoAccounts.createAccount(NanoAccountType.NANO, createPublicKey(privateKey));
  }

  // BIP39 VERSIONS:
  static bool isValidSeed(String seed) {
    // Ensure seed is 64 or 128 characters long
    if (seed == null || (seed.length != 64 && seed.length != 128)) {
      return false;
    }
    // Ensure seed only contains hex characters, 0-9;A-F
    return NanoHelpers.isHexString(seed);
  }

  /// Convert a 24-word mnemonic word list to a nano seed
  static Future<String> mnemonicListToSeed(List<String> words) async {
    if (words.length != 24) {
      throw Exception('Expected a 24-word list, got a ${words.length} list');
    }

    // // Constructs a Mnemonic from Sentence/Phrase
    final Mnemonic mnemonic3 = Mnemonic.fromSentence(words.join(' '), Language.english);
    // print(hex.encode(mnemonic3.entropy));
    final String seed = hex.encode(mnemonic3.entropy);

    KeyData master = await ED25519_HD_KEY.getMasterKeyFromSeed(mnemonic3.entropy);

    print("##########");

    print(hex.encode(master.key)); // 171cb88b1b3c1db25add599712e36245d75bc65a1a5c9e18d76f9f2b1eab4
    print(hex.encode(master.chainCode));

    KeyData data = await ED25519_HD_KEY.derivePath("m/44'/165'/0'", mnemonic3.entropy);
    print(hex.encode(data.key));

    print(seed);

    return seed;
    // return "";
    // return bip39.mnemonicToEntropy(words.join(' ')).toUpperCase();
  }

  // static String seedToPrivateBip39(String seed, int index) {
  //   // return NanoKeys.seedToPrivate(seed, index);
  // }

  // static String seedToAddressBip39(String seed, int index) {
  //   // return NanoAccounts.createAccount(NanoAccountType.NANO, NanoKeys.createPublicKey(seedToPrivate(seed, index)));
  // }

  Future<void> loginAccount(String? seed, BuildContext context, {int offset = 0}) async {
    Account? selectedAcct = await sl.get<DBHelper>().getSelectedAccount(seed);
    if (selectedAcct == null) {
      selectedAcct = Account(index: offset, lastAccess: 0, name: AppLocalization.of(context).defaultAccountName, selected: true);
      await sl.get<DBHelper>().saveAccount(selectedAcct);
    }
    StateContainer.of(context).updateWallet(account: selectedAcct);
  }

  static bool isValidBip39Seed(String seed) {
    // Ensure seed is 128 characters long
    if (seed == null || seed.length != 128) {
      return false;
    }
    // Ensure seed only contains hex characters, 0-9;A-F
    return NanoHelpers.isHexString(seed);
  }
}
