import 'dart:convert';

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
// import 'package:blake2/blake2.dart';
import 'dart:typed_data';

import 'package:nautilus_wallet_flutter/util/blake2b.dart';

import 'package:nautilus_wallet_flutter/util/curve25519.dart';

String generateNonce(int length) {
  String result = ""; // resulting nonce
  String chars = "ABCDEF1234567890"; // hex characters
  var rng = new Random.secure();
  // length is doubled because it takes 2 characters to represent a byte
  for (int i = 0; i < (length * 2); i++) {
    result += chars[rng.nextInt(chars.length)];
  }
  return result;
}

Uint8List convertEd25519SecretKeyToCurve25519(Uint8List sk) {
  Uint8List o = new Uint8List(32);

  Uint8List d = blake2b(sk);
  d[0] &= 248;
  d[31] &= 127;
  d[31] |= 64;

  for (var i = 0; i < 32; i++) {
    o[i] = d[i];
  }
  return o;
}

Uint8List encodeString(String source) {
  // String (Dart uses UTF-16) to bytes
  List<int> list = [];
  source.runes.forEach((rune) {
    if (rune >= 0x10000) {
      rune -= 0x10000;
      int firstWord = (rune >> 10) + 0xD800;
      list.add(firstWord >> 8);
      list.add(firstWord & 0xFF);
      int secondWord = (rune & 0x3FF) + 0xDC00;
      list.add(secondWord >> 8);
      list.add(secondWord & 0xFF);
    } else {
      list.add(rune >> 8);
      list.add(rune & 0xFF);
    }
  });
  Uint8List bytes = Uint8List.fromList(list);
  return bytes;
}

String decodeString(Uint8List bytes) {
  // Bytes to UTF-16 string
  StringBuffer buffer = new StringBuffer();
  for (int i = 0; i < bytes.length;) {
    int firstWord = (bytes[i] << 8) + bytes[i + 1];
    if (0xD800 <= firstWord && firstWord <= 0xDBFF) {
      int secondWord = (bytes[i + 2] << 8) + bytes[i + 3];
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
  static const NONCE_LENGTH = 24;

  static Future<String> encrypt(String message, String address, String privateKey) async {
    String publicKey = NanoAccounts.extractPublicKey(address);

    Uint8List convertedPublicKey = Sodium.cryptoSignEd25519PkToCurve25519(Sodium.hex2bin(publicKey));
    Uint8List convertedPrivateKey = convertEd25519SecretKeyToCurve25519(Sodium.hex2bin(privateKey));

    print("convertedPublicKey: ${Sodium.bin2hex(convertedPublicKey)}");
    print("convertedPrivateKey: ${Sodium.bin2hex(convertedPrivateKey)}");

    // Curve25519 curve = new Curve25519();
    // Uint8List sharedKey = curve.boxBefore(convertedPublicKey, convertedPrivateKey);
    // Map map = Map();
    // map['publicKey'] = convertedPublicKey;
    // map['secretKey'] = convertedPrivateKey;
    // print("calculating shared key");
    // Uint8List sharedKey = await compute(boxBefore, map);
    // print("sharedKey: ${Sodium.bin2hex(sharedKey)}");

    // print(encrypted.toString());
    // return encrypted.toString();

    // print("convertedSharedKey: ${Sodium.bin2hex(sharedKey)}");
    // print("pkLen: ${Sodium.hex2bin(publicKey).length}");
    // print("skLen: ${Sodium.hex2bin(privateKey).length}");

    // String constant_nonce = "42565937c3b257e4e094cc0e82eca63dd87587fcd18319f7";
    Uint8List nonce = NanoHelpers.hexToBytes(generateNonce(NONCE_LENGTH));
    // Uint8List encrypted = curve.secretbox(utf8.encode(message), nonce, sharedKey);
    Map map = Map();
    map['msg'] = encodeString(message);
    map['nonce'] = nonce;
    map['publicKey'] = convertedPublicKey;
    map['secretKey'] = convertedPrivateKey;

    Uint8List encrypted = await compute(box, map);

    var full = BytesBuilder();
    full.add(nonce);
    full.add(encrypted);
    return Sodium.bin2base64(full.toBytes());
  }

  static Future<String> decrypt(String message, String address, String privateKey) async {
    String publicKey = NanoAccounts.extractPublicKey(address);

    Uint8List convertedPublicKey = Sodium.cryptoSignEd25519PkToCurve25519(Sodium.hex2bin(publicKey));
    // Uint8List convertedPrivateKey = Sodium.cryptoSignEd25519SkToCurve25519(Sodium.hex2bin(privateKey));
    Uint8List convertedPrivateKey = convertEd25519SecretKeyToCurve25519(Sodium.hex2bin(privateKey));

    // Curve25519 curve = new Curve25519();

    // Uint8List sharedKey = oldBoxBefore(convertedPublicKey, convertedPrivateKey);

    // Map map = Map();
    // map['publicKey'] = convertedPublicKey;
    // map['secretKey'] = convertedPrivateKey;
    // print("calculating shared key");
    // Uint8List sharedKey = await compute(boxBefore, map);

    // print("sharedKey: ${Sodium.bin2hex(sharedKey)}");

    // Uint8List convertedPublicKey = new Uint8List(32);
    // Uint8List convertedPrivateKey = new Uint8List(32);
    // TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(convertedPublicKey, Sodium.hex2bin(publicKey));
    // TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(convertedPrivateKey, Sodium.hex2bin(privateKey));
    // Uint8List sharedKey = Sodium.cryptoBoxBeforenm(convertedPublicKey, convertedPrivateKey);
    // Uint8List sharedKey = X25519(convertedPublicKey, convertedPrivateKey);
    // Uint8List sharedKey = Sodium.cryptoBoxBeforenm(Sodium.hex2bin(publicKey), Sodium.hex2bin(privateKey));

    // // const decodedEncryptedMessageBytes = base64.base64ToBytes(encrypted)
    Uint8List decodedEncryptedMessageBytes = Sodium.base642bin(message);
    // Uint8List decodedEncryptedMessageBytes = utf8.encode(message);
    Uint8List nonce = decodedEncryptedMessageBytes.sublist(0, NONCE_LENGTH);
    Uint8List encryptedMessage = decodedEncryptedMessageBytes.sublist(NONCE_LENGTH, decodedEncryptedMessageBytes.length);

    // Uint8List decrypted = Sodium.cryptoBoxOpenEasy(encryptedMessage, nonce, convertedPublicKey, convertedPrivateKey);

    print(message);
    print(Sodium.bin2hex(nonce));
    print(Sodium.bin2hex(encryptedMessage));

    // Uint8List decrypted = curve.boxOpen(encryptedMessage, nonce, convertedPublicKey, convertedPrivateKey);
    Map map = Map();
    // (encryptedMessage, nonce, convertedPublicKey, convertedPrivateKey);
    map['msg'] = encryptedMessage;
    map['nonce'] = nonce;
    map['publicKey'] = convertedPublicKey;
    map['secretKey'] = convertedPrivateKey;
    Uint8List decrypted = await compute(boxOpen, map);

    return decodeString(decrypted);
  }
}
