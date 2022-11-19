// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Konto"),
        "accountNameHint":
            MessageLookupByLibrary.simpleMessage("Geben Sie einen Namen ein"),
        "accountNameMissing":
            MessageLookupByLibrary.simpleMessage("Wählen Sie einen Kontonamen"),
        "accounts": MessageLookupByLibrary.simpleMessage("Konten"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Bist du dir sicher, dass du deine Geheimsequenz oder deinen Seed gesichert hast?"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Aktive Nachricht"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Konto hinzufügen"),
        "addAddress":
            MessageLookupByLibrary.simpleMessage("Füge eine Adresse hinzu"),
        "addBlocked":
            MessageLookupByLibrary.simpleMessage("Einen Benutzer blockieren"),
        "addContact": MessageLookupByLibrary.simpleMessage("Neuer Kontakt"),
        "addFavorite":
            MessageLookupByLibrary.simpleMessage("Favorit hinzufügen"),
        "addUser": MessageLookupByLibrary.simpleMessage(
            "Fügen Sie einen Benutzer hinzu"),
        "addWatchOnlyAccount": MessageLookupByLibrary.simpleMessage(
            "Fügen Sie ein Watch Only-Konto hinzu"),
        "addWatchOnlyAccountError": MessageLookupByLibrary.simpleMessage(
            "Fehler beim Hinzufügen des Watch Only-Kontos: Das Konto war null"),
        "addWatchOnlyAccountSuccess": MessageLookupByLibrary.simpleMessage(
            "Nur-Uhr-Konto erfolgreich erstellt!"),
        "address": MessageLookupByLibrary.simpleMessage("Adresse"),
        "addressCopied":
            MessageLookupByLibrary.simpleMessage("Adresse kopiert"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Adresse eingeben"),
        "addressMissing":
            MessageLookupByLibrary.simpleMessage("Bitte Adresse eingeben"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Bitte gib einen Nutzernamen oder eine Adresse ein"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Teilen"),
        "aliases": MessageLookupByLibrary.simpleMessage("Aliase"),
        "amountGiftGreaterError": MessageLookupByLibrary.simpleMessage(
            "Der Aufteilungsbetrag darf nicht größer als das Geschenkguthaben sein"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Bitte Betrag eingeben"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "Wir haben festgestellt, dass Sie auf einen Link geklickt haben, der Nano enthält. Möchten Sie den Einrichtungsvorgang überspringen? Sie können die Dinge später immer noch ändern.\n\n Wenn Sie jedoch einen vorhandenen Seed haben, den Sie importieren möchten, sollten Sie Nein auswählen."),
        "askTracking": MessageLookupByLibrary.simpleMessage(
            "Wir werden gleich um die „Tracking“-Erlaubnis bitten, diese wird *ausschließlich* für die Zuordnung von Links/Verweise und kleinere Analysen (Dinge wie Anzahl der Installationen, welche App-Version usw.) verwendet. Wir glauben, dass Sie ein Recht auf Ihre Privatsphäre haben und an Ihren personenbezogenen Daten nicht interessiert sind, benötigen wir lediglich die Erlaubnis, damit die Linkzuordnungen korrekt funktionieren."),
        "asked": MessageLookupByLibrary.simpleMessage("Fragte"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("Authentifizieren"),
        "authError": MessageLookupByLibrary.simpleMessage(
            "Bei der Authentifizierung ist ein Fehler aufgetreten. Versuchen Sie es später noch einmal."),
        "authMethod": MessageLookupByLibrary.simpleMessage(
            "Authentifizierungs-Verfahren"),
        "authenticating":
            MessageLookupByLibrary.simpleMessage("Authentifizieren"),
        "autoImport":
            MessageLookupByLibrary.simpleMessage("Automatisch importieren"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Automatisch sperren"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("Ich habe den Seed gesichert"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Geheimsequenz sichern"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Seed sichern"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Bist du sicher, dass du deinen Seed gesichert hast?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Sichere deinen Seed"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Biometrie"),
        "blockExplorer": MessageLookupByLibrary.simpleMessage("Block Explorer"),
        "blockExplorerHeader": MessageLookupByLibrary.simpleMessage(
            "Explorer-Informationen blockieren"),
        "blockExplorerInfo": MessageLookupByLibrary.simpleMessage(
            "Welcher Block-Explorer zum Anzeigen von Transaktionsinformationen verwendet werden soll"),
        "blockUser":
            MessageLookupByLibrary.simpleMessage("Diesen Benutzer blockieren"),
        "blockedAdded": MessageLookupByLibrary.simpleMessage(
            "%1 wurde erfolgreich blockiert."),
        "blockedExists": MessageLookupByLibrary.simpleMessage(
            "Der Benutzer wurde bereits blockiert!"),
        "blockedHeader": MessageLookupByLibrary.simpleMessage("Blockiert"),
        "blockedInfo": MessageLookupByLibrary.simpleMessage(
            "Blockieren Sie einen Benutzer mit einem bekannten Alias oder einer Adresse. Alle Nachrichten, Transaktionen oder Anfragen von ihnen werden ignoriert."),
        "blockedInfoHeader":
            MessageLookupByLibrary.simpleMessage("Blockierte Informationen"),
        "blockedNameExists": MessageLookupByLibrary.simpleMessage(
            "Spitzname wurde bereits verwendet!"),
        "blockedNameMissing":
            MessageLookupByLibrary.simpleMessage("Wähle einen Spitznamen"),
        "blockedRemoved":
            MessageLookupByLibrary.simpleMessage("%1 wurde entsperrt!"),
        "branchConnectErrorLongDesc": MessageLookupByLibrary.simpleMessage(
            "Wir können die Branch-API anscheinend nicht erreichen, dies wird normalerweise durch ein Netzwerkproblem oder ein VPN verursacht, das die Verbindung blockiert.\n\n Sie sollten die App weiterhin wie gewohnt verwenden können, das Senden und Empfangen von Geschenkkarten funktioniert jedoch möglicherweise nicht."),
        "branchConnectErrorShortDesc": MessageLookupByLibrary.simpleMessage(
            "Fehler: Verzweigungs-API kann nicht erreicht werden"),
        "branchConnectErrorTitle":
            MessageLookupByLibrary.simpleMessage("Verbindungswarnung"),
        "businessButton": MessageLookupByLibrary.simpleMessage(""),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("Captcha"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "Um Missbrauch zu verhindern, müssen Sie ein Captcha lösen, um die Geschenkkarte auf der nächsten Seite zu beanspruchen."),
        "changeCurrency":
            MessageLookupByLibrary.simpleMessage("Währung ändern"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Protokoll ändern"),
        "changePassword":
            MessageLookupByLibrary.simpleMessage("Passwort ändern"),
        "changePasswordParagraph": MessageLookupByLibrary.simpleMessage(
            "Ändern Sie Ihr bestehendes Passwort. Wenn Sie Ihr aktuelles Passwort nicht kennen, raten Sie einfach, da es eigentlich nicht erforderlich ist, es zu ändern (da Sie bereits angemeldet sind), aber wir können den vorhandenen Sicherungseintrag löschen."),
        "changePin": MessageLookupByLibrary.simpleMessage("PIN ändern"),
        "changePinHint": MessageLookupByLibrary.simpleMessage("Stift setzen"),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Vertreter wechseln"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Ändern"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Neuer Vertreter"),
        "changeRepSame": MessageLookupByLibrary.simpleMessage(
            "Das ist schon Ihr Vertreter!"),
        "changeRepSucces": MessageLookupByLibrary.simpleMessage(
            "Vertreter erfolgreich gewechselt"),
        "changeSeed": MessageLookupByLibrary.simpleMessage("Samen ändern"),
        "changeSeedParagraph": MessageLookupByLibrary.simpleMessage(
            "Ändern Sie den Seed/Phrase, der mit diesem Magic-Link-authentifizierten Konto verknüpft ist. Das Passwort, das Sie hier festlegen, wird Ihr vorhandenes Passwort überschreiben, aber Sie können dasselbe Passwort verwenden, wenn Sie dies wünschen."),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Verfügbarkeit prüfen"),
        "close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Passwort bestätigen"),
        "confirmPinHint":
            MessageLookupByLibrary.simpleMessage("Bestätigen Sie die PIN"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Verbindet"),
        "connectionWarning":
            MessageLookupByLibrary.simpleMessage("Verbindung nicht möglich"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "Wir können anscheinend keine Verbindung zum Back-End herstellen, dies könnte nur Ihre Verbindung sein, oder wenn das Problem weiterhin besteht, ist das Back-End möglicherweise wegen Wartungsarbeiten oder sogar ausgefallen. Wenn es mehr als eine Stunde her ist und du immer noch Probleme hast, sende bitte einen Bericht unter #bug-reports auf dem Discord-Server @ chat.perish.co"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Wir können anscheinend keine Verbindung zum Back-End herstellen, dies könnte nur Ihre Verbindung sein, oder wenn das Problem weiterhin besteht, ist das Back-End möglicherweise wegen Wartungsarbeiten oder sogar ausgefallen. Wenn es mehr als eine Stunde her ist und du immer noch Probleme hast, sende bitte einen Bericht unter #bug-reports auf dem Discord-Server @ chat.perish.co"),
        "connectionWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Wir können anscheinend keine Verbindung zum Backend herstellen"),
        "contactAdded": MessageLookupByLibrary.simpleMessage(
            "%1 zu Kontakten hinzugefügt!"),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Kontakt bereits vorhanden"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Kontakt"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Ungültiger Kontaktname"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Namen eingeben @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Gib diesem Kontakt einen Namen"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 wurde aus den Kontakten gelöscht!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Kontakte"),
        "contactsImportErr":
            MessageLookupByLibrary.simpleMessage("Import fehlgeschlagen"),
        "contactsImportSuccess": MessageLookupByLibrary.simpleMessage(
            "%1 Kontakte wurden importiert"),
        "continueButton": MessageLookupByLibrary.simpleMessage("Fortsetzen"),
        "continueWithoutLogin":
            MessageLookupByLibrary.simpleMessage("Ohne Anmeldung fortfahren"),
        "copied": MessageLookupByLibrary.simpleMessage("Kopiert"),
        "copy": MessageLookupByLibrary.simpleMessage("Kopieren"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Adresse kopieren"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Link kopieren"),
        "copyMessage":
            MessageLookupByLibrary.simpleMessage("Nachricht kopieren"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Seed kopieren"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Wallet-Adresse in die Zwischenablage kopieren"),
        "copyXMRSeed":
            MessageLookupByLibrary.simpleMessage("Kopieren Sie Monero-Seed"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Wähle ein Passwort."),
        "createGiftCard":
            MessageLookupByLibrary.simpleMessage("Geschenkgutschein erstellen"),
        "createGiftHeader": MessageLookupByLibrary.simpleMessage(
            "Erstelle einen Geschenkgutschein"),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "Für zusätzliche Sicherheit kannst du ein Passwort festlegen."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Ein Passwort wählen"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "Das Passwort ist optional. Dein Wallet wird immer mithilfe einer PIN oder biometrischen Daten geschützt."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Wählen"),
        "createPinHint": MessageLookupByLibrary.simpleMessage(
            "Erstellen Sie eine Stecknadel"),
        "createQR": MessageLookupByLibrary.simpleMessage("QR-Code erstellen"),
        "created": MessageLookupByLibrary.simpleMessage("erstellt"),
        "creatingGiftCard":
            MessageLookupByLibrary.simpleMessage("Geschenkgutschein erstellen"),
        "currency": MessageLookupByLibrary.simpleMessage("Währung"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Währungsmodus"),
        "currencyModeHeader": MessageLookupByLibrary.simpleMessage(
            "Informationen zum Währungsmodus"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Wählen Sie aus, in welcher Einheit Beträge angezeigt werden sollen.\n1 nyano = 0,000001 NANO oder \n1.000.000 Nyano = 1 NANO"),
        "currentlyRepresented":
            MessageLookupByLibrary.simpleMessage("Aktueller Vertreter"),
        "dayAgo": MessageLookupByLibrary.simpleMessage("Vor einem Tag"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Entschlüsselungsfehler!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Hauptkonto"),
        "defaultGiftMessage": MessageLookupByLibrary.simpleMessage(
            "Schauen dir Nautilus an! Ich habe dir Nano mit diesem Link geschickt:"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Name des neuen Kontos %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Deaktivieren"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Passwort wurde deaktiviert"),
        "disableWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Wallet-Passwort deaktivieren"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Schließen"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Ungültiger Domainname"),
        "donateButton": MessageLookupByLibrary.simpleMessage("Spenden"),
        "donateToSupport": MessageLookupByLibrary.simpleMessage(
            "Unterstützen Sie das Projekt"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "enableNotifications": MessageLookupByLibrary.simpleMessage(
            "Benachrichtigungen aktivieren"),
        "enableTracking":
            MessageLookupByLibrary.simpleMessage("Tracking aktivieren"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Wallet-Passwort konnte nicht festgelegt werden"),
        "enterAddress":
            MessageLookupByLibrary.simpleMessage("Adresse eingeben"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Betrag eingeben"),
        "enterEmail": MessageLookupByLibrary.simpleMessage("Email eingeben"),
        "enterGiftMemo":
            MessageLookupByLibrary.simpleMessage("Geschenknotiz eingeben"),
        "enterHeight": MessageLookupByLibrary.simpleMessage("Höhe eingeben"),
        "enterMemo":
            MessageLookupByLibrary.simpleMessage("Nachricht eintragen"),
        "enterMoneroAddress": MessageLookupByLibrary.simpleMessage(
            "Geben Sie die XMR-Adresse ein"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Passwort eingeben"),
        "enterSplitAmount":
            MessageLookupByLibrary.simpleMessage("Splitbetrag eingeben"),
        "enterUserOrAddress": MessageLookupByLibrary.simpleMessage(
            "Benutzer oder Adresse eingeben"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Gib einen Nutzernamen ein"),
        "errorProcessingGiftCard": MessageLookupByLibrary.simpleMessage(
            "Bei der Verarbeitung dieser Geschenkkarte ist ein Fehler aufgetreten. Sie ist möglicherweise ungültig, abgelaufen oder leer."),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("Von jemandem"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Willkommen bei Nautilus. Wenn du NANO sendest oder empfängst, sieht es aus wie folgt: "),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Ein paar"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Ein paar mehr"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("An jemanden"),
        "examplePayRecipient": MessageLookupByLibrary.simpleMessage("@dad"),
        "examplePayRecipientMessage": MessageLookupByLibrary.simpleMessage(
            "Herzlichen Glückwunsch zum Geburtstag!"),
        "examplePaymentExplainer": MessageLookupByLibrary.simpleMessage(
            "Sobald Sie eine Zahlungsaufforderung gesendet oder erhalten haben, werden sie hier so angezeigt, mit der Farbe und dem Etikett der Karte, die den Status angeben. \n\nGrün zeigt an, dass die Anfrage bezahlt wurde.\nGelb zeigt an, dass die Anfrage/das Memo nicht bezahlt/gelesen wurde.\nRot zeigt an, dass die Anfrage nicht gelesen oder empfangen wurde.\n\n Neutrale Karten ohne Betrag sind nur Nachrichten."),
        "examplePaymentFrom": MessageLookupByLibrary.simpleMessage("@landlord"),
        "examplePaymentFulfilled":
            MessageLookupByLibrary.simpleMessage("Einige"),
        "examplePaymentFulfilledMemo":
            MessageLookupByLibrary.simpleMessage("Sushi"),
        "examplePaymentIntro": MessageLookupByLibrary.simpleMessage(
            "Sobald du eine Zahlungsaufforderung gesendet oder erhalten hast, werden sie hier angezeigt:"),
        "examplePaymentMessage":
            MessageLookupByLibrary.simpleMessage("Hey, was ist los?"),
        "examplePaymentReceivable":
            MessageLookupByLibrary.simpleMessage("Eine Menge"),
        "examplePaymentReceivableMemo":
            MessageLookupByLibrary.simpleMessage("Mieten"),
        "examplePaymentTo":
            MessageLookupByLibrary.simpleMessage("@best_friend"),
        "exampleRecRecipient":
            MessageLookupByLibrary.simpleMessage("@coworker"),
        "exampleRecRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Gas-Geld"),
        "exchangeNano":
            MessageLookupByLibrary.simpleMessage("Nano austauschen"),
        "existingPasswordHint": MessageLookupByLibrary.simpleMessage(
            "Gib dein aktuelles Passwort ein"),
        "existingPinHint": MessageLookupByLibrary.simpleMessage(
            "Geben Sie die aktuelle PIN ein"),
        "exit": MessageLookupByLibrary.simpleMessage("Verlassen"),
        "exportTXData":
            MessageLookupByLibrary.simpleMessage("Transaktionen exportieren"),
        "failed": MessageLookupByLibrary.simpleMessage("fehlgeschlagen"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader":
            MessageLookupByLibrary.simpleMessage("Nautilus getrennt"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "Nautilus Server scheinen nicht verbunden zu sein, Senden und Empfangen (ohne Memos) sollten weiterhin betriebsbereit sein, aber Zahlungsaufforderungen werden möglicherweise nicht ausgeführt\n\n Komm später zurück oder starte die App neu, um es erneut zu versuchen"),
        "favoriteExists": MessageLookupByLibrary.simpleMessage(
            "Favorit ist bereits vorhanden"),
        "favoriteHeader": MessageLookupByLibrary.simpleMessage("Favorit"),
        "favoriteInvalid":
            MessageLookupByLibrary.simpleMessage("Ungültiger Lieblingsname"),
        "favoriteNameHint":
            MessageLookupByLibrary.simpleMessage("Gib einen Spitznamen ein"),
        "favoriteNameMissing": MessageLookupByLibrary.simpleMessage(
            "Wähle einen Namen für diesen Favoriten"),
        "favoriteRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 wurde aus den Favoriten entfernt!"),
        "favoritesHeader":
            MessageLookupByLibrary.simpleMessage("Meine Favoriten"),
        "featured": MessageLookupByLibrary.simpleMessage("Ausgewählte"),
        "fewDaysAgo":
            MessageLookupByLibrary.simpleMessage("Vor ein paar Tagen"),
        "fewHoursAgo":
            MessageLookupByLibrary.simpleMessage("Vor ein paar Stunden"),
        "fewMinutesAgo":
            MessageLookupByLibrary.simpleMessage("Vor ein paar Minuten"),
        "fewSecondsAgo":
            MessageLookupByLibrary.simpleMessage("Vor ein paar Sekunden"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Fingerabdruck scannen, um Seed zu sichern."),
        "from": MessageLookupByLibrary.simpleMessage("Von"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("erfüllt"),
        "fundingBannerHeader":
            MessageLookupByLibrary.simpleMessage("Finanzierungsbanner"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("Finanzierung"),
        "getNano": MessageLookupByLibrary.simpleMessage("Holen Sie sich Nano"),
        "giftAlert":
            MessageLookupByLibrary.simpleMessage("Du hast eine Geschenk!"),
        "giftAlertEmpty":
            MessageLookupByLibrary.simpleMessage("Leeres Geschenk"),
        "giftAmount":
            MessageLookupByLibrary.simpleMessage("Betrag des Geschenks"),
        "giftCardCreationError": MessageLookupByLibrary.simpleMessage(
            "Beim Versuch, einen Geschenkkarten-Link zu erstellen, ist ein Fehler aufgetreten"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "Beim Versuch, eine Geschenkkarte zu erstellen, ist ein Fehler aufgetreten! Der Link zur Geschenkkarte und zum Download von Nautilus, mit Seed (getrennt von einem ^ Zeichen) wurde in ihre Zwischenablage kopiert. Je nach Fehlerart ist es möglich, dass die übertragenen Nanos wieder hergestellt werden können."),
        "giftCardInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Informationen zum Geschenkbogen"),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Geschenk von"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Laden Sie eine digitale Geschenkkarte mit NANO! Legen Sie einen Betrag und optional eine Nachricht fest, damit der Empfänger sehen kann, wenn er ihn öffnet!\n\nNach der Erstellung erhalten Sie einen Link, den Sie an jeden senden können. Wenn er geöffnet wird, wird das Geld nach der Installation von Nautilus automatisch an den Empfänger verteilt!\n\nWenn der Empfänger bereits Nautilus-Benutzer ist, wird er beim Öffnen des Links aufgefordert, das Geld auf sein Konto zu überweisen."),
        "giftMessage": MessageLookupByLibrary.simpleMessage("Geschenk-Meldung"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "Bei der Verarbeitung dieser Geschenkkarte ist ein Fehler aufgetreten. Überprüfen Sie vielleicht Ihre Verbindung und versuchen Sie erneut, auf den Geschenklink zu klicken."),
        "giftProcessSuccess": MessageLookupByLibrary.simpleMessage(
            "Geschenk erfolgreich erhalten, es kann einen Moment dauern, bis es in deiner Brieftasche erscheint."),
        "giftRefundSuccess": MessageLookupByLibrary.simpleMessage(
            "Geschenk erfolgreich erstattet!"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Zurück"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Gehe zu QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Verstanden!"),
        "handoff": MessageLookupByLibrary.simpleMessage("weiterleiten"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage(
            "Beim Versuch, die Sperre zu übergeben, ist etwas schief gelaufen!"),
        "handoffSupportedMethodNotFound": MessageLookupByLibrary.simpleMessage(
            "Eine unterstützte Übergabemethode konnte nicht gefunden werden!"),
        "hide": MessageLookupByLibrary.simpleMessage("Verstecken"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Konto verbergen?"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Möchten Sie leere Konten wirklich ausblenden?\n\nDadurch werden alle Konten mit einem Kontostand von genau 0 ausgeblendet (mit Ausnahme von Watch-Only-Adressen und Ihrem Hauptkonto), aber Sie können sie später jederzeit wieder hinzufügen, indem Sie auf die Schaltfläche \"Konto hinzufügen\" tippen"),
        "hideAccountsHeader":
            MessageLookupByLibrary.simpleMessage("Konten verstecken?"),
        "hideEmptyAccounts":
            MessageLookupByLibrary.simpleMessage("Leere Konten ausblenden"),
        "home": MessageLookupByLibrary.simpleMessage("Zuhause"),
        "homeButton": MessageLookupByLibrary.simpleMessage(""),
        "hourAgo": MessageLookupByLibrary.simpleMessage("Vor einer Stunde"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("Ich verstehe die Risiken"),
        "ignore": MessageLookupByLibrary.simpleMessage("Ignorieren"),
        "imSure": MessageLookupByLibrary.simpleMessage("Ich bin sicher"),
        "import": MessageLookupByLibrary.simpleMessage("Importieren"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "Der Link, auf den Sie geklickt haben, enthält einige Nanos. Möchten Sie ihn in diese Brieftasche importieren oder demjenigen, der ihn gesendet hat, erstatten?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "Es sieht so aus, als hätten Sie auf einen Link geklickt, der etwas NANO enthält, um diese Gelder zu erhalten, die wir nur benötigen, damit Sie die Einrichtung Ihres Wallets abschließen können."),
        "importGiftv2": MessageLookupByLibrary.simpleMessage(
            "Der Link, auf den Sie geklickt haben, enthält etwas NANO, möchten Sie es in dieses Wallet importieren?"),
        "importHD": MessageLookupByLibrary.simpleMessage("HD importieren"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Geheimsequenz importieren"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Bitte gib unten deine 24-wörtige Geheimsequenz ein. Trenne die Wörter dabei mit Leerzeichen."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Seed importieren"),
        "importSeedHint":
            MessageLookupByLibrary.simpleMessage("Bitte füge deinen Seed ein."),
        "importSeedInstead": MessageLookupByLibrary.simpleMessage(
            "Stattdessen Seed importieren"),
        "importStandard":
            MessageLookupByLibrary.simpleMessage("Standard importieren"),
        "importWallet":
            MessageLookupByLibrary.simpleMessage("Wallet importieren"),
        "instantly": MessageLookupByLibrary.simpleMessage("Sofort"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Nicht genügend Guthaben"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "Wir haben den Einführungsprozess übersprungen, um Ihnen Zeit zu sparen, aber Sie sollten Ihren neu erstellten Seed sofort sichern.\n\nWenn Sie Ihren Seed verlieren, verlieren Sie den Zugriff auf Ihre Gelder.\n\nAußerdem wurde Ihr Passcode auf „000000“ gesetzt, den Sie ebenfalls sofort ändern sollten."),
        "introSkippedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Sichern Sie Ihren Seed!"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Ungültige Empfänger-Adresse"),
        "invalidHeight": MessageLookupByLibrary.simpleMessage("Ungültige Höhe"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Ungültiges Passwort"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("Ungültige PIN"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "Aufgrund der Richtlinien und Einschränkungen des iOS App Store können wir Sie nicht mit unserer Spendenseite verlinken. Wenn Sie das Projekt unterstützen möchten, senden Sie es bitte an die Adresse des Nautilus-Knotens."),
        "language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "linkCopied":
            MessageLookupByLibrary.simpleMessage("Link wurde kopiert"),
        "loaded": MessageLookupByLibrary.simpleMessage("Geladen"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Geladen in"),
        "lockAppSetting": MessageLookupByLibrary.simpleMessage(
            "Authentifizierung beim Öffnen"),
        "locked": MessageLookupByLibrary.simpleMessage("Gesperrt"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Anmeldung"),
        "loginOrRegisterHeader":
            MessageLookupByLibrary.simpleMessage("Anmelden oder Registrieren"),
        "logout": MessageLookupByLibrary.simpleMessage("Ausloggen"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Seed löschen und ausloggen"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Bist du dir sicher?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Beim Ausloggen werden dein Seed und alle mit Nautilus verbundenen Daten von diesem Gerät gelöscht. Falls du deinen Seed nicht gesichert hast, verlierst du dauerhaft den Zugriff auf dein Guthaben."),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Solange du deinen Seed gesichert hast, musst du dir keine Gedanken machen."),
        "looksLikeHdSeed": MessageLookupByLibrary.simpleMessage(
            "Dies scheint ein HD-Seed zu sein, es sei denn, Sie sind sicher, dass Sie wissen, was Sie tun, Sie sollten stattdessen die Option „HD importieren“ verwenden."),
        "looksLikeStandardSeed": MessageLookupByLibrary.simpleMessage(
            "Dies scheint ein Standard-Seed zu sein, Sie sollten stattdessen die Option „Standard importieren“ verwenden."),
        "manage": MessageLookupByLibrary.simpleMessage("Verwaltung"),
        "mantaError": MessageLookupByLibrary.simpleMessage(
            "Anfrage konnte nicht bestätigt werden"),
        "manualEntry":
            MessageLookupByLibrary.simpleMessage("Manueller Eintrag"),
        "markAsPaid":
            MessageLookupByLibrary.simpleMessage("Als bezahlt markieren"),
        "markAsUnpaid":
            MessageLookupByLibrary.simpleMessage("Als unbezahlt markieren"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Memo erneut gesendet! Falls immer noch nicht bestätigt, ist das Gerät des Empfängers möglicherweise offline."),
        "messageCopied":
            MessageLookupByLibrary.simpleMessage("Nachricht kopiert"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Nachricht"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "Der Mindest-Sendebetrag beträgt %1 NANO"),
        "minuteAgo": MessageLookupByLibrary.simpleMessage("Vor einer Minute"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 ist kein gültiges Wort"),
        "mnemonicPhrase": MessageLookupByLibrary.simpleMessage("Wortfolge"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Die Geheimsequenz muss 24 Wörter enthalten"),
        "monthlyServerCosts":
            MessageLookupByLibrary.simpleMessage("Monatliche Serverkosten"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings":
            MessageLookupByLibrary.simpleMessage("Mehr Einstellungen"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "nautilusWallet":
            MessageLookupByLibrary.simpleMessage("Nautilus-Geldbörse"),
        "nearby": MessageLookupByLibrary.simpleMessage("In der Nähe"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "Diese Funktion erfordert einen längeren Transaktionsverlauf, um Spam zu verhindern.\n\nAlternativ können Sie einen QR-Code anzeigen, den jemand scannen kann."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Überprüfung erforderlich"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Dies ist dein neues Konto. Sobald du deine ersten NANO erhalten hast, werden die Transktionen wie folgt angezeigt:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Neues Wallet"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Weiter"),
        "no": MessageLookupByLibrary.simpleMessage("Nein"),
        "noContactsExport": MessageLookupByLibrary.simpleMessage(
            "Keine Kontakte zum Exportieren gefunden"),
        "noContactsImport": MessageLookupByLibrary.simpleMessage(
            "Keine Kontakte zum Importieren gefunden"),
        "noSearchResults":
            MessageLookupByLibrary.simpleMessage("Keine Suchergebnisse!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("Überspringen"),
        "noTXDataExport": MessageLookupByLibrary.simpleMessage(
            "Es gibt keine zu exportierenden Transaktionen."),
        "noThanks": MessageLookupByLibrary.simpleMessage("Nein danke"),
        "nodeStatus":
            MessageLookupByLibrary.simpleMessage("Status des Knotens"),
        "noneMethod": MessageLookupByLibrary.simpleMessage("Keiner"),
        "notSent": MessageLookupByLibrary.simpleMessage("nicht gesendet"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Öffne Nautilus, um diese Transaktion zu sehen."),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Zum Öffnen tippen"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "Damit diese Funktion ordnungsgemäß funktioniert, müssen Benachrichtigungen aktiviert sein"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("%1 NANO erhalten"),
        "notificationWarning": MessageLookupByLibrary.simpleMessage(
            "Benachrichtigungen deaktiviert"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Für Zahlungsanforderungen, Memos und Nachrichten müssen alle Benachrichtigungen aktiviert werden, damit sie ordnungsgemäß funktionieren, da sie den FCM-Benachrichtigungsdienst verwenden, um die Nachrichtenübermittlung sicherzustellen.\n\nSie können Benachrichtigungen mit der Schaltfläche unten aktivieren oder diese Karte schließen, wenn Sie diese Funktionen nicht verwenden möchten."),
        "notificationWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Zahlungsaufforderungen, Memos und Nachrichten funktionieren nicht richtig."),
        "notifications":
            MessageLookupByLibrary.simpleMessage("Benachrichtigungen"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Nyanicon"),
        "obscureInfoHeader": MessageLookupByLibrary.simpleMessage(""),
        "obscureTransaction": MessageLookupByLibrary.simpleMessage(""),
        "obscureTransactionBody": MessageLookupByLibrary.simpleMessage(""),
        "off": MessageLookupByLibrary.simpleMessage("Aus"),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "onStr": MessageLookupByLibrary.simpleMessage("An"),
        "onboard": MessageLookupByLibrary.simpleMessage("Lade jemanden ein"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Onboarding"),
        "onramp": MessageLookupByLibrary.simpleMessage("Auf der Rampe"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Eröffnet"),
        "paid": MessageLookupByLibrary.simpleMessage("bezahlt"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("Paper Wallet"),
        "passwordBlank": MessageLookupByLibrary.simpleMessage(
            "Passwort darf nicht leer sein"),
        "passwordCapitalLetter": MessageLookupByLibrary.simpleMessage(
            "Das Passwort muss mindestens 1 Groß- und Kleinbuchstaben enthalten"),
        "passwordDisclaimer": MessageLookupByLibrary.simpleMessage(
            "Wir sind nicht verantwortlich, wenn Sie Ihr Passwort vergessen, und wir sind nicht in der Lage, es für Sie zurückzusetzen oder zu ändern."),
        "passwordIncorrect":
            MessageLookupByLibrary.simpleMessage("Falsches Passwort"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Zum Öffnen der App wird jetzt kein Passwort mehr benötigt."),
        "passwordNumber": MessageLookupByLibrary.simpleMessage(
            "Das Passwort muss mindestens 1 Ziffer enthalten"),
        "passwordSpecialCharacter": MessageLookupByLibrary.simpleMessage(
            "Das Passwort muss mindestens 1 Sonderzeichen enthalten"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Das Passwort ist zu kurz"),
        "passwordWarning": MessageLookupByLibrary.simpleMessage(
            "Dieses Passwort wird zum Öffnen von Nautilus benötigt."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Dieses Passwort wird benötigt, um Nautilus zu öffnen."),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Passwörter stimmen nicht überein"),
        "pay": MessageLookupByLibrary.simpleMessage("Zahlen"),
        "payRequest":
            MessageLookupByLibrary.simpleMessage("Zahlen Sie diese Anfrage"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Jemand hat eine Zahlung von dir verlangt! Weitere Informationen findest du auf der Zahlungsseite."),
        "payments": MessageLookupByLibrary.simpleMessage("Zahlungen"),
        "pickFromList":
            MessageLookupByLibrary.simpleMessage("Aus Liste wählen"),
        "pinBlank":
            MessageLookupByLibrary.simpleMessage("Pin darf nicht leer sein"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("PINs stimmen nicht überein"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Bestätige deine PIN"),
        "pinCreateTitle": MessageLookupByLibrary.simpleMessage(
            "Erstelle eine 6-stellige PIN"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("PIN eingeben"),
        "pinIncorrect":
            MessageLookupByLibrary.simpleMessage("Falsche PIN eingegeben"),
        "pinInvalid":
            MessageLookupByLibrary.simpleMessage("Falsche PIN eingegeben"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "PIN eingeben, um Vertreter zu wechseln"),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "PIN eingeben, um Seed zu sehen."),
        "pinsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Stifte stimmen nicht überein"),
        "plausibleDeniabilityParagraph": MessageLookupByLibrary.simpleMessage(
            "Dies ist NICHT dieselbe PIN, die Sie zum Erstellen Ihrer Brieftasche verwendet haben. Drücken Sie die Info-Taste für weitere Informationen."),
        "plausibleInfoHeader":
            MessageLookupByLibrary.simpleMessage("Plausible Deniability Info"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Legen Sie einen sekundären Pin für den plausiblen Deniability-Modus fest.\n\nWenn Ihre Brieftasche mit dieser sekundären PIN entsperrt wird, wird Ihr Seed durch einen Hash des vorhandenen Seeds ersetzt. Dies ist eine Sicherheitsfunktion, die verwendet werden soll, falls Sie gezwungen sind, Ihre Brieftasche zu öffnen.\n\nDiese PIN verhält sich wie eine normale (korrekte) PIN, AUSSER beim Entsperren Ihrer Brieftasche, wenn der Plausible Deniability-Modus aktiviert wird.\n\nIhr Geld WIRD VERLOREN, wenn Sie in den Plausible Deniability-Modus wechseln, wenn Sie Ihren Seed nicht gesichert haben!"),
        "preferences": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Datenschutz"),
        "promotionalLink":
            MessageLookupByLibrary.simpleMessage("Kostenlos Nano"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Nano kaufen"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR-Code enthält kein gültiges Ziel"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Bitte Kamerazugriff erlauben, um QR-Codes zu scannen"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "Der QR-Code enthält keinen gültigen Seed oder Private Key"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "Der QR-Code enthält keine gültige Geheimsequenz"),
        "qrUnknownError": MessageLookupByLibrary.simpleMessage(
            "QR-Code konnte nicht gelesen werden"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp": MessageLookupByLibrary.simpleMessage("Bewerte die App"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "Wenn Ihnen die App gefällt, sollten Sie sich die Zeit nehmen, sie zu überprüfen.\nEs hilft wirklich und sollte nicht länger als eine Minute dauern."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Seed"),
        "readMore": MessageLookupByLibrary.simpleMessage("Mehr Infos"),
        "receivable": MessageLookupByLibrary.simpleMessage("ausstehend"),
        "receive": MessageLookupByLibrary.simpleMessage("Empfangen"),
        "receiveMinimum":
            MessageLookupByLibrary.simpleMessage("Minimum erhalten"),
        "receiveMinimumHeader": MessageLookupByLibrary.simpleMessage(
            "Mindestinformationen erhalten"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "Ein Mindestbetrag, den Sie erhalten müssen. Wenn eine Zahlung oder Anfrage mit einem geringeren Betrag eingeht, wird sie ignoriert."),
        "received": MessageLookupByLibrary.simpleMessage("Empfangen"),
        "refund": MessageLookupByLibrary.simpleMessage("Rückerstattung"),
        "registerButton": MessageLookupByLibrary.simpleMessage("Registrieren"),
        "registerFor": MessageLookupByLibrary.simpleMessage("zum"),
        "registerUsername":
            MessageLookupByLibrary.simpleMessage("Nutzername registrieren"),
        "registerUsernameHeader": MessageLookupByLibrary.simpleMessage(
            "Einen Nutzernamen registrieren"),
        "registering": MessageLookupByLibrary.simpleMessage("Registrierung"),
        "remove": MessageLookupByLibrary.simpleMessage("Entfernen"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Bist du dir sicher, dass du dieses Konto verbergen willst? Du kannst es später durch Tippen auf den \"%1\"-Button wieder hinzufügen."),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("Entsperren"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Möchten Sie die Blockierung von %1 wirklich entsperren?"),
        "removeContact":
            MessageLookupByLibrary.simpleMessage("Kontakt löschen"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Willst du %1 wirklich löschen?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Favorit entfernen"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "Kommt es zu zwei widersprüchlichen Transaktionen, so stimmen Vertreter-Accounts darüber ab, welche der Transaktionen akzeptiert wird. Dabei entspricht ein Nano einem Stimmrecht. Du kannst einem Vertreter Stimmrechte in Höhe deines Guthabens übertragen. Deine Nanos gehören dabei natürlich weiterhin dir und der Vertreter kann diese nicht ausgeben. Wähle einen vertrauenswürdigen Vertreter mit einer hohen Erreichbarkeit."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("Was ist ein Vertreter?"),
        "reply": MessageLookupByLibrary.simpleMessage("Antworten"),
        "representatives": MessageLookupByLibrary.simpleMessage("Vertreter"),
        "request": MessageLookupByLibrary.simpleMessage("Anfrage"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Anfrage %1 %2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Anfrage fehlgeschlagen: Dieser Benutzer scheint Nautilus nicht installiert zu haben, oder Benachrichtigungen sind deaktiviert."),
        "requestFrom": MessageLookupByLibrary.simpleMessage("Anfrage von"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Zahlung anfragen"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Fehler beim Senden der Zahlungsaufforderung. Das Gerät des Empfängers ist möglicherweise offline oder nicht verfügbar."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Anfrage erneut gesendet! Falls immer noch nicht bestätigt, ist das Gerät des Empfängers möglicherweise offline."),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Fordern Sie eine Zahlung mit End-to-End-verschlüsselten Nachrichten an!\n\nZahlungsaufforderungen, Memos und Nachrichten können nur von anderen Nautilus-Benutzern empfangen werden, aber Sie können sie für Ihre eigenen Aufzeichnungen verwenden, auch wenn der Empfänger Nautilus nicht verwendet."),
        "requestSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Blattinfo anfordern"),
        "requested": MessageLookupByLibrary.simpleMessage("Angefragt"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Angefragt von"),
        "requesting": MessageLookupByLibrary.simpleMessage("Beantragen"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Passwortabfrage beim Öffnen der App?"),
        "requireCaptcha": MessageLookupByLibrary.simpleMessage(
            "Fordern Sie CAPTCHA an, um die Geschenkkarte anzufordern"),
        "resendMemo":
            MessageLookupByLibrary.simpleMessage("Dieses Memo erneut senden"),
        "resetAccountButton":
            MessageLookupByLibrary.simpleMessage("Konto zurücksetzen"),
        "resetAccountParagraph": MessageLookupByLibrary.simpleMessage(
            "Dadurch wird ein neues Konto mit dem Passwort erstellt, das Sie gerade festgelegt haben. Das alte Konto wird nicht gelöscht, es sei denn, die gewählten Passwörter sind dieselben."),
        "resetDatabase":
            MessageLookupByLibrary.simpleMessage("Die Datenbank zurücksetzen"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Möchten Sie die interne Datenbank wirklich zurücksetzen? \n\nDies kann Probleme im Zusammenhang mit der Aktualisierung der App beheben, aber auch alle gespeicherten Einstellungen werden gelöscht. Dadurch wird Ihr Wallet-Samen NICHT gelöscht. Wenn du Probleme hast, solltest du deinen Seed sichern, die App neu installieren und wenn das Problem weiterhin besteht, kannst du gerne einen Fehlerbericht auf Github oder Discord erstellen."),
        "retry":
            MessageLookupByLibrary.simpleMessage("Versuchen Sie es erneut"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "Es sieht aus, als seien Änderungen an deinem Gerät vorgenommen worden, welche dessen Sicherheit beeinträchtigen. Es wird empfohlen, das Gerät in seinen Originalzustand zurückzusetzen."),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Scanne einen\nNano-Address-QR-Code"),
        "scanNFC": MessageLookupByLibrary.simpleMessage("Über NFC senden"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("QR-Code scannen"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Suche nach irgendwas"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "Auf der nächsten Seite siehst du deine Geheimsequenz. Diese erlaubt dir Zugriff auf dein Guthaben. Es ist sehr wichtig, dass du sie sicherst und geheim hältst."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Sicherheit geht vor!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Geheimsequenz"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Geheimsequenz kopiert"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Geheimsequenz kopieren"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Solltest du dein Gerät verlieren oder die App löschen, benötigst du deine Geheimsequenz oder deinen Seed, um auf dein Guthaben zugreifen zu können!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Sicherheit"),
        "seed": MessageLookupByLibrary.simpleMessage("Seed"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Unten siehst du deinen Seed. Es ist extrem wichtig, dass du ein Backup deines Seeds erstellst. Sichere deinen Seed niemals als Klartext oder mit einem Screenshot."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Seed in Zwischenablage kopiert.\n Du kannst ihn jetzt 2 Minuten lang einfügen."),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("Seed kopiert"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Ein Seed enthält dieselben Informationen wie eine Geheimsequenz, ist jedoch maschinell lesbar. Solange du eines der beiden gesichert hast, hast du Zugriff auf dein Guthaben."),
        "seedInvalid":
            MessageLookupByLibrary.simpleMessage("Seed ist ungültig."),
        "selfSendError": MessageLookupByLibrary.simpleMessage(
            "Kann nicht von sich selbst anfragen"),
        "send": MessageLookupByLibrary.simpleMessage("Senden"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("%1 NANO senden?"),
        "sendAmounts": MessageLookupByLibrary.simpleMessage("Beträge senden"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "Ein Fehler ist aufgetreten. Versuche es später erneut."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Senden von"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Das Senden von Memos mit Transaktion ist fehlgeschlagen, sie sind möglicherweise kein Nautilus-Benutzer."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Nachricht wird gesendet"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Anfrage erneut senden"),
        "sendRequests": MessageLookupByLibrary.simpleMessage("Anfragen senden"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Senden oder fordern Sie eine Zahlung an, mit Ende-zu-Ende-verschlüsselten Nachrichten!\n\nZahlungsaufforderungen, Memos und Nachrichten können nur von anderen nautilus-Nutzern entgegengenommen werden.\n\nSie benötigen keinen Benutzernamen, um Zahlungsanfragen zu senden oder zu empfangen, und Sie können diese für Ihre eigenen Aufzeichnungen verwenden, auch wenn sie Nautilus nicht verwenden."),
        "sendSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Blattinfo senden"),
        "sending": MessageLookupByLibrary.simpleMessage("Sende"),
        "sent": MessageLookupByLibrary.simpleMessage("Gesendet"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Gesendet an"),
        "set": MessageLookupByLibrary.simpleMessage("Satz"),
        "setPassword":
            MessageLookupByLibrary.simpleMessage("Passwort festlegen"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Passwort erfolgreich festgelegt"),
        "setPin": MessageLookupByLibrary.simpleMessage("Pin setzen"),
        "setPinParagraph": MessageLookupByLibrary.simpleMessage(
            "Legen Sie Ihre bestehende PIN fest oder ändern Sie sie. Wenn Sie noch keine PIN festgelegt haben, lautet die Standard-PIN 000000."),
        "setPinSuccess": MessageLookupByLibrary.simpleMessage(
            "Pin wurde erfolgreich gesetzt"),
        "setPlausibleDeniabilityPin":
            MessageLookupByLibrary.simpleMessage("Plausiblen Pin setzen"),
        "setRestoreHeight": MessageLookupByLibrary.simpleMessage(
            "Stellen Sie die Wiederherstellungshöhe ein"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Wallet-Passwort festlegen"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "setXMRRestoreHeight": MessageLookupByLibrary.simpleMessage(
            "Stellen Sie die XMR-Wiederherstellungshöhe ein"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "settingsTransfer": MessageLookupByLibrary.simpleMessage(
            "Von Paper Wallet importieren"),
        "share": MessageLookupByLibrary.simpleMessage("Teilen"),
        "shareLink": MessageLookupByLibrary.simpleMessage("Link teilen"),
        "shareMessage":
            MessageLookupByLibrary.simpleMessage("Nachricht teilen"),
        "shareNautilus":
            MessageLookupByLibrary.simpleMessage("Nautilus teilen"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Probier mal Nautilus, Nanos offizielles Android-Wallet!"),
        "shareText": MessageLookupByLibrary.simpleMessage("Text teilen"),
        "shopButton": MessageLookupByLibrary.simpleMessage(""),
        "show": MessageLookupByLibrary.simpleMessage("Zeigen"),
        "showAccountInfo":
            MessageLookupByLibrary.simpleMessage("Kontoinformation"),
        "showAccountQR":
            MessageLookupByLibrary.simpleMessage("Konto-QR-Code anzeigen"),
        "showContacts":
            MessageLookupByLibrary.simpleMessage("Kontakte einblenden"),
        "showFunding": MessageLookupByLibrary.simpleMessage(
            "Finanzierungsbanner anzeigen"),
        "showLinkOptions":
            MessageLookupByLibrary.simpleMessage("Linkoptionen anzeigen"),
        "showLinkQR": MessageLookupByLibrary.simpleMessage("Link-QR anzeigen"),
        "showMoneroHeader":
            MessageLookupByLibrary.simpleMessage("Monero anzeigen"),
        "showMoneroInfo":
            MessageLookupByLibrary.simpleMessage("Monero-Bereich aktivieren"),
        "showQR": MessageLookupByLibrary.simpleMessage("QR-Code anzeigen"),
        "showUnopenedWarning":
            MessageLookupByLibrary.simpleMessage("Ungeöffnete Warnung"),
        "simplex": MessageLookupByLibrary.simpleMessage("Simplex"),
        "social": MessageLookupByLibrary.simpleMessage("Sozial"),
        "someone": MessageLookupByLibrary.simpleMessage("jemand"),
        "spendNano": MessageLookupByLibrary.simpleMessage("NANO ausgeben"),
        "splitBill": MessageLookupByLibrary.simpleMessage("Geteilte Rechnung"),
        "splitBillHeader":
            MessageLookupByLibrary.simpleMessage("Eine Rechnung teilen"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "Senden Sie eine Reihe von Zahlungsaufforderungen auf einmal! Macht es einfach, zum Beispiel eine Rechnung in einem Restaurant aufzuteilen."),
        "splitBillInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Split-Rechnungsinformationen"),
        "splitBy": MessageLookupByLibrary.simpleMessage("Geteilt durch"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment": MessageLookupByLibrary.simpleMessage(
            "Helfen Sie mit, die Entwicklung zu unterstützen"),
        "supportTheDeveloper": MessageLookupByLibrary.simpleMessage(
            "Unterstützen Sie den Entwickler"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("XMR tauschen"),
        "swapXMRHeader":
            MessageLookupByLibrary.simpleMessage("Monero tauschen"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "Monero ist eine datenschutzorientierte Kryptowährung, die es sehr schwierig oder sogar unmöglich macht, Transaktionen zu verfolgen. Inzwischen ist NANO eine zahlungsorientierte Kryptowährung, die schnell und gebührenfrei ist. Zusammen bieten sie einige der nützlichsten Aspekte von Kryptowährungen!\n\nVerwenden Sie diese Seite, um Ihren NANO ganz einfach gegen XMR auszutauschen!"),
        "swapping": MessageLookupByLibrary.simpleMessage("Austauschen"),
        "switchToSeed":
            MessageLookupByLibrary.simpleMessage("Zum Seed wechseln"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("Systemsprache"),
        "tapMessageToEdit": MessageLookupByLibrary.simpleMessage(
            "Tippe auf die Nachricht, um sie zu bearbeiten"),
        "tapToHide":
            MessageLookupByLibrary.simpleMessage("Zum Verbergen tippen"),
        "tapToReveal":
            MessageLookupByLibrary.simpleMessage("Zum Anzeigen tippen"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Thema"),
        "thisMayTakeSomeTime": MessageLookupByLibrary.simpleMessage(
            "das kann eine Weile dauern..."),
        "to": MessageLookupByLibrary.simpleMessage("An"),
        "tooManyFailedAttempts":
            MessageLookupByLibrary.simpleMessage("Zu viele Fehlversuche."),
        "trackingHeader":
            MessageLookupByLibrary.simpleMessage("Tracking-Autorisierung"),
        "trackingWarning":
            MessageLookupByLibrary.simpleMessage("Tracking deaktiviert"),
        "trackingWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Die Funktionalität der Geschenkkarte kann eingeschränkt sein oder überhaupt nicht funktionieren, wenn die Nachverfolgung deaktiviert ist. Wir verwenden diese Berechtigung AUSSCHLIESSLICH für diese Funktion. Absolut keine Ihrer Daten werden verkauft, gesammelt oder im Backend für irgendeinen Zweck verfolgt, der über den Bedarf hinausgeht"),
        "trackingWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Geschenkkarten-Links funktionieren nicht richtig"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transaktionen"),
        "transfer": MessageLookupByLibrary.simpleMessage("Transferieren"),
        "transferClose": MessageLookupByLibrary.simpleMessage(
            "Tippe, um das Fenster zu schließen."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO wurden erfolgreich an dein Nautilus Wallet gesendet."),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "Ein Wallet mit einem Guthaben von %1 NANO wurde gefunden.\n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "Tippe, um den Transfer zu bestätigen.\n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "Der Vorgang kann einige Sekunden dauern."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "Während des Transfers ist ein Fehler aufgetreten. Bitte versuche es später erneut."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Guthaben\ntransferieren"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "Dieser Vorgang wird das Guthaben vom Paper Wallet in dein Nautilus Wallet transferieren.\n\nTippe zum Starten auf \"%1\" ."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "Bei diesem Vorgang wird das Geld von einer Papiergeldbörse auf Ihre Nautilus-Brieftasche übertragen."),
        "transferLoading":
            MessageLookupByLibrary.simpleMessage("Transfer läuft"),
        "transferManualHint":
            MessageLookupByLibrary.simpleMessage("Seed eingeben."),
        "transferNoFunds": MessageLookupByLibrary.simpleMessage(
            "Dieser Seed enthält keine NANO."),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "Dieser QR Code enthält keinen gültigen Seed."),
        "transferQrScanHint": MessageLookupByLibrary.simpleMessage(
            "Scanne einen Nano \nSeed oder Private Key"),
        "unacknowledged": MessageLookupByLibrary.simpleMessage("unbestätigt"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("unbestätigt"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("nicht erfüllt"),
        "unlock": MessageLookupByLibrary.simpleMessage("Entsperrt"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Authentifizieren, um Nautilus zu entsperren"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "PIN eingeben, um Nautilus zu entsperren"),
        "unopenedWarningHeader": MessageLookupByLibrary.simpleMessage(
            "Ungeöffnete Warnung anzeigen"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "Zeigen Sie eine Warnung an, wenn Sie Geld an ein ungeöffnetes Konto senden. Dies ist nützlich, da die meisten Adressen, an die Sie senden, einen Saldo haben und das Senden an eine neue Adresse das Ergebnis eines Tippfehlers sein kann."),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "Sind Sie sicher, dass dies die richtige Adresse ist?\nDieses Konto scheint ungeöffnet zu sein\n\nSie können diese Warnung im Einstellungsfach unter \"Ungeöffnete Warnung\" deaktivieren."),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("Konto ungeöffnet"),
        "unpaid": MessageLookupByLibrary.simpleMessage("unbezahlt"),
        "unread": MessageLookupByLibrary.simpleMessage("ungelesen"),
        "uptime": MessageLookupByLibrary.simpleMessage("Verfügbarkeit"),
        "useNano": MessageLookupByLibrary.simpleMessage("NANO verwenden"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userAlreadyAddedError": MessageLookupByLibrary.simpleMessage(
            "Benutzer bereits hinzugefügt!"),
        "userNotFound": MessageLookupByLibrary.simpleMessage(
            "Der Benutzer wurde nicht gefunden!"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "Du hast bereits einen registrierten Nutzernamen! Es ist derzeit nicht möglich, deinen Nutzernamen zu ändern, aber es steht dir frei, einen neuen unter einer anderen Adresse zu registrieren."),
        "usernameAvailable":
            MessageLookupByLibrary.simpleMessage("Nutzername verfügbar!"),
        "usernameEmpty": MessageLookupByLibrary.simpleMessage(
            "Bitte gib einen Nutzernamen ein"),
        "usernameError":
            MessageLookupByLibrary.simpleMessage("Fehler beim Benutzernamen"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "Wähle ein einzigartiges @username aus, damit Freunde und Familie dich leichter finden können!\n\nMit einem Nautilus-Benutzernamen wird die Benutzeroberfläche weltweit aktualisiert, um Ihr neues Handle widerzuspiegeln."),
        "usernameInvalid":
            MessageLookupByLibrary.simpleMessage("Ungültiger Benutzername"),
        "usernameUnavailable":
            MessageLookupByLibrary.simpleMessage("Nutzername nicht verfügbar"),
        "usernameWarning": MessageLookupByLibrary.simpleMessage(
            "Nautilus-Benutzernamen sind ein zentralisierter Dienst von NANO.to"),
        "using": MessageLookupByLibrary.simpleMessage("Verwenden"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("Details ansehen"),
        "viewTX": MessageLookupByLibrary.simpleMessage("Transaktion anzeigen"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("Stimmgewicht"),
        "warning": MessageLookupByLibrary.simpleMessage("WARNUNG"),
        "watchAccountExists":
            MessageLookupByLibrary.simpleMessage("Konto bereits hinzugefügt!"),
        "watchOnlyAccount":
            MessageLookupByLibrary.simpleMessage("Nur Konto ansehen"),
        "watchOnlySendDisabled": MessageLookupByLibrary.simpleMessage(
            "Versendungen sind an Nur-Überwachungs-Adressen deaktiviert"),
        "weekAgo": MessageLookupByLibrary.simpleMessage("Vor einer Woche"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Willkommen bei Nautilus. Um fortzufahren, benötigst du ein Wallet. Erstelle bitte ein neues Wallet oder importiere ein bereits existierendes Wallet."),
        "welcomeTextLogin": MessageLookupByLibrary.simpleMessage(
            "Willkommen bei Nautilus. Wählen Sie eine Option, um loszulegen, oder wählen Sie ein Thema mit dem Symbol unten aus."),
        "welcomeTextUpdated": MessageLookupByLibrary.simpleMessage(
            "Willkommen bei Nautilus. Erstellen Sie zunächst eine neue Brieftasche oder importieren Sie eine vorhandene."),
        "welcomeTextWithoutLogin": MessageLookupByLibrary.simpleMessage(
            "Erstellen Sie zunächst eine neue Brieftasche oder importieren Sie eine vorhandene."),
        "withAddress": MessageLookupByLibrary.simpleMessage("Mit Adresse"),
        "withFee": MessageLookupByLibrary.simpleMessage("Mit Gebühr"),
        "withMessage": MessageLookupByLibrary.simpleMessage("Mit Nachricht"),
        "xMinute": MessageLookupByLibrary.simpleMessage("Nach %1 Minute"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("Nach %1 Minute"),
        "xmrStatusConnecting":
            MessageLookupByLibrary.simpleMessage("Verbinden"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("Fehler"),
        "xmrStatusLoading":
            MessageLookupByLibrary.simpleMessage("Wird geladen"),
        "xmrStatusSynchronized":
            MessageLookupByLibrary.simpleMessage("Synchronisiert"),
        "xmrStatusSynchronizing":
            MessageLookupByLibrary.simpleMessage("Synchronisieren"),
        "yes": MessageLookupByLibrary.simpleMessage("Ja"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Ja")
      };
}
