// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a no locale. All the
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
  String get localeName => 'no';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Konto"),
        "accountNameHint":
            MessageLookupByLibrary.simpleMessage("Skriv inn et navn"),
        "accountNameMissing":
            MessageLookupByLibrary.simpleMessage("Velg et kontonavn"),
        "accounts": MessageLookupByLibrary.simpleMessage("Kontoer"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at du har sikkerhetskopiert din Tilknytningskode eller Seed?"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Aktiv melding"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Legg til konto"),
        "addAddress":
            MessageLookupByLibrary.simpleMessage("Legg til en adresse"),
        "addBlocked":
            MessageLookupByLibrary.simpleMessage("Blokkere en bruker"),
        "addContact": MessageLookupByLibrary.simpleMessage("Legg til kontakt"),
        "addFavorite":
            MessageLookupByLibrary.simpleMessage("Legg til favoritt"),
        "addNode": MessageLookupByLibrary.simpleMessage("Legg til node"),
        "addUser": MessageLookupByLibrary.simpleMessage("Legg til en bruker"),
        "addWatchOnlyAccount": MessageLookupByLibrary.simpleMessage(
            "Legg til kun overvåkningskonto"),
        "addWatchOnlyAccountError": MessageLookupByLibrary.simpleMessage(
            "Feil ved å legge til kun overvåkningskonto: Kontoen var null"),
        "addWatchOnlyAccountSuccess": MessageLookupByLibrary.simpleMessage(
            "Vellykket opprettet klokkekonto!"),
        "address": MessageLookupByLibrary.simpleMessage("Adresse"),
        "addressCopied":
            MessageLookupByLibrary.simpleMessage("Adresse kopiert"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Angi adresse"),
        "addressMissing":
            MessageLookupByLibrary.simpleMessage("Vennligst angi en adresse"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Skriv inn et brukernavn eller adresse"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Del adresse"),
        "aliases": MessageLookupByLibrary.simpleMessage("Aliaser"),
        "amountGiftGreaterError": MessageLookupByLibrary.simpleMessage(
            "Delt beløp kan ikke være større enn gavesaldoen"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Vennligst tast inn et beløp"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "Vi la merke til at du klikket på en lenke som inneholder noe nano, vil du hoppe over konfigurasjonsprosessen? Du kan alltid endre ting senere.\n\n Hvis du imidlertid har et eksisterende frø som du vil importere, bør du velge nei."),
        "askTracking": MessageLookupByLibrary.simpleMessage(
            "Vi er i ferd med å be om \"sporing\"-tillatelsen, denne brukes *strengt* for å tilskrive lenker/henvisninger, og mindre analyser (ting som antall installasjoner, hvilken appversjon osv.) Vi mener at du har rett til personvernet ditt og ikke er interessert i noen av dine personlige data, trenger vi bare tillatelsen for at lenketilordninger skal fungere korrekt."),
        "asked": MessageLookupByLibrary.simpleMessage("spurte"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("Autentiserer"),
        "authError": MessageLookupByLibrary.simpleMessage(
            "Det oppsto en feil under autentisering. Prøv igjen senere."),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Godkjennelsesmetode"),
        "authenticating": MessageLookupByLibrary.simpleMessage("Autentiserer"),
        "autoImport": MessageLookupByLibrary.simpleMessage("Automatisk import"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Lås automatisk"),
        "autoRenewSub": MessageLookupByLibrary.simpleMessage(
            "Automatisk fornyelse av abonnement"),
        "backupConfirmButton": MessageLookupByLibrary.simpleMessage(
            "Jeg har laget en sikkerhetskopi"),
        "backupSecretPhrase": MessageLookupByLibrary.simpleMessage(
            "Sikkerhetskopier Tilknytningskode"),
        "backupSeed":
            MessageLookupByLibrary.simpleMessage("Sikkerhetskopier Seed"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at du har sikkerhetskopiert lommebokens Seed?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Lag sikkerhetskopi av Seed"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Biometri"),
        "blockExplorer":
            MessageLookupByLibrary.simpleMessage("Blokker Explorer"),
        "blockExplorerHeader":
            MessageLookupByLibrary.simpleMessage("Blokker Explorer"),
        "blockExplorerInfo": MessageLookupByLibrary.simpleMessage(
            "Hvilken blokkutforsker som skal brukes til å vise transaksjonsinformasjon"),
        "blockUser":
            MessageLookupByLibrary.simpleMessage("Blokker denne brukeren"),
        "blockedAdded": MessageLookupByLibrary.simpleMessage("%1 er blokkert."),
        "blockedExists":
            MessageLookupByLibrary.simpleMessage("Bruker allerede blokkert!"),
        "blockedHeader": MessageLookupByLibrary.simpleMessage("blokkert"),
        "blockedInfo": MessageLookupByLibrary.simpleMessage(
            "Blokker en bruker med et hvilket som helst kjent alias eller adresse. Eventuelle meldinger, transaksjoner eller forespørsler fra dem vil bli ignorert."),
        "blockedInfoHeader":
            MessageLookupByLibrary.simpleMessage("Blokkert info"),
        "blockedNameExists":
            MessageLookupByLibrary.simpleMessage("Kallenavn allerede brukt!"),
        "blockedNameMissing":
            MessageLookupByLibrary.simpleMessage("Velg et kallenavn"),
        "blockedRemoved":
            MessageLookupByLibrary.simpleMessage("%1 har blitt blokkert!"),
        "branchConnectErrorLongDesc": MessageLookupByLibrary.simpleMessage(
            "Det ser ikke ut til at vi kan nå Branch API, dette er vanligvis forårsaket av et slags nettverksproblem eller VPN som blokkerer tilkoblingen.\n\n Du skal fortsatt kunne bruke appen som normalt, men sending og mottak av gavekort fungerer kanskje ikke."),
        "branchConnectErrorShortDesc": MessageLookupByLibrary.simpleMessage(
            "Feil: kan ikke nå Branch API"),
        "branchConnectErrorTitle":
            MessageLookupByLibrary.simpleMessage("Advarsel om tilkobling"),
        "businessButton": MessageLookupByLibrary.simpleMessage("Virksomhet"),
        "cancel": MessageLookupByLibrary.simpleMessage("Avbryt"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("Captcha"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "For å forhindre misbruk krever vi at du løser en captcha for å kunne kreve gavekortet på neste side."),
        "changeCurrency": MessageLookupByLibrary.simpleMessage("Endre valuta"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Endre logg"),
        "changeNode": MessageLookupByLibrary.simpleMessage("Endre node"),
        "changePassword": MessageLookupByLibrary.simpleMessage("Bytt passord"),
        "changePasswordParagraph": MessageLookupByLibrary.simpleMessage(
            "Endre ditt eksisterende passord. Hvis du ikke kjenner det nåværende passordet ditt, gjør du bare din beste gjetning ettersom det faktisk ikke er nødvendig å endre det (siden du allerede er logget på), men det lar oss slette den eksisterende sikkerhetskopioppføringen."),
        "changePin": MessageLookupByLibrary.simpleMessage("Bytt pinne"),
        "changePinHint": MessageLookupByLibrary.simpleMessage("Sett pinne"),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Endre representant"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Endre"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Angi ny representant."),
        "changeRepSame": MessageLookupByLibrary.simpleMessage(
            "Dette er allerede din representant!"),
        "changeRepSucces":
            MessageLookupByLibrary.simpleMessage("Representant endret"),
        "changeSeed": MessageLookupByLibrary.simpleMessage("Bytt frø"),
        "changeSeedParagraph": MessageLookupByLibrary.simpleMessage(
            "Endre frøet/frasen som er knyttet til denne magiske lenken godkjente kontoen, uansett passord du angir her vil overskrive det eksisterende passordet ditt, men du kan bruke det samme passordet hvis du velger det."),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Sjekk tilgjengelighet"),
        "close": MessageLookupByLibrary.simpleMessage("Lukk"),
        "confirm": MessageLookupByLibrary.simpleMessage("Bekreft"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Bekreft passordet"),
        "confirmPinHint":
            MessageLookupByLibrary.simpleMessage("Bekreft pinnen"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Kobler til"),
        "connectionWarning":
            MessageLookupByLibrary.simpleMessage("Kan ikke koble til"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "Det ser ikke ut til at vi kan koble til backend, dette kan bare være tilkoblingen din, eller hvis problemet vedvarer, kan backend være nede for vedlikehold eller til og med et strømbrudd. Hvis det har gått mer enn en time og du fortsatt har problemer, vennligst send en rapport i #bug-reports på discord-serveren @ chat.perish.co"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Det ser ikke ut til at vi kan koble til backend, dette kan bare være tilkoblingen din, eller hvis problemet vedvarer, kan backend være nede for vedlikehold eller til og med et strømbrudd. Hvis det har gått mer enn en time og du fortsatt har problemer, vennligst send en rapport i #bug-reports på discord-serveren @ chat.perish.co"),
        "connectionWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Det ser ikke ut til at vi kan koble til backend"),
        "contactAdded":
            MessageLookupByLibrary.simpleMessage("%1 er lagt til i kontakter."),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Kontakt eksisterer allerede"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Kontakt"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Ugyldig kontaktnavn"),
        "contactNameHint": MessageLookupByLibrary.simpleMessage("Angi navn @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Velg et navn til denne kontakten"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 har blitt fjernet fra kontakter!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Kontakter"),
        "contactsImportErr": MessageLookupByLibrary.simpleMessage(
            "Kunne ikke importere kontakter"),
        "contactsImportSuccess":
            MessageLookupByLibrary.simpleMessage("%1 kontakter importert."),
        "continueButton": MessageLookupByLibrary.simpleMessage("Fortsette"),
        "continueWithoutLogin":
            MessageLookupByLibrary.simpleMessage("Fortsett uten pålogging"),
        "copied": MessageLookupByLibrary.simpleMessage("Kopiert"),
        "copy": MessageLookupByLibrary.simpleMessage("Kopier"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Kopier adresse"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Kopier lenke"),
        "copyMessage": MessageLookupByLibrary.simpleMessage("Kopier melding"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Kopier Seed"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Kopier lommebokadresse til utklippstavlen"),
        "copyXMRSeed":
            MessageLookupByLibrary.simpleMessage("Kopier Monero Seed"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Lag et passord."),
        "createGiftCard": MessageLookupByLibrary.simpleMessage("Lag gavekort"),
        "createGiftHeader":
            MessageLookupByLibrary.simpleMessage("Lag et gavekort"),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "Du kan opprette et passord for ekstra sikkerhet til din lommebok."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Lag et passord"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "Passord er valgfritt, og din lommebok vil uansett være beskyttet med din PIN-kode eller biometri."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Opprett"),
        "createPinHint": MessageLookupByLibrary.simpleMessage("Lag en nål"),
        "createQR": MessageLookupByLibrary.simpleMessage("Opprett QR-kode"),
        "created": MessageLookupByLibrary.simpleMessage("opprettet"),
        "creatingGiftCard":
            MessageLookupByLibrary.simpleMessage("Opprette gavekort"),
        "currency": MessageLookupByLibrary.simpleMessage("Valuta"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Valuta-modus"),
        "currencyModeHeader":
            MessageLookupByLibrary.simpleMessage("Valuta Mode Info"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Velg hvilken enhet du vil vise beløp i.\n1 nyano = 0.000001 NANO, eller \n1 000,000 nyano = 1 NANO"),
        "currentlyRepresented":
            MessageLookupByLibrary.simpleMessage("Aktuell representant"),
        "dayAgo": MessageLookupByLibrary.simpleMessage("En dag siden"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Dekryptering Feil!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Hovedkonto"),
        "defaultGiftMessage": MessageLookupByLibrary.simpleMessage(
            "Sjekk ut Nautilus! Jeg sendte deg litt nano med denne linken:"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Konto %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Slett"),
        "deleteNodeConfirmation": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at du vil slette denne noden?\n\nDu kan alltid legge den til på nytt senere ved å trykke på \"Legg til node\"-knappen"),
        "deleteNodeHeader": MessageLookupByLibrary.simpleMessage("Slett node?"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Deaktiver"),
        "disablePasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Passordet har blitt deaktivert"),
        "disableWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Deaktiver lommebokens passord"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Avvis"),
        "doYouHaveSeedBody": MessageLookupByLibrary.simpleMessage(
            "Hvis du ikke er sikker på hva dette betyr, har du sannsynligvis ikke et frø å importere og kan bare trykke fortsett."),
        "doYouHaveSeedHeader":
            MessageLookupByLibrary.simpleMessage("Har du et frø å importere?"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Ugyldig domenenavn"),
        "donateButton": MessageLookupByLibrary.simpleMessage("Donere"),
        "donateToSupport":
            MessageLookupByLibrary.simpleMessage("Støtt prosjektet"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "enableNotifications":
            MessageLookupByLibrary.simpleMessage("Aktiver varsler"),
        "enableTracking":
            MessageLookupByLibrary.simpleMessage("Aktiver sporing"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Kunne ikke velge lommebokens passord"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("Angi adresse"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Tast inn beløp"),
        "enterEmail": MessageLookupByLibrary.simpleMessage("Skriv inn e-post"),
        "enterGiftMemo":
            MessageLookupByLibrary.simpleMessage("Skriv inn gavebrev"),
        "enterHeight": MessageLookupByLibrary.simpleMessage("Skriv inn Høyde"),
        "enterHttpUrl":
            MessageLookupByLibrary.simpleMessage("Skriv inn HTTP URL"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("Skriv inn melding"),
        "enterMoneroAddress":
            MessageLookupByLibrary.simpleMessage("Skriv inn XMR-adresse"),
        "enterNodeName":
            MessageLookupByLibrary.simpleMessage("Skriv inn nodenavn"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Tast inn ditt passord"),
        "enterSplitAmount":
            MessageLookupByLibrary.simpleMessage("Angi delt beløp"),
        "enterUserOrAddress": MessageLookupByLibrary.simpleMessage(
            "Skriv inn bruker eller adresse"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Skriv inn et brukernavn"),
        "enterWsUrl":
            MessageLookupByLibrary.simpleMessage("Skriv inn WebSocket URL"),
        "errorProcessingGiftCard": MessageLookupByLibrary.simpleMessage(
            "Det oppsto en feil under behandlingen av dette gavekortet. Det kan være at det ikke er gyldig, utløpt eller tomt."),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom":
            MessageLookupByLibrary.simpleMessage("Fra en tilfeldig"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Velkommen til Nautilus. Når du mottar NANO, vil transaksjonene vises slik:"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Litt"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Mange"),
        "exampleCardTo":
            MessageLookupByLibrary.simpleMessage("Til en tilfeldig"),
        "examplePayRecipient": MessageLookupByLibrary.simpleMessage("@dad"),
        "examplePayRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Gratulerer med dagen!"),
        "examplePaymentExplainer": MessageLookupByLibrary.simpleMessage(
            "Når du har sendt eller mottatt en betalingsforespørsel, de vil dukke opp her slik med fargen og koden på kortet som indikerer statusen. \n\nGrønt indikerer at forespørselen er betalt.\nGul indikerer at forespørselen/notatet ikke er betalt/lest.\nRød indikerer at forespørselen ikke er lest eller mottatt.\n\n Nøytrale fargede kort uten beløp er bare meldinger."),
        "examplePaymentFrom": MessageLookupByLibrary.simpleMessage("@landlord"),
        "examplePaymentFulfilled": MessageLookupByLibrary.simpleMessage("Noen"),
        "examplePaymentFulfilledMemo":
            MessageLookupByLibrary.simpleMessage("Sushi"),
        "examplePaymentIntro": MessageLookupByLibrary.simpleMessage(
            "Når du har sendt eller mottatt en betalingsforespørsel, vises de her:"),
        "examplePaymentMessage":
            MessageLookupByLibrary.simpleMessage("Hei, hva skjer?"),
        "examplePaymentReceivable": MessageLookupByLibrary.simpleMessage("Mye"),
        "examplePaymentReceivableMemo":
            MessageLookupByLibrary.simpleMessage("Leie"),
        "examplePaymentTo":
            MessageLookupByLibrary.simpleMessage("@best_friend"),
        "exampleRecRecipient":
            MessageLookupByLibrary.simpleMessage("@coworker"),
        "exampleRecRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Gass Penger"),
        "exchangeNano": MessageLookupByLibrary.simpleMessage("Bytt NANO"),
        "existingPasswordHint":
            MessageLookupByLibrary.simpleMessage("Skriv inn nåværende passord"),
        "existingPinHint":
            MessageLookupByLibrary.simpleMessage("Skriv inn gjeldende pin"),
        "exit": MessageLookupByLibrary.simpleMessage("Avslutt"),
        "exportTXData":
            MessageLookupByLibrary.simpleMessage("Eksporter transaksjoner"),
        "failed": MessageLookupByLibrary.simpleMessage("mislyktes"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader":
            MessageLookupByLibrary.simpleMessage("Nautilus frakoblet"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "Nautilus-servere ser ut til å være frakoblet, Sending og mottak (uten notater) skal fortsatt være i drift, men betalingsforespørsler kan ikke gå gjennom\n\n Kom tilbake senere eller start appen på nytt for å prøve igjen"),
        "favoriteExists":
            MessageLookupByLibrary.simpleMessage("Favoritt eksisterer"),
        "favoriteHeader": MessageLookupByLibrary.simpleMessage("favoritt"),
        "favoriteInvalid":
            MessageLookupByLibrary.simpleMessage("Ugyldig favorittnavn"),
        "favoriteNameHint":
            MessageLookupByLibrary.simpleMessage("Skriv inn et kallenavn"),
        "favoriteNameMissing": MessageLookupByLibrary.simpleMessage(
            "Velg et navn for denne favoritten"),
        "favoriteRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 er fjernet fra favoritter!"),
        "favoritesHeader": MessageLookupByLibrary.simpleMessage("favoritter"),
        "featured": MessageLookupByLibrary.simpleMessage("Utvalgte"),
        "fewDaysAgo":
            MessageLookupByLibrary.simpleMessage("For noen dager siden"),
        "fewHoursAgo":
            MessageLookupByLibrary.simpleMessage("For noen timer siden"),
        "fewMinutesAgo":
            MessageLookupByLibrary.simpleMessage("Noen minutter siden"),
        "fewSecondsAgo":
            MessageLookupByLibrary.simpleMessage("Noen få sekunder siden"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Verifiser for å sikkerhetskopiere Seed."),
        "from": MessageLookupByLibrary.simpleMessage("Fra"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("oppfylt"),
        "fundingBannerHeader":
            MessageLookupByLibrary.simpleMessage("Finansieringsbanner"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("Finansiering"),
        "getNano": MessageLookupByLibrary.simpleMessage("Skaff deg NANO"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("Du har en gave!"),
        "giftAlertEmpty": MessageLookupByLibrary.simpleMessage("Tom gave"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("Gavebeløp"),
        "giftCardCreationError": MessageLookupByLibrary.simpleMessage(
            "Det oppstod en feil under forsøk på å opprette en gavekortkobling"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "Det oppstod en feil under forsøk på å opprette et gavekort, GAVEKORT-LINKEN ELLER SEEDEN HAR BLITT KOPIERT TIL UTKLIPPTAVLEN DIN, DINE MIDLER KAN INNHOLDES I DET, AVHENGIG AV HVA GIKK FEIL."),
        "giftCardInfoHeader":
            MessageLookupByLibrary.simpleMessage("Gaveark info"),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Gave fra"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Last inn et digitalt gavekort med NANO! Angi et beløp, og en valgfri melding for mottakeren å se når de åpner den!\n\nNår du er opprettet, får du en lenke som du kan sende til hvem som helst, som når den åpnes automatisk vil distribuere midlene til mottakeren etter installasjon av Nautilus!\n\nHvis mottakeren allerede er en Nautilus-bruker, vil de få beskjed om å overføre midlene til kontoen sin når lenken åpnes"),
        "giftMessage": MessageLookupByLibrary.simpleMessage("Gave Melding"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "Det oppsto en feil under behandlingen av dette gavekortet. Sjekk kanskje tilkoblingen din og prøv å klikke på gavelenken igjen."),
        "giftProcessSuccess": MessageLookupByLibrary.simpleMessage(
            "Gaven er mottatt, det kan ta et øyeblikk før den vises i lommeboken din."),
        "giftRefundSuccess":
            MessageLookupByLibrary.simpleMessage("Gaven ble refundert!"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Gå tilbake"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Gå til QR"),
        "gotItButton":
            MessageLookupByLibrary.simpleMessage("Jeg har forstått!"),
        "handoff": MessageLookupByLibrary.simpleMessage("overrekke"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage(
            "Noe gikk galt under forsøk på å overføre blokkering!"),
        "handoffSupportedMethodNotFound": MessageLookupByLibrary.simpleMessage(
            "En støttet overleveringsmetode ble ikke funnet!"),
        "haveSeedToImport":
            MessageLookupByLibrary.simpleMessage("Jeg har et frø"),
        "hide": MessageLookupByLibrary.simpleMessage("Skjul"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Skjul konto?"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at du vil skjule tomme kontoer?\n\nDette vil skjule alle kontoer med en saldo på nøyaktig 0 (unntatt overvåkningsadresser og hovedkontoen din), men du kan alltid legge dem til på nytt senere ved å trykke på \"Legg til konto\"-knappen"),
        "hideAccountsHeader":
            MessageLookupByLibrary.simpleMessage("Vil du skjule kontoer?"),
        "hideEmptyAccounts":
            MessageLookupByLibrary.simpleMessage("Skjul tomme kontoer"),
        "home": MessageLookupByLibrary.simpleMessage("Hjem"),
        "homeButton": MessageLookupByLibrary.simpleMessage("Hjem"),
        "hourAgo": MessageLookupByLibrary.simpleMessage("En time siden"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("Jeg forstår risikoene"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignorer"),
        "imSure": MessageLookupByLibrary.simpleMessage("Jeg er sikker"),
        "import": MessageLookupByLibrary.simpleMessage("Importer"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "Koblingen du klikket inneholder noe nano, vil du importere den til denne lommeboken, eller refunder den til den som sendte den?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "Det ser ut til at du har klikket på en lenke som inneholder noe NANO, for å motta disse midlene trenger vi bare at du fullfører konfigureringen av lommeboken din."),
        "importGiftv2": MessageLookupByLibrary.simpleMessage(
            "Linken du klikket inneholder noe NANO, vil du importere det til denne lommeboken?"),
        "importHD": MessageLookupByLibrary.simpleMessage("Importer HD"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Importer tilknytningkode"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Vennligst angi din 24-ords tilknytningskode nedenfor. Hvert ord skal være adskilt med et mellomrom."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Importer Seed"),
        "importSeedHint":
            MessageLookupByLibrary.simpleMessage("Angi Seed nedenfor"),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Importer Seed i stedet"),
        "importStandard":
            MessageLookupByLibrary.simpleMessage("Importstandard"),
        "importWallet":
            MessageLookupByLibrary.simpleMessage("Importer lommebok"),
        "instantly": MessageLookupByLibrary.simpleMessage("Øyeblikkelig"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Saldo er utilstrekkelig"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "Vi hoppet over introduksjonsprosessen for å spare tid, men du bør ta backup av det nyopprettede frøet ditt umiddelbart.\n\nHvis du mister frøet ditt, mister du tilgang til midlene dine.\n\nI tillegg er passordet ditt satt til \"000000\", som du også bør endre umiddelbart."),
        "introSkippedWarningHeader": MessageLookupByLibrary.simpleMessage(
            "Ta sikkerhetskopi av frøet ditt!"),
        "invalidAddress": MessageLookupByLibrary.simpleMessage(
            "Den angitte adressen er ugyldig"),
        "invalidHeight": MessageLookupByLibrary.simpleMessage("Ugyldig høyde"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Ugyldig passord"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("Ugyldig PIN-kode"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "På grunn av iOS App Store retningslinjer og begrensninger, kan vi ikke koble deg til donasjonssiden vår. Hvis du ønsker å støtte prosjektet, vurder å sende til nautilus-nodens adresse."),
        "language": MessageLookupByLibrary.simpleMessage("Språk"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("Kopiert kobling"),
        "loaded": MessageLookupByLibrary.simpleMessage("lastet"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Lastet inn"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Verifiser ved oppstart"),
        "locked": MessageLookupByLibrary.simpleMessage("Låst"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Logg Inn"),
        "loginOrRegisterHeader": MessageLookupByLibrary.simpleMessage(
            "Logg inn eller registrer deg"),
        "logout": MessageLookupByLibrary.simpleMessage("Logg ut"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Slett Seed og logg ut"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Er du sikker?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Når du logger ut fjernes ditt Seed og all Nautilus-relatert data fra denne enheten. Om ditt Seed ikke er sikkerhetskopiert, vil du aldri kunne få tilgang til dine midler igjen"),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Så lenge du har sikkerhetskopiert ditt Seed, har du ingenting å bekymre deg over."),
        "looksLikeHdSeed": MessageLookupByLibrary.simpleMessage(
            "Dette ser ut til å være et HD-frø, med mindre du er sikker på at du vet hva du gjør, bør du bruke alternativet \"Importer HD\" i stedet."),
        "looksLikeStandardSeed": MessageLookupByLibrary.simpleMessage(
            "Dette ser ut til å være et standard frø, du bør bruke alternativet \"Import standard\" i stedet."),
        "manage": MessageLookupByLibrary.simpleMessage("Administrer"),
        "mantaError": MessageLookupByLibrary.simpleMessage(
            "Kunne ikke bekrefte forespørsel"),
        "manualEntry":
            MessageLookupByLibrary.simpleMessage("Manuell inntasting"),
        "markAsPaid": MessageLookupByLibrary.simpleMessage("Merk som betalt"),
        "markAsUnpaid":
            MessageLookupByLibrary.simpleMessage("Merk som ubetalt"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Memo sendt på nytt! Hvis det fortsatt ikke er godkjent, kan mottakerens enhet være frakoblet."),
        "messageCopied":
            MessageLookupByLibrary.simpleMessage("Melding kopiert"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Melding"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "Minste overførselsbeløp er %1 NANO"),
        "minuteAgo":
            MessageLookupByLibrary.simpleMessage("For et minutt siden"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 er ikke et gyldig ord"),
        "mnemonicPhrase":
            MessageLookupByLibrary.simpleMessage("Mnemonisk frase"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Tilknytningskode kan kun inneholde 24 ord"),
        "monthlyServerCosts":
            MessageLookupByLibrary.simpleMessage("Månedlige serverkostnader"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings":
            MessageLookupByLibrary.simpleMessage("Flere innstillinger"),
        "nameEmpty":
            MessageLookupByLibrary.simpleMessage("Vennligst skriv inn et navn"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "nautilusWallet":
            MessageLookupByLibrary.simpleMessage("Nautilus lommebok"),
        "nearby": MessageLookupByLibrary.simpleMessage("I nærheten"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "Denne funksjonen krever at du har en lengre transaksjonshistorikk for å forhindre spam.\n\nAlternativt kan du vise en QR-kode for noen å skanne."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Bekreftelse nødvendig"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Dette er din nye konto. Når du mottar NANO vises transaksjoner slik:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Ny lommebok"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Neste"),
        "no": MessageLookupByLibrary.simpleMessage("Nei"),
        "noContactsExport": MessageLookupByLibrary.simpleMessage(
            "Det er ingen kontakter å eksportere."),
        "noContactsImport": MessageLookupByLibrary.simpleMessage(
            "Ingen nye kontakter å importere."),
        "noSearchResults":
            MessageLookupByLibrary.simpleMessage("Ingen søkeresultater!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("Nei, hopp over"),
        "noTXDataExport": MessageLookupByLibrary.simpleMessage(
            "Det er ingen transaksjoner å eksportere."),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "node": MessageLookupByLibrary.simpleMessage("Node"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("Node Status"),
        "nodes": MessageLookupByLibrary.simpleMessage("Noder"),
        "noneMethod": MessageLookupByLibrary.simpleMessage("Ingen"),
        "notSent": MessageLookupByLibrary.simpleMessage("ikke sendt"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Åpne Nautilus for å vise denne transaksjonen"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Tap for å åpne"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "For at denne funksjonen skal fungere riktig, må varsler være aktivert"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("%1 NANO mottatt"),
        "notificationWarning":
            MessageLookupByLibrary.simpleMessage("Varsler deaktivert"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Alle betalingsforespørsler, notater og meldinger krever at varslinger er aktivert for å fungere som de skal, ettersom de bruker FCM-varslingstjenesten for å sikre meldingslevering.\n\nDu kan aktivere varsler med knappen nedenfor eller avvise dette kortet hvis du ikke bryr deg om å bruke disse funksjonene."),
        "notificationWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Betalingsforespørsler, notater og meldinger vil ikke fungere ordentlig."),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifikasjoner"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Nyanicon"),
        "obscureInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Uklar transaksjonsinformasjon"),
        "obscureTransaction":
            MessageLookupByLibrary.simpleMessage("Obskur transaksjon"),
        "obscureTransactionBody": MessageLookupByLibrary.simpleMessage(
            "Dette er IKKE ekte personvern, men det vil gjøre det vanskeligere for mottakeren å se hvem som har sendt dem penger."),
        "off": MessageLookupByLibrary.simpleMessage("Deaktiver"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "onStr": MessageLookupByLibrary.simpleMessage("Aktiver"),
        "onboard": MessageLookupByLibrary.simpleMessage("Inviter noen"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Onboarding"),
        "onramp": MessageLookupByLibrary.simpleMessage("Onramp"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Åpnet"),
        "paid": MessageLookupByLibrary.simpleMessage("betalt"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("Papirlommebok"),
        "passwordBlank": MessageLookupByLibrary.simpleMessage(
            "Passordet kan ikke være tomt"),
        "passwordCapitalLetter": MessageLookupByLibrary.simpleMessage(
            "Passordet må inneholde minst én stor og liten bokstav"),
        "passwordDisclaimer": MessageLookupByLibrary.simpleMessage(
            "Vi er ikke ansvarlige hvis du glemmer passordet ditt, og vi kan ikke tilbakestille eller endre det for deg."),
        "passwordIncorrect":
            MessageLookupByLibrary.simpleMessage("feil passord"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Du trenger ikke lenger et passord for å åpne Nautilus."),
        "passwordNumber": MessageLookupByLibrary.simpleMessage(
            "Passordet må inneholde minst ett tall"),
        "passwordSpecialCharacter": MessageLookupByLibrary.simpleMessage(
            "Passordet må inneholde minst 1 spesialtegn"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Passordet er for kort"),
        "passwordWarning": MessageLookupByLibrary.simpleMessage(
            "Dette passordet kreves for å åpne Nautilus."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Dette passordet vil være påkrevd for å åpne Nautilus."),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Passordene stemmer ikke overens"),
        "pay": MessageLookupByLibrary.simpleMessage("Betale"),
        "payRequest":
            MessageLookupByLibrary.simpleMessage("Betal denne forespørselen"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Noen har bedt om betaling fra deg! sjekk betalingssiden for mer info."),
        "payments": MessageLookupByLibrary.simpleMessage("Betalinger"),
        "pickFromList":
            MessageLookupByLibrary.simpleMessage("Velg en fra listen"),
        "pinBlank":
            MessageLookupByLibrary.simpleMessage("Pin kan ikke være tom"),
        "pinConfirmError": MessageLookupByLibrary.simpleMessage(
            "PIN-kodene stemmer ikke overens"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Bekreft din PIN-kode"),
        "pinCreateTitle": MessageLookupByLibrary.simpleMessage(
            "Opprett en 6-sifret PIN-kode"),
        "pinEnterTitle":
            MessageLookupByLibrary.simpleMessage("Tast inn PIN-kode"),
        "pinIncorrect": MessageLookupByLibrary.simpleMessage("Feil pin angitt"),
        "pinInvalid": MessageLookupByLibrary.simpleMessage(
            "Den inntastede PIN-koden er ugyldig"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN-kode"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "Angi PIN-kode for å endre representant."),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Angi PIN-kode for a sikkerhetskopiere Seed"),
        "pinsDontMatch":
            MessageLookupByLibrary.simpleMessage("Pinner stemmer ikke"),
        "plausibleDeniabilityParagraph": MessageLookupByLibrary.simpleMessage(
            "Dette er IKKE den samme pinnen du brukte til å lage lommeboken din. Trykk på info-knappen for mer informasjon."),
        "plausibleInfoHeader":
            MessageLookupByLibrary.simpleMessage("Plausible Deniability Info"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Angi en sekundær pinne for plausible deniability-modus.\n\nHvis lommeboken din låses opp med denne sekundære pinnen, vil frøet ditt bli erstattet med en hash av det eksisterende frøet. Dette er en sikkerhetsfunksjon som skal brukes i tilfelle du blir tvunget til å åpne lommeboken.\n\nDenne pinnen vil fungere som en vanlig (riktig) pin, UNNTATT når du låser opp lommeboken din, som er når modusen for plausibel benektelse vil aktiveres.\n\nDine midler VIL GÅ TAP når du går inn i plausible deniability-modus hvis du ikke har sikkerhetskopiert frøet ditt!"),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferanser"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Personvernpolicy"),
        "proSubRequiredHeader": MessageLookupByLibrary.simpleMessage(
            "Nautilus Pro-abonnement kreves"),
        "proSubRequiredParagraph": MessageLookupByLibrary.simpleMessage(
            "For bare 1 NANO per måned kan du låse opp alle funksjonene til Nautilus Pro."),
        "promotionalLink": MessageLookupByLibrary.simpleMessage("Gratis NANO"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Kjøp Nano"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR-koden inneholder ikke en gyldig adresse"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Gi kameratillatelse for å scanne QR-koder"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "QR-koden inneholder ikke et gyldig Seed eller privat nøkkel"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "QR-kode inneholder ikke en gyldig tilknytningskode"),
        "qrUnknownError":
            MessageLookupByLibrary.simpleMessage("Kunne ikke lese QR-kode"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp": MessageLookupByLibrary.simpleMessage("Vurder appen"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn\'t take more than a minute."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Seed"),
        "readMore": MessageLookupByLibrary.simpleMessage("Les mer"),
        "receivable": MessageLookupByLibrary.simpleMessage("fordring"),
        "receive": MessageLookupByLibrary.simpleMessage("Motta"),
        "receiveMinimum": MessageLookupByLibrary.simpleMessage("Motta Minimum"),
        "receiveMinimumHeader":
            MessageLookupByLibrary.simpleMessage("Motta Minimum Info"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "Et minimumsbeløp å motta. Hvis en betaling eller forespørsel mottas med et beløp mindre enn dette, det vil bli ignorert."),
        "received": MessageLookupByLibrary.simpleMessage("Mottatt"),
        "refund": MessageLookupByLibrary.simpleMessage("tilbakebetaling"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Registrere"),
        "registerFor": MessageLookupByLibrary.simpleMessage("for"),
        "registerUsername":
            MessageLookupByLibrary.simpleMessage("Registrer brukernavn"),
        "registerUsernameHeader":
            MessageLookupByLibrary.simpleMessage("Registrer et brukernavn"),
        "registering": MessageLookupByLibrary.simpleMessage("Registrering"),
        "remove": MessageLookupByLibrary.simpleMessage("Fjerne"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at du vil skjule denne kontoen? Du kan legge den til igjen senere ved å trykke på \"%1\" knappen."),
        "removeBlocked":
            MessageLookupByLibrary.simpleMessage("Opphev blokkeringen"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at du vil oppheve blokkeringen av %1?"),
        "removeContact": MessageLookupByLibrary.simpleMessage("Fjern kontakt"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at du vil slette %1?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Fjern favoritt"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "En representant er en konto, som stemmer for konsensus på nettverket. Avstemningskraft veies ut fra balanse, og du kan delegere din balanse for å øke stemmevekten til en representant som du stoler på. Din representant har ingen brukskraft over dine midler. Du bør velge en representant som er sjeldent offline og som er pålitelig."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("Hva er en representant?"),
        "reply": MessageLookupByLibrary.simpleMessage("Svar"),
        "representatives":
            MessageLookupByLibrary.simpleMessage("Representanter"),
        "request": MessageLookupByLibrary.simpleMessage("Be om"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Forespørsel %1 %2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Forespørselen mislyktes: Denne brukeren ser ikke ut til å ha Nautilus installert eller har varslinger deaktivert."),
        "requestFrom": MessageLookupByLibrary.simpleMessage("Forespørsel fra"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Be om betaling"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Feil ved sending av betalingsforespørsel, mottakerens enhet kan være frakoblet eller utilgjengelig."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Be om sendt på nytt! Hvis det fortsatt ikke er godkjent, kan mottakerens enhet være frakoblet."),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Be om en betaling med ende til ende krypterte meldinger!\n\nBetalingsforespørsler, notater og meldinger vil kun kunne mottas av andre nautilus-brukere, men du kan bruke dem til din egen journalføring selv om mottakeren ikke bruker nautilus."),
        "requestSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Be om arkinformasjon"),
        "requested": MessageLookupByLibrary.simpleMessage("forespurt"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Forespurt fra"),
        "requesting": MessageLookupByLibrary.simpleMessage("Forespørsel"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Krev et passord for å åpne Nautilus?"),
        "requireCaptcha": MessageLookupByLibrary.simpleMessage(
            "Krev CAPTCHA for å kreve gavekort"),
        "resendMemo":
            MessageLookupByLibrary.simpleMessage("Send dette notatet på nytt"),
        "resetAccountButton":
            MessageLookupByLibrary.simpleMessage("Tilbakestill konto"),
        "resetAccountParagraph": MessageLookupByLibrary.simpleMessage(
            "Dette vil opprette en ny konto med passordet du nettopp har angitt, den gamle kontoen vil ikke bli slettet med mindre passordene som er valgt er de samme."),
        "resetDatabase":
            MessageLookupByLibrary.simpleMessage("Tilbakestill databasen"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at du vil tilbakestille den interne databasen? \n\nDette kan løse problemer knyttet til oppdatering av appen, men vil også slette alle lagrede preferanser. Dette vil IKKE slette lommebokfrøet ditt. Hvis du har problemer, bør du ta sikkerhetskopi av frøet ditt, installer appen på nytt, og hvis problemet vedvarer, kan du gjerne lage en feilrapport om github eller uenighet."),
        "retry": MessageLookupByLibrary.simpleMessage("Prøv på nytt"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "Din enhet er tilsynelatende \"rooted\", \"jailbroken\", eller endret på en måte som kompromitterer din sikkerhet. Det er anbefalt at du nullstiller enheten til opprinnelig tilstand, før du fortsetter."),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Scan en NANO \nadresse QR-kode"),
        "scanNFC": MessageLookupByLibrary.simpleMessage("Send via NFC"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Scan QR-kode"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Søk etter hva som helst"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "På neste skjerm vil du se din Tilknytningskode, som er en adgangskode til dine midler. Det er avgjørende at du sikkerhetskopierer denne og aldri deler den med noen."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Sikkerhet først!"),
        "secretPhrase":
            MessageLookupByLibrary.simpleMessage("Tilknytningskode"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Tilknytningskode kopiert"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Kopier Tilknytningskode"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Om du mister enheten din eller avinstallerer applikasjonen, trenger du din Tilknytningskode eller Seed til å gjenvinne dine midler!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Sikkerhet"),
        "seed": MessageLookupByLibrary.simpleMessage("Seed"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Nedenfor er din lommeboks Seed. Det er viktig at du sikkerhetskopierer dette, og aldri lagrer det som tekst eller skjermbilde."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Seed kopiert til utklippstavle\nKan limes inn i 2 minutter."),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("Seed kopiert"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Et Seed inneholder den samme informasjonen som en tilknytningskode, men på en måte som en datamaskin kan lese. Så lenge du har en sikkerhetskopi av en av dem, vil du ha tilgang til dine midler."),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("Seed er ugyldig"),
        "selfSendError":
            MessageLookupByLibrary.simpleMessage("Kan ikke be om fra meg selv"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Send %1 NANO"),
        "sendAmounts": MessageLookupByLibrary.simpleMessage("Send beløp"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "Det oppsto en feil. Prøv igjen senere."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Send fra"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Sending av notat med transaksjon mislyktes, de er kanskje ikke en Nautilus-bruker."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Sende melding"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Send forespørsel på nytt"),
        "sendRequests":
            MessageLookupByLibrary.simpleMessage("Sende forespørsler"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Send eller be om betaling, med End to End-krypterte meldinger!\n\nBetalingsforespørsler, notater, og meldinger vil bare kunne mottas av andre nautilus-brukere.\n\nDu trenger ikke å ha et brukernavn for å sende eller motta betalingsforespørsler, og du kan bruke dem til din egen journalføring selv om de ikke bruker nautilus."),
        "sendSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Send info om ark"),
        "sending": MessageLookupByLibrary.simpleMessage("Sender"),
        "sent": MessageLookupByLibrary.simpleMessage("Sendt"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Sendt til"),
        "set": MessageLookupByLibrary.simpleMessage("Sett"),
        "setPassword": MessageLookupByLibrary.simpleMessage("Velg passord"),
        "setPasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Passordet er valgt"),
        "setPin": MessageLookupByLibrary.simpleMessage("Sett Pin"),
        "setPinParagraph": MessageLookupByLibrary.simpleMessage(
            "Angi eller endre din eksisterende PIN-kode. Hvis du ikke har angitt en PIN-kode ennå, er standard-PIN-koden 000000."),
        "setPinSuccess":
            MessageLookupByLibrary.simpleMessage("Pin har blitt satt"),
        "setPlausibleDeniabilityPin":
            MessageLookupByLibrary.simpleMessage("Sett Plausible Pin"),
        "setRestoreHeight":
            MessageLookupByLibrary.simpleMessage("Angi gjenopprettingshøyde"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Velg lommebokens passord"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "setXMRRestoreHeight": MessageLookupByLibrary.simpleMessage(
            "Still inn XMR-gjenopprettingshøyde"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Instillinger"),
        "settingsTransfer":
            MessageLookupByLibrary.simpleMessage("Last fra papirlommebok"),
        "share": MessageLookupByLibrary.simpleMessage("Dele"),
        "shareLink": MessageLookupByLibrary.simpleMessage("Del Link"),
        "shareMessage": MessageLookupByLibrary.simpleMessage("Del melding"),
        "shareNautilus": MessageLookupByLibrary.simpleMessage("Del Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Sjekk ut Nautilus! En ledende NANO mobil lommebok!"),
        "shareText": MessageLookupByLibrary.simpleMessage("Del tekst"),
        "shopButton": MessageLookupByLibrary.simpleMessage("Butikk"),
        "show": MessageLookupByLibrary.simpleMessage("Forestilling"),
        "showAccountInfo":
            MessageLookupByLibrary.simpleMessage("Kontoinformasjon"),
        "showAccountQR":
            MessageLookupByLibrary.simpleMessage("Vis konto QR-kode"),
        "showContacts": MessageLookupByLibrary.simpleMessage("Vis kontakter"),
        "showFunding":
            MessageLookupByLibrary.simpleMessage("Vis finansieringsbanner"),
        "showLinkOptions":
            MessageLookupByLibrary.simpleMessage("Vis koblingsalternativer"),
        "showLinkQR": MessageLookupByLibrary.simpleMessage("Vis lenke QR"),
        "showMoneroHeader": MessageLookupByLibrary.simpleMessage("Vis Monero"),
        "showMoneroInfo":
            MessageLookupByLibrary.simpleMessage("Aktiver Monero-seksjonen"),
        "showQR": MessageLookupByLibrary.simpleMessage("Vis QR-kode"),
        "showUnopenedWarning":
            MessageLookupByLibrary.simpleMessage("Uåpnet advarsel"),
        "simplex": MessageLookupByLibrary.simpleMessage("Simplex"),
        "social": MessageLookupByLibrary.simpleMessage("Sosial"),
        "someone": MessageLookupByLibrary.simpleMessage("noen"),
        "spendNano": MessageLookupByLibrary.simpleMessage("Bruk NANO"),
        "splitBill": MessageLookupByLibrary.simpleMessage("Delt regning"),
        "splitBillHeader":
            MessageLookupByLibrary.simpleMessage("Del en regning"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "Send en haug med betalingsforespørsler på en gang! Gjør det enkelt å dele en regning på en restaurant for eksempel."),
        "splitBillInfoHeader":
            MessageLookupByLibrary.simpleMessage("Del regningsinformasjon"),
        "splitBy": MessageLookupByLibrary.simpleMessage("Del opp etter"),
        "subscribeButton": MessageLookupByLibrary.simpleMessage("Abonnere"),
        "subscribeWithApple":
            MessageLookupByLibrary.simpleMessage("Abonner via Apple Pay"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment": MessageLookupByLibrary.simpleMessage(
            "Hjelp til å støtte utvikling"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Støtt utvikleren"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("Bytt XMR"),
        "swapXMRHeader": MessageLookupByLibrary.simpleMessage("Bytt Monero"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "Monero er en personvernfokusert kryptovaluta som gjør det svært vanskelig eller til og med umulig å spore transaksjoner. I mellomtiden er NANO en betalingsfokusert kryptovaluta som er rask og avgiftsfri. Sammen gir de noen av de mest nyttige aspektene ved kryptovalutaer!\n\nBruk denne siden til å enkelt bytte ut NANO-en din med XMR!"),
        "swapping": MessageLookupByLibrary.simpleMessage("Bytting"),
        "switchToSeed": MessageLookupByLibrary.simpleMessage("Bytt til Seed"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("Systemstandard"),
        "tapMessageToEdit": MessageLookupByLibrary.simpleMessage(
            "Trykk på melding for å redigere"),
        "tapToHide": MessageLookupByLibrary.simpleMessage("Trykk for å skjule"),
        "tapToReveal": MessageLookupByLibrary.simpleMessage("Trykk for å vise"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Tema"),
        "thisMayTakeSomeTime":
            MessageLookupByLibrary.simpleMessage("dette kan ta en stund..."),
        "to": MessageLookupByLibrary.simpleMessage("Til"),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "For mange forsøk på å låse opp mislyktes."),
        "trackingHeader":
            MessageLookupByLibrary.simpleMessage("Sporingsautorisasjon"),
        "trackingWarning":
            MessageLookupByLibrary.simpleMessage("Sporing deaktivert"),
        "trackingWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Gavekortfunksjonaliteten kan være redusert eller ikke fungere i det hele tatt hvis sporing er deaktivert. Vi bruker denne tillatelsen EKSKLUSIVT for denne funksjonen. Absolutt ingen av dataene dine selges, samles inn eller spores på backend for noe formål utover nødvendig"),
        "trackingWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Gavekortlenker vil ikke fungere skikkelig"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transaksjoner"),
        "transfer": MessageLookupByLibrary.simpleMessage("Overføre"),
        "transferClose": MessageLookupByLibrary.simpleMessage(
            "Trykk hvor som helst for å lukke vinduet."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO ble overført til din Nautilus lommebok.\n"),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "En lommebok med en saldo på %1 NANO ble funnet.\n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "Trykk bekreft for å overføre midlene.\n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "Det kan ta flere sekunder å gjennomføre overførselen."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "Det oppsto en feil under overføringen. Prøv igjen senere."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Overfør midler"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "Denne prosessen vil overføre midler fra en papirlommebok til din Nautilus lommebok.\n\nTrykk på \"%1\" knappen for å starte."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "Denne prosessen vil overføre midlene fra en papirlommebok til din Nautilus-lommebok."),
        "transferLoading": MessageLookupByLibrary.simpleMessage("Overfører"),
        "transferManualHint":
            MessageLookupByLibrary.simpleMessage("Tast inn Seed nedenfor."),
        "transferNoFunds": MessageLookupByLibrary.simpleMessage(
            "Det er ingen NANO i dette Seed"),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "Denne QR-koden inneholder ikke et gyldig Seed."),
        "transferQrScanHint": MessageLookupByLibrary.simpleMessage(
            "Scan NANO \nSeed eller privat nøkkel"),
        "unacknowledged": MessageLookupByLibrary.simpleMessage("ubekreftede"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("ubekreftet"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("uoppfylt"),
        "unlock": MessageLookupByLibrary.simpleMessage("Lås opp"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Verifiser for å låse opp Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Angi PIN-kode for å låse opp Nautilus"),
        "unopenedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Vis uåpnet advarsel"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "Vis en advarsel når du sender penger til en uåpnet konto, dette er nyttig fordi det meste av tiden vil adresser du sender til vil ha en saldo, og sending til en ny adresse kan være et resultat av en skrivefeil."),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "Er du sikker på at dette er riktig adresse?\nDenne kontoen ser ut til å være uåpnet\n\nDu kan deaktivere denne advarselen i innstillingsskuffen under \"Uåpnet advarsel\""),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("Konto uåpnet"),
        "unpaid": MessageLookupByLibrary.simpleMessage("ubetalt"),
        "unread": MessageLookupByLibrary.simpleMessage("ulest"),
        "uptime": MessageLookupByLibrary.simpleMessage("Tid online"),
        "urlEmpty":
            MessageLookupByLibrary.simpleMessage("Vennligst skriv inn en URL"),
        "useNano": MessageLookupByLibrary.simpleMessage("Bruk NANO"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userAlreadyAddedError":
            MessageLookupByLibrary.simpleMessage("Bruker allerede lagt til!"),
        "userNotFound":
            MessageLookupByLibrary.simpleMessage("Bruker ikke funnet!"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "Du har allerede registrert et brukernavn! Det er for øyeblikket ikke mulig å endre brukernavnet ditt, men du kan registrere en ny under en annen adresse."),
        "usernameAvailable":
            MessageLookupByLibrary.simpleMessage("Brukernavn tilgjengelig!"),
        "usernameEmpty": MessageLookupByLibrary.simpleMessage(
            "Vennligst skriv inn et brukernavn"),
        "usernameError":
            MessageLookupByLibrary.simpleMessage("Brukernavn Feil"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "Velg en unik @username for å gjøre det enkelt for venner og familie å finne deg!\n\nÅ ha et Nautilus-brukernavn oppdaterer brukergrensesnittet globalt for å gjenspeile det nye håndtaket ditt."),
        "usernameInvalid":
            MessageLookupByLibrary.simpleMessage("Ugyldig brukernavn"),
        "usernameUnavailable":
            MessageLookupByLibrary.simpleMessage("Brukernavn utilgjengelig"),
        "usernameWarning": MessageLookupByLibrary.simpleMessage(
            "Nautilus brukernavn er en sentralisert tjeneste levert av nano.to"),
        "using": MessageLookupByLibrary.simpleMessage("Ved hjelp av"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("Vis detaljer"),
        "viewTX": MessageLookupByLibrary.simpleMessage("Se transaksjonen"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("Stemmevekt"),
        "warning": MessageLookupByLibrary.simpleMessage("Advarsel"),
        "watchAccountExists":
            MessageLookupByLibrary.simpleMessage("Konto allerede lagt til!"),
        "watchOnlyAccount":
            MessageLookupByLibrary.simpleMessage("Bare se konto"),
        "watchOnlySendDisabled": MessageLookupByLibrary.simpleMessage(
            "Sending er deaktivert på adresser som kun er på vakt"),
        "weekAgo": MessageLookupByLibrary.simpleMessage("En uke siden"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Velkommen til Nautilus. For å starte, kan du opprette en ny lommebok eller importere en eksisterende."),
        "welcomeTextLogin": MessageLookupByLibrary.simpleMessage(
            "Velkommen til Nautilus. Velg et alternativ for å komme i gang eller velg et tema ved å bruke ikonet nedenfor."),
        "welcomeTextUpdated": MessageLookupByLibrary.simpleMessage(
            "Velkommen til Nautilus. For å starte, lag en ny lommebok eller importer en eksisterende."),
        "welcomeTextWithoutLogin": MessageLookupByLibrary.simpleMessage(
            "For å starte, opprett en ny lommebok eller importer en eksisterende."),
        "withAddress": MessageLookupByLibrary.simpleMessage("Med adresse"),
        "withFee": MessageLookupByLibrary.simpleMessage("Med gebyr"),
        "withMessage": MessageLookupByLibrary.simpleMessage("Med melding"),
        "xMinute": MessageLookupByLibrary.simpleMessage("Etter %1 minutt"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("Etter %1 minutter"),
        "xmrStatusConnecting":
            MessageLookupByLibrary.simpleMessage("Kobler til"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("Feil"),
        "xmrStatusLoading": MessageLookupByLibrary.simpleMessage("Laster"),
        "xmrStatusSynchronized":
            MessageLookupByLibrary.simpleMessage("Synkronisert"),
        "xmrStatusSynchronizing":
            MessageLookupByLibrary.simpleMessage("Synkroniserer"),
        "yes": MessageLookupByLibrary.simpleMessage("Ja"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Ja")
      };
}
