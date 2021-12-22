# Nautilus Wallet

![Cover](https://raw.githubusercontent.com/fwd/nautilus/master/.github/banner.png)

---

This project is in development by the team @ [Nano.to](https://nano.to/development)


#### Features

- [ ] When you start typing in the Address input of 'Send From' screen, Nano.to/Known usernames will be shown.
- [ ] Usernames should be clickable to reveal the full address & when the username was last leased / updated
- [ ] When searching Usernames, a '@' will not be need to show list... Just start typing.
   - Usernames when displayed in full will still show an @
- [ ] Add as contact button / system using nano.to usernames
   - Through the payment history in some form
   - Contacts may be nickname-able (i.e Favorites)
- [ ] Add Username Reservation Screen to app.
   - Can be done on android np.
   - On iOS it can only be linked to / referenced unless you use the IAP mechanism (and Apple will take a % cut) **Classic Monopoly**
- [ ] Payment history shows Nano.to Usernames or Favorites
- [ ] Replace all AppDitto trademarks, as to not infringe on their marks. 
   - [x] Move all appditto assets to a legacy_assets folder, to be removed as replacements are made

#### Aesthetic goals
- [ ] Show nano.to usernames over full addresses wherever possible
- [ ] Registered Usernames will be called Usernames. 
- [ ] Simplify the 'New User' onboarding screens. Right now there are about 3-5 screens between new users, the UI (wallet). I want to bring this down to 1-3. 
   - Ask to import seed or create one
   - Backup Seed
   - Set Pin
   - Done!
- [ ] Local contacts will be called Favorites.
- [ ] Create clever UI to differenciate between Favorites & Usernames.
   - Maybe prefix favorites with a # or $
   - Prefix usernames with an @
- [ ] Change default theme to a darker color. **CSS Hex Color TBD**
- [ ] Increase 'Receive' screen font size of NANO Address by 50%. Reduce QR Code size by 30%
- [ ] Advanced theming support

#### Changes so far
- [x] removed natricons
- [x] most branding / strings replaced with Nautilus
- [x] experimenting with themes
- [x] start changing the send screen
- [x] update icons
- [x] use json data on the send screen
- [ ] cache json from /reps and /known
- [ ] set random representative for new accounts using nano.to/reps


<img src="/screenshots/flutter_01.png" width="200">
<img src="/screenshots/flutter_02.png" width="200">
<img src="/screenshots/flutter_03.png" width="200">

### Nautilus - Beta 0.1 (Q1 2022)

- Build with some / core features, possibly provide an apk on github

### Nautilus - Beta 0.25 (Q1 2022)

- Buy XNO right on the Wallet, with Simplex (or MoonPay) integration. Like Trust Wallet!

### Nautilus - Beta 0.5 (Q2 2022)

- Wider release / testing

### Nautilus - Beta 1.0 (Q3 2022)

- Available on most App stores.

### Nautilus - Stable v1 (Q1 2023)

- On device PoW generation. **Apple may not allow this. We'll see**
- Eliminate Nautilus back-end server requirement. **Or minimize need for it**
- Offline/Bluetooth Payments (???) **Big if**

### Nautilus - Stable v2 (Q4 2024)

- Cash out NANO to bank via ACH, WIRE etc. 
- Optional, Metal, NANO debit card (Nano.to/Card) 

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

