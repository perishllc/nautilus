import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:wallet_flutter/util/blake2b.dart';
import 'package:x25519/x25519.dart';

String generateNonce(int length) {
  String result = ""; // resulting nonce
  const String chars = "ABCDEF1234567890"; // hex characters
  final Random rng = Random.secure();
  // length is doubled because it takes 2 characters to represent a byte
  for (int i = 0; i < (length * 2); i++) {
    result += chars[rng.nextInt(chars.length)];
  }
  return result;
}

Uint8List convertEd25519SecretKeyToCurve25519(Uint8List sk) {
  final Uint8List o = Uint8List(32);

  final Uint8List d = blake2b(sk);
  d[0] &= 248;
  d[31] &= 127;
  d[31] |= 64;

  for (int i = 0; i < 32; i++) {
    o[i] = d[i];
  }
  return o;
}

Uint8List encodeString(String source) {
  // String (Dart uses UTF-16) to bytes
  final List<int> list = [];
  source.runes.forEach((int rune) {
    if (rune >= 0x10000) {
      rune -= 0x10000;
      final int firstWord = (rune >> 10) + 0xD800;
      list.add(firstWord >> 8);
      list.add(firstWord & 0xFF);
      final int secondWord = (rune & 0x3FF) + 0xDC00;
      list.add(secondWord >> 8);
      list.add(secondWord & 0xFF);
    } else {
      list.add(rune >> 8);
      list.add(rune & 0xFF);
    }
  });
  final Uint8List bytes = Uint8List.fromList(list);
  return bytes;
}

String decodeString(Uint8List bytes) {
  // Bytes to UTF-16 string
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < bytes.length;) {
    final int firstWord = (bytes[i] << 8) + bytes[i + 1];
    if (0xD800 <= firstWord && firstWord <= 0xDBFF) {
      final int secondWord = (bytes[i + 2] << 8) + bytes[i + 3];
      buffer.writeCharCode(((firstWord - 0xD800) << 10) + (secondWord - 0xDC00) + 0x10000);
      i += 4;
    } else {
      buffer.writeCharCode(firstWord);
      i += 2;
    }
  }

  return buffer.toString();
}

class Box {
  static const int NONCE_LENGTH = 24;

  static String encrypt(String message, String address, String privateKey) {
    final String publicKey = NanoAccounts.extractPublicKey(address);

    final Uint8List convertedPublicKey = Sodium.cryptoSignEd25519PkToCurve25519(NanoHelpers.hexToBytes(publicKey));
    final Uint8List convertedPrivateKey = convertEd25519SecretKeyToCurve25519(NanoHelpers.hexToBytes(privateKey));

    final Uint8List aliceSharedKey = X25519(convertedPrivateKey, convertedPublicKey);

    final Key key = Key(aliceSharedKey);
    final IV iv = IV.fromLength(16);

    final Encrypter encrypter = Encrypter(AES(key));

    final Encrypted encrypted = encrypter.encrypt(message, iv: iv);

    return encrypted.base64;
  }

  static String decrypt(String encrypted, String address, String privateKey) {
    final String publicKey = NanoAccounts.extractPublicKey(address);

    final Uint8List convertedPublicKey = Sodium.cryptoSignEd25519PkToCurve25519(NanoHelpers.hexToBytes(publicKey));
    final Uint8List convertedPrivateKey = convertEd25519SecretKeyToCurve25519(NanoHelpers.hexToBytes(privateKey));

    final Uint8List bobSharedKey = X25519(convertedPrivateKey, convertedPublicKey);
    final Key key = Key(bobSharedKey);
    final Encrypter encrypter = Encrypter(AES(key));
    final IV iv = IV.fromLength(16);
    final String decrypted = encrypter.decrypt(Encrypted.fromBase64(encrypted), iv: iv);

    return decrypted;
  }
}
