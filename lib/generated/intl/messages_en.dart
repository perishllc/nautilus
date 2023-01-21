// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "accountNameHint": MessageLookupByLibrary.simpleMessage("Enter a Name"),
        "accountNameMissing":
            MessageLookupByLibrary.simpleMessage("Choose an Account Name"),
        "accounts": MessageLookupByLibrary.simpleMessage("Accounts"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Are you sure that you\'ve backed up your secret phrase or seed?"),
        "activateSub":
            MessageLookupByLibrary.simpleMessage("Activate Subscription"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Active Message"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Add Account"),
        "addAddress": MessageLookupByLibrary.simpleMessage("Add an Address"),
        "addBlocked": MessageLookupByLibrary.simpleMessage("Block a User"),
        "addContact": MessageLookupByLibrary.simpleMessage("Add Contact"),
        "addFavorite": MessageLookupByLibrary.simpleMessage("Add Favorite"),
        "addNode": MessageLookupByLibrary.simpleMessage("Add Node"),
        "addSubscription":
            MessageLookupByLibrary.simpleMessage("Add Subscription"),
        "addUser": MessageLookupByLibrary.simpleMessage("Add a User"),
        "addWatchOnlyAccount":
            MessageLookupByLibrary.simpleMessage("Add Watch Only Account"),
        "addWatchOnlyAccountError": MessageLookupByLibrary.simpleMessage(
            "Error adding Watch Only Account: Account was null"),
        "addWatchOnlyAccountSuccess": MessageLookupByLibrary.simpleMessage(
            "Successfully created watch only account!"),
        "addWorkSource":
            MessageLookupByLibrary.simpleMessage("Add Work Source"),
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "addressCopied": MessageLookupByLibrary.simpleMessage("Address Copied"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Enter Address"),
        "addressMissing":
            MessageLookupByLibrary.simpleMessage("Please enter an Address"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Please enter a Username or Address"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Share Address"),
        "advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
        "aliases": MessageLookupByLibrary.simpleMessage("Aliases"),
        "amount": MessageLookupByLibrary.simpleMessage("Amount"),
        "amountGiftGreaterError": MessageLookupByLibrary.simpleMessage(
            "Split Amount can\'t be greater than gift balance"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Please enter an Amount"),
        "appWallet": MessageLookupByLibrary.simpleMessage("%1 Wallet"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "We noticed you clicked on a link that contains some %2, would you like to skip the setup process? You can always change things later.\n\n If you have an existing seed that you want to import however, you should select no."),
        "askTracking": MessageLookupByLibrary.simpleMessage(
            "We\'re about to ask for the \"tracking\" permission, this is used *strictly* for attributing links / referrals, and minor analytics (things like number of installs, what app version, etc.) We believe you are entitled to your privacy and are not interested in any of your personal data, we just need the permission in order for link attributions to work correctly."),
        "asked": MessageLookupByLibrary.simpleMessage("Asked"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("Authenticating"),
        "authError": MessageLookupByLibrary.simpleMessage(
            "An error occurred while authenticating. Try again later."),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Authentication Method"),
        "authenticating":
            MessageLookupByLibrary.simpleMessage("Authenticating"),
        "autoImport": MessageLookupByLibrary.simpleMessage("Auto Import"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Automatically Lock"),
        "autoRenewSub":
            MessageLookupByLibrary.simpleMessage("Auto Renew Subscription"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("I\'ve Backed It Up"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Backup Secret Phrase"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Backup Seed"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure that you backed up your wallet seed?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Backup your seed"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Biometrics"),
        "blockExplorer": MessageLookupByLibrary.simpleMessage("Block Explorer"),
        "blockExplorerHeader":
            MessageLookupByLibrary.simpleMessage("Block Explorer Info"),
        "blockExplorerInfo": MessageLookupByLibrary.simpleMessage(
            "Which block explorer to use to display transaction information"),
        "blockUser": MessageLookupByLibrary.simpleMessage("Block this User"),
        "blockedAdded":
            MessageLookupByLibrary.simpleMessage("%1 successfully blocked."),
        "blockedExists":
            MessageLookupByLibrary.simpleMessage("User already Blocked!"),
        "blockedHeader": MessageLookupByLibrary.simpleMessage("Blocked"),
        "blockedInfo": MessageLookupByLibrary.simpleMessage(
            "Block a user by any known alias or address. Any messages, transactions, or requests from them will be ignored."),
        "blockedInfoHeader":
            MessageLookupByLibrary.simpleMessage("Blocked Info"),
        "blockedNameExists":
            MessageLookupByLibrary.simpleMessage("Nick name already used!"),
        "blockedNameMissing":
            MessageLookupByLibrary.simpleMessage("Choose a Nick Name"),
        "blockedRemoved":
            MessageLookupByLibrary.simpleMessage("%1 has been unblocked!"),
        "branchConnectErrorLongDesc": MessageLookupByLibrary.simpleMessage(
            "We can\'t seem to reach the Branch API, this is usually cause by some sort of network issue or VPN blocking the connection.\n\n You should still be able to use the app as normal, however sending and receiving gift cards may not work."),
        "branchConnectErrorShortDesc": MessageLookupByLibrary.simpleMessage(
            "Error: can\'t reach Branch API"),
        "branchConnectErrorTitle":
            MessageLookupByLibrary.simpleMessage("Connection Warning"),
        "businessButton": MessageLookupByLibrary.simpleMessage("Business"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelSub":
            MessageLookupByLibrary.simpleMessage("Cancel Subscription"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("Captcha"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "In order to prevent abuse, we require you to solve a quick captcha on the next page to claim this gift card."),
        "changeCurrency":
            MessageLookupByLibrary.simpleMessage("Change Currency"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Change Log"),
        "changeNode": MessageLookupByLibrary.simpleMessage("Change Node"),
        "changePassword":
            MessageLookupByLibrary.simpleMessage("Change Password"),
        "changePasswordParagraph": MessageLookupByLibrary.simpleMessage(
            "Change your existing password. If you don\'t know your current password, just make your best guess as it\'s not actually required to change it (since you are already logged in), but it does let us delete the existing backup entry."),
        "changePin": MessageLookupByLibrary.simpleMessage("Change Pin"),
        "changePinHint": MessageLookupByLibrary.simpleMessage("Set pin"),
        "changePow": MessageLookupByLibrary.simpleMessage("Change PoW"),
        "changePowSource":
            MessageLookupByLibrary.simpleMessage("Change PoW Source"),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Change Representative"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Change"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Enter New Representative"),
        "changeRepSame": MessageLookupByLibrary.simpleMessage(
            "This is already your representative!"),
        "changeRepSucces": MessageLookupByLibrary.simpleMessage(
            "Representative Changed Successfully"),
        "changeSeed": MessageLookupByLibrary.simpleMessage("Change Seed"),
        "changeSeedParagraph": MessageLookupByLibrary.simpleMessage(
            "Change the seed/phrase associated with this magic-link authed account, whatever password you set here will overwrite your existing password, but you can use the same password if you choose."),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Check Availability"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Confirm the password"),
        "confirmPinHint":
            MessageLookupByLibrary.simpleMessage("Confirm the pin"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Connecting"),
        "connectionWarning":
            MessageLookupByLibrary.simpleMessage("Can\'t Connect"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "We can\'t seem to connect to the backend, this could just be your connection or if the issue persists, the backend might be down for maintanence or even an outage. If it\'s been more than an hour and you\'re still having issues, please submit a report in #bug-reports in the discord server @ chat.perish.co"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "We can\'t seem to connect to the backend, this could just be your connection or if the issue persists, the backend might be down for maintanence or even an outage. If it\'s been more than an hour and you\'re still having issues, please submit a report in #bug-reports in the discord server @ chat.perish.co"),
        "connectionWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "We can\'t seem to connect to the backend"),
        "contactAdded":
            MessageLookupByLibrary.simpleMessage("%1 added to contacts."),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Contact Already Exists"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Contact"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Contact Name"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Enter a Nickname"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Choose a Name for this Contact"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 has been removed from contacts!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Contacts"),
        "contactsImportErr":
            MessageLookupByLibrary.simpleMessage("Failed to import contacts"),
        "contactsImportSuccess": MessageLookupByLibrary.simpleMessage(
            "Sucessfully imported %1 contacts."),
        "continueButton": MessageLookupByLibrary.simpleMessage("Continue"),
        "continueWithoutLogin":
            MessageLookupByLibrary.simpleMessage("Continue without login"),
        "copied": MessageLookupByLibrary.simpleMessage("Copied"),
        "copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Copy Address"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
        "copyMessage": MessageLookupByLibrary.simpleMessage("Copy Message"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Copy Seed"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Copy wallet address to clipboard"),
        "copyXMRSeed": MessageLookupByLibrary.simpleMessage("Copy Monero Seed"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Create a password."),
        "createGiftCard":
            MessageLookupByLibrary.simpleMessage("Create Gift Card"),
        "createGiftHeader":
            MessageLookupByLibrary.simpleMessage("Create a Gift Card"),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "You can create a password to add additional security to your wallet."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Create a password"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "Password is optional, and your wallet will be protected with your PIN or biometrics regardless."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Create"),
        "createPinHint": MessageLookupByLibrary.simpleMessage("Create a pin"),
        "createQR": MessageLookupByLibrary.simpleMessage("Create QR Code"),
        "created": MessageLookupByLibrary.simpleMessage("created"),
        "creatingGiftCard":
            MessageLookupByLibrary.simpleMessage("Creating Gift Card"),
        "currency": MessageLookupByLibrary.simpleMessage("Currency"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Currency Mode"),
        "currencyModeHeader":
            MessageLookupByLibrary.simpleMessage("Currency Mode Info"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Choose which unit to display amounts in.\n1 nyano = 0.000001 NANO, or \n1,000,000 nyano = 1 NANO"),
        "currentlyRepresented":
            MessageLookupByLibrary.simpleMessage("Currently Represented By"),
        "dayAgo": MessageLookupByLibrary.simpleMessage("A day ago"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Decryption Error!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Main Account"),
        "defaultGiftMessage": MessageLookupByLibrary.simpleMessage(
            "Check out %1! I sent you some %2 with this link:"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Account %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteNodeConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this node?\n\nYou can always re-add it later by tapping the \"Add Node\" button"),
        "deleteNodeHeader":
            MessageLookupByLibrary.simpleMessage("Delete Node?"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "deleteSubConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this subscription?\n\nYou can always re-add it later by tapping the \"Add Subscription\" button"),
        "deleteSubHeader":
            MessageLookupByLibrary.simpleMessage("Delete Subscription?"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Disable"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Password has been disabled"),
        "disableWalletPassword":
            MessageLookupByLibrary.simpleMessage("Disable Wallet Password"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
        "doYouHaveSeedBody": MessageLookupByLibrary.simpleMessage(
            "If you\'re not sure what this means then you probably don\'t have a seed to import and can just press continue."),
        "doYouHaveSeedHeader": MessageLookupByLibrary.simpleMessage(
            "Do you have a seed to import?"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Domain Name"),
        "donateButton": MessageLookupByLibrary.simpleMessage("Donate"),
        "donateToSupport":
            MessageLookupByLibrary.simpleMessage("Support the Project"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "enableNotifications":
            MessageLookupByLibrary.simpleMessage("Enable Notifications"),
        "enableTracking":
            MessageLookupByLibrary.simpleMessage("Enable Tracking"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Failed to set a wallet password"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("Enter Address"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Enter Amount"),
        "enterEmail": MessageLookupByLibrary.simpleMessage("Enter Email"),
        "enterFrequency":
            MessageLookupByLibrary.simpleMessage("Enter Frequency"),
        "enterGiftMemo":
            MessageLookupByLibrary.simpleMessage("Enter Gift Note"),
        "enterHeight": MessageLookupByLibrary.simpleMessage("Enter Height"),
        "enterHttpUrl": MessageLookupByLibrary.simpleMessage("Enter HTTP URL"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("Enter Message"),
        "enterMoneroAddress":
            MessageLookupByLibrary.simpleMessage("Enter XMR Address"),
        "enterName": MessageLookupByLibrary.simpleMessage("Enter Name"),
        "enterNodeName":
            MessageLookupByLibrary.simpleMessage("Enter Node Name"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Enter your password"),
        "enterSplitAmount":
            MessageLookupByLibrary.simpleMessage("Enter Split Amount"),
        "enterUserOrAddress":
            MessageLookupByLibrary.simpleMessage("Enter User or Address"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Enter a username"),
        "enterWsUrl":
            MessageLookupByLibrary.simpleMessage("Enter WebSocket URL"),
        "errorProcessingGiftCard": MessageLookupByLibrary.simpleMessage(
            "There was an error while processing this gift card, it may be invalid, expired, or empty.\n\nAdditionally, you may need to update the app to the latest version in order to redeem this gift."),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("someone"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Welcome to %1. Once you receive %2, transactions will show up like this:"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("A little"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("A lot of"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("someone"),
        "examplePayRecipient": MessageLookupByLibrary.simpleMessage("@dad"),
        "examplePayRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Happy Birthday!"),
        "examplePaymentExplainer": MessageLookupByLibrary.simpleMessage(
            "Once you send or receive a payment request, they\'ll show up here like this with the color and tag of the card indicating the status. \n\nGreen indicates the request has been paid.\nYellow indicates the request / memo has not been paid / read.\nRed indicates the request has not been read or received.\n\n Neutral colored cards without an amount are just messages."),
        "examplePaymentFrom": MessageLookupByLibrary.simpleMessage("@landlord"),
        "examplePaymentFulfilled": MessageLookupByLibrary.simpleMessage("Some"),
        "examplePaymentFulfilledMemo":
            MessageLookupByLibrary.simpleMessage("Sushi"),
        "examplePaymentIntro": MessageLookupByLibrary.simpleMessage(
            "Once you send or receive a payment request, they\'ll show up here:"),
        "examplePaymentMessage":
            MessageLookupByLibrary.simpleMessage("Hey what\'s up?"),
        "examplePaymentReceivable":
            MessageLookupByLibrary.simpleMessage("A lot of"),
        "examplePaymentReceivableMemo":
            MessageLookupByLibrary.simpleMessage("Rent"),
        "examplePaymentTo":
            MessageLookupByLibrary.simpleMessage("@best_friend"),
        "exampleRecRecipient":
            MessageLookupByLibrary.simpleMessage("@coworker"),
        "exampleRecRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Gas Money"),
        "exchangeCurrency": MessageLookupByLibrary.simpleMessage("Exchange %2"),
        "exchangeNano": MessageLookupByLibrary.simpleMessage("Exchange NANO"),
        "existingPasswordHint":
            MessageLookupByLibrary.simpleMessage("Enter current password"),
        "existingPinHint":
            MessageLookupByLibrary.simpleMessage("Enter current pin"),
        "exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "exportTXData":
            MessageLookupByLibrary.simpleMessage("Export Transactions"),
        "failed": MessageLookupByLibrary.simpleMessage("failed"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader":
            MessageLookupByLibrary.simpleMessage("%1 Disconnected"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "%1 Servers appear to be disconnected, Sending and Receiving (without memos) should still be operational but payment requests may not go through\n\n Come back later or restart the app to try again"),
        "favoriteExists":
            MessageLookupByLibrary.simpleMessage("Favorite Already Exists"),
        "favoriteHeader": MessageLookupByLibrary.simpleMessage("Favorite"),
        "favoriteInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Favorite Name"),
        "favoriteNameHint":
            MessageLookupByLibrary.simpleMessage("Enter a Nick Name"),
        "favoriteNameMissing": MessageLookupByLibrary.simpleMessage(
            "Choose a Name for this Favorite"),
        "favoriteRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 has been removed from favorites!"),
        "favoritesHeader": MessageLookupByLibrary.simpleMessage("Favorites"),
        "featured": MessageLookupByLibrary.simpleMessage("Featured"),
        "fewDaysAgo": MessageLookupByLibrary.simpleMessage("A few days ago"),
        "fewHoursAgo": MessageLookupByLibrary.simpleMessage("A few hours ago"),
        "fewMinutesAgo":
            MessageLookupByLibrary.simpleMessage("A few minutes ago"),
        "fewSecondsAgo":
            MessageLookupByLibrary.simpleMessage("A few seconds ago"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Authenticate to backup seed."),
        "frequencyEmpty":
            MessageLookupByLibrary.simpleMessage("Please enter a Frequency"),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("fulfilled"),
        "fundingBannerHeader":
            MessageLookupByLibrary.simpleMessage("Funding Banner"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("Funding"),
        "getCurrency": MessageLookupByLibrary.simpleMessage("Get %2"),
        "getNano": MessageLookupByLibrary.simpleMessage("Get NANO"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("You have a gift!"),
        "giftAlertEmpty": MessageLookupByLibrary.simpleMessage("Empty Gift"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("Gift Amount"),
        "giftCardCreationError": MessageLookupByLibrary.simpleMessage(
            "An error occured while trying to create a gift card link"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "An error occured while trying to create a gift card, THE GIFT CARD LINK OR SEED HAS BEEN COPIED TO YOUR CLIPBOARD, YOUR FUNDS MAY BE CONTAINED WITHIN IT DEPENDING ON WHAT WENT WRONG."),
        "giftCardInfoHeader":
            MessageLookupByLibrary.simpleMessage("Gift Sheet Info"),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Gift From"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Load a Digital Gift Card with %2! Set an amount, and an optional message for the recipient to see when they open it!\n\nOnce created, you\'ll get a link that you can send to anyone, which when opened will automatically distribute the funds to the recipient after installing %1!\n\nIf the recipient is already a %1 user they\'ll get a prompt to transfer the funds into their account upon opening the link\n\nYou can also set a split amount to distribute from the gift card rather than the entire balance."),
        "giftMessage": MessageLookupByLibrary.simpleMessage("Gift Message"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "There was an error while processing this gift card. Maybe check your connection and try clicking the gift link again."),
        "giftProcessSuccess": MessageLookupByLibrary.simpleMessage(
            "Gift Successfully Received, it may take a moment to appear in your wallet."),
        "giftRefundSuccess":
            MessageLookupByLibrary.simpleMessage("Gift Successfully Refunded!"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Go Back"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Go to QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Got It!"),
        "handoff": MessageLookupByLibrary.simpleMessage("handoff"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage(
            "Something went wrong while trying to handoff block!"),
        "handoffSupportedMethodNotFound": MessageLookupByLibrary.simpleMessage(
            "A supported handoff method couldn\'t be found!"),
        "haveSeedToImport":
            MessageLookupByLibrary.simpleMessage("I have a seed"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Hide Account?"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to hide empty accounts?\n\nThis will hide all accounts with a balance of exactly 0 (excluding watch only addresses and your main account), but you can always re-add them later by tapping the \"Add Account\" button"),
        "hideAccountsHeader":
            MessageLookupByLibrary.simpleMessage("Hide Accounts?"),
        "hideEmptyAccounts":
            MessageLookupByLibrary.simpleMessage("Hide Empty Accounts"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "homeButton": MessageLookupByLibrary.simpleMessage("Home"),
        "hourAgo": MessageLookupByLibrary.simpleMessage("An hour ago"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("I Understand the Risks"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignore"),
        "imSure": MessageLookupByLibrary.simpleMessage("I\'m Sure"),
        "import": MessageLookupByLibrary.simpleMessage("Import"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "The link you clicked contains some %2, would you like to import it to this wallet, or refund it to whoever sent it?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some %2 appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "It looks like you clicked a link that contains some %2, in order to receive these funds we just need for you to finish setting up your wallet."),
        "importGiftv2": MessageLookupByLibrary.simpleMessage(
            "The link you clicked contains some %2, would you like to import it to this wallet?"),
        "importHD": MessageLookupByLibrary.simpleMessage("Import HD"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Import Secret Phrase"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Please enter your 24-word secret phrase below. Each word should be separated by a space."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Import Seed"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage(
            "Please enter your seed below."),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Import Seed Instead"),
        "importStandard":
            MessageLookupByLibrary.simpleMessage("Import Standard"),
        "importWallet": MessageLookupByLibrary.simpleMessage("Import Wallet"),
        "instantly": MessageLookupByLibrary.simpleMessage("Instantly"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Insufficient Balance"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "We skipped the intro process to save you time, but you should backup your newly created seed immediately.\n\nIf you lose your seed you will lose access to your funds.\n\nAdditionally, your passcode has been set to \"000000\" which you should also change immediately."),
        "introSkippedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Backup your seed!"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Address entered was invalid"),
        "invalidFrequency":
            MessageLookupByLibrary.simpleMessage("Frequency Invalid"),
        "invalidHeight": MessageLookupByLibrary.simpleMessage("Invalid Height"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Invalid Password"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("Invalid Pin"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "Due to iOS App Store guidelines and restrictions, we can\'t link you to our donations page. If you\'d like to support the project, consider sending to the %1 node\'s address."),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("Link Copied"),
        "loaded": MessageLookupByLibrary.simpleMessage("Loaded"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Loaded Into"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Authenticate on Launch"),
        "locked": MessageLookupByLibrary.simpleMessage("Locked"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
        "loginOrRegisterHeader":
            MessageLookupByLibrary.simpleMessage("Login or Register"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Delete Seed and Logout"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Logging out will remove your seed and all %1-related data from this device. If your seed is not backed up, you will never be able to access your funds again"),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "As long as you\'ve backed up your seed you have nothing to worry about."),
        "looksLikeHdSeed": MessageLookupByLibrary.simpleMessage(
            "This appears to be an HD seed, unless you\'re sure you know what you\'re doing, you should use the \"Import HD\" option instead."),
        "looksLikeStandardSeed": MessageLookupByLibrary.simpleMessage(
            "This appears to be a standard seed, you should use the \"Import Standard\" option instead."),
        "manage": MessageLookupByLibrary.simpleMessage("Manage"),
        "mantaError":
            MessageLookupByLibrary.simpleMessage("Couldn\'t Verify Request"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("Manual Entry"),
        "markAsPaid": MessageLookupByLibrary.simpleMessage("Mark as Paid"),
        "markAsUnpaid": MessageLookupByLibrary.simpleMessage("Mark as Unpaid"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Message re-sent! If still unread, the recipient\'s device may be offline."),
        "messageCopied": MessageLookupByLibrary.simpleMessage("Message Copied"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Message"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "Minimum send amount is %1 %2"),
        "minuteAgo": MessageLookupByLibrary.simpleMessage("A minute ago"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 is not a valid word"),
        "mnemonicPhrase":
            MessageLookupByLibrary.simpleMessage("Mnemonic Phrase"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Secret phrase may only contain 24 words"),
        "monthlyServerCosts":
            MessageLookupByLibrary.simpleMessage("Monthly Server Costs"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings": MessageLookupByLibrary.simpleMessage("More Settings"),
        "nameEmpty":
            MessageLookupByLibrary.simpleMessage("Please enter a Name"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "nautilusWallet":
            MessageLookupByLibrary.simpleMessage("Nautilus Wallet"),
        "nearby": MessageLookupByLibrary.simpleMessage("Nearby"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "This feature requires you to have a longer transaction history in order to prevent spam.\n\nAlternatively, you can show a QR code for someone to scan."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Verification Needed"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "This is your new account. Once you receive %2, transactions will show up like this:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("New Wallet"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Next"),
        "nextPayment": MessageLookupByLibrary.simpleMessage("Next Payment"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noContactsExport": MessageLookupByLibrary.simpleMessage(
            "There\'s no contacts to export."),
        "noContactsImport":
            MessageLookupByLibrary.simpleMessage("No new contacts to import."),
        "noSearchResults":
            MessageLookupByLibrary.simpleMessage("No Search Results!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("No, Skip"),
        "noTXDataExport": MessageLookupByLibrary.simpleMessage(
            "There\'s no transactions to export."),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "node": MessageLookupByLibrary.simpleMessage("Node"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("Node Status"),
        "nodes": MessageLookupByLibrary.simpleMessage("Nodes"),
        "noneMethod": MessageLookupByLibrary.simpleMessage("None"),
        "notSent": MessageLookupByLibrary.simpleMessage("not sent"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Open %1 to view this transaction"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Tap to open"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "In order for this feature to work correctly, notifications must be enabled"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Received %1 %2"),
        "notificationWarning":
            MessageLookupByLibrary.simpleMessage("Notifications Disabled"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Payment Requests, Memos, and Messages all require notifications to be enabled in order to work properly as they use the FCM notifications service to ensure message delivery.\n\nYou can enable notifications with the button below or dismiss this card if you don\'t care to use these features."),
        "notificationWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Payment Requests, Memos, and Messages will not function properly."),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Nyanicon"),
        "obscureInfoHeader":
            MessageLookupByLibrary.simpleMessage("Obscure Transaction Info"),
        "obscureTransaction":
            MessageLookupByLibrary.simpleMessage("Obscure Transaction"),
        "obscureTransactionBody": MessageLookupByLibrary.simpleMessage(
            "This is NOT true privacy, but it will make it harder for the recipient to see who sent them funds."),
        "off": MessageLookupByLibrary.simpleMessage("Off"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "onStr": MessageLookupByLibrary.simpleMessage("On"),
        "onboard": MessageLookupByLibrary.simpleMessage("Invite Someone"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Onboarding"),
        "onramp": MessageLookupByLibrary.simpleMessage("Onramp"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Opened"),
        "paid": MessageLookupByLibrary.simpleMessage("paid"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("Paper Wallet"),
        "passwordBlank":
            MessageLookupByLibrary.simpleMessage("Password cannot be empty"),
        "passwordCapitalLetter": MessageLookupByLibrary.simpleMessage(
            "Password must contain at least 1 upper case and lower case letter"),
        "passwordDisclaimer": MessageLookupByLibrary.simpleMessage(
            "We\'re not responsible if you forget your password, and by design we are unable to reset or change it for you."),
        "passwordIncorrect":
            MessageLookupByLibrary.simpleMessage("Incorrect password"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "You will not need a password to open %1 anymore."),
        "passwordNumber": MessageLookupByLibrary.simpleMessage(
            "Password must contain at least 1 number"),
        "passwordSpecialCharacter": MessageLookupByLibrary.simpleMessage(
            "Password must contain at least 1 special character"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Password is too short"),
        "passwordWarning": MessageLookupByLibrary.simpleMessage(
            "This password will be required to open %1."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "This password will be required to open %1."),
        "passwordsDontMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "pay": MessageLookupByLibrary.simpleMessage("Pay"),
        "payRequest": MessageLookupByLibrary.simpleMessage("Pay this request"),
        "paymentHistory":
            MessageLookupByLibrary.simpleMessage("Payment History"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Someone has requested payment from you! check the payments page for more info."),
        "payments": MessageLookupByLibrary.simpleMessage("Payments"),
        "pickFromList":
            MessageLookupByLibrary.simpleMessage("Pick From a List"),
        "pinBlank": MessageLookupByLibrary.simpleMessage("Pin cannot be empty"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("Pins do not match"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Confirm your pin"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Create a 6-digit pin"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("Enter pin"),
        "pinIncorrect":
            MessageLookupByLibrary.simpleMessage("Incorrect pin entered"),
        "pinInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid pin entered"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "Enter PIN to change representative."),
        "pinSeedBackup":
            MessageLookupByLibrary.simpleMessage("Enter PIN to Backup Seed"),
        "pinsDontMatch":
            MessageLookupByLibrary.simpleMessage("Pins do not match"),
        "plausibleDeniabilityParagraph": MessageLookupByLibrary.simpleMessage(
            "This is NOT the same pin you used to create your wallet. Press the info button for more information."),
        "plausibleInfoHeader":
            MessageLookupByLibrary.simpleMessage("Plausible Deniability Info"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Set a secondary pin for plausible deniability mode.\n\nIf your wallet is unlocked using this secondary pin, your seed will be replaced with a hash of the existing seed. This is a security feature intended to be used in the event you are forced to open your wallet.\n\nThis pin will act like a normal (correct) pin EXCEPT when unlocking your wallet, which is when plausible deniability mode will activate.\n\nYour funds WILL BE LOST upon entering plausible deniability mode if you have not backed up your seed!"),
        "pow": MessageLookupByLibrary.simpleMessage("PoW"),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "proSubRequiredHeader": MessageLookupByLibrary.simpleMessage(
            "%1 Pro Subscription Required"),
        "proSubRequiredParagraph": MessageLookupByLibrary.simpleMessage(
            "For just %3 %2 per month, you can unlock all of the features of %1 Pro."),
        "promotionalLink": MessageLookupByLibrary.simpleMessage("Free %2"),
        "purchaseCurrency": MessageLookupByLibrary.simpleMessage("Purchase %2"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Purchase Nano"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR code does not contain a valid destination"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Please Grant Camera Permissions to scan QR Codes"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "QR code does not contain a valid seed or private key"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "QR does not contain a valid secret phrase"),
        "qrUnknownError":
            MessageLookupByLibrary.simpleMessage("Could not Read QR Code"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp": MessageLookupByLibrary.simpleMessage("Rate the App"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn\'t take more than a minute."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Raw Seed"),
        "readMore": MessageLookupByLibrary.simpleMessage("Read More"),
        "receivable": MessageLookupByLibrary.simpleMessage("receivable"),
        "receive": MessageLookupByLibrary.simpleMessage("Receive"),
        "receiveMinimum":
            MessageLookupByLibrary.simpleMessage("Receive Minimum"),
        "receiveMinimumHeader":
            MessageLookupByLibrary.simpleMessage("Receive Minimum Info"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "A minimum amount to receive. If a payment or request is received with an amount less than this, it will be ignored."),
        "received": MessageLookupByLibrary.simpleMessage("Received"),
        "refund": MessageLookupByLibrary.simpleMessage("Refund"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Register"),
        "registerFor": MessageLookupByLibrary.simpleMessage("for"),
        "registerUsername":
            MessageLookupByLibrary.simpleMessage("Register Username"),
        "registerUsernameHeader":
            MessageLookupByLibrary.simpleMessage("Register a Username"),
        "registering": MessageLookupByLibrary.simpleMessage("Registering"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to hide this account? You can re-add it later by tapping the \"%1\" button."),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("Unblock"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to unblock %1?"),
        "removeContact": MessageLookupByLibrary.simpleMessage("Remove Contact"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Remove Favorite"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "A representative is an account that votes for network consensus. Voting power is weighted by balance, you may delegate your balance to increase the voting weight of a representative you trust. Your representative does not have spending power over your funds. You should choose a representative that has little downtime and is trustworthy."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("What is a representative?"),
        "reply": MessageLookupByLibrary.simpleMessage("Reply"),
        "representatives":
            MessageLookupByLibrary.simpleMessage("Representatives"),
        "request": MessageLookupByLibrary.simpleMessage("Request"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Request %1 %2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Request Failed: This user doesn\'t appear to have %1 installed, or has notifications disabled."),
        "requestFrom": MessageLookupByLibrary.simpleMessage("Request From"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Request Payment"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Error sending payment request, the recipient\'s device may be offline or unavailable."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Request re-sent! If still unread, the recipient\'s device may be offline."),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other %1 users, but you can use them for your own record keeping even if the recipient doesn\'t use %1."),
        "requestSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Request Sheet Info"),
        "requested": MessageLookupByLibrary.simpleMessage("Requested"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Requested From"),
        "requesting": MessageLookupByLibrary.simpleMessage("Requesting"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Require a password to open %1?"),
        "requireCaptcha": MessageLookupByLibrary.simpleMessage(
            "Require CAPTCHA to claim gift card"),
        "resendMemo": MessageLookupByLibrary.simpleMessage("Resend this memo"),
        "resetAccountButton":
            MessageLookupByLibrary.simpleMessage("Reset Account"),
        "resetAccountParagraph": MessageLookupByLibrary.simpleMessage(
            "This will make a new account with the password you have just set, the old account won\'t be deleted unless the passwords chosen are the same."),
        "resetDatabase": MessageLookupByLibrary.simpleMessage("Reset the App"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure? This will delete any gift cards you have created, memos, messages, and contacts will all be erased.\n\nThis will NOT delete your wallet\'s internal seed, but you should still back it up if you haven\'t done so already. If you\'re having issues or encountering a bug, you should report it on the discord server (the link to it is at the bottom of the settings drawer)."),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "It appears your device is \"rooted\", \"jailbroken\", or modified in a way that compromises security. It is recommended that you reset your device to its original state before proceeding."),
        "scanInstructions":
            MessageLookupByLibrary.simpleMessage("Scan a %2 \naddress QR code"),
        "scanNFC": MessageLookupByLibrary.simpleMessage("Scan NFC"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Scan QR Code"),
        "schedule": MessageLookupByLibrary.simpleMessage("Schedule"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Search for anything"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "In the next screen, you will see your secret phrase. It is a password to access your funds. It is crucial that you back it up and never share it with anyone."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Safety First!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Secret Phrase"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Secret Phrase Copied"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Copy Secret Phrase"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "If you lose your device or uninstall the application, you\'ll need your secret phrase or seed to recover your funds!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Security"),
        "seed": MessageLookupByLibrary.simpleMessage("Seed"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Below is your wallet\'s seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Seed Copied to Clipboard\nIt is pasteable for 2 minutes."),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("Seed Copied"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "A seed bears the same information as a secret phrase, but in a machine-readable way. As long as you have one of them backed up, you\'ll have access to your funds."),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("Seed is Invalid"),
        "selfSendError":
            MessageLookupByLibrary.simpleMessage("Can\'t request from self"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendAmountConfirm": MessageLookupByLibrary.simpleMessage("Send %1 %2"),
        "sendAmounts": MessageLookupByLibrary.simpleMessage("Send Amounts"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "An error occurred. Try again later."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Send From"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Sending memo with transaction failed, they may not be a %1 user."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Sending message"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Send Request again"),
        "sendRequests": MessageLookupByLibrary.simpleMessage("Send Requests"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Send or Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other %1 users.\n\nYou don\'t need to have a username in order to send or receive payment requests, and you can use them for your own record keeping even if they don\'t use %1."),
        "sendSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Send Sheet Info"),
        "sending": MessageLookupByLibrary.simpleMessage("Sending"),
        "sent": MessageLookupByLibrary.simpleMessage("Sent"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Sent To"),
        "set": MessageLookupByLibrary.simpleMessage("Set"),
        "setPassword": MessageLookupByLibrary.simpleMessage("Set Password"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Password has been set successfully"),
        "setPin": MessageLookupByLibrary.simpleMessage("Set Pin"),
        "setPinParagraph": MessageLookupByLibrary.simpleMessage(
            "Set or change your existing PIN. If you haven\'t set a PIN yet, the default PIN is 000000."),
        "setPinSuccess": MessageLookupByLibrary.simpleMessage(
            "Pin has been set successfully"),
        "setPlausibleDeniabilityPin":
            MessageLookupByLibrary.simpleMessage("Set Plausible Pin"),
        "setRestoreHeight":
            MessageLookupByLibrary.simpleMessage("Set Restore Height"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Set Wallet Password"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin": MessageLookupByLibrary.simpleMessage(""),
        "setXMRRestoreHeight":
            MessageLookupByLibrary.simpleMessage("Set XMR Restore Height"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingsTransfer":
            MessageLookupByLibrary.simpleMessage("Load from Paper Wallet"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "shareApp": MessageLookupByLibrary.simpleMessage("Share %1"),
        "shareAppText": MessageLookupByLibrary.simpleMessage(
            "Check out %1! A premier %2 mobile wallet!"),
        "shareLink": MessageLookupByLibrary.simpleMessage("Share Link"),
        "shareMessage": MessageLookupByLibrary.simpleMessage("Share Message"),
        "shareNautilus": MessageLookupByLibrary.simpleMessage("Share Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Check out Nautilus! A premier NANO mobile wallet!"),
        "shareText": MessageLookupByLibrary.simpleMessage("Share Text"),
        "shopButton": MessageLookupByLibrary.simpleMessage("Shop"),
        "show": MessageLookupByLibrary.simpleMessage("Show"),
        "showAccountInfo": MessageLookupByLibrary.simpleMessage("Account Info"),
        "showAccountQR":
            MessageLookupByLibrary.simpleMessage("Show Account QR Code"),
        "showContacts": MessageLookupByLibrary.simpleMessage("Show Contacts"),
        "showFunding":
            MessageLookupByLibrary.simpleMessage("Show Funding Banner"),
        "showLinkOptions":
            MessageLookupByLibrary.simpleMessage("Show Link Options"),
        "showLinkQR": MessageLookupByLibrary.simpleMessage("Show Link QR"),
        "showMoneroHeader": MessageLookupByLibrary.simpleMessage("Show Monero"),
        "showMoneroInfo":
            MessageLookupByLibrary.simpleMessage("Enable Monero Section"),
        "showQR": MessageLookupByLibrary.simpleMessage("Show QR Code"),
        "showUnopenedWarning":
            MessageLookupByLibrary.simpleMessage("Unopened Warning"),
        "simplex": MessageLookupByLibrary.simpleMessage("Simplex"),
        "social": MessageLookupByLibrary.simpleMessage("Social"),
        "someone": MessageLookupByLibrary.simpleMessage("someone"),
        "spendCurrency": MessageLookupByLibrary.simpleMessage("Spend %2"),
        "spendNano": MessageLookupByLibrary.simpleMessage("Spend NANO"),
        "splitBill": MessageLookupByLibrary.simpleMessage("Split Bill"),
        "splitBillHeader": MessageLookupByLibrary.simpleMessage("Split A Bill"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "Send a bunch of payment requests at once! Makes it easy it split a bill at a restaurant for example."),
        "splitBillInfoHeader":
            MessageLookupByLibrary.simpleMessage("Split Bill Info"),
        "splitBy": MessageLookupByLibrary.simpleMessage("Split By"),
        "subsButton": MessageLookupByLibrary.simpleMessage("Subscriptions"),
        "subscribeButton": MessageLookupByLibrary.simpleMessage("Subscribe"),
        "subscribeWithApple":
            MessageLookupByLibrary.simpleMessage("Subscribe via Apple Pay"),
        "subscribed": MessageLookupByLibrary.simpleMessage("Subscribed"),
        "subscribing": MessageLookupByLibrary.simpleMessage("Subscribing"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment":
            MessageLookupByLibrary.simpleMessage("Help Support Development"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Support the Developer"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("Swap XMR"),
        "swapXMRHeader": MessageLookupByLibrary.simpleMessage("Swap Monero"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "Monero is a privacy-focused cryptocurrency that makes it very hard or even impossible to trace transactions. Meanwhile %2 is a payments-focused cryptocurrency that is fast and fee-less. Together they provide some of the most useful aspects of cryptocurrencies!\n\nUse this page to easily swap your %2 for XMR!"),
        "swapping": MessageLookupByLibrary.simpleMessage("Swapping"),
        "switchToSeed": MessageLookupByLibrary.simpleMessage("Switch to Seed"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("System Default"),
        "tapMessageToEdit":
            MessageLookupByLibrary.simpleMessage("Tap message to edit"),
        "tapToHide": MessageLookupByLibrary.simpleMessage("Tap to hide"),
        "tapToReveal": MessageLookupByLibrary.simpleMessage("Tap to reveal"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Theme"),
        "thisMayTakeSomeTime":
            MessageLookupByLibrary.simpleMessage("this may take a while..."),
        "to": MessageLookupByLibrary.simpleMessage("To"),
        "todayAt": MessageLookupByLibrary.simpleMessage("Today at"),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "Too many failed unlock attempts."),
        "trackingHeader":
            MessageLookupByLibrary.simpleMessage("Tracking Authorization"),
        "trackingWarning":
            MessageLookupByLibrary.simpleMessage("Tracking Disabled"),
        "trackingWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Gift Card functionality may be reduced or not work at all if tracking is disabled. We use this permission EXCLUSIVELY for this feature. Absolutely none of your data is sold, collected or tracked on the backend for any purpose beyond necessary"),
        "trackingWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Gift Card Links will not function properly"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transactions"),
        "transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
        "transferClose": MessageLookupByLibrary.simpleMessage(
            "Tap anywhere to close the window."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 %2 successfully transferred to your %3 Wallet.\n"),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "A wallet with a balance of %1 %2 has been detected.\n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "Tap confirm to transfer the funds.\n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "Transfer may take several seconds to complete."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "An error has occurred during the transfer. Please try again later."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Transfer Funds"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "This process will transfer the funds from a paper wallet to your %2 wallet.\n\nTap the \"%1\" button to start."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "This process will transfer the funds from a paper wallet to your %1 wallet."),
        "transferLoading": MessageLookupByLibrary.simpleMessage("Transferring"),
        "transferManualHint": MessageLookupByLibrary.simpleMessage(
            "Please enter the seed below."),
        "transferNoFunds": MessageLookupByLibrary.simpleMessage(
            "This seed does not have any %2 on it"),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "This QR code does not contain a valid seed."),
        "transferQrScanHint": MessageLookupByLibrary.simpleMessage(
            "Scan a %2 \nseed or private key"),
        "unacknowledged":
            MessageLookupByLibrary.simpleMessage("unacknowledged"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("unconfirmed"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("unfulfilled"),
        "unlock": MessageLookupByLibrary.simpleMessage("Unlock"),
        "unlockBiometrics":
            MessageLookupByLibrary.simpleMessage("Authenticate to Unlock %1"),
        "unlockPin":
            MessageLookupByLibrary.simpleMessage("Enter PIN to Unlock %1"),
        "unopenedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Show Unopened Warning"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "Show a warning when sending funds to an unopened account, this is useful because most of the time addresses you send to will have a balance, and sending to a new address may be the result of a typo."),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "Are you sure this is the right address?\nThis account appears to be unopened\n\nYou can disable this warning in the settings drawer under \"Unopened Warning\""),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("Account Unopened"),
        "unpaid": MessageLookupByLibrary.simpleMessage("unpaid"),
        "unread": MessageLookupByLibrary.simpleMessage("unread"),
        "uptime": MessageLookupByLibrary.simpleMessage("Uptime"),
        "urlEmpty": MessageLookupByLibrary.simpleMessage("Please enter a URL"),
        "useAppRep": MessageLookupByLibrary.simpleMessage("Use %1 Rep"),
        "useCurrency": MessageLookupByLibrary.simpleMessage("Use %2"),
        "useNano": MessageLookupByLibrary.simpleMessage("Use NANO"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userAlreadyAddedError":
            MessageLookupByLibrary.simpleMessage("User already added!"),
        "userNotFound": MessageLookupByLibrary.simpleMessage("User not found!"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "usernameAvailable":
            MessageLookupByLibrary.simpleMessage("Username available!"),
        "usernameEmpty":
            MessageLookupByLibrary.simpleMessage("Please enter a Username"),
        "usernameError": MessageLookupByLibrary.simpleMessage("Username Error"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "Pick out a unique @username to make it easy for friends and family to find you!\n\nHaving a %1 username updates the UI globally to reflect your new handle."),
        "usernameInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Username"),
        "usernameUnavailable":
            MessageLookupByLibrary.simpleMessage("Username unavailable"),
        "usernameWarning": MessageLookupByLibrary.simpleMessage(
            "%1 usernames are a centralized service provided by Nano.to"),
        "using": MessageLookupByLibrary.simpleMessage("Using"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("View Details"),
        "viewPaymentHistory":
            MessageLookupByLibrary.simpleMessage("View Payment History"),
        "viewTX": MessageLookupByLibrary.simpleMessage("View Transaction"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("Voting Weight"),
        "warning": MessageLookupByLibrary.simpleMessage("Warning"),
        "watchAccountExists":
            MessageLookupByLibrary.simpleMessage("Account already added!"),
        "watchOnlyAccount":
            MessageLookupByLibrary.simpleMessage("Watch Only Account"),
        "watchOnlySendDisabled": MessageLookupByLibrary.simpleMessage(
            "Sends are disabled on watch only addresses"),
        "weekAgo": MessageLookupByLibrary.simpleMessage("A week ago"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(""),
        "welcomeTextLogin": MessageLookupByLibrary.simpleMessage(
            "Welcome to %1. Choose an option to get started or pick a theme using the icon below."),
        "welcomeTextUpdated": MessageLookupByLibrary.simpleMessage(
            "Welcome to %1. To start, create a new wallet or import an existing one."),
        "welcomeTextWithoutLogin": MessageLookupByLibrary.simpleMessage(
            "To start, create a new wallet or import an existing one."),
        "withAddress": MessageLookupByLibrary.simpleMessage("With Address"),
        "withFee": MessageLookupByLibrary.simpleMessage("With Fee"),
        "withMessage": MessageLookupByLibrary.simpleMessage("With Message"),
        "xMinute": MessageLookupByLibrary.simpleMessage("After %1 minute"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("After %1 minutes"),
        "xmrStatusConnecting":
            MessageLookupByLibrary.simpleMessage("Connecting"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("Error"),
        "xmrStatusLoading": MessageLookupByLibrary.simpleMessage("Loading"),
        "xmrStatusSynchronized": MessageLookupByLibrary.simpleMessage("Synced"),
        "xmrStatusSynchronizing":
            MessageLookupByLibrary.simpleMessage("Syncing"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Yes"),
        "yesterdayAt": MessageLookupByLibrary.simpleMessage("Yesterday at")
      };
}
