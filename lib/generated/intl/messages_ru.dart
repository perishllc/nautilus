// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Счёт"),
        "accountNameHint": MessageLookupByLibrary.simpleMessage("Введите имя"),
        "accountNameMissing":
            MessageLookupByLibrary.simpleMessage("Выберите имя учетной записи"),
        "accounts": MessageLookupByLibrary.simpleMessage("Счета"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что у вас есть копия вашей секретной фразы или Seed?"),
        "activateSub":
            MessageLookupByLibrary.simpleMessage("Активировать подписку"),
        "activeMessageHeader":
            MessageLookupByLibrary.simpleMessage("Активное сообщение"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Добавить аккаунт"),
        "addAddress": MessageLookupByLibrary.simpleMessage("Добавить адрес"),
        "addBlocked":
            MessageLookupByLibrary.simpleMessage("Заблокировать пользователя"),
        "addContact": MessageLookupByLibrary.simpleMessage("Добавить Контакт"),
        "addFavorite":
            MessageLookupByLibrary.simpleMessage("Добавить избранное"),
        "addNode": MessageLookupByLibrary.simpleMessage("Добавить узел"),
        "addSubscription":
            MessageLookupByLibrary.simpleMessage("Добавить подписку"),
        "addUser":
            MessageLookupByLibrary.simpleMessage("Добавить пользователя"),
        "addWatchOnlyAccount": MessageLookupByLibrary.simpleMessage(
            "Добавить учетную запись только для просмотра"),
        "addWatchOnlyAccountError": MessageLookupByLibrary.simpleMessage(
            "Ошибка при добавлении учетной записи только для просмотра: учетная запись недействительна."),
        "addWatchOnlyAccountSuccess": MessageLookupByLibrary.simpleMessage(
            "Аккаунт только для просмотра успешно создан!"),
        "addWorkSource":
            MessageLookupByLibrary.simpleMessage("Добавить источник работы"),
        "address": MessageLookupByLibrary.simpleMessage("Адрес"),
        "addressCopied":
            MessageLookupByLibrary.simpleMessage("Адрес скопирован"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Введите адрес"),
        "addressMissing":
            MessageLookupByLibrary.simpleMessage("Пожалуйста введите адрес"),
        "addressOrUserMissing": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите имя пользователя или адрес"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Отправить"),
        "advanced": MessageLookupByLibrary.simpleMessage("Передовой"),
        "aliases": MessageLookupByLibrary.simpleMessage("Псевдонимы"),
        "amount": MessageLookupByLibrary.simpleMessage("Количество"),
        "amountGiftGreaterError": MessageLookupByLibrary.simpleMessage(
            "Сумма разделения не может превышать баланс подарка"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Пожалуйста введите сумму"),
        "appWallet": MessageLookupByLibrary.simpleMessage("%1 кошелек"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "Мы заметили, что вы нажали на ссылку, содержащую нано. Хотите пропустить процесс установки? Вы всегда можете изменить ситуацию позже.\n\n Однако, если у вас есть семя, которое вы хотите импортировать, вам следует выбрать нет."),
        "askTracking": MessageLookupByLibrary.simpleMessage(
            "Мы собираемся запросить разрешение на «отслеживание», оно используется *строго* для атрибуции ссылок / рефералов и незначительной аналитики (например, количество установок, версия приложения и т. д.). Мы считаем, что вы имеете право на вашу конфиденциальность и не заинтересованы в каких-либо ваших личных данных, нам просто нужно разрешение, чтобы атрибуция ссылок работала правильно."),
        "asked": MessageLookupByLibrary.simpleMessage("Спросил"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("Аутентификация"),
        "authError": MessageLookupByLibrary.simpleMessage(
            "Произошла ошибка при аутентификации. Попробуйте позже."),
        "authMethod": MessageLookupByLibrary.simpleMessage("Аутентификация"),
        "authenticating":
            MessageLookupByLibrary.simpleMessage("Аутентификация"),
        "autoImport":
            MessageLookupByLibrary.simpleMessage("Автоматический импорт"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Автоблокировка"),
        "autoRenewSub": MessageLookupByLibrary.simpleMessage(
            "Автоматическое продление подписки"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("Я сделал резервную копию"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Резервная Секретная Фраза"),
        "backupSeed":
            MessageLookupByLibrary.simpleMessage("Резервное копирование Seed"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Вы уверены,что сохранили Seed?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Резервное копирование Seed"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Биометрия"),
        "blockExplorer":
            MessageLookupByLibrary.simpleMessage("Блок-обозреватель"),
        "blockExplorerHeader": MessageLookupByLibrary.simpleMessage(
            "Информация обозревателя блоков"),
        "blockExplorerInfo": MessageLookupByLibrary.simpleMessage(
            "Какой обозреватель блоков использовать для отображения информации о транзакциях"),
        "blockUser": MessageLookupByLibrary.simpleMessage(
            "Заблокировать этого пользователя"),
        "blockedAdded":
            MessageLookupByLibrary.simpleMessage("% 1 успешно заблокирован."),
        "blockedExists": MessageLookupByLibrary.simpleMessage(
            "Пользователь уже заблокирован!"),
        "blockedHeader": MessageLookupByLibrary.simpleMessage("Заблокировано"),
        "blockedInfo": MessageLookupByLibrary.simpleMessage(
            "Заблокировать пользователя по любому известному псевдониму или адресу. Любые сообщения, транзакции или запросы от них будут игнорироваться."),
        "blockedInfoHeader":
            MessageLookupByLibrary.simpleMessage("Заблокированная информация"),
        "blockedNameExists":
            MessageLookupByLibrary.simpleMessage("Ник уже используется!"),
        "blockedNameMissing":
            MessageLookupByLibrary.simpleMessage("Выберите псевдоним"),
        "blockedRemoved":
            MessageLookupByLibrary.simpleMessage("% 1 разблокирован!"),
        "branchConnectErrorLongDesc": MessageLookupByLibrary.simpleMessage(
            "Кажется, мы не можем получить доступ к Branch API, обычно это происходит из-за какой-то проблемы с сетью или VPN, блокирующей соединение.\n\n Вы по-прежнему сможете использовать приложение как обычно, однако отправка и получение подарочных карт могут не работать."),
        "branchConnectErrorShortDesc": MessageLookupByLibrary.simpleMessage(
            "Ошибка: не удается получить доступ к Branch API"),
        "branchConnectErrorTitle": MessageLookupByLibrary.simpleMessage(
            "Предупреждение о подключении"),
        "businessButton": MessageLookupByLibrary.simpleMessage("Бизнес"),
        "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "cancelSub": MessageLookupByLibrary.simpleMessage("Отменить подписку"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("Капча"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "Во избежание злоупотреблений мы требуем, чтобы вы разгадали капчу, чтобы получить подарочную карту на следующей странице."),
        "changeCurrency":
            MessageLookupByLibrary.simpleMessage("Сменить Валюту"),
        "changeLog": MessageLookupByLibrary.simpleMessage("Журнал изменений"),
        "changeNode": MessageLookupByLibrary.simpleMessage("Изменить узел"),
        "changeNodeInfo": MessageLookupByLibrary.simpleMessage(
            "Измените узел, к которому вы подключены. Это позволяет вам подключиться к другому узлу, если у вас возникли проблемы с узлом по умолчанию, или просто если вы хотите подключиться к тому, который вы размещаете сами. Узел используется для отправки транзакций и получения обновлений о вашей учетной записи."),
        "changePassword":
            MessageLookupByLibrary.simpleMessage("Изменить пароль"),
        "changePasswordParagraph": MessageLookupByLibrary.simpleMessage(
            "Измените существующий пароль. Если вы не знаете свой текущий пароль, просто сделайте предположение, так как на самом деле менять его не требуется (поскольку вы уже вошли в систему), но это позволяет нам удалить существующую запись резервной копии."),
        "changePin": MessageLookupByLibrary.simpleMessage("Изменить пин"),
        "changePinHint":
            MessageLookupByLibrary.simpleMessage("Установите булавку"),
        "changePow": MessageLookupByLibrary.simpleMessage("Изменить PoW"),
        "changePowSource":
            MessageLookupByLibrary.simpleMessage("Изменить источник PoW"),
        "changePowSourceInfo": MessageLookupByLibrary.simpleMessage(
            "Измените источник PoW, используемый для отправки и получения транзакций."),
        "changeRepAuthenticate":
            MessageLookupByLibrary.simpleMessage("Сменить представителя"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("Изменить"),
        "changeRepHint":
            MessageLookupByLibrary.simpleMessage("Новый представитель"),
        "changeRepSame":
            MessageLookupByLibrary.simpleMessage("Это уже ваш представитель!"),
        "changeRepSucces": MessageLookupByLibrary.simpleMessage(
            "Представитель успешно изменён."),
        "changeSeed": MessageLookupByLibrary.simpleMessage("Изменить семя"),
        "changeSeedParagraph": MessageLookupByLibrary.simpleMessage(
            "Измените начальное число/фразу, связанную с этой учетной записью с авторизацией по магической ссылке, любой пароль, который вы установите здесь, перезапишет ваш существующий пароль, но вы можете использовать тот же пароль, если хотите."),
        "checkAvailability":
            MessageLookupByLibrary.simpleMessage("Проверить доступность"),
        "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
        "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Подтвердите пароль"),
        "confirmPinHint":
            MessageLookupByLibrary.simpleMessage("Подтвердите пин-код"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Подключение"),
        "connectionWarning":
            MessageLookupByLibrary.simpleMessage("Не могу подключиться"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "Кажется, мы не можем подключиться к серверной части, это может быть просто ваше соединение, или, если проблема не устранена, серверная часть может быть отключена для обслуживания или даже простоя. Если прошло больше часа, а проблемы все еще возникают, отправьте отчет в #bug-reports на сервере разногласий @ chat.perish.co."),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Кажется, мы не можем подключиться к серверной части, это может быть просто ваше соединение, или, если проблема не устранена, серверная часть может быть отключена для обслуживания или даже простоя. Если прошло больше часа, а проблемы все еще возникают, отправьте отчет в #bug-reports на сервере разногласий @ chat.perish.co."),
        "connectionWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Мы не можем подключиться к серверной части"),
        "contactAdded":
            MessageLookupByLibrary.simpleMessage("%1 добавлен в контакты!"),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Контакт уже существует"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Контакт"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Недопустимое имя"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Введите имя @"),
        "contactNameMissing":
            MessageLookupByLibrary.simpleMessage("Выберите имя для контакта"),
        "contactRemoved":
            MessageLookupByLibrary.simpleMessage("%1 удален из контактов!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Контакты"),
        "contactsImportErr":
            MessageLookupByLibrary.simpleMessage("Не удалось импортировать"),
        "contactsImportSuccess":
            MessageLookupByLibrary.simpleMessage("Успешно импортированы %1"),
        "continueButton": MessageLookupByLibrary.simpleMessage("Продолжать"),
        "continueWithoutLogin":
            MessageLookupByLibrary.simpleMessage("Продолжить без входа"),
        "copied": MessageLookupByLibrary.simpleMessage("Скопировано"),
        "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Копировать адрес"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Скопировать ссылку"),
        "copyMessage":
            MessageLookupByLibrary.simpleMessage("Копировать сообщение"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Копировать Seed"),
        "copyWalletAddressToClipboard": MessageLookupByLibrary.simpleMessage(
            "Скопировать адрес кошелька в буфер обмена"),
        "copyXMRSeed":
            MessageLookupByLibrary.simpleMessage("Копировать семя Monero"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Создать пароль."),
        "createGiftCard":
            MessageLookupByLibrary.simpleMessage("Создать подарочную карту"),
        "createGiftHeader":
            MessageLookupByLibrary.simpleMessage("Создайте подарочную карту"),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "Вы можете создать пароль для дополнительной безопасности кошелька."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Создать пароль"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "Пароль не является обязательным, и ваш кошелек будет защищен вашим PIN-кодом или биометрической информацией."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Создать"),
        "createPinHint":
            MessageLookupByLibrary.simpleMessage("Создать булавку"),
        "createQR": MessageLookupByLibrary.simpleMessage("Создать QR-код"),
        "created": MessageLookupByLibrary.simpleMessage("созданный"),
        "creatingGiftCard":
            MessageLookupByLibrary.simpleMessage("Создание подарочной карты"),
        "currency": MessageLookupByLibrary.simpleMessage("Валюта"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("Режим валюты"),
        "currencyModeHeader": MessageLookupByLibrary.simpleMessage(
            "Информация о валютном режиме"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "Выберите единицу измерения для отображения сумм.\n1 ньяно = 0,000001 НАНО, или \n1 000 000 ньяно = 1 НАНО"),
        "currentlyRepresented": MessageLookupByLibrary.simpleMessage(
            "В настоящее время представлен"),
        "dayAgo": MessageLookupByLibrary.simpleMessage("День назад"),
        "decryptionError":
            MessageLookupByLibrary.simpleMessage("Ошибка дешифрования!"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Основной счёт"),
        "defaultGiftMessage": MessageLookupByLibrary.simpleMessage(
            "Обратите внимание на Наутилус! Я отправил вам нано по этой ссылке:"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Счёт %1"),
        "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "deleteAccount":
            MessageLookupByLibrary.simpleMessage("Удалить аккаунт"),
        "deleteNodeConfirmation": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этот узел?\n\nВы всегда можете повторно добавить его позже, нажав кнопку «Добавить узел»."),
        "deleteNodeHeader":
            MessageLookupByLibrary.simpleMessage("Удалить узел?"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "deleteSubConfirmation": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить эту подписку?\n\nВы всегда можете повторно добавить ее позже, нажав кнопку «Добавить подписку»."),
        "deleteSubHeader":
            MessageLookupByLibrary.simpleMessage("Удалить подписку?"),
        "deleteWorkSourceConfirmation": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите удалить этот рабочий источник?\n\nВы всегда можете повторно добавить его позже, нажав кнопку «Добавить рабочий источник»."),
        "deleteWorkSourceHeader":
            MessageLookupByLibrary.simpleMessage("Удалить рабочий источник?"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Отключить"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Пароль был отключен"),
        "disableWalletPassword":
            MessageLookupByLibrary.simpleMessage("Отключить пароль"),
        "dismiss": MessageLookupByLibrary.simpleMessage("Отклонить"),
        "doYouHaveSeedBody": MessageLookupByLibrary.simpleMessage(
            "Если вы не уверены, что это значит, то, вероятно, у вас нет сидов для импорта, и вы можете просто нажать «Продолжить»."),
        "doYouHaveSeedHeader": MessageLookupByLibrary.simpleMessage(
            "У вас есть семена для импорта?"),
        "domainInvalid":
            MessageLookupByLibrary.simpleMessage("Неверное доменное имя"),
        "donateButton": MessageLookupByLibrary.simpleMessage("Пожертвовать"),
        "donateToSupport":
            MessageLookupByLibrary.simpleMessage("Поддержите проект"),
        "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
        "enableNotifications":
            MessageLookupByLibrary.simpleMessage("Включить уведомления"),
        "enableTracking":
            MessageLookupByLibrary.simpleMessage("Включить отслеживание"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Не удалось установить пароль"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("Введите Адрес"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Введите Сумму"),
        "enterEmail": MessageLookupByLibrary.simpleMessage(
            "Введите адрес электронной почты"),
        "enterFrequency":
            MessageLookupByLibrary.simpleMessage("Введите частоту"),
        "enterGiftMemo": MessageLookupByLibrary.simpleMessage(
            "Введите примечание к подарку"),
        "enterHeight": MessageLookupByLibrary.simpleMessage("Введите рост"),
        "enterHttpUrl":
            MessageLookupByLibrary.simpleMessage("Введите URL-адрес HTTP"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("Введите сообщение"),
        "enterMoneroAddress":
            MessageLookupByLibrary.simpleMessage("Введите XMR-адрес"),
        "enterName": MessageLookupByLibrary.simpleMessage("Введите имя"),
        "enterNodeName":
            MessageLookupByLibrary.simpleMessage("Введите имя узла"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Введите свой пароль"),
        "enterSplitAmount":
            MessageLookupByLibrary.simpleMessage("Введите сумму разделения"),
        "enterUserOrAddress": MessageLookupByLibrary.simpleMessage(
            "Введите пользователя или адрес"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Введите имя пользователя"),
        "enterWsUrl": MessageLookupByLibrary.simpleMessage(
            "Введите URL-адрес веб-сокета"),
        "errorProcessingGiftCard": MessageLookupByLibrary.simpleMessage(
            "При обработке этой подарочной карты произошла ошибка. Возможно, она недействительна, просрочена или пуста."),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("от кого-то"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Добро пожаловать в Nautilus.Когда вы получите или отправите NANO,это будет отображено ниже."),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Немного"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Много"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("кому-то"),
        "examplePayRecipient": MessageLookupByLibrary.simpleMessage("@dad"),
        "examplePayRecipientMessage":
            MessageLookupByLibrary.simpleMessage("С Днем Рождения!"),
        "examplePaymentExplainer": MessageLookupByLibrary.simpleMessage(
            "Как только вы отправите или получите запрос на оплату, они появятся здесь следующим образом с цветом и биркой карты, указывающими статус. \n\nЗеленый цвет означает, что запрос оплачен.\nЖелтый цвет означает, что запрос/памятка не оплачен/прочитана.\nКрасный цвет означает, что запрос не был прочитан или получен.\n\n Карточки нейтрального цвета без суммы — это просто сообщения."),
        "examplePaymentFrom": MessageLookupByLibrary.simpleMessage("@landlord"),
        "examplePaymentFulfilled":
            MessageLookupByLibrary.simpleMessage("Некоторые"),
        "examplePaymentFulfilledMemo":
            MessageLookupByLibrary.simpleMessage("Суши"),
        "examplePaymentIntro": MessageLookupByLibrary.simpleMessage(
            "Как только вы отправите или получите запрос на оплату, они появятся здесь:"),
        "examplePaymentMessage":
            MessageLookupByLibrary.simpleMessage("Эй, что такое?"),
        "examplePaymentReceivable":
            MessageLookupByLibrary.simpleMessage("Много"),
        "examplePaymentReceivableMemo":
            MessageLookupByLibrary.simpleMessage("Аренда"),
        "examplePaymentTo":
            MessageLookupByLibrary.simpleMessage("@best_friend"),
        "exampleRecRecipient":
            MessageLookupByLibrary.simpleMessage("@coworker"),
        "exampleRecRecipientMessage":
            MessageLookupByLibrary.simpleMessage("Газовые деньги"),
        "exchangeCurrency": MessageLookupByLibrary.simpleMessage("Обмен %2"),
        "exchangeNano": MessageLookupByLibrary.simpleMessage("Обмен НАНО"),
        "existingPasswordHint":
            MessageLookupByLibrary.simpleMessage("Введите текущий пароль"),
        "existingPinHint":
            MessageLookupByLibrary.simpleMessage("Введите текущий пин-код"),
        "exit": MessageLookupByLibrary.simpleMessage("Выход"),
        "exportTXData":
            MessageLookupByLibrary.simpleMessage("Экспорт транзакций"),
        "failed": MessageLookupByLibrary.simpleMessage("не удалось"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader":
            MessageLookupByLibrary.simpleMessage("«Наутилус отключен»"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "Кажется, что серверы Nautilus отключены, отправка и получение (без заметок) должны оставаться в рабочем состоянии, но запросы на оплату могут не проходить\n\n Вернитесь позже или перезапустите приложение, чтобы повторить попытку"),
        "favoriteExists":
            MessageLookupByLibrary.simpleMessage("Избранное уже существует"),
        "favoriteHeader": MessageLookupByLibrary.simpleMessage("Фаворит"),
        "favoriteInvalid":
            MessageLookupByLibrary.simpleMessage("Неверное имя избранного"),
        "favoriteNameHint":
            MessageLookupByLibrary.simpleMessage("Введите псевдоним"),
        "favoriteNameMissing": MessageLookupByLibrary.simpleMessage(
            "Выберите имя для этого избранного"),
        "favoriteRemoved":
            MessageLookupByLibrary.simpleMessage("% 1 удален из избранного!"),
        "favoritesHeader": MessageLookupByLibrary.simpleMessage("Избранное"),
        "featured": MessageLookupByLibrary.simpleMessage("Рекомендуемые"),
        "fewDaysAgo":
            MessageLookupByLibrary.simpleMessage("Несколько дней назад"),
        "fewHoursAgo":
            MessageLookupByLibrary.simpleMessage("Несколько часов назад"),
        "fewMinutesAgo":
            MessageLookupByLibrary.simpleMessage("Несколько минут назад"),
        "fewSecondsAgo":
            MessageLookupByLibrary.simpleMessage("Несколько секунд назад"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Аутентификация для резервного копирования Seed."),
        "frequencyEmpty":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите частоту"),
        "from": MessageLookupByLibrary.simpleMessage("От"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("выполнивших"),
        "fundingBannerHeader":
            MessageLookupByLibrary.simpleMessage("Баннер финансирования"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("Финансирование"),
        "getCurrency": MessageLookupByLibrary.simpleMessage("Получить %2"),
        "getNano": MessageLookupByLibrary.simpleMessage("Получить НАНО"),
        "giftAlert":
            MessageLookupByLibrary.simpleMessage("У тебя есть подарок!"),
        "giftAlertEmpty":
            MessageLookupByLibrary.simpleMessage("Пустой подарок"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("Сумма подарка"),
        "giftCardCreationError": MessageLookupByLibrary.simpleMessage(
            "Произошла ошибка при попытке создать ссылку на подарочную карту"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "Произошла ошибка при попытке создать подарочную карту, ССЫЛКА ИЛИ SEED НА ПОДАРОЧНУЮ КАРТУ БЫЛА скопирована в буфер обмена, ВАШИ СРЕДСТВА МОГУТ СОДЕРЖАТЬСЯ В НЕМ, В ЗАВИСИМОСТИ ОТ ТОГО, ЧТО ПОШЛО НЕ ТАК."),
        "giftCardInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Информация о подарочном листе"),
        "giftFrom": MessageLookupByLibrary.simpleMessage("Подарок от"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "Загрузите цифровую подарочную карту с NANO! Задайте сумму и необязательное сообщение, которое получатель увидит, когда откроет его!\n\nПосле создания вы получите ссылку, которую можете отправить кому угодно, которая при открытии автоматически распределит средства получателю после установки Nautilus!\n\nЕсли получатель уже является пользователем Nautilus, он получит приглашение перевести средства на свой счет при переходе по ссылке."),
        "giftMessage":
            MessageLookupByLibrary.simpleMessage("Сообщение о подарке"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "При обработке подарочной карты произошла ошибка. Возможно, проверьте ваше соединение и попробуйте еще раз щелкнуть ссылку подарка."),
        "giftProcessSuccess": MessageLookupByLibrary.simpleMessage(
            "Подарок успешно получен, может пройти некоторое время, прежде чем он появится в вашем кошельке."),
        "giftRefundSuccess":
            MessageLookupByLibrary.simpleMessage("Подарок успешно возвращен!"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Назад"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("Перейти к QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Готово!"),
        "handoff": MessageLookupByLibrary.simpleMessage("руки прочь"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage(
            "Что-то пошло не так при попытке передать блокировку!"),
        "handoffSupportedMethodNotFound": MessageLookupByLibrary.simpleMessage(
            "Поддерживаемый метод передачи обслуживания не найден!"),
        "haveSeedToImport":
            MessageLookupByLibrary.simpleMessage("у меня есть семя"),
        "hide": MessageLookupByLibrary.simpleMessage("Скрыть"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Скрыть аккаунт?"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите скрыть пустые аккаунты?\n\nЭто скроет все учетные записи с балансом ровно 0 (за исключением адресов только для просмотра и вашей основной учетной записи), но вы всегда сможете повторно добавить их позже, нажав кнопку «Добавить учетную запись»."),
        "hideAccountsHeader":
            MessageLookupByLibrary.simpleMessage("Скрыть учетные записи?"),
        "hideEmptyAccounts":
            MessageLookupByLibrary.simpleMessage("Скрыть пустые аккаунты"),
        "home": MessageLookupByLibrary.simpleMessage("Главная"),
        "homeButton": MessageLookupByLibrary.simpleMessage("Дом"),
        "hourAgo": MessageLookupByLibrary.simpleMessage("Час назад"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("Я понимаю риски"),
        "ignore": MessageLookupByLibrary.simpleMessage("Игнорировать"),
        "imSure": MessageLookupByLibrary.simpleMessage("Я уверен"),
        "import": MessageLookupByLibrary.simpleMessage("Импорт"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "Ссылка, по которой вы нажали, содержит nano, хотите ли вы импортировать ее в этот кошелек или вернуть ее тому, кто ее отправил?"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "Похоже, вы нажали на ссылку, которая содержит немного NANO, чтобы получить эти средства, нам просто нужно, чтобы вы завершили настройку своего кошелька."),
        "importGiftv2": MessageLookupByLibrary.simpleMessage(
            "Ссылка, по которой вы щелкнули, содержит некоторое количество NANO. Вы хотите импортировать его в этот кошелек?"),
        "importHD": MessageLookupByLibrary.simpleMessage("Импорт HD"),
        "importSecretPhrase": MessageLookupByLibrary.simpleMessage(
            "Импортировать секретную фразу"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите вашу секретную фразу из 24 слов ниже, каждое слово должно быть разделено пробелом."),
        "importSeed":
            MessageLookupByLibrary.simpleMessage("Импортировать  Seed"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите ваш Seed ниже."),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Импортируйте Seed"),
        "importStandard":
            MessageLookupByLibrary.simpleMessage("Стандарт импорта"),
        "importWallet": MessageLookupByLibrary.simpleMessage("Импортировать"),
        "instantly": MessageLookupByLibrary.simpleMessage("Немедленно"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Недостаточный баланс"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "Мы пропустили вводный процесс, чтобы сэкономить ваше время, но вам следует немедленно сделать резервную копию только что созданного начального числа.\n\nЕсли вы потеряете свой seed, вы потеряете доступ к своим средствам.\n\nКроме того, ваш пароль был установлен на «000000», который вы также должны немедленно изменить."),
        "introSkippedWarningHeader": MessageLookupByLibrary.simpleMessage(
            "Сделайте резервную копию вашего семени!"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Введен неверный адрес"),
        "invalidFrequency":
            MessageLookupByLibrary.simpleMessage("Частота недействительна"),
        "invalidHeight": MessageLookupByLibrary.simpleMessage("Неверный рост"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Неправильный пароль"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("Неверный PIN-код"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "Из-за правил и ограничений iOS App Store мы не можем связать вас с нашей страницей пожертвований. Если вы хотите поддержать проект, рассмотрите возможность отправки на адрес узла nautilus."),
        "language": MessageLookupByLibrary.simpleMessage("Язык"),
        "linkCopied":
            MessageLookupByLibrary.simpleMessage("Ссылка скопирована"),
        "loaded": MessageLookupByLibrary.simpleMessage("Загружен"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("Загружено в"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Аутентификация при запуске"),
        "locked": MessageLookupByLibrary.simpleMessage("Закрыт"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Авторизоваться"),
        "loginOrRegisterHeader": MessageLookupByLibrary.simpleMessage(
            "Войдите или зарегистрируйтесь"),
        "logout": MessageLookupByLibrary.simpleMessage("Выход"),
        "logoutAction": MessageLookupByLibrary.simpleMessage(
            "Удаление Seed и выход из системы."),
        "logoutAreYouSure": MessageLookupByLibrary.simpleMessage("Вы уверены?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Выход из системы приведёт к удалению Seed и всех связанных с Nautilus данных с этого устройства.Если ваш Seed не будет скопирован,вы больше никогда не сможете получить доступ к своим средствам."),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Если вы создали резервную копию своего Seed,вам не о чем беспокоиться"),
        "looksLikeHdSeed": MessageLookupByLibrary.simpleMessage(
            "Похоже, это семя HD, если вы не уверены, что знаете, что делаете, вместо этого вам следует использовать опцию «Импорт HD»."),
        "looksLikeStandardSeed": MessageLookupByLibrary.simpleMessage(
            "Похоже, это стандартное семя, вместо этого вы должны использовать опцию «Импорт стандарта»."),
        "manage": MessageLookupByLibrary.simpleMessage("Управление"),
        "mantaError":
            MessageLookupByLibrary.simpleMessage("Не удалось проверить запрос"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("Ручной ввод"),
        "markAsPaid":
            MessageLookupByLibrary.simpleMessage("Отметить как оплаченный"),
        "markAsUnpaid":
            MessageLookupByLibrary.simpleMessage("Отметить как неопла"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Памятка отправлена повторно! Если все еще не подтверждено, устройство получателя может быть отключено."),
        "messageCopied":
            MessageLookupByLibrary.simpleMessage("Сообщение скопировано"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("Сообщение"),
        "minimumSend": MessageLookupByLibrary.simpleMessage(
            "Минимум сумма отправки % 1 NANO "),
        "minuteAgo": MessageLookupByLibrary.simpleMessage("Минуту назад"),
        "mnemonicInvalidWord": MessageLookupByLibrary.simpleMessage(
            "%1 не является допустимым словом"),
        "mnemonicPhrase":
            MessageLookupByLibrary.simpleMessage("Мнемоническая фраза"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Секретная фраза может содержать только 24 слова"),
        "monthlyServerCosts": MessageLookupByLibrary.simpleMessage(
            "Ежемесячные расходы на сервер"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings": MessageLookupByLibrary.simpleMessage("Больше настроек"),
        "nameEmpty":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите имя"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "nautilusWallet":
            MessageLookupByLibrary.simpleMessage("Кошелек Наутилус"),
        "nearby": MessageLookupByLibrary.simpleMessage("Рядом, поблизости"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "Эта функция требует более длительной истории транзакций, чтобы предотвратить спам.\n\nКроме того, вы можете показать QR-код для сканирования."),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("Необходима верификация"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Это ваш новый аккаунт. Как только вы получите NANO, транзакции будут выглядеть так:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Новый кошелёк"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Далее"),
        "nextPayment": MessageLookupByLibrary.simpleMessage("Следующий платеж"),
        "no": MessageLookupByLibrary.simpleMessage("Нет"),
        "noContactsExport":
            MessageLookupByLibrary.simpleMessage("Нет контактов для экспорта"),
        "noContactsImport":
            MessageLookupByLibrary.simpleMessage("Нет контактов для импорта"),
        "noSearchResults":
            MessageLookupByLibrary.simpleMessage("Нет результатов поиска!"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("Нет, пропустить"),
        "noTXDataExport": MessageLookupByLibrary.simpleMessage(
            "Нет транзакций для экспорта."),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "node": MessageLookupByLibrary.simpleMessage("Узел"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("Статус узла"),
        "nodes": MessageLookupByLibrary.simpleMessage("Узлы"),
        "noneMethod": MessageLookupByLibrary.simpleMessage("Никто"),
        "notSent": MessageLookupByLibrary.simpleMessage("не отправлено"),
        "notificationBody": MessageLookupByLibrary.simpleMessage(
            "Откройте Nautilus для просмотра."),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("Нажмите чтобы открыть"),
        "notificationInfo": MessageLookupByLibrary.simpleMessage(
            "Чтобы эта функция работала правильно, уведомления должны быть включены"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Получено %1 NANO"),
        "notificationWarning":
            MessageLookupByLibrary.simpleMessage("Уведомления отключены"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Платежные запросы, заметки и сообщения требуют включения уведомлений для правильной работы, поскольку они используют службу уведомлений FCM для обеспечения доставки сообщений.\n\nВы можете включить уведомления с помощью кнопки ниже или закрыть эту карточку, если не хотите использовать эти функции."),
        "notificationWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Платежные запросы, заметки и сообщения не будут работать должным образом."),
        "notifications": MessageLookupByLibrary.simpleMessage("Уведомления"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Ньяникон"),
        "obscureInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Неясная информация о транзакции"),
        "obscureTransaction":
            MessageLookupByLibrary.simpleMessage("Неясная транзакция"),
        "obscureTransactionBody": MessageLookupByLibrary.simpleMessage(
            "Это НЕ настоящая конфиденциальность, но получателю будет сложнее увидеть, кто отправил ему средства."),
        "off": MessageLookupByLibrary.simpleMessage("Выкл."),
        "ok": MessageLookupByLibrary.simpleMessage("Ок"),
        "onStr": MessageLookupByLibrary.simpleMessage("Вкл."),
        "onboard":
            MessageLookupByLibrary.simpleMessage("Пригласить кого-нибудь"),
        "onboarding": MessageLookupByLibrary.simpleMessage("Онбординг"),
        "onramp": MessageLookupByLibrary.simpleMessage("На рампе"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("Открыт"),
        "paid": MessageLookupByLibrary.simpleMessage("оплаченный"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("Paper кошелёк"),
        "passwordBlank":
            MessageLookupByLibrary.simpleMessage("Пароль не может быть пустым"),
        "passwordCapitalLetter": MessageLookupByLibrary.simpleMessage(
            "Пароль должен содержать как минимум 1 заглавную и строчную буквы"),
        "passwordDisclaimer": MessageLookupByLibrary.simpleMessage(
            "Мы не несем ответственности, если вы забудете свой пароль, и мы не можем сбросить или изменить его за вас."),
        "passwordIncorrect":
            MessageLookupByLibrary.simpleMessage("неверный пароль"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Вам больше не понадобится пароль, чтобы открыть Nautilus."),
        "passwordNumber": MessageLookupByLibrary.simpleMessage(
            "Пароль должен содержать не менее 1 цифры"),
        "passwordSpecialCharacter": MessageLookupByLibrary.simpleMessage(
            "Пароль должен содержать не менее 1 специального символа"),
        "passwordTooShort":
            MessageLookupByLibrary.simpleMessage("Пароль слишком короткий"),
        "passwordWarning": MessageLookupByLibrary.simpleMessage(
            "Этот пароль потребуется для открытия Nautilus."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Этот пароль потребуется для открытия Nautilus."),
        "passwordsDontMatch":
            MessageLookupByLibrary.simpleMessage("Пароли не совпадают"),
        "pay": MessageLookupByLibrary.simpleMessage("Оплатить"),
        "payRequest":
            MessageLookupByLibrary.simpleMessage("Оплатить этот запрос"),
        "paymentHistory":
            MessageLookupByLibrary.simpleMessage("История платежей"),
        "paymentRequestMessage": MessageLookupByLibrary.simpleMessage(
            "Кто-то запросил у вас оплату! посетите страницу платежей для получения дополнительной информации."),
        "payments": MessageLookupByLibrary.simpleMessage("Платежи"),
        "pickFromList":
            MessageLookupByLibrary.simpleMessage("Выбрать из списка"),
        "pinBlank": MessageLookupByLibrary.simpleMessage(
            "PIN-код не может быть пустым"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("PIN не совпадают."),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Подтвердите PIN"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Создать 6-значный PIN."),
        "pinEnterTitle":
            MessageLookupByLibrary.simpleMessage("Введите PIN-код"),
        "pinIncorrect":
            MessageLookupByLibrary.simpleMessage("Введен неверный пин"),
        "pinInvalid":
            MessageLookupByLibrary.simpleMessage("Введён неверный PIN код."),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage(
            "Введите PIN для смены представителя"),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Введите PIN для резервного копирования Seed."),
        "pinsDontMatch":
            MessageLookupByLibrary.simpleMessage("Пины не совпадают"),
        "plausibleDeniabilityParagraph": MessageLookupByLibrary.simpleMessage(
            "Это НЕ тот же пин-код, который вы использовали для создания своего кошелька. Нажмите кнопку информации для получения дополнительной информации."),
        "plausibleInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Информация о правдоподобном отрицании"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Установите вторичный контакт для правдоподобного режима отрицания.\n\nЕсли ваш кошелек разблокирован с помощью этого вторичного пин-кода, ваш сид будет заменен хэшем существующего сид-кода. Это функция безопасности, предназначенная для использования в случае, если вы будете вынуждены открыть свой кошелек.\n\nЭтот пин-код будет действовать как обычный (правильный) пин-код, ЗА ИСКЛЮЧЕНИЕМ разблокировки вашего кошелька, когда активируется режим правдоподобного отрицания.\n\nВаши средства БУДУТ ПОТЕРЯНЫ при входе в режим правдоподобного отрицания, если вы не создали резервную копию своего начального числа!"),
        "pow": MessageLookupByLibrary.simpleMessage("PoW"),
        "preferences": MessageLookupByLibrary.simpleMessage("Предпочтения"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Политика"),
        "proSubRequiredHeader": MessageLookupByLibrary.simpleMessage(
            "Требуется подписка Nautilus Pro"),
        "proSubRequiredParagraph": MessageLookupByLibrary.simpleMessage(
            "Всего за 1 NANO в месяц вы можете разблокировать все функции Nautilus Pro."),
        "promotionalLink":
            MessageLookupByLibrary.simpleMessage("Бесплатно НАНО"),
        "purchaseCurrency": MessageLookupByLibrary.simpleMessage("Купить %2"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("Приобрести нано"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR-не содержит действительный адрес"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, предоставьте разрешения камеры для сканирования QR"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "QR-код не содержит действительный Seed или закрытый ключ"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "QR не содержит действительной секретной фразы"),
        "qrUnknownError":
            MessageLookupByLibrary.simpleMessage("Не удалось прочитать QR-код"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp":
            MessageLookupByLibrary.simpleMessage("Оцените приложение"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "Если вам нравится приложение, подумайте о том, чтобы проверить его,\nЭто действительно помогает, и это займет не больше минуты."),
        "rawSeed": MessageLookupByLibrary.simpleMessage("Сырой Seed"),
        "readMore": MessageLookupByLibrary.simpleMessage("Подробнее"),
        "receivable": MessageLookupByLibrary.simpleMessage("приемлемый"),
        "receive": MessageLookupByLibrary.simpleMessage("Получить"),
        "receiveMinimum":
            MessageLookupByLibrary.simpleMessage("Минимум получения"),
        "receiveMinimumHeader": MessageLookupByLibrary.simpleMessage(
            "Получение минимальной информации"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "Минимальная сумма для получения. Если платеж или запрос получен на сумму меньше указанной, они будут проигнорированы."),
        "received": MessageLookupByLibrary.simpleMessage("Получено"),
        "refund": MessageLookupByLibrary.simpleMessage("Возврат"),
        "registerButton": MessageLookupByLibrary.simpleMessage("регистр"),
        "registerFor": MessageLookupByLibrary.simpleMessage("для"),
        "registerUsername": MessageLookupByLibrary.simpleMessage(
            "Зарегистрировать имя пользователя"),
        "registerUsernameHeader": MessageLookupByLibrary.simpleMessage(
            "Зарегистрируйте имя пользователя"),
        "registering": MessageLookupByLibrary.simpleMessage("Регистрация"),
        "remove": MessageLookupByLibrary.simpleMessage("Удалять"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите скрыть аккаунт? Вы можете добавить его снова, нажав кнопку \"%1\"."),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("Разблокировать"),
        "removeBlockedConfirmation": MessageLookupByLibrary.simpleMessage(
            "Вы действительно хотите разблокировать %1?"),
        "removeContact":
            MessageLookupByLibrary.simpleMessage("Удалить Контакт"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Вы уверены,что хотите удалить %1?"),
        "removeFavorite":
            MessageLookupByLibrary.simpleMessage("Удалить избранное"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "Представитель-это учетная запись, счёт, который голосует за консенсус сети. Право голоса взвешивается по балансу, вы можете делегировать свой баланс, чтобы увеличить вес голоса представителя, которому вы доверяете. Ваш представитель не имеет права распоряжаться вашими средствами. Вы должны выбрать представителя, который имеет мало времени простоя и заслуживает доверия."),
        "repInfoHeader":
            MessageLookupByLibrary.simpleMessage("Что такое представитель?"),
        "reply": MessageLookupByLibrary.simpleMessage("Ответить"),
        "representatives":
            MessageLookupByLibrary.simpleMessage("Представители"),
        "request": MessageLookupByLibrary.simpleMessage("Запрос"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Запрос %1 %2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "Запрос не удался: у этого пользователя, похоже, не установлен Nautilus или уведомления отключены."),
        "requestFrom": MessageLookupByLibrary.simpleMessage("Запрос от"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Запросить платеж"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "Ошибка при отправке запроса на оплату, устройство получателя может быть отключено или недоступно."),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "Запрос отправлен повторно! Если все еще не подтверждено, устройство получателя может быть отключено."),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Запросите платеж с сообщениями, зашифрованными сквозным шифрованием!\n\nПлатежные запросы, заметки и сообщения могут быть получены только другими пользователями nautilus, но вы можете использовать их для ведения собственного учета, даже если получатель не использует nautilus."),
        "requestSheetInfoHeader":
            MessageLookupByLibrary.simpleMessage("Информация о листе запроса"),
        "requested": MessageLookupByLibrary.simpleMessage("Запрошен"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("Запрошен"),
        "requesting": MessageLookupByLibrary.simpleMessage("Запрос"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Требуется пароль для открытия Nautilus?"),
        "requireCaptcha": MessageLookupByLibrary.simpleMessage(
            "Требовать CAPTCHA для получения подарочной карты"),
        "resendMemo": MessageLookupByLibrary.simpleMessage(
            "Повторно отправить эту заметку"),
        "resetAccountButton":
            MessageLookupByLibrary.simpleMessage("Сбросить учетную запись"),
        "resetAccountParagraph": MessageLookupByLibrary.simpleMessage(
            "Это создаст новую учетную запись с только что установленным паролем, старая учетная запись не будет удалена, если выбранные пароли не совпадают."),
        "resetDatabase":
            MessageLookupByLibrary.simpleMessage("Сброс базы данных"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "Вы действительно хотите сбросить внутреннюю базу данных? \n\nЭто может устранить проблемы, связанные с обновлением приложения, но также удалит все сохраненные настройки. Это НЕ приведет к удалению seed вашего кошелька. Если у вас возникли проблемы, вам следует создать резервную копию seed, переустановить приложение, а если проблема не исчезнет, не стесняйтесь сообщать об ошибке на github или discord."),
        "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "Похоже, ваше устройство \"рутировано\" , \"взломано\" или модифицировано таким образом, что это ставит под угрозу безопасность. Перед продолжением рекомендуется переустановить устройство в исходное состояние."),
        "scanInstructions":
            MessageLookupByLibrary.simpleMessage("Сканировать\nQR-код адрес."),
        "scanNFC": MessageLookupByLibrary.simpleMessage("Отправить через NFC"),
        "scanQrCode":
            MessageLookupByLibrary.simpleMessage("Сканировать QR-код"),
        "schedule": MessageLookupByLibrary.simpleMessage("График"),
        "searchHint": MessageLookupByLibrary.simpleMessage("Ищите что угодно"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "На следующем экране вы увидите свою секретную фразу. Это пароль для доступа к вашим средствам. Крайне важно, чтобы вы создали резервную копию и никогда не передавали ее никому."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Безопасность прежде всего!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Секретная фраза"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Секретная фраза скопирована"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Копировать секретную фразу"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Если вы потеряете свое устройство или удалите приложение, вам понадобится ваша секретная фраза или Seed, чтобы вернуть свои средства!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Безопасность"),
        "seed": MessageLookupByLibrary.simpleMessage("Seed"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Ниже Seed вашего кошелька.Крайне важно,чтобы Вы сохранили Seed и никогда не хранили его как обычный текст или как скриншот."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Seed скопирован в буфер обмена\nсохраниться в течение 2 минут."),
        "seedCopiedShort":
            MessageLookupByLibrary.simpleMessage("Seed скопирован"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Seed содержит ту же информацию, что и секретная фраза, но в машиночитаемом виде. Пока она у вас есть, у вас будет доступ к вашим средствам"),
        "seedInvalid":
            MessageLookupByLibrary.simpleMessage("Seed Недействительный."),
        "selfSendError":
            MessageLookupByLibrary.simpleMessage("Не могу запросить у себя"),
        "send": MessageLookupByLibrary.simpleMessage("Отправить"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Отправить %1 Nano"),
        "sendAmounts": MessageLookupByLibrary.simpleMessage("Отправить суммы"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "Произошла ошибка. Попробуйте позже."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Отправить из"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "Отправка памятки с транзакцией не удалась, возможно, они не являются пользователем Nautilus."),
        "sendMessageConfirm":
            MessageLookupByLibrary.simpleMessage("Отправка сообщения"),
        "sendRequestAgain":
            MessageLookupByLibrary.simpleMessage("Отправить запрос еще раз"),
        "sendRequests":
            MessageLookupByLibrary.simpleMessage("Отправить запросы"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "Отправляйте или запрашивайте платеж с помощью сообщений со сквозным шифрованием!\n\nЗапросы на оплату, записки и сообщения будут приниматься только другими пользователями nautilus.\n\nВам не нужно иметь имя пользователя для отправки или получения запросов на оплату, и вы можете использовать их для ведения собственного учета, даже если они не используют nautilus."),
        "sendSheetInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Отправить информацию о листе"),
        "sending": MessageLookupByLibrary.simpleMessage("Отправить"),
        "sent": MessageLookupByLibrary.simpleMessage("Отправлено"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Отправлено на"),
        "set": MessageLookupByLibrary.simpleMessage("Установлен"),
        "setPassword": MessageLookupByLibrary.simpleMessage("Установка пароля"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Пароль был успешно установлен"),
        "setPin": MessageLookupByLibrary.simpleMessage("Установить булавку"),
        "setPinParagraph": MessageLookupByLibrary.simpleMessage(
            "Установите или измените существующий PIN-код. Если вы еще не установили PIN-код, PIN-код по умолчанию — 000000."),
        "setPinSuccess":
            MessageLookupByLibrary.simpleMessage("Пин-код успешно установлен"),
        "setPlausibleDeniabilityPin": MessageLookupByLibrary.simpleMessage(
            "Установить правдоподобный PIN-код"),
        "setRestoreHeight": MessageLookupByLibrary.simpleMessage(
            "Установить высоту восстановления"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Установить пароль"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "setXMRRestoreHeight": MessageLookupByLibrary.simpleMessage(
            "Установить высоту восстановления XMR"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Настройки"),
        "settingsTransfer":
            MessageLookupByLibrary.simpleMessage("Загрузить с Paper кошелька"),
        "share": MessageLookupByLibrary.simpleMessage("Делиться"),
        "shareApp": MessageLookupByLibrary.simpleMessage("Поделиться %1"),
        "shareAppText": MessageLookupByLibrary.simpleMessage(
            "Проверьте %1! Первоклассный мобильный кошелек NANO!"),
        "shareLink": MessageLookupByLibrary.simpleMessage("Поделиться ссылкой"),
        "shareMessage":
            MessageLookupByLibrary.simpleMessage("Поделиться сообщением"),
        "shareNautilus":
            MessageLookupByLibrary.simpleMessage("Поделиться Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "Оцените Nautilus! Лучший Android кошелёк Nano!"),
        "shareText": MessageLookupByLibrary.simpleMessage("Поделиться текстом"),
        "shopButton": MessageLookupByLibrary.simpleMessage("Магазин"),
        "show": MessageLookupByLibrary.simpleMessage("Показывать"),
        "showAccount": MessageLookupByLibrary.simpleMessage("Показать аккаунт"),
        "showAccountInfo":
            MessageLookupByLibrary.simpleMessage("Информация об аккаунте"),
        "showAccountQR": MessageLookupByLibrary.simpleMessage(
            "Показать QR-код учетной записи"),
        "showContacts":
            MessageLookupByLibrary.simpleMessage("Показать контакты"),
        "showFunding": MessageLookupByLibrary.simpleMessage(
            "Показать баннер финансирования"),
        "showLinkOptions":
            MessageLookupByLibrary.simpleMessage("Показать параметры ссылки"),
        "showLinkQR":
            MessageLookupByLibrary.simpleMessage("Показать ссылку QR"),
        "showMoneroHeader":
            MessageLookupByLibrary.simpleMessage("Показать Монеро"),
        "showMoneroInfo":
            MessageLookupByLibrary.simpleMessage("Включить раздел Monero"),
        "showQR": MessageLookupByLibrary.simpleMessage("Показать QR-код"),
        "showUnopenedWarning":
            MessageLookupByLibrary.simpleMessage("Неоткрытое предупреждение"),
        "simplex": MessageLookupByLibrary.simpleMessage("Симплекс"),
        "social": MessageLookupByLibrary.simpleMessage("Социальное"),
        "someone": MessageLookupByLibrary.simpleMessage("кто то"),
        "spendCurrency": MessageLookupByLibrary.simpleMessage("Потратить %2"),
        "spendNano": MessageLookupByLibrary.simpleMessage("Потратить НАНО"),
        "splitBill": MessageLookupByLibrary.simpleMessage("Разделить счет"),
        "splitBillHeader":
            MessageLookupByLibrary.simpleMessage("Разделить счет"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "Отправляйте сразу кучу запросов на оплату! Например, легко разделить счет в ресторане."),
        "splitBillInfoHeader": MessageLookupByLibrary.simpleMessage(
            "Информация о раздельном счете"),
        "splitBy": MessageLookupByLibrary.simpleMessage("Разделить по"),
        "subsButton": MessageLookupByLibrary.simpleMessage("Подписки"),
        "subsInfo": MessageLookupByLibrary.simpleMessage(
            "Вы можете использовать подписки для настройки таких вещей, как ежемесячное пожертвование вашему любимому создателю контента или ежемесячная подписка на службу, продолжительность подписки настраивается, и ее легко отключить и снова включить. Когда срок подписки подходит к концу, вы получите уведомление и значок, чтобы напомнить вам, что срок ее действия истек."),
        "subscribeButton": MessageLookupByLibrary.simpleMessage("Подписывайся"),
        "subscribeEvery":
            MessageLookupByLibrary.simpleMessage("Подписывайтесь каждый"),
        "subscribeWithApple": MessageLookupByLibrary.simpleMessage(
            "Оформить подписку через ApplePay"),
        "subscribed": MessageLookupByLibrary.simpleMessage("Подписан"),
        "subscribing": MessageLookupByLibrary.simpleMessage("Подписка"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment": MessageLookupByLibrary.simpleMessage(
            "Помогите поддержать развитие"),
        "supportTheDeveloper":
            MessageLookupByLibrary.simpleMessage("Поддержать разработчика"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("Обмен XMR"),
        "swapXMRHeader": MessageLookupByLibrary.simpleMessage("Обмен Монеро"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "Monero — это криптовалюта, ориентированная на конфиденциальность, что делает очень трудным или даже невозможным отслеживание транзакций. Между тем, NANO — это криптовалюта, ориентированная на платежи, быстрая и бесплатная. Вместе они обеспечивают некоторые из самых полезных аспектов криптовалют!\n\nИспользуйте эту страницу, чтобы легко обменять NANO на XMR!"),
        "swapping": MessageLookupByLibrary.simpleMessage("Обмен"),
        "switchToSeed":
            MessageLookupByLibrary.simpleMessage("Переключиться на Seed"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("По умолчанию"),
        "tapMessageToEdit": MessageLookupByLibrary.simpleMessage(
            "Нажмите на сообщение, чтобы отредактировать"),
        "tapToHide":
            MessageLookupByLibrary.simpleMessage("Нажмите, чтобы скрыть"),
        "tapToReveal":
            MessageLookupByLibrary.simpleMessage("Нажмите, чтобы показать"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("Тема"),
        "thisMayTakeSomeTime": MessageLookupByLibrary.simpleMessage(
            "это может занять некоторое время..."),
        "to": MessageLookupByLibrary.simpleMessage("на"),
        "todayAt": MessageLookupByLibrary.simpleMessage("Сегодня в"),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "Много неудачных попыток разблокировки."),
        "trackingHeader":
            MessageLookupByLibrary.simpleMessage("Отслеживание авторизации"),
        "trackingWarning":
            MessageLookupByLibrary.simpleMessage("Отслеживание отключено"),
        "trackingWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "Функционал подарочной карты может быть ограничен или вообще не работать, если отслеживание отключено. Мы используем это разрешение ИСКЛЮЧИТЕЛЬНО для этой функции. Абсолютно никакие ваши данные не продаются, не собираются и не отслеживаются на серверной части для каких-либо целей, кроме необходимых."),
        "trackingWarningBodyShort": MessageLookupByLibrary.simpleMessage(
            "Ссылки на подарочные карты не будут работать должным образом"),
        "transactions": MessageLookupByLibrary.simpleMessage("Транзакции"),
        "transfer": MessageLookupByLibrary.simpleMessage("Отправить"),
        "transferClose": MessageLookupByLibrary.simpleMessage(
            "Нажмите в любом месте, чтобы закрыть окно."),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO успешно переведены в Nautilus кошелёк.\n"),
        "transferConfirmInfo": MessageLookupByLibrary.simpleMessage(
            "Обнаружен кошелёк с балансом %1 NANO.\n"),
        "transferConfirmInfoSecond": MessageLookupByLibrary.simpleMessage(
            "Нажмите Подтвердить, чтобы перевести средства.\n"),
        "transferConfirmInfoThird": MessageLookupByLibrary.simpleMessage(
            "Перевод может занять несколько секунд."),
        "transferError": MessageLookupByLibrary.simpleMessage(
            "Во время передачи произошла ошибка.Пожалуйста, попробуйте позже."),
        "transferHeader":
            MessageLookupByLibrary.simpleMessage("Перевод Средств"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "Этот процесс переведёт средства с бумажного кошелька на ваш Nautilus кошелёк.\n\nНажмите кнопку \"%1\" чтобы начать."),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "В результате этого средства будут переведены с бумажного кошелька на ваш кошелек Nautilus."),
        "transferLoading": MessageLookupByLibrary.simpleMessage("Перевод"),
        "transferManualHint":
            MessageLookupByLibrary.simpleMessage("Введите Seed ниже."),
        "transferNoFunds":
            MessageLookupByLibrary.simpleMessage("На этом seed нет NANO."),
        "transferQrScanError": MessageLookupByLibrary.simpleMessage(
            "Этот QR не содержит действительного seed"),
        "transferQrScanHint": MessageLookupByLibrary.simpleMessage(
            "Сканировать Nano \nseed или закрытый ключ"),
        "unacknowledged": MessageLookupByLibrary.simpleMessage("непризнанный"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("неподтвержденный"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("невыполненными"),
        "unlock": MessageLookupByLibrary.simpleMessage("Открыть"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Аутентификация для разблокировки Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Введите PIN , для разблокировки Nautilus"),
        "unopenedWarningHeader": MessageLookupByLibrary.simpleMessage(
            "Показать неоткрытое предупреждение"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "Показывать предупреждение при отправке средств на неоткрытый счет, это полезно, потому что в большинстве случаев адреса, на которые вы отправляете, будут иметь баланс, а отправка на новый адрес может быть результатом опечатки."),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что это правильный адрес?\nЭтот аккаунт не открыт\n\nВы можете отключить это предупреждение в ящике настроек в разделе «Неоткрытое предупреждение»."),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("Счет не открыт"),
        "unpaid": MessageLookupByLibrary.simpleMessage("невыплаченных"),
        "unread": MessageLookupByLibrary.simpleMessage("непрочитанный"),
        "uptime": MessageLookupByLibrary.simpleMessage("Онлайн время"),
        "urlEmpty":
            MessageLookupByLibrary.simpleMessage("Пожалуйста, введите URL"),
        "useAppRep":
            MessageLookupByLibrary.simpleMessage("Используйте %1 репутацию"),
        "useCurrency": MessageLookupByLibrary.simpleMessage("Использовать %2"),
        "useNano": MessageLookupByLibrary.simpleMessage("Используйте НАНО"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userAlreadyAddedError":
            MessageLookupByLibrary.simpleMessage("Пользователь уже добавлен!"),
        "userNotFound":
            MessageLookupByLibrary.simpleMessage("Пользователь не найден!"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "У вас уже есть зарегистрированное имя пользователя! В настоящее время изменить имя пользователя невозможно, но вы можете зарегистрировать новое имя под другим адресом."),
        "usernameAvailable":
            MessageLookupByLibrary.simpleMessage("Доступно имя пользователя!"),
        "usernameEmpty": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите имя пользователя"),
        "usernameError":
            MessageLookupByLibrary.simpleMessage("Ошибка имени пользователя"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "Выберите уникальный @username, чтобы друзьям и семье было легко найти вас!\n\nИмя пользователя Nautilus обновляет пользовательский интерфейс по всему миру, чтобы отразить ваш новый дескриптор."),
        "usernameInvalid":
            MessageLookupByLibrary.simpleMessage("Неверное имя пользователя"),
        "usernameUnavailable":
            MessageLookupByLibrary.simpleMessage("Имя пользователя недоступно"),
        "usernameWarning": MessageLookupByLibrary.simpleMessage(
            "Имена пользователей Nautilus — это централизованная услуга, предоставляемая Nano.to"),
        "using": MessageLookupByLibrary.simpleMessage("С использованием"),
        "viewDetails":
            MessageLookupByLibrary.simpleMessage("Посмотреть Детали"),
        "viewPaymentHistory":
            MessageLookupByLibrary.simpleMessage("Просмотр истории платежей"),
        "viewTX": MessageLookupByLibrary.simpleMessage("Посмотреть транзакцию"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("Вес голосования"),
        "warning": MessageLookupByLibrary.simpleMessage("Предупреждение"),
        "watchAccountExists":
            MessageLookupByLibrary.simpleMessage("Аккаунт уже добавлен!"),
        "watchOnlyAccount": MessageLookupByLibrary.simpleMessage(
            "Аккаунт только для просмотра"),
        "watchOnlySendDisabled": MessageLookupByLibrary.simpleMessage(
            "Отправка отключена на адресах только для просмотра"),
        "weekAgo": MessageLookupByLibrary.simpleMessage("Неделю назад"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Добро пожаловать в Nautilus. Вы можете создать новый кошелек или импортировать уже существующий."),
        "welcomeTextLogin": MessageLookupByLibrary.simpleMessage(
            "Добро пожаловать в Наутилус. Выберите вариант, чтобы начать, или выберите тему, используя значок ниже."),
        "welcomeTextUpdated": MessageLookupByLibrary.simpleMessage(
            "Добро пожаловать в Наутилус. Для начала создайте новый кошелек или импортируйте существующий."),
        "welcomeTextWithoutLogin": MessageLookupByLibrary.simpleMessage(
            "Для начала создайте новый кошелек или импортируйте существующий."),
        "withAddress": MessageLookupByLibrary.simpleMessage("С адресом"),
        "withFee": MessageLookupByLibrary.simpleMessage("Платно"),
        "withMessage": MessageLookupByLibrary.simpleMessage("С сообщением"),
        "xMinute": MessageLookupByLibrary.simpleMessage("Через %1 мин."),
        "xMinutes": MessageLookupByLibrary.simpleMessage("Через %1 мин."),
        "xmrStatusConnecting":
            MessageLookupByLibrary.simpleMessage("Подключение"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("Ошибка"),
        "xmrStatusLoading": MessageLookupByLibrary.simpleMessage("Загрузка"),
        "xmrStatusSynchronized":
            MessageLookupByLibrary.simpleMessage("Синхронизировано"),
        "xmrStatusSynchronizing":
            MessageLookupByLibrary.simpleMessage("Синхронизации"),
        "yes": MessageLookupByLibrary.simpleMessage("Да"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Да"),
        "yesterdayAt": MessageLookupByLibrary.simpleMessage("Вчера в")
      };
}
