import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';

class NanoUtil {
  static String seedToPrivate(String seed, int index) {
    return NanoKeys.seedToPrivate(seed, index);
  }

  static String seedToAddress(String seed, int index) {
    return NanoAccounts.createAccount(NanoAccountType.NANO, NanoKeys.createPublicKey(seedToPrivate(seed, index)));
  }

  Future<void> loginAccount(String? seed, BuildContext context, {int offset = 0}) async {
    Account? selectedAcct = await sl.get<DBHelper>().getSelectedAccount(seed);
    if (selectedAcct == null) {
      selectedAcct = Account(index: offset, lastAccess: 0, name: AppLocalization.of(context).defaultAccountName, selected: true);
      await sl.get<DBHelper>().saveAccount(selectedAcct);
    }
    StateContainer.of(context).updateWallet(account: selectedAcct);
  }

  static bool isValidBip39Seed(String seed) {
    // Ensure seed is 64 characters long
    if (seed == null || seed.length != 128) {
      return false;
    }
    // Ensure seed only contains hex characters, 0-9;A-F
    return NanoHelpers.isHexString(seed);
  }
}
