import 'dart:typed_data';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/util/curve25519.dart';

class Ed25519 {
  Ed25519() {
    curve = Curve25519();
    X = curve.gf([0xd51a, 0x8f25, 0x2d60, 0xc956, 0xa7b2, 0x9525, 0xc760, 0x692c, 0xdc5c, 0xfdd6, 0xe231, 0xc0a4, 0x53fe, 0xcd6e, 0x36d3, 0x2169]);
    Y = curve.gf([0x6658, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666, 0x6666]);
    L = Uint8List.fromList(
        [0xed, 0xd3, 0xf5, 0x5c, 0x1a, 0x63, 0x12, 0x58, 0xd6, 0x9c, 0xf7, 0xa2, 0xde, 0xf9, 0xde, 0x14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x10]);
  }

  late Curve25519 curve;
  late Int32List X;
  late Int32List Y;
  late Uint8List L;

  void pack(Uint8List r, dynamic p) {
    final Curve25519 CURVE = curve;
    Int32List tx = CURVE.gf(), ty = CURVE.gf(), zi = CURVE.gf();
    CURVE.inv25519(zi, p[2] as Int32List);
    CURVE.M(tx, p[0] as Int32List, zi);
    CURVE.M(ty, p[1] as Int32List, zi);
    CURVE.pack25519(r, ty);
    r[31] ^= CURVE.par25519(tx) << 7;
  }

  void modL(Uint8List r, dynamic x /*: Uint32Array | Float64Array*/) {
    int carry;
    int i, j, k;

    late Uint32List y;
    late Float64List z;

    if (x is Uint32List) {
      y = x;

      for (i = 63; i >= 32; --i) {
        carry = 0;
        // for (j = i - 32, k = i - 12; j < k; ++j) {
        // 	y[j] += carry - 16 * y[i] * this.L[j - (i - 32)];
        // 	carry = (y[j] + 128) >> 8;
        // 	y[j] -= carry * 256;
        // }
        j = i - 32;
        k = i - 12;
        while (j < k) {
          y[j] += carry - 16 * y[i] * L[j - (i - 32)];
          carry = (y[j] + 128) >> 8;
          y[j] -= carry * 256;
          j++;
        }

        y[j] += carry;
        y[i] = 0;
      }

      carry = 0;
      for (j = 0; j < 32; j++) {
        y[j] += carry - (y[31] >> 4) * L[j];
        carry = y[j] >> 8;
        y[j] &= 255;
      }

      for (j = 0; j < 32; j++) {
        y[j] -= carry * L[j];
      }

      for (i = 0; i < 32; i++) {
        y[i + 1] += y[i] >> 8;
        r[i] = y[i] & 0xff;
      }
    } else if (x is Float64List) {
      z = x;

      // throw Exception("Not implemented");

      for (i = 63; i >= 32; --i) {
        carry = 0;
        // for (j = i - 32, k = i - 12; j < k; ++j) {
        // 	z[j] += carry - 16 * z[i] * this.L[j - (i - 32)];
        // 	carry = (z[j] + 128) >> 8;
        // 	z[j] -= carry * 256;
        // }
        j = i - 32;
        k = i - 12;
        while (j < k) {
          z[j] += carry - 16 * z[i] * L[j - (i - 32)];
          carry = (z[j] + 128).toInt() >> 8;
          z[j] -= carry * 256;
          j++;
        }

        z[j] += carry;
        z[i] = 0;
      }

      carry = 0;
      for (j = 0; j < 32; j++) {
        z[j] += carry - (z[31].toInt() >> 4) * L[j];
        carry = z[j].toInt() >> 8;
        // z[j] &= 255;
        z[j] = (z[j].toInt() & 255).toDouble();
      }

      for (j = 0; j < 32; j++) {
        z[j] -= carry * L[j];
      }

      for (i = 0; i < 32; i++) {
        z[i + 1] += z[i].toInt() >> 8;
        r[i] = z[i].toInt() & 0xff;
      }
    }

    // for (i = 63; i >= 32; --i) {
    // 	carry = 0;
    // 	// for (j = i - 32, k = i - 12; j < k; ++j) {
    // 	// 	x[j] += carry - 16 * x[i] * this.L[j - (i - 32)];
    // 	// 	carry = (x[j] + 128) >> 8;
    // 	// 	x[j] -= carry * 256;
    // 	// }
    //   j = i - 32;
    //   k = i - 12;
    // 	while (j < k) {
    // 		x[j] += carry - 16 * x[i] * L[j - (i - 32)];
    // 		carry = (x[j] + 128) >> 8;
    // 		x[j] -= carry * 256;
    //     j++;
    // 	}

    // 	x[j] += carry;
    // 	x[i] = 0;
    // }

    // carry = 0;
    // for (j = 0; j < 32; j++) {
    // 	x[j] += carry - (x[31] >> 4) * L[j];
    // 	carry = x[j] >> 8;
    // 	x[j] &= 255;
    // }

    // for (j = 0; j < 32; j++) {
    // 	x[j] -= carry * L[j];
    // }

    // for (i = 0; i < 32; i++) {
    // 	x[i + 1] += x[i] >> 8;
    // 	r[i] = x[i] & 0xff;
    // }
  }

  void reduce(Uint8List r) {
    final Uint32List x = Uint32List(64);
    for (int i = 0; i < 64; i++) {
      x[i] = r[i];
    }

    modL(r, x);
  }

  void scalarmult(List<Int32List> p, List<Int32List> q, Uint8List s) {
    final Curve25519 CURVE = curve;
    CURVE.set25519(p[0], CURVE.gf0);
    CURVE.set25519(p[1], CURVE.gf1);
    CURVE.set25519(p[2], CURVE.gf1);
    CURVE.set25519(p[3], CURVE.gf0);
    for (int i = 255; i >= 0; --i) {
      // final int b = (s[(i / 8) | 0] >> (i & 7)) & 1;

      final int temp3 = i ~/ 8;
      final int temp2 = temp3 | 0;
      final int temp = s[temp2];
      final int b = (temp >> (i & 7)) & 1;

      CURVE.cswap(p, q, b);
      CURVE.add(q, p);
      CURVE.add(p, p);
      CURVE.cswap(p, q, b);
    }
  }

  void scalarbase(List<Int32List> p, Uint8List s) {
    final Curve25519 CURVE = curve;
    final List<Int32List> q = [CURVE.gf(), CURVE.gf(), CURVE.gf(), CURVE.gf()];
    CURVE.set25519(q[0], X);
    CURVE.set25519(q[1], Y);
    CURVE.set25519(q[2], CURVE.gf1);
    CURVE.M(q[3], X, Y);
    scalarmult(p, q, s);
  }

  /**
	 * Generate an ed25519 keypair
	 * @param {String} seed A 32 byte cryptographic secure random hexadecimal string. This is basically the secret key
	 * @param {Object} Returns sk (Secret key) and pk (Public key) as 32 byte hexadecimal strings
	 */
  // generateKeys(seed: string): KeyPair {
  // 	const pk = new Uint8Array(32)
  // 	const List p = [this.curve.gf(), this.curve.gf(), this.curve.gf(), this.curve.gf()]
  // 	const h = blake2b(Convert.hex2ab(seed), undefined, 64).slice(0, 32)

  // 	h[0] &= 0xf8
  // 	h[31] &= 0x7f
  // 	h[31] |= 0x40

  // 	this.scalarbase(p, h)
  // 	this.pack(pk, p)

  // 	return {
  // 		privateKey: seed,
  // 		publicKey: Convert.ab2hex(pk),
  // 	}
  // }

  // String generatePublicKey(String seed) {
  // 	var pk = Uint8List(32);
  // 	var p = [curve.gf(), curve.gf(), curve.gf(), curve.gf()];
  // 	var h = blake2b(NanoHelpers.hexToBytes(seed), null, 64);
  //   h = h.sublist(0, 32);

  // 	h[0] &= 0xf8;
  // 	h[31] &= 0x7f;
  // 	h[31] |= 0x40;

  // 	this.scalarbase(p, h);
  // 	this.pack(pk, p);

  //   // Convert.ab2hex(pk);
  //   return NanoHelpers.byteToHex(pk);
  // }

  /**
	 * Convert ed25519 keypair to curve25519 keypair suitable for Diffie-Hellman key exchange
	 *
	 * @param {KeyPair} keyPair ed25519 keypair
	 * @returns {KeyPair} keyPair Curve25519 keypair
	 */
  // convertKeys(keyPair: KeyPair): KeyPair {
  // 	const publicKey = Convert.ab2hex(this.curve.convertEd25519PublicKeyToCurve25519(Convert.hex2ab(keyPair.publicKey)))
  // 	if (!publicKey) {
  // 		return null
  // 	}
  // 	const privateKey = Convert.ab2hex(this.curve.convertEd25519SecretKeyToCurve25519(Convert.hex2ab(keyPair.privateKey)))
  // 	return {
  // 		publicKey,
  // 		privateKey,
  // 	}
  // }

  /**
	 * Generate a message signature
	 * @param {Uint8Array} msg Message to be signed as byte array
	 * @param {Uint8Array} privateKey Secret key as byte array
	 * @param {Uint8Array} Returns the signature as 64 byte typed array
	 */
  Uint8List sign(Uint8List msg, Uint8List privateKey) {
    final Uint8List signedMsg = naclSign(msg, privateKey);
    final Uint8List sig = Uint8List(64);

    for (int i = 0; i < sig.length; i++) {
      sig[i] = signedMsg[i];
    }

    return sig;
  }

  Uint8List naclSign(Uint8List msg, Uint8List secretKey) {
    if (secretKey.length != 32) {
      throw Exception("bad secret key size");
    }

    final Uint8List signedMsg = Uint8List(64 + msg.length);
    cryptoSign(signedMsg, msg, msg.length, secretKey);

    return signedMsg;
  }

  int cryptoSign(Uint8List sm, Uint8List m, int n, Uint8List sk) {
    final Curve25519 CURVE = curve;
    final Uint8List d = Uint8List(64);
    final Uint8List h = Uint8List(64);
    final Uint8List r = Uint8List(64);
    final Float64List x = Float64List(64);
    final List<Int32List> p = [CURVE.gf(), CURVE.gf(), CURVE.gf(), CURVE.gf()];

    int i;
    int j;

    // const pk = NanoHelpers.hexToBytes(generateKeys(NanoHelpers.byteToHex(sk)).publicKey);
    // public key:
    final Uint8List pk = NanoHelpers.hexToBytes(NanoKeys.createPublicKey(NanoKeys.seedToPrivate(NanoHelpers.byteToHex(sk), 0)));

    curve.cryptoHash(d, sk, 32);
    d[0] &= 248;
    d[31] &= 127;
    d[31] |= 64;

    final int smlen = n + 64;
    for (i = 0; i < n; i++) {
      sm[64 + i] = m[i];
    }

    for (i = 0; i < 32; i++) {
      sm[32 + i] = d[32 + i];
    }

    curve.cryptoHash(r, sm.sublist(32), n + 32);
    reduce(r);
    scalarbase(p, r);
    pack(sm, p);

    for (i = 32; i < 64; i++) {
      sm[i] = pk[i - 32];
    }

    curve.cryptoHash(h, sm, n + 64);
    reduce(h);

    for (i = 0; i < 64; i++) {
      x[i] = 0;
    }

    for (i = 0; i < 32; i++) {
      x[i] = (r[i]).toDouble();
    }

    for (i = 0; i < 32; i++) {
      for (j = 0; j < 32; j++) {
        x[i + j] += h[i] * d[j];
      }
    }

    modL(sm.sublist(32), x);

    return smlen;
  }
}
