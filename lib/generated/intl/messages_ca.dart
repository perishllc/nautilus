// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ca locale. All the
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
  String get localeName => 'ca';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Compte"),
        "accounts": MessageLookupByLibrary.simpleMessage("Comptes"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "N\'estàs segur que has fet una còpia de seguretat de la teva frase secreta o llavor?"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Missatge actiu"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Afegir compte"),
        "addBlocked": MessageLookupByLibrary.simpleMessage("Block a User"),
        "addContact": MessageLookupByLibrary.simpleMessage("Afegir contacte"),
        "addFavorite": MessageLookupByLibrary.simpleMessage("Add Favorite"),
        "addressCopied": MessageLookupByLibrary.simpleMessage("Adreça copiada"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Introduir adreça"),
        "addressMissing": MessageLookupByLibrary.simpleMessage(
            "Si us plau, introdueix una adreça"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Please Enter a Username or Address"),
        "addressShare":
            MessageLookupByLibrary.simpleMessage("Compartir adreça"),
        "aliases": MessageLookupByLibrary.simpleMessage("Aliases"),
        "amountMissing": MessageLookupByLibrary.simpleMessage(
            "Si us plau, introdueix una quantitat"),
        "asked": MessageLookupByLibrary.simpleMessage("Asked"),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Mètode d\'autenticació"),
        "autoImport": MessageLookupByLibrary.simpleMessage("Auto Import"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Bloqueig automàtic"),
        "backupConfirmButton": MessageLookupByLibrary.simpleMessage(
            "N\'he fet una còpia de seguretat"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Copiar la frase secreta"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Copiar la llavor"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "N\'estàs segur que has fet una còpia de seguretat de la llavor?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Copia la teva llavor"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Biometria"),
        "blockExplorer":
            MessageLookupByLibrary.simpleMessage("Explorador de blocs"),
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
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel·lar"),
        "changeCurrency":
            MessageLookupByLibrary.simpleMessage("Canviar moneda"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Change Log"),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Canviar representant"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Canviar"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Introduir nou representant"),
        "changeRepSame": MessageLookupByLibrary.simpleMessage(
            "This is already your representative!"),
        "changeRepSucces": MessageLookupByLibrary.simpleMessage(
            "Representant canviat amb èxit"),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Check Availability"),
        "close": MessageLookupByLibrary.simpleMessage("Tancar"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Confirma la contrasenya"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Connectant"),
        "contactAdded": MessageLookupByLibrary.simpleMessage(
            "%1 s\'ha afegit als contactes."),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("El contacte ja existeix"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Contacte"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Nom de contacte invàlid"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Introdueix un nom @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Escull un nom per aquest contacte"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 s\'ha eliminat dels contactes!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Contactes"),
        "contactsImportErr": MessageLookupByLibrary.simpleMessage(
            "Error a l\'importar contactes"),
        "contactsImportSuccess": MessageLookupByLibrary.simpleMessage(
            "%1 contactes importats amb èxit."),
        "copied": MessageLookupByLibrary.simpleMessage("Copiat"),
        "copy": MessageLookupByLibrary.simpleMessage("Copia"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Copiar adreça"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Copiar la llavor"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Copy wallet address to clipboard"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Crea una contrasenya."),
        "createGiftCard":
            MessageLookupByLibrary.simpleMessage("Create Gift Card"),
        "createGiftHeader":
            MessageLookupByLibrary.simpleMessage("Create a Gift Card"),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "Pots establir una contrasenya per afegir protecció addicional al teu moneder."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Crea una contrasenya"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "La contrasenya és opcional, el teu moneder estarà protegit amb el PIN o les dades biomètriques."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Crear"),
        "createQR": MessageLookupByLibrary.simpleMessage("Create QR Code"),
        "creatingGiftCard":
            MessageLookupByLibrary.simpleMessage("Creating Gift Card"),
        "currency": MessageLookupByLibrary.simpleMessage("Moneda"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Currency Mode"),
        "currencyModeHeader":
            MessageLookupByLibrary.simpleMessage("Currency Mode Info"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Choose which unit to display amounts in.\n1 nyano = 0.000001 NANO, or \n1,000,000 nyano = 1 NANO"),
        "currentlyRepresented":
            MessageLookupByLibrary.simpleMessage("Actualment representat per"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Decryption Error!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Compte principal"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Compte %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Desactivar"),
        "disablePasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "La contrasenya s\'ha desactivat"),
        "disableWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Desactivar contrasenya del moneder"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Descartar"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Domain Name"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Error a l\'establir la contrasenya del moneder"),
        "enterAddress":
            MessageLookupByLibrary.simpleMessage("Introduir adreça"),
        "enterAmount":
            MessageLookupByLibrary.simpleMessage("Introduir quantitat"),
        "enterGiftMemo":
            MessageLookupByLibrary.simpleMessage("Enter Gift Note"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("Enter Message"),
        "enterPasswordHint": MessageLookupByLibrary.simpleMessage(
            "Introdueix la teva contrasenya"),
        "enterUserOrAddress":
            MessageLookupByLibrary.simpleMessage("Enter User or Address"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Enter a username"),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("d\'algú"),
        "exampleCardFromKal":
            MessageLookupByLibrary.simpleMessage("d\'un mico qualsevol"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Benvingut a Nautilus. Un cop hagis rebut NANO, les transaccions apareixeran així:"),
        "exampleCardIntroKal": MessageLookupByLibrary.simpleMessage(
            "Benvingut a Kalium. Un cop hagis rebut BANANO, les transaccions apareixeran així:"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Uns pocs"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Molts"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("a algú"),
        "exampleCardToKal":
            MessageLookupByLibrary.simpleMessage("a un mico qualsevol"),
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
        "exit": MessageLookupByLibrary.simpleMessage("Sortir"),
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
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Autentica\'t per copiar la llavor i la frase secreta."),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("fulfilled"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("You have a gift!"),
        "giftAlertEmpty": MessageLookupByLibrary.simpleMessage("Empty Gift"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("Gift Amount"),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Gift From"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Load a Digital Gift Card with NANO! Set an amount, and an optional message for the recipient to see when they open it!\n\nOnce created, you\'ll get a link that you can send to anyone, which when opened will automatically distribute the funds to the recipient after installing Nautilus!\n\nIf the recipient is already a Nautilus user they will get a prompt to transfer the funds into their account upon opening the link"),
        "giftMessage": MessageLookupByLibrary.simpleMessage("Gift Message"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Tornar"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Go to QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Ho entenc!"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Amagar compte?"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("Entenc els riscos"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignorar"),
        "import": MessageLookupByLibrary.simpleMessage("Importar"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "The link you clicked contains some nano, would you like to import it to this wallet, or refund it to whoever sent it?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Importar frase secreta"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Si us plau, introdueix la teva frase secreta de 24 paraules a sota. Cada paraula ha d\'estar separada per un espai."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Importa la llavor"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage(
            "Si us plau, introdueix la llavor a sota."),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Canviar a importar llavor"),
        "importWallet":
            MessageLookupByLibrary.simpleMessage("Importar el moneder"),
        "instantly": MessageLookupByLibrary.simpleMessage("A l\'instant"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Saldo insuficient"),
        "invalidAddress": MessageLookupByLibrary.simpleMessage(
            "L\'adreça introduïda no és vàlida"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Contrasenya no vàlida"),
        "kaliumWallet": MessageLookupByLibrary.simpleMessage("Moneder Kalium"),
        "language": MessageLookupByLibrary.simpleMessage("Idioma"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("Link Copied"),
        "liveSupportButton": MessageLookupByLibrary.simpleMessage("Suport"),
        "loaded": MessageLookupByLibrary.simpleMessage("Loaded"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Loaded Into"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Autenticar-se a l\'inici"),
        "locked": MessageLookupByLibrary.simpleMessage("Bloquejat"),
        "logout": MessageLookupByLibrary.simpleMessage("Tancar la sessió"),
        "logoutAction": MessageLookupByLibrary.simpleMessage(
            "Eliminar llavor i tancar sessió"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("N\'estàs segur?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Tancar la sessió eliminarà la llavor i totes les dades relacionades amb Nautilus emmagatzemades en aquest dispositiu. Si no disposes d\'una còpia de seguretat de la teva llavor, no podràs recuperar l\'accés als teus fons"),
        "logoutDetailKal": MessageLookupByLibrary.simpleMessage(
            "Tancar la sessió eliminarà la llavor i totes les dades relacionades amb Kalium emmagatzemades en aquest dispositiu. Si no disposes d\'una còpia de seguretat de la teva llavor, no podràs recuperar l\'accés als teus fons"),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Sempre que hagis fet una còpia de seguretat de la teva llavor no t\'has de preocupar per res."),
        "manage": MessageLookupByLibrary.simpleMessage("Administrar"),
        "mantaError": MessageLookupByLibrary.simpleMessage(
            "No s\'ha pogut verificar la sol·licitud"),
        "manualEntry":
            MessageLookupByLibrary.simpleMessage("Introduir manualment"),
        "markAsPaid": MessageLookupByLibrary.simpleMessage("Mark as Paid"),
        "markAsUnpaid": MessageLookupByLibrary.simpleMessage("Mark as Unpaid"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Memo re-sent! If still unacknowledged, the recipient\'s device may be offline."),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Missatge"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "La quanitat mínima d\'enviament és %1 NANO"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 no és una paraula vàlida"),
        "mnemonicPhrase":
            MessageLookupByLibrary.simpleMessage("Frase mnemotècnica"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "La frase secreta només pot contenir 24 paraules"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "This feature requires you to have a longer transaction history in order to prevent spam.\n\nAlternatively, you can show a QR code for someone to scan."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Verification Needed"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Aquest és el teu nou compte. Un cop hagis rebut NANO, les transaccions apareixeran així:"),
        "newAccountIntroKal": MessageLookupByLibrary.simpleMessage(
            "Aquest és el teu nou compte. Un cop hagis rebut BANANO, les transaccions apareixeran així:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Nou moneder"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Següent"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noContactsExport": MessageLookupByLibrary.simpleMessage(
            "No hi ha contactes per exportar."),
        "noContactsImport": MessageLookupByLibrary.simpleMessage(
            "No hi ha nous contactes per importar."),
        "noSearchResults":
            MessageLookupByLibrary.simpleMessage("No Search Results!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("No, ometre"),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("Node Status"),
        "notSent": MessageLookupByLibrary.simpleMessage("not sent"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Obre Nautilus per veure aquesta transacció"),
        "notificationBodyKal": MessageLookupByLibrary.simpleMessage(
            "Obre Kalium per veure aquesta transacció"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Prémer per obrir"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "In order for this feature to work correctly, notifications must be enabled"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Has rebut %1 NANO"),
        "notificationTitleKal":
            MessageLookupByLibrary.simpleMessage("Has rebut %1 BANANO"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notificacions"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Nyanicon"),
        "off": MessageLookupByLibrary.simpleMessage("Desactivades"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "onStr": MessageLookupByLibrary.simpleMessage("Activades"),
        "onramp": MessageLookupByLibrary.simpleMessage("Onramp"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Opened"),
        "paid": MessageLookupByLibrary.simpleMessage("paid"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("Moneder de paper"),
        "passwordBlank": MessageLookupByLibrary.simpleMessage(
            "La contrasenya no pot estar buida"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Ja no requeriràs una contrasenya per obrir Nautilus."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Es requerirà aquesta contrasenya per obrir Nautilus."),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Les contrasenyes no coincideixen"),
        "pay": MessageLookupByLibrary.simpleMessage("Pay"),
        "payRequest": MessageLookupByLibrary.simpleMessage("Pay this request"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Someone has requested payment from you! check the payments page for more info."),
        "payments": MessageLookupByLibrary.simpleMessage("Payments"),
        "pickFromList":
            MessageLookupByLibrary.simpleMessage("Escollir d\'una llista"),
        "pinConfirmError": MessageLookupByLibrary.simpleMessage(
            "Els codis PIN no coincideixen"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Confirma el teu PIN"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Crea un PIN de 6 dígits"),
        "pinEnterTitle":
            MessageLookupByLibrary.simpleMessage("Introdueix el PIN"),
        "pinInvalid":
            MessageLookupByLibrary.simpleMessage("PIN introduït invàlid"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "Introdueix el PIN per canviar el representant."),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Introdueix el PIN per copiar la llavor i la frase secreta"),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferències"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Política de privadesa"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Purchase Nano"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "El codi QR no conté un destí vàlid"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Si us plau, concedeix permisos de càmera per escanejar codis QR"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "El codi QR no conté una llavor o clau privada vàlida"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "El codi QR no conté una frase secreta vàlida"),
        "qrUnknownError": MessageLookupByLibrary.simpleMessage(
            "No s\'ha pogut llegir el codi QR"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp": MessageLookupByLibrary.simpleMessage("Rate the App"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn\'t take more than a minute."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Llavor"),
        "readMore": MessageLookupByLibrary.simpleMessage("Llegir més"),
        "receivable": MessageLookupByLibrary.simpleMessage("receivable"),
        "receive": MessageLookupByLibrary.simpleMessage("Rebre"),
        "receiveMinimum":
            MessageLookupByLibrary.simpleMessage("Receive Minimum"),
        "receiveMinimumHeader":
            MessageLookupByLibrary.simpleMessage("Receive Minimum Info"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "A minimum amount to receive. If a payment or request is received with an amount less than this, it will be ignored."),
        "received": MessageLookupByLibrary.simpleMessage("Rebut"),
        "refund": MessageLookupByLibrary.simpleMessage("Refund"),
        "registerFor": MessageLookupByLibrary.simpleMessage("for"),
        "registerUsername":
            MessageLookupByLibrary.simpleMessage("Register Username"),
        "registerUsernameHeader":
            MessageLookupByLibrary.simpleMessage("Register a Username"),
        "registering": MessageLookupByLibrary.simpleMessage("Registering"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "N\'estàs segur que vols amagar aquest compte? Més endavant el pots tornar a afegir prement el botó \"%1\"."),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("Unblock"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to unblock %1?"),
        "removeContact":
            MessageLookupByLibrary.simpleMessage("Eliminar contacte"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "N\'estàs segur que vols eliminar a %1?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Remove Favorite"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "Un representant és un compte que vota pel consens de la xarxa, i el pes de vot està ponderat pel saldo. Pots delegar el teu saldo per incrementar el pes de vot d\'un representant en el que confiïs. El teu representant no té cap capacitat de gestió ni ús sobre els teus fons. És recomanable escollir un representant que tingui una alta disponibilitat i sigui de confiança."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("Què és un representant?"),
        "reply": MessageLookupByLibrary.simpleMessage("Reply"),
        "representatives":
            MessageLookupByLibrary.simpleMessage("Representants"),
        "request": MessageLookupByLibrary.simpleMessage("Request"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Request %1 %2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Request Failed: This user doesn\'t appear to have Nautilus installed, or has notifications disabled."),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Request Payment"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Error sending payment request, the recipient\'s device may be offline or unavailable."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Request re-sent! If still unacknowledged, the recipient\'s device may be offline."),
        "requested": MessageLookupByLibrary.simpleMessage("Requested"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Requested From"),
        "requesting": MessageLookupByLibrary.simpleMessage("Requesting"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Vols requerir una contrasenya per obrir Nautilus?"),
        "resendMemo": MessageLookupByLibrary.simpleMessage("Resend this memo"),
        "resetDatabase":
            MessageLookupByLibrary.simpleMessage("Reset the Database"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to reset the internal database? \n\nThis may fix issues related to updating the app, but will also delete all saved preferences. This will NOT delete your wallet seed. If you\'re having issues you should backup your seed, re-install the app, and if the issue persists feel free to make a bug report on github or discord."),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "Sembla que el teu dispositiu té accés \"root\", \"jailbreak\", o està modificat de forma que en compromet la seguretat. És recomanable que es retorni el dispositiu a l\'estat original abans de continuar."),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Escaneja el codi QR\nd\'una adreça Nano"),
        "scanInstructionsKal": MessageLookupByLibrary.simpleMessage(
            "Escaneja el codi QR\nd\'una adreça Banano"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Escanejar codi QR"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Search for anything"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "En la següent pantalla, veuràs una frase secreta. És una contrasenya per accedir als teus fons. És crucial que en facis una còpia de seguretat i no la comparteixis amb ningú."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Seguretat abans que res!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Frase secreta"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Frase secreta copiada"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Copiar frase secreta"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Si perds el teu dispositiu o desinstal·les l\'aplicació, necessitaràs la teva frase secreta o llavor per recuperar els teus fons!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Seguretat"),
        "seed": MessageLookupByLibrary.simpleMessage("Llavor"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "A sota tens la teva llavor. És crucial que facis una còpia de la teva llavor i no la desis mai en text sense format o en una captura de pantalla."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Llavor copiada al porta-retalls\nEs pot enganxar durant 2 minuts."),
        "seedCopiedShort":
            MessageLookupByLibrary.simpleMessage("Llavor copiada"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Una llavor conté la mateixa informació que una frase secreta, però de forma llegible per una màquina. Mentre tinguis una còpia de seguretat de qualsevol de les dues, tindràs accés als teus fons."),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("Llavor no vàlida"),
        "selfSendError":
            MessageLookupByLibrary.simpleMessage("Can\'t request from self"),
        "send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Enviar %1 NANO"),
        "sendAmountConfirmKal":
            MessageLookupByLibrary.simpleMessage("Enviar %1 BANANO"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error. Intenta-ho més tard."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Enviar des de"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Sending memo with transaction failed, they may not be a Nautilus user."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Sending message"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Send Request again"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Send or Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other nautilus users.\n\nYou don\'t need to have a username in order to send or receive payment requests, and you can use them for your own record keeping even if they don\'t use nautilus."),
        "sendSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Send Sheet Info"),
        "sending": MessageLookupByLibrary.simpleMessage("Enviant"),
        "sent": MessageLookupByLibrary.simpleMessage("Enviat"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Enviar a"),
        "setPassword":
            MessageLookupByLibrary.simpleMessage("Establir contrasenya"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Contrasenya establerta amb èxit"),
        "setWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Establir contrasenya del moneder"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Configuració"),
        "settingsTransfer": MessageLookupByLibrary.simpleMessage(
            "Carregar des d\'un moneder de paper"),
        "shareLink": MessageLookupByLibrary.simpleMessage("Share Link"),
        "shareNautilus":
            MessageLookupByLibrary.simpleMessage("Compartir Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Fes una ullada a Nautilus! Un moneder mòbil NANO de primera!"),
        "showContacts": MessageLookupByLibrary.simpleMessage("Show Contacts"),
        "simplex": MessageLookupByLibrary.simpleMessage("Simplex"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Support the Developer"),
        "switchToSeed":
            MessageLookupByLibrary.simpleMessage("Canviar a la llavor"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("Predeterminat del sistema"),
        "tapToHide": MessageLookupByLibrary.simpleMessage("Prem per amagar"),
        "tapToReveal": MessageLookupByLibrary.simpleMessage("Prem per mostrar"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Tema"),
        "to": MessageLookupByLibrary.simpleMessage("A"),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "Massa intents de desbloqueig fallits."),
        "transactions": MessageLookupByLibrary.simpleMessage("Transaccions"),
        "transfer": MessageLookupByLibrary.simpleMessage("Transferir"),
        "transferClose": MessageLookupByLibrary.simpleMessage(
            "Prem a qualsevol lloc per tancar la finestra."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO han estat transferits amb èxit al teu moneder Nautilus.\n"),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "S\'ha detectat un moneder amb un saldo de %1 NANO.\n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "La transferència pot tardar uns quants segons a completar-se.\n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "La transferència pot tardar uns quants segons a completar-se."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error en la transferència. Si us plau, intenta-ho més tard."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Transferir fons"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "Aquest procés transferirà els fons des d\'un moneder de paper al teu moneder Nautilus.\n\nPrem el botó \"%1\" per començar."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "This process will transfer the funds from a paper wallet to your Nautilus wallet."),
        "transferLoading": MessageLookupByLibrary.simpleMessage("Transferint"),
        "transferManualHint": MessageLookupByLibrary.simpleMessage(
            "Si us plau, introdueix la llavor a sota."),
        "transferNoFunds": MessageLookupByLibrary.simpleMessage(
            "Aquesta llavor no conté cap NANO"),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "Aquest codi QR no conté una llavor vàlida."),
        "transferQrScanHint": MessageLookupByLibrary.simpleMessage(
            "Escaneja una llavor\no clau privada Nano"),
        "unacknowledged":
            MessageLookupByLibrary.simpleMessage("unacknowledged"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("sense confirmar"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("unfulfilled"),
        "unlock": MessageLookupByLibrary.simpleMessage("Desbloquejar"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Autentica\'t per desbloquejar Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Introdueix el PIN per desbloquejar Nautilus"),
        "unlockPinKal": MessageLookupByLibrary.simpleMessage(
            "Introdueix el PIN per desbloquejar Kalium"),
        "unpaid": MessageLookupByLibrary.simpleMessage("unpaid"),
        "unread": MessageLookupByLibrary.simpleMessage("unread"),
        "uptime": MessageLookupByLibrary.simpleMessage("Disponibilitat"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
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
        "viewDetails": MessageLookupByLibrary.simpleMessage("Veure detalls"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("Pes de vot"),
        "warning": MessageLookupByLibrary.simpleMessage("Advertència"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Benvingut a Nautilus. Per començar, pots crear un nou moneder o importar-ne un d\'existent."),
        "welcomeTextKal": MessageLookupByLibrary.simpleMessage(
            "Benvingut a Kalium. Per començar, pots crear un nou moneder o importar-ne un d\'existent."),
        "withAddress": MessageLookupByLibrary.simpleMessage("With Address"),
        "withMessage": MessageLookupByLibrary.simpleMessage("With Message"),
        "xMinute": MessageLookupByLibrary.simpleMessage("Després d\'%1 minut"),
        "xMinutes":
            MessageLookupByLibrary.simpleMessage("Després de %1 minuts"),
        "yes": MessageLookupByLibrary.simpleMessage("Sí"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Sí")
      };
}
