import 'dart:typed_data';
import 'package:wallet_flutter/util/blake2b.dart';

// floor(num num) {
//   return num.floor();
// }

/**
 * Time constant comparison of two arrays
 *
 * @param {Uint8Array} lh First array of bytes
 * @param {Uint8Array} rh Second array of bytes
 * @return {Boolean} True if the arrays are equal (length and content), false otherwise
 */
bool compare(Uint8List lh, Uint8List rh) {
  if (lh.length != rh.length) {
    return false;
  }

  int i;
  int d = 0;
  final int len = lh.length;

  for (i = 0; i < len; i++) {
    d |= lh[i] ^ rh[i];
  }

  return d == 0;
}

class Curve25519 {

  Curve25519() {
    // Int32List gf0 = gf();
    // Int32List gf1 = gf([1]);
    // // Uint8List _9 = new Uint8List(32);
    // // _9[0] = 9;
    // Uint8List _9 = Uint8List.fromList([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);// TODO: fix this
    // Int32List _121665 = gf([0xdb41, 1]);
    // Int32List D = gf([0x78a3, 0x1359, 0x4dca, 0x75eb, 0xd8ab, 0x4141, 0x0a4d, 0x0070, 0xe898, 0x7779, 0x4079, 0x8cc7, 0xfe73, 0x2b6f, 0x6cee, 0x5203]);
    // Int32List D2 = gf([0xf159, 0x26b2, 0x9b94, 0xebd6, 0xb156, 0x8283, 0x149a, 0x00e0, 0xd130, 0xeef3, 0x80f2, 0x198e, 0xfce7, 0x56df, 0xd9dc, 0x2406]);
    // Int32List I = gf([0xa0b0, 0x4a0e, 0x1b27, 0xc4ee, 0xe478, 0xad2f, 0x1806, 0x2f43, 0xd7a7, 0x3dfb, 0x0099, 0x2b4d, 0xdf0b, 0x4fc1, 0x2480, 0x2b83]);
    // Uint8List _0 = Uint8List(16);
    // Uint8List sigma = Uint8List.fromList([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
    // Uint32List minusp = Uint32List.fromList([5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 252]);

    gf0 = gf();
    gf1 = gf([1]);
    // Uint8List _9 = new Uint8List(32);
    // _9[0] = 9;
    Uint8List _9 = Uint8List.fromList([9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]); // TODO: fix this
    _121665 = gf([0xdb41, 1]);
    D = gf([0x78a3, 0x1359, 0x4dca, 0x75eb, 0xd8ab, 0x4141, 0x0a4d, 0x0070, 0xe898, 0x7779, 0x4079, 0x8cc7, 0xfe73, 0x2b6f, 0x6cee, 0x5203]);
    D2 = gf([0xf159, 0x26b2, 0x9b94, 0xebd6, 0xb156, 0x8283, 0x149a, 0x00e0, 0xd130, 0xeef3, 0x80f2, 0x198e, 0xfce7, 0x56df, 0xd9dc, 0x2406]);
    I = gf([0xa0b0, 0x4a0e, 0x1b27, 0xc4ee, 0xe478, 0xad2f, 0x1806, 0x2f43, 0xd7a7, 0x3dfb, 0x0099, 0x2b4d, 0xdf0b, 0x4fc1, 0x2480, 0x2b83]);
    _0 = Uint8List(16);
    sigma = Uint8List.fromList([101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32, 107]);
    minusp = Uint32List.fromList([5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 252]);
  }
  
  late Int32List gf0;
  late Int32List gf1;
  late Int32List D;
  late Int32List D2;
  late Int32List I;
  late Uint8List _9;
  late Int32List _121665;
  late Uint8List _0;
  late Uint8List sigma;
  late Uint32List minusp;

  Int32List gf([List<int>? init]) {
    final Int32List r = Int32List(16);
    if (init != null) {
      for (int i = 0; i < init.length; i++) {
        r[i] = init[i];
      }
    }

    return r;
  }

  void A(Int32List o, Int32List a, Int32List b) {
    for (int i = 0; i < 16; i++) {
      o[i] = a[i] + b[i];
    }
  }

  void Z(Int32List o, Int32List a, Int32List b) {
    for (int i = 0; i < 16; i++) {
      o[i] = a[i] - b[i];
    }
  }

  // Avoid loops for better performance
  void M(Int32List o, Int32List a, Int32List b) {
    int v,
        c,
        t0 = 0,
        t1 = 0,
        t2 = 0,
        t3 = 0,
        t4 = 0,
        t5 = 0,
        t6 = 0,
        t7 = 0,
        t8 = 0,
        t9 = 0,
        t10 = 0,
        t11 = 0,
        t12 = 0,
        t13 = 0,
        t14 = 0,
        t15 = 0,
        t16 = 0,
        t17 = 0,
        t18 = 0,
        t19 = 0,
        t20 = 0,
        t21 = 0,
        t22 = 0,
        t23 = 0,
        t24 = 0,
        t25 = 0,
        t26 = 0,
        t27 = 0,
        t28 = 0,
        t29 = 0,
        t30 = 0;
    int b0 = b[0],
        b1 = b[1],
        b2 = b[2],
        b3 = b[3],
        b4 = b[4],
        b5 = b[5],
        b6 = b[6],
        b7 = b[7],
        b8 = b[8],
        b9 = b[9],
        b10 = b[10],
        b11 = b[11],
        b12 = b[12],
        b13 = b[13],
        b14 = b[14],
        b15 = b[15];

    v = a[0];
    t0 += v * b0;
    t1 += v * b1;
    t2 += v * b2;
    t3 += v * b3;
    t4 += v * b4;
    t5 += v * b5;
    t6 += v * b6;
    t7 += v * b7;
    t8 += v * b8;
    t9 += v * b9;
    t10 += v * b10;
    t11 += v * b11;
    t12 += v * b12;
    t13 += v * b13;
    t14 += v * b14;
    t15 += v * b15;
    v = a[1];
    t1 += v * b0;
    t2 += v * b1;
    t3 += v * b2;
    t4 += v * b3;
    t5 += v * b4;
    t6 += v * b5;
    t7 += v * b6;
    t8 += v * b7;
    t9 += v * b8;
    t10 += v * b9;
    t11 += v * b10;
    t12 += v * b11;
    t13 += v * b12;
    t14 += v * b13;
    t15 += v * b14;
    t16 += v * b15;
    v = a[2];
    t2 += v * b0;
    t3 += v * b1;
    t4 += v * b2;
    t5 += v * b3;
    t6 += v * b4;
    t7 += v * b5;
    t8 += v * b6;
    t9 += v * b7;
    t10 += v * b8;
    t11 += v * b9;
    t12 += v * b10;
    t13 += v * b11;
    t14 += v * b12;
    t15 += v * b13;
    t16 += v * b14;
    t17 += v * b15;
    v = a[3];
    t3 += v * b0;
    t4 += v * b1;
    t5 += v * b2;
    t6 += v * b3;
    t7 += v * b4;
    t8 += v * b5;
    t9 += v * b6;
    t10 += v * b7;
    t11 += v * b8;
    t12 += v * b9;
    t13 += v * b10;
    t14 += v * b11;
    t15 += v * b12;
    t16 += v * b13;
    t17 += v * b14;
    t18 += v * b15;
    v = a[4];
    t4 += v * b0;
    t5 += v * b1;
    t6 += v * b2;
    t7 += v * b3;
    t8 += v * b4;
    t9 += v * b5;
    t10 += v * b6;
    t11 += v * b7;
    t12 += v * b8;
    t13 += v * b9;
    t14 += v * b10;
    t15 += v * b11;
    t16 += v * b12;
    t17 += v * b13;
    t18 += v * b14;
    t19 += v * b15;
    v = a[5];
    t5 += v * b0;
    t6 += v * b1;
    t7 += v * b2;
    t8 += v * b3;
    t9 += v * b4;
    t10 += v * b5;
    t11 += v * b6;
    t12 += v * b7;
    t13 += v * b8;
    t14 += v * b9;
    t15 += v * b10;
    t16 += v * b11;
    t17 += v * b12;
    t18 += v * b13;
    t19 += v * b14;
    t20 += v * b15;
    v = a[6];
    t6 += v * b0;
    t7 += v * b1;
    t8 += v * b2;
    t9 += v * b3;
    t10 += v * b4;
    t11 += v * b5;
    t12 += v * b6;
    t13 += v * b7;
    t14 += v * b8;
    t15 += v * b9;
    t16 += v * b10;
    t17 += v * b11;
    t18 += v * b12;
    t19 += v * b13;
    t20 += v * b14;
    t21 += v * b15;
    v = a[7];
    t7 += v * b0;
    t8 += v * b1;
    t9 += v * b2;
    t10 += v * b3;
    t11 += v * b4;
    t12 += v * b5;
    t13 += v * b6;
    t14 += v * b7;
    t15 += v * b8;
    t16 += v * b9;
    t17 += v * b10;
    t18 += v * b11;
    t19 += v * b12;
    t20 += v * b13;
    t21 += v * b14;
    t22 += v * b15;
    v = a[8];
    t8 += v * b0;
    t9 += v * b1;
    t10 += v * b2;
    t11 += v * b3;
    t12 += v * b4;
    t13 += v * b5;
    t14 += v * b6;
    t15 += v * b7;
    t16 += v * b8;
    t17 += v * b9;
    t18 += v * b10;
    t19 += v * b11;
    t20 += v * b12;
    t21 += v * b13;
    t22 += v * b14;
    t23 += v * b15;
    v = a[9];
    t9 += v * b0;
    t10 += v * b1;
    t11 += v * b2;
    t12 += v * b3;
    t13 += v * b4;
    t14 += v * b5;
    t15 += v * b6;
    t16 += v * b7;
    t17 += v * b8;
    t18 += v * b9;
    t19 += v * b10;
    t20 += v * b11;
    t21 += v * b12;
    t22 += v * b13;
    t23 += v * b14;
    t24 += v * b15;
    v = a[10];
    t10 += v * b0;
    t11 += v * b1;
    t12 += v * b2;
    t13 += v * b3;
    t14 += v * b4;
    t15 += v * b5;
    t16 += v * b6;
    t17 += v * b7;
    t18 += v * b8;
    t19 += v * b9;
    t20 += v * b10;
    t21 += v * b11;
    t22 += v * b12;
    t23 += v * b13;
    t24 += v * b14;
    t25 += v * b15;
    v = a[11];
    t11 += v * b0;
    t12 += v * b1;
    t13 += v * b2;
    t14 += v * b3;
    t15 += v * b4;
    t16 += v * b5;
    t17 += v * b6;
    t18 += v * b7;
    t19 += v * b8;
    t20 += v * b9;
    t21 += v * b10;
    t22 += v * b11;
    t23 += v * b12;
    t24 += v * b13;
    t25 += v * b14;
    t26 += v * b15;
    v = a[12];
    t12 += v * b0;
    t13 += v * b1;
    t14 += v * b2;
    t15 += v * b3;
    t16 += v * b4;
    t17 += v * b5;
    t18 += v * b6;
    t19 += v * b7;
    t20 += v * b8;
    t21 += v * b9;
    t22 += v * b10;
    t23 += v * b11;
    t24 += v * b12;
    t25 += v * b13;
    t26 += v * b14;
    t27 += v * b15;
    v = a[13];
    t13 += v * b0;
    t14 += v * b1;
    t15 += v * b2;
    t16 += v * b3;
    t17 += v * b4;
    t18 += v * b5;
    t19 += v * b6;
    t20 += v * b7;
    t21 += v * b8;
    t22 += v * b9;
    t23 += v * b10;
    t24 += v * b11;
    t25 += v * b12;
    t26 += v * b13;
    t27 += v * b14;
    t28 += v * b15;
    v = a[14];
    t14 += v * b0;
    t15 += v * b1;
    t16 += v * b2;
    t17 += v * b3;
    t18 += v * b4;
    t19 += v * b5;
    t20 += v * b6;
    t21 += v * b7;
    t22 += v * b8;
    t23 += v * b9;
    t24 += v * b10;
    t25 += v * b11;
    t26 += v * b12;
    t27 += v * b13;
    t28 += v * b14;
    t29 += v * b15;
    v = a[15];
    t15 += v * b0;
    t16 += v * b1;
    t17 += v * b2;
    t18 += v * b3;
    t19 += v * b4;
    t20 += v * b5;
    t21 += v * b6;
    t22 += v * b7;
    t23 += v * b8;
    t24 += v * b9;
    t25 += v * b10;
    t26 += v * b11;
    t27 += v * b12;
    t28 += v * b13;
    t29 += v * b14;
    t30 += v * b15;

    t0 += 38 * t16;
    t1 += 38 * t17;
    t2 += 38 * t18;
    t3 += 38 * t19;
    t4 += 38 * t20;
    t5 += 38 * t21;
    t6 += 38 * t22;
    t7 += 38 * t23;
    t8 += 38 * t24;
    t9 += 38 * t25;
    t10 += 38 * t26;
    t11 += 38 * t27;
    t12 += 38 * t28;
    t13 += 38 * t29;
    t14 += 38 * t30;

    c = 1;
    v = t0 + c + 65535;
    c = (v / 65536).floor();
    t0 = v - c * 65536;
    v = t1 + c + 65535;
    c = (v / 65536).floor();
    t1 = v - c * 65536;
    v = t2 + c + 65535;
    c = (v / 65536).floor();
    t2 = v - c * 65536;
    v = t3 + c + 65535;
    c = (v / 65536).floor();
    t3 = v - c * 65536;
    v = t4 + c + 65535;
    c = (v / 65536).floor();
    t4 = v - c * 65536;
    v = t5 + c + 65535;
    c = (v / 65536).floor();
    t5 = v - c * 65536;
    v = t6 + c + 65535;
    c = (v / 65536).floor();
    t6 = v - c * 65536;
    v = t7 + c + 65535;
    c = (v / 65536).floor();
    t7 = v - c * 65536;
    v = t8 + c + 65535;
    c = (v / 65536).floor();
    t8 = v - c * 65536;
    v = t9 + c + 65535;
    c = (v / 65536).floor();
    t9 = v - c * 65536;
    v = t10 + c + 65535;
    c = (v / 65536).floor();
    t10 = v - c * 65536;
    v = t11 + c + 65535;
    c = (v / 65536).floor();
    t11 = v - c * 65536;
    v = t12 + c + 65535;
    c = (v / 65536).floor();
    t12 = v - c * 65536;
    v = t13 + c + 65535;
    c = (v / 65536).floor();
    t13 = v - c * 65536;
    v = t14 + c + 65535;
    c = (v / 65536).floor();
    t14 = v - c * 65536;
    v = t15 + c + 65535;
    c = (v / 65536).floor();
    t15 = v - c * 65536;
    t0 += c - 1 + 37 * (c - 1);

    c = 1;
    v = t0 + c + 65535;
    c = (v / 65536).floor();
    t0 = v - c * 65536;
    v = t1 + c + 65535;
    c = (v / 65536).floor();
    t1 = v - c * 65536;
    v = t2 + c + 65535;
    c = (v / 65536).floor();
    t2 = v - c * 65536;
    v = t3 + c + 65535;
    c = (v / 65536).floor();
    t3 = v - c * 65536;
    v = t4 + c + 65535;
    c = (v / 65536).floor();
    t4 = v - c * 65536;
    v = t5 + c + 65535;
    c = (v / 65536).floor();
    t5 = v - c * 65536;
    v = t6 + c + 65535;
    c = (v / 65536).floor();
    t6 = v - c * 65536;
    v = t7 + c + 65535;
    c = (v / 65536).floor();
    t7 = v - c * 65536;
    v = t8 + c + 65535;
    c = (v / 65536).floor();
    t8 = v - c * 65536;
    v = t9 + c + 65535;
    c = (v / 65536).floor();
    t9 = v - c * 65536;
    v = t10 + c + 65535;
    c = (v / 65536).floor();
    t10 = v - c * 65536;
    v = t11 + c + 65535;
    c = (v / 65536).floor();
    t11 = v - c * 65536;
    v = t12 + c + 65535;
    c = (v / 65536).floor();
    t12 = v - c * 65536;
    v = t13 + c + 65535;
    c = (v / 65536).floor();
    t13 = v - c * 65536;
    v = t14 + c + 65535;
    c = (v / 65536).floor();
    t14 = v - c * 65536;
    v = t15 + c + 65535;
    c = (v / 65536).floor();
    t15 = v - c * 65536;
    t0 += c - 1 + 37 * (c - 1);

    o[0] = t0;
    o[1] = t1;
    o[2] = t2;
    o[3] = t3;
    o[4] = t4;
    o[5] = t5;
    o[6] = t6;
    o[7] = t7;
    o[8] = t8;
    o[9] = t9;
    o[10] = t10;
    o[11] = t11;
    o[12] = t12;
    o[13] = t13;
    o[14] = t14;
    o[15] = t15;
  }

  void coreSalsa20(Uint8List o, Uint8List p, Uint8List k, Uint8List c) {
    int j0 = c[0] & 0xff | (c[1] & 0xff) << 8 | (c[2] & 0xff) << 16 | (c[3] & 0xff) << 24,
        j1 = k[0] & 0xff | (k[1] & 0xff) << 8 | (k[2] & 0xff) << 16 | (k[3] & 0xff) << 24,
        j2 = k[4] & 0xff | (k[5] & 0xff) << 8 | (k[6] & 0xff) << 16 | (k[7] & 0xff) << 24,
        j3 = k[8] & 0xff | (k[9] & 0xff) << 8 | (k[10] & 0xff) << 16 | (k[11] & 0xff) << 24,
        j4 = k[12] & 0xff | (k[13] & 0xff) << 8 | (k[14] & 0xff) << 16 | (k[15] & 0xff) << 24,
        j5 = c[4] & 0xff | (c[5] & 0xff) << 8 | (c[6] & 0xff) << 16 | (c[7] & 0xff) << 24,
        j6 = p[0] & 0xff | (p[1] & 0xff) << 8 | (p[2] & 0xff) << 16 | (p[3] & 0xff) << 24,
        j7 = p[4] & 0xff | (p[5] & 0xff) << 8 | (p[6] & 0xff) << 16 | (p[7] & 0xff) << 24,
        j8 = p[8] & 0xff | (p[9] & 0xff) << 8 | (p[10] & 0xff) << 16 | (p[11] & 0xff) << 24,
        j9 = p[12] & 0xff | (p[13] & 0xff) << 8 | (p[14] & 0xff) << 16 | (p[15] & 0xff) << 24,
        j10 = c[8] & 0xff | (c[9] & 0xff) << 8 | (c[10] & 0xff) << 16 | (c[11] & 0xff) << 24,
        j11 = k[16] & 0xff | (k[17] & 0xff) << 8 | (k[18] & 0xff) << 16 | (k[19] & 0xff) << 24,
        j12 = k[20] & 0xff | (k[21] & 0xff) << 8 | (k[22] & 0xff) << 16 | (k[23] & 0xff) << 24,
        j13 = k[24] & 0xff | (k[25] & 0xff) << 8 | (k[26] & 0xff) << 16 | (k[27] & 0xff) << 24,
        j14 = k[28] & 0xff | (k[29] & 0xff) << 8 | (k[30] & 0xff) << 16 | (k[31] & 0xff) << 24,
        j15 = c[12] & 0xff | (c[13] & 0xff) << 8 | (c[14] & 0xff) << 16 | (c[15] & 0xff) << 24;

    int x0 = j0,
        x1 = j1,
        x2 = j2,
        x3 = j3,
        x4 = j4,
        x5 = j5,
        x6 = j6,
        x7 = j7,
        x8 = j8,
        x9 = j9,
        x10 = j10,
        x11 = j11,
        x12 = j12,
        x13 = j13,
        x14 = j14,
        x15 = j15,
        u;

    for (int i = 0; i < 20; i += 2) {
      // triple shifts: >>> changed to >>
      u = x0 + x12 | 0;
      x4 ^= u << 7 | u >> (32 - 7);
      u = x4 + x0 | 0;
      x8 ^= u << 9 | u >> (32 - 9);
      u = x8 + x4 | 0;
      x12 ^= u << 13 | u >> (32 - 13);
      u = x12 + x8 | 0;
      x0 ^= u << 18 | u >> (32 - 18);

      u = x5 + x1 | 0;
      x9 ^= u << 7 | u >> (32 - 7);
      u = x9 + x5 | 0;
      x13 ^= u << 9 | u >> (32 - 9);
      u = x13 + x9 | 0;
      x1 ^= u << 13 | u >> (32 - 13);
      u = x1 + x13 | 0;
      x5 ^= u << 18 | u >> (32 - 18);

      u = x10 + x6 | 0;
      x14 ^= u << 7 | u >> (32 - 7);
      u = x14 + x10 | 0;
      x2 ^= u << 9 | u >> (32 - 9);
      u = x2 + x14 | 0;
      x6 ^= u << 13 | u >> (32 - 13);
      u = x6 + x2 | 0;
      x10 ^= u << 18 | u >> (32 - 18);

      u = x15 + x11 | 0;
      x3 ^= u << 7 | u >> (32 - 7);
      u = x3 + x15 | 0;
      x7 ^= u << 9 | u >> (32 - 9);
      u = x7 + x3 | 0;
      x11 ^= u << 13 | u >> (32 - 13);
      u = x11 + x7 | 0;
      x15 ^= u << 18 | u >> (32 - 18);

      u = x0 + x3 | 0;
      x1 ^= u << 7 | u >> (32 - 7);
      u = x1 + x0 | 0;
      x2 ^= u << 9 | u >> (32 - 9);
      u = x2 + x1 | 0;
      x3 ^= u << 13 | u >> (32 - 13);
      u = x3 + x2 | 0;
      x0 ^= u << 18 | u >> (32 - 18);

      u = x5 + x4 | 0;
      x6 ^= u << 7 | u >> (32 - 7);
      u = x6 + x5 | 0;
      x7 ^= u << 9 | u >> (32 - 9);
      u = x7 + x6 | 0;
      x4 ^= u << 13 | u >> (32 - 13);
      u = x4 + x7 | 0;
      x5 ^= u << 18 | u >> (32 - 18);

      u = x10 + x9 | 0;
      x11 ^= u << 7 | u >> (32 - 7);
      u = x11 + x10 | 0;
      x8 ^= u << 9 | u >> (32 - 9);
      u = x8 + x11 | 0;
      x9 ^= u << 13 | u >> (32 - 13);
      u = x9 + x8 | 0;
      x10 ^= u << 18 | u >> (32 - 18);

      u = x15 + x14 | 0;
      x12 ^= u << 7 | u >> (32 - 7);
      u = x12 + x15 | 0;
      x13 ^= u << 9 | u >> (32 - 9);
      u = x13 + x12 | 0;
      x14 ^= u << 13 | u >> (32 - 13);
      u = x14 + x13 | 0;
      x15 ^= u << 18 | u >> (32 - 18);
    }
    x0 = x0 + j0 | 0;
    x1 = x1 + j1 | 0;
    x2 = x2 + j2 | 0;
    x3 = x3 + j3 | 0;
    x4 = x4 + j4 | 0;
    x5 = x5 + j5 | 0;
    x6 = x6 + j6 | 0;
    x7 = x7 + j7 | 0;
    x8 = x8 + j8 | 0;
    x9 = x9 + j9 | 0;
    x10 = x10 + j10 | 0;
    x11 = x11 + j11 | 0;
    x12 = x12 + j12 | 0;
    x13 = x13 + j13 | 0;
    x14 = x14 + j14 | 0;
    x15 = x15 + j15 | 0;

    o[0] = x0 >> 0 & 0xff;
    o[1] = x0 >> 8 & 0xff;
    o[2] = x0 >> 16 & 0xff;
    o[3] = x0 >> 24 & 0xff;

    o[4] = x1 >> 0 & 0xff;
    o[5] = x1 >> 8 & 0xff;
    o[6] = x1 >> 16 & 0xff;
    o[7] = x1 >> 24 & 0xff;

    o[8] = x2 >> 0 & 0xff;
    o[9] = x2 >> 8 & 0xff;
    o[10] = x2 >> 16 & 0xff;
    o[11] = x2 >> 24 & 0xff;

    o[12] = x3 >> 0 & 0xff;
    o[13] = x3 >> 8 & 0xff;
    o[14] = x3 >> 16 & 0xff;
    o[15] = x3 >> 24 & 0xff;

    o[16] = x4 >> 0 & 0xff;
    o[17] = x4 >> 8 & 0xff;
    o[18] = x4 >> 16 & 0xff;
    o[19] = x4 >> 24 & 0xff;

    o[20] = x5 >> 0 & 0xff;
    o[21] = x5 >> 8 & 0xff;
    o[22] = x5 >> 16 & 0xff;
    o[23] = x5 >> 24 & 0xff;

    o[24] = x6 >> 0 & 0xff;
    o[25] = x6 >> 8 & 0xff;
    o[26] = x6 >> 16 & 0xff;
    o[27] = x6 >> 24 & 0xff;

    o[28] = x7 >> 0 & 0xff;
    o[29] = x7 >> 8 & 0xff;
    o[30] = x7 >> 16 & 0xff;
    o[31] = x7 >> 24 & 0xff;

    o[32] = x8 >> 0 & 0xff;
    o[33] = x8 >> 8 & 0xff;
    o[34] = x8 >> 16 & 0xff;
    o[35] = x8 >> 24 & 0xff;

    o[36] = x9 >> 0 & 0xff;
    o[37] = x9 >> 8 & 0xff;
    o[38] = x9 >> 16 & 0xff;
    o[39] = x9 >> 24 & 0xff;

    o[40] = x10 >> 0 & 0xff;
    o[41] = x10 >> 8 & 0xff;
    o[42] = x10 >> 16 & 0xff;
    o[43] = x10 >> 24 & 0xff;

    o[44] = x11 >> 0 & 0xff;
    o[45] = x11 >> 8 & 0xff;
    o[46] = x11 >> 16 & 0xff;
    o[47] = x11 >> 24 & 0xff;

    o[48] = x12 >> 0 & 0xff;
    o[49] = x12 >> 8 & 0xff;
    o[50] = x12 >> 16 & 0xff;
    o[51] = x12 >> 24 & 0xff;

    o[52] = x13 >> 0 & 0xff;
    o[53] = x13 >> 8 & 0xff;
    o[54] = x13 >> 16 & 0xff;
    o[55] = x13 >> 24 & 0xff;

    o[56] = x14 >> 0 & 0xff;
    o[57] = x14 >> 8 & 0xff;
    o[58] = x14 >> 16 & 0xff;
    o[59] = x14 >> 24 & 0xff;

    o[60] = x15 >> 0 & 0xff;
    o[61] = x15 >> 8 & 0xff;
    o[62] = x15 >> 16 & 0xff;
    o[63] = x15 >> 24 & 0xff;
  }

  void coreHsalsa20(Uint8List o, Uint8List p, Uint8List k, Uint8List c) {
    int j0 = c[0] & 0xff | (c[1] & 0xff) << 8 | (c[2] & 0xff) << 16 | (c[3] & 0xff) << 24,
        j1 = k[0] & 0xff | (k[1] & 0xff) << 8 | (k[2] & 0xff) << 16 | (k[3] & 0xff) << 24,
        j2 = k[4] & 0xff | (k[5] & 0xff) << 8 | (k[6] & 0xff) << 16 | (k[7] & 0xff) << 24,
        j3 = k[8] & 0xff | (k[9] & 0xff) << 8 | (k[10] & 0xff) << 16 | (k[11] & 0xff) << 24,
        j4 = k[12] & 0xff | (k[13] & 0xff) << 8 | (k[14] & 0xff) << 16 | (k[15] & 0xff) << 24,
        j5 = c[4] & 0xff | (c[5] & 0xff) << 8 | (c[6] & 0xff) << 16 | (c[7] & 0xff) << 24,
        j6 = p[0] & 0xff | (p[1] & 0xff) << 8 | (p[2] & 0xff) << 16 | (p[3] & 0xff) << 24,
        j7 = p[4] & 0xff | (p[5] & 0xff) << 8 | (p[6] & 0xff) << 16 | (p[7] & 0xff) << 24,
        j8 = p[8] & 0xff | (p[9] & 0xff) << 8 | (p[10] & 0xff) << 16 | (p[11] & 0xff) << 24,
        j9 = p[12] & 0xff | (p[13] & 0xff) << 8 | (p[14] & 0xff) << 16 | (p[15] & 0xff) << 24,
        j10 = c[8] & 0xff | (c[9] & 0xff) << 8 | (c[10] & 0xff) << 16 | (c[11] & 0xff) << 24,
        j11 = k[16] & 0xff | (k[17] & 0xff) << 8 | (k[18] & 0xff) << 16 | (k[19] & 0xff) << 24,
        j12 = k[20] & 0xff | (k[21] & 0xff) << 8 | (k[22] & 0xff) << 16 | (k[23] & 0xff) << 24,
        j13 = k[24] & 0xff | (k[25] & 0xff) << 8 | (k[26] & 0xff) << 16 | (k[27] & 0xff) << 24,
        j14 = k[28] & 0xff | (k[29] & 0xff) << 8 | (k[30] & 0xff) << 16 | (k[31] & 0xff) << 24,
        j15 = c[12] & 0xff | (c[13] & 0xff) << 8 | (c[14] & 0xff) << 16 | (c[15] & 0xff) << 24;

    int x0 = j0,
        x1 = j1,
        x2 = j2,
        x3 = j3,
        x4 = j4,
        x5 = j5,
        x6 = j6,
        x7 = j7,
        x8 = j8,
        x9 = j9,
        x10 = j10,
        x11 = j11,
        x12 = j12,
        x13 = j13,
        x14 = j14,
        x15 = j15,
        u;

    for (int i = 0; i < 20; i += 2) {
      u = x0 + x12 | 0;
      x4 ^= u << 7 | u >> (32 - 7);
      u = x4 + x0 | 0;
      x8 ^= u << 9 | u >> (32 - 9);
      u = x8 + x4 | 0;
      x12 ^= u << 13 | u >> (32 - 13);
      u = x12 + x8 | 0;
      x0 ^= u << 18 | u >> (32 - 18);

      u = x5 + x1 | 0;
      x9 ^= u << 7 | u >> (32 - 7);
      u = x9 + x5 | 0;
      x13 ^= u << 9 | u >> (32 - 9);
      u = x13 + x9 | 0;
      x1 ^= u << 13 | u >> (32 - 13);
      u = x1 + x13 | 0;
      x5 ^= u << 18 | u >> (32 - 18);

      u = x10 + x6 | 0;
      x14 ^= u << 7 | u >> (32 - 7);
      u = x14 + x10 | 0;
      x2 ^= u << 9 | u >> (32 - 9);
      u = x2 + x14 | 0;
      x6 ^= u << 13 | u >> (32 - 13);
      u = x6 + x2 | 0;
      x10 ^= u << 18 | u >> (32 - 18);

      u = x15 + x11 | 0;
      x3 ^= u << 7 | u >> (32 - 7);
      u = x3 + x15 | 0;
      x7 ^= u << 9 | u >> (32 - 9);
      u = x7 + x3 | 0;
      x11 ^= u << 13 | u >> (32 - 13);
      u = x11 + x7 | 0;
      x15 ^= u << 18 | u >> (32 - 18);

      u = x0 + x3 | 0;
      x1 ^= u << 7 | u >> (32 - 7);
      u = x1 + x0 | 0;
      x2 ^= u << 9 | u >> (32 - 9);
      u = x2 + x1 | 0;
      x3 ^= u << 13 | u >> (32 - 13);
      u = x3 + x2 | 0;
      x0 ^= u << 18 | u >> (32 - 18);

      u = x5 + x4 | 0;
      x6 ^= u << 7 | u >> (32 - 7);
      u = x6 + x5 | 0;
      x7 ^= u << 9 | u >> (32 - 9);
      u = x7 + x6 | 0;
      x4 ^= u << 13 | u >> (32 - 13);
      u = x4 + x7 | 0;
      x5 ^= u << 18 | u >> (32 - 18);

      u = x10 + x9 | 0;
      x11 ^= u << 7 | u >> (32 - 7);
      u = x11 + x10 | 0;
      x8 ^= u << 9 | u >> (32 - 9);
      u = x8 + x11 | 0;
      x9 ^= u << 13 | u >> (32 - 13);
      u = x9 + x8 | 0;
      x10 ^= u << 18 | u >> (32 - 18);

      u = x15 + x14 | 0;
      x12 ^= u << 7 | u >> (32 - 7);
      u = x12 + x15 | 0;
      x13 ^= u << 9 | u >> (32 - 9);
      u = x13 + x12 | 0;
      x14 ^= u << 13 | u >> (32 - 13);
      u = x14 + x13 | 0;
      x15 ^= u << 18 | u >> (32 - 18);
    }

    o[0] = x0 >> 0 & 0xff;
    o[1] = x0 >> 8 & 0xff;
    o[2] = x0 >> 16 & 0xff;
    o[3] = x0 >> 24 & 0xff;

    o[4] = x5 >> 0 & 0xff;
    o[5] = x5 >> 8 & 0xff;
    o[6] = x5 >> 16 & 0xff;
    o[7] = x5 >> 24 & 0xff;

    o[8] = x10 >> 0 & 0xff;
    o[9] = x10 >> 8 & 0xff;
    o[10] = x10 >> 16 & 0xff;
    o[11] = x10 >> 24 & 0xff;

    o[12] = x15 >> 0 & 0xff;
    o[13] = x15 >> 8 & 0xff;
    o[14] = x15 >> 16 & 0xff;
    o[15] = x15 >> 24 & 0xff;

    o[16] = x6 >> 0 & 0xff;
    o[17] = x6 >> 8 & 0xff;
    o[18] = x6 >> 16 & 0xff;
    o[19] = x6 >> 24 & 0xff;

    o[20] = x7 >> 0 & 0xff;
    o[21] = x7 >> 8 & 0xff;
    o[22] = x7 >> 16 & 0xff;
    o[23] = x7 >> 24 & 0xff;

    o[24] = x8 >> 0 & 0xff;
    o[25] = x8 >> 8 & 0xff;
    o[26] = x8 >> 16 & 0xff;
    o[27] = x8 >> 24 & 0xff;

    o[28] = x9 >> 0 & 0xff;
    o[29] = x9 >> 8 & 0xff;
    o[30] = x9 >> 16 & 0xff;
    o[31] = x9 >> 24 & 0xff;
  }

  void S(Int32List o, Int32List a) {
    M(o, a, a);
  }

  void add(List<Int32List> p, List<Int32List> q) {
    Int32List a = gf(), b = gf(), c = gf(), d = gf(), e = gf(), f = gf(), g = gf(), h = gf(), t = gf();

    Z(a, p[1], p[0]);
    Z(t, q[1], q[0]);
    M(a, a, t);
    A(b, p[0], p[1]);
    A(t, q[0], q[1]);
    M(b, b, t);
    M(c, p[3], q[3]);
    M(c, c, D2);
    M(d, p[2], q[2]);
    A(d, d, d);
    Z(e, b, a);
    Z(f, d, c);
    A(g, d, c);
    A(h, b, a);
    M(p[0], e, f);
    M(p[1], h, g);
    M(p[2], g, f);
    M(p[3], e, h);
  }

  void set25519(Int32List r, Int32List a) {
    for (int i = 0; i < 16; i++) {
      r[i] = a[i];
    }
  }

  void car25519(Int32List o) {
    int i, v, c = 1;
    for (i = 0; i < 16; i++) {
      v = o[i] + c + 65535;
      c = (v / 65536).floor();
      o[i] = v - c * 65536;
    }

    o[0] += c - 1 + 37 * (c - 1);
  }

  // b is 0 or 1
  void sel25519(Int32List p, Int32List q, int b) {
    int i, t;
    final int c = ~(b - 1);
    for (i = 0; i < 16; i++) {
      t = c & (p[i] ^ q[i]);
      p[i] ^= t;
      q[i] ^= t;
    }
  }

  void inv25519(Int32List o, Int32List i) {
    int a;
    final Int32List c = gf();
    for (a = 0; a < 16; a++) {
      c[a] = i[a];
    }

    for (a = 253; a >= 0; a--) {
      S(c, c);
      if (a != 2 && a != 4) {
        M(c, c, i);
      }
    }

    for (a = 0; a < 16; a++) {
      o[a] = c[a];
    }
  }

  bool neq25519(Int32List a, Int32List b) {
    Uint8List c = Uint8List(32), d = Uint8List(32);
    pack25519(c, a);
    pack25519(d, b);
    return !compare(c, d);
  }

  int par25519(Int32List a) {
    final Uint8List d = Uint8List(32);
    pack25519(d, a);
    return d[0] & 1;
  }

  void pow2523(Int32List o, Int32List i) {
    int a;
    final Int32List c = gf();
    for (a = 0; a < 16; a++) {
      c[a] = i[a];
    }

    for (a = 250; a >= 0; a--) {
      S(c, c);
      if (a != 1) M(c, c, i);
    }

    for (a = 0; a < 16; a++) {
      o[a] = c[a];
    }
  }

  void cswap(List<Int32List> p, List<Int32List> q, int b) {
    for (int i = 0; i < 4; i++) {
      sel25519(p[i], q[i], b);
    }
  }

  void pack25519(Uint8List o, Int32List n) {
    int i;
    final Int32List m = gf();
    final Int32List t = gf();
    for (i = 0; i < 16; i++) {
      t[i] = n[i];
    }

    car25519(t);
    car25519(t);
    car25519(t);
    for (int j = 0; j < 2; j++) {
      m[0] = t[0] - 0xffed;
      for (i = 1; i < 15; i++) {
        m[i] = t[i] - 0xffff - ((m[i - 1] >> 16) & 1);
        m[i - 1] &= 0xffff;
      }

      m[15] = t[15] - 0x7fff - ((m[14] >> 16) & 1);
      final int b = (m[15] >> 16) & 1;
      m[14] &= 0xffff;
      sel25519(t, m, 1 - b);
    }

    for (i = 0; i < 16; i++) {
      o[2 * i] = t[i] & 0xff;
      o[2 * i + 1] = t[i] >> 8;
    }
  }

  void unpack25519(Int32List o, Uint8List n) {
    for (int i = 0; i < 16; i++) {
      o[i] = n[2 * i] + (n[2 * i + 1] << 8);
    }

    o[15] &= 0x7fff;
  }

  int unpackNeg(List<Int32List> r, Uint8List p) {
    Int32List t = gf(), chk = gf(), num = gf(), den = gf(), den2 = gf(), den4 = gf(), den6 = gf();

    set25519(r[2], gf1);
    unpack25519(r[1], p);
    S(num, r[1]);
    M(den, num, D);
    Z(num, num, r[2]);
    A(den, r[2], den);

    S(den2, den);
    S(den4, den2);
    M(den6, den4, den2);
    M(t, den6, num);
    M(t, t, den);

    pow2523(t, t);
    M(t, t, num);
    M(t, t, den);
    M(t, t, den);
    M(r[0], t, den);

    S(chk, r[0]);
    M(chk, chk, den);
    if (neq25519(chk, num)) {
      M(r[0], r[0], I);
    }

    S(chk, r[0]);
    M(chk, chk, den);
    if (neq25519(chk, num)) {
      return -1;
    }

    if (par25519(r[0]) == (p[31] >> 7)) {
      Z(r[0], gf0, r[0]);
    }

    M(r[3], r[0], r[1]);

    return 0;
  }

  int vn(Uint8List x, int xi, Uint8List y, int yi, int n) {
    int i, d = 0;
    for (i = 0; i < n; i++) {
      d |= x[xi + i] ^ y[yi + i];
    }
    return (1 & ((d - 1) >> 8)) - 1;
  }

  /**
	 * Internal scalar mult function
	 * @param {Uint8List} q Result
	 * @param {Uint8List} s Secret key
	 * @param {Uint8List} p Public key
	 */
  void cryptoScalarmult(Uint8List q, Uint8List s, Uint8List p) {
    final Int32List x = Int32List(80);
    int r, i;
    Int32List a = gf(), b = gf(), c = gf(), d = gf(), e = gf(), f = gf();

    unpack25519(x, p);

    for (i = 0; i < 16; i++) {
      b[i] = x[i];
      d[i] = a[i] = c[i] = 0;
    }

    a[0] = d[0] = 1;
    for (i = 254; i >= 0; --i) {
      r = (s[i >> 3] >> (i & 7)) & 1;
      sel25519(a, b, r);
      sel25519(c, d, r);
      A(e, a, c);
      Z(a, a, c);
      A(c, b, d);
      Z(b, b, d);
      S(d, e);
      S(f, a);
      M(a, c, a);
      M(c, b, e);
      A(e, a, c);
      Z(a, a, c);
      S(b, a);
      Z(c, d, f);
      M(a, c, _121665);
      A(a, a, d);
      M(c, c, a);
      M(a, d, f);
      M(d, b, x);
      S(b, e);
      sel25519(a, b, r);
      sel25519(c, d, r);
    }

    for (i = 0; i < 16; i++) {
      x[i + 16] = a[i];
      x[i + 32] = c[i];
      x[i + 48] = b[i];
      x[i + 64] = d[i];
    }

    final Int32List x32 = x.sublist(32); // todo
    final Int32List x16 = x.sublist(16);
    inv25519(x32, x32);
    M(x16, x16, x32);
    pack25519(q, x16);
  }

  int cryptoStreamSalsa20Xor(Uint8List c, int cpos, Uint8List m, int mpos, int b, Uint8List n, Uint8List k) {
    final Uint8List z = Uint8List(16);
    final Uint8List x = Uint8List(64);
    int u, i;
    for (i = 0; i < 16; i++) {
      z[i] = 0;
    }
    for (i = 0; i < 8; i++) {
      z[i] = n[i];
    }
    while (b >= 64) {
      coreSalsa20(x, z, k, sigma);
      for (i = 0; i < 64; i++) c[cpos + i] = m[mpos + i] ^ x[i];
      u = 1;
      for (i = 8; i < 16; i++) {
        u = u + (z[i] & 0xff) | 0;
        z[i] = u & 0xff;
        // u >>>= 8;
        u >>= 8;
      }
      b -= 64;
      cpos += 64;
      mpos += 64;
    }
    if (b > 0) {
      coreSalsa20(x, z, k, sigma);
      for (i = 0; i < b; i++) {
        c[cpos + i] = m[mpos + i] ^ x[i];
      }
    }
    return 0;
  }

  int cryptoStreamSalsa20(Uint8List c, int cpos, int b, Uint8List n, Uint8List k) {
    Uint8List z = Uint8List(16), x = Uint8List(64);
    int u, i;
    for (i = 0; i < 16; i++) z[i] = 0;
    for (i = 0; i < 8; i++) z[i] = n[i];
    while (b >= 64) {
      coreSalsa20(x, z, k, sigma);
      for (i = 0; i < 64; i++) {
        c[cpos + i] = x[i];
      }
      u = 1;
      for (i = 8; i < 16; i++) {
        u = u + (z[i] & 0xff) | 0;
        z[i] = u & 0xff;
        // u >>>= 8;
        u >>= 8;
      }
      b -= 64;
      cpos += 64;
    }
    if (b > 0) {
      coreSalsa20(x, z, k, sigma);
      for (i = 0; i < b; i++) {
        c[cpos + i] = x[i];
      }
    }
    return 0;
  }

  add1305(Uint32List h, Uint32List c) {
    int j, u = 0;
    for (j = 0; j < 17; j++) {
      u = (u + ((h[j] + c[j]) | 0)) | 0;
      h[j] = u & 255;
      // u >>>= 8
      u >>= 8;
    }
  }

  int cryptoOnetimeauth(Uint8List out, int outpos, Uint8List m, int mpos, int n, Uint8List k) {
    int s, i, j;
    int u; // todo
    Uint32List x = Uint32List(17), r = Uint32List(17), h = Uint32List(17), c = Uint32List(17), g = Uint32List(17);
    for (j = 0; j < 17; j++) {
      r[j] = h[j] = 0;
    }
    for (j = 0; j < 16; j++) {
      r[j] = k[j];
    }

    r[3] &= 15;
    r[4] &= 252;
    r[7] &= 15;
    r[8] &= 252;
    r[11] &= 15;
    r[12] &= 252;
    r[15] &= 15;

    while (n > 0) {
      for (j = 0; j < 17; j++) {
        c[j] = 0;
      }
      for (j = 0; (j < 16) && (j < n); ++j) {
        c[j] = m[mpos + j];
      }
      c[j] = 1;
      mpos += j;
      n -= j;
      add1305(h, c);
      for (i = 0; i < 17; i++) {
        x[i] = 0;
        for (j = 0; j < 17; j++) {
          x[i] = (x[i] + (h[j] * ((j <= i) ? r[i - j] : ((320 * r[i + 17 - j]) | 0))) | 0) | 0;
        }
      }
      for (i = 0; i < 17; i++) {
        h[i] = x[i];
      }
      u = 0;
      for (j = 0; j < 16; j++) {
        u = (u + h[j]) | 0;
        h[j] = u & 255;
        u >>= 8;
      }
      u = (u + h[16]) | 0;
      h[16] = u & 3;
      u = (5 * (u >> 2)) | 0;
      for (j = 0; j < 16; j++) {
        u = (u + h[j]) | 0;
        h[j] = u & 255;
        u >>= 8;
      }
      u = (u + h[16]) | 0;
      h[16] = u;
    }

    for (j = 0; j < 17; j++) {
      g[j] = h[j];
    }
    add1305(h, minusp);
    s = -(h[16] >> 7) | 0;
    for (j = 0; j < 17; j++) {
      h[j] ^= s & (g[j] ^ h[j]);
    }

    for (j = 0; j < 16; j++) {
      c[j] = k[j + 16];
    }
    c[16] = 0;
    add1305(h, c);
    for (j = 0; j < 16; j++) {
      out[outpos + j] = h[j];
    }
    return 0;
  }

  dynamic cryptoOnetimeauthVerify(Uint8List h, int hpos, Uint8List m, int mpos, int n, Uint8List k) {
    final Uint8List x = Uint8List(16);
    cryptoOnetimeauth(x, 0, m, mpos, n, k);
    return cryptoVerify16(h, hpos, x, 0);
  }

  int cryptoVerify16(Uint8List x, int xi, Uint8List y, int yi) {
    return vn(x, xi, y, yi, 16);
  }

  void cryptoBoxBeforenm(Uint8List k, Uint8List y, Uint8List x) {
    final Uint8List s = Uint8List(32);
    cryptoScalarmult(s, x, y);
    return coreHsalsa20(k, _0, s, sigma);
  }

  int cryptoSecretbox(Uint8List c, Uint8List m, int d, Uint8List n, Uint8List k) {
    int i;
    if (d < 32) {
      return -1;
    }
    cryptoStreamXor(c, 0, m, 0, d, n, k);
    cryptoOnetimeauth(c, 16, c, 32, d - 32, c);
    for (i = 0; i < 16; i++) {
      c[i] = 0;
    }
    return 0;
  }

  int cryptoSecretboxOpen(Uint8List m, Uint8List c, int d, Uint8List n, Uint8List k) {
    int i;
    final Uint8List x = Uint8List(32);
    if (d < 32) {
      return -1;
    }
    cryptoStream(x, 0, 32, n, k);
    if (cryptoOnetimeauthVerify(c, 16, c, 32, d - 32, x) != 0) {
      return -1;
    }
    cryptoStreamXor(m, 0, c, 0, d, n, k);
    for (i = 0; i < 32; i++) {
      m[i] = 0;
    }
    return 0;
  }

  int cryptoStream(Uint8List c, int cpos, int d, Uint8List n, Uint8List k) {
    final Uint8List s = Uint8List(32);
    coreHsalsa20(s, n, k, sigma);
    final Uint8List sn = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      sn[i] = n[i + 16];
    }
    return cryptoStreamSalsa20(c, cpos, d, sn, s);
  }

  int cryptoStreamXor(Uint8List c, int cpos, Uint8List m, int mpos, int d, Uint8List n, Uint8List k) {
    final Uint8List s = Uint8List(32);
    coreHsalsa20(s, n, k, sigma);
    final Uint8List sn = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      sn[i] = n[i + 16];
    }
    return cryptoStreamSalsa20Xor(c, cpos, m, mpos, d, sn, s);
  }

  void checkLengths(Uint8List k, Uint8List n) {
    if (k.length != 32) {
      // throw Error('bad key size');
      throw Exception('bad key size');
    }
    if (n.length != 24) {
      // throw Error('bad nonce size');
      throw Exception('bad nonce size');
    }
  }

  void checkBoxLengths(Uint8List pk, Uint8List sk) {
    if (pk.length != 32) {
      // throw new Error('bad public key size');
      throw Exception('bad public key size');
    }
    if (sk.length != 32) {
      // throw new Error('bad secret key size');
      throw Exception('bad secret key size');
    }
  }

  // checkListTypes(...params: any) {
  // 	for (var i = 0; i < params.length; i++) {
  // 		if (!(params[i] instanceof Uint8List)) {
  // 			throw new TypeError('unexpected type, use Uint8List');
  // 		}
  // 	}
  // }

  Uint8List secretbox(Uint8List msg, Uint8List nonce, Uint8List key) {
    // checkListTypes(msg, nonce, key);
    checkLengths(key, nonce);
    final Uint8List m = Uint8List(32 + msg.length);
    final Uint8List c = Uint8List(m.length);
    for (int i = 0; i < msg.length; i++) {
      m[i + 32] = msg[i];
    }
    cryptoSecretbox(c, m, m.length, nonce, key);
    return c.sublist(16); // todo
  }

  // Uint8List secretbox(Map map) {

  //   Uint8List msg = map["msg"];
  //   Uint8List nonce = map["nonce"];
  //   Uint8List key = map["key"];

  //   // checkListTypes(msg, nonce, key);
  //   checkLengths(key, nonce);
  //   Uint8List m = new Uint8List(32 + msg.length);
  //   Uint8List c = new Uint8List(m.length);
  //   for (int i = 0; i < msg.length; i++) {
  //     m[i + 32] = msg[i];
  //   }
  //   cryptoSecretbox(c, m, m.length, nonce, key);
  //   return c.sublist(16); // todo
  // }

  Uint8List? secretboxOpen(Uint8List box, Uint8List nonce, Uint8List key) {
    // checkListTypes(box, nonce, key);
    checkLengths(key, nonce);
    final Uint8List c = Uint8List(16 + box.length);
    final Uint8List m = Uint8List(c.length);
    for (int i = 0; i < box.length; i++) {
      c[i + 16] = box[i];
    }
    if (c.length < 32) {
      return null;
    }
    if (cryptoSecretboxOpen(m, c, c.length, nonce, key) != 0) {
      return null;
    }
    return m.sublist(32); // todo
  }

  Uint8List oldBox(Uint8List msg, Uint8List nonce, Uint8List publicKey, Uint8List secretKey) {
    final Uint8List k = oldBoxBefore(publicKey, secretKey);
    return secretbox(msg, nonce, k);
  }

  Uint8List box(Map map) {
    final Uint8List msg = map["msg"] as Uint8List;
    final Uint8List nonce = map["nonce"] as Uint8List;
    final Uint8List publicKey = map["publicKey"] as Uint8List;
    final Uint8List secretKey = map["secretKey"] as Uint8List;
    final Uint8List k = oldBoxBefore(publicKey, secretKey);
    return secretbox(msg, nonce, k);
  }

  Uint8List? oldBoxOpen(Uint8List msg, Uint8List nonce, Uint8List publicKey, Uint8List secretKey) {
    final Uint8List k = oldBoxBefore(publicKey, secretKey);
    return secretboxOpen(msg, nonce, k);
  }

  Uint8List? boxOpen(Map map) {
    final Uint8List publicKey = map["publicKey"] as Uint8List;
    final Uint8List secretKey = map["secretKey"] as Uint8List;
    final Uint8List msg = map["msg"] as Uint8List;
    final Uint8List nonce = map["nonce"] as Uint8List;
    final Uint8List k = oldBoxBefore(publicKey, secretKey);
    return secretboxOpen(msg, nonce, k);
  }

  Uint8List oldBoxBefore(Uint8List publicKey, Uint8List secretKey) {
    // checkListTypes(publicKey, secretKey);
    checkBoxLengths(publicKey, secretKey);
    final Uint8List k = Uint8List(32);
    cryptoBoxBeforenm(k, publicKey, secretKey);
    return k;
  }

  Uint8List boxBefore(Map map /*Uint8List publicKey, Uint8List secretKey*/) {
    final Uint8List publicKey = map['publicKey'] as Uint8List;
    final Uint8List secretKey = map['secretKey'] as Uint8List;
    // checkListTypes(publicKey, secretKey);
    checkBoxLengths(publicKey, secretKey);
    final Uint8List k = Uint8List(32);
    cryptoBoxBeforenm(k, publicKey, secretKey);
    return k;
  }

  /**
	 * Generate the common key as the produkt of sk1 * pk2
	 * @param {Uint8List} sk A 32 byte secret key of pair 1
	 * @param {Uint8List} pk A 32 byte public key of pair 2
	 * @return {Uint8List} sk * pk
	 */
  Uint8List scalarMult(Uint8List sk, Uint8List pk) {
    final Uint8List q = Uint8List(32);
    cryptoScalarmult(q, sk, pk);
    return q;
  }

  /**
	 * Generate a curve 25519 keypair
	 * @param {Uint8List} seed A 32 byte cryptographic secure random List. is basically the secret key
	 * @param {Object} Returns sk (Secret key) and pk (Public key) as 32 byte typed Lists
	 */
  Set<Uint8List> generateKeys(Uint8List seed) {
    // var sk = seed.slice();
    final Uint8List sk = seed;
    final Uint8List pk = Uint8List(32);
    if (sk.length != 32) {
      // throw new Error('Invalid secret key size, expected 32 bytes')
      throw Exception('Invalid secret key size, expected 32 bytes');
    }

    sk[0] &= 0xf8;
    sk[31] &= 0x7f;
    sk[31] |= 0x40;

    cryptoScalarmult(pk, sk, _9);

    return {
      sk,
      pk,
    };
  }

  /**
	 * Converts a ed25519 public key to Curve25519 to be used in
	 * Diffie-Hellman key exchange
	 */
  Uint8List? convertEd25519PublicKeyToCurve25519(Uint8List pk) {
    final Uint8List z = Uint8List(32);
    final List<Int32List> q = [gf(), gf(), gf(), gf()];
    final Int32List a = gf();
    final Int32List b = gf();

    // TODO: check if this is correct
    if (unpackNeg(q, pk) == 0) {
      return null;
    }

    final Int32List y = q[1];

    A(a, gf1, y);
    Z(b, gf1, y);
    inv25519(b, b);
    M(a, a, b);

    pack25519(z, a);

    return z;
  }

  /**
	 * Converts a ed25519 secret key to Curve25519 to be used in
	 * Diffie-Hellman key exchange
	 */
  Uint8List convertEd25519SecretKeyToCurve25519(Uint8List sk) {
    final Uint8List d = Uint8List(64);
    final Uint8List o = Uint8List(32);
    int i;

    cryptoHash(d, sk, 32);
    d[0] &= 248;
    d[31] &= 127;
    d[31] |= 64;

    for (i = 0; i < 32; i++) {
      o[i] = d[i];
    }

    for (i = 0; i < 64; i++) {
      d[i] = 0;
    }

    return o;
  }

  void cryptoHash(Uint8List out, Uint8List m, int n) {
    final Uint8List input = Uint8List(n);
    for (int i = 0; i < n; ++i) {
      input[i] = m[i];
    }

    final Uint8List hash = blake2b(input);
    for (int i = 0; i < 64; ++i) {
      out[i] = hash[i];
    }
  }
}
