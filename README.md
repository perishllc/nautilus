# Nautilus Wallet

![Cover](https://raw.githubusercontent.com/fwd/nautilus/master/.github/banner.png)

---

This project is in development by the team @ [Nano.to](https://nano.to/development)

### Nautilus - Beta 0.1 (Q1 2022)

- Replace all AppDitto trademarks, as to not infringe on their marks. **Logo assets pending**
- Change default theme to a darker color. **CSS HEX TBD**
- Simplify the 'New User' onboarding screens. Right down there are about 3-5 screens between new users, the UI (wallet). I want to bring this down to 1-3. 
   - Set Pin
   - Backup Seed
   - Done!
- Disable Natricon functionality entirely. 
- When you start typing in the Address input of 'Send From' screen, Nano.to/Known usernames will bw shown. 
- When searching Usernames, a '@' will not be need to show list... Just start typing.
- Payment history show Nano.to Usernames.
- Local contacts will be called Favorites. 
- Registered Usernames will be called Usernames. 
- Create clever UI to differenciate between Favorites & Usernames. 
- Increase 'Receive' screen font size of NANO Address by 50%. Reduce QR Code size by 30%
- Add Username Reservation Screen to app. **This actually may be an issue with Apple not allowing third party payments.**

### Nautilus - Beta 1.0 (Q3 2022)

- Available on most App stores. 

### Nautilus - Beta 2.0 (Q1 2023)

- On device PoW generation.
- Eliminate Nautilus back-end server requirement.

### Nautilus - Beta 2.0 (Q1 2024)

- Metal NANO debit card, Managed via Nautilus (Nano.to/Card)

---

# Nautilus

![Cover](https://raw.githubusercontent.com/fwd/nautilus/master/.github/banner.png)

### A [Natrium](https://github.com/appditto/natrium_wallet_flutter) fork, with [Nano.to](https://github.com/formsend/nano) integration, and a few other improvements.

## Server Repo

Nautilus's backend server can be found [here](https://github.com/fwd/nautilus-server)

## Contributing

* Fork the repository and clone it to your local machine
* Follow the instructions [here](https://flutter.io/docs/get-started/install) to install the Flutter SDK
* Setup [Android Studio](https://flutter.io/docs/development/tools/android-studio) or [Visual Studio Code](https://flutter.io/docs/development/tools/vs-code).

## Building

* iOS: `flutter build ios`
* Android (armeabi-v7a): `flutter build apk`
* Android (arm64-v8a): `flutter build apk --target=android-arm64`

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

