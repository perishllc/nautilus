// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a lv locale. All the
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
  String get localeName => 'lv';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Konts"),
        "accountNameHint":
            MessageLookupByLibrary.simpleMessage("Ievadiet Vārdu"),
        "accountNameMissing":
            MessageLookupByLibrary.simpleMessage("Izvēlieties konta nosaukumu"),
        "accounts": MessageLookupByLibrary.simpleMessage("Konti"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Vai esat drošs ka izveidojāt rezerves kopiju slepenajai frāzei vai privātajai atslēgai?"),
        "activateSub":
            MessageLookupByLibrary.simpleMessage("Aktivizējiet abonementu"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Active Message"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Pievienot kontu"),
        "addAddress":
            MessageLookupByLibrary.simpleMessage("Pievienojiet adresi"),
        "addBlocked": MessageLookupByLibrary.simpleMessage("Block a User"),
        "addContact":
            MessageLookupByLibrary.simpleMessage("Pievienot kontaktu"),
        "addFavorite": MessageLookupByLibrary.simpleMessage("Add Favorite"),
        "addNode": MessageLookupByLibrary.simpleMessage("Pievienot mezglu"),
        "addSubscription":
            MessageLookupByLibrary.simpleMessage("Pievienot abonementu"),
        "addUser":
            MessageLookupByLibrary.simpleMessage("Pievienojiet lietotāju"),
        "addWatchOnlyAccount": MessageLookupByLibrary.simpleMessage(
            "Pievienojiet tikai skatīšanās kontu"),
        "addWatchOnlyAccountError": MessageLookupByLibrary.simpleMessage(
            "Pievienojot tikai skatīšanās kontu, radās kļūda: konts bija nulle"),
        "addWatchOnlyAccountSuccess": MessageLookupByLibrary.simpleMessage(
            "Veiksmīgi izveidots tikai pulksteņa konts!"),
        "address": MessageLookupByLibrary.simpleMessage("Adrese"),
        "addressCopied":
            MessageLookupByLibrary.simpleMessage("Adrese nokopēta"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Enter Address"),
        "addressMissing":
            MessageLookupByLibrary.simpleMessage("Lūdzu ievadiet adresi"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Please Enter a Username or Address"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Kopīgot adresi"),
        "advanced": MessageLookupByLibrary.simpleMessage("Papildu"),
        "aliases": MessageLookupByLibrary.simpleMessage("Aliases"),
        "amountGiftGreaterError": MessageLookupByLibrary.simpleMessage(
            "Dalītā summa nevar būt lielāka par dāvanas atlikumu"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Lūdzu ievadiet daudzumu"),
        "appWallet": MessageLookupByLibrary.simpleMessage("%1 Maks"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "Mēs pamanījām, ka esat noklikšķinājis uz saites, kurā ir ietverts nanoelements. Vai vēlaties izlaist iestatīšanas procesu? Jūs vienmēr varat mainīt lietas vēlāk.\n\n Tomēr, ja jums ir kāda sēkla, kuru vēlaties importēt, atlasiet nē."),
        "askTracking": MessageLookupByLibrary.simpleMessage(
            "Mēs gatavojamies lūgt \"izsekošanas\" atļauju. Šī atļauja tiek izmantota *stingri*, lai piešķirtu saites / novirzīšanas un nelielas analīzes datus (piemēram, instalēšanas reižu skaits, lietotnes versija utt.). Mēs uzskatām, ka jums ir tiesības uz savu privātumu. un mūs neinteresē nekādi jūsu personas dati, mums ir nepieciešama tikai atļauja, lai saišu attiecinājumi darbotos pareizi."),
        "asked": MessageLookupByLibrary.simpleMessage("Asked"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("Autentifikācija"),
        "authError": MessageLookupByLibrary.simpleMessage(
            "Autentifikācijas laikā radās kļūda. Pamēģini vēlreiz vēlāk."),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Autentificēšanās metode"),
        "authenticating":
            MessageLookupByLibrary.simpleMessage("Autentifikācija"),
        "autoImport": MessageLookupByLibrary.simpleMessage("Auto Import"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Automātiski aizslēgt"),
        "autoRenewSub": MessageLookupByLibrary.simpleMessage(
            "Automātiski atjaunot abonementu"),
        "backupConfirmButton": MessageLookupByLibrary.simpleMessage(
            "Esmu izveidojis rezerves kopiju"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Backup Secret Phrase"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Kopēt sēklu"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Vai esat drošs, ka saglabājāt sēklas rezerves kopiju?"),
        "backupYourSeed": MessageLookupByLibrary.simpleMessage(
            "Izveidojiet sēklas rezerves kopiju"),
        "biometricsMethod":
            MessageLookupByLibrary.simpleMessage("Biometriskā atpazīšana"),
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
            "Šķiet, ka mēs nevaram sasniegt Branch API, jo parasti to izraisa kāda veida tīkla problēma vai VPN, kas bloķē savienojumu.\n\n Jums joprojām vajadzētu būt iespējai izmantot lietotni kā parasti, taču dāvanu karšu nosūtīšana un saņemšana var nedarboties."),
        "branchConnectErrorShortDesc": MessageLookupByLibrary.simpleMessage(
            "Kļūda: nevar sasniegt Branch API"),
        "branchConnectErrorTitle":
            MessageLookupByLibrary.simpleMessage("Brīdinājums par savienojumu"),
        "businessButton": MessageLookupByLibrary.simpleMessage("Bizness"),
        "cancel": MessageLookupByLibrary.simpleMessage("Atcelt"),
        "cancelSub": MessageLookupByLibrary.simpleMessage("Anulēt abonementu"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("Captcha"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "Lai novērstu ļaunprātīgu izmantošanu, mēs pieprasām jums atrisināt captcha, lai nākamajā lapā varētu pieprasīt dāvanu karti."),
        "changeCurrency": MessageLookupByLibrary.simpleMessage("Mainīt valūtu"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Change Log"),
        "changeNode": MessageLookupByLibrary.simpleMessage("Mainīt mezglu"),
        "changePassword": MessageLookupByLibrary.simpleMessage("Mainīt paroli"),
        "changePasswordParagraph": MessageLookupByLibrary.simpleMessage(
            "Mainiet savu esošo paroli. Ja nezināt savu pašreizējo paroli, vienkārši uzminējiet, jo tā faktiski nav jāmaina (jo jūs jau esat pieteicies), taču tas ļauj mums izdzēst esošo rezerves ierakstu."),
        "changePin": MessageLookupByLibrary.simpleMessage("Mainīt Pin"),
        "changePinHint": MessageLookupByLibrary.simpleMessage("Iestatīt tapu"),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Mainīt pārstāvi"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Mainīt"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Ievadiet jaunu pārstāvi"),
        "changeRepSame": MessageLookupByLibrary.simpleMessage(
            "This is already your representative!"),
        "changeRepSucces":
            MessageLookupByLibrary.simpleMessage("Pārstāvis nomainīts sekmīgi"),
        "changeSeed": MessageLookupByLibrary.simpleMessage("Mainīt sēklu"),
        "changeSeedParagraph": MessageLookupByLibrary.simpleMessage(
            "Mainiet sēklu/frāzi, kas saistīta ar šo maģiskās saites autentificēto kontu, neatkarīgi no šeit iestatītās paroles tiks pārrakstīta jūsu esošā parole, taču varat izmantot to pašu paroli, ja vēlaties."),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Check Availability"),
        "close": MessageLookupByLibrary.simpleMessage("Aizvērt"),
        "confirm": MessageLookupByLibrary.simpleMessage("Apstiprināt"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Confirm the password"),
        "confirmPinHint":
            MessageLookupByLibrary.simpleMessage("Apstipriniet spraudīti"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Connecting"),
        "connectionWarning":
            MessageLookupByLibrary.simpleMessage("Nevar izveidot savienojumu"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "Šķiet, ka mēs nevaram izveidot savienojumu ar aizmugursistēmu. Tas var būt tikai jūsu savienojums vai, ja problēma joprojām pastāv, aizmugursistēma var nedarboties apkopes vai pat pārtraukuma dēļ. Ja ir pagājusi vairāk nekā stunda un problēmas joprojām pastāv, lūdzu, iesniedziet ziņojumu sadaļā #bug-reports discord serverī @ chat.perish.co"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Šķiet, ka mēs nevaram izveidot savienojumu ar aizmugursistēmu. Tas var būt tikai jūsu savienojums vai, ja problēma joprojām pastāv, aizmugursistēma var nedarboties apkopes vai pat pārtraukuma dēļ. Ja ir pagājusi vairāk nekā stunda un problēmas joprojām pastāv, lūdzu, iesniedziet ziņojumu sadaļā #bug-reports discord serverī @ chat.perish.co"),
        "connectionWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Šķiet, ka nevar izveidot savienojumu ar aizmugursistēmu"),
        "contactAdded":
            MessageLookupByLibrary.simpleMessage("%1 pievienots kontaktiem."),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Kontakts jau eksistē"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Kontakts"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Nederīgs kontakta nosaukums"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Ievadiet nosaukumu @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Izvēlieties kontakta nosaukumu"),
        "contactRemoved":
            MessageLookupByLibrary.simpleMessage("%1 dzēsts no kontaktiem!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Kontakti"),
        "contactsImportErr": MessageLookupByLibrary.simpleMessage(
            "Neizdevās importēt kontaktus"),
        "contactsImportSuccess": MessageLookupByLibrary.simpleMessage(
            "Sekmīgi importēti %1 kontakti."),
        "continueButton": MessageLookupByLibrary.simpleMessage("Turpināt"),
        "continueWithoutLogin":
            MessageLookupByLibrary.simpleMessage("Turpināt bez pieteikšanās"),
        "copied": MessageLookupByLibrary.simpleMessage("Nokopēts"),
        "copy": MessageLookupByLibrary.simpleMessage("Kopēt"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Kopēt adresi"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
        "copyMessage": MessageLookupByLibrary.simpleMessage("Kopēt ziņojumu"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Kopēt sēklu"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Copy wallet address to clipboard"),
        "copyXMRSeed":
            MessageLookupByLibrary.simpleMessage("Kopējiet Monero Seed"),
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
        "createPinHint":
            MessageLookupByLibrary.simpleMessage("Izveidojiet spraudīti"),
        "createQR": MessageLookupByLibrary.simpleMessage("Create QR Code"),
        "created": MessageLookupByLibrary.simpleMessage("izveidots"),
        "creatingGiftCard":
            MessageLookupByLibrary.simpleMessage("Creating Gift Card"),
        "currency": MessageLookupByLibrary.simpleMessage("Currency"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Currency Mode"),
        "currencyModeHeader":
            MessageLookupByLibrary.simpleMessage("Currency Mode Info"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Choose which unit to display amounts in.\n1 nyano = 0.000001 NANO, or \n1,000,000 nyano = 1 NANO"),
        "currentlyRepresented":
            MessageLookupByLibrary.simpleMessage("Pašreizējais pārstāvis ir"),
        "dayAgo": MessageLookupByLibrary.simpleMessage("Pirms dienas"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Decryption Error!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Pamata konts"),
        "defaultGiftMessage": MessageLookupByLibrary.simpleMessage(
            "Iepazīstieties ar Nautilus! Es nosūtīju jums nano ar šo saiti:"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Konts %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteNodeConfirmation": MessageLookupByLibrary.simpleMessage(
            "Vai tiešām vēlaties dzēst šo mezglu?\n\nJūs vienmēr varat to atkārtoti pievienot vēlāk, pieskaroties pogai \"Pievienot mezglu\"."),
        "deleteNodeHeader":
            MessageLookupByLibrary.simpleMessage("Vai dzēst mezglu?"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "deleteSubConfirmation": MessageLookupByLibrary.simpleMessage(
            "Vai tiešām vēlaties dzēst šo abonementu?\n\nJūs vienmēr varat to atkārtoti pievienot vēlāk, pieskaroties pogai \"Pievienot abonementu\"."),
        "deleteSubHeader":
            MessageLookupByLibrary.simpleMessage("Vai dzēst abonementu?"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Disable"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Password has been disabled"),
        "disableWalletPassword":
            MessageLookupByLibrary.simpleMessage("Disable Wallet Password"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
        "doYouHaveSeedBody": MessageLookupByLibrary.simpleMessage(
            "Ja neesat pārliecināts, ko tas nozīmē, iespējams, jums nav sēklu, ko importēt, un varat vienkārši nospiest Turpināt."),
        "doYouHaveSeedHeader": MessageLookupByLibrary.simpleMessage(
            "Vai jums ir sēklas, ko importēt?"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Domain Name"),
        "donateButton": MessageLookupByLibrary.simpleMessage("Ziedot"),
        "donateToSupport":
            MessageLookupByLibrary.simpleMessage("Atbalstiet projektu"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "enableNotifications":
            MessageLookupByLibrary.simpleMessage("Iespējot paziņojumus"),
        "enableTracking":
            MessageLookupByLibrary.simpleMessage("Iespējot izsekošanu"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Failed to set a wallet password"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("Ievadiet adresi"),
        "enterAmount":
            MessageLookupByLibrary.simpleMessage("Ievadiet daudzumu"),
        "enterEmail": MessageLookupByLibrary.simpleMessage("Ievadiet e-pastu"),
        "enterGiftMemo":
            MessageLookupByLibrary.simpleMessage("Enter Gift Note"),
        "enterHeight":
            MessageLookupByLibrary.simpleMessage("Ievadiet augstumu"),
        "enterHttpUrl":
            MessageLookupByLibrary.simpleMessage("Ievadiet HTTP URL"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("Enter Message"),
        "enterMoneroAddress":
            MessageLookupByLibrary.simpleMessage("Ievadiet XMR adresi"),
        "enterName": MessageLookupByLibrary.simpleMessage("Ievadiet Vārdu"),
        "enterNodeName":
            MessageLookupByLibrary.simpleMessage("Ievadiet mezgla nosaukumu"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Enter your password"),
        "enterSplitAmount":
            MessageLookupByLibrary.simpleMessage("Ievadiet sadalīto summu"),
        "enterUserOrAddress":
            MessageLookupByLibrary.simpleMessage("Enter User or Address"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Enter a username"),
        "enterWsUrl":
            MessageLookupByLibrary.simpleMessage("Ievadiet WebSocket URL"),
        "errorProcessingGiftCard": MessageLookupByLibrary.simpleMessage(
            "Apstrādājot šo dāvanu karti, radās kļūda. Tā var nebūt derīga, beidzies derīguma termiņš vai tā ir tukša."),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("no kāda"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Sveicināti Nautilus. Tiklīdz saņemsiet NANO, transakcijas būs redzamas šādi:"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Nedaudz"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Daudz"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("kādam"),
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
        "exchangeCurrency": MessageLookupByLibrary.simpleMessage("Apmaiņa %2"),
        "exchangeNano":
            MessageLookupByLibrary.simpleMessage("Apmainīties ar NANO"),
        "existingPasswordHint":
            MessageLookupByLibrary.simpleMessage("Ievadiet pašreizējo paroli"),
        "existingPinHint":
            MessageLookupByLibrary.simpleMessage("Ievadiet pašreizējo PIN"),
        "exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "exportTXData":
            MessageLookupByLibrary.simpleMessage("Eksporta darījumi"),
        "failed": MessageLookupByLibrary.simpleMessage("failed"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader":
            MessageLookupByLibrary.simpleMessage("Nautilus Disconnected"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "Nautilus Servers appear to be disconnected, Sending and Receiving (without memos) should still be operational but payment requests may not go through\n\n Come back later or restart the app to try again"),
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
        "fewDaysAgo":
            MessageLookupByLibrary.simpleMessage("Pirms dažām dienām"),
        "fewHoursAgo":
            MessageLookupByLibrary.simpleMessage("Pirms dažām stundām"),
        "fewMinutesAgo":
            MessageLookupByLibrary.simpleMessage("Pirms dažām minūtēm"),
        "fewSecondsAgo":
            MessageLookupByLibrary.simpleMessage("Pirms dažām sekundēm"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Autorizējieties, lai kopētu sēklu."),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("fulfilled"),
        "fundingBannerHeader":
            MessageLookupByLibrary.simpleMessage("Finansēšanas reklāmkarogs"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("Finansējums"),
        "getCurrency": MessageLookupByLibrary.simpleMessage("Iegūstiet %2"),
        "getNano": MessageLookupByLibrary.simpleMessage("Iegūstiet NANO"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("You have a gift!"),
        "giftAlertEmpty": MessageLookupByLibrary.simpleMessage("Empty Gift"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("Gift Amount"),
        "giftCardCreationError": MessageLookupByLibrary.simpleMessage(
            "Mēģinot izveidot dāvanu kartes saiti, radās kļūda"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "Mēģinot izveidot dāvanu karti, radās kļūda, DĀVANU KARTES SAITE VAI SĒKLA IR KOPĒTA JŪSU STARPKLĀTĒ, TAJĀ VAR BŪT JŪSU LĪDZEKĻI ATKARĪBĀ NO KAS NOTIEK NELABI."),
        "giftCardInfoHeader":
            MessageLookupByLibrary.simpleMessage("Informācija par dāvanu lapu"),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Gift From"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Load a Digital Gift Card with NANO! Set an amount, and an optional message for the recipient to see when they open it!\n\nOnce created, you\'ll get a link that you can send to anyone, which when opened will automatically distribute the funds to the recipient after installing Nautilus!\n\nIf the recipient is already a Nautilus user they will get a prompt to transfer the funds into their account upon opening the link"),
        "giftMessage": MessageLookupByLibrary.simpleMessage("Gift Message"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "Apstrādājot šo dāvanu karti, radās kļūda. Varbūt pārbaudiet savienojumu un mēģiniet vēlreiz noklikšķināt uz dāvanas saites."),
        "giftProcessSuccess": MessageLookupByLibrary.simpleMessage(
            "Dāvana ir veiksmīgi saņemta, var paiet kāds brīdis, līdz tā parādīsies jūsu makā."),
        "giftRefundSuccess":
            MessageLookupByLibrary.simpleMessage("Dāvana veiksmīgi atmaksāta!"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Go Back"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Go to QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Sapratu!"),
        "handoff": MessageLookupByLibrary.simpleMessage("nodošana"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage(
            "Mēģinot nodot bloku, radās problēma."),
        "handoffSupportedMethodNotFound": MessageLookupByLibrary.simpleMessage(
            "Nevarēja atrast atbalstītu nodošanas metodi!"),
        "haveSeedToImport":
            MessageLookupByLibrary.simpleMessage("Man ir sēkla"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Paslēpt kontu?"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Vai tiešām vēlaties paslēpt tukšos kontus?\n\nTādējādi tiks paslēpti visi konti, kuru atlikums ir tieši 0 (izņemot tikai pulksteņu adreses un jūsu galveno kontu), taču jūs vienmēr varat tos atkārtoti pievienot vēlāk, pieskaroties pogai \"Pievienot kontu\"."),
        "hideAccountsHeader":
            MessageLookupByLibrary.simpleMessage("Vai slēpt kontus?"),
        "hideEmptyAccounts":
            MessageLookupByLibrary.simpleMessage("Paslēpt tukšos kontus"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "homeButton": MessageLookupByLibrary.simpleMessage("Mājas"),
        "hourAgo": MessageLookupByLibrary.simpleMessage("Pirms stundas"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("I Understand the Risks"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignore"),
        "imSure": MessageLookupByLibrary.simpleMessage("Esmu pārliecināts"),
        "import": MessageLookupByLibrary.simpleMessage("Importēt"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "The link you clicked contains some nano, would you like to import it to this wallet, or refund it to whoever sent it?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "Šķiet, ka noklikšķinājāt uz saites, kurā ir ietverts NANO. Lai saņemtu šos līdzekļus, mums tikai jāpabeidz sava maka iestatīšana."),
        "importGiftv2": MessageLookupByLibrary.simpleMessage(
            "Saite, uz kuras noklikšķinājāt, satur kādu NANO. Vai vēlaties to importēt šajā makā?"),
        "importHD": MessageLookupByLibrary.simpleMessage("Importēt HD"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Importēt slepeno frāzi"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Lūdzu ievadiet jūsu 24 vārdu slepeno frāzi. Katram vārdam jābūt atdalītam ar atstarpi."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Importēt sēklu"),
        "importSeedHint":
            MessageLookupByLibrary.simpleMessage("Zemāk norādiet sēklu."),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Importēt privāto atslēgu"),
        "importStandard":
            MessageLookupByLibrary.simpleMessage("Importa standarts"),
        "importWallet": MessageLookupByLibrary.simpleMessage("Importēt maku"),
        "instantly": MessageLookupByLibrary.simpleMessage("Uzreiz"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Nepietiek līdzekļu"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "Mēs izlaidām ievada procesu, lai ietaupītu jūsu laiku, taču jums nekavējoties jādublē jaunizveidotā sēkla.\n\nJa pazaudēsit savu sēklu, jūs zaudēsit piekļuvi saviem līdzekļiem.\n\nTurklāt jūsu piekļuves kods ir iestatīts uz \"000000\", kas jums arī nekavējoties jāmaina."),
        "introSkippedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Dublējiet savu sēklu!"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Ievadītā adrese nav derīga"),
        "invalidHeight":
            MessageLookupByLibrary.simpleMessage("Nederīgs augstums"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Invalid Password"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("Nederīga Pin"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "iOS App Store vadlīniju un ierobežojumu dēļ mēs nevaram saistīt jūs ar mūsu ziedojumu lapu. Ja vēlaties atbalstīt projektu, apsveriet iespēju nosūtīt uz nautilus mezgla adresi."),
        "language": MessageLookupByLibrary.simpleMessage("Valoda"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("Link Copied"),
        "loaded": MessageLookupByLibrary.simpleMessage("Loaded"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Loaded Into"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Autentificēties palaižot"),
        "locked": MessageLookupByLibrary.simpleMessage("Aizslēgts"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Pieslēgties"),
        "loginOrRegisterHeader": MessageLookupByLibrary.simpleMessage(
            "Pieteikties vai Reģistrēties"),
        "logout": MessageLookupByLibrary.simpleMessage("Iziet"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Dzēst sēklu un iziet"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Vai esat drošs?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Izejot tiks aizmirsta jūsu sēkla un visi Nautilus saistītie dati šajā ierīcē. Ja neesat izveidojis maka sēklas rezerves kopiju, maks un tā līdzekļi tiks neatgriezeniski zaudēti"),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Ja vien esat saglabājis maka sēklu, jums ne par ko nav jāuztraucas."),
        "looksLikeHdSeed": MessageLookupByLibrary.simpleMessage(
            "Šķiet, ka tas ir HD sēkla, ja vien neesat pārliecināts, ka zināt, ko darāt, tā vietā izmantojiet opciju \"Importēt HD\"."),
        "looksLikeStandardSeed": MessageLookupByLibrary.simpleMessage(
            "Šķiet, ka šī ir standarta sēkla, tā vietā izmantojiet opciju \"Importēt standartu\"."),
        "manage": MessageLookupByLibrary.simpleMessage("Pārvaldīt"),
        "mantaError":
            MessageLookupByLibrary.simpleMessage("Couldn\'t Verify Request"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("Manuālā ievade"),
        "markAsPaid": MessageLookupByLibrary.simpleMessage("Mark as Paid"),
        "markAsUnpaid": MessageLookupByLibrary.simpleMessage("Mark as Unpaid"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Memo re-sent! If still unacknowledged, the recipient\'s device may be offline."),
        "messageCopied": MessageLookupByLibrary.simpleMessage("Ziņa nokopēta"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Message"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "Minimum send amount is %1 %2"),
        "minuteAgo": MessageLookupByLibrary.simpleMessage("Pirms minūtes"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 nav derīgs vārds"),
        "mnemonicPhrase":
            MessageLookupByLibrary.simpleMessage("Mnemoniskā frāze"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Slepenā frāze var saturēt tikai 24 vārdus"),
        "monthlyServerCosts":
            MessageLookupByLibrary.simpleMessage("Ikmēneša servera izmaksas"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings":
            MessageLookupByLibrary.simpleMessage("Vairāk iestatījumu"),
        "nameEmpty":
            MessageLookupByLibrary.simpleMessage("Lūdzu, ievadiet Vārdu"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "nautilusWallet": MessageLookupByLibrary.simpleMessage("Nautilus maks"),
        "nearby": MessageLookupByLibrary.simpleMessage("Tuvumā"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "This feature requires you to have a longer transaction history in order to prevent spam.\n\nAlternatively, you can show a QR code for someone to scan."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Verification Needed"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Šis ir jūsu jaunais konts. Tiklīdz saņemsiet NANO, transakcijas būs redzamas šādi:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Jauns maks"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Next"),
        "no": MessageLookupByLibrary.simpleMessage("Nē"),
        "noContactsExport":
            MessageLookupByLibrary.simpleMessage("Nav kontaktu ko eksportēt."),
        "noContactsImport": MessageLookupByLibrary.simpleMessage(
            "Nav jauni kontakti, ko importēt."),
        "noSearchResults":
            MessageLookupByLibrary.simpleMessage("No Search Results!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("No, Skip"),
        "noTXDataExport":
            MessageLookupByLibrary.simpleMessage("Nav eksportējamu darījumu."),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "node": MessageLookupByLibrary.simpleMessage("Mezgls"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("Node Status"),
        "nodes": MessageLookupByLibrary.simpleMessage("Mezgli"),
        "noneMethod": MessageLookupByLibrary.simpleMessage("Nav"),
        "notSent": MessageLookupByLibrary.simpleMessage("not sent"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Atveriet Nautilus, lai apskatītu šo transakciju"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Pieskaries, lai atvērtu"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "In order for this feature to work correctly, notifications must be enabled"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Saņemts %1 NANO"),
        "notificationWarning":
            MessageLookupByLibrary.simpleMessage("Paziņojumi ir atspējoti"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Maksājumu pieprasījumiem, piezīmēm un ziņojumiem ir jāiespējo paziņojumi, lai tie darbotos pareizi, jo tie izmanto FCM paziņojumu pakalpojumu, lai nodrošinātu ziņojumu piegādi.\n\nVarat iespējot paziņojumus, izmantojot tālāk esošo pogu, vai noraidīt šo kartīti, ja nevēlaties izmantot šīs funkcijas."),
        "notificationWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Maksājumu pieprasījumi, piezīmes un ziņojumi nedarbosies pareizi."),
        "notifications": MessageLookupByLibrary.simpleMessage("Paziņojumi"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Nyanicon"),
        "obscureInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Neskaidra informācija par darījumu"),
        "obscureTransaction":
            MessageLookupByLibrary.simpleMessage("Neskaidrs darījums"),
        "obscureTransactionBody": MessageLookupByLibrary.simpleMessage(
            "Tas NAV īsts privātums, taču saņēmējam būs grūtāk redzēt, kas viņam ir nosūtījis līdzekļus."),
        "off": MessageLookupByLibrary.simpleMessage("Izslēgts"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "onStr": MessageLookupByLibrary.simpleMessage("Ieslēgts"),
        "onboard": MessageLookupByLibrary.simpleMessage("Uzaiciniet kādu"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Uzņemšana"),
        "onramp": MessageLookupByLibrary.simpleMessage("Onramp"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Opened"),
        "paid": MessageLookupByLibrary.simpleMessage("paid"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("Papīra maks"),
        "passwordBlank":
            MessageLookupByLibrary.simpleMessage("Password cannot be empty"),
        "passwordCapitalLetter": MessageLookupByLibrary.simpleMessage(
            "Parolē jāsatur vismaz 1 lielais un mazais burts"),
        "passwordDisclaimer": MessageLookupByLibrary.simpleMessage(
            "Mēs neesam atbildīgi, ja aizmirstat savu paroli, un mēs nevaram to atiestatīt vai mainīt jūsu vietā."),
        "passwordIncorrect":
            MessageLookupByLibrary.simpleMessage("nepareiza parole"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "You will not need a password to open Nautilus anymore."),
        "passwordNumber": MessageLookupByLibrary.simpleMessage(
            "Parolē ir jābūt vismaz 1 ciparam"),
        "passwordSpecialCharacter": MessageLookupByLibrary.simpleMessage(
            "Parolē jāsatur vismaz 1 speciālā rakstzīme"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Parole ir pārāk īsa"),
        "passwordWarning": MessageLookupByLibrary.simpleMessage(
            "Šī parole būs nepieciešama, lai atvērtu Nautilus."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "This password will be required to open Nautilus."),
        "passwordsDontMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "pay": MessageLookupByLibrary.simpleMessage("Pay"),
        "payRequest": MessageLookupByLibrary.simpleMessage("Pay this request"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Someone has requested payment from you! check the payments page for more info."),
        "payments": MessageLookupByLibrary.simpleMessage("Payments"),
        "pickFromList":
            MessageLookupByLibrary.simpleMessage("Pick From a List"),
        "pinBlank": MessageLookupByLibrary.simpleMessage("Pin nevar būt tukšs"),
        "pinConfirmError": MessageLookupByLibrary.simpleMessage("PIN nesakrīt"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Apstipriniet savu PIN"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Izveidojiet sešu ciparu PIN"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("Ievadiet PIN"),
        "pinIncorrect": MessageLookupByLibrary.simpleMessage(
            "Ievadīta nepareiza spraudīte"),
        "pinInvalid": MessageLookupByLibrary.simpleMessage("Nepareizs PIN"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "Ievadiet PIN, lai nomainītu pārstāvi."),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Ievadiet PIN, lai kopētu sēklu"),
        "pinsDontMatch":
            MessageLookupByLibrary.simpleMessage("Piespraudes nesakrīt"),
        "plausibleDeniabilityParagraph": MessageLookupByLibrary.simpleMessage(
            "Šī NAV tā pati spraudīte, kuru izmantojāt, lai izveidotu maku. Lai iegūtu papildinformāciju, nospiediet informācijas pogu."),
        "plausibleInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Informācija par ticamu noliegumu"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Iestatiet sekundāro tapu ticamam noraidīšanas režīmam.\n\nJa jūsu maks tiek atbloķēts, izmantojot šo sekundāro tapu, jūsu sēkla tiks aizstāta ar esošās sēklas jaucējkrānu. Šis ir drošības līdzeklis, kas paredzēts lietošanai, ja esat spiests atvērt maku.\n\nŠī spraudīte darbosies kā parasta (pareiza) piespraude, IZŅEMOT, kad atbloķēsiet maku, kad aktivizēsies ticamā atteikuma režīms.\n\nJūsu līdzekļi TIKS ZAUDĒTI, ieejot ticamā noraidīšanas režīmā, ja neesat veicis sākotnējo dublējumu!"),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Privātuma politika"),
        "proSubRequiredHeader": MessageLookupByLibrary.simpleMessage(
            "Nepieciešams Nautilus Pro abonements"),
        "proSubRequiredParagraph": MessageLookupByLibrary.simpleMessage(
            "Tikai par 1 NANO mēnesī varat atbloķēt visas Nautilus Pro funkcijas."),
        "promotionalLink":
            MessageLookupByLibrary.simpleMessage("Bezmaksas NANO"),
        "purchaseCurrency": MessageLookupByLibrary.simpleMessage("Pirkums %2"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Purchase Nano"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR code does not contain a valid destination"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Please Grant Camera Permissions to scan QR Codes"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "QR kods nesatur derīgu sēklu vai privāto atslēgu"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "QR kods nesatur derīgu slepeno frāzi"),
        "qrUnknownError":
            MessageLookupByLibrary.simpleMessage("Could not Read QR Code"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp": MessageLookupByLibrary.simpleMessage("Rate the App"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn\'t take more than a minute."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Plikā sēkla"),
        "readMore": MessageLookupByLibrary.simpleMessage("Read More"),
        "receivable": MessageLookupByLibrary.simpleMessage("receivable"),
        "receive": MessageLookupByLibrary.simpleMessage("Saņemt"),
        "receiveMinimum":
            MessageLookupByLibrary.simpleMessage("Receive Minimum"),
        "receiveMinimumHeader":
            MessageLookupByLibrary.simpleMessage("Receive Minimum Info"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "A minimum amount to receive. If a payment or request is received with an amount less than this, it will be ignored."),
        "received": MessageLookupByLibrary.simpleMessage("Saņemtie"),
        "refund": MessageLookupByLibrary.simpleMessage("Refund"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Reģistrēties"),
        "registerFor": MessageLookupByLibrary.simpleMessage("for"),
        "registerUsername":
            MessageLookupByLibrary.simpleMessage("Register Username"),
        "registerUsernameHeader":
            MessageLookupByLibrary.simpleMessage("Register a Username"),
        "registering": MessageLookupByLibrary.simpleMessage("Registering"),
        "remove": MessageLookupByLibrary.simpleMessage("Noņemt"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Tiešām paslēpt šo kontu? Vēlāk varēsiet to pievienot atkal, pieskaroties \"%1\" pogai."),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("Unblock"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to unblock %1?"),
        "removeContact": MessageLookupByLibrary.simpleMessage("Dzēst kontaktu"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Vai esat drošs, ka vēlaties dzēst kontaktu %1?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Remove Favorite"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "Pārstāvis ir konts, kas balso tīmekļa vienprātībai. Balss svaru nosaka kopējā līdzekļu bilance. Jūs varat deleģēt savu bilanci kādam uzticamam pārstāvim, lai palielinātu tā balss svaru. Jūsu pārstāvis nav spējīgs tērēt jūsu līdzekļus. Ieteicams izvēlēties pārstāvi, kas ir uzticams un ir ar zemu zaudlaiku jeb dīkstāvi."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("Kas ir pārstāvis?"),
        "reply": MessageLookupByLibrary.simpleMessage("Reply"),
        "representatives":
            MessageLookupByLibrary.simpleMessage("Representatives"),
        "request": MessageLookupByLibrary.simpleMessage("Request"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Request %1 %2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Request Failed: This user doesn\'t appear to have Nautilus installed, or has notifications disabled."),
        "requestFrom": MessageLookupByLibrary.simpleMessage("Pieprasījums no"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Request Payment"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Error sending payment request, the recipient\'s device may be offline or unavailable."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Request re-sent! If still unacknowledged, the recipient\'s device may be offline."),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Pieprasiet maksājumu ar šifrētiem ziņojumiem no gala līdz beigām!\n\nMaksājumu pieprasījumus, piezīmes un ziņojumus varēs saņemt tikai citi nautilus lietotāji, taču jūs varat tos izmantot savai uzskaitei pat tad, ja saņēmējs neizmanto Nautilus."),
        "requestSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Pieprasīt lapas informāciju"),
        "requested": MessageLookupByLibrary.simpleMessage("Requested"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Requested From"),
        "requesting": MessageLookupByLibrary.simpleMessage("Requesting"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Require a password to open Nautilus?"),
        "requireCaptcha": MessageLookupByLibrary.simpleMessage(
            "Lai pieprasītu dāvanu karti, ir nepieciešams CAPTCHA"),
        "resendMemo": MessageLookupByLibrary.simpleMessage("Resend this memo"),
        "resetAccountButton":
            MessageLookupByLibrary.simpleMessage("Atiestatīt kontu"),
        "resetAccountParagraph": MessageLookupByLibrary.simpleMessage(
            "Tādējādi tiks izveidots jauns konts ar tikko iestatīto paroli. Vecais konts netiks dzēsts, ja vien izvēlētās paroles nebūs vienādas."),
        "resetDatabase":
            MessageLookupByLibrary.simpleMessage("Reset the Database"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to reset the internal database? \n\nThis may fix issues related to updating the app, but will also delete all saved preferences. This will NOT delete your wallet seed. If you\'re having issues you should backup your seed, re-install the app, and if the issue persists feel free to make a bug report on github or discord."),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "It appears your device is \"rooted\", \"jailbroken\", or modified in a way that compromises security. It is recommended that you reset your device to its original state before proceeding."),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Noskenējiet Nano \nadreses QR kodu"),
        "scanNFC":
            MessageLookupByLibrary.simpleMessage("Sūtīt, izmantojot NFC"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Skenēt QR kodu"),
        "schedule": MessageLookupByLibrary.simpleMessage("Grafiks"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Search for anything"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "Nākamajā sadaļā redzēsiet jūsu slepeno frāzi. Tā ir parole ar kuru varat piekļūt jūsu līdzekļiem. Ir ārkārtīgi svarīgi izveidot rezerves kopiju un turēt to noslēpumā."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Drošība pirmajā vietā!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Slepenā frāze"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Slepenā frāze nokopēta"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Kopēt slepeno frāzi"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Gadījumā, ja nozaudējat telefonu, vai atinstalējat šo aplikāciju, jums būs nepieciešama slepenā frāze, vai privātā atslēga, lai piekļūtu jūsu līdzekļiem!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Drošība"),
        "seed": MessageLookupByLibrary.simpleMessage("Sēkla"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Zemāk atrodas jūsu maka sēkla. Ārkārtīgi svarīgi sēklai izveidot rezerves kopiju, kā arī to neglabāt vienkārša teksta formātā vai kā ekrānšāviņu."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Sēkla nokopēta starpliktuvē\nTo iespējams ielīmēt 2 minūšu laikā."),
        "seedCopiedShort":
            MessageLookupByLibrary.simpleMessage("Sēkla nokopēta"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Privātā atslēga satur to pašu informāciju, ko slepenā frāze, tikai mašīnām saprotamā formā. Ja vismaz vienu no tām saglabājāt kā rezerves kopiju, jums būs piekļuve jūsu līdzekļiem."),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("Sēkla nav derīga"),
        "selfSendError":
            MessageLookupByLibrary.simpleMessage("Can\'t request from self"),
        "send": MessageLookupByLibrary.simpleMessage("Sūtīt"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Sūtīt %1 NANO"),
        "sendAmounts": MessageLookupByLibrary.simpleMessage("Sūtīt summas"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "Notika kļūda. Pēc laika mēģiniet atkal."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Sūtīt no"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Sending memo with transaction failed, they may not be a Nautilus user."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Sending message"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Send Request again"),
        "sendRequests":
            MessageLookupByLibrary.simpleMessage("Sūtīt pieprasījumus"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Send or Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other nautilus users.\n\nYou don\'t need to have a username in order to send or receive payment requests, and you can use them for your own record keeping even if they don\'t use nautilus."),
        "sendSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Send Sheet Info"),
        "sending": MessageLookupByLibrary.simpleMessage("Sūta"),
        "sent": MessageLookupByLibrary.simpleMessage("Nosūtītie"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Nosūtīts"),
        "set": MessageLookupByLibrary.simpleMessage("Iestatīt"),
        "setPassword": MessageLookupByLibrary.simpleMessage("Set Password"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Password has been set successfully"),
        "setPin": MessageLookupByLibrary.simpleMessage("Iestatīt Pin"),
        "setPinParagraph": MessageLookupByLibrary.simpleMessage(
            "Iestatiet vai mainiet savu esošo PIN. Ja vēl neesat iestatījis PIN, noklusējuma PIN ir 000000."),
        "setPinSuccess":
            MessageLookupByLibrary.simpleMessage("Pin ir veiksmīgi iestatīts"),
        "setPlausibleDeniabilityPin":
            MessageLookupByLibrary.simpleMessage("Iestatiet ticamu tapu"),
        "setRestoreHeight": MessageLookupByLibrary.simpleMessage(
            "Iestatiet atjaunošanas augstumu"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Set Wallet Password"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "setXMRRestoreHeight": MessageLookupByLibrary.simpleMessage(
            "Iestatiet XMR atjaunošanas augstumu"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Iestatījumi"),
        "settingsTransfer":
            MessageLookupByLibrary.simpleMessage("Ielādēt no papīra maka"),
        "share": MessageLookupByLibrary.simpleMessage("Dalīties"),
        "shareApp": MessageLookupByLibrary.simpleMessage("Kopīgot %1"),
        "shareAppText": MessageLookupByLibrary.simpleMessage(
            "Pārbaudiet %1! Labākais NANO mobilais maks!"),
        "shareLink": MessageLookupByLibrary.simpleMessage("Share Link"),
        "shareMessage": MessageLookupByLibrary.simpleMessage("Kopīgot ziņu"),
        "shareNautilus":
            MessageLookupByLibrary.simpleMessage("Dalīties ar Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Uzmet aci Nautilus! Izcils NANO viedais maks!"),
        "shareText": MessageLookupByLibrary.simpleMessage("Kopīgot tekstu"),
        "shopButton": MessageLookupByLibrary.simpleMessage("Veikals"),
        "show": MessageLookupByLibrary.simpleMessage("Rādīt"),
        "showAccountInfo":
            MessageLookupByLibrary.simpleMessage("Konta informācija"),
        "showAccountQR":
            MessageLookupByLibrary.simpleMessage("Rādīt konta QR kodu"),
        "showContacts": MessageLookupByLibrary.simpleMessage("Show Contacts"),
        "showFunding": MessageLookupByLibrary.simpleMessage(
            "Rādīt finansējuma reklāmkarogu"),
        "showLinkOptions":
            MessageLookupByLibrary.simpleMessage("Rādīt saites opcijas"),
        "showLinkQR": MessageLookupByLibrary.simpleMessage("Rādīt saites QR"),
        "showMoneroHeader":
            MessageLookupByLibrary.simpleMessage("Parādiet Monero"),
        "showMoneroInfo":
            MessageLookupByLibrary.simpleMessage("Iespējot Monero sadaļu"),
        "showQR": MessageLookupByLibrary.simpleMessage("Rādīt QR kodu"),
        "showUnopenedWarning":
            MessageLookupByLibrary.simpleMessage("Neatvērts brīdinājums"),
        "simplex": MessageLookupByLibrary.simpleMessage("Simplex"),
        "social": MessageLookupByLibrary.simpleMessage("Sociālie"),
        "someone": MessageLookupByLibrary.simpleMessage("kāds"),
        "spendCurrency": MessageLookupByLibrary.simpleMessage("Iztērē %2"),
        "spendNano": MessageLookupByLibrary.simpleMessage("Tērē NANO"),
        "splitBill": MessageLookupByLibrary.simpleMessage("Sadalīts Bils"),
        "splitBillHeader":
            MessageLookupByLibrary.simpleMessage("Sadaliet rēķinu"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "Nosūtiet uzreiz vairākus maksājuma pieprasījumus! Atvieglo, piemēram, rēķina sadalīšanu restorānā."),
        "splitBillInfoHeader":
            MessageLookupByLibrary.simpleMessage("Dalīta rēķina informācija"),
        "splitBy": MessageLookupByLibrary.simpleMessage("Sadalīt pēc"),
        "subsButton": MessageLookupByLibrary.simpleMessage("Abonementi"),
        "subscribeButton": MessageLookupByLibrary.simpleMessage("Abonēt"),
        "subscribeWithApple": MessageLookupByLibrary.simpleMessage(
            "Abonējiet, izmantojot Apple Pay"),
        "subscribed": MessageLookupByLibrary.simpleMessage("Abonēts"),
        "subscribing": MessageLookupByLibrary.simpleMessage("Abonēšana"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment": MessageLookupByLibrary.simpleMessage(
            "Palīdzība Atbalsts attīstībai"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Support the Developer"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("Nomainiet XMR"),
        "swapXMRHeader":
            MessageLookupByLibrary.simpleMessage("Apmainīt Monero"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "Monero ir uz privātumu vērsta kriptovalūta, kas padara darījumu izsekošanu ļoti sarežģītu vai pat neiespējamu. Tikmēr NANO ir uz maksājumiem orientēta kriptovalūta, kas ir ātra un bez maksas. Kopā tie nodrošina dažus no visnoderīgākajiem kriptovalūtu aspektiem!\n\nIzmantojiet šo lapu, lai viegli nomainītu savu NANO pret XMR!"),
        "swapping": MessageLookupByLibrary.simpleMessage("Maiņa"),
        "switchToSeed": MessageLookupByLibrary.simpleMessage(
            "Pārslēgties uz privāto atslēgu"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("Noklusētie iestatījumi"),
        "tapMessageToEdit": MessageLookupByLibrary.simpleMessage(
            "Pieskarieties ziņojumam, lai rediģētu"),
        "tapToHide":
            MessageLookupByLibrary.simpleMessage("Pieskaries, lai paslēptu"),
        "tapToReveal":
            MessageLookupByLibrary.simpleMessage("Pieskaries, lai parādītu"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Motīvs"),
        "thisMayTakeSomeTime": MessageLookupByLibrary.simpleMessage(
            "tas var aizņemt kādu laiku..."),
        "to": MessageLookupByLibrary.simpleMessage("Adresāts"),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "Pārāk daudz atslēgšanas mēģinājumi."),
        "trackingHeader":
            MessageLookupByLibrary.simpleMessage("Izsekošanas autorizācija"),
        "trackingWarning":
            MessageLookupByLibrary.simpleMessage("Izsekošana ir atspējota"),
        "trackingWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Ja izsekošana ir atspējota, dāvanu kartes funkcionalitāte var tikt samazināta vai nedarboties vispār. Mēs izmantojam šo atļauju TIKAI šai funkcijai. Pilnīgi neviens no jūsu datiem netiek pārdots, vākts vai izsekots aizmugursistēmā jebkādiem nolūkiem, kas nav nepieciešami"),
        "trackingWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Dāvanu karšu saites nedarbosies pareizi"),
        "transactions": MessageLookupByLibrary.simpleMessage("Darījumi"),
        "transfer": MessageLookupByLibrary.simpleMessage("Pārsūtīt"),
        "transferClose": MessageLookupByLibrary.simpleMessage(
            "Pieskarieties jebkur, lai aizvērtu."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO sekmīgi pārskaitīti uz jūsu Nautilus maku.\n"),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "Maks ar %1 NANO bilanci ir atrasts.\n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "Pieskarieties, lai apstiprinātu līdzekļu pārskaitīšanu.\n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "Pārskaitīšana var prasīt vairākas sekundes."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "Pārsūtīšanas laikā notika kļūda. Lūdzu vēlāk mēģiniet vēlreiz."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Pārsūtīt līdzekļus"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "Šis process pārskaitīs jūsu papīra maka līdzekļus uz jūsu Nautilus maku.\n\nPieskaries \"%1\" pogai, lai sāktu."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "This process will transfer the funds from a paper wallet to your Nautilus wallet."),
        "transferLoading": MessageLookupByLibrary.simpleMessage("Pārsūta"),
        "transferManualHint":
            MessageLookupByLibrary.simpleMessage("Lūdzu, zemāk ievadiet sēklu"),
        "transferNoFunds": MessageLookupByLibrary.simpleMessage(
            "Šai sēklai nav piesaistīti līdzekļi"),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "Šis QR kods nesatur derīgu sēklu"),
        "transferQrScanHint": MessageLookupByLibrary.simpleMessage(
            "Skenē Nano \nsēklu vai privāto atslēgu"),
        "unacknowledged":
            MessageLookupByLibrary.simpleMessage("unacknowledged"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("unconfirmed"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("unfulfilled"),
        "unlock": MessageLookupByLibrary.simpleMessage("Atslēgt"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Autorizējieties, lai piekļūtu Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Ievadiet PIN, lai piekļūtu Nautilus"),
        "unopenedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Rādīt neatvērto brīdinājumu"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "Parādiet brīdinājumu, sūtot līdzekļus uz neatvērtu kontu. Tas ir noderīgi, jo lielāko daļu laika adresēm, uz kurām sūtāt, būs atlikums, un sūtīšana uz jaunu adresi var būt drukas kļūdas rezultāts."),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "Vai esat pārliecināts, ka šī ir īstā adrese?\nŠķiet, ka šis konts nav atvērts\n\nŠo brīdinājumu varat atspējot iestatījumu atvilktnes sadaļā \"Neatvērts brīdinājums\"."),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("Konts neatvērts"),
        "unpaid": MessageLookupByLibrary.simpleMessage("unpaid"),
        "unread": MessageLookupByLibrary.simpleMessage("unread"),
        "uptime": MessageLookupByLibrary.simpleMessage("Uptime"),
        "urlEmpty": MessageLookupByLibrary.simpleMessage("Lūdzu, ievadiet URL"),
        "useAppRep": MessageLookupByLibrary.simpleMessage("Izmantojiet %1 Rep"),
        "useCurrency": MessageLookupByLibrary.simpleMessage("Izmantojiet %2"),
        "useNano": MessageLookupByLibrary.simpleMessage("Izmantojiet NANO"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userAlreadyAddedError": MessageLookupByLibrary.simpleMessage(
            "Lietotājs jau ir pievienots!"),
        "userNotFound": MessageLookupByLibrary.simpleMessage("User not found!"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "usernameAvailable":
            MessageLookupByLibrary.simpleMessage("Username available!"),
        "usernameEmpty":
            MessageLookupByLibrary.simpleMessage("Please Enter a Username"),
        "usernameError": MessageLookupByLibrary.simpleMessage("Username Error"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "Pick out a unique @username to make it easy for friends and family to find you!\n\nHaving a Nautilus username updates the UI globally to reflect your new handle."),
        "usernameInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Username"),
        "usernameUnavailable":
            MessageLookupByLibrary.simpleMessage("Username unavailable"),
        "usernameWarning": MessageLookupByLibrary.simpleMessage(
            "Nautilus usernames are a centralized service provided by Nano.to"),
        "using": MessageLookupByLibrary.simpleMessage("Izmantojot"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("Apskatīt detaļas"),
        "viewPaymentHistory":
            MessageLookupByLibrary.simpleMessage("Skatīt maksājumu vēsturi"),
        "viewTX": MessageLookupByLibrary.simpleMessage("Skatīt darījumu"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("Voting Weight"),
        "warning": MessageLookupByLibrary.simpleMessage("Brīdinājums"),
        "watchAccountExists":
            MessageLookupByLibrary.simpleMessage("Konts jau ir pievienots!"),
        "watchOnlyAccount":
            MessageLookupByLibrary.simpleMessage("Tikai skatīšanās konts"),
        "watchOnlySendDisabled": MessageLookupByLibrary.simpleMessage(
            "Sūtīšana ir atspējota tikai pulksteņa adresēm"),
        "weekAgo": MessageLookupByLibrary.simpleMessage("Pirms nedēļas"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Sveicināti Nautilus. Izveidojiet jaunu maku vai importējiet eksistējošu"),
        "welcomeTextLogin": MessageLookupByLibrary.simpleMessage(
            "Laipni lūdzam Nautilus. Izvēlieties opciju, lai sāktu darbu, vai izvēlieties motīvu, izmantojot tālāk esošo ikonu."),
        "welcomeTextUpdated": MessageLookupByLibrary.simpleMessage(
            "Laipni lūdzam Nautilus. Lai sāktu, izveidojiet jaunu maku vai importējiet esošu."),
        "welcomeTextWithoutLogin": MessageLookupByLibrary.simpleMessage(
            "Lai sāktu, izveidojiet jaunu maku vai importējiet esošu."),
        "withAddress": MessageLookupByLibrary.simpleMessage("With Address"),
        "withFee": MessageLookupByLibrary.simpleMessage("Ar maksu"),
        "withMessage": MessageLookupByLibrary.simpleMessage("With Message"),
        "xMinute": MessageLookupByLibrary.simpleMessage("Pēc %1 minūtes"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("Pēc %1 minūtēm"),
        "xmrStatusConnecting":
            MessageLookupByLibrary.simpleMessage("Savienojuma izveide"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("Kļūda"),
        "xmrStatusLoading":
            MessageLookupByLibrary.simpleMessage("Notiek ielāde"),
        "xmrStatusSynchronized":
            MessageLookupByLibrary.simpleMessage("Sinhronizēts"),
        "xmrStatusSynchronizing":
            MessageLookupByLibrary.simpleMessage("Sinhronizācija"),
        "yes": MessageLookupByLibrary.simpleMessage("Jā"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
