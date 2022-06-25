import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';

/// Input formatter for Crypto/Fiat amounts
class CurrencyFormatter extends TextInputFormatter {
  String commaSeparator;
  String decimalSeparator;
  int maxDecimalDigits;

  CurrencyFormatter({this.commaSeparator = ",", this.decimalSeparator = ".", this.maxDecimalDigits = NumberUtil.maxDecimalDigits});

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    bool returnOriginal = true;
    if (newValue.text.contains(decimalSeparator) || newValue.text.contains(commaSeparator)) {
      returnOriginal = false;
    }

    // If no text, or text doesnt contain a period of comma, no work to do here
    if (newValue.selection.baseOffset == 0 || returnOriginal) {
      return newValue;
    }

    String workingText = newValue.text.replaceAll(commaSeparator, decimalSeparator);
    // if contains more than 2 decimals in newValue, return oldValue
    if (decimalSeparator.allMatches(workingText).length > 1) {
      return newValue.copyWith(text: oldValue.text, selection: new TextSelection.collapsed(offset: oldValue.text.length));
    } else if (workingText.startsWith(decimalSeparator)) {
      workingText = "0" + workingText;
    }

    final List<String> splitStr = workingText.split(decimalSeparator);
    // If this string contains more than 1 decimal, move all characters to after the first decimal
    if (splitStr.length > 2) {
      returnOriginal = false;
      splitStr.forEach((val) {
        if (splitStr.indexOf(val) > 1) {
          splitStr[1] += val;
        }
      });
    }
    if (splitStr[1].length <= maxDecimalDigits) {
      if (workingText == newValue.text) {
        return newValue;
      } else {
        return newValue.copyWith(text: workingText, selection: new TextSelection.collapsed(offset: workingText.length));
      }
    }
    final String newText = splitStr[0] + decimalSeparator + splitStr[1].substring(0, maxDecimalDigits);
    return newValue.copyWith(text: newText, selection: new TextSelection.collapsed(offset: newText.length));
  }
}

class LocalCurrencyFormatter extends TextInputFormatter {
  NumberFormat? currencyFormat;
  bool? active;

  LocalCurrencyFormatter({this.currencyFormat, this.active});

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.trim() == currencyFormat!.currencySymbol.trim() || newValue.text.isEmpty) {
      // Return empty string
      return newValue.copyWith(text: "", selection: new TextSelection.collapsed(offset: 0));
    }
    // Ensure our input is in the right formatting here
    if (active!) {
      // Make local currency = symbol + amount with correct decimal separator
      final String curText = newValue.text;
      String shouldBeText = NumberUtil.sanitizeNumber(curText.replaceAll(",", "."));
      shouldBeText = currencyFormat!.currencySymbol + shouldBeText.replaceAll(".", currencyFormat!.symbols.DECIMAL_SEP);
      if (shouldBeText != curText) {
        return newValue.copyWith(text: shouldBeText, selection: TextSelection.collapsed(offset: shouldBeText.length));
      }
    } else {
      // Make crypto amount have no symbol and formatted as US locale
      final String curText = newValue.text;
      final String shouldBeText = NumberUtil.sanitizeNumber(curText.replaceAll(",", "."));
      if (shouldBeText != curText) {
        return newValue.copyWith(text: shouldBeText, selection: TextSelection.collapsed(offset: shouldBeText.length));
      }
    }
    return newValue;
  }
}

/// Input formatter that ensures text starts with @
class ContactInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String workingText = newValue.text;
    if (!workingText.startsWith("★")) {
      workingText = "★" + workingText;
    }

    final List<String> splitStr = workingText.split('★');
    // If this string contains more than 1 @, remove all but the first one
    if (splitStr.length > 2) {
      workingText = "★" + workingText.replaceAll(r"★", "");
    }

    // If nothing changed, return original
    if (workingText == newValue.text) {
      return newValue;
    }

    return newValue.copyWith(text: workingText, selection: new TextSelection.collapsed(offset: workingText.length));
  }
}

/// Input formatter that ensures only one space between words
class SingleSpaceInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Don't allow first character to be a space
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    } else if (oldValue.text.length == 0 && newValue.text == " ") {
      return oldValue;
    } else if (oldValue.text.endsWith(" ") && newValue.text.endsWith("  ")) {
      return oldValue;
    }

    return newValue;
  }
}

/// Ensures input is always uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Ensures input is always lowercase
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

final BigInt rawPerNano = BigInt.from(10).pow(30);
final BigInt rawPerNyano = BigInt.from(10).pow(24);

// String getCurrencySymbol(BuildContext context) {
//   if (StateContainer.of(context).nyanoMode) {
//     // TODO: decide on a symbol
//     // Ꞥ ꞥ Ɏ ɏ ў Ȳ
//     // return "Ȳ";
//     return "";
//   } else {
//     return "Ӿ";
//   }
// }

TextSpan displayCurrencySymbol(BuildContext context, TextStyle textStyle, {String prefix = ""}) {
  if (StateContainer.of(context).nyanoMode) {
    return TextSpan(text: "${prefix}y", style: textStyle.copyWith(decoration: TextDecoration.lineThrough));
  }

  return TextSpan(text: "$prefixӾ", style: textStyle);

  // return const TextSpan();
}

List<TextSpan> displayRawFull(BuildContext context, TextStyle textStyle, String raw) {
  return [];
}

String getRawAsThemeAwareAmount(BuildContext context, String? raw) {
  final BigInt rawPerCur = StateContainer.of(context).nyanoMode ? rawPerNyano : rawPerNano;
  return NumberUtil.getRawAsUsableString(raw, rawPerCur);
}

String getThemeAwareRawAccuracy(BuildContext context, String? raw) {
  final BigInt rawPerCur = StateContainer.of(context).nyanoMode ? rawPerNyano : rawPerNano;
  final String rawString = NumberUtil.getRawAsUsableString(raw, rawPerCur);
  final String rawDecimalString = NumberUtil.getRawAsDecimal(raw, rawPerCur).toString();

  if (raw == null || raw.isEmpty || raw == "0") {
    return "";
  }

  if (rawString != rawDecimalString) {
    return "~";
  }
  return "";
}

// String getThemeAwareAccuracyAmount(BuildContext context, String? raw, TextStyle textStyle) {
  
// }
  

String getThemeAwareAmountAsRaw(BuildContext context, String amount) {
  if (StateContainer.of(context).nyanoMode) {
    return NumberUtil.getNyanoAmountAsRaw(amount);
  } else {
    return NumberUtil.getAmountAsRaw(amount);
  }
}

String getRawAsThemeAwareFormattedAmount(BuildContext context, String? raw) {
  final String amount = getRawAsThemeAwareAmount(context, raw);

  if (!amount.contains(".")) {
    // add commas to the amount:
    final RegExp reg = RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))");
    final String Function(Match) mathFunc = (Match match) => "${match[1]},";
    final String result = amount.replaceAllMapped(reg, mathFunc);
    return result;
  } else {
    final String numAmount = amount.split(".")[0];
    String decAmount = amount.split(".")[1];

    final RegExp reg = RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))");
    final String Function(Match) mathFunc = (Match match) => "${match[1]},";
    final String result = numAmount.replaceAllMapped(reg, mathFunc);

    // truncate:
    if (decAmount.length > NumberUtil.maxDecimalDigits) {
      decAmount = decAmount.substring(0, NumberUtil.maxDecimalDigits);
      // remove trailing zeros:
      decAmount = decAmount.replaceAllMapped(RegExp(r'0+$'), (Match match) => "");
    }

    return "$result.$decAmount";
  }
}

String getThemeAwareCombined(BuildContext context, String? raw) {
  return getThemeAwareRawAccuracy(context, raw) + getRawAsThemeAwareAmount(context, raw);
}

String getThemeCurrencyMode(BuildContext context) {
  if (StateContainer.of(context).nyanoMode) {
    return "NYANO";
  } else {
    return "NANO";
  }
}
