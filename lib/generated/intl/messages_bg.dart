// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a bg locale. All the
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
  String get localeName => 'bg';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Акаунт"),
        "accountNameHint": MessageLookupByLibrary.simpleMessage("Въведете име"),
        "accountNameMissing":
            MessageLookupByLibrary.simpleMessage("Изберете име на акаунт"),
        "accounts": MessageLookupByLibrary.simpleMessage("Акаунти"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Сигурни ли сте, че имате копие на тайната си фраза или Seed?"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Активно съобщение"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Добави Акаунт"),
        "addBlocked":
            MessageLookupByLibrary.simpleMessage("Блокиране на потребител"),
        "addContact": MessageLookupByLibrary.simpleMessage("Добави Контакт"),
        "addFavorite": MessageLookupByLibrary.simpleMessage("Добави Любими"),
        "addWatchOnlyAccount": MessageLookupByLibrary.simpleMessage(
            "Добавете акаунт само за гледане"),
        "addWatchOnlyAccountError": MessageLookupByLibrary.simpleMessage(
            "Грешка при добавяне на акаунт само за гледане: акаунтът беше нулев"),
        "addWatchOnlyAccountSuccess": MessageLookupByLibrary.simpleMessage(
            "Успешно създаден акаунт само за гледане!"),
        "address": MessageLookupByLibrary.simpleMessage("Адрес"),
        "addressCopied": MessageLookupByLibrary.simpleMessage("Адрес Копиран"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Въведи Адрес\n"),
        "addressMissing":
            MessageLookupByLibrary.simpleMessage("Моля въведете Адрес"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Моля, въведете потребителско име или адрес"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Сподели Адрес"),
        "aliases": MessageLookupByLibrary.simpleMessage("Псевдоними"),
        "amountGiftGreaterError": MessageLookupByLibrary.simpleMessage(
            "Разделената сума не може да бъде по-голяма от баланса на подаръка"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Моля въведете Сума"),
        "asked": MessageLookupByLibrary.simpleMessage("Попитан"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("Удостоверява се"),
        "authError": MessageLookupByLibrary.simpleMessage(
            "Възникна грешка при удостоверяване. Опитайте отново по-късно."),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Метод за Удостоверяване"),
        "authenticating":
            MessageLookupByLibrary.simpleMessage("Удостоверява се"),
        "autoImport": MessageLookupByLibrary.simpleMessage("Автоматичен внос"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Автоматично Заключване"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("Направих резервно копие"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Backup Секретната Фраза"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Съхрани Seed"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Сигурен ли си, че копира твоя Seed?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Съхрани своя Seed"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Биометрични"),
        "blockExplorer": MessageLookupByLibrary.simpleMessage("Експлорер"),
        "blockExplorerHeader": MessageLookupByLibrary.simpleMessage(
            "Блокиране на информация за изследователя"),
        "blockExplorerInfo": MessageLookupByLibrary.simpleMessage(
            "Кой блок изследовател да използва за показване на информация за транзакциите"),
        "blockUser": MessageLookupByLibrary.simpleMessage(
            "Блокиране на този потребител"),
        "blockedAdded":
            MessageLookupByLibrary.simpleMessage("% 1 е блокиран успешно."),
        "blockedExists": MessageLookupByLibrary.simpleMessage(
            "Потребителят вече е блокиран!"),
        "blockedHeader": MessageLookupByLibrary.simpleMessage("Блокиран"),
        "blockedInfo": MessageLookupByLibrary.simpleMessage(
            "Блокиране на потребител от всеки известен псевдоним или адрес. Всички съобщения, транзакции или искания от тях ще бъдат игнорирани."),
        "blockedInfoHeader":
            MessageLookupByLibrary.simpleMessage("Блокирана информация"),
        "blockedNameExists": MessageLookupByLibrary.simpleMessage(
            "Името на Ник вече се използва!"),
        "blockedNameMissing":
            MessageLookupByLibrary.simpleMessage("Изберете име на Ник"),
        "blockedRemoved":
            MessageLookupByLibrary.simpleMessage("% 1 е бил отблокиран!"),
        "branchConnectErrorLongDesc": MessageLookupByLibrary.simpleMessage(
            "Изглежда не можем да достигнем до Branch API, това обикновено се дължи на някакъв мрежов проблем или VPN блокиране на връзката.\n\n Все още трябва да можете да използвате приложението както обикновено, но изпращането и получаването на карти за подаръци може да не работи."),
        "branchConnectErrorShortDesc": MessageLookupByLibrary.simpleMessage(
            "Грешка: не може да се достигне до Branch API"),
        "branchConnectErrorTitle":
            MessageLookupByLibrary.simpleMessage("Предупреждение за връзка"),
        "cancel": MessageLookupByLibrary.simpleMessage("Отмени"),
        "changeCurrency": MessageLookupByLibrary.simpleMessage("Смени Валута"),
        "changeLog":
            MessageLookupByLibrary.simpleMessage("Промяна на дневника"),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Смени Представителя"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Смени"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Въведете нов Представител"),
        "changeRepSame": MessageLookupByLibrary.simpleMessage(
            "Това вече е твой представител!"),
        "changeRepSucces": MessageLookupByLibrary.simpleMessage(
            "Представителя е Сменен Успешно"),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Провери наличността"),
        "close": MessageLookupByLibrary.simpleMessage("Затвори"),
        "confirm": MessageLookupByLibrary.simpleMessage("Потвърди"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Потвърди паролата"),
        "confirmPinHint":
            MessageLookupByLibrary.simpleMessage("Потвърдете щифта"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Свързвам се"),
        "connectionWarning":
            MessageLookupByLibrary.simpleMessage("Не мога да се свържа"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "Изглежда не можем да се свържем с бекенда, това може да е просто вашата връзка или ако проблемът продължава, бекендът може да не работи поради поддръжка или дори прекъсване. Ако е минал повече от час и все още имате проблеми, моля, изпратете доклад в #bug-reports в сървъра на discord @ chat.perish.co"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Изглежда не можем да се свържем с бекенда, това може да е просто вашата връзка или ако проблемът продължава, бекендът може да не работи поради поддръжка или дори прекъсване. Ако е минал повече от час и все още имате проблеми, моля, изпратете доклад в #bug-reports в сървъра на discord @ chat.perish.co"),
        "connectionWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Изглежда не можем да се свържем с бекенда"),
        "contactAdded":
            MessageLookupByLibrary.simpleMessage("%1 добавен/и в Контакти."),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Контакта вече съществува"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Контакт"),
        "contactInvalid": MessageLookupByLibrary.simpleMessage("Невалидно Име"),
        "contactNameHint": MessageLookupByLibrary.simpleMessage("Въведи Име @"),
        "contactNameMissing":
            MessageLookupByLibrary.simpleMessage("Избери име за този Контакт."),
        "contactRemoved":
            MessageLookupByLibrary.simpleMessage("%1 премахнат/и от Контакти!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Контакти"),
        "contactsImportErr": MessageLookupByLibrary.simpleMessage(
            "Неуспешно импортиране на Контакти"),
        "contactsImportSuccess": MessageLookupByLibrary.simpleMessage(
            "Успешно добавен %1 контакт/и."),
        "copied": MessageLookupByLibrary.simpleMessage("Копирано"),
        "copy": MessageLookupByLibrary.simpleMessage("Копирай"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Копирай Адрес"),
        "copyLink":
            MessageLookupByLibrary.simpleMessage("Копиране на връзката"),
        "copyMessage":
            MessageLookupByLibrary.simpleMessage("Копиране на съобщение"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Копирай Seed"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Копиране на адреса на портфейла в клипборда"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Задай парола "),
        "createGiftCard":
            MessageLookupByLibrary.simpleMessage("Създайте Подаръчна Карта"),
        "createGiftHeader":
            MessageLookupByLibrary.simpleMessage("Създайте карта за подарък"),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "Може да зададете парола за да направите портфейла още по-сигурен"),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Задай парола "),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "Паролата не е задължителна и портфейлът ви ще бъде защитен с вашия ПИН или биометрични данни"),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Задай "),
        "createPinHint": MessageLookupByLibrary.simpleMessage("Създайте щифт"),
        "createQR": MessageLookupByLibrary.simpleMessage("Създаване на QR код"),
        "created": MessageLookupByLibrary.simpleMessage("създадено"),
        "creatingGiftCard": MessageLookupByLibrary.simpleMessage(
            "Създаване на Подаръчна Карта"),
        "currency": MessageLookupByLibrary.simpleMessage("Валута"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Валутен режим"),
        "currencyModeHeader": MessageLookupByLibrary.simpleMessage(
            "Информация за валутния режим"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Изберете в коя единица да се показват сумите.\n1 няно = 0.000001 НАНО, или \n1 000 000 нано = 1 NANO"),
        "currentlyRepresented":
            MessageLookupByLibrary.simpleMessage("Сегашният Представител е"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Грешка при декриптиране!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Основен Акаунт"),
        "defaultGiftMessage": MessageLookupByLibrary.simpleMessage(
            "Вижте Nautilus! Изпратих ви малко нано с тази връзка:"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Акаунт %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Изтриване"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Деактивирай"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Паролата е премахната"),
        "disableWalletPassword":
            MessageLookupByLibrary.simpleMessage("Премахни "),
        "dismiss": MessageLookupByLibrary.simpleMessage("Отхвърляне"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Невалидно име на домейн"),
        "donateButton": MessageLookupByLibrary.simpleMessage("Дарете"),
        "donateToSupport":
            MessageLookupByLibrary.simpleMessage("Подкрепете проекта"),
        "edit": MessageLookupByLibrary.simpleMessage("Редактиране"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Задаването на парола е невалидно"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("Въведи Адрес"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Въведи Сума"),
        "enterGiftMemo":
            MessageLookupByLibrary.simpleMessage("Въведете бележка за подарък"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("Въведете съобщение"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Въведи паролата"),
        "enterSplitAmount":
            MessageLookupByLibrary.simpleMessage("Въведете разделена сума"),
        "enterUserOrAddress": MessageLookupByLibrary.simpleMessage(
            "Въведете потребител или адрес"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Въведете потребителско име"),
        "errorProcessingGiftCard": MessageLookupByLibrary.simpleMessage(
            "Възникна грешка при обработката на тази карта за подарък, тя може да не е валидна, с изтекъл срок на валидност или празна."),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("от някого"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Добре Дошли в Nautilus. След като получите NANO, транзакциите ще се покажат по следния начин:"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Малко"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Много"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("за някого"),
        "examplePayRecipient": MessageLookupByLibrary.simpleMessage("@dad"),
        "examplePayRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Честит рожден ден!"),
        "examplePaymentExplainer": MessageLookupByLibrary.simpleMessage(
            "След като изпратите или получите заявка за плащане, те ще се покажат тук по този начин с цвета и етикета на картата, показващи състоянието. \n\nЗеленото показва, че заявката е платена.\nЖълто показва заявката/бележката не е била платена/прочетена.\nЧервеното показва, че заявката не е прочетена или получена.\n\n Неутралните цветни карти без сума са само съобщения."),
        "examplePaymentFrom": MessageLookupByLibrary.simpleMessage("@landlord"),
        "examplePaymentFulfilled":
            MessageLookupByLibrary.simpleMessage("Някои"),
        "examplePaymentFulfilledMemo":
            MessageLookupByLibrary.simpleMessage("Суши"),
        "examplePaymentIntro": MessageLookupByLibrary.simpleMessage(
            "След като изпратите или получите заявка за плащане, те ще се появят тук:"),
        "examplePaymentMessage":
            MessageLookupByLibrary.simpleMessage("Хей, какво става?"),
        "examplePaymentReceivable":
            MessageLookupByLibrary.simpleMessage("Много"),
        "examplePaymentReceivableMemo":
            MessageLookupByLibrary.simpleMessage("Наем"),
        "examplePaymentTo":
            MessageLookupByLibrary.simpleMessage("@best_friend"),
        "exampleRecRecipient":
            MessageLookupByLibrary.simpleMessage("@coworker"),
        "exampleRecRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Газови пари"),
        "exit": MessageLookupByLibrary.simpleMessage("Изход"),
        "failed": MessageLookupByLibrary.simpleMessage("провали"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader":
            MessageLookupByLibrary.simpleMessage("Наутилус е изключен"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "Nautilus Сървърите изглежда са прекъснати, Изпращането и получаването (без бележки) все още трябва да са оперативни, но заявките за плащане може да не преминават\n\n Върнете се по-късно или рестартирайте приложението, за да опитате отново"),
        "favoriteExists":
            MessageLookupByLibrary.simpleMessage("Любимата вече съществува"),
        "favoriteHeader": MessageLookupByLibrary.simpleMessage("Любими"),
        "favoriteInvalid":
            MessageLookupByLibrary.simpleMessage("Невалидно любимо име"),
        "favoriteNameHint":
            MessageLookupByLibrary.simpleMessage("Въведете име на Ник"),
        "favoriteNameMissing": MessageLookupByLibrary.simpleMessage(
            "Изберете име за този фаворит"),
        "favoriteRemoved":
            MessageLookupByLibrary.simpleMessage("% 1 е премахнат от любими!"),
        "favoritesHeader": MessageLookupByLibrary.simpleMessage("Любими"),
        "featured": MessageLookupByLibrary.simpleMessage("Препоръчани"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Удостовери за да съхраниш Seed."),
        "from": MessageLookupByLibrary.simpleMessage("От"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("изпълнени"),
        "fundingBannerHeader":
            MessageLookupByLibrary.simpleMessage("Банер за финансиране"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("Финансиране"),
        "getNano": MessageLookupByLibrary.simpleMessage("Вземете NANO"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("Имаш дарба!"),
        "giftAlertEmpty":
            MessageLookupByLibrary.simpleMessage("Празен Подарък"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("Сума За Подарък"),
        "giftCardCreationError": MessageLookupByLibrary.simpleMessage(
            "Възникна грешка при опит за създаване на връзка към карта за подарък"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "Възникна грешка при опит за създаване на карта за подарък, ВРЪЗКАТА КЪМ КАРТАТА ЗА ПОДАРЪК ИЛИ СЕМЕНАТА Е КОПИРАН ВЪВ ВАШИЯ КЛИПБОРД, ВАШИТЕ СРЕДСТВА МОЖЕ ДА СЕ СЪДЪРЖАТ В НЕГО В ЗАВИСИМОСТ ОТ КАКВО СЕ СЛУЧИ."),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Подарък От"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Заредете цифрова карта за подарък с NANO! Задайте сума и незадължително съобщение, което получателят да види, когато го отвори!\n\nВеднъж създаден, ще получите линк, който можете да изпратите на всеки, който при отваряне автоматично ще разпредели средствата на получателя след инсталирането на Nautilus!\n\nАко получателят вече е потребител на Nautilus, той ще получи подкана да прехвърли средствата в сметката си при отваряне на връзката"),
        "giftMessage":
            MessageLookupByLibrary.simpleMessage("Подарък Съобщение"),
        "giftProcessSuccess": MessageLookupByLibrary.simpleMessage(
            "Подаръкът е получен успешно, може да отнеме известно време, докато се появи в портфейла ви."),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Върни се"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Отидете на QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Готово!"),
        "handoff": MessageLookupByLibrary.simpleMessage("не пипай"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage(
            "Нещо се обърка при опит за блокиране на прехвърлянето!"),
        "handoffSupportedMethodNotFound": MessageLookupByLibrary.simpleMessage(
            "Поддържан метод за прехвърляне не може да бъде намерен!"),
        "hide": MessageLookupByLibrary.simpleMessage("Скрий"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Скрий Акаунт?"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Сигурни ли сте, че искате да скриете празните акаунти?\n\nТова ще скрие всички акаунти с баланс точно 0 (с изключение на адресите само за гледане и основния ви акаунт), но винаги можете да ги добавите отново по-късно, като докоснете бутона „Добавяне на акаунт“"),
        "hideAccountsHeader":
            MessageLookupByLibrary.simpleMessage("Скриване на акаунти?"),
        "hideEmptyAccounts": MessageLookupByLibrary.simpleMessage(
            "Скриване на празните акаунти"),
        "home": MessageLookupByLibrary.simpleMessage("У дома"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("Разбирам рисковете"),
        "ignore": MessageLookupByLibrary.simpleMessage("Игнорирай"),
        "imSure": MessageLookupByLibrary.simpleMessage("Сигурен съм"),
        "import": MessageLookupByLibrary.simpleMessage("Импортирай"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "Връзката, която сте кликнали, съдържа малко нано, бихте ли искали да го импортирате в този портфейл или да го възстановите на този, който го е изпратил?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "Изглежда, че сте кликнали върху връзка, която съдържа малко NANO, за да получим тези средства, трябва само да завършите настройката на портфейла си."),
        "importGiftv2": MessageLookupByLibrary.simpleMessage(
            "Връзката, върху която сте кликнали, съдържа малко NANO, искате ли да го импортирате в този портфейл?"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Импортирай тайната фраза"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Моля, въведете вашата тайна фраза от 24 думи по-долу.  Всяка дума трябва да бъде отделена с интервал."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Импортирай seed"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage(
            "Моля въведете вашият Seed по-долу."),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Вместо това Импортирай Seed"),
        "importWallet":
            MessageLookupByLibrary.simpleMessage("Импортирай Портфейл"),
        "instantly": MessageLookupByLibrary.simpleMessage("Веднага"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Недостатъчен Баланс"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "Пропуснахме въвеждащия процес, за да ви спестим време, но трябва незабавно да архивирате новосъздадения начален файл.\n\nАко загубите своето семе, ще загубите достъп до средствата си.\n\nОсвен това паролата ви е зададена на \"000000\", която също трябва да промените незабавно."),
        "introSkippedWarningHeader":
            MessageLookupByLibrary.simpleMessage("Архивирайте вашето семе!"),
        "invalidAddress": MessageLookupByLibrary.simpleMessage(
            "Въведеният Адрес е невалиден"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Грешна парола "),
        "invalidPin": MessageLookupByLibrary.simpleMessage("Невалиден ПИН"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "Поради указанията и ограниченията на iOS App Store, не можем да ви свържем с нашата страница за дарения. Ако искате да подкрепите проекта, помислете за изпращане до адреса на възела nautilus."),
        "language": MessageLookupByLibrary.simpleMessage("Език"),
        "linkCopied":
            MessageLookupByLibrary.simpleMessage("Връзката е копирана"),
        "loaded": MessageLookupByLibrary.simpleMessage("Заредени"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Заредени в"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Удостовери на Стартиране"),
        "locked": MessageLookupByLibrary.simpleMessage("Заключено"),
        "logout": MessageLookupByLibrary.simpleMessage("Отпиши се"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Изтрий Seed и се Отпиши"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Сигурен ли си?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Отписването ще премахне вашият Seed и всички свързани с Nautilus данни от това устройство. Ако вашият Seed няма резервно копие, вие никога повече няма да имате достъп до вашите средства."),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Ако имате резервно копие на вашия Seed, няма за какво да се тревожите."),
        "manage": MessageLookupByLibrary.simpleMessage("Управление"),
        "mantaError":
            MessageLookupByLibrary.simpleMessage("Потвърждението неуспешно "),
        "manualEntry": MessageLookupByLibrary.simpleMessage("Ръчно въвеждане"),
        "markAsPaid":
            MessageLookupByLibrary.simpleMessage("Маркиране като платено"),
        "markAsUnpaid":
            MessageLookupByLibrary.simpleMessage("Маркиране като неплатено"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Бележката е изпратена отново! Ако все още не е признато, устройството на получателя може да е офлайн."),
        "messageCopied":
            MessageLookupByLibrary.simpleMessage("Съобщението е копирано"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Съобщение"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "Мин сума за изпращане %1 NANO"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 не е валидна дума"),
        "mnemonicPhrase":
            MessageLookupByLibrary.simpleMessage("Мнемонична фраза"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Тайната фраза може да съдържа само 24 думи"),
        "monthlyServerCosts":
            MessageLookupByLibrary.simpleMessage("Месечни разходи за сървър"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings": MessageLookupByLibrary.simpleMessage("Още настройки"),
        "natricon": MessageLookupByLibrary.simpleMessage("Натрикона"),
        "nautilusWallet":
            MessageLookupByLibrary.simpleMessage("Портфейл Nautilus"),
        "nearby": MessageLookupByLibrary.simpleMessage("Наблизо"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "Тази функция изисква да имате по-дълга история на транзакциите, за да предотвратите спам.\n\nКато алтернатива можете да покажете QR код, който някой да сканира."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Необходима е проверка"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Това е вашият нов акаунт. След като получите NANO, транзакциите ще се покажат по следният начин:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Нов Портфейл"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Следващ"),
        "no": MessageLookupByLibrary.simpleMessage("Не"),
        "noContactsExport":
            MessageLookupByLibrary.simpleMessage("Няма контакти за експорт"),
        "noContactsImport": MessageLookupByLibrary.simpleMessage(
            "Няма нови контакти за импорт."),
        "noSearchResults": MessageLookupByLibrary.simpleMessage(
            "Няма резултати от търсенето!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("Не, пропусни"),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("Статус на възела"),
        "notSent": MessageLookupByLibrary.simpleMessage("не е изпратено"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Отвори Nautilus за да видиш тази транзакция"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Натисни за да отвориш"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "За да може тази функция да работи правилно, уведомленията трябва да бъдат активирани"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Получени %1 NANO"),
        "notifications": MessageLookupByLibrary.simpleMessage("Известия"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Нианикон"),
        "off": MessageLookupByLibrary.simpleMessage("Изкл."),
        "ok": MessageLookupByLibrary.simpleMessage("ОК"),
        "onStr": MessageLookupByLibrary.simpleMessage("Вкл."),
        "onramp": MessageLookupByLibrary.simpleMessage("Onramp"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Отворен"),
        "paid": MessageLookupByLibrary.simpleMessage("платени"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("Хартиен Портфейл"),
        "passwordBlank": MessageLookupByLibrary.simpleMessage(
            "Полето за парола не може да е празно"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Няма да се изисква повече парола за да се отвори Nautilus."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Тази парола ще се изисква за да се отвори Nautilus."),
        "passwordsDontMatch":
            MessageLookupByLibrary.simpleMessage("Паролите не съвпадат"),
        "pay": MessageLookupByLibrary.simpleMessage("Плати"),
        "payRequest": MessageLookupByLibrary.simpleMessage("Плати тази заявка"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Някой е поискал плащане от вас! проверете страницата за плащания за повече информация."),
        "payments": MessageLookupByLibrary.simpleMessage("Плащания"),
        "pickFromList": MessageLookupByLibrary.simpleMessage("Избери от листа"),
        "pinBlank":
            MessageLookupByLibrary.simpleMessage("Pin не може да бъде празен"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("ПИН-а не съвпада"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Потвърдете вашият ПИН"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Създайте 6-цифрен ПИН-код"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("Въведете ПИН"),
        "pinInvalid":
            MessageLookupByLibrary.simpleMessage("Въведен е невалиден ПИН"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("ПИН-код"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "Въведете ПИН за да смените Представителя."),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Въведи ПИН за да съхраниш Seed"),
        "pinsDontMatch":
            MessageLookupByLibrary.simpleMessage("Щифтовете не съвпадат"),
        "plausibleDeniabilityParagraph": MessageLookupByLibrary.simpleMessage(
            "Това НЕ е същият щифт, който сте използвали, за да създадете своя портфейл. Натиснете бутона информация за повече информация."),
        "plausibleInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Правдоподобна информация за отричане"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Задайте вторичен щифт за правдоподобен режим на отказ.\n\nАко вашият портфейл е отключен с помощта на този вторичен щифт, вашето семе ще бъде заменено с хеш на съществуващото семе. Това е защитна функция, предназначена да се използва в случай, че сте принудени да отворите портфейла си.\n\nТози щифт ще действа като нормален (правилен) щифт ОСВЕН при отключване на портфейла ви, когато ще се активира правдоподобният режим на отказ.\n\nВашите средства ЩЕ БЪДАТ ЗАГУБЕНИ при влизане в правдоподобен режим на отказ, ако не сте направили резервно копие на вашето семе!"),
        "preferences": MessageLookupByLibrary.simpleMessage("Предпочитания"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Декларация за Поверителност"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Покупка Нано"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR кода не съдържа валидна дестинация "),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Моля дайте разрешение на Камера да сканира QR код"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "QR-кода не съдържа валиден Seed или Личен Ключ"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "QR не съдържа валидна тайна фраза"),
        "qrUnknownError": MessageLookupByLibrary.simpleMessage(
            "Не може да се прочете QR кода"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp":
            MessageLookupByLibrary.simpleMessage("Оценете приложението"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "Ако ви харесва приложението, помислете да отделите време, за да го прегледате,\nТова наистина помага и не трябва да отнеме повече от минута."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Raw Seed"),
        "readMore": MessageLookupByLibrary.simpleMessage("Прочети повече"),
        "receivable": MessageLookupByLibrary.simpleMessage("вземания"),
        "receive": MessageLookupByLibrary.simpleMessage("Получи"),
        "receiveMinimum":
            MessageLookupByLibrary.simpleMessage("Получаване на минимум"),
        "receiveMinimumHeader": MessageLookupByLibrary.simpleMessage(
            "Получаване на минимална информация"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "Минимална сума за получаване. Ако плащането или искането е получено със сума, по-малка от тази, тя ще бъде игнорирана."),
        "received": MessageLookupByLibrary.simpleMessage("Получено"),
        "refund": MessageLookupByLibrary.simpleMessage("Възстановяване"),
        "registerFor": MessageLookupByLibrary.simpleMessage("за"),
        "registerUsername": MessageLookupByLibrary.simpleMessage(
            "Регистриране на потребителско име"),
        "registerUsernameHeader": MessageLookupByLibrary.simpleMessage(
            "Регистриране на потребителско име"),
        "registering": MessageLookupByLibrary.simpleMessage("Регистриране"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Наистина ли искате да скриете този акаунт? Може да го добавите по-късно като натиснете бутона  \"%1\"."),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("Отблокиране"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Сигурни ли сте, че искате да деблокирате% 1?"),
        "removeContact":
            MessageLookupByLibrary.simpleMessage("Премахни Контакт"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Сигурен ли си, че искаш да изтриеш %1?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Премахване на любими"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "Представител е акаунт, който гласува за мрежови консенсус. Силата на глас се измерва по критерий средства, вие можете да делегирате своят баланс за да увеличите гласовата тежест на представителя, на който се доверявате. Вашият Представител не разполага със сила да изразходи вашите средства. Трябва да изберете Представител, който е надежден и често онлайн."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("Какво е Представител?"),
        "reply": MessageLookupByLibrary.simpleMessage("Отговор"),
        "representatives":
            MessageLookupByLibrary.simpleMessage("Представители"),
        "request": MessageLookupByLibrary.simpleMessage("Заявка"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Заявка% 1% 2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Заявката е неуспешна: Изглежда, че този потребител няма инсталиран Nautilus или известията са деактивирани."),
        "requestFrom": MessageLookupByLibrary.simpleMessage("Заявка от"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Заявка за плащане"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Грешка при изпращане на заявка за плащане, устройството на получателя може да е офлайн или недостъпно."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Заявката е изпратена отново! Ако все още не е признато, устройството на получателя може да е офлайн."),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Поискайте плащане с криптирани от край до край съобщения!\n\nЗаявките за плащане, бележките и съобщенията ще могат да се получават само от други потребители на nautilus, но можете да ги използвате за собствено водене на записи, дори ако получателят не използва nautilus."),
        "requestSheetInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Искане на информация за лист"),
        "requested": MessageLookupByLibrary.simpleMessage("Заявени"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Искано от"),
        "requesting": MessageLookupByLibrary.simpleMessage("Искане"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Да се изисква парола за отваряне на Nautilus?"),
        "resendMemo": MessageLookupByLibrary.simpleMessage(
            "Повторно изпращане на тази бележка"),
        "resetDatabase":
            MessageLookupByLibrary.simpleMessage("Нулиране на базата данни"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Сигурни ли сте, че искате да възстановите вътрешната база данни? \n\nТова може да отстрани проблеми, свързани с актуализирането на приложението, но също така ще изтрие всички запазени предпочитания. Това няма да изтрие семената на портфейла ви. Ако имате проблеми, трябва да архивирате семето си, да инсталирате отново приложението и ако проблемът продължава, не се колебайте да направите доклад за грешки в github или раздора."),
        "retry": MessageLookupByLibrary.simpleMessage("Повторен опит"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "Изглежда вашето устройство е “рутнато”, “джейлбрейкнато” или модифицирано така, че да може да бъде компроментирано. Препоръчително е да върнете устройството към фабрични настройки преди да продължите. "),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Сканирай Nano адрес или QR-код"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Сканирай QR-код"),
        "searchHint":
            MessageLookupByLibrary.simpleMessage("Търсете каквото и да е"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "На следващия екран ще видите тайната си фраза.  Това е парола за достъп до средствата ви.  От решаващо значение е да я архивирате и никога да не я споделяте с никого."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Първо безопасността!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Тайна фраза"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Тайната Фраза Копирана"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Копирай Тайната Фраза"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Ако загубите устройството си или деинсталирате приложението, ще се нуждаете от тайната си фраза или Seed, за да възстановите средствата си!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Сигурност"),
        "seed": MessageLookupByLibrary.simpleMessage("Seed"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "По-долу се намира твоя Seed. Много е важно да го съхраниш на сигурно място, но никога като обикновен текст или скрийншот."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Seed Копиран в Клипборда. Ще бъде съхранен там за 2 минути."),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("Seed Копиран"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Seed носят същата информация като тайната фраза, но по начин, който може да се чете от машина.  Докато имате едната от тях, ще имате достъп до средствата си."),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("Seed Невалиден"),
        "selfSendError": MessageLookupByLibrary.simpleMessage(
            "Не мога да поискам от себе си"),
        "send": MessageLookupByLibrary.simpleMessage("Изпрати"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Изпрати %1 NANO"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "Възникна грешка. Опитайте по-късно."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Изпрати от"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Изпращането на бележка с транзакция е неуспешно, те може да не са потребител на Nautilus."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Изпращане на съобщение"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Изпратете Заявка отново"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Изпратете или поискайте плащане с криптирани съобщения от край до край!\n\nИсканията за плащане, бележки и съобщения ще бъдат получени само от други потребители на nautilus.\n\nНе е необходимо да имате потребителско име, за да изпращате или получавате заявки за плащане, и можете да ги използвате за собствено водене на записи, дори ако те не използват nautilus."),
        "sendSheetInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Изпращане на информация за листа"),
        "sendViaNFC":
            MessageLookupByLibrary.simpleMessage("Изпращане чрез NFC"),
        "sending": MessageLookupByLibrary.simpleMessage("Изпращам"),
        "sent": MessageLookupByLibrary.simpleMessage("Изпратено"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Изпратено до"),
        "setPassword": MessageLookupByLibrary.simpleMessage("Задай парола"),
        "setPasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Паролата е зададена успешно"),
        "setPin": MessageLookupByLibrary.simpleMessage("Задайте ПИН"),
        "setPinSuccess":
            MessageLookupByLibrary.simpleMessage("ПИН кодът е зададен успешно"),
        "setPlausibleDeniabilityPin": MessageLookupByLibrary.simpleMessage(
            "Задаване на правдоподобен щифт"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Задай парола на Портфейла"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Настройки"),
        "settingsTransfer":
            MessageLookupByLibrary.simpleMessage("Зареди от Хартиен Портфейл"),
        "shareLink":
            MessageLookupByLibrary.simpleMessage("Споделяне на връзка"),
        "shareMessage":
            MessageLookupByLibrary.simpleMessage("Споделете съобщение"),
        "shareNautilus":
            MessageLookupByLibrary.simpleMessage("Сподели Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Виж Nautilus! Водещият NANO мобилен портфейл!"),
        "show": MessageLookupByLibrary.simpleMessage("Покажи"),
        "showAccountQR": MessageLookupByLibrary.simpleMessage(
            "Показване на QR кода на акаунта"),
        "showContacts":
            MessageLookupByLibrary.simpleMessage("Показване на контактите"),
        "showFunding": MessageLookupByLibrary.simpleMessage(
            "Показване на банера за финансиране"),
        "showLinkQR":
            MessageLookupByLibrary.simpleMessage("Показване на връзка QR"),
        "showQR": MessageLookupByLibrary.simpleMessage("Показване на QR код"),
        "showUnopenedWarning":
            MessageLookupByLibrary.simpleMessage("Неотворено предупреждение"),
        "simplex": MessageLookupByLibrary.simpleMessage("Симплекс"),
        "someone": MessageLookupByLibrary.simpleMessage("някой"),
        "spendNano": MessageLookupByLibrary.simpleMessage("Прекарайте NANO"),
        "splitBy": MessageLookupByLibrary.simpleMessage("Разделяне по"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment": MessageLookupByLibrary.simpleMessage(
            "Помощ за поддръжка на развитието"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Подкрепа на разработчика"),
        "switchToSeed":
            MessageLookupByLibrary.simpleMessage("Премини към Seed"),
        "systemDefault":
            MessageLookupByLibrary.simpleMessage("По Подразбиране"),
        "tapMessageToEdit": MessageLookupByLibrary.simpleMessage(
            "Докоснете съобщение за редактиране"),
        "tapToHide":
            MessageLookupByLibrary.simpleMessage("Докосни за да скриеш"),
        "tapToReveal":
            MessageLookupByLibrary.simpleMessage("Докосни за да разкриеш"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Тема"),
        "to": MessageLookupByLibrary.simpleMessage("До"),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "Твърде много неуспешни опити за отключване."),
        "transactions": MessageLookupByLibrary.simpleMessage("Транзакции"),
        "transfer": MessageLookupByLibrary.simpleMessage("Прехвърли"),
        "transferClose": MessageLookupByLibrary.simpleMessage(
            "Докоснете някъде, за да затворите прозореца."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO успешно прехвърлени към вашият Nautilus Портфейл.\n"),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "Портфейл с баланс от %1 NANO е открит.\n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "Натиснете да потвърдите прехвърлянето на средствата.\n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "Прехвърлянето може да отнеме няколко секунди."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "Възникна грешка по време на прехвърлянето. Моля опитайте по-късно."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Прехвърли Средства"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "Този процес ще прехвърли вашите средства от Хартиен Портфейл към Nautilus Портфейл.\n\nНатиснете \"%1\" бутона за Старт."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "Този процес ще прехвърли средствата от хартиен портфейл към портфейла ви Nautilus."),
        "transferLoading": MessageLookupByLibrary.simpleMessage("Прехвърляне"),
        "transferManualHint":
            MessageLookupByLibrary.simpleMessage("Моля въведете Seed по-долу."),
        "transferNoFunds": MessageLookupByLibrary.simpleMessage(
            "Този Seed не съдържа NANO на него."),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "Този QR-код не съдържа валиден Seed."),
        "transferQrScanHint": MessageLookupByLibrary.simpleMessage(
            "Сканирайте Nano \nSeed или Личен Ключ."),
        "unacknowledged": MessageLookupByLibrary.simpleMessage("непризнат"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("Непотвърдена"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("неизпълнени"),
        "unlock": MessageLookupByLibrary.simpleMessage("Отключи"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Удостовери за Отключване на Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Въведи ПИН за да отключиш Nautilus"),
        "unopenedWarningHeader": MessageLookupByLibrary.simpleMessage(
            "Показване на неотворено предупреждение"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "Показвайте предупреждение, когато изпращате средства към неотворена сметка, това е полезно, защото повечето пъти адресите, до които изпращате, ще имат баланс, а изпращането до нов адрес може да е резултат от печатна грешка."),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "Сигурни ли сте, че това е правилният адрес?\nТози акаунт изглежда не е отворен\n\nМожете да деактивирате това предупреждение в чекмеджето с настройки под „Неотворено предупреждение“"),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("Неотворен акаунт"),
        "unpaid": MessageLookupByLibrary.simpleMessage("неплатени"),
        "unread": MessageLookupByLibrary.simpleMessage("непрочетени"),
        "uptime": MessageLookupByLibrary.simpleMessage("Ъптайм"),
        "useNano": MessageLookupByLibrary.simpleMessage("Използвайте NANO"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userNotFound":
            MessageLookupByLibrary.simpleMessage("Потребителят не е намерен!"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "Вече имате регистрирано потребителско име! Понастоящем не е възможно да промените потребителското си име, но можете да регистрирате ново под друг адрес."),
        "usernameAvailable": MessageLookupByLibrary.simpleMessage(
            "Потребителско име на разположение!"),
        "usernameEmpty": MessageLookupByLibrary.simpleMessage(
            "Моля, въведете потребителско име"),
        "usernameError":
            MessageLookupByLibrary.simpleMessage("Потребителско име Грешка"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "Изберете уникален @username, за да улесните приятелите и семейството ви да ви намерят!\n\nНаличието на потребителско име на Nautilus актуализира потребителския интерфейс в световен мащаб, за да отразява новата ви дръжка."),
        "usernameInvalid":
            MessageLookupByLibrary.simpleMessage("Невалидно потребителско име"),
        "usernameUnavailable": MessageLookupByLibrary.simpleMessage(
            "Потребителското име не е налице"),
        "usernameWarning": MessageLookupByLibrary.simpleMessage(
            "Потребителските имена на Nautilus са централизирана услуга, предоставяна от Nano.to"),
        "using": MessageLookupByLibrary.simpleMessage("Използвайки"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("Виж Детайли"),
        "viewTX":
            MessageLookupByLibrary.simpleMessage("Преглед на транзакцията"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("Гласова Тежест"),
        "warning": MessageLookupByLibrary.simpleMessage("ВНИМАНИЕ"),
        "watchAccountExists":
            MessageLookupByLibrary.simpleMessage("Акаунтът вече е добавен!"),
        "watchOnlyAccount":
            MessageLookupByLibrary.simpleMessage("Акаунт само за гледане"),
        "watchOnlySendDisabled": MessageLookupByLibrary.simpleMessage(
            "Изпращанията са деактивирани на адреси само за гледане"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Добре дошли в Nautilus. За да започнете, можете да създадете нов портфейл или да импортирате вече съществуващ."),
        "welcomeTextUpdated": MessageLookupByLibrary.simpleMessage(
            "Добре дошли в Наутилус. За да започнете, създайте нов портфейл или импортирайте съществуващ."),
        "withAddress": MessageLookupByLibrary.simpleMessage("С адрес"),
        "withMessage": MessageLookupByLibrary.simpleMessage("Със Съобщение"),
        "xMinute": MessageLookupByLibrary.simpleMessage("След %1 минута"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("След %1 минути"),
        "yes": MessageLookupByLibrary.simpleMessage("Да"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Да")
      };
}