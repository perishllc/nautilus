import 'dart:math';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

class NumberUtil {
  static final BigInt rawPerNano = BigInt.from(10).pow(30);
  static final BigInt rawPerNyano = BigInt.from(10).pow(24);
  static const int maxDecimalDigits = 6; // Max digits after decimal

  /// Convert raw to ban and return as BigDecimal
  ///
  /// @param raw 100000000000000000000000000000
  /// @return Decimal value 1.000000000000000000000000000000
  ///
  static Decimal getRawAsUsableDecimal(String raw) {
    Decimal amount = Decimal.parse(raw.toString());
    Decimal result = amount / Decimal.parse(rawPerNano.toString());
    return result;
  }

  /// Truncate a Decimal to a specific amount of digits
  ///
  /// @param input 1.059
  /// @return double value 1.05
  ///
  static double truncateDecimal(Decimal input, {int digits = maxDecimalDigits}) {
    return (input * Decimal.fromInt(pow(10, digits))).truncateToDouble() / pow(10, digits);
  }

  /// Return raw as a normal amount.
  ///
  /// @param raw 100000000000000000000000000000
  /// @returns 1
  ///
  static String getRawAsUsableString(String raw) {
    NumberFormat nf = new NumberFormat.currency(locale: 'en_US', decimalDigits: maxDecimalDigits, symbol: '');
    String asString = nf.format(truncateDecimal(getRawAsUsableDecimal(raw)));
    var split = asString.split(".");
    if (split.length > 1) {
      // Remove trailing 0s from this
      if (int.parse(split[1]) == 0) {
        asString = split[0];
      } else {
        String newStr = split[0] + ".";
        String digits = split[1];
        int endIndex = digits.length;
        for (int i = 1; i <= digits.length; i++) {
          if (int.parse(digits[digits.length - i]) == 0) {
            endIndex--;
          } else {
            break;
          }
        }
        digits = digits.substring(0, endIndex);
        newStr = split[0] + "." + digits;
        asString = newStr;
      }
    }
    return asString;
  }

  /// Return raw as a normal amount.
  ///
  /// @param raw 100000000000000000000000000000
  /// @returns 1
  ///
  static String getRawAsNyanoString(String raw) {
    print(raw);
    NumberFormat nf = new NumberFormat.currency(locale: 'en_US', decimalDigits: maxDecimalDigits, symbol: '');
    String asString = nf.format(truncateDecimal(getRawAsUsableDecimal(raw)));
    var split = asString.split(".");
    // log this:
    // print(split);
    if (split.length > 1) {
      // Remove trailing 0s from this
      if (int.parse(split[1]) == 0) {
        asString = split[0] * 1000000;
      } else {
        // print(split[0]);
        String newStr = (int.parse(split[0]) * 1000000).toString();
        String digits = split[1];
        int toMove = 6;
        String buildStr = "";

        // digits.length is never more than 6 so I can cheat here a bit:

        for (int i = 0; i < digits.length; i++) {
          buildStr += digits[i];
          toMove--;
        }

        // buildStr = (int.parse(buildStr) * pow(10, toMove)).toString();

        buildStr = newStr.substring(0, newStr.length - (6 - toMove)) + buildStr;
        asString = buildStr;
      }
    }

    // if (asString != "0") {
    //   asString = asString + "00000";
    // }

    // remove "0." from the beginning of the string:
    // if (asString.startsWith("0.")) {
    //   asString = asString.substring(2, asString.length);
    // }

    return asString;
  }

  static String getNanoStringAsNyano(String amount) {
    String raw = getAmountAsRaw(amount);
    print("raw: " + raw);
    String nyano = getRawAsNyanoString(raw);
    print("nyano: " + nyano);
    return nyano;
  }

  /// Return readable string amount as raw string
  /// @param amount 1.01
  /// @returns  101000000000000000000000000000
  ///
  static String getAmountAsRaw(String amount) {
    Decimal asDecimal = Decimal.parse(amount);
    Decimal rawDecimal = Decimal.parse(rawPerNano.toString());
    return (asDecimal * rawDecimal).toString();
  }

  /// Return percentage of total supploy
  /// @param amount 10020243004141
  /// @return 0.0000001%
  static String getPercentOfTotalSupply(BigInt amount) {
    Decimal totalSupply = Decimal.parse('133248290000000000000000000000000000000');
    Decimal amountRaw = Decimal.parse(amount.toString());
    return ((amountRaw / totalSupply) * Decimal.fromInt(100)).toStringAsFixed(4);
  }

  /// Sanitize a number as something that can actually
  /// be parsed. Expects "." to be decimal separator
  /// @param amount $1,512
  /// @returns 1.512
  static String sanitizeNumber(String input, {int maxDecimalDigits = maxDecimalDigits}) {
    String sanitized = "";
    List<String> splitStr = input.split(".");
    if (splitStr.length > 1) {
      if (splitStr[1].length > maxDecimalDigits) {
        splitStr[1] = splitStr[1].substring(0, maxDecimalDigits);
        input = splitStr[0] + "." + splitStr[1];
      }
    }
    for (int i = 0; i < input.length; i++) {
      try {
        if (input[i] == ".") {
          sanitized = sanitized + input[i];
        } else {
          int.parse(input[i]);
          sanitized = sanitized + input[i];
        }
      } catch (e) {}
    }
    return sanitized;
  }
}
