import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/firebase_options.dart';

// import 'package:screenshot_integration_demo/main.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:nautilus_wallet_flutter/main.dart';
import 'package:nautilus_wallet_flutter/main.dart' as app;
import 'package:nautilus_wallet_flutter/service_locator.dart';

Future<void> pumpForSeconds(WidgetTester tester, int seconds) async {
  bool timerDone = false;
  Timer(Duration(seconds: seconds), () => timerDone = true);
  while (timerDone != true) {
    await tester.pump();
  }
}

Future<void> goBack(WidgetTester tester) async {
  final NavigatorState navigator = tester.state(find.byType(Navigator));
  navigator.pop();
  await tester.pump();
}

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized() as IntegrationTestWidgetsFlutterBinding;

  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('screenshot intro screens', (WidgetTester tester) async {
    String platformName = '';

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

    await app.main();

    await tester.pumpAndSettle();

    // await binding.takeScreenshot('intro');

    // may or may not already be logged in:
    try {
      await tester.tap(find.byKey(const Key("new_wallet_button")));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("got_it_button")));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("backed_it_up_button")));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("backup_confirm_button")));
      await tester.pumpAndSettle();

      for (int i = 0; i < 12; i++) {
        await tester.tap(find.byKey(const Key("pin_0_button")));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const Key("changelog_dismiss_button")));
      await tester.pumpAndSettle();
    } catch (e) {
      print("probably just already logged in: $e");
    }

    await tester.pumpAndSettle();

    // await binding.takeScreenshot('home_screen_demo_cards');

    await tester.tap(find.byKey(const Key("home_send_button")));
    await tester.pumpAndSettle();

    // await binding.takeScreenshot('send_screen');

    await goBack(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("home_receive_button")));
    await tester.pumpAndSettle();

    // await binding.takeScreenshot('receive_screen');

    await goBack(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("home_settings_button")));
    await tester.pumpAndSettle();

    // await binding.takeScreenshot('settings_drawer');

    await goBack(tester);
    await tester.pumpAndSettle();

    // sleep for 10 seconds
    await Future.delayed(const Duration(seconds: 200000));
  });
}
