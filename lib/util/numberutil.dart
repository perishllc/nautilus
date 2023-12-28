import 'package:decimal/decimal.dart';

class NumberUtil {

  static const int maxDecimalDigits = 6; // Max digits after decimal

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
