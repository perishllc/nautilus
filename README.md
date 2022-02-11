# Nautilus Wallet

![Cover](/assets/banner.png)

### A [Natrium](https://github.com/appditto/natrium_wallet_flutter) fork, with [Nano.to](https://github.com/formsend/nano) usernames, payment requests, and more.

This project is in development by the team @ [Nano.to](https://nano.to/development)


___

#### Major Features
- [x] Input nano.to usernames instead of addresses
- [x] Auto-fill usernames where applicable
- [x] Request payment from any nautilus waller user.
- [x] Minumum receive amount is a user preference that can be changed.
- [x] Users can be favorited and will be shown in the 'Favorites' list.
- [x] Receive screen live update-able QR code
- [ ] Generate paper gift cards (paper wallets) in app, to be sent either as a link or a capy-paste-able string
- [x] Auto-loading of paper wallets found in the clipboard w/ confirmation on app open
- [ ] Username Reservations in app
- [ ] Replace all AppDitto trademarks, as to not infringe on their marks. 
   - [x] Move all appditto assets to a legacy_assets folder, to be removed as replacements are made

#### Aesthetic goals
- [x] Show nano.to usernames over full addresses wherever possible
- [x] Registered usernames called usernames.
- [ ] Usernames should be clickable to reveal the full address & when the username was last leased / updated
- [x] Simplify the 'New User' onboarding process down to 1-3 steps
   - Ask to import seed or create one
   - Backup Seed
   - Set Pin
- [x] Local contacts changed to favorites.
- [x] UI to differenciate between Favorites & Usernames.
   - Favorites prefixed with '★'
   - Usernames prefixed with '@'
- [x] Change default theme to a darker color.
- [x] Increase 'Receive' screen font size of NANO Address by 50%. Reduce QR Code size by 30%
- [x] Advanced theming support
- [x] Payment Requests are easy to make, and make it easy to pay a request

#### Immediate TODO

#### TODO / Improvements
- [ ] fix bug with account balance of current wallet in accounts screen being incorrectly displayed as 0
- [ ] cache json from /reps and /known
- [ ] set random representative for new accounts using nano.to/reps
- [ ] provide a discount for usernames registered through nautilus
- [ ] setting that lets you choose which username to display in the app if multiple are registered

## Planned features
- [ ] paper wallet generator / sender in app
- [ ] finish payment request feature
- [ ] dedicated past payments screen
- [ ] [Recurring and scheduled sends](https://github.com/appditto/natrium_wallet_flutter/issues/109) (credit: JediJiuJitsu)



#### Changes so far
- [x] removed natricons
- [x] most branding / strings replaced with Nautilus
- [x] experimenting with themes
- [x] start changing the send screen
- [x] update app icons (not final)
- [x] use json data on the send screen
- [x] finish contacts -> favorites
- [x] change addresses to usernames in the transaction history
- [x] add buy nano button to the drawer
- [x] add register username button to the drawer
- [x] add web views for the buttons
- [x] remove btc from top bar
- [x] use usernames in place of shorthand addresses where applicable
- [x] simplified intro process
- [x] scaled down the QR code size on the receive screen and added usernames when available
- [x] fix sending to local favorites
- [x] lots of UX improvements especially with favorites / sending in general
- [x] replace natrium logo from the center of generated QR codes
- [x] fix bug with account history not showing up
- [x] use different star icon for the app drawer favorites
- [x] add more icons to the app drawer
- [x] fix currency symbol bugs
- [x] replace android/app/src/main/ic_launcher-web.png *must* be 512x512 for the play store
- [x] fix "invalid favorite" error when sending an invalid username
- [x] change @ to ★ on the send screen
- [x] nyano mode, complete with unit changes
- [x] generating paper wallets
- [x] request / pay buttons from usernames [requires server-side work]
- [x] push notifications for requests that when tapped bring you to the send screen pre-filled with the request
- [x] change send button to not be disabled with an empty balance (for payment requests)
- [x] auto detect and ask to load paper wallets from the clipboard
- [x] receive screen update-able QR code

<div style="display: flex; flex-direction: row">
   <img src="/screenshots/flutter_01.png" width="200">
   <img src="/screenshots/flutter_02.png" width="200">
</div>
<div style="display: flex; flex-direction: row">
   <img src="/screenshots/flutter_03.png" width="200">
   <img src="/screenshots/flutter_06.png" width="200">
</div>
<div style="display: flex; flex-direction: row">
   <img src="/screenshots/flutter_04.png" width="200">
   <img src="/screenshots/flutter_05.png" width="200">
</div>

___

## Timeline (subject to change)

### Nautilus - Beta 0.1 (Q1 2022)

- Build with some / core features, provide an apk on github

### Nautilus - Beta 0.25 (Q1 2022)
- Proper integration with a payment platform to allow the purchase of nano using a debit/credit card.
   - Likely Simplex / MoonPay

### Nautilus - Beta 0.5 (Q2 2022)

- Wider release / testing
- On the Google Play Store

### Nautilus - Beta 0.9 (Q3 2022)

- Available on most App stores.

### Nautilus - Stable v1 (Q1 2023)

- On device PoW generation. **Apple may not allow this. We'll see**
- Eliminate or minimize back-end server requirements.
- Offline / NFC Payments

### Nautilus - Stable v2 (Q4 2024)
- Cash out NANO to bank via ACH, WIRE etc.
- Optional, Metal, NANO debit card (Nano.to/Card)


___


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

## License

Nautilus is released under the MIT License, the same license as Natrium.
