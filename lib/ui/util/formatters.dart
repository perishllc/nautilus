import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/util/numberutil.dart';

/// Input formatter for Crypto/Fiat amounts
int findDifferentCharacterInString(String str1, String str2) {
  for (int i = 0; i < str1.length; i++) {
    if (i > str2.length - 1) {
      return i;
    }
    if (str1[i] != str2[i]) {
      return i;
    }
  }
  return -1;
}

/// Input formatter for Crypto/Fiat amounts
class CurrencyFormatter2 extends TextInputFormatter {
  CurrencyFormatter2(
      {required this.currencyFormat, this.maxDecimalDigits = NumberUtil.maxDecimalDigits, this.active = false});

  NumberFormat currencyFormat;
  int maxDecimalDigits;
  bool active;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String commaSeparator = currencyFormat.symbols.GROUP_SEP;
    final String decimalSeparator = currencyFormat.symbols.DECIMAL_SEP;
    final String currencySymbol = currencyFormat.currencySymbol;
    // final int maxDecimalDigits = currencyFormat.decimalDigits!;

    final TextEditingValue same = newValue.copyWith(text: oldValue.text, selection: oldValue.selection);
    String workingText = newValue.text;
    int workingOffset = 0;
    final String oldText = oldValue.text;
    final int oldSelectionOffset = oldValue.selection.extentOffset;
    final TextSelection oldSelection = oldValue.selection;

    // deny illegal moves:
    if (workingText == "") {
      return newValue;
    }

    // deny if trying to add a 2nd decimalSeparator:
    if (decimalSeparator.allMatches(workingText).length > 1) {
      return same;
    }

    workingOffset += newValue.text.length - oldValue.text.length;

    // we added 1 character:
    if (workingText.length == oldValue.text.length + 1) {
      // OLD:
      // // we added a comma, attempt to replace it with a decimalSeparator if there isn't one already:
      // if (commaSeparator.allMatches(workingText).length > commaSeparator.allMatches(oldValue.text).length) {
      //   // return if we already have a decimalSeparator:
      //   if (workingText.contains(decimalSeparator)) {
      //     return same;
      //   }
      //   // replace the comma with a decimalSeparator:
      //   // find the index of the comma:
      //   final int commaIndex = findDifferentCharacterInString(workingText, oldValue.text);
      //   workingText = workingText.substring(0, commaIndex) + decimalSeparator + workingText.substring(commaIndex + 1);
      // }

      // NEW:

      // find the index of the new character:
      final int newCharIndex = findDifferentCharacterInString(workingText, oldValue.text);
      final String newChar = workingText[newCharIndex];
      // if the new character isn't a number, replace the character with a decimalSeparator:
      if (!RegExp(r"^\d$").hasMatch(newChar)) {
        // replace the comma with a decimalSeparator:
        workingText =
            workingText.substring(0, newCharIndex) + decimalSeparator + workingText.substring(newCharIndex + 1);
      }
    }

    // we deleted 1 character:
    if (workingText.length == oldValue.text.length - 1) {
      // we deleted a comma, remove the number behind it instead:
      if (commaSeparator.allMatches(workingText).length < commaSeparator.allMatches(oldValue.text).length) {
        // get the pos of the comma - 1:
        final int commaPos = oldText.indexOf(commaSeparator) - 1;
        // remove the number behind the comma and the comma:
        if (commaPos >= 0) {
          workingText = oldText.substring(0, commaPos + 1) + oldText.substring(commaPos + 1);
          workingOffset -= 1;
        }
      }
      // // we deleted a decimal, remove the number behind it instead:
      // if (decimalSeparator.allMatches(workingText).length < decimalSeparator.allMatches(oldValue.text).length) {
      //   // get the pos of the decimal - 1:
      //   final int decimalPos = workingText.indexOf(decimalSeparator) - 1;
      //   if (decimalPos >= 0) {
      //     workingText = workingText.substring(0, decimalPos) + workingText.substring(decimalPos + 1);
      //   }
      // }
    }

    if (workingText.startsWith(commaSeparator)) {
      return same;
    }

    if (workingText.length == 1) {
      if (workingText != decimalSeparator &&
          workingText != currencySymbol &&
          !["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(workingText)) {
        return same;
      }
    }

    // prevent numbers from starting with a decimal:
    if (workingText.startsWith(decimalSeparator)) {
      workingText = "0$workingText";
      workingOffset += 1;
    }

    // make sure that the text follows the format of the local currency:
    String localizedAmount = convertCryptoToLocalAmount(
        workingText.replaceAll(commaSeparator, "").replaceAll(currencySymbol, ""), currencyFormat);
    if (active) {
      localizedAmount = currencySymbol + localizedAmount.trim();
    } else {
      localizedAmount = localizedAmount.trim();
    }
    int amountLengthChanged = 0;
    amountLengthChanged = localizedAmount.length - workingText.length;
    workingOffset += amountLengthChanged;

    // print("$localizedAmount : $workingText : $amountLengthChanged");

    // edge case:
    if (amountLengthChanged < 0 && newValue.text.startsWith(decimalSeparator)) {
      workingOffset += 1;
    }

    workingText = localizedAmount;

    // split into parts:
    final List<String> splitStr = workingText.split(decimalSeparator);

    // cap the number of decimal digits if necessary:
    if (splitStr.length > 1 && newValue.text.contains(decimalSeparator)) {
      // workingText = splitStr[0] + decimalSeparator + splitStr[1].substring(0, min(maxDecimalDigits, splitStr[1].length));
      if (splitStr[1].length > maxDecimalDigits) {
        return same;
      }
    }

    if (splitStr[0].length > 13) {
      return same;
    }

    // selection:
    workingOffset += oldSelectionOffset;
    // print("oldSel: $oldSelectionOffset");
    // print("newSel: $workingOffset");

    // if (workingText == oldValue.text) {
    //   newSelection = oldSelection;
    // } else if (oldSelection.baseOffset < workingText.length - 1) {
    //   if (newValue.text.startsWith(decimalSeparator)) {
    //     offset = 1;
    //   }
    //   // move the cursor back by one if this was a backspace:
    //   if (newValue.text.length == oldValue.text.length - 1) {
    //     offset = -2;
    //   }
    //   newSelection = TextSelection.collapsed(offset: oldSelection.baseOffset + 1 + offset);
    // } else {
    //   newSelection = TextSelection.collapsed(offset: workingText.length);
    // }
    TextSelection newSelection;
    if (workingText == oldValue.text || workingText.length == oldValue.text.length) {
      newSelection = oldSelection;
    } else {
      newSelection = TextSelection.collapsed(offset: workingOffset);
    }

    return newValue.copyWith(text: workingText, selection: newSelection);
  }
}

String convertLocalToCrypto(String cryptoAmount, NumberFormat? currencyFormat) {
  return "";
}

// formats to 1,456,789.123456:
String normalizedAmount(NumberFormat currencyFormat, String amount) {
  amount = amount.replaceAll(currencyFormat.symbols.DECIMAL_SEP, "D");
  amount = amount.replaceAll(currencyFormat.symbols.GROUP_SEP, "G");
  amount = amount.replaceAll("D", ".").replaceAll("G", ",");
  return amount;
}

// ONLY the format of: 1234.12345
// MUST be parseable
String sanitizedAmount(NumberFormat currencyFormat, String amount) {
  amount = normalizedAmount(currencyFormat, amount);
  amount = amount.replaceAll(",", "").replaceAll(currencyFormat.currencySymbol, "").replaceAll(" ", "").trim();
  if (amount.endsWith(".")) {
    amount = amount.substring(0, amount.length - 1);
  }
  return amount;
}

String convertCryptoToLocalAmount(String localAmount, NumberFormat currencyFormat) {
  // Make local currency = symbol + amount with correct decimal separator
  final String sanitizedText = sanitizedAmount(currencyFormat, localAmount);
  final List<String> splitStrs = sanitizedText.split(".");
  final String firstPart = splitStrs[0].trim();
  String secondPart = sanitizedText.split(".").length > 1 ? splitStrs[1].trim() : "";

  if (secondPart.isNotEmpty || localAmount.contains(currencyFormat.symbols.DECIMAL_SEP)) {
    secondPart = currencyFormat.symbols.DECIMAL_SEP + secondPart;
  }

  if (firstPart.isEmpty) {
    return "";
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

String convertLocalCurrencyToLocalizedCrypto(BuildContext context, NumberFormat localCurrencyFormat, String amount) {
  final String sanitizedAmt = sanitizedAmount(localCurrencyFormat, amount);
  if (sanitizedAmt.isEmpty) {
    return "";
  }
  final Decimal valueLocal = Decimal.parse(sanitizedAmt);
  final Decimal conversion = Decimal.parse(StateContainer.of(context).wallet!.localCurrencyConversion!);
  final String nanoAmount =
      NumberUtil.truncateDecimal((valueLocal / conversion).toDecimal(scaleOnInfinitePrecision: 16));

  // replace dec separator as this function expects the localized version:
  // no need to put the group separator back in as it's stripped again anyways:
  final String localizedNanoAmount = nanoAmount.replaceAll(".", localCurrencyFormat.symbols.DECIMAL_SEP);

  return convertCryptoToLocalAmount(localizedNanoAmount, localCurrencyFormat);
}

String convertCryptoToLocalCurrency(BuildContext context, NumberFormat localCurrencyFormat, String amount) {
  String sanitizedAmt = amount
      .replaceAll(localCurrencyFormat.symbols.GROUP_SEP, "")
      .replaceAll(localCurrencyFormat.symbols.DECIMAL_SEP, ".");
  sanitizedAmt = NumberUtil.sanitizeNumber(sanitizedAmt);
  if (sanitizedAmt.isEmpty) {
    return "";
  }
  final Decimal valueCrypto = Decimal.parse(sanitizedAmt);
  final Decimal conversion = Decimal.parse(StateContainer.of(context).wallet!.localCurrencyConversion!);
  sanitizedAmt = NumberUtil.truncateDecimal(valueCrypto * conversion, digits: 2);

  return (localCurrencyFormat.currencySymbol + convertCryptoToLocalAmount(sanitizedAmt, localCurrencyFormat))
      .replaceAll(" ", "");
}

/// Input formatter that ensures text starts with @
class ContactInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String workingText = newValue.text;
    if (!workingText.startsWith("★")) {
      workingText = "★$workingText";
    }

    final List<String> splitStr = workingText.split('★');
    // If this string contains more than 1 @, remove all but the first one
    if (splitStr.length > 2) {
      workingText = "★${workingText.replaceAll(r"★", "")}";
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
  @override
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
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Ensures input is always lowercase
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}

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

  if (StateContainer.of(context).bananoMode) {
    return TextSpan(text: "${prefix}B", style: textStyle.copyWith(decoration: TextDecoration.lineThrough));
  }

  return TextSpan(text: "$prefixӾ", style: textStyle);

  // return const TextSpan();
}

String getCurrencySuffix(BuildContext context) {
  if (StateContainer.of(context).nyanoMode) {
    return " nyano)";
  }
  if (StateContainer.of(context).bananoMode) {
    return " banano)";
  }
  return " NANO)";
}

List<TextSpan> displayRawFull(BuildContext context, TextStyle textStyle, String raw) {
  return [];
}

String getRawAsThemeAwareAmount(BuildContext context, String? raw) {
  final BigInt rawPerCur = StateContainer.of(context).nyanoMode
      ? NumberUtil.rawPerNyano
      : StateContainer.of(context).bananoMode
          ? NumberUtil.rawPerBanano
          : NumberUtil.rawPerNano;
  return NumberUtil.getRawAsUsableString(raw, rawPerCur); // "$amount.$decPart"
}

String getThemeAwareRawAccuracy(BuildContext context, String? raw) {
  final BigInt rawPerCur = StateContainer.of(context).nyanoMode
      ? NumberUtil.rawPerNyano
      : StateContainer.of(context).bananoMode
          ? NumberUtil.rawPerBanano
          : NumberUtil.rawPerNano;
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

String getXMRRawAsThemeAwareAmount(BuildContext context, String? raw) {
  final BigInt rawPerCur = NumberUtil.rawPerXMR;
  return NumberUtil.getRawAsUsableString(raw, rawPerCur); // "$amount.$decPart"
}

String getXMRThemeAwareRawAccuracy(BuildContext context, String? raw) {
  final BigInt rawPerCur = NumberUtil.rawPerXMR;
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
  } else if (StateContainer.of(context).bananoMode) {
    return NumberUtil.getBananoAmountAsRaw(amount);
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

  //final String formattedAmount =
  //    currencyFormat.format(double.parse(amountStr)).replaceAll(StateContainer.of(context).curCurrency.getCurrencySymbol(), "").replaceAll(" ", "");
  final String formattedAmount = currencyFormat
      .format(double.parse(amountStr.split(".")[0]))
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

// card time format:
// String CARD_TIME_FORMAT = "MMM d, h:mm a";
// ignore: non_constant_identifier_names
// String CARD_TIME_FORMAT = "MMM dd, HH:mm";
String OLD_CARD_TIME_FORMAT = "MMM dd, HH:mm";
String CARD_TIME_FORMAT = "y/MM/dd, HH:mm";
String CARD_HOUR_TIME_FORMAT = "HH:mm";
String getTimeAgoString(BuildContext context, int epochTime) {
  String timeStr = DateFormat(CARD_TIME_FORMAT).format(DateTime.fromMillisecondsSinceEpoch(epochTime * 1000));

  // current time in epoch seconds:
  final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // time difference in seconds:
  final int diff = now - epochTime;

  // check if it's a few seconds ago, a minute ago, etc.

  if (diff < 60) {
    // a few seconds ago
    timeStr = Z.of(context).fewSecondsAgo;
  } else if (diff < 86400) {
    // check if it's today or yesterday
    final DateTime nowDate = DateTime.now();
    final DateTime epochDate = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    if (nowDate.day == epochDate.day && nowDate.month == epochDate.month) {
      // today at: xx:xx
      timeStr =
          "${Z.of(context).todayAt} ${DateFormat(CARD_HOUR_TIME_FORMAT).format(DateTime.fromMillisecondsSinceEpoch(epochTime * 1000))}";
    } else if (nowDate.day - 1 == epochDate.day && nowDate.month == epochDate.month) {
      // yesterday at: xx:xx
      timeStr =
          "${Z.of(context).yesterdayAt} ${DateFormat(CARD_HOUR_TIME_FORMAT).format(DateTime.fromMillisecondsSinceEpoch(epochTime * 1000))}";
    }
    // today at: xx:xx
    // timeStr = "Today at ${DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(epochTime * 1000))}";
  }

  // if (diff < 60) {
  //   // a few seconds ago
  //   timeStr = Z.of(context).fewSecondsAgo;
  // } else if (diff < 120) {
  //   // a minute ago
  //   timeStr = Z.of(context).minuteAgo;
  // } else if (diff < 3600) {
  //   // 2-60 minutes ago
  //   timeStr = Z.of(context).fewMinutesAgo;
  // } else if (diff < 7200) {
  //   // 1-2 hours ago
  //   timeStr = Z.of(context).hourAgo;
  // } else if (diff < 86400) {
  //   // 2-24 hours ago
  //   timeStr = Z.of(context).fewHoursAgo;
  // } else if (diff < 172800) {
  //   // 24-48 hours ago
  //   timeStr = Z.of(context).dayAgo;
  // } else if (diff < 604800) {
  //   // 2-7 days ago
  //   timeStr = Z.of(context).fewDaysAgo;
  // } else if (diff < 1209600) {
  //   // 1-2 weeks ago
  //   timeStr = Z.of(context).weekAgo;
  // }

  return timeStr;
}

String getCardTime(int epochTime) {
  final String timeStr = DateFormat(CARD_TIME_FORMAT).format(DateTime.fromMillisecondsSinceEpoch(epochTime * 1000));
  return timeStr;
}

String getOldCardTime(int epochTime) {
  final String timeStr = DateFormat(OLD_CARD_TIME_FORMAT).format(DateTime.fromMillisecondsSinceEpoch(epochTime * 1000));
  return timeStr;
}
