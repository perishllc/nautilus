import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/firebase_options.dart';
import 'package:wallet_flutter/main.dart' as app;
import 'package:wallet_flutter/service_locator.dart';

Future<void> pumpForSeconds(WidgetTester tester, int seconds) async {
  bool timerDone = false;
  Timer(Duration(seconds: seconds), () => timerDone = true);
  while (timerDone != true) {
    await tester.pump();
  }
}

Future<void> pumpSettleWait(WidgetTester tester, Duration duration) async {
  bool timerDone = false;
  Timer(duration, () => timerDone = true);
  await tester.pumpAndSettle();
  while (timerDone != true) {
    await tester.pump();
  }
}

Future<void> goBack(WidgetTester tester) async {
  final NavigatorState navigator = tester.state(find.byType(Navigator));
  navigator.pop();
  await tester.pump();
}

/// returns a base64 screenshot of the screen, useful for making a
/// diagnostic for unit test failures.
Future<String> takeScreenshot() async {
  final RenderRepaintBoundary renderObj =
      find.byKey(const ValueKey('screenshotter')).evaluate().single.renderObject! as RenderRepaintBoundary;

  final double devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
  final ui.Image image = await renderObj.toImage(pixelRatio: devicePixelRatio);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List pngBytes = byteData!.buffer.asUint8List();
  final String bs64 = base64Encode(pngBytes);
  return bs64;
}

Future<void> printScreenshot() async {
  final String screenshot = await takeScreenshot();
  // ignore: avoid_print
  print(screenshot);
}

Future<void> saveScreenshot(IntegrationTestWidgetsFlutterBinding binding, String name) async {
  print("saving screenshot: $name");
  final String screenshot = await takeScreenshot();
  binding.reportData?[name] = screenshot;
}

// inject repaint boundary so we can take screenshots
Future<void> appMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load environment variables:
  await dotenv.load();

  // Setup Service Provide
  setupServiceLocator();
  // Setup logger, only show warning and higher in release mode.
  if (kReleaseMode) {
    Logger.level = Level.warning;
  } else {
    // Logger.level = Level.debug;
    Logger.level = Level.verbose;
  }
  // Setup firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kReleaseMode) {
    // we have to stall for whatever reason in debug mode
    // otherwise the app doesn't start properly (black screen)
    await Future<dynamic>.delayed(const Duration(seconds: 2));
  }
  // Run app
  if (kReleaseMode) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  // runApp(StateContainer(child: App()));
  runApp(const RepaintBoundary(
    key: ValueKey<String>("screenshotter"),
    child: StateContainer(
      child: app.App(),
    ),
  ));

  return;
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('screenshot intro screens', (WidgetTester tester) async {
    String platformName = "";

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        platformName = "android";
        // required prior to taking the screenshot.
        await binding.convertFlutterSurfaceToImage();
      } else {
        platformName = "ios";
      }
    } else {
      platformName = "web";
    }

    const Duration halfSecond = Duration(milliseconds: 600);

    binding.reportData = {
      "platform": platformName,
      "width": binding.window.physicalSize.width.toInt().toString(),
      "height": binding.window.physicalSize.height.toInt().toString(),
    };

    await appMain();

    // await tester.pumpAndSettle();
    // sleep for a bit to let the app load
    await Future<dynamic>.delayed(const Duration(seconds: 10));

    bool loggedIn = false;

    // may or may not already be logged in:
    try {
      expect(find.byKey(const Key("new_existing_button")), findsOneWidget);
      loggedIn = false;
    } catch (error) {
      loggedIn = true;
    }

    if (!loggedIn) {
      await saveScreenshot(binding, "welcome_intro_screen");
      await tester.tap(find.byKey(const Key("new_existing_button")));
      await pumpSettleWait(tester, halfSecond);
      await tester.tap(find.byKey(const Key("new_wallet_button")));
      await pumpSettleWait(tester, halfSecond);
      await tester.tap(find.byKey(const Key("got_it_button")));
      await pumpSettleWait(tester, halfSecond);
      await tester.tap(find.byKey(const Key("backed_it_up_button")));
      await pumpSettleWait(tester, halfSecond);
      await tester.tap(find.byKey(const Key("backup_confirm_button")));
      await pumpSettleWait(tester, halfSecond);

      for (int i = 0; i < 12; i++) {
        await tester.tap(find.byKey(const Key("pin_0_button")));
        await pumpSettleWait(tester, halfSecond);
      }
    }

    await pumpSettleWait(tester, halfSecond);
    // wait a second for home screen to load:
    await Future<dynamic>.delayed(const Duration(seconds: 2));
    try {
      await tester.tap(find.byKey(const Key("changelog_dismiss_button")));
      await pumpSettleWait(tester, halfSecond);
    } catch (error) {
      print("there was no changelog dialog to press");
    }

    await pumpSettleWait(tester, halfSecond);
    await saveScreenshot(binding, "home_demo_cards_screen");

    await tester.tap(find.byKey(const Key("home_send_button")));
    await pumpSettleWait(tester, halfSecond);

    await saveScreenshot(binding, "send_screen");
    await pumpSettleWait(tester, halfSecond);

    // gift card button:
    await tester.tap(find.byKey(const Key("gift_button")));
    await pumpSettleWait(tester, halfSecond);

    await saveScreenshot(binding, "gift_card_screen");
    await pumpSettleWait(tester, halfSecond);

    await goBack(tester);
    await pumpSettleWait(tester, halfSecond);

    // wait a second for the back press:
    await Future<dynamic>.delayed(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key("home_receive_button")));
    await pumpSettleWait(tester, halfSecond);

    await saveScreenshot(binding, "receive_screen");
    await pumpSettleWait(tester, halfSecond);

    await goBack(tester);
    await pumpSettleWait(tester, halfSecond);

    await tester.tap(find.byKey(const Key("home_settings_button")));
    await pumpSettleWait(tester, halfSecond);

    await saveScreenshot(binding, "settings_drawer_screen");
    await pumpSettleWait(tester, halfSecond);

    await goBack(tester);
    await pumpSettleWait(tester, halfSecond);

    await pumpSettleWait(tester, halfSecond);
    await pumpSettleWait(tester, halfSecond);
    await pumpSettleWait(tester, halfSecond);

    // sleep for 10 seconds
    // await Future<dynamic>.delayed(const Duration(seconds: 200000));
  });
}
