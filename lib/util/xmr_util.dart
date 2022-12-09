import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:wallet_flutter/util/blake2b.dart';

class XmrUtil {
  static String changeEndianness(String input) {
    String output = "";
    for (int i = 0; i < input.length; i += 2) {
      output = input.substring(i, i + 2) + output;
    }
    return output;
  }

  static String sc_reduce32(String input) {
    final BigInt l = BigInt.parse("7237005577332262213973186563042994240857116359379907606001950938285454250989");
    String s = input;
    s = changeEndianness(s);
    final BigInt seed = BigInt.parse("0x$s");
    String p1 = (seed % l).toRadixString(16);
    if (p1.length == 63) {
      p1 = "0$p1";
    }
    return changeEndianness(p1.toUpperCase());
  }

  static String seedToXmrSecretKey(String seed) {
    final String hashedSeed = NanoHelpers.byteToHex(blake2b(NanoHelpers.hexToBytes(seed))).substring(0, 64);
    final String reduced = sc_reduce32(hashedSeed);
    return reduced;
  }
}
