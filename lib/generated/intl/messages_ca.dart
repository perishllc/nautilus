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
        "account": MessageLookupByLibrary.simpleMessage("Účet"),
        "accountNameHint":
            MessageLookupByLibrary.simpleMessage("Introduïu un nom"),
        "accountNameMissing":
            MessageLookupByLibrary.simpleMessage("Trieu un nom de compte"),
        "accounts": MessageLookupByLibrary.simpleMessage("Účty"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Jste si jisti, že jste zálohovali svou tajnou frázi nebo semínko?"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Aktivní zpráva"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Přidat účet"),
        "addAddress":
            MessageLookupByLibrary.simpleMessage("Afegeix una adreça"),
        "addBlocked": MessageLookupByLibrary.simpleMessage("Block a User"),
        "addContact": MessageLookupByLibrary.simpleMessage("Přidat kontakt"),
        "addFavorite": MessageLookupByLibrary.simpleMessage("Add Favorite"),
        "addUser": MessageLookupByLibrary.simpleMessage("Afegeix un usuari"),
        "addWatchOnlyAccount": MessageLookupByLibrary.simpleMessage(
            "Afegeix un compte només de rellotge"),
        "addWatchOnlyAccountError": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error en afegir el compte de només vigilància: el compte era nul"),
        "addWatchOnlyAccountSuccess": MessageLookupByLibrary.simpleMessage(
            "S\'ha creat correctament el compte només de rellotge!"),
        "address": MessageLookupByLibrary.simpleMessage("adreça"),
        "addressCopied":
            MessageLookupByLibrary.simpleMessage("Adresa zkopírována"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Zadejte adresu"),
        "addressMissing":
            MessageLookupByLibrary.simpleMessage("Prosím zadejte adresu"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Please Enter a Username or Address"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Sdílet adresu"),
        "aliases": MessageLookupByLibrary.simpleMessage("Aliases"),
        "amountGiftGreaterError": MessageLookupByLibrary.simpleMessage(
            "L\'import dividit no pot ser superior al saldo del regal"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Prosím zadejte částku"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "Hem observat que heu fet clic en un enllaç que conté una mica de nano, voleu ometre el procés de configuració? Sempre pots canviar les coses després.\n\n Tanmateix, si teniu una llavor existent que voleu importar, haureu de seleccionar no."),
        "asked": MessageLookupByLibrary.simpleMessage("Asked"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("Autenticació"),
        "authError": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error durant l\'autenticació. Torna-ho a provar més tard."),
        "authMethod": MessageLookupByLibrary.simpleMessage("Metoda ověření"),
        "authenticating": MessageLookupByLibrary.simpleMessage("Autenticació"),
        "autoImport": MessageLookupByLibrary.simpleMessage("Auto Import"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Automaticky zamknout"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("Zálohoval jsem to"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Zálohovat tajnou frázi"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Zálohovat semínko"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Jste si jisti, že jste zálohovali své semínko peněženky?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Zálohujte své semínko"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Biometrie"),
        "blockExplorer":
            MessageLookupByLibrary.simpleMessage("Průzkumník bloků"),
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
            "Sembla que no podem arribar a l\'API Branch, això sol ser causat per algun tipus de problema de xarxa o VPN que bloqueja la connexió.\n\n Encara hauríeu de poder utilitzar l\'aplicació amb normalitat, però és possible que l\'enviament i la recepció de targetes regal no funcionin."),
        "branchConnectErrorShortDesc": MessageLookupByLibrary.simpleMessage(
            "Error: no es pot accedir a l\'API Branch"),
        "branchConnectErrorTitle":
            MessageLookupByLibrary.simpleMessage("Avís de connexió"),
        "cancel": MessageLookupByLibrary.simpleMessage("Zrušit"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("Captcha"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "Per evitar l\'abús, us demanem que resolgueu un captcha per reclamar la targeta regal a la pàgina següent."),
        "changeCurrency": MessageLookupByLibrary.simpleMessage("Změna měny"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Change Log"),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Změnit zástupce"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Změnit"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Zadejte nového zástupce"),
        "changeRepSame": MessageLookupByLibrary.simpleMessage(
            "This is already your representative!"),
        "changeRepSucces":
            MessageLookupByLibrary.simpleMessage("Zástupce byl úspěšně změněn"),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Check Availability"),
        "close": MessageLookupByLibrary.simpleMessage("Zavřít"),
        "confirm": MessageLookupByLibrary.simpleMessage("Potvrdit"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Potvrďte heslo"),
        "confirmPinHint":
            MessageLookupByLibrary.simpleMessage("Confirmeu el pin"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Připojování"),
        "connectionWarning":
            MessageLookupByLibrary.simpleMessage("No es pot connectar"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "Sembla que no ens podem connectar al backend, aquesta podria ser només la vostra connexió o, si el problema persisteix, el backend podria estar inactiu per manteniment o fins i tot una interrupció. Si ha passat més d\'una hora i encara teniu problemes, envieu un informe a #bug-reports al servidor de Discord @ chat.perish.co"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Sembla que no ens podem connectar al backend, aquesta podria ser només la vostra connexió o, si el problema persisteix, el backend podria estar inactiu per manteniment o fins i tot una interrupció. Si ha passat més d\'una hora i encara teniu problemes, envieu un informe a #bug-reports al servidor de Discord @ chat.perish.co"),
        "connectionWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Sembla que no ens podem connectar al backend"),
        "contactAdded":
            MessageLookupByLibrary.simpleMessage("%1 přidán do kontaktů."),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Kontakt již existuje."),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Kontakt"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Zadejte jméno kontaktu"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Zadejte jméno @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Zadejte nové jméno pro tento kontakt"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 byl úspěšně odstraněn z kontaktů!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Kontakty"),
        "contactsImportErr":
            MessageLookupByLibrary.simpleMessage("Import kontaktů se nezdařil"),
        "contactsImportSuccess": MessageLookupByLibrary.simpleMessage(
            "%1 kontaktů bylo úspěšně importováno."),
        "copied": MessageLookupByLibrary.simpleMessage("Zkopírováno"),
        "copy": MessageLookupByLibrary.simpleMessage("Kopírovat"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Kopírovat adresu"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
        "copyMessage":
            MessageLookupByLibrary.simpleMessage("Copia el missatge"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Kopírovat semínko"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Copy wallet address to clipboard"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Vytvořte si heslo."),
        "createGiftCard":
            MessageLookupByLibrary.simpleMessage("Create Gift Card"),
        "createGiftHeader":
            MessageLookupByLibrary.simpleMessage("Create a Gift Card"),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "Můžete si vytvořit heslo a přidat tak do své peněženky další zabezpečení."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Vytvořit heslo"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "Heslo je volitelné a vaše peněženka bude bez ohledu na to chráněna vaším PIN nebo biometrickými údaji."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Vytvořit"),
        "createPinHint": MessageLookupByLibrary.simpleMessage("Crea un pin"),
        "createQR": MessageLookupByLibrary.simpleMessage("Create QR Code"),
        "created": MessageLookupByLibrary.simpleMessage("creat"),
        "creatingGiftCard":
            MessageLookupByLibrary.simpleMessage("Creating Gift Card"),
        "currency": MessageLookupByLibrary.simpleMessage("Měna"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Currency Mode"),
        "currencyModeHeader":
            MessageLookupByLibrary.simpleMessage("Currency Mode Info"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Choose which unit to display amounts in.\n1 nyano = 0.000001 NANO, or \n1,000,000 nyano = 1 NANO"),
        "currentlyRepresented":
            MessageLookupByLibrary.simpleMessage("V současné době zastupuje"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Decryption Error!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Hlavní účet"),
        "defaultGiftMessage": MessageLookupByLibrary.simpleMessage(
            "Fes una ullada a Nautilus! T\'he enviat un nano amb aquest enllaç:"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Účet %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Vypnout"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Heslo bylo vypnuto úspěšně"),
        "disableWalletPassword":
            MessageLookupByLibrary.simpleMessage("Vypnout heslo peněženky"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Zavrhnout"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Domain Name"),
        "donateButton": MessageLookupByLibrary.simpleMessage("Donar"),
        "donateToSupport":
            MessageLookupByLibrary.simpleMessage("Donar suport al projecte"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "enableNotifications":
            MessageLookupByLibrary.simpleMessage("Activa les notificacions"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Nastavení hesla k peněžence se nezdařilo"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("Zadejte adresu"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Zadejte částku"),
        "enterGiftMemo":
            MessageLookupByLibrary.simpleMessage("Enter Gift Note"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("Enter Message"),
        "enterMoneroAddress":
            MessageLookupByLibrary.simpleMessage("Introduïu l\'adreça XMR"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Zadejte vaše heslo"),
        "enterSplitAmount":
            MessageLookupByLibrary.simpleMessage("Introduïu l\'import dividit"),
        "enterUserOrAddress":
            MessageLookupByLibrary.simpleMessage("Enter User or Address"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Enter a username"),
        "errorProcessingGiftCard": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error en processar aquesta targeta de regal, és possible que no sigui vàlida, caducada o buida."),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("od někoho"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Vítejte v Natriu. Jakmile obdržíte NANO, transakce se zobrazí takto:"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Málo"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Hodně"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("někomu"),
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
        "exchangeNano": MessageLookupByLibrary.simpleMessage("Intercanvi NANO"),
        "exit": MessageLookupByLibrary.simpleMessage("Odejít"),
        "exportTXData":
            MessageLookupByLibrary.simpleMessage("Transaccions d\'exportació"),
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
            "Ověřte se pro zálohu semínka."),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("fulfilled"),
        "fundingBannerHeader":
            MessageLookupByLibrary.simpleMessage("Banner de finançament"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("Finançament"),
        "getNano": MessageLookupByLibrary.simpleMessage("Aconsegueix NANO"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("You have a gift!"),
        "giftAlertEmpty": MessageLookupByLibrary.simpleMessage("Empty Gift"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("Gift Amount"),
        "giftCardCreationError": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error en intentar crear un enllaç de targeta regal"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error en intentar crear una targeta regal, S\'HA COPIAT L\'ENLLAÇ DE LA TARGETA REGAL O LA LLAVOR AL TEU PORTAPELLORS, ELS VOSTRES FONS ES PODEN CONTINGUIR-HI DEPENDI DEL QUÈ S\'HA FALLAT."),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Gift From"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Load a Digital Gift Card with NANO! Set an amount, and an optional message for the recipient to see when they open it!\n\nOnce created, you\'ll get a link that you can send to anyone, which when opened will automatically distribute the funds to the recipient after installing Nautilus!\n\nIf the recipient is already a Nautilus user they will get a prompt to transfer the funds into their account upon opening the link"),
        "giftMessage": MessageLookupByLibrary.simpleMessage("Gift Message"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error en processar aquesta targeta regal. Potser comproveu la vostra connexió i torneu a fer clic a l\'enllaç del regal."),
        "giftProcessSuccess": MessageLookupByLibrary.simpleMessage(
            "Regal rebut correctament, pot trigar un moment a aparèixer a la cartera."),
        "giftRefundSuccess": MessageLookupByLibrary.simpleMessage(
            "Regal reemborsat correctament!"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Zpět"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Go to QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Chápu!"),
        "handoff": MessageLookupByLibrary.simpleMessage("lliurament"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage(
            "S\'ha produït un error en intentar transferir el bloqueig!"),
        "handoffSupportedMethodNotFound": MessageLookupByLibrary.simpleMessage(
            "No s\'ha pogut trobar un mètode de lliurament compatible!"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "hideAccountHeader": MessageLookupByLibrary.simpleMessage("Skrýt účet"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Esteu segur que voleu amagar els comptes buits?\n\nAixò amagarà tots els comptes amb un saldo exactament 0 (excepte les adreces només de rellotge i el vostre compte principal), però sempre podeu tornar-los a afegir més tard tocant el botó \"Afegeix un compte\"."),
        "hideAccountsHeader":
            MessageLookupByLibrary.simpleMessage("Amagar els comptes?"),
        "hideEmptyAccounts":
            MessageLookupByLibrary.simpleMessage("Amaga els comptes buits"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("Chápu rizika"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignorovat"),
        "imSure": MessageLookupByLibrary.simpleMessage("Estic segur"),
        "import": MessageLookupByLibrary.simpleMessage("Importovat"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "The link you clicked contains some nano, would you like to import it to this wallet, or refund it to whoever sent it?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "Sembla que heu fet clic en un enllaç que conté una mica de NANO, per rebre aquests fons només necessitem que acabeu de configurar la vostra cartera."),
        "importGiftv2": MessageLookupByLibrary.simpleMessage(
            "L\'enllaç que heu fet clic conté una mica de NANO, voleu importar-lo a aquesta cartera?"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Importujte tajnou frázi"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Níže zadejte svoji 24slovnou tajnou frázi. Každé slovo by mělo být odděleno mezerou."),
        "importSeed":
            MessageLookupByLibrary.simpleMessage("Importovat semínko"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage(
            "Prosím, zadejte vaše semínko níže."),
        "importSeedInstead": MessageLookupByLibrary.simpleMessage(
            "Místo toho importovat semínko"),
        "importWallet":
            MessageLookupByLibrary.simpleMessage("Importovat pěněženku"),
        "instantly": MessageLookupByLibrary.simpleMessage("Ihned"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Nedostatečný zůstatek"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "Hem saltat el procés d\'introducció per estalviar-vos temps, però hauríeu de fer una còpia de seguretat de la nova llavor creada immediatament.\n\nSi perds la teva llavor, perdràs l\'accés als teus fons.\n\nA més, la vostra contrasenya s\'ha establert a \"000000\", que també hauríeu de canviar immediatament."),
        "introSkippedWarningHeader": MessageLookupByLibrary.simpleMessage(
            "Fes una còpia de seguretat de la teva llavor!"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Zadaná adresa není platná"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Neplatné heslo"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("Pin no vàlid"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "A causa de les directrius i restriccions de l\'App Store d\'iOS, no us podem enllaçar a la nostra pàgina de donacions. Si voleu donar suport al projecte, considereu enviar-lo a l\'adreça del node nautilus."),
        "language": MessageLookupByLibrary.simpleMessage("Jazyk"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("Link Copied"),
        "loaded": MessageLookupByLibrary.simpleMessage("Loaded"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Loaded Into"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Ověřit při spuštění"),
        "locked": MessageLookupByLibrary.simpleMessage("Zamčeno"),
        "logout": MessageLookupByLibrary.simpleMessage("Odhlásit"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Smazat semínko a odhlásit"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Jste si jisti?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Odhlášením odstraníte z tohoto zařízení vaše semínko a všechna data související s Nautilus. Pokud vaše semínko není zálohováno, už nikdy nebudete mít přístup ke svým prostředkům"),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Pokud jste zálohovali své semínko, nemusíte se ničeho obávat."),
        "manage": MessageLookupByLibrary.simpleMessage("Spravovat"),
        "mantaError": MessageLookupByLibrary.simpleMessage(
            "Požadavek se nepodařilo ověřit"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("Ruční zadání"),
        "markAsPaid": MessageLookupByLibrary.simpleMessage("Mark as Paid"),
        "markAsUnpaid": MessageLookupByLibrary.simpleMessage("Mark as Unpaid"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Memo re-sent! If still unacknowledged, the recipient\'s device may be offline."),
        "messageCopied":
            MessageLookupByLibrary.simpleMessage("S\'ha copiat el missatge"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Zpráva"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "Minimální částka pro odeslání je% 1 NANO"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("% 1 není platné slovo"),
        "mnemonicPhrase":
            MessageLookupByLibrary.simpleMessage("Mnemonická fráze"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Tajná fráze může obsahovat pouze 24 slov"),
        "monthlyServerCosts": MessageLookupByLibrary.simpleMessage(
            "Costos mensuals del servidor"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings":
            MessageLookupByLibrary.simpleMessage("Més configuració"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "nautilusWallet":
            MessageLookupByLibrary.simpleMessage("Cartera Nautilus"),
        "nearby": MessageLookupByLibrary.simpleMessage("A prop"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "This feature requires you to have a longer transaction history in order to prevent spam.\n\nAlternatively, you can show a QR code for someone to scan."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Verification Needed"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Toto je váš nový účet. Jakmile obdržíte NANO, transakce se zobrazí takto:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Nová peněženka"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Další"),
        "no": MessageLookupByLibrary.simpleMessage("Ne"),
        "noContactsExport": MessageLookupByLibrary.simpleMessage(
            "Neexistují žádné kontakty k exportu."),
        "noContactsImport": MessageLookupByLibrary.simpleMessage(
            "Žádné nové kontakty k importu."),
        "noSearchResults":
            MessageLookupByLibrary.simpleMessage("No Search Results!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("Ne, přeskočit"),
        "noTXDataExport": MessageLookupByLibrary.simpleMessage(
            "No hi ha transaccions per exportar."),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("Node Status"),
        "notSent": MessageLookupByLibrary.simpleMessage("not sent"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Otevřete Nautilus pro zobrazení této transakce"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Klepnutím otevřete"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "In order for this feature to work correctly, notifications must be enabled"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Přijato %1 NANO"),
        "notificationWarning":
            MessageLookupByLibrary.simpleMessage("Notificacions desactivades"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Les sol·licituds de pagament, les notes i els missatges requereixen que les notificacions estiguin habilitades per funcionar correctament, ja que utilitzen el servei de notificacions de FCM per garantir el lliurament dels missatges.\n\nPodeu activar les notificacions amb el botó següent o ignorar aquesta targeta si no us interessa utilitzar aquestes funcions."),
        "notificationWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Les sol·licituds de pagament, les notes i els missatges no funcionaran correctament."),
        "notifications": MessageLookupByLibrary.simpleMessage("Upozornění"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Nyanicon"),
        "off": MessageLookupByLibrary.simpleMessage("Off"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "onStr": MessageLookupByLibrary.simpleMessage("On"),
        "onboard": MessageLookupByLibrary.simpleMessage("Convida algú"),
        "onboarding": MessageLookupByLibrary.simpleMessage("En l\'embarcament"),
        "onramp": MessageLookupByLibrary.simpleMessage("Onramp"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Opened"),
        "paid": MessageLookupByLibrary.simpleMessage("paid"),
        "paperWallet":
            MessageLookupByLibrary.simpleMessage("Papírová Peněženka"),
        "passwordBlank":
            MessageLookupByLibrary.simpleMessage("Heslo nemůže být prázdné"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Už nebudete potřebovat heslo pro otevření Nautilus."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Toto heslo bude vyžadováno k otevření Nautilus."),
        "passwordsDontMatch":
            MessageLookupByLibrary.simpleMessage("Heslo se neshoduje"),
        "pay": MessageLookupByLibrary.simpleMessage("Pay"),
        "payRequest": MessageLookupByLibrary.simpleMessage("Pay this request"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Someone has requested payment from you! check the payments page for more info."),
        "payments": MessageLookupByLibrary.simpleMessage("Payments"),
        "pickFromList":
            MessageLookupByLibrary.simpleMessage("Vyberte ze seznamu"),
        "pinBlank":
            MessageLookupByLibrary.simpleMessage("El pin no pot estar buit"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("Pin se neshoduje"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Potvrdit Váš pin"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Vytvořte si šestimístný pin"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("Zadejte pin"),
        "pinInvalid": MessageLookupByLibrary.simpleMessage("Neplatný pin"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "Zadejte PIN pro změnu zástupce."),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Zadejte PIN pro zálohu semínka"),
        "pinsDontMatch":
            MessageLookupByLibrary.simpleMessage("Els pins no coincideixen"),
        "plausibleDeniabilityParagraph": MessageLookupByLibrary.simpleMessage(
            "Aquest NO és el mateix pin que vas utilitzar per crear la teva cartera. Premeu el botó d\'informació per obtenir més informació."),
        "plausibleInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Informació de negació plausible"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Estableix un pin secundari per al mode de denegació plausible.\n\nSi la vostra cartera es desbloqueja amb aquest pin secundari, la vostra llavor es substituirà per un hash de la llavor existent. Aquesta és una funció de seguretat destinada a utilitzar-se en cas que se us obligui a obrir la cartera.\n\nAquest pin actuarà com un pin normal (correcte) EXCEPTE en desbloquejar la cartera, que és quan s\'activarà el mode de denegació plausible.\n\nEls vostres fons ES PERDRÀN en entrar en mode de denegació plausible si no heu fet una còpia de seguretat de la vostra llavor!"),
        "preferences": MessageLookupByLibrary.simpleMessage("Předvolby"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage(
            "Zásady ochrany osobních údajů"),
        "promotionalLink": MessageLookupByLibrary.simpleMessage("NANO gratuït"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Purchase Nano"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR kód neobsahuje platnou destinaci."),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Udělte oprávnění fotoaparátu ke skenování QR kódů"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "QR kód neobsahuje platné semínko ani soukromý klíč"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "QR neobsahuje platnou tajnou frázi"),
        "qrUnknownError":
            MessageLookupByLibrary.simpleMessage("Nelze přečíst QR kód"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp": MessageLookupByLibrary.simpleMessage("Rate the App"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn\'t take more than a minute."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Hrubé semínko"),
        "readMore": MessageLookupByLibrary.simpleMessage("Více"),
        "receivable": MessageLookupByLibrary.simpleMessage("nevyřízený"),
        "receive": MessageLookupByLibrary.simpleMessage("Přijmout"),
        "receiveMinimum":
            MessageLookupByLibrary.simpleMessage("Receive Minimum"),
        "receiveMinimumHeader":
            MessageLookupByLibrary.simpleMessage("Receive Minimum Info"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "A minimum amount to receive. If a payment or request is received with an amount less than this, it will be ignored."),
        "received": MessageLookupByLibrary.simpleMessage("Přijmuto"),
        "refund": MessageLookupByLibrary.simpleMessage("Refund"),
        "registerFor": MessageLookupByLibrary.simpleMessage("for"),
        "registerUsername":
            MessageLookupByLibrary.simpleMessage("Register Username"),
        "registerUsernameHeader":
            MessageLookupByLibrary.simpleMessage("Register a Username"),
        "registering": MessageLookupByLibrary.simpleMessage("Registering"),
        "remove": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Opravdu chcete tento účet skrýt? Můžete jej znovu přidat později klepnutím na tlačítko \"%1\"."),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("Unblock"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to unblock %1?"),
        "removeContact":
            MessageLookupByLibrary.simpleMessage("Odstranit kontakt"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Opravdu chcete odstranit %1?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Remove Favorite"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "Zástupce je účet, který hlasuje pro konsensus sítě. Hlasovací síla je vážena rovnováhou, můžete delegovat svůj zůstatek a zvýšit hlasovací váhu zástupce, kterému důvěřujete. Váš zástupce nemá výdělečnou moc nad vašimi prostředky. Měli byste si vybrat zástupce, který má málo prostojů a je důvěryhodný."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("Co je to zástupce?"),
        "reply": MessageLookupByLibrary.simpleMessage("Reply"),
        "representatives": MessageLookupByLibrary.simpleMessage("Zástupci"),
        "request": MessageLookupByLibrary.simpleMessage("Request"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Request %1 %2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Request Failed: This user doesn\'t appear to have Nautilus installed, or has notifications disabled."),
        "requestFrom": MessageLookupByLibrary.simpleMessage("Sol·licitud de"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Request Payment"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Error sending payment request, the recipient\'s device may be offline or unavailable."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Request re-sent! If still unacknowledged, the recipient\'s device may be offline."),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Sol·liciteu un pagament, amb missatges xifrats d\'extrem a extrem!\n\nLes sol·licituds de pagament, les notes i els missatges només els podran rebre altres usuaris de nautilus, però podeu utilitzar-los per al vostre propi registre, encara que el destinatari no utilitzi nautilus."),
        "requestSheetInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Sol·licitar informació del full"),
        "requested": MessageLookupByLibrary.simpleMessage("Requested"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Requested From"),
        "requesting": MessageLookupByLibrary.simpleMessage("Requesting"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Vyžadovat heslo k otevření Nautilus?"),
        "requireCaptcha": MessageLookupByLibrary.simpleMessage(
            "Requereix CAPTCHA per reclamar la targeta regal"),
        "resendMemo": MessageLookupByLibrary.simpleMessage("Resend this memo"),
        "resetDatabase":
            MessageLookupByLibrary.simpleMessage("Reset the Database"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to reset the internal database? \n\nThis may fix issues related to updating the app, but will also delete all saved preferences. This will NOT delete your wallet seed. If you\'re having issues you should backup your seed, re-install the app, and if the issue persists feel free to make a bug report on github or discord."),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "Zdá se, že vaše zařízení je \"rootováno\", \"jailbroken\" nebo upraveno způsobem, který ohrožuje zabezpečení. Před pokračováním se doporučuje resetovat zařízení do původního stavu."),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Naskenujte QR kód Nano \n adresy"),
        "scanNFC":
            MessageLookupByLibrary.simpleMessage("Enviar mitjançant NFC"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Oskenovat QR kód"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Search for anything"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "Na další obrazovce uvidíte svoji tajnou frázi. Jedná se o heslo pro přístup k vašim finančním prostředkům. Je zásadní, abyste jej zálohovali a nikdy s nikým nesdíleli."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Bezpečnost především!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Tajná fráze"),
        "secretPhraseCopied": MessageLookupByLibrary.simpleMessage(
            "Tajná fráze byla zkopírována"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Zkopírovat tajnou frázi"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Pokud ztratíte zařízení nebo odinstalujete aplikaci, budete potřebovat tajnou frázi nebo semínko, abyste mohli získat zpět své prostředky!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Zabezpečení"),
        "seed": MessageLookupByLibrary.simpleMessage("Semínko"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Níže je semínko vaší peněženky. Je zásadní, abyste zálohovali své semínko a nikdy ho neukládali jako prostý text nebo snímek obrazovky."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Semínko zkopírováno do schránky \n Je vložitelné po dobu 2 minut."),
        "seedCopiedShort":
            MessageLookupByLibrary.simpleMessage("Semínko zkopírováno"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Semínko nese stejné informace jako tajná fráze, ale strojově čitelné. Pokud máte jeden z nich zálohovaný, budete mít přístup ke svým prostředkům."),
        "seedInvalid":
            MessageLookupByLibrary.simpleMessage("Semínko není platné"),
        "selfSendError":
            MessageLookupByLibrary.simpleMessage("Can\'t request from self"),
        "send": MessageLookupByLibrary.simpleMessage("Poslat"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Odeslat %1 NANO"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "Došlo k chybě. Zkuste to později."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Odeslat z"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Sending memo with transaction failed, they may not be a Nautilus user."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Sending message"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Send Request again"),
        "sendRequests":
            MessageLookupByLibrary.simpleMessage("Enviar sol · licituds"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Send or Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other nautilus users.\n\nYou don\'t need to have a username in order to send or receive payment requests, and you can use them for your own record keeping even if they don\'t use nautilus."),
        "sendSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Send Sheet Info"),
        "sending": MessageLookupByLibrary.simpleMessage("Odesílání"),
        "sent": MessageLookupByLibrary.simpleMessage("Odesláno"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Odeslat"),
        "setPassword": MessageLookupByLibrary.simpleMessage("Nastavit heslo"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Heslo bylo úspěšně nastaveno"),
        "setPin": MessageLookupByLibrary.simpleMessage("Estableix el Pin"),
        "setPinSuccess": MessageLookupByLibrary.simpleMessage(
            "El pin s\'ha establert correctament"),
        "setPlausibleDeniabilityPin":
            MessageLookupByLibrary.simpleMessage("Estableix un pin plausible"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Nastavit heslo peněženky"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Nastavení"),
        "settingsTransfer":
            MessageLookupByLibrary.simpleMessage("Načíst z papírové penězenky"),
        "share": MessageLookupByLibrary.simpleMessage("Compartir"),
        "shareLink": MessageLookupByLibrary.simpleMessage("Share Link"),
        "shareMessage":
            MessageLookupByLibrary.simpleMessage("Comparteix missatge"),
        "shareNautilus":
            MessageLookupByLibrary.simpleMessage("Sdílet Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Vyzkoušejte Nautilus! Špičková mobilní peněženka NANO!"),
        "shareText": MessageLookupByLibrary.simpleMessage("Comparteix el text"),
        "show": MessageLookupByLibrary.simpleMessage("Espectacle"),
        "showAccountInfo":
            MessageLookupByLibrary.simpleMessage("Informació del compte"),
        "showAccountQR": MessageLookupByLibrary.simpleMessage(
            "Mostra el codi QR del compte"),
        "showContacts": MessageLookupByLibrary.simpleMessage("Show Contacts"),
        "showFunding": MessageLookupByLibrary.simpleMessage(
            "Mostra el bàner de finançament"),
        "showLinkOptions": MessageLookupByLibrary.simpleMessage(
            "Mostra les opcions d\'enllaç"),
        "showLinkQR":
            MessageLookupByLibrary.simpleMessage("Mostra l\'enllaç QR"),
        "showMoneroHeader": MessageLookupByLibrary.simpleMessage(""),
        "showMoneroInfo": MessageLookupByLibrary.simpleMessage(""),
        "showQR": MessageLookupByLibrary.simpleMessage("Mostra el codi QR"),
        "showUnopenedWarning":
            MessageLookupByLibrary.simpleMessage("Avís sense obrir"),
        "simplex": MessageLookupByLibrary.simpleMessage("Simplex"),
        "social": MessageLookupByLibrary.simpleMessage("Social"),
        "someone": MessageLookupByLibrary.simpleMessage("algú"),
        "spendNano": MessageLookupByLibrary.simpleMessage("Gasta NANO"),
        "splitBill": MessageLookupByLibrary.simpleMessage("Bill dividit"),
        "splitBillHeader":
            MessageLookupByLibrary.simpleMessage("Dividir una factura"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "Envieu un munt de sol·licituds de pagament alhora! Per exemple, facilita el repartiment d\'una factura en un restaurant."),
        "splitBillInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Informació de factura dividida"),
        "splitBy": MessageLookupByLibrary.simpleMessage("Dividit per"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment":
            MessageLookupByLibrary.simpleMessage("Ajuda al desenvolupament"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Support the Developer"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("Canvia XMR"),
        "swapXMRHeader": MessageLookupByLibrary.simpleMessage("Canvia Monero"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "Monero és una criptomoneda centrada en la privadesa que fa que sigui molt difícil o fins i tot impossible rastrejar les transaccions. Mentrestant, NANO és una criptomoneda centrada en els pagaments que és ràpida i sense comissions. Junts proporcionen alguns dels aspectes més útils de les criptomonedes!\n\nUtilitzeu aquesta pàgina per canviar fàcilment el vostre NANO per XMR!"),
        "swapping": MessageLookupByLibrary.simpleMessage("Canvi"),
        "switchToSeed":
            MessageLookupByLibrary.simpleMessage("Přepnout na semínko"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("Výchozí systému"),
        "tapMessageToEdit":
            MessageLookupByLibrary.simpleMessage("Toca el missatge per editar"),
        "tapToHide": MessageLookupByLibrary.simpleMessage("Klepnutím skryjete"),
        "tapToReveal":
            MessageLookupByLibrary.simpleMessage("Klikněte pro zobrazení"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Tématika"),
        "to": MessageLookupByLibrary.simpleMessage("Pro"),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "Příliš mnoho neúspěšných pokusů o odemknutí."),
        "transactions": MessageLookupByLibrary.simpleMessage("Transakce"),
        "transfer": MessageLookupByLibrary.simpleMessage("Převod"),
        "transferClose": MessageLookupByLibrary.simpleMessage(
            "Klepnutím kamkoli zavřete okno."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO úspěšně převedeno do vaší peněženky Nautilus. \n"),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "Byla nalezena peněženka se zůstatkem %1 NANO. \n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "Prostředky převedete klepnutím na potvrzení. \n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "Dokončení přenosu může trvat několik sekund."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "Během přenosu došlo k chybě. Prosím zkuste to znovu později."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Převést finanční prostředky"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "Tento proces přenese prostředky z papírové peněženky do vaší peněženky Nautilus. \n\n Začněte klepnutím na tlačítko \"% 1\"."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "This process will transfer the funds from a paper wallet to your Nautilus wallet."),
        "transferLoading": MessageLookupByLibrary.simpleMessage("Přenáší se"),
        "transferManualHint":
            MessageLookupByLibrary.simpleMessage("Zadejte semínko níže."),
        "transferNoFunds": MessageLookupByLibrary.simpleMessage(
            "Toto semínko nemá na sobě žádné NANO"),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "Tento QR kód neobsahuje platné semínko."),
        "transferQrScanHint": MessageLookupByLibrary.simpleMessage(
            "Naskenujte počáteční \n nebo soukromý klíč Nano"),
        "unacknowledged":
            MessageLookupByLibrary.simpleMessage("unacknowledged"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("nepotvrzený"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("unfulfilled"),
        "unlock": MessageLookupByLibrary.simpleMessage("Odemknout"),
        "unlockBiometrics":
            MessageLookupByLibrary.simpleMessage("Ověřte a odemkněte Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Zadejte PIN pro odemčení Natria"),
        "unopenedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Mostra un avís sense obrir"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "Mostra un avís quan envieu fons a un compte sense obrir, això és útil perquè la majoria de vegades les adreces a les quals envieu tindran un saldo, i l\'enviament a una adreça nova pot ser el resultat d\'un error ortogràfic."),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "Esteu segur que aquesta és l\'adreça correcta?\nSembla que aquest compte no està obert\n\nPodeu desactivar aquest avís al calaix de configuració a \"Avís sense obrir\"."),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("Compte sense obrir"),
        "unpaid": MessageLookupByLibrary.simpleMessage("unpaid"),
        "unread": MessageLookupByLibrary.simpleMessage("unread"),
        "uptime": MessageLookupByLibrary.simpleMessage("Provozuschopnost"),
        "useNano": MessageLookupByLibrary.simpleMessage("Utilitzeu NANO"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userAlreadyAddedError":
            MessageLookupByLibrary.simpleMessage("Usuari ja afegit!"),
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
        "using": MessageLookupByLibrary.simpleMessage("Utilitzant"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("Zobrazit detaily"),
        "viewTX":
            MessageLookupByLibrary.simpleMessage("Visualitza la transacció"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("Hlasovací síla"),
        "warning": MessageLookupByLibrary.simpleMessage("Varování"),
        "watchAccountExists":
            MessageLookupByLibrary.simpleMessage("Compte ja afegit!"),
        "watchOnlyAccount": MessageLookupByLibrary.simpleMessage(
            "Compte de només visualització"),
        "watchOnlySendDisabled": MessageLookupByLibrary.simpleMessage(
            "Els enviaments estan desactivats a les adreces només de rellotge"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Vítejte v Nautilus. Nejprve můžete vytvořit novou peněženku nebo importovat stávající."),
        "welcomeTextUpdated": MessageLookupByLibrary.simpleMessage(
            "Benvingut a Nautilus. Per començar, creeu una cartera nova o importeu-ne una existent."),
        "withAddress": MessageLookupByLibrary.simpleMessage("With Address"),
        "withMessage": MessageLookupByLibrary.simpleMessage("With Message"),
        "xMinute": MessageLookupByLibrary.simpleMessage("Po %1 minutě"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("Po %1 minutách"),
        "xmrStatusConnecting":
            MessageLookupByLibrary.simpleMessage("Connectant"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("Error"),
        "xmrStatusLoading": MessageLookupByLibrary.simpleMessage("Carregant"),
        "xmrStatusSynchronized":
            MessageLookupByLibrary.simpleMessage("Sincronitzat"),
        "xmrStatusSynchronizing":
            MessageLookupByLibrary.simpleMessage("Sincronització"),
        "yes": MessageLookupByLibrary.simpleMessage("Ano"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Ano")
      };
}
