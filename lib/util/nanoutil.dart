import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import "package:ed25519_hd_key/ed25519_hd_key.dart";
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:libcrypto/libcrypto.dart';
import 'package:nanoutil/nanoutil.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/db/account.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/service_locator.dart';

class NanoUtilities {

  Future<void> loginAccount(String? seed, BuildContext context, {int offset = 0, bool updateWallet = true}) async {
    Account? selectedAcct = await sl.get<DBHelper>().getSelectedAccount(seed);
    if (selectedAcct == null) {
      selectedAcct = Account(index: offset, lastAccess: 0, name: Z.of(context).defaultAccountName, selected: true);
      await sl.get<DBHelper>().saveAccount(selectedAcct);
    }
    if (updateWallet) {
      StateContainer.of(context).updateWallet(account: selectedAcct);
    }
  }

  static NanoDerivationType derivationMethodToType(String derivationMethod) {
    if (derivationMethod == "standard") {
      return NanoDerivationType.STANDARD;
    } else if (derivationMethod == "hd") {
      return NanoDerivationType.HD;
    } else {
      throw Exception("Unknown derivation method");
    }
  }
}
