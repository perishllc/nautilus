import 'dart:math';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautilus_wallet_flutter/util/numberutil.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';

/// Input formatter for Crypto/Fiat amounts
class CurrencyFormatter extends TextInputFormatter {
  CurrencyFormatter({required this.currencyFormat, this.maxDecimalDigits = NumberUtil.maxDecimalDigits});

  NumberFormat currencyFormat;
  int maxDecimalDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String commaSeparator = currencyFormat.symbols.GROUP_SEP;
    final String decimalSeparator = currencyFormat.symbols.DECIMAL_SEP;
    // final int maxDecimalDigits = currencyFormat.decimalDigits!;

    if (!newValue.text.contains(decimalSeparator) && !newValue.text.contains(commaSeparator)) {
      return newValue;
    }

    String workingText = newValue.text.replaceAll(commaSeparator, "");
    // if contains more than 2 decimals in newValue, return oldValue
    if (decimalSeparator.allMatches(workingText).length > 1) {
      return newValue.copyWith(text: oldValue.text, selection: oldValue.selection);
    }

    if (workingText.startsWith(decimalSeparator)) {
      workingText = "0$workingText";
    }

    final List<String> splitStr = workingText.split(decimalSeparator);

    // If this string contains more than 1 decimal, move all characters to after the first decimal
    // if (splitStr.length > 2) {
    //   returnOriginal = false;
    //   splitStr.forEach((val) {
    //     if (splitStr.indexOf(val) > 1) {
    //       splitStr[1] += val;
    //     }
    //   });
    // }
    // if (splitStr.isNotEmpty && splitStr[1].length > maxDecimalDigits) {
    //   // if (workingText == newValue.text) {
    //   //   return newValue;
    //   // } else {
    //   //   return newValue.copyWith(text: workingText, selection: TextSelection.collapsed(offset: workingText.length));
    //   // }
    //   return oldValue;
    // }
    late String newText;
    if (splitStr.length > 1 && newValue.text.contains(decimalSeparator)) {
      newText = splitStr[0] + decimalSeparator + splitStr[1].substring(0, min(maxDecimalDigits, splitStr[1].length));
    } else {
      newText = newValue.text;
    }

    if (splitStr[0].length > 13) {
      return newValue.copyWith(text: oldValue.text, selection: oldValue.selection);
    }

    // selection:
    final TextSelection oldSelection = oldValue.selection;
    TextSelection newSelection;
    if (newText == oldValue.text) {
      newSelection = oldSelection;
    } else if (oldSelection.baseOffset < newText.length - 1) {
      int offset = 0;
      if (newValue.text.startsWith(decimalSeparator)) {
        offset = 1;
      }
      // move the cursor back by one if this was a backspace:
      if (newValue.text.length == oldValue.text.length - 1) {
        offset = -2;
      }
      newSelection = TextSelection.collapsed(offset: oldSelection.baseOffset + 1 + offset);
    } else {
      newSelection = TextSelection.collapsed(offset: newText.length);
    }

    return newValue.copyWith(text: newText, selection: newSelection);
  }
}

class LocalCurrencyFormatter extends TextInputFormatter {
  LocalCurrencyFormatter({this.currencyFormat, this.active});

  NumberFormat? currencyFormat;
  bool? active;

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.trim() == currencyFormat!.currencySymbol.trim() ||
        newValue.text.isEmpty ||
        newValue.text == " ") {
      // Return empty string
      return newValue.copyWith(text: "", selection: const TextSelection.collapsed(offset: 0));
    }

    String shouldBeText = convertCryptoToLocalAmount(newValue.text, currencyFormat);
    if (active!) {
      shouldBeText = currencyFormat!.currencySymbol + shouldBeText;
    }

    if (shouldBeText != newValue.text) {
      // find selection:
      final TextSelection oldSelection = oldValue.selection;
      TextSelection newSelection;
      if (shouldBeText == oldValue.text) {
        newSelection = oldSelection;
      } else if (oldSelection.baseOffset < shouldBeText.length) {
        int offset = 0;
        // if (newValue.text.startsWith(decimalSeparator)) {
        //   offset = 1;
        // }
        final int diff = shouldBeText.length - oldValue.text.length;
        // move the cursor back by one if this was a backspace:
        if (shouldBeText.length > oldValue.text.length) {
          offset = diff;
        } else if (shouldBeText.length < oldValue.text.length) {
          offset = diff;
        }
        newSelection = TextSelection.collapsed(offset: max(oldSelection.baseOffset + offset, 0));
      } else {
        newSelection = TextSelection.collapsed(offset: shouldBeText.length);
      }

      return newValue.copyWith(text: shouldBeText, selection: newSelection);
    }
    // } else {
    //   // Make crypto amount have no symbol and formatted as US locale
    //   final String curText = newValue.text;
    //   final String shouldBeText = NumberUtil.sanitizeNumber(curText.replaceAll(",", "."));
    //   if (shouldBeText != curText) {
    //     return newValue.copyWith(text: shouldBeText, selection: TextSelection.collapsed(offset: shouldBeText.length));
    //   }
    // }
    return newValue;
  }
}

String convertLocalToCrypto(String cryptoAmount, NumberFormat? currencyFormat) {
  return "";
}

String convertCryptoToLocalAmount(String localAmount, NumberFormat? currencyFormat) {
  // Make local currency = symbol + amount with correct decimal separator
  final String sanitizedText = localAmount
      .replaceAll(currencyFormat!.symbols.GROUP_SEP, "")
      .replaceAll(currencyFormat.currencySymbol, "")
      .replaceAll(" ", "");
  final List<String> splitStrs = sanitizedText.split(currencyFormat.symbols.DECIMAL_SEP);
  final String firstPart = splitStrs[0].trim();
  String secondPart = sanitizedText.split(currencyFormat.symbols.DECIMAL_SEP).length > 1 ? splitStrs[1].trim() : "";

  if (secondPart.isNotEmpty || localAmount.contains(currencyFormat.symbols.DECIMAL_SEP)) {
    secondPart = currencyFormat.symbols.DECIMAL_SEP + secondPart;
  }
  // shouldBeText = currencyFormat!.currencySymbol + shouldBeText.replaceAll(".", currencyFormat!.symbols.DECIMAL_SEP);

  // add commas based on locale:

  // group separator: currencyFormat!.symbols.GROUP_SEP
  // decimal separator: currencyFormat!.symbols.DECIMAL_SEP
  // print("newValue: " + localAmount);
  // print("sanitizedText: " + sanitizedText);
  // print("firstPart: " + firstPart);
  // print("secondPart: " + secondPart);

  final NumberFormat formatCurrency = NumberFormat.simpleCurrency(
      decimalDigits: currencyFormat.decimalDigits, locale: currencyFormat.locale, name: currencyFormat.currencyName);
  String formattedCurrency = formatCurrency.format(int.parse(firstPart));

  formattedCurrency = formattedCurrency
      .split(currencyFormat.symbols.DECIMAL_SEP)[0]
      .replaceAll(currencyFormat.currencySymbol, "")
      .replaceAll(" ", "");
  return formattedCurrency + secondPart;
}

/// Input formatter that ensures text starts with @
class ContactInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String workingText = newValue.text;
    if (!workingText.startsWith("???")) {
      workingText = "???$workingText";
    }

    final List<String> splitStr = workingText.split('???');
    // If this string contains more than 1 @, remove all but the first one
    if (splitStr.length > 2) {
      workingText = "???${workingText.replaceAll(r"???", "")}";
    }

    // If nothing changed, return original
    if (workingText == newValue.text) {
      return newValue;
    }

    return newValue.copyWith(text: workingText, selection: TextSelection.collapsed(offset: workingText.length));
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
    } else if (oldValue.text.isEmpty && newValue.text == " ") {
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
//     // ??? ??? ?? ?? ?? ??
//     // return "??";
//     return "";
//   } else {
//     return "??";
//   }
// }

TextSpan displayCurrencySymbol(BuildContext context, TextStyle textStyle, {String prefix = ""}) {
  if (StateContainer.of(context).nyanoMode) {
    return TextSpan(text: "${prefix}y", style: textStyle.copyWith(decoration: TextDecoration.lineThrough));
  }

  return TextSpan(text: "$prefix??", style: textStyle);

  // return const TextSpan();
}

List<TextSpan> displayRawFull(BuildContext context, TextStyle textStyle, String raw) {
  return [];
}

String getRawAsThemeAwareAmount(BuildContext context, String? raw) {
  final BigInt rawPerCur = StateContainer.of(context).nyanoMode ? rawPerNyano : rawPerNano;
  return NumberUtil.getRawAsUsableString(raw, rawPerCur); // "$amount.$decPart"
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
  final String amountStr = getRawAsThemeAwareAmount(context, raw);

  // if (!amount.contains(".")) {
  //   // add commas to the amount:
  //   final RegExp reg = RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))");
  //   final String Function(Match) mathFunc = (Match match) => "${match[1]},";
  //   final String result = amount.replaceAllMapped(reg, mathFunc);
  //   return result;
  // } else {
  //   final String numAmount = amount.split(".")[0];
  //   String decAmount = amount.split(".")[1];

  //   final RegExp reg = RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))");
  //   final String Function(Match) mathFunc = (Match match) => "${match[1]},";
  //   final String result = numAmount.replaceAllMapped(reg, mathFunc);

  //   // truncate:
  //   if (decAmount.length > NumberUtil.maxDecimalDigits) {
  //     decAmount = decAmount.substring(0, NumberUtil.maxDecimalDigits);
  //     // remove trailing zeros:
  //     decAmount = decAmount.replaceAllMapped(RegExp(r'0+$'), (Match match) => "");
  //   }
  //   return "$result.$decAmount";
  // }

  final NumberFormat currencyFormat = NumberFormat.currency(
      locale: StateContainer.of(context).curCurrency.getLocale().toString(),
      symbol: StateContainer.of(context).curCurrency.getCurrencySymbol());

  final String formattedAmount = currencyFormat
      .format(double.parse(amountStr))
      .replaceAll(StateContainer.of(context).curCurrency.getCurrencySymbol(), "")
      .replaceAll(" ", "");

  final String decimalSeparator = currencyFormat.symbols.DECIMAL_SEP;
  // split by the decimal separator:
  final List<String> splitStrs = formattedAmount.split(decimalSeparator);
  final String firstPart = splitStrs[0];
  if (amountStr.contains(".")) {
    final String secondPart = amountStr.split(".")[1];
    return "$firstPart$decimalSeparator$secondPart";
  }
  return firstPart;
}

String getThemeAwareAccuracyAmount(BuildContext context, String? raw) {
  return getThemeAwareRawAccuracy(context, raw) + getRawAsThemeAwareAmount(context, raw);
}

String getThemeCurrencyMode(BuildContext context) {
  if (StateContainer.of(context).nyanoMode) {
    return "NYANO";
  } else {
    return "NANO";
  }
}
