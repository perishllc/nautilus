// Blake2B in pure Javascript
// Adapted from the reference implementation in RFC7693
// Ported to Javascript by DC - https://github.com/dcposch

// const util = require('./util')

// 64-bit unsigned addition
// Sets v[a,a+1] += v[b,b+1]
// v should be a Uint32Array
import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';

Uint32List ADD64AA(Uint32List v, int a, int b) {
  final int o0 = v[a] + v[b];
  int o1 = v[a + 1] + v[b + 1];
  if (o0 >= 0x100000000) {
    o1++;
  }
  v[a] = o0;
  v[a + 1] = o1;
  return v;
}

// 64-bit unsigned addition
// Sets v[a,a+1] += b
// b0 is the low 32 bits of b, b1 represents the high 32 bits
Uint32List ADD64AC(Uint32List v, int a, int b0, int b1) {
  int o0 = v[a] + b0;
  if (b0 < 0) {
    o0 += 0x100000000;
  }
  int o1 = v[a + 1] + b1;
  if (o0 >= 0x100000000) {
    o1++;
  }
  v[a] = o0;
  v[a + 1] = o1;
  return v;
}

// Little-endian byte access
B2B_GET32(var arr, var i) {
  return arr[i] ^ (arr[i + 1] << 8) ^ (arr[i + 2] << 16) ^ (arr[i + 3] << 24);
}

// G Mixing function
// The ROTRs are inlined for speed
// B2B_G(var a, var b, var c, var d, var ix, var iy) {
B2B_G(int a, int b, int c, int d, int ix, int iy) {
  final int x0 = m[ix];
  final int x1 = m[ix + 1];
  final int y0 = m[iy];
  final int y1 = m[iy + 1];

  v = ADD64AA(v, a,
      b); // v[a,a+1] += v[b,b+1] ... in JS we must store a uint64 as two uint32s
  v = ADD64AC(v, a, x0,
      x1); // v[a, a+1] += x ... x0 is the low 32 bits of x, x1 is the high 32 bits

  // v[d,d+1] = (v[d,d+1] xor v[a,a+1]) rotated to the right by 32 bits
  int xor0 = v[d] ^ v[a];
  int xor1 = v[d + 1] ^ v[a + 1];
  v[d] = xor1;
  v[d + 1] = xor0;

  v = ADD64AA(v, c, d);

  // v[b,b+1] = (v[b,b+1] xor v[c,c+1]) rotated right by 24 bits
  xor0 = v[b] ^ v[c];
  xor1 = v[b + 1] ^ v[c + 1];
  // v[b] = (xor0 >>> 24) ^ (xor1 << 8);
  // v[b + 1] = (xor1 >>> 24) ^ (xor0 << 8);
  v[b] = (xor0 >> 24) ^ (xor1 << 8);
  v[b + 1] = (xor1 >> 24) ^ (xor0 << 8);

  v = ADD64AA(v, a, b);
  v = ADD64AC(v, a, y0, y1);

  // v[d,d+1] = (v[d,d+1] xor v[a,a+1]) rotated right by 16 bits
  xor0 = v[d] ^ v[a];
  xor1 = v[d + 1] ^ v[a + 1];
  // v[d] = (xor0 >>> 16) ^ (xor1 << 16)
  // v[d + 1] = (xor1 >>> 16) ^ (xor0 << 16)
  v[d] = (xor0 >> 16) ^ (xor1 << 16);
  v[d + 1] = (xor1 >> 16) ^ (xor0 << 16);

  v = ADD64AA(v, c, d);

  // v[b,b+1] = (v[b,b+1] xor v[c,c+1]) rotated right by 63 bits
  xor0 = v[b] ^ v[c];
  xor1 = v[b + 1] ^ v[c + 1];
  // v[b] = (xor1 >>> 31) ^ (xor0 << 1)
  // v[b + 1] = (xor0 >>> 31) ^ (xor1 << 1)
  v[b] = (xor1 >> 31) ^ (xor0 << 1);
  v[b + 1] = (xor0 >> 31) ^ (xor1 << 1);
}

// Initialization Vector
Uint32List BLAKE2B_IV32 = Uint32List.fromList([
  0xf3bcc908,
  0x6a09e667,
  0x84caa73b,
  0xbb67ae85,
  0xfe94f82b,
  0x3c6ef372,
  0x5f1d36f1,
  0xa54ff53a,
  0xade682d1,
  0x510e527f,
  0x2b3e6c1f,
  0x9b05688c,
  0xfb41bd6b,
  0x1f83d9ab,
  0x137e2179,
  0x5be0cd19
]);

List<int> SIGMA8 = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  14,
  10,
  4,
  8,
  9,
  15,
  13,
  6,
  1,
  12,
  0,
  2,
  11,
  7,
  5,
  3,
  11,
  8,
  12,
  0,
  5,
  2,
  15,
  13,
  10,
  14,
  3,
  6,
  7,
  1,
  9,
  4,
  7,
  9,
  3,
  1,
  13,
  12,
  11,
  14,
  2,
  6,
  5,
  10,
  4,
  0,
  15,
  8,
  9,
  0,
  5,
  7,
  2,
  4,
  10,
  15,
  14,
  1,
  11,
  12,
  6,
  8,
  3,
  13,
  2,
  12,
  6,
  10,
  0,
  11,
  8,
  3,
  4,
  13,
  7,
  5,
  15,
  14,
  1,
  9,
  12,
  5,
  1,
  15,
  14,
  13,
  4,
  10,
  0,
  7,
  6,
  3,
  9,
  2,
  8,
  11,
  13,
  11,
  7,
  14,
  12,
  1,
  3,
  9,
  5,
  0,
  15,
  4,
  8,
  6,
  2,
  10,
  6,
  15,
  14,
  9,
  11,
  3,
  0,
  8,
  12,
  2,
  13,
  7,
  1,
  4,
  10,
  5,
  10,
  2,
  8,
  4,
  7,
  6,
  1,
  5,
  15,
  11,
  9,
  14,
  3,
  12,
  13,
  0,
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  14,
  10,
  4,
  8,
  9,
  15,
  13,
  6,
  1,
  12,
  0,
  2,
  11,
  7,
  5,
  3
];

// These are offsets into a uint64 buffer.
// Multiply them all by 2 to make them offsets into a uint32 buffer,
// because this is Javascript and we don't have uint64s
// const SIGMA82 = new Uint8Array(
//   SIGMA8.map(function (x) {
//     return x * 2
//   })
// )
// var SIGMA82 = new Uint8List.fromList(SIGMA8.map((x) {
//   return x * 2;
// }).toList());
// var SIGMA82 = SIGMA8.map((e) => e * 2).toList();

Uint8List SIGMA82 = Uint8List.fromList([
  0,
  2,
  4,
  6,
  8,
  10,
  12,
  14,
  16,
  18,
  20,
  22,
  24,
  26,
  28,
  30,
  28,
  20,
  8,
  16,
  18,
  30,
  26,
  12,
  2,
  24,
  0,
  4,
  22,
  14,
  10,
  6,
  22,
  16,
  24,
  0,
  10,
  4,
  30,
  26,
  20,
  28,
  6,
  12,
  14,
  2,
  18,
  8,
  14,
  18,
  6,
  2,
  26,
  24,
  22,
  28,
  4,
  12,
  10,
  20,
  8,
  0,
  30,
  16,
  18,
  0,
  10,
  14,
  4,
  8,
  20,
  30,
  28,
  2,
  22,
  24,
  12,
  16,
  6,
  26,
  4,
  24,
  12,
  20,
  0,
  22,
  16,
  6,
  8,
  26,
  14,
  10,
  30,
  28,
  2,
  18,
  24,
  10,
  2,
  30,
  28,
  26,
  8,
  20,
  0,
  14,
  12,
  6,
  18,
  4,
  16,
  22,
  26,
  22,
  14,
  28,
  24,
  2,
  6,
  18,
  10,
  0,
  30,
  8,
  16,
  12,
  4,
  20,
  12,
  30,
  28,
  18,
  22,
  6,
  0,
  16,
  24,
  4,
  26,
  14,
  2,
  8,
  20,
  10,
  20,
  4,
  16,
  8,
  14,
  12,
  2,
  10,
  30,
  22,
  18,
  28,
  6,
  24,
  26,
  0,
  0,
  2,
  4,
  6,
  8,
  10,
  12,
  14,
  16,
  18,
  20,
  22,
  24,
  26,
  28,
  30,
  28,
  20,
  8,
  16,
  18,
  30,
  26,
  12,
  2,
  24,
  0,
  4,
  22,
  14,
  10,
  6
]);

// Compression function. 'last' flag indicates last block.
// Note we're representing 16 uint64s as 32 uint32s
Uint32List v = Uint32List(32);
Uint32List m = Uint32List(32);
blake2bCompress(ctx, last) {
  int i = 0;

  // init work variables
  for (i = 0; i < 16; i++) {
    v[i] = ctx["h"][i] as int;
    v[i + 16] = BLAKE2B_IV32[i];
  }

  // low 64 bits of offset
  v[24] = v[24] ^ (ctx["t"] as int);
  // v[25] = v[25] ^ (ctx["t"] / 0x100000000);
  v[25] = v[25] ^ ((ctx["t"] / 0x100000000).toInt() as int);
  // high 64 bits not supported, offset may not be higher than 2**53-1

  // last block flag set ?
  if (last as bool) {
    v[28] = ~v[28];
    v[29] = ~v[29];
  }

  // get little-endian words
  for (i = 0; i < 32; i++) {
    m[i] = B2B_GET32(ctx["b"], 4 * i) as int;
  }

  // twelve rounds of mixing
  // uncomment the DebugPrint calls to log the computation
  // and match the RFC sample documentation
  // util.debugPrint('          m[16]', m, 64)
  for (i = 0; i < 12; i++) {
    // util.debugPrint('   (i=' + (i < 10 ? ' ' : '') + i + ') v[16]', v, 64)
    B2B_G(0, 8, 16, 24, SIGMA82[i * 16 + 0], SIGMA82[i * 16 + 1]);
    B2B_G(2, 10, 18, 26, SIGMA82[i * 16 + 2], SIGMA82[i * 16 + 3]);
    B2B_G(4, 12, 20, 28, SIGMA82[i * 16 + 4], SIGMA82[i * 16 + 5]);
    B2B_G(6, 14, 22, 30, SIGMA82[i * 16 + 6], SIGMA82[i * 16 + 7]);
    B2B_G(0, 10, 20, 30, SIGMA82[i * 16 + 8], SIGMA82[i * 16 + 9]);
    B2B_G(2, 12, 22, 24, SIGMA82[i * 16 + 10], SIGMA82[i * 16 + 11]);
    B2B_G(4, 14, 16, 26, SIGMA82[i * 16 + 12], SIGMA82[i * 16 + 13]);
    B2B_G(6, 8, 18, 28, SIGMA82[i * 16 + 14], SIGMA82[i * 16 + 15]);
  }
  // util.debugPrint('   (i=12) v[16]', v, 64)

  for (i = 0; i < 16; i++) {
    ctx["h"][i] = ctx["h"][i] ^ v[i] ^ v[i + 16];
  }
  // util.debugPrint('h[8]', ctx.h, 64)
}

// reusable parameterBlock
Uint8List parameterBlock = Uint8List.fromList([
  0,
  0,
  0,
  0, //  0: outlen, keylen, fanout, depth
  0,
  0,
  0,
  0, //  4: leaf length, sequential mode
  0,
  0,
  0,
  0, //  8: node offset
  0,
  0,
  0,
  0, // 12: node offset
  0,
  0,
  0,
  0, // 16: node depth, inner length, rfu
  0,
  0,
  0,
  0, // 20: rfu
  0,
  0,
  0,
  0, // 24: rfu
  0,
  0,
  0,
  0, // 28: rfu
  0,
  0,
  0,
  0, // 32: salt
  0,
  0,
  0,
  0, // 36: salt
  0,
  0,
  0,
  0, // 40: salt
  0,
  0,
  0,
  0, // 44: salt
  0,
  0,
  0,
  0, // 48: personal
  0,
  0,
  0,
  0, // 52: personal
  0,
  0,
  0,
  0, // 56: personal
  0,
  0,
  0,
  0 // 60: personal
]);

// Creates a BLAKE2b hashing context
// Requires an output length between 1 and 64 bytes
// Takes an optional Uint8Array key
// Takes an optinal Uint8Array salt
// Takes an optinal Uint8Array personal
blake2bInit(int outlen,
    [Uint8List? key, Uint8List? salt, Uint8List? personal]) {
  // if (outlen === 0 || outlen > 64) {
  //   throw new Error('Illegal output length, expected 0 < length <= 64');
  // }
  // if (key && key.length > 64) {
  //   throw new Error('Illegal key, expected Uint8Array with 0 < length <= 64');
  // }
  // if (salt && salt.length !== 16) {
  //   throw new Error('Illegal salt, expected Uint8Array with length is 16');
  // }
  // if (personal && personal.length !== 16) {
  //   throw new Error('Illegal personal, expected Uint8Array with length is 16');
  // }

  // state, 'param block'
  final Map<String, dynamic> ctx = {
    "b": Uint8List(128),
    "h": Uint32List(16),
    "t": 0, // input count
    "c": 0, // pointer within buffer
    "outlen": outlen // output length in bytes
  };

  // initialize parameterBlock before usage
  // parameterBlock.fill(0);
  for (int i = 0; i < parameterBlock.length; i++) {
    parameterBlock[i] = 0;
  }
  parameterBlock[0] = outlen;
  // if (key) {
  //   parameterBlock[1] = key.length;
  // }
  parameterBlock[2] = 1; // fanout
  parameterBlock[3] = 1; // depth
  // if (salt) parameterBlock.set(salt, 32);
  // if (personal) parameterBlock.set(personal, 48);

  // initialize hash state
  for (int i = 0; i < 16; i++) {
    ctx["h"][i] = BLAKE2B_IV32[i] ^ (B2B_GET32(parameterBlock, i * 4) as int);
  }

  // key the hash, if applicable
  // if (key) {
  //   blake2bUpdate(ctx, key);
  //   // at the end
  //   ctx["c"] = 128;
  // }

  return ctx;
}

// Updates a BLAKE2b streaming hash
// Requires hash context and Uint8Array (byte array)
blake2bUpdate(ctx, Uint8List input) {
  for (int i = 0; i < input.length; i++) {
    if (ctx["c"] == 128) {
      // buffer full ?
      ctx["t"] += ctx["c"]; // add counters
      blake2bCompress(ctx, false); // compress (not last)
      ctx["c"] = 0; // counter to zero
    }
    ctx["b"][ctx["c"]++] = input[i];
  }
}

// Completes a BLAKE2b streaming hash
// Returns a Uint8Array containing the message digest
Uint8List blake2bFinal(ctx) {
  ctx["t"] += ctx["c"]; // mark last block offset

  while (ctx["c"] < 128 as bool) {
    // fill up with zeros
    ctx["b"][ctx["c"]++] = 0;
  }
  blake2bCompress(ctx, true); // final block flag = 1

  // little endian convert and store
  final Uint8List out = Uint8List(ctx["outlen"] as int);
  for (int i = 0; i < (ctx["outlen"] as num); i++) {
    out[i] = ctx["h"][i >> 2] >> (8 * (i & 3)) as int;
  }
  return out;
}

// Computes the BLAKE2B hash of a string or byte array, and returns a Uint8Array
//
// Returns a n-byte Uint8Array
//
// Parameters:
// - input - the input bytes, as a string, Buffer or Uint8Array
// - key - optional key Uint8Array, up to 64 bytes
// - outlen - optional output length in bytes, default 64
// - salt - optional salt bytes, string, Buffer or Uint8Array
// - personal - optional personal bytes, string, Buffer or Uint8Array
Uint8List blake2b(Uint8List input,
    [Uint8List? key, int? outlen, Uint8List? salt, Uint8List? personal]) {
  // preprocess inputs
  outlen = outlen ?? 64;
  // outlen = 64;
  // input = util.normalizeInput(input);
  // if (salt) {
  //   salt = util.normalizeInput(salt);
  // }
  // if (personal) {
  //   personal = util.normalizeInput(personal);
  // }

  // do the math
  final ctx = blake2bInit(outlen, key, salt, personal);
  blake2bUpdate(ctx, input);
  return blake2bFinal(ctx);
}

// Computes the BLAKE2B hash of a string or byte array
//
// Returns an n-byte hash in hex, all lowercase
//
// Parameters:
// - input - the input bytes, as a string, Buffer, or Uint8Array
// - key - optional key Uint8Array, up to 64 bytes
// - outlen - optional output length in bytes, default 64
// - salt - optional salt bytes, string, Buffer or Uint8Array
// - personal - optional personal bytes, string, Buffer or Uint8Array
Uint8List blake2bHex(Uint8List input, Uint8List key, int outlen, Uint8List salt,
    Uint8List personal) {
  final Uint8List output = blake2b(input, key, outlen, salt, personal);
  // return util.toHex(output);
  return output;
}

// Future<String> generate_work(String hash, String difficulty) async {

//   String sendDifficulty = "fffffff800000000";
//   String receiveDifficulty = "fffffe0000000000";

//   final String hashedPassword = NanoHelpers.byteToHex(blake2b(
//       Uint8List.fromList(utf8.encode(confirmPasswordController!.text))));

//   return "";
// }

const int allThreshold = 0xffffffc000000000;
const int sendChangeThreshold = 0xfffffff800000000;
const int receiveOpenThreshold = 0xfffffe0000000000;

bool threshold(Uint8List value, int difficulty) {
  if ((value[0] == 255) && (value[1] == 255) && (value[2] == 255)) {
    print("0x${uint8ToHex(value)}");
  }

  if ((value[0] == 255) &&
      (value[1] == 255) &&
      (value[2] == 255) &&
      (value[3] >= 192)) {
    print("0x${uint8ToHex(value)}");
    return true;
  } else {
    return false;
  }

  // if ((value[0] == 255) &&
  //     (value[1] == 255) &&
  //     (value[2] == 255) &&
  //     (value[3] == 255)) {
  //   // print(NanoHelpers.byteToHex(value));
  //   print("0x${uint8ToHex(value)}");
  //   return true;
  // }

  // sendChangeThreshold:
  // if ((value[0] == 255) && // 0xff
  //     (value[1] == 255) && // 0xff
  //     (value[2] == 255) && // 0xff
  //     (value[3] == 255) && // 0xff
  //     (value[4] >= 248)) {// 0xf8
  //   return true;
  // } else {
  //   return false;
  // }

  // receiveOpenThreshold:
  // if ((value[0] == 255) && // 0xff
  //     (value[1] == 255) && // 0xff
  //     (value[2] >= 254)) {
  //   // 0xfe
  //   return true;
  // } else {
  //   return false;
  // }

  // // // Combine the bytes into a 64-bit unsigned integer
  // // int combinedValue = 0;
  // // for (int i = 0; i < 8; i++) {
  // //   combinedValue = (combinedValue << 8) | value[i];
  // // }
  // // return combinedValue > difficulty;

  // List<int> difficultyBytes = [
  //   (difficulty >> 56) & 0xFF,
  //   (difficulty >> 48) & 0xFF,
  //   (difficulty >> 40) & 0xFF,
  //   (difficulty >> 32) & 0xFF,
  //   (difficulty >> 24) & 0xFF,
  //   (difficulty >> 16) & 0xFF,
  //   (difficulty >> 8) & 0xFF,
  //   difficulty & 0xFF,
  // ];

  // for (int i = 0; i < 8; i++) {
  //   if (value[i] > difficultyBytes[i]) {
  //     return true;
  //   } else if (value[i] < difficultyBytes[i]) {
  //     return false;
  //   }
  // }
  // return true;

  return false;
}

Uint8List randomUint() {
  final Random random = Random();
  return Uint8List.fromList(List<int>.generate(8, (_) => random.nextInt(256)));
}

Uint8List? generator256(Uint8List hash) {
  Uint8List random = randomUint();
  for (int r = 0; r < 256; r++) {
    random[7] = (random[7] + r) % 256; // pseudo random part
    // Uint8List random = randomUint();
    final dynamic context = blake2bInit(8, null);
    blake2bUpdate(context, random);
    blake2bUpdate(context, hash);
    final Uint8List blakeRandom =
        Uint8List.fromList(blake2bFinal(context).reversed.toList());
    if (threshold(blakeRandom, sendChangeThreshold)) {
      return Uint8List.fromList(random.reversed.toList());
    }
  }
  return null;
}

Future<String> generate_work(String hashString, int threadNum) async {
  final Uint8List hash = NanoHelpers.hexToBytes(hashString);
  for (int i = 0; i < 1024; i++) {
    if (i % 512 == 0) {
      print("$threadNum: $i");
    }
    final Uint8List? generate = generator256(hash);
    if (generate != null) {
      // print(uint8ToHex(generate));
      return uint8ToHex(generate);
    }
  }
  throw Exception("didn't find a valid nonce");
}

Future<String> generateWorkMultiThreaded(String hash) async {
  final List<Future<String>> results = <Future<String>>[];
  for (int i = 0; i < 4; i++) {
    results.add(Isolate.run(() {
      return generate_work(hash, i + 1);
    }));
  }

  final Completer<String> completer = Completer<String>();

  for (final Future<String> future in results) {
    future.then(
      (String value) {
        if (!completer.isCompleted) {
          // completer.complete(value);
          return value;
        }
      },
      onError: (error) {
        // You can handle or log the error if needed
        print(error);
      },
    );
  }

  throw Exception("didn't find a valid nonce");

  // return completer.future;
}

List<int> uint8ToUint4(Uint8List uint8) {
  int length = uint8.length;
  List<int> uint4 = List.filled(length * 2, 0);
  for (int i = 0; i < length; i++) {
    uint4[i * 2] = uint8[i] ~/ 16;
    uint4[i * 2 + 1] = uint8[i] % 16;
  }
  return uint4;
}

Uint8List hexToUint8(String hex) {
  int length = hex.length ~/ 2;
  Uint8List uint8 = Uint8List(length);
  for (int i = 0; i < length; i++) {
    uint8[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return uint8;
}

String uint4ToHex(List<int> uint4) {
  return uint4.map((val) => val.toRadixString(16).toLowerCase()).join('');
}

String uint8ToHex(Uint8List uint8) {
  return uint4ToHex(uint8ToUint4(uint8));
}
