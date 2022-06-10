import 'dart:convert';

import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:blake2/blake2.dart';
import 'dart:typed_data';

Uint8List convertEd25519SecretKeyToCurve25519(Uint8List sk) {
  Uint8List o = new Uint8List(32);
  var i;

  Uint8List d = cryptoHash(sk);
  d[0] &= 248;
  d[31] &= 127;
  d[31] |= 64;

  for (i = 0; i < 32; i++) {
    o[i] = d[i];
  }

  // for (i = 0; i < 64; i++) {
  //   d[i] = 0;
  // }

  return o;
}

Uint8List generateHash(Uint8List data) {
  // blake2bUpdate
  // const ctx = blake2bInit(32, undefined)
  // data.forEach(str => blake2bUpdate(ctx, Convert.hex2ab(str)))
  // return blake2bFinal(ctx)

  final Blake2b blake2b = Blake2b(
    digestLength: 32,
    // key: Uint8List.fromList(data),
    // key: data,
  );

  data.forEach((element) {
    Uint8List tmp = Uint8List.fromList([element]);
    blake2b.update(tmp);
  });

  return blake2b.digest();
}

Uint8List cryptoHash(Uint8List m) {
  Uint8List out = new Uint8List(64);
  Uint8List input = new Uint8List(32);
  for (var i = 0; i < 32; ++i) {
    input[i] = m[i];
  }

  // NanoBlocks.computeStateHash();

  print(input);

  // hash = Convert.ab2hex(Signer.generateHash(input.map(Convert.stringToHex)))

  // var hash = Blake2bHash.hash(input, 0, input.length);
  // print(hash);
  // print(hash.length);

  var hash = generateHash(input);
  print(NanoHelpers.byteToHex(hash));
  print(hash.length);
  // for (var i = 0; i < 64; ++i) {
  //   out[i] = NanoHelpers.hexToBytes(hash[i])[0];
  // }

  return hash;

  // return out;
}

class Box {
  static const NONCE_LENGTH = 24;

  init() {
    Sodium.init();
  }

  static String encrypt(String message, String address, String privateKey) {
    String publicKey = NanoAccounts.extractPublicKey(address);

    Uint8List convertedPublicKey = Sodium.cryptoSignEd25519PkToCurve25519(NanoHelpers.hexToBytes(publicKey));
    // Uint8List convertedPrivateKey = Sodium.cryptoSignEd25519SkToCurve25519(NanoHelpers.hexToBytes(privateKey));
    Uint8List convertedPrivateKey = convertEd25519SecretKeyToCurve25519(NanoHelpers.hexToBytes(privateKey));

    print("convertedPublicKey: ${NanoHelpers.byteToHex(convertedPublicKey)}");
    print("convertedPrivateKey: ${NanoHelpers.byteToHex(convertedPrivateKey)}");
    print("pkLen: ${Sodium.hex2bin(publicKey).length}");
    print("skLen: ${Sodium.hex2bin(privateKey).length}");

    String constant_nonce = "42565937c3b257e4e094cc0e82eca63dd87587fcd18319f7";
    Uint8List nonce = Sodium.hex2bin(constant_nonce);

    // Uint8List encrypted = Sodium.cryptoBox(Sodium.hex2bin(message), nonce, convertedPublicKey, convertedPrivateKey);

    Uint8List k = Sodium.cryptoBoxBeforenm(convertedPublicKey, convertedPrivateKey);
    Uint8List encrypted = Sodium.cryptoSecretboxEasy(utf8.encode(message), nonce, k);
    print(encrypted.length);
    print("here");

    var full = BytesBuilder();
    full.add(nonce);
    full.add(encrypted);
    return Sodium.bin2base64(full.toBytes());
  }

  static String decrypt(String message, String address, String privateKey) {
    String publicKey = NanoAccounts.extractPublicKey(address);

    Uint8List convertedPublicKey = Sodium.cryptoSignEd25519PkToCurve25519(Sodium.hex2bin(publicKey));
    // Uint8List convertedPrivateKey = Sodium.cryptoSignEd25519SkToCurve25519(Sodium.hex2bin(privateKey));
    Uint8List convertedPrivateKey = convertEd25519SecretKeyToCurve25519(Sodium.hex2bin(privateKey));

    // const decodedEncryptedMessageBytes = base64.base64ToBytes(encrypted)
    Uint8List decodedEncryptedMessageBytes = Sodium.base642bin(message);
    Uint8List nonce = decodedEncryptedMessageBytes.sublist(0, NONCE_LENGTH);
    Uint8List encryptedMessage = decodedEncryptedMessageBytes.sublist(NONCE_LENGTH, decodedEncryptedMessageBytes.length);

    Uint8List decrypted = Sodium.cryptoBoxOpenEasy(encryptedMessage, nonce, convertedPublicKey, convertedPrivateKey);

    // Uint8List k = Sodium.cryptoBoxBeforenm(convertedPublicKey, convertedPrivateKey);
    // Uint8List decrypted = Sodium.cryptoBoxOpenEasyAfternm(encryptedMessage, nonce, k);

    return utf8.decode(decrypted);

    // const decrypted = new Curve25519().boxOpen(
    // 	encryptedMessage,
    // 	nonce,
    // 	Convert.hex2ab(convertedPublicKey),
    // 	Convert.hex2ab(convertedPrivateKey),
    // )

    // if (!decrypted) {
    // 	throw new Error('Could not decrypt message')
    // }

    // return Convert.encodeUTF8(decrypted)
  }
}
