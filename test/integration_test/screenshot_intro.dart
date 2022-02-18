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
  // final binding = IntegrationTestWidgetsFlutterBinding();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot intro screens', (WidgetTester tester) async {
    setupServiceLocator();
    // Setup firebase
    await Firebase.initializeApp();
    // sleep for a bit to allow firebase to initialize
    await Future.delayed(Duration(seconds: 10));
    // load the App widget
    // await tester.pumpWidget(new StateContainer(child: new App()));
    // new StateContainer(child: new App())''
    runApp(new StateContainer(child: new App()));

    // wait for data to load
    // await tester.pumpAndSettle();
    await pumpForSeconds(tester, 15);

    // sleep for 10 seconds
    await Future.delayed(Duration(seconds: 2));

    print("tapping button!");

    await tester.tap(find.byKey(Key("new_wallet_button")));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("got_it_button")));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("backed_it_up_button")));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key("backup_confirm_button")));
    await tester.pumpAndSettle();

    for (var i = 0; i < 12; i++) {
      await tester.tap(find.byKey(Key("pin_0_button")));
      await tester.pumpAndSettle();
    }

    // sleep for 10 seconds
    await Future.delayed(Duration(seconds: 200));

    // WidgetsFlutterBinding.ensureInitialized();
    // // Setup Service Provide
    // setupServiceLocator();
    // // Setup firebase
    // await Firebase.initializeApp();
    // // Run app
    // // this breaks debug mode (on launch, until hot restarted):
    // // if (kReleaseMode) {
    // //   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // // }
    // runApp(new StateContainer(child: new App()));
  });
}
