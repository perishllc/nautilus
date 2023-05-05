import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

class Sha {
  /// Calculates the sha256 hash from the given buffers.
  ///
  /// @param {List<Uint8List>} byte arrays
  /// @returns {Uint8List}
  static Uint8List sha256(List<Uint8List> byteArrays) {
    Digest digest = Digest("SHA-256");
    Uint8List hashed = Uint8List(32);
    for (final Uint8List byteArray in byteArrays) {
      digest.update(byteArray, 0, byteArray.lengthInBytes);
    }
    digest.doFinal(hashed, 0);
    return hashed;
  }
}
