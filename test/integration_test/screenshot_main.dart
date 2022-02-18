import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';

// import 'package:screenshot_integration_demo/main.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:nautilus_wallet_flutter/main.dart';
import 'package:nautilus_wallet_flutter/main.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';

Future<void> pumpForSeconds(WidgetTester tester, int seconds) async {
  bool timerDone = false;
  Timer(Duration(seconds: seconds), () => timerDone = true);
  while (timerDone != true) {
    await tester.pump();
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot main screens', (WidgetTester tester) async {
    setupServiceLocator();
    // Setup firebase
    await Firebase.initializeApp();
    // load the App widget
    // await tester.pumpWidget(new StateContainer(child: new App()));
    // new StateContainer(child: new App())''
    runApp(new StateContainer(child: new App()));

    // wait for data to load
    // await tester.pumpAndSettle();
    await pumpForSeconds(tester, 10);

    // sleep for 10 seconds
    await Future.delayed(Duration(seconds: 3));

    print("tapping button!");

    // await tester.tap(find.byKey(Key("new_wallet_button")));
    // await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('screenshot_main_1.png');

    // sleep for 10 seconds
    await Future.delayed(Duration(seconds: 200));
  });
}
