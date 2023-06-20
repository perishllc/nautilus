import 'package:decimal/decimal.dart';

class NumberUtil {
  static const int maxDecimalDigits = 6; // Max digits after decimal
  static BigInt rawPerNano = BigInt.parse("1000000000000000000000000000000");
  static BigInt rawPerNyano = BigInt.parse("1000000000000000000000000");
  static BigInt rawPerBanano = BigInt.parse("100000000000000000000000000000");
  static BigInt rawPerXMR = BigInt.parse("1000000000000");
  static BigInt convertXMRtoNano = BigInt.parse("1000000000000000000");
  // static BigInt convertXMRtoNano = BigInt.parse("1000000000000000000000000000");

  /// Convert raw to ban and return as BigDecimal
  ///
  /// @param raw 100000000000000000000000000000
  /// @return Decimal value 1.000000000000000000000000000000
  ///
  static Decimal getRawAsDecimal(String? raw, BigInt? rawPerCur) {
    rawPerCur ??= rawPerNano;
    final Decimal amount = Decimal.parse(raw.toString());
    final Decimal result = (amount / Decimal.parse(rawPerCur.toString())).toDecimal();
    return result;
  }

  static String truncateDecimal(Decimal input, {int digits = maxDecimalDigits}) {
    Decimal bigger = input.shift(digits);
    bigger = bigger.floor(); // chop off the decimal: 1.059 -> 1.05
    bigger = bigger.shift(-digits);
    return bigger.toString();
  }

  /// Return raw as a NANO amount.
  ///
  /// @param raw 100000000000000000000000000000
  /// @returns 1
  ///
  static String getRawAsUsableString(String? raw, BigInt rawPerCur) {
    final String res = truncateDecimal(getRawAsDecimal(raw, rawPerCur), digits: maxDecimalDigits + 9);

    if (raw == null || raw == "0" || raw == "00000000000000000000000000000000") {
      return "0";
    }

    if (!res.contains(".")) {
      return res;
    }

    final String numAmount = res.split(".")[0];
    String decAmount = res.split(".")[1];

    // truncate:
    if (decAmount.length > maxDecimalDigits) {
      decAmount = decAmount.substring(0, NumberUtil.maxDecimalDigits);
      // remove trailing zeros:
      decAmount = decAmount.replaceAllMapped(RegExp(r'0+$'), (Match match) => '');
      if (decAmount.isEmpty) {
        return numAmount;
      }
    }

    return "$numAmount.$decAmount";
  }

  /// Return raw as a NYANO amount.
  ///
  /// @param raw 100000000000000000000000000000
  /// @returns 1
  ///
  // static String getRawAsNanoStringOld(String? raw) {
  //   NumberFormat nf = new NumberFormat.currency(locale: 'en_US', decimalDigits: maxDecimalDigits, symbol: '');
  //   String asString = nf.format(truncateDecimal(getRawAsNyanoDecimal(raw)));
  //   var split = asString.split(".");
  //   if (split.length > 1) {
  //     // Remove trailing 0s from this
  //     if (int.parse(split[1]) == 0) {
  //       asString = split[0];
  //     } else {
  //       String newStr = split[0] + ".";
  //       String digits = split[1];
  //       int endIndex = digits.length;
  //       for (int i = 1; i <= digits.length; i++) {
  //         if (int.parse(digits[digits.length - i]) == 0) {
  //           endIndex--;
  //         } else {
  //           break;
  //         }
  //       }
  //       digits = digits.substring(0, endIndex);
  //       newStr = split[0] + "." + digits;
  //       asString = newStr;
  //     }
  //   }
  //   return asString;
  // }

  // static String getNanoStringAsNyano(String amount) {
  //   String raw = getAmountAsRaw(amount);
  //   String nyano = getRawAsUsableString(raw, rawPerNyano);
  //   return nyano;
  // }

  /// Return readable string amount as raw string
  /// @param amount 1.01
  /// @returns  101000000000000000000000
  ///
  static String getNyanoAmountAsRaw(String amount) {
    final Decimal asDecimal = Decimal.parse(amount);
    final Decimal rawDecimal = Decimal.parse(rawPerNyano.toString());
    return (asDecimal * rawDecimal).toString();
  }

  static String getBananoAmountAsRaw(String amount) {
    final Decimal asDecimal = Decimal.parse(amount);
    final Decimal rawDecimal = Decimal.parse(rawPerBanano.toString());
    return (asDecimal * rawDecimal).toString();
  }

  /// Return readable string amount as raw string
  /// @param amount 1.01
  /// @returns  101000000000000000000000000000
  ///
  static String getAmountAsRaw(String amount) {
    final Decimal asDecimal = Decimal.parse(amount);
    final Decimal rawDecimal = Decimal.parse(rawPerNano.toString());
    return (asDecimal * rawDecimal).toString();
  }

  static String getXMRAmountAsRaw(String amount) {
    final Decimal asDecimal = Decimal.parse(amount);
    final Decimal rawDecimal = Decimal.parse(rawPerXMR.toString());
    return (asDecimal * rawDecimal).toString();
  }

  /// Return percentage of total supploy
  /// @param amount 10020243004141
  /// @return 0.0000001%
  static String getPercentOfTotalSupply(BigInt amount) {
    final Decimal totalSupply = Decimal.parse('133248290000000000000000000000000000000');
    final Decimal amountRaw = Decimal.parse(amount.toString());
    return ((amountRaw / totalSupply).toDecimal(scaleOnInfinitePrecision: maxDecimalDigits) * Decimal.fromInt(100))
        .toStringAsFixed(4);
  }

  /// Sanitize a number as something that can actually
  /// be parsed. Expects "." to be decimal separator
  /// @param amount $1,512
  /// @returns 1.512
  static String sanitizeNumber(String input, {int maxDecimalDigits = maxDecimalDigits}) {
    String sanitized = "";
    final List<String> splitStr = input.split(".");
    if (splitStr.length > 1) {
      if (splitStr[1].length > maxDecimalDigits) {
        splitStr[1] = splitStr[1].substring(0, maxDecimalDigits);
        input = "${splitStr[0]}.${splitStr[1]}";
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
