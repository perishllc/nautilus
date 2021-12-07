# Nautilus

![Cover](https://raw.githubusercontent.com/fwd/nautilus/master/.github/banner.png)

A [Natrium](https://github.com/appditto/natrium_wallet_flutter) fork, with [Nano.to](https://github.com/formsend/nano) integration, and a few other improvements.

## Server Repo

Nautilus's backend server can be found [here](https://github.com/fwd/nautilus-server)

## Contributing

* Fork the repository and clone it to your local machine
* Follow the instructions [here](https://flutter.io/docs/get-started/install) to install the Flutter SDK
* Setup [Android Studio](https://flutter.io/docs/development/tools/android-studio) or [Visual Studio Code](https://flutter.io/docs/development/tools/vs-code).

## Building

Android (armeabi-v7a): `flutter build apk`
Android (arm64-v8a): `flutter build apk --target=android-arm64`
iOS: `flutter build ios`

If you have a connected device or emulator you can run and deploy the app with `flutter run`

## Have a question?

If you need any help, feel free to file an issue if you do not manage to find a solution.

## License

Nautilus is released under the MIT License, the same license as Natrium wallet.

### Update translations:

```
flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localization.dart
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n \
   --no-use-deferred-loading lib/localization.dart lib/l10n/intl_*.arb
```

