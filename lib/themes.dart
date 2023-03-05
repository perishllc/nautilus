// ignore_for_file: annotate_overrides, overridden_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum OverlayTheme {
  KALIUM,
  NATRIUM,
  IRIDIUM,
  TITANIUM,
  BERYLLIUM,
  RUTHIUM,
  RADIUM,
  INDIUM,
  NEPTUNIUM,
  THORIUM,
  CARBON,
  URANIUM,
  BLAISE,
  BLAISEDARK,
  COPPER,
  MONOCHROME,
  MIDNIGHT,
  SUNSHINE,
  PERISHABLE,
}

abstract class BaseTheme {
  Color? primary;
  Color? primary60;
  Color? primary45;
  Color? primary30;
  Color? primary20;
  Color? primary15;
  Color? primary10;

  Color? success;
  Color? success60;
  Color? success45;
  Color? success30;
  Color? success15;
  Color? successDark;
  Color? successDark30;

  Color? warning;
  Color? warning60;
  Color? warning45;
  Color? warning30;
  Color? warning15;
  Color? warningDark;
  Color? warningDark30;

  Color? error;
  Color? error60;
  Color? error30;
  Color? error15;
  Color? errorDark;
  Color? errorDark30;

  Color? background;
  Color? background40;
  Color? background00;

  Color? backgroundDark;
  Color? backgroundDark00;

  Color? backgroundDarkest;

  Color? text;
  Color? text60;
  Color? text45;
  Color? text30;
  Color? text20;
  Color? text15;
  Color? text10;
  Color? text05;
  Color? text03;

  Color? overlay20;
  Color? overlay30;
  Color? overlay50;
  Color? overlay70;
  Color? overlay80;
  Color? overlay85;
  Color? overlay90;

  Color? barrier;
  Color? barrierWeaker;
  Color? barrierWeakest;
  Color? barrierStronger;

  Color? animationOverlayMedium;
  Color? animationOverlayStrong;

  Brightness? brightness;
  SystemUiOverlayStyle? statusBar;

  BoxShadow? boxShadow;
  BoxShadow? boxShadowButton;

  // QR scanner theme
  // OverlayTheme? qrScanTheme;
  // App icon (iOS only)
  // AppIconEnum? appIcon;
}

abstract class NyanTheme extends BaseTheme {
  // just used to distinguish between the two types of themes
}

class NautilusTheme extends BaseTheme {
  static const Color nautilusBlue = Color(0xFF4080D7);

  static const Color main = nautilusBlue;
  static const Color bg = Color.fromRGBO(32, 32, 32, 1);
  static const Color bgDark = Color.fromRGBO(24, 24, 24, 1);
  static const Color bgDarkest = Color.fromRGBO(48, 48, 48, 1);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color green = Color(0xFF41E099);
  static const Color greenDark = Color(0xFF148A55);

  static const Color yellow = Color(0xFFFFB300);
  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);
  static const Color redDark = Color(0xFFB20000);

  Color? primary = main;
  Color? primary60 = main.withOpacity(0.6);
  Color? primary45 = main.withOpacity(0.45);
  Color? primary30 = main.withOpacity(0.3);
  Color? primary20 = main.withOpacity(0.2);
  Color? primary15 = main.withOpacity(0.15);
  Color? primary10 = main.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = bg;
  Color? background40 = bg.withOpacity(0.4);
  Color? background00 = bg.withOpacity(0.0);

  Color? backgroundDark = bgDark;
  Color? backgroundDark00 = bgDark.withOpacity(0.0);

  Color? backgroundDarkest = bgDarkest;

  Color? text = white.withOpacity(0.9);
  Color? text60 = white.withOpacity(0.6);
  Color? text45 = white.withOpacity(0.45);
  Color? text30 = white.withOpacity(0.3);
  Color? text20 = white.withOpacity(0.2);
  Color? text15 = white.withOpacity(0.15);
  Color? text10 = white.withOpacity(0.1);
  Color? text05 = white.withOpacity(0.05);
  Color? text03 = white.withOpacity(0.03);

  Color? overlay90 = black.withOpacity(0.9);
  Color? overlay85 = black.withOpacity(0.85);
  Color? overlay80 = black.withOpacity(0.8);
  Color? overlay70 = black.withOpacity(0.7);
  Color? overlay50 = black.withOpacity(0.5);
  Color? overlay30 = black.withOpacity(0.3);
  Color? overlay20 = black.withOpacity(0.2);

  Color? barrier = black.withOpacity(0.7);
  Color? barrierWeaker = black.withOpacity(0.4);
  Color? barrierWeakest = black.withOpacity(0.3);
  Color? barrierStronger = black.withOpacity(0.85);

  Color? animationOverlayMedium = black.withOpacity(0.7);
  Color? animationOverlayStrong = black.withOpacity(0.85);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = const BoxShadow(color: Colors.transparent);
  BoxShadow? boxShadowButton = const BoxShadow(color: Colors.transparent);
}


class PotassiusTheme extends BaseTheme {
  static const Color nautilusBlue = Color(0xFFF4D820);

  static const Color main = nautilusBlue;
  static const Color bg = Color.fromRGBO(32, 32, 32, 1);
  static const Color bgDark = Color.fromRGBO(24, 24, 24, 1);
  static const Color bgDarkest = Color.fromRGBO(48, 48, 48, 1);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color green = Color(0xFF41E099);
  static const Color greenDark = Color(0xFF148A55);

  static const Color yellow = Color(0xFFFFB300);
  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);
  static const Color redDark = Color(0xFFB20000);

  Color? primary = main;
  Color? primary60 = main.withOpacity(0.6);
  Color? primary45 = main.withOpacity(0.45);
  Color? primary30 = main.withOpacity(0.3);
  Color? primary20 = main.withOpacity(0.2);
  Color? primary15 = main.withOpacity(0.15);
  Color? primary10 = main.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = bg;
  Color? background40 = bg.withOpacity(0.4);
  Color? background00 = bg.withOpacity(0.0);

  Color? backgroundDark = bgDark;
  Color? backgroundDark00 = bgDark.withOpacity(0.0);

  Color? backgroundDarkest = bgDarkest;

  Color? text = white.withOpacity(0.9);
  Color? text60 = white.withOpacity(0.6);
  Color? text45 = white.withOpacity(0.45);
  Color? text30 = white.withOpacity(0.3);
  Color? text20 = white.withOpacity(0.2);
  Color? text15 = white.withOpacity(0.15);
  Color? text10 = white.withOpacity(0.1);
  Color? text05 = white.withOpacity(0.05);
  Color? text03 = white.withOpacity(0.03);

  Color? overlay90 = black.withOpacity(0.9);
  Color? overlay85 = black.withOpacity(0.85);
  Color? overlay80 = black.withOpacity(0.8);
  Color? overlay70 = black.withOpacity(0.7);
  Color? overlay50 = black.withOpacity(0.5);
  Color? overlay30 = black.withOpacity(0.3);
  Color? overlay20 = black.withOpacity(0.2);

  Color? barrier = black.withOpacity(0.7);
  Color? barrierWeaker = black.withOpacity(0.4);
  Color? barrierWeakest = black.withOpacity(0.3);
  Color? barrierStronger = black.withOpacity(0.85);

  Color? animationOverlayMedium = black.withOpacity(0.7);
  Color? animationOverlayStrong = black.withOpacity(0.85);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = const BoxShadow(color: Colors.transparent);
  BoxShadow? boxShadowButton = const BoxShadow(color: Colors.transparent);
}

class TitaniumTheme extends BaseTheme {
  static const Color blueishGreen = Color(0xFF61C6AD);

  static const Color green = Color(0xFFB5ED88);

  static const Color greenDark = Color(0xFF5F893D);

  static const Color tealDark = Color(0xFF041920);

  static const Color tealLight = Color(0xFF052029);

  static const Color tealDarkest = Color(0xFF041920);

  static const Color white = Color(0xFFFFFFFF);

  static const Color black = Color(0xFF000000);

  static const Color yellow = Color(0xFFFFB300);

  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);

  static const Color redDark = Color(0xFFB20000);

  Color? primary = blueishGreen;
  Color? primary60 = blueishGreen.withOpacity(0.6);
  Color? primary45 = blueishGreen.withOpacity(0.45);
  Color? primary30 = blueishGreen.withOpacity(0.3);
  Color? primary20 = blueishGreen.withOpacity(0.2);
  Color? primary15 = blueishGreen.withOpacity(0.15);
  Color? primary10 = blueishGreen.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = tealDark;
  Color? background40 = tealDark.withOpacity(0.4);
  Color? background00 = tealDark.withOpacity(0.0);

  Color? backgroundDark = tealLight;
  Color? backgroundDark00 = tealLight.withOpacity(0.0);

  Color? backgroundDarkest = tealDarkest;

  Color? text = white.withOpacity(0.9);
  Color? text60 = white.withOpacity(0.6);
  Color? text45 = white.withOpacity(0.45);
  Color? text30 = white.withOpacity(0.3);
  Color? text20 = white.withOpacity(0.2);
  Color? text15 = white.withOpacity(0.15);
  Color? text10 = white.withOpacity(0.1);
  Color? text05 = white.withOpacity(0.05);
  Color? text03 = white.withOpacity(0.03);

  Color? overlay90 = black.withOpacity(0.9);
  Color? overlay85 = black.withOpacity(0.85);
  Color? overlay80 = black.withOpacity(0.8);
  Color? overlay70 = black.withOpacity(0.7);
  Color? overlay50 = black.withOpacity(0.5);
  Color? overlay30 = black.withOpacity(0.3);
  Color? overlay20 = black.withOpacity(0.2);

  Color? barrier = black.withOpacity(0.7);
  Color? barrierWeaker = black.withOpacity(0.4);
  Color? barrierWeakest = black.withOpacity(0.3);
  Color? barrierStronger = black.withOpacity(0.85);

  Color? animationOverlayMedium = black.withOpacity(0.7);
  Color? animationOverlayStrong = black.withOpacity(0.85);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = const BoxShadow(color: Colors.transparent);
  BoxShadow? boxShadowButton = const BoxShadow(color: Colors.transparent);

  // OverlayTheme? qrScanTheme = OverlayTheme.TITANIUM;
  // AppIconEnum? appIcon = AppIconEnum.TITANIUM;
}

class IndiumTheme extends BaseTheme {
  static const Color deepBlue = Color(0xFF0050BB);

  static const Color green = Color(0xFF00A873);

  static const Color greenLight = Color(0xFF9EEDD4);

  static const Color white = Color(0xFFFFFFFF);

  static const Color whiteishDark = Color(0xFFE8F0FA);

  static const Color grey = Color(0xFF454868);

  static const Color black = Color(0xFF000000);

  static const Color darkDeepBlue = Color(0xFF0050BB);

  static const Color yellow = Color(0xFFFFB300);

  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);

  static const Color redDark = Color(0xFFB20000);

  Color? primary = deepBlue;
  Color? primary60 = deepBlue.withOpacity(0.6);
  Color? primary45 = deepBlue.withOpacity(0.45);
  Color? primary30 = deepBlue.withOpacity(0.3);
  Color? primary20 = deepBlue.withOpacity(0.2);
  Color? primary15 = deepBlue.withOpacity(0.15);
  Color? primary10 = deepBlue.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenLight;
  Color? successDark30 = greenLight.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = white;
  Color? background40 = white.withOpacity(0.4);
  Color? background00 = white.withOpacity(0.0);

  Color? backgroundDark = white;
  Color? backgroundDark00 = white.withOpacity(0.0);

  Color? backgroundDarkest = whiteishDark;

  Color? text = grey.withOpacity(0.9);
  Color? text60 = grey.withOpacity(0.6);
  Color? text45 = grey.withOpacity(0.45);
  Color? text30 = grey.withOpacity(0.3);
  Color? text20 = grey.withOpacity(0.2);
  Color? text15 = grey.withOpacity(0.15);
  Color? text10 = grey.withOpacity(0.1);
  Color? text05 = grey.withOpacity(0.05);
  Color? text03 = grey.withOpacity(0.03);

  Color? overlay90 = black.withOpacity(0.9);
  Color? overlay85 = black.withOpacity(0.85);
  Color? overlay80 = black.withOpacity(0.8);
  Color? overlay70 = black.withOpacity(0.70);
  Color? overlay50 = black.withOpacity(0.5);
  Color? overlay30 = black.withOpacity(0.3);
  Color? overlay20 = black.withOpacity(0.2);

  Color? barrier = black.withOpacity(0.7);
  Color? barrierWeaker = black.withOpacity(0.4);
  Color? barrierWeakest = black.withOpacity(0.3);
  Color? barrierStronger = black.withOpacity(0.85);

  Color? animationOverlayMedium = white.withOpacity(0.7);
  Color? animationOverlayStrong = white.withOpacity(0.85);

  Brightness? brightness = Brightness.light;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = BoxShadow(color: darkDeepBlue.withOpacity(0.1), offset: const Offset(0, 5), blurRadius: 15);
  BoxShadow? boxShadowButton = BoxShadow(color: darkDeepBlue.withOpacity(0.2), offset: const Offset(0, 5), blurRadius: 15);
}

class SunshineTheme extends BaseTheme {
  static const Color nautilusBlue = Color(0xFF4080D7);

  static const Color bg = Color(0xFFFFCB42);
  static const Color bgDark = Color(0xFFFFB200);
  static const Color bgDarkest = Color(0xFFFFCB42);

  static const Color white = Color.fromARGB(255, 255, 255, 255);

  // static const Color grey = Color(0xFF454868);
  static const Color grey = Color(0xFF353858);
  static const Color black = Color(0xFF000000);

  static const Color greenDark = Color(0xFF41E099);
  static const Color green = Color(0xFF148A55);
  static const Color yellow = Color.fromARGB(255, 153, 0, 255);
  static const Color yellowDark = Color.fromARGB(255, 132, 0, 255);
  static const Color red = Color(0xFFE80000);
  static const Color redDark = Color(0xFFB20000);

  Color? primary = nautilusBlue;
  Color? primary60 = nautilusBlue.withOpacity(0.6);
  Color? primary45 = nautilusBlue.withOpacity(0.45);
  Color? primary30 = nautilusBlue.withOpacity(0.3);
  Color? primary20 = nautilusBlue.withOpacity(0.2);
  Color? primary15 = nautilusBlue.withOpacity(0.15);
  Color? primary10 = nautilusBlue.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = bg;
  Color? background40 = bg.withOpacity(0.4);
  Color? background00 = bg.withOpacity(0.0);

  Color? backgroundDark = bgDark;
  Color? backgroundDark00 = bgDark.withOpacity(0.0);

  Color? backgroundDarkest = bgDarkest;

  Color? text = grey.withOpacity(0.9);
  Color? text60 = grey.withOpacity(0.6);
  Color? text45 = grey.withOpacity(0.45);
  Color? text30 = grey.withOpacity(0.3);
  Color? text20 = grey.withOpacity(0.2);
  Color? text15 = grey.withOpacity(0.15);
  Color? text10 = grey.withOpacity(0.1);
  Color? text05 = grey.withOpacity(0.05);
  Color? text03 = grey.withOpacity(0.03);

  Color? overlay90 = black.withOpacity(0.9);
  Color? overlay85 = black.withOpacity(0.85);
  Color? overlay80 = black.withOpacity(0.8);
  Color? overlay70 = black.withOpacity(0.70);
  Color? overlay50 = black.withOpacity(0.5);
  Color? overlay30 = black.withOpacity(0.3);
  Color? overlay20 = black.withOpacity(0.2);

  Color? barrier = black.withOpacity(0.7);
  Color? barrierWeaker = black.withOpacity(0.4);
  Color? barrierWeakest = black.withOpacity(0.3);
  Color? barrierStronger = black.withOpacity(0.85);

  Color? animationOverlayMedium = white.withOpacity(0.7);
  Color? animationOverlayStrong = white.withOpacity(0.85);

  Brightness? brightness = Brightness.light;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

  // BoxShadow? boxShadow = BoxShadow(color: darkDeepBlue.withOpacity(0.1), offset: const Offset(0, 5), blurRadius: 15);
  // BoxShadow? boxShadowButton = BoxShadow(color: darkDeepBlue.withOpacity(0.2), offset: const Offset(0, 5), blurRadius: 15);

  BoxShadow? boxShadow = const BoxShadow(color: Colors.transparent);
  BoxShadow? boxShadowButton = const BoxShadow(color: Colors.transparent);

}

class NeptuniumTheme extends BaseTheme {
  static const Color blue = Color(0xFF4A90E2);

  static const Color orange = Color(0xFFF9AE42);

  static const Color orangeDark = Color(0xFF9C671E);

  static const Color blueDark = Color(0xFF000034);

  static const Color blueLightish = Color(0xFF080840);

  static const Color blueDarkest = Color(0xFF000034);

  static const Color white = Color(0xFFFFFFFF);

  static const Color black = Color(0xFF000000);

  static const Color yellow = Color(0xFFFFB300);

  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);

  static const Color redDark = Color(0xFFB20000);

  Color? primary = blue;
  Color? primary60 = blue.withOpacity(0.6);
  Color? primary45 = blue.withOpacity(0.45);
  Color? primary30 = blue.withOpacity(0.3);
  Color? primary20 = blue.withOpacity(0.2);
  Color? primary15 = blue.withOpacity(0.15);
  Color? primary10 = blue.withOpacity(0.1);

  Color? success = orange;
  Color? success60 = orange.withOpacity(0.6);
  Color? success30 = orange.withOpacity(0.3);
  Color? success15 = orange.withOpacity(0.15);

  Color? successDark = orangeDark;
  Color? successDark30 = orangeDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = blueDark;
  Color? background40 = blueDark.withOpacity(0.4);
  Color? background00 = blueDark.withOpacity(0.0);

  Color? backgroundDark = blueLightish;
  Color? backgroundDark00 = blueLightish.withOpacity(0.0);

  Color? backgroundDarkest = blueDarkest;

  Color? text = white.withOpacity(0.9);
  Color? text60 = white.withOpacity(0.6);
  Color? text45 = white.withOpacity(0.45);
  Color? text30 = white.withOpacity(0.3);
  Color? text20 = white.withOpacity(0.2);
  Color? text15 = white.withOpacity(0.15);
  Color? text10 = white.withOpacity(0.1);
  Color? text05 = white.withOpacity(0.05);
  Color? text03 = white.withOpacity(0.03);

  Color? overlay90 = black.withOpacity(0.9);
  Color? overlay85 = black.withOpacity(0.85);
  Color? overlay80 = black.withOpacity(0.8);
  Color? overlay70 = black.withOpacity(0.7);
  Color? overlay50 = black.withOpacity(0.5);
  Color? overlay30 = black.withOpacity(0.3);
  Color? overlay20 = black.withOpacity(0.2);

  Color? barrier = black.withOpacity(0.75);
  Color? barrierWeaker = black.withOpacity(0.45);
  Color? barrierWeakest = black.withOpacity(0.35);
  Color? barrierStronger = black.withOpacity(0.9);

  Color? animationOverlayMedium = black.withOpacity(0.75);
  Color? animationOverlayStrong = black.withOpacity(0.9);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = const BoxShadow(color: Colors.transparent);
  BoxShadow? boxShadowButton = const BoxShadow(color: Colors.transparent);

  // OverlayTheme? qrScanTheme = OverlayTheme.NEPTUNIUM;
}

class ThoriumTheme extends BaseTheme {
  static const Color teal = Color(0xFF75F3FF);

  static const Color orange = Color(0xFFFFBA59);

  static const Color orangeDark = Color(0xFFBF8026);

  static const Color purpleDark = Color(0xFF200A40);

  static const Color purpleLight = Color(0xFF2A1052);

  static const Color purpleDarkest = Color(0xFF200A40);

  static const Color white = Color(0xFFFFFFFF);

  static const Color black = Color(0xFF000000);

  static const Color yellow = Color(0xFFFFB300);

  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);

  static const Color redDark = Color(0xFFB20000);

  Color? primary = teal;
  Color? primary60 = teal.withOpacity(0.6);
  Color? primary45 = teal.withOpacity(0.45);
  Color? primary30 = teal.withOpacity(0.3);
  Color? primary20 = teal.withOpacity(0.2);
  Color? primary15 = teal.withOpacity(0.15);
  Color? primary10 = teal.withOpacity(0.1);

  Color? success = orange;
  Color? success60 = orange.withOpacity(0.6);
  Color? success30 = orange.withOpacity(0.3);
  Color? success15 = orange.withOpacity(0.15);

  Color? successDark = orangeDark;
  Color? successDark30 = orangeDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = purpleDark;
  Color? background40 = purpleDark.withOpacity(0.4);
  Color? background00 = purpleDark.withOpacity(0.0);

  Color? backgroundDark = purpleLight;
  Color? backgroundDark00 = purpleLight.withOpacity(0.0);

  Color? backgroundDarkest = purpleDarkest;

  Color? text = white.withOpacity(0.9);
  Color? text60 = white.withOpacity(0.6);
  Color? text45 = white.withOpacity(0.45);
  Color? text30 = white.withOpacity(0.3);
  Color? text20 = white.withOpacity(0.2);
  Color? text15 = white.withOpacity(0.15);
  Color? text10 = white.withOpacity(0.1);
  Color? text05 = white.withOpacity(0.05);
  Color? text03 = white.withOpacity(0.03);

  Color? overlay90 = black.withOpacity(0.9);
  Color? overlay85 = black.withOpacity(0.85);
  Color? overlay80 = black.withOpacity(0.8);
  Color? overlay70 = black.withOpacity(0.7);
  Color? overlay50 = black.withOpacity(0.5);
  Color? overlay30 = black.withOpacity(0.3);
  Color? overlay20 = black.withOpacity(0.2);

  Color? barrier = black.withOpacity(0.7);
  Color? barrierWeaker = black.withOpacity(0.4);
  Color? barrierWeakest = black.withOpacity(0.3);
  Color? barrierStronger = black.withOpacity(0.85);

  Color? animationOverlayMedium = black.withOpacity(0.7);
  Color? animationOverlayStrong = black.withOpacity(0.85);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = const BoxShadow(color: Colors.transparent);
  BoxShadow? boxShadowButton = const BoxShadow(color: Colors.transparent);

  // OverlayTheme? qrScanTheme = OverlayTheme.THORIUM;
}

class CarbonTheme extends BaseTheme {
  static const Color brightBlue = Color(0xFF99C1F0);

  static const Color green = Color(0xFF41E099);

  static const Color greenDark = Color(0xFF148A55);

  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteish = Color(0xFFE9E9F2);

  static const Color black = Color(0xFF000000);
  static const Color blackBlueish = Color(0xFF0D1014);
  static const Color blackLighter = Color(0xFF0E0F0F);

  static const Color yellow = Color(0xFFFFB300);

  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);

  static const Color redDark = Color(0xFFB20000);

  Color? primary = brightBlue;
  Color? primary60 = brightBlue.withOpacity(0.6);
  Color? primary45 = brightBlue.withOpacity(0.45);
  Color? primary30 = brightBlue.withOpacity(0.3);
  Color? primary20 = brightBlue.withOpacity(0.2);
  Color? primary15 = brightBlue.withOpacity(0.15);
  Color? primary10 = brightBlue.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = black;
  Color? background40 = black.withOpacity(0.4);
  Color? background00 = black.withOpacity(0.0);

  Color? backgroundDark = black;
  Color? backgroundDark00 = black.withOpacity(0.0);

  Color? backgroundDarkest = blackLighter;

  Color? text = whiteish.withOpacity(0.9);
  Color? text60 = whiteish.withOpacity(0.6);
  Color? text45 = whiteish.withOpacity(0.45);
  Color? text30 = whiteish.withOpacity(0.3);
  Color? text20 = whiteish.withOpacity(0.2);
  Color? text15 = whiteish.withOpacity(0.15);
  Color? text10 = whiteish.withOpacity(0.1);
  Color? text05 = whiteish.withOpacity(0.05);
  Color? text03 = whiteish.withOpacity(0.03);

  Color? overlay90 = blackLighter.withOpacity(0.9);
  Color? overlay85 = blackLighter.withOpacity(0.85);
  Color? overlay80 = blackLighter.withOpacity(0.8);
  Color? overlay70 = blackLighter.withOpacity(0.7);
  Color? overlay50 = blackLighter.withOpacity(0.5);
  Color? overlay30 = blackLighter.withOpacity(0.3);
  Color? overlay20 = blackLighter.withOpacity(0.2);

  Color? barrier = blackBlueish.withOpacity(0.8);
  Color? barrierWeaker = blackBlueish.withOpacity(0.7);
  Color? barrierWeakest = blackBlueish.withOpacity(0.35);
  Color? barrierStronger = blackBlueish.withOpacity(0.9);

  Color? animationOverlayMedium = blackBlueish.withOpacity(0.8);
  Color? animationOverlayStrong = blackBlueish.withOpacity(0.9);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = BoxShadow(
    color: white.withOpacity(0.14),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 1,
  );
  BoxShadow? boxShadowButton = BoxShadow(
    color: brightBlue.withOpacity(0.24),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 0,
  );

  // OverlayTheme? qrScanTheme = OverlayTheme.CARBON;
}

class PurpeliumTheme extends BaseTheme {
  static const Color purpeliumPurple = Color(0xFFB999F0);
  // some test colors:
  // current: #B999F0
  // darker: #B19CD9
  // lighter: #CCA9DD

  static const Color green = Color(0xFF41E099);

  static const Color greenDark = Color(0xFF148A55);

  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteish = Color(0xFFE9E9F2);

  static const Color black = Color(0xFF000000);
  static const Color blackBlueish = Color(0xFF0D1014);
  static const Color blackLighter = Color(0xFF0E0F0F);

  static const Color yellow = Color(0xFFFFB300);

  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);

  static const Color redDark = Color(0xFFB20000);

  Color? primary = purpeliumPurple;
  Color? primary60 = purpeliumPurple.withOpacity(0.6);
  Color? primary45 = purpeliumPurple.withOpacity(0.45);
  Color? primary30 = purpeliumPurple.withOpacity(0.3);
  Color? primary20 = purpeliumPurple.withOpacity(0.2);
  Color? primary15 = purpeliumPurple.withOpacity(0.15);
  Color? primary10 = purpeliumPurple.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = black;
  Color? background40 = black.withOpacity(0.4);
  Color? background00 = black.withOpacity(0.0);

  Color? backgroundDark = black;
  Color? backgroundDark00 = black.withOpacity(0.0);

  Color? backgroundDarkest = blackLighter;

  Color? text = whiteish.withOpacity(0.9);
  Color? text60 = whiteish.withOpacity(0.6);
  Color? text45 = whiteish.withOpacity(0.45);
  Color? text30 = whiteish.withOpacity(0.3);
  Color? text20 = whiteish.withOpacity(0.2);
  Color? text15 = whiteish.withOpacity(0.15);
  Color? text10 = whiteish.withOpacity(0.1);
  Color? text05 = whiteish.withOpacity(0.05);
  Color? text03 = whiteish.withOpacity(0.03);

  Color? overlay90 = blackLighter.withOpacity(0.9);
  Color? overlay85 = blackLighter.withOpacity(0.85);
  Color? overlay80 = blackLighter.withOpacity(0.8);
  Color? overlay70 = blackLighter.withOpacity(0.7);
  Color? overlay50 = blackLighter.withOpacity(0.5);
  Color? overlay30 = blackLighter.withOpacity(0.3);
  Color? overlay20 = blackLighter.withOpacity(0.2);

  Color? barrier = blackBlueish.withOpacity(0.8);
  Color? barrierWeaker = blackBlueish.withOpacity(0.7);
  Color? barrierWeakest = blackBlueish.withOpacity(0.35);
  Color? barrierStronger = blackBlueish.withOpacity(0.9);

  Color? animationOverlayMedium = blackBlueish.withOpacity(0.8);
  Color? animationOverlayStrong = blackBlueish.withOpacity(0.9);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = BoxShadow(
    color: white.withOpacity(0.14),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 1,
  );
  BoxShadow? boxShadowButton = BoxShadow(
    color: purpeliumPurple.withOpacity(0.24),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 0,
  );

  // OverlayTheme? qrScanTheme = OverlayTheme.CARBON;
}

class NyanoTheme extends NyanTheme {
  static const Color nyanoBlue = Color(0xFF4A90E2);
  static const Color darkerBlue = Color(0xFF0E1032);
  // some test colors:
  // current: #B999F0
  // darker: #B19CD9
  // lighter: #CCA9DD

  static const Color green = Color(0xFF41E099);

  static const Color greenDark = Color(0xFF148A55);

  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteish = Color(0xFFE9E9F2);

  static const Color black = Color(0xFF000000);
  static const Color blackBlueish = Color(0xFF0D1014);
  static const Color blackLighter = Color(0xFF0E0F0F);

  static const Color yellow = Color(0xFFFFB300);

  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);

  static const Color redDark = Color(0xFFB20000);

  Color? primary = nyanoBlue;
  Color? primary60 = nyanoBlue.withOpacity(0.6);
  Color? primary45 = nyanoBlue.withOpacity(0.45);
  Color? primary30 = nyanoBlue.withOpacity(0.3);
  Color? primary20 = nyanoBlue.withOpacity(0.2);
  Color? primary15 = nyanoBlue.withOpacity(0.15);
  Color? primary10 = nyanoBlue.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = black;
  Color? background40 = black.withOpacity(0.4);
  Color? background00 = black.withOpacity(0.0);

  Color? backgroundDark = black;
  Color? backgroundDark00 = black.withOpacity(0.0);

  Color? backgroundDarkest = blackLighter;

  Color? text = whiteish.withOpacity(0.9);
  Color? text60 = whiteish.withOpacity(0.6);
  Color? text45 = whiteish.withOpacity(0.45);
  Color? text30 = whiteish.withOpacity(0.3);
  Color? text20 = whiteish.withOpacity(0.2);
  Color? text15 = whiteish.withOpacity(0.15);
  Color? text10 = whiteish.withOpacity(0.1);
  Color? text05 = whiteish.withOpacity(0.05);
  Color? text03 = whiteish.withOpacity(0.03);

  Color? overlay90 = blackLighter.withOpacity(0.9);
  Color? overlay85 = blackLighter.withOpacity(0.85);
  Color? overlay80 = blackLighter.withOpacity(0.8);
  Color? overlay70 = blackLighter.withOpacity(0.7);
  Color? overlay50 = blackLighter.withOpacity(0.5);
  Color? overlay30 = blackLighter.withOpacity(0.3);
  Color? overlay20 = blackLighter.withOpacity(0.2);

  Color? barrier = blackBlueish.withOpacity(0.8);
  Color? barrierWeaker = blackBlueish.withOpacity(0.7);
  Color? barrierWeakest = blackBlueish.withOpacity(0.35);
  Color? barrierStronger = blackBlueish.withOpacity(0.9);

  Color? animationOverlayMedium = blackBlueish.withOpacity(0.8);
  Color? animationOverlayStrong = blackBlueish.withOpacity(0.9);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = BoxShadow(
    color: white.withOpacity(0.14),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 1,
  );
  BoxShadow? boxShadowButton = BoxShadow(
    color: nyanoBlue.withOpacity(0.24),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 0,
  );

  // OverlayTheme? qrScanTheme = OverlayTheme.CARBON;
}

class MonochromeTheme extends BaseTheme {
  static const Color tealLightest = Color.fromRGBO(128, 128, 128, 1);
  static const Color tealLight = Color.fromRGBO(64, 64, 64, 1);
  static const Color tealDark = Color.fromRGBO(16, 16, 16, 1);
  static const Color tealDarkest = Color.fromRGBO(10, 10, 10, 1);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color green = Color(0xFF41E099);
  static const Color greenDark = Color(0xFF148A55);

  static const Color yellow = Color(0xFFFFB300);
  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);
  static const Color redDark = Color(0xFFB20000);

  Color? primary = tealLightest;
  Color? primary60 = tealLightest.withOpacity(0.6);
  Color? primary45 = tealLightest.withOpacity(0.45);
  Color? primary30 = tealLightest.withOpacity(0.3);
  Color? primary20 = tealLightest.withOpacity(0.2);
  Color? primary15 = tealLightest.withOpacity(0.15);
  Color? primary10 = tealLightest.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = tealLight;
  Color? background40 = tealLight.withOpacity(0.4);
  Color? background00 = tealLight.withOpacity(0.0);

  Color? backgroundDark = tealDark;
  Color? backgroundDark00 = tealDark.withOpacity(0.0);

  Color? backgroundDarkest = tealDarkest;

  Color? text = white.withOpacity(0.9);
  Color? text60 = white.withOpacity(0.6);
  Color? text45 = white.withOpacity(0.45);
  Color? text30 = white.withOpacity(0.3);
  Color? text20 = white.withOpacity(0.2);
  Color? text15 = white.withOpacity(0.15);
  Color? text10 = white.withOpacity(0.1);
  Color? text05 = white.withOpacity(0.05);
  Color? text03 = white.withOpacity(0.03);

  Color? overlay90 = black.withOpacity(0.9);
  Color? overlay85 = black.withOpacity(0.85);
  Color? overlay80 = black.withOpacity(0.8);
  Color? overlay70 = black.withOpacity(0.7);
  Color? overlay50 = black.withOpacity(0.5);
  Color? overlay30 = black.withOpacity(0.3);
  Color? overlay20 = black.withOpacity(0.2);

  Color? barrier = black.withOpacity(0.7);
  Color? barrierWeaker = black.withOpacity(0.4);
  Color? barrierWeakest = black.withOpacity(0.3);
  Color? barrierStronger = black.withOpacity(0.85);

  Color? animationOverlayMedium = black.withOpacity(0.7);
  Color? animationOverlayStrong = black.withOpacity(0.85);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = const BoxShadow(color: Colors.transparent);
  BoxShadow? boxShadowButton = const BoxShadow(color: Colors.transparent);
}

class MidnightTheme extends BaseTheme {
  static const Color nautilusBlue = Color(0xFF4080D7);
  static const Color brighterBlue = Color(0xFF80BAC7);
  // some test colors:
  // current: #B999F0
  // darker: #B19CD9
  // lighter: #CCA9DD

  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteish = Color(0xFFE9E9F2);

  static const Color black = Color(0xFF000000);
  static const Color blackBlueish = Color(0xFF0D1014);
  static const Color blackLighter = Color(0xFF0E0F0F);

  static const Color green = Color(0xFF41E099);
  static const Color greenDark = Color(0xFF148A55);

  static const Color yellow = Color(0xFFFFB300);
  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);
  static const Color redDark = Color(0xFFB20000);

  Color? primary = nautilusBlue;
  Color? primary60 = nautilusBlue.withOpacity(0.6);
  Color? primary45 = nautilusBlue.withOpacity(0.45);
  Color? primary30 = nautilusBlue.withOpacity(0.3);
  Color? primary20 = nautilusBlue.withOpacity(0.2);
  Color? primary15 = nautilusBlue.withOpacity(0.15);
  Color? primary10 = nautilusBlue.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = black;
  Color? background40 = black.withOpacity(0.4);
  Color? background00 = black.withOpacity(0.0);

  Color? backgroundDark = black;
  Color? backgroundDark00 = black.withOpacity(0.0);

  Color? backgroundDarkest = blackLighter;

  Color? text = whiteish.withOpacity(0.9);
  Color? text60 = whiteish.withOpacity(0.6);
  Color? text45 = whiteish.withOpacity(0.45);
  Color? text30 = whiteish.withOpacity(0.3);
  Color? text20 = whiteish.withOpacity(0.2);
  Color? text15 = whiteish.withOpacity(0.15);
  Color? text10 = whiteish.withOpacity(0.1);
  Color? text05 = whiteish.withOpacity(0.05);
  Color? text03 = whiteish.withOpacity(0.03);

  Color? overlay90 = blackLighter.withOpacity(0.9);
  Color? overlay85 = blackLighter.withOpacity(0.85);
  Color? overlay80 = blackLighter.withOpacity(0.8);
  Color? overlay70 = blackLighter.withOpacity(0.7);
  Color? overlay50 = blackLighter.withOpacity(0.5);
  Color? overlay30 = blackLighter.withOpacity(0.3);
  Color? overlay20 = blackLighter.withOpacity(0.2);

  Color? barrier = blackBlueish.withOpacity(0.8);
  Color? barrierWeaker = blackBlueish.withOpacity(0.7);
  Color? barrierWeakest = blackBlueish.withOpacity(0.35);
  Color? barrierStronger = blackBlueish.withOpacity(0.9);

  Color? animationOverlayMedium = blackBlueish.withOpacity(0.8);
  Color? animationOverlayStrong = blackBlueish.withOpacity(0.9);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = BoxShadow(
    color: white.withOpacity(0.14),
    // color: black.withOpacity(0.5),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 1,
  );
  BoxShadow? boxShadowButton = BoxShadow(
    // color: brightRed,
    color: nautilusBlue.withOpacity(0.24),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 0,
  );

  // OverlayTheme? qrScanTheme = OverlayTheme.CARBON;
  // AppIconEnum? appIcon = AppIconEnum.CARBON;
}

class PerishableTheme extends BaseTheme {
  static const Color nautilusBlue = Color(0xFF4080D7);

  // static const Color perishPurple = Color(0xFF9A5EFC);
  // // static const Color perishPurple = Color(0xFF6305fa);
  // // static const Color perishOrange = Color(0xFFff9966);
  // // static const Color perishYellow = Color(0xFFffcc00);
  // static const Color perishRed = Color.fromRGBO(34, 24, 22, 1);
  // static const Color perishOrange = Color(0xFFFF9966);

  static const Color perishPurple = Color(0xFF9A5EFC);
  static const Color perishOrange = Color(0xFFff9966);
  // static const Color perishPurple = Color(0xFF6305fa);
  // static const Color perishYellow = Color(0xFFffcc00);
  static const Color perishRed = Color.fromRGBO(34, 24, 22, 1);
  // static const Color perishOrange = Color(0xFFFF9966);

  static const Color purpleLight = Color(0xFF2A1052);
  static const Color purpleDarkest = Color(0xFF200A40);

  static const Color brighterBlue = Color(0xFF80BAC7);
  // some test colors:
  // current: #B999F0
  // darker: #B19CD9
  // lighter: #CCA9DD

  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteish = Color(0xFFE9E9F2);

  static const Color black = Color(0xFF000000);
  static const Color blackBlueish = Color(0xFF0D1014);
  static const Color blackLighter = Color.fromRGBO(47, 44, 54, 1);

  static const Color green = Color(0xFF41E099);
  static const Color greenDark = Color(0xFF148A55);

  static const Color yellow = Color(0xFFFFB300);
  static const Color yellowDark = Color(0xFFFFCB00);

  static const Color red = Color(0xFFE80000);
  static const Color redDark = Color(0xFFB20000);

  Color? primary = perishOrange;
  Color? primary60 = perishOrange.withOpacity(0.6);
  Color? primary45 = perishOrange.withOpacity(0.45);
  Color? primary30 = perishOrange.withOpacity(0.3);
  Color? primary20 = perishOrange.withOpacity(0.2);
  Color? primary15 = perishOrange.withOpacity(0.15);
  Color? primary10 = perishOrange.withOpacity(0.1);

  Color? success = green;
  Color? success60 = green.withOpacity(0.6);
  Color? success45 = green.withOpacity(0.45);
  Color? success30 = green.withOpacity(0.3);
  Color? success15 = green.withOpacity(0.15);

  Color? successDark = greenDark;
  Color? successDark30 = greenDark.withOpacity(0.3);

  Color? warning = yellow;
  Color? warning60 = yellow.withOpacity(0.6);
  Color? warning45 = yellow.withOpacity(0.45);
  Color? warning30 = yellow.withOpacity(0.3);
  Color? warning15 = yellow.withOpacity(0.15);

  Color? warningDark = yellowDark;
  Color? warningDark30 = yellowDark.withOpacity(0.3);

  Color? error = red;
  Color? error60 = red.withOpacity(0.6);
  Color? error30 = red.withOpacity(0.3);
  Color? error15 = red.withOpacity(0.15);

  Color? errorDark = redDark;
  Color? errorDark30 = redDark.withOpacity(0.3);

  Color? background = purpleLight;
  Color? background40 = purpleLight.withOpacity(0.4);
  Color? background00 = purpleLight.withOpacity(0.0);

  // tx color:
  Color? backgroundDark = perishPurple;
  Color? backgroundDark00 = perishPurple.withOpacity(0.0);

  Color? backgroundDarkest = purpleDarkest;

  Color? text = whiteish.withOpacity(0.9);
  Color? text60 = whiteish.withOpacity(0.6);
  Color? text45 = whiteish.withOpacity(0.45);
  Color? text30 = whiteish.withOpacity(0.3);
  Color? text20 = whiteish.withOpacity(0.2);
  Color? text15 = whiteish.withOpacity(0.15);
  Color? text10 = whiteish.withOpacity(0.1);
  Color? text05 = whiteish.withOpacity(0.05);
  Color? text03 = whiteish.withOpacity(0.03);

  Color? overlay90 = blackLighter.withOpacity(0.9);
  Color? overlay85 = blackLighter.withOpacity(0.85);
  Color? overlay80 = blackLighter.withOpacity(0.8);
  Color? overlay70 = blackLighter.withOpacity(0.7);
  Color? overlay50 = blackLighter.withOpacity(0.5);
  Color? overlay30 = blackLighter.withOpacity(0.3);
  Color? overlay20 = blackLighter.withOpacity(0.2);

  Color? barrier = blackBlueish.withOpacity(0.8);
  Color? barrierWeaker = blackBlueish.withOpacity(0.7);
  Color? barrierWeakest = blackBlueish.withOpacity(0.35);
  Color? barrierStronger = blackBlueish.withOpacity(0.9);

  Color? animationOverlayMedium = blackBlueish.withOpacity(0.8);
  Color? animationOverlayStrong = blackBlueish.withOpacity(0.9);

  Brightness? brightness = Brightness.dark;
  SystemUiOverlayStyle? statusBar = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow? boxShadow = BoxShadow(
    color: white.withOpacity(0.14),
    // color: black.withOpacity(0.5),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 1,
  );
  BoxShadow? boxShadowButton = BoxShadow(
    // color: brightRed,
    color: nautilusBlue.withOpacity(0.24),
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 0,
  );
}

enum AppIconEnum { NAUTILUS, TITANIUM, INDIUM, SUNSHINE, NEPTUNIUM, THORIUM, CARBON, PURPELIUM, NYANO }

class AppIcon {
  static const MethodChannel _channel = MethodChannel('fappchannel');

  static Future<void> setAppIcon(AppIconEnum? iconToChange) async {
    return;
  }
}
