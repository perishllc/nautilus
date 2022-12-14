// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hant locale. All the
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
  String get localeName => 'zh_Hant';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("帳戶"),
        "accountNameHint": MessageLookupByLibrary.simpleMessage("輸入名稱"),
        "accountNameMissing": MessageLookupByLibrary.simpleMessage("選擇一個帳戶名稱"),
        "accounts": MessageLookupByLibrary.simpleMessage("帳戶"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage("確定已備份您的種子或秘密詞語嗎？"),
        "activeMessageHeader": MessageLookupByLibrary.simpleMessage("作用中訊息"),
        "addAccount": MessageLookupByLibrary.simpleMessage("新增帳戶"),
        "addAddress": MessageLookupByLibrary.simpleMessage("添加地址"),
        "addBlocked": MessageLookupByLibrary.simpleMessage("封鎖使用者"),
        "addContact": MessageLookupByLibrary.simpleMessage("新增聯絡人"),
        "addFavorite": MessageLookupByLibrary.simpleMessage("加入我的最愛"),
        "addNode": MessageLookupByLibrary.simpleMessage("添加節點"),
        "addUser": MessageLookupByLibrary.simpleMessage("添加用戶"),
        "addWatchOnlyAccount": MessageLookupByLibrary.simpleMessage("添加僅觀看帳戶"),
        "addWatchOnlyAccountError":
            MessageLookupByLibrary.simpleMessage("添加僅觀看帳戶時出錯：帳戶為空"),
        "addWatchOnlyAccountSuccess":
            MessageLookupByLibrary.simpleMessage("已成功創建僅限觀看的帳戶！"),
        "address": MessageLookupByLibrary.simpleMessage("地址"),
        "addressCopied": MessageLookupByLibrary.simpleMessage("地址已複製"),
        "addressHint": MessageLookupByLibrary.simpleMessage("輸入地址"),
        "addressMissing": MessageLookupByLibrary.simpleMessage("請輸入目標地址"),
        "addressOrUserMissing":
            MessageLookupByLibrary.simpleMessage("請輸入使用者名稱或地址"),
        "addressShare": MessageLookupByLibrary.simpleMessage("分享地址"),
        "aliases": MessageLookupByLibrary.simpleMessage("別名"),
        "amountGiftGreaterError":
            MessageLookupByLibrary.simpleMessage("分割金額不能大於禮物餘額"),
        "amountMissing": MessageLookupByLibrary.simpleMessage("請輸入金額"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "我們注意到您單擊了包含一些 nano 的鏈接，您想跳過設置過程嗎？你以後總是可以改變的。\n\n 但是，如果您有要導入的現有種子，則應選擇否。"),
        "askTracking": MessageLookupByLibrary.simpleMessage(
            "我們即將請求“跟踪”權限，這*嚴格*用於歸因鏈接/推薦和次要分析（例如安裝數量、應用版本等）我們相信您有權享有您的隱私並且對您的任何個人數據不感興趣，我們只需要獲得許可，鏈接屬性才能正常工作。"),
        "asked": MessageLookupByLibrary.simpleMessage("詢問"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("認證"),
        "authError": MessageLookupByLibrary.simpleMessage("驗證時出錯。稍後再試。"),
        "authMethod": MessageLookupByLibrary.simpleMessage("驗證機制"),
        "authenticating": MessageLookupByLibrary.simpleMessage("認證"),
        "autoImport": MessageLookupByLibrary.simpleMessage("自動匯入"),
        "autoLockHeader": MessageLookupByLibrary.simpleMessage("自動鎖定"),
        "autoRenewSub": MessageLookupByLibrary.simpleMessage("自動續訂"),
        "backupConfirmButton": MessageLookupByLibrary.simpleMessage("已備份"),
        "backupSecretPhrase": MessageLookupByLibrary.simpleMessage("備份秘密詞語"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("備份種子"),
        "backupSeedConfirm":
            MessageLookupByLibrary.simpleMessage("您確認已備份您的錢包種子嗎？"),
        "backupYourSeed": MessageLookupByLibrary.simpleMessage("備份您的種子"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("生物辨識技術"),
        "blockExplorer": MessageLookupByLibrary.simpleMessage("封鎖總管"),
        "blockExplorerHeader": MessageLookupByLibrary.simpleMessage("封鎖總管資訊"),
        "blockExplorerInfo":
            MessageLookupByLibrary.simpleMessage("使用哪個塊資源管理器來顯示交易信息"),
        "blockUser": MessageLookupByLibrary.simpleMessage("封鎖此使用者"),
        "blockedAdded": MessageLookupByLibrary.simpleMessage("% 1 已成功封鎖。"),
        "blockedExists": MessageLookupByLibrary.simpleMessage("使用者已封鎖！"),
        "blockedHeader": MessageLookupByLibrary.simpleMessage("封鎖"),
        "blockedInfo": MessageLookupByLibrary.simpleMessage(
            "透過任何已知的別名或地址封鎖使用者。任何來自他們的消息，交易或請求都將被忽略。"),
        "blockedInfoHeader": MessageLookupByLibrary.simpleMessage("封鎖的資訊"),
        "blockedNameExists": MessageLookupByLibrary.simpleMessage("暱稱已使用！"),
        "blockedNameMissing": MessageLookupByLibrary.simpleMessage("選擇暱稱"),
        "blockedRemoved": MessageLookupByLibrary.simpleMessage("% 1 已解除封鎖！"),
        "branchConnectErrorLongDesc": MessageLookupByLibrary.simpleMessage(
            "我們似乎無法訪問 Branch API，這通常是由某種網絡問題或 VPN 阻止連接引起的。\n\n 您應該仍然可以正常使用該應用程序，但發送和接收禮品卡可能無法正常工作。"),
        "branchConnectErrorShortDesc":
            MessageLookupByLibrary.simpleMessage("錯誤：無法訪問分支 API"),
        "branchConnectErrorTitle": MessageLookupByLibrary.simpleMessage("連接警告"),
        "businessButton": MessageLookupByLibrary.simpleMessage("商業"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("驗證碼"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "為了防止濫用，我們要求您解決驗證碼才能在下一頁領取禮品卡。"),
        "changeCurrency": MessageLookupByLibrary.simpleMessage("變更貨幣單位"),
        "changeLog": MessageLookupByLibrary.simpleMessage("更改日誌"),
        "changeNode": MessageLookupByLibrary.simpleMessage("改變節點"),
        "changePassword": MessageLookupByLibrary.simpleMessage("更改密碼"),
        "changePasswordParagraph": MessageLookupByLibrary.simpleMessage(
            "更改現有密碼。如果您不知道當前密碼，請做出最佳猜測，因為實際上不需要更改它（因為您已經登錄），但它確實讓我們刪除了現有的備份條目。"),
        "changePin": MessageLookupByLibrary.simpleMessage("更改引腳"),
        "changePinHint": MessageLookupByLibrary.simpleMessage("設置引腳"),
        "changeRepAuthenticate": MessageLookupByLibrary.simpleMessage("變更代表"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("變更"),
        "changeRepHint": MessageLookupByLibrary.simpleMessage("輸入新代表"),
        "changeRepSame": MessageLookupByLibrary.simpleMessage("這已經是您的代表了！"),
        "changeRepSucces": MessageLookupByLibrary.simpleMessage("代表變更成功"),
        "changeSeed": MessageLookupByLibrary.simpleMessage("改變種子"),
        "changeSeedParagraph": MessageLookupByLibrary.simpleMessage(
            "更改與此magic-link authed 帳戶關聯的種子/短語，您在此處設置的任何密碼都將覆蓋您現有的密碼，但您可以選擇使用相同的密碼。"),
        "checkAvailability": MessageLookupByLibrary.simpleMessage("查看可用性"),
        "close": MessageLookupByLibrary.simpleMessage("關閉"),
        "confirm": MessageLookupByLibrary.simpleMessage("確認"),
        "confirmPasswordHint": MessageLookupByLibrary.simpleMessage("確認密碼"),
        "confirmPinHint": MessageLookupByLibrary.simpleMessage("確認引腳"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("連線中"),
        "connectionWarning": MessageLookupByLibrary.simpleMessage("無法連接"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "我們似乎無法連接到後端，這可能只是您的連接，或者如果問題仍然存在，後端可能會因維護甚至中斷而停機。如果一個多小時後仍然有問題，請在 discord 服務器@chat.perish.co 的#bug-reports 中提交報告"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "我們似乎無法連接到後端，這可能只是您的連接，或者如果問題仍然存在，後端可能會因維護甚至中斷而停機。如果一個多小時後仍然有問題，請在 discord 服務器@chat.perish.co 的#bug-reports 中提交報告"),
        "connectionWarningBodyShort":
            MessageLookupByLibrary.simpleMessage("我們似乎無法連接到後端"),
        "contactAdded": MessageLookupByLibrary.simpleMessage("%1 已新增為聯絡人！"),
        "contactExists": MessageLookupByLibrary.simpleMessage("聯絡人已存在"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("聯絡人"),
        "contactInvalid": MessageLookupByLibrary.simpleMessage("無效的聯絡人名稱"),
        "contactNameHint": MessageLookupByLibrary.simpleMessage("輸入名稱 @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage("選擇該聯絡人的名稱"),
        "contactRemoved":
            MessageLookupByLibrary.simpleMessage("%1 已自聯絡人清單中刪除！"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("聯絡人清單"),
        "contactsImportErr": MessageLookupByLibrary.simpleMessage("無法匯入聯絡人"),
        "contactsImportSuccess":
            MessageLookupByLibrary.simpleMessage("順利匯出 %1 個聯絡人"),
        "continueButton": MessageLookupByLibrary.simpleMessage("繼續"),
        "continueWithoutLogin":
            MessageLookupByLibrary.simpleMessage("無需登錄即可繼續"),
        "copied": MessageLookupByLibrary.simpleMessage("已複製"),
        "copy": MessageLookupByLibrary.simpleMessage("複製"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("複製地址"),
        "copyLink": MessageLookupByLibrary.simpleMessage("複製連結"),
        "copyMessage": MessageLookupByLibrary.simpleMessage("複製消息"),
        "copySeed": MessageLookupByLibrary.simpleMessage("複製種子"),
        "copyWalletAddressToClipboard":
            MessageLookupByLibrary.simpleMessage("將錢包地址複製到剪貼板"),
        "copyXMRSeed": MessageLookupByLibrary.simpleMessage("複製門羅幣種子"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("建立一組密碼。"),
        "createGiftCard": MessageLookupByLibrary.simpleMessage("建立禮品卡"),
        "createGiftHeader": MessageLookupByLibrary.simpleMessage("建立禮品卡"),
        "createPasswordFirstParagraph":
            MessageLookupByLibrary.simpleMessage("您可建立一組密碼以增進錢包的安全強度。"),
        "createPasswordHint": MessageLookupByLibrary.simpleMessage("建立密碼"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "密碼並非必要，無論如何您的錢包仍會被辨識碼或生物辨識技術保護。"),
        "createPasswordSheetHeader": MessageLookupByLibrary.simpleMessage("建立"),
        "createPinHint": MessageLookupByLibrary.simpleMessage("創建圖釘"),
        "createQR": MessageLookupByLibrary.simpleMessage("建立二維碼"),
        "created": MessageLookupByLibrary.simpleMessage("創建"),
        "creatingGiftCard": MessageLookupByLibrary.simpleMessage("建立禮品卡"),
        "currency": MessageLookupByLibrary.simpleMessage("貨幣"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("貨幣模式"),
        "currencyModeHeader": MessageLookupByLibrary.simpleMessage("貨幣模式資訊"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "選擇顯示金額的單位。\n1 尼亞諾 = 0.000001 納米, 或 \n100 萬尼亞諾 = 1 納米"),
        "currentlyRepresented": MessageLookupByLibrary.simpleMessage("目前代表為"),
        "dayAgo": MessageLookupByLibrary.simpleMessage("一天前"),
        "decryptionError": MessageLookupByLibrary.simpleMessage("解密錯誤！"),
        "defaultAccountName": MessageLookupByLibrary.simpleMessage("主要帳戶"),
        "defaultGiftMessage":
            MessageLookupByLibrary.simpleMessage("看看鸚鵡螺！我用這個鏈接給你發了一些 nano："),
        "defaultNewAccountName": MessageLookupByLibrary.simpleMessage("帳戶 %1"),
        "delete": MessageLookupByLibrary.simpleMessage("刪除"),
        "deleteNodeConfirmation": MessageLookupByLibrary.simpleMessage(
            "您確定要刪除此節點嗎？\n\n您以後隨時可以通過點擊“添加節點”按鈕重新添加它"),
        "deleteNodeHeader": MessageLookupByLibrary.simpleMessage("刪除節點？"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("解除"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("錢包密碼已解除"),
        "disableWalletPassword": MessageLookupByLibrary.simpleMessage("解除錢包密碼"),
        "dismiss": MessageLookupByLibrary.simpleMessage("解僱"),
        "doYouHaveSeedBody": MessageLookupByLibrary.simpleMessage(
            "如果您不確定這意味著什麼，那麼您可能沒有要導入的種子，可以按繼續。"),
        "doYouHaveSeedHeader":
            MessageLookupByLibrary.simpleMessage("你有種子要進口嗎？"),
        "domainInvalid": MessageLookupByLibrary.simpleMessage("無效的網域名稱"),
        "donateButton": MessageLookupByLibrary.simpleMessage("捐"),
        "donateToSupport": MessageLookupByLibrary.simpleMessage("支持項目"),
        "edit": MessageLookupByLibrary.simpleMessage("編輯"),
        "enableNotifications": MessageLookupByLibrary.simpleMessage("啟用通知"),
        "enableTracking": MessageLookupByLibrary.simpleMessage("啟用跟踪"),
        "encryptionFailedError":
            MessageLookupByLibrary.simpleMessage("無法設定錢包密碼"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("輸入地址"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("輸入金額"),
        "enterEmail": MessageLookupByLibrary.simpleMessage("輸入電子郵件"),
        "enterGiftMemo": MessageLookupByLibrary.simpleMessage("輸入禮品備註"),
        "enterHeight": MessageLookupByLibrary.simpleMessage("輸入高度"),
        "enterHttpUrl": MessageLookupByLibrary.simpleMessage("輸入 HTTP 網址"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("輸入訊息"),
        "enterMoneroAddress": MessageLookupByLibrary.simpleMessage("輸入 XMR 地址"),
        "enterNodeName": MessageLookupByLibrary.simpleMessage("輸入節點名稱"),
        "enterPasswordHint": MessageLookupByLibrary.simpleMessage("輸入您的密碼"),
        "enterSplitAmount": MessageLookupByLibrary.simpleMessage("輸入分割金額"),
        "enterUserOrAddress": MessageLookupByLibrary.simpleMessage("輸入使用者或地址"),
        "enterUsername": MessageLookupByLibrary.simpleMessage("輸入使用者名稱"),
        "enterWsUrl": MessageLookupByLibrary.simpleMessage("輸入 WebSocket 網址"),
        "errorProcessingGiftCard":
            MessageLookupByLibrary.simpleMessage("處理此禮品卡時出錯，它可能無效、過期或為空。"),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("來自某人"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "歡迎來到 Nautilus。當您收到或發送 NANO 時，交易將顯示如下："),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("一點"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("很多"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("發給某人"),
        "examplePayRecipient": MessageLookupByLibrary.simpleMessage("@dad"),
        "examplePayRecipientMessage":
            MessageLookupByLibrary.simpleMessage("生日快樂！"),
        "examplePaymentExplainer": MessageLookupByLibrary.simpleMessage(
            "當您發送或收到付款請求後，它們會像這樣顯示在這裡，並帶有顯示狀態的卡片的顏色和標籤。 \n\n綠色表示請求已付款。\n黃色表示請求/備忘錄尚未付款/讀取。\n紅色表示請求尚未讀取或接收。\n\n 沒有金額的中性彩色卡片只是消息。"),
        "examplePaymentFrom": MessageLookupByLibrary.simpleMessage("@landlord"),
        "examplePaymentFulfilled": MessageLookupByLibrary.simpleMessage("一些"),
        "examplePaymentFulfilledMemo":
            MessageLookupByLibrary.simpleMessage("壽司"),
        "examplePaymentIntro":
            MessageLookupByLibrary.simpleMessage("一旦您傳送或收到付款要求，它們就會顯示在這裡："),
        "examplePaymentMessage": MessageLookupByLibrary.simpleMessage("嘿怎麼了？"),
        "examplePaymentReceivable": MessageLookupByLibrary.simpleMessage("很多"),
        "examplePaymentReceivableMemo":
            MessageLookupByLibrary.simpleMessage("租金"),
        "examplePaymentTo":
            MessageLookupByLibrary.simpleMessage("@best_friend"),
        "exampleRecRecipient":
            MessageLookupByLibrary.simpleMessage("@coworker"),
        "exampleRecRecipientMessage":
            MessageLookupByLibrary.simpleMessage("氣, 錢"),
        "exchangeNano": MessageLookupByLibrary.simpleMessage("交換納米"),
        "existingPasswordHint": MessageLookupByLibrary.simpleMessage("輸入當前密碼"),
        "existingPinHint": MessageLookupByLibrary.simpleMessage("輸入當前引腳"),
        "exit": MessageLookupByLibrary.simpleMessage("退出"),
        "exportTXData": MessageLookupByLibrary.simpleMessage("出口交易"),
        "failed": MessageLookupByLibrary.simpleMessage("失敗"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader": MessageLookupByLibrary.simpleMessage("鸚鵡螺已斷開連接"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "Nautilus 服務器似乎斷開連接，發送和接收（沒有備忘錄）應該仍然可以運行，但付款請求可能無法通過\n\n 稍後再回來或重新啟動應用程式再試一次"),
        "favoriteExists": MessageLookupByLibrary.simpleMessage("我的最愛已存在"),
        "favoriteHeader": MessageLookupByLibrary.simpleMessage("我的最愛"),
        "favoriteInvalid": MessageLookupByLibrary.simpleMessage("我的最愛名稱無效"),
        "favoriteNameHint": MessageLookupByLibrary.simpleMessage("輸入暱稱"),
        "favoriteNameMissing": MessageLookupByLibrary.simpleMessage("選擇此最愛的名稱"),
        "favoriteRemoved":
            MessageLookupByLibrary.simpleMessage("% 1 已從我的最愛中移除！"),
        "favoritesHeader": MessageLookupByLibrary.simpleMessage("我的最愛"),
        "featured": MessageLookupByLibrary.simpleMessage("。特色。"),
        "fewDaysAgo": MessageLookupByLibrary.simpleMessage("幾天之前"),
        "fewHoursAgo": MessageLookupByLibrary.simpleMessage("幾個小時前"),
        "fewMinutesAgo": MessageLookupByLibrary.simpleMessage("幾分鐘前"),
        "fewSecondsAgo": MessageLookupByLibrary.simpleMessage("幾秒鐘前"),
        "fingerprintSeedBackup":
            MessageLookupByLibrary.simpleMessage("確認指紋或 Face ID，備份錢包種子。"),
        "from": MessageLookupByLibrary.simpleMessage("從"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("履行"),
        "fundingBannerHeader": MessageLookupByLibrary.simpleMessage("資金橫幅"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("資金"),
        "getNano": MessageLookupByLibrary.simpleMessage("獲取納米"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("你有禮物！"),
        "giftAlertEmpty": MessageLookupByLibrary.simpleMessage("空, 禮物"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("禮品金額"),
        "giftCardCreationError":
            MessageLookupByLibrary.simpleMessage("嘗試創建禮品卡鏈接時出錯"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "嘗試創建禮品卡時發生錯誤，禮品卡鏈接或種子已復製到您的剪貼板，您的資金可能包含在其中，具體取決於出現的問題。"),
        "giftCardInfoHeader": MessageLookupByLibrary.simpleMessage("禮品單信息"),
        "giftFrom": MessageLookupByLibrary.simpleMessage("禮物來自"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "使用 NANO 加載數字禮品卡！設置金額，並為收件人查看何時打開它的可選消息！\n\n創建完成後，您將獲得一個可以發送給任何人的鏈接，打開後會在安裝 Nautilus 後自動將資金分配給收件人！\n\n如果收款人已經是 Nautilus 用戶，他們將在打開鏈接時提示將資金轉入他們的帳戶"),
        "giftMessage": MessageLookupByLibrary.simpleMessage("禮物訊息"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "處理此禮品卡時出錯。也許檢查您的連接並嘗試再次單擊禮物鏈接。"),
        "giftProcessSuccess":
            MessageLookupByLibrary.simpleMessage("禮物已成功收到，可能需要一點時間才會出現在您的錢包中。"),
        "giftRefundSuccess": MessageLookupByLibrary.simpleMessage("禮品成功退還！"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("返回"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("前往 QR"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("已理解"),
        "handoff": MessageLookupByLibrary.simpleMessage("不可觸摸"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage("嘗試切換塊時出現問題！"),
        "handoffSupportedMethodNotFound":
            MessageLookupByLibrary.simpleMessage("找不到受支持的切換方法！"),
        "haveSeedToImport": MessageLookupByLibrary.simpleMessage("我有一顆種子"),
        "hide": MessageLookupByLibrary.simpleMessage("隱藏"),
        "hideAccountHeader": MessageLookupByLibrary.simpleMessage("隱藏帳戶？"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "您確定要隱藏空帳戶嗎？\n\n這將隱藏所有餘額為 0 的帳戶（不包括僅觀看地址和您的主帳戶），但您以後可以隨時通過點擊“添加帳戶”按鈕重新添加它們"),
        "hideAccountsHeader": MessageLookupByLibrary.simpleMessage("隱藏帳戶？"),
        "hideEmptyAccounts": MessageLookupByLibrary.simpleMessage("隱藏空賬戶"),
        "home": MessageLookupByLibrary.simpleMessage("首頁"),
        "homeButton": MessageLookupByLibrary.simpleMessage("家"),
        "hourAgo": MessageLookupByLibrary.simpleMessage("一小時前"),
        "iUnderstandTheRisks": MessageLookupByLibrary.simpleMessage("我已理解風險"),
        "ignore": MessageLookupByLibrary.simpleMessage("忽略"),
        "imSure": MessageLookupByLibrary.simpleMessage("我確定"),
        "import": MessageLookupByLibrary.simpleMessage("匯入"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "您點擊的鏈接包含一些納米，您要將其導入此錢包，還是將其退還給發送的人？"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "看起來你點擊了一個包含一些 NANO 的鏈接，為了接收這些資金，我們只需要你完成設置你的錢包。"),
        "importGiftv2":
            MessageLookupByLibrary.simpleMessage("您點擊的鏈接包含一些 NANO，您想將其導入此錢包嗎？"),
        "importHD": MessageLookupByLibrary.simpleMessage("導入高清"),
        "importSecretPhrase": MessageLookupByLibrary.simpleMessage("輸入秘密詞語"),
        "importSecretPhraseHint":
            MessageLookupByLibrary.simpleMessage("請輸入您的 24 個秘密詞語。每個詞應用空格分隔。"),
        "importSeed": MessageLookupByLibrary.simpleMessage("匯入種子"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage("請在下方輸入您的種子"),
        "importSeedInstead": MessageLookupByLibrary.simpleMessage("匯入種子"),
        "importStandard": MessageLookupByLibrary.simpleMessage("進口標準"),
        "importWallet": MessageLookupByLibrary.simpleMessage("匯入現有錢包"),
        "instantly": MessageLookupByLibrary.simpleMessage("立刻"),
        "insufficientBalance": MessageLookupByLibrary.simpleMessage("餘額不足"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "我們跳過了介紹過程以節省您的時間，但您應該立即備份新創建的種子。\n\n如果您失去種子，您將無法使用您的資金。\n\n此外，您的密碼已設置為“000000”，您也應立即更改。"),
        "introSkippedWarningHeader":
            MessageLookupByLibrary.simpleMessage("備份你的種子！"),
        "invalidAddress": MessageLookupByLibrary.simpleMessage("無效的目標地址"),
        "invalidHeight": MessageLookupByLibrary.simpleMessage("無效高度"),
        "invalidPassword": MessageLookupByLibrary.simpleMessage("無效的密碼"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("無效引腳"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "由於 iOS App Store 指南和限制，我們無法將您鏈接到我們的捐贈頁面。如果您想支持該項目，請考慮發送到 nautilus 節點的地址。"),
        "language": MessageLookupByLibrary.simpleMessage("語言"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("連結已複製"),
        "loaded": MessageLookupByLibrary.simpleMessage("已載入"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("載入到"),
        "lockAppSetting": MessageLookupByLibrary.simpleMessage("啟動時要求驗證"),
        "locked": MessageLookupByLibrary.simpleMessage("已鎖定"),
        "loginButton": MessageLookupByLibrary.simpleMessage("登錄"),
        "loginOrRegisterHeader": MessageLookupByLibrary.simpleMessage("登錄或註冊"),
        "logout": MessageLookupByLibrary.simpleMessage("登出"),
        "logoutAction": MessageLookupByLibrary.simpleMessage("刪除種子並登出"),
        "logoutAreYouSure": MessageLookupByLibrary.simpleMessage("您確定嗎？"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "本動作會刪除您在本裝置裡頭的種子及所有和 Nautilus 有關的資料。如果您的種子沒有備份，您將永遠無法存取您的帳戶"),
        "logoutReassurance":
            MessageLookupByLibrary.simpleMessage("只要您已備份您的種子，就不必擔心。"),
        "looksLikeHdSeed": MessageLookupByLibrary.simpleMessage(
            "這似乎是一個高清種子，除非你確定你知道你在做什麼，否則你應該使用“導入高清”選項。"),
        "looksLikeStandardSeed":
            MessageLookupByLibrary.simpleMessage("這似乎是一個標準種子，您應該改用“導入標準”選項。"),
        "manage": MessageLookupByLibrary.simpleMessage("管理"),
        "mantaError": MessageLookupByLibrary.simpleMessage("無法驗證請求"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("手動輸入"),
        "markAsPaid": MessageLookupByLibrary.simpleMessage("標示為已付款"),
        "markAsUnpaid": MessageLookupByLibrary.simpleMessage("標示為未付款"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "備忘錄重新發送！如果仍未確認，則收件者的裝置可能處於離線狀態。"),
        "messageCopied": MessageLookupByLibrary.simpleMessage("消息已復制"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("留言"),
        "minimumSend": MessageLookupByLibrary.simpleMessage("最低發送金額是 %1 NANO"),
        "minuteAgo": MessageLookupByLibrary.simpleMessage("一分鐘前"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 不是有效的詞語。"),
        "mnemonicPhrase": MessageLookupByLibrary.simpleMessage("助記詞"),
        "mnemonicSizeError":
            MessageLookupByLibrary.simpleMessage("秘密詞語一定要包含 24 個詞語"),
        "monthlyServerCosts": MessageLookupByLibrary.simpleMessage("每月服務器成本"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings": MessageLookupByLibrary.simpleMessage("更多設置"),
        "nameEmpty": MessageLookupByLibrary.simpleMessage("請輸入姓名"),
        "natricon": MessageLookupByLibrary.simpleMessage("卡通圖示"),
        "nautilusWallet": MessageLookupByLibrary.simpleMessage("鸚鵡螺錢包"),
        "nearby": MessageLookupByLibrary.simpleMessage("附近"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "此功能要求您擁有更長的交易歷史記錄，以防止垃圾郵件。\n\n或者，您可以顯示 QR 碼供某人掃描。"),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("需要驗證"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "這是您的新帳戶。當您收到 NANO 時，交易會顯示如下："),
        "newWallet": MessageLookupByLibrary.simpleMessage("建立新錢包"),
        "nextButton": MessageLookupByLibrary.simpleMessage("繼續"),
        "no": MessageLookupByLibrary.simpleMessage("不要"),
        "noContactsExport": MessageLookupByLibrary.simpleMessage("沒有可匯出的聯絡人"),
        "noContactsImport": MessageLookupByLibrary.simpleMessage("沒有可匯入的聯絡人"),
        "noSearchResults": MessageLookupByLibrary.simpleMessage("沒有搜索結果！"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("不用，略過"),
        "noTXDataExport": MessageLookupByLibrary.simpleMessage("沒有要導出的交易。"),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "node": MessageLookupByLibrary.simpleMessage("節點"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("節點狀態"),
        "nodes": MessageLookupByLibrary.simpleMessage("節點"),
        "noneMethod": MessageLookupByLibrary.simpleMessage("沒有任何"),
        "notSent": MessageLookupByLibrary.simpleMessage("未傳送"),
        "notificationBody": MessageLookupByLibrary.simpleMessage("查看交易明細"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("輕觸打開"),
        "notificationInfo":
            MessageLookupByLibrary.simpleMessage("為了使此功能正常工作，必須啟用通知"),
        "notificationTitle": MessageLookupByLibrary.simpleMessage("收到 %1 NANO"),
        "notificationWarning": MessageLookupByLibrary.simpleMessage("通知已禁用"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "付款請求、備忘錄和消息都需要啟用通知才能正常工作，因為它們使用 FCM 通知服務來確保消息傳遞。\n\n如果您不想使用這些功能，可以使用下面的按鈕啟用通知或關閉此卡。"),
        "notificationWarningBodyShort":
            MessageLookupByLibrary.simpleMessage("付款請求、備忘錄和消息將無法正常運行。"),
        "notifications": MessageLookupByLibrary.simpleMessage("通知"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("尼亞諾克"),
        "obscureInfoHeader": MessageLookupByLibrary.simpleMessage("模糊的交易信息"),
        "obscureTransaction": MessageLookupByLibrary.simpleMessage("模糊交易"),
        "obscureTransactionBody": MessageLookupByLibrary.simpleMessage(
            "這不是真正的隱私，但它會讓收款人更難看到是誰給他們匯款的。"),
        "off": MessageLookupByLibrary.simpleMessage("關閉"),
        "ok": MessageLookupByLibrary.simpleMessage("好"),
        "onStr": MessageLookupByLibrary.simpleMessage("開啟"),
        "onboard": MessageLookupByLibrary.simpleMessage("邀請某人"),
        "onboarding": MessageLookupByLibrary.simpleMessage("入職"),
        "onramp": MessageLookupByLibrary.simpleMessage("在坡道上"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("打開"),
        "paid": MessageLookupByLibrary.simpleMessage("支付"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("紙錢包"),
        "passwordBlank": MessageLookupByLibrary.simpleMessage("密碼不得留白"),
        "passwordCapitalLetter":
            MessageLookupByLibrary.simpleMessage("密碼必須至少包含 1 個大寫和小寫字母"),
        "passwordDisclaimer": MessageLookupByLibrary.simpleMessage(
            "如果您忘記了密碼，我們概不負責，並且我們無法為您重置或更改密碼。"),
        "passwordIncorrect": MessageLookupByLibrary.simpleMessage("密碼錯誤"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage("您日後啟動 Nautilus 時不用輸入密碼。"),
        "passwordNumber":
            MessageLookupByLibrary.simpleMessage("密碼必須至少包含 1 個數字"),
        "passwordSpecialCharacter":
            MessageLookupByLibrary.simpleMessage("密碼必須至少包含 1 個特殊字符"),
        "passwordTooShort": MessageLookupByLibrary.simpleMessage("密碼太短"),
        "passwordWarning":
            MessageLookupByLibrary.simpleMessage("打開 Nautilus 需要此密碼。"),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage("以後需要這個密碼方可開啟 Nautilus。"),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage("密碼不匹配"),
        "pay": MessageLookupByLibrary.simpleMessage("支付"),
        "payRequest": MessageLookupByLibrary.simpleMessage("支付此請求"),
        "paymentRequestMessage":
            MessageLookupByLibrary.simpleMessage("有人要求您付款！查看付款頁面以獲取更多信息。"),
        "payments": MessageLookupByLibrary.simpleMessage("付款"),
        "pickFromList": MessageLookupByLibrary.simpleMessage("自代表名單選擇"),
        "pinBlank": MessageLookupByLibrary.simpleMessage("引腳不能為空"),
        "pinConfirmError": MessageLookupByLibrary.simpleMessage("識別碼不匹配"),
        "pinConfirmTitle": MessageLookupByLibrary.simpleMessage("確認您的識別碼"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("建立 6 個數字組成的辨識碼"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("輸入識別碼"),
        "pinIncorrect": MessageLookupByLibrary.simpleMessage("輸入的密碼不正確"),
        "pinInvalid": MessageLookupByLibrary.simpleMessage("輸入的識別碼無效"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("識別碼"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage("輸入識別碼以變更代表。"),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage("輸入識別碼以查看錢包種子"),
        "pinsDontMatch": MessageLookupByLibrary.simpleMessage("引腳不匹配"),
        "plausibleDeniabilityParagraph":
            MessageLookupByLibrary.simpleMessage("這與您用於創建錢包的密碼不同。按信息按鈕了解更多信息。"),
        "plausibleInfoHeader":
            MessageLookupByLibrary.simpleMessage("似是而非的否認信息"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "為似是而非的否認模式設置輔助引腳。\n\n如果您的錢包使用此輔助密碼解鎖，您的種子將替換為現有種子的哈希值。這是一項安全功能，旨在在您被迫打開錢包的情況下使用。\n\n除了解鎖你的錢包時，這個密碼就像一個正常的（正確的）密碼，這是在合理的否認模式將激活的時候。\n\n如果您沒有備份您的種子，您的資金將在進入合理否認模式時丟失！"),
        "preferences": MessageLookupByLibrary.simpleMessage("個人偏好"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("隱私政策"),
        "proSubRequiredHeader":
            MessageLookupByLibrary.simpleMessage("需要訂閱 Nautilus Pro"),
        "proSubRequiredParagraph": MessageLookupByLibrary.simpleMessage(
            "每月只需 1 NANO，您就可以解鎖 Nautilus Pro 的所有功能。"),
        "promotionalLink": MessageLookupByLibrary.simpleMessage("免費納米"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("購買納米"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage("二維條碼不含有效的地址"),
        "qrInvalidPermissions":
            MessageLookupByLibrary.simpleMessage("請允許相機權限來掃描二維條碼"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage("二維條碼不含任何有效的種子"),
        "qrMnemonicError":
            MessageLookupByLibrary.simpleMessage("二維條碼不含有效的秘密詞語"),
        "qrUnknownError": MessageLookupByLibrary.simpleMessage("無法讀取二維條碼"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp": MessageLookupByLibrary.simpleMessage("對應用程序評分"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "如果您喜歡該應用程序，請考慮花時間對其進行審查，\n它確實有幫助，不應該花費超過一分鐘。"),
        "rawSeed": MessageLookupByLibrary.simpleMessage("種子"),
        "readMore": MessageLookupByLibrary.simpleMessage("閱讀更多"),
        "receivable": MessageLookupByLibrary.simpleMessage("應收帳款"),
        "receive": MessageLookupByLibrary.simpleMessage("接收"),
        "receiveMinimum": MessageLookupByLibrary.simpleMessage("接收最低"),
        "receiveMinimumHeader": MessageLookupByLibrary.simpleMessage("接收最低資訊"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "收到的最低金額。如果收到的付款或請求金額少於此金額，則會被忽略。"),
        "received": MessageLookupByLibrary.simpleMessage("收到"),
        "refund": MessageLookupByLibrary.simpleMessage("退款"),
        "registerButton": MessageLookupByLibrary.simpleMessage("登記"),
        "registerFor": MessageLookupByLibrary.simpleMessage("為了"),
        "registerUsername": MessageLookupByLibrary.simpleMessage("註冊用戶名"),
        "registerUsernameHeader": MessageLookupByLibrary.simpleMessage("註冊用戶名"),
        "registering": MessageLookupByLibrary.simpleMessage("註冊"),
        "remove": MessageLookupByLibrary.simpleMessage("消除"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "您確定要隱藏此帳戶？ 您之後可輕觸 \"%1\" 按鈕來重新增添此帳戶。"),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("解除封鎖"),
        "removeBlockedConfirmation":
            MessageLookupByLibrary.simpleMessage("您確定要解除封鎖% 1 嗎？"),
        "removeContact": MessageLookupByLibrary.simpleMessage("刪除聯絡人"),
        "removeContactConfirmation":
            MessageLookupByLibrary.simpleMessage("您確定要删除 %1 嗎？"),
        "removeFavorite": MessageLookupByLibrary.simpleMessage("移除我的最愛"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "代表是指透過開放式代表投票以達成網路共識的帳戶。代表的投票權重由帳戶餘額加權，您可用餘額來增加您信任的代表的投票權重。您的代表對您的資金沒有控制權。您應該選擇一個鮮少離線且值得信賴的代表。"),
        "repInfoHeader": MessageLookupByLibrary.simpleMessage("什麼是代表？"),
        "reply": MessageLookupByLibrary.simpleMessage("回覆"),
        "representatives": MessageLookupByLibrary.simpleMessage("代表"),
        "request": MessageLookupByLibrary.simpleMessage("要求"),
        "requestAmountConfirm": MessageLookupByLibrary.simpleMessage("請求% 1"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "要求失敗：此使用者似乎沒有安裝 Nautilus，或已停用通知。"),
        "requestFrom": MessageLookupByLibrary.simpleMessage("請求來自"),
        "requestPayment": MessageLookupByLibrary.simpleMessage("請求付款"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "傳送付款要求時發生錯誤，收件人的裝置可能離線或無法使用。"),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "請求重新發送！如果仍未確認，則收件者的裝置可能處於離線狀態。"),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "使用端到端加密消息請求付款！\n\n付款請求、備忘錄和消息只能由其他 nautilus 用戶接收，但即使收件人不使用 nautilus，您也可以將它們用於自己的記錄保存。"),
        "requestSheetInfoHeader": MessageLookupByLibrary.simpleMessage("請求表信息"),
        "requested": MessageLookupByLibrary.simpleMessage("要求"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("要求來源"),
        "requesting": MessageLookupByLibrary.simpleMessage("要求"),
        "requireAPasswordToOpenHeader":
            MessageLookupByLibrary.simpleMessage("需要密碼才可開啟 Nautilus 嗎？"),
        "requireCaptcha":
            MessageLookupByLibrary.simpleMessage("要求 CAPTCHA 領取禮品卡"),
        "resendMemo": MessageLookupByLibrary.simpleMessage("重新傳送此備忘錄"),
        "resetAccountButton": MessageLookupByLibrary.simpleMessage("重置帳戶"),
        "resetAccountParagraph": MessageLookupByLibrary.simpleMessage(
            "這將使用您剛剛設置的密碼創建一個新帳戶，除非選擇的密碼相同，否則舊帳戶不會被刪除。"),
        "resetDatabase": MessageLookupByLibrary.simpleMessage("重設資料庫"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "您確定要重設內部資料庫嗎？ \n\n這可能會修復與更新應用程式相關的問題，但也會刪除所有儲存的偏好設定。這不會刪除您的錢包種子。如果您遇到問題，則應備份種子，重新安裝該應用程序，如果問題仍然存在，請隨時在 github 或不和諧上進行錯誤報告。"),
        "retry": MessageLookupByLibrary.simpleMessage("重試"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "您的裝置似乎已「越獄」或被修改，從而存在安全疑慮。建議您在繼續之前，將裝置還原至初始狀態。"),
        "scanInstructions":
            MessageLookupByLibrary.simpleMessage("掃描 NANO 二維條碼地址"),
        "scanNFC": MessageLookupByLibrary.simpleMessage("通過 NFC 發送"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("掃描二維條碼"),
        "searchHint": MessageLookupByLibrary.simpleMessage("搜尋任何東西"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "您將看到您的秘密詞語，秘密詞語是存取您資產的密碼。務必確認您將其備份，不與他人分享。"),
        "secretInfoHeader": MessageLookupByLibrary.simpleMessage("安全至上！"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("秘密詞語"),
        "secretPhraseCopied": MessageLookupByLibrary.simpleMessage("已複製秘密詞語"),
        "secretPhraseCopy": MessageLookupByLibrary.simpleMessage("複製秘密詞語"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "若您的手機遺失或卸載本程式，就需要您的種子或秘密詞語才可重新處理您的資產！"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("資訊安全"),
        "seed": MessageLookupByLibrary.simpleMessage("種子"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "以下是您錢包的種子。請注意，您一定要備份種子，但不要將其儲存為純文字或螢幕截圖"),
        "seedCopied":
            MessageLookupByLibrary.simpleMessage("將種子複製到剪貼簿。\n2 分鐘後失效"),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("種子已複製"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "種子和秘密詞語包含相同資訊，只是前者用機器可讀形式。只要事先備份種子或秘密詞語，即可存取您的資產。"),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("種子無效"),
        "selfSendError": MessageLookupByLibrary.simpleMessage("無法向自己請求"),
        "send": MessageLookupByLibrary.simpleMessage("發送"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("發送 %1 NANO？"),
        "sendAmounts": MessageLookupByLibrary.simpleMessage("發送金額"),
        "sendError": MessageLookupByLibrary.simpleMessage("發生錯誤。稍後再試。"),
        "sendFrom": MessageLookupByLibrary.simpleMessage("發送自："),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "發送交易備忘錄失敗，他們可能不是 Nautilus 用戶。"),
        "sendMessageConfirm": MessageLookupByLibrary.simpleMessage("發送消息"),
        "sendRequestAgain": MessageLookupByLibrary.simpleMessage("再次發送請求"),
        "sendRequests": MessageLookupByLibrary.simpleMessage("發送請求"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "發送或請求付款，帶有端到端加密消息！\n\n付款請求，備忘錄和消息僅由其他 Nautilus 用戶應收。\n\n您無需擁有用戶名即可發送或接收付款請求，即使他們不使用鸚鵡螺，也可以將它們用於自己的記錄保存。"),
        "sendSheetInfoHeader": MessageLookupByLibrary.simpleMessage("傳送工作表資訊"),
        "sending": MessageLookupByLibrary.simpleMessage("傳送"),
        "sent": MessageLookupByLibrary.simpleMessage("發送"),
        "sentTo": MessageLookupByLibrary.simpleMessage("發送給："),
        "set": MessageLookupByLibrary.simpleMessage("放"),
        "setPassword": MessageLookupByLibrary.simpleMessage("設定密碼"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage("順利設定密碼"),
        "setPin": MessageLookupByLibrary.simpleMessage("設置引腳"),
        "setPinParagraph": MessageLookupByLibrary.simpleMessage(
            "設置或更改您現有的 PIN。如果您尚未設置 PIN，則默認 PIN 為 000000。"),
        "setPinSuccess": MessageLookupByLibrary.simpleMessage("已成功設置引腳"),
        "setPlausibleDeniabilityPin":
            MessageLookupByLibrary.simpleMessage("設置合理的引腳"),
        "setRestoreHeight": MessageLookupByLibrary.simpleMessage("設置恢復高度"),
        "setWalletPassword": MessageLookupByLibrary.simpleMessage("設定錢包密碼"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "setXMRRestoreHeight":
            MessageLookupByLibrary.simpleMessage("設置 XMR 恢復高度"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("設定"),
        "settingsTransfer": MessageLookupByLibrary.simpleMessage("透過紙錢包儲值"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "shareLink": MessageLookupByLibrary.simpleMessage("分享連結"),
        "shareMessage": MessageLookupByLibrary.simpleMessage("分享訊息"),
        "shareNautilus": MessageLookupByLibrary.simpleMessage("分享 Nautilus"),
        "shareNautilusText": MessageLookupByLibrary.simpleMessage(
            "請試試 Nautilus —— 針對行動裝置的 NANO 錢包！"),
        "shareText": MessageLookupByLibrary.simpleMessage("分享文字"),
        "shopButton": MessageLookupByLibrary.simpleMessage("店鋪"),
        "show": MessageLookupByLibrary.simpleMessage("節目"),
        "showAccountInfo": MessageLookupByLibrary.simpleMessage("帳戶信息"),
        "showAccountQR": MessageLookupByLibrary.simpleMessage("顯示賬戶二維碼"),
        "showContacts": MessageLookupByLibrary.simpleMessage("顯示聯絡人"),
        "showFunding": MessageLookupByLibrary.simpleMessage("顯示資金橫幅"),
        "showLinkOptions": MessageLookupByLibrary.simpleMessage("顯示鏈接選項"),
        "showLinkQR": MessageLookupByLibrary.simpleMessage("顯示鏈接二維碼"),
        "showMoneroHeader": MessageLookupByLibrary.simpleMessage("顯示門羅幣"),
        "showMoneroInfo": MessageLookupByLibrary.simpleMessage("啟用門羅幣部分"),
        "showQR": MessageLookupByLibrary.simpleMessage("顯示二維碼"),
        "showUnopenedWarning": MessageLookupByLibrary.simpleMessage("未開封警告"),
        "simplex": MessageLookupByLibrary.simpleMessage("單面"),
        "social": MessageLookupByLibrary.simpleMessage("社會的"),
        "someone": MessageLookupByLibrary.simpleMessage("某人"),
        "spendNano": MessageLookupByLibrary.simpleMessage("花費 NANO"),
        "splitBill": MessageLookupByLibrary.simpleMessage("拆分賬單"),
        "splitBillHeader": MessageLookupByLibrary.simpleMessage("拆分賬單"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "一次發送一堆付款請求！例如，它可以很容易地在餐廳拆分賬單。"),
        "splitBillInfoHeader": MessageLookupByLibrary.simpleMessage("拆分賬單信息"),
        "splitBy": MessageLookupByLibrary.simpleMessage("拆分依據"),
        "subscribeButton": MessageLookupByLibrary.simpleMessage("訂閱"),
        "subscribeWithApple":
            MessageLookupByLibrary.simpleMessage("通過 Apple Pay 訂閱"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment": MessageLookupByLibrary.simpleMessage("幫助支持發展"),
        "supportTheDeveloper": MessageLookupByLibrary.simpleMessage("支持開發人員"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("交換 XMR"),
        "swapXMRHeader": MessageLookupByLibrary.simpleMessage("交換門羅幣"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "門羅幣是一種以隱私為中心的加密貨幣，它使得追踪交易變得非常困難甚至不可能。同時，NANO 是一種以支付為中心的加密貨幣，速度快，費用低。它們一起提供了加密貨幣的一些最有用的方面！\n\n使用此頁面輕鬆將您的 NANO 換成 XMR！"),
        "swapping": MessageLookupByLibrary.simpleMessage("交換"),
        "switchToSeed": MessageLookupByLibrary.simpleMessage("轉換為種子"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("系統預設"),
        "tapMessageToEdit": MessageLookupByLibrary.simpleMessage("點按消息進行編輯"),
        "tapToHide": MessageLookupByLibrary.simpleMessage("輕觸以隱藏"),
        "tapToReveal": MessageLookupByLibrary.simpleMessage("輕觸以揭露"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("佈景主題"),
        "thisMayTakeSomeTime":
            MessageLookupByLibrary.simpleMessage("可能還要等一下..."),
        "to": MessageLookupByLibrary.simpleMessage("至："),
        "tooManyFailedAttempts":
            MessageLookupByLibrary.simpleMessage("解鎖失敗太多次"),
        "trackingHeader": MessageLookupByLibrary.simpleMessage("追踪授權"),
        "trackingWarning": MessageLookupByLibrary.simpleMessage("跟踪已禁用"),
        "trackingWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "如果禁用跟踪，禮品卡功能可能會減少或根本無法使用。我們將此權限專門用於此功能。絕對不會出於任何不必要的目的在後端出售、收集或跟踪您的任何數據"),
        "trackingWarningBodyShort":
            MessageLookupByLibrary.simpleMessage("禮品卡鏈接無法正常工作"),
        "transactions": MessageLookupByLibrary.simpleMessage("交易"),
        "transfer": MessageLookupByLibrary.simpleMessage("移轉"),
        "transferClose": MessageLookupByLibrary.simpleMessage("輕觸任意位置以關閉視窗。"),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO 順利移轉到您的 Nautilus 錢包。\n"),
        "transferConfirmInfo":
            MessageLookupByLibrary.simpleMessage("偵測到一個內有 %1 NANO 的錢包。\n"),
        "transferConfirmInfoSecond":
            MessageLookupByLibrary.simpleMessage("輕觸以確認移轉。\n"),
        "transferConfirmInfoThird":
            MessageLookupByLibrary.simpleMessage("移轉需要幾秒鐘完成，請稍等。"),
        "transferError":
            MessageLookupByLibrary.simpleMessage("轉帳過程遇到障礙，請稍後再試。"),
        "transferHeader": MessageLookupByLibrary.simpleMessage("自紙錢包移轉資產"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "這過程會將紙錢包的資產移轉至您的 Nautilus 錢包。\n\n輕觸 \"%1\" 按鈕開始。"),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "這個過程會將資金從紙錢包轉移到您的 Nautilus 錢包。"),
        "transferLoading": MessageLookupByLibrary.simpleMessage("移轉中"),
        "transferManualHint": MessageLookupByLibrary.simpleMessage("請輸入紙錢包的種子"),
        "transferNoFunds":
            MessageLookupByLibrary.simpleMessage("這個種子不含任何 NANO"),
        "transferQrScanError":
            MessageLookupByLibrary.simpleMessage("這個二維條碼不含任何有效的種子"),
        "transferQrScanHint":
            MessageLookupByLibrary.simpleMessage("掃描 NANO 種子"),
        "unacknowledged": MessageLookupByLibrary.simpleMessage("未公開承認的"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("未經證實"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("沒有實現"),
        "unlock": MessageLookupByLibrary.simpleMessage("解鎖"),
        "unlockBiometrics":
            MessageLookupByLibrary.simpleMessage("經由生物辨識解鎖 Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage("請輸入識別碼以解鎖 Nautilus"),
        "unopenedWarningHeader":
            MessageLookupByLibrary.simpleMessage("顯示未打開的警告"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "在向未開立的賬戶發送資金時顯示警告，這很有用，因為您發送到的大多數時間地址都會有餘額，而發送到新地址可能是拼寫錯誤的結果。"),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "你確定這是正確的地址嗎？\n此帳戶似乎未打開\n\n您可以在“未打開警告”下的設置抽屜中禁用此警告"),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("未開戶"),
        "unpaid": MessageLookupByLibrary.simpleMessage("未付"),
        "unread": MessageLookupByLibrary.simpleMessage("未讀"),
        "uptime": MessageLookupByLibrary.simpleMessage("上線時間"),
        "urlEmpty": MessageLookupByLibrary.simpleMessage("請輸入網址"),
        "useNano": MessageLookupByLibrary.simpleMessage("使用納米"),
        "useNautilusRep":
            MessageLookupByLibrary.simpleMessage("Use Nautilus Rep"),
        "userAlreadyAddedError": MessageLookupByLibrary.simpleMessage("用戶已添加！"),
        "userNotFound": MessageLookupByLibrary.simpleMessage("找不到用戶！"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "您已經註冊了用戶名！目前無法更改您的用戶名，但您可以在其他地址下自由註冊一個新的用戶名。"),
        "usernameAvailable": MessageLookupByLibrary.simpleMessage("用戶名可用！"),
        "usernameEmpty": MessageLookupByLibrary.simpleMessage("請輸入使用者名稱"),
        "usernameError": MessageLookupByLibrary.simpleMessage("用戶名錯誤"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "挑選一個獨特的 @username，讓朋友和家人都能輕鬆找到你！\n\n擁有 Nautilus 使用者名稱會在全球範圍內更新使用者介面，以反映您的新帳號。"),
        "usernameInvalid": MessageLookupByLibrary.simpleMessage("無效的用戶名"),
        "usernameUnavailable": MessageLookupByLibrary.simpleMessage("用戶名不可用"),
        "usernameWarning": MessageLookupByLibrary.simpleMessage(
            "Nautilus 用戶名是 Nano.by 提供的集中式服務"),
        "using": MessageLookupByLibrary.simpleMessage("使用"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("更多資訊"),
        "viewTX": MessageLookupByLibrary.simpleMessage("查看交易"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("投票比重"),
        "warning": MessageLookupByLibrary.simpleMessage("警告"),
        "watchAccountExists": MessageLookupByLibrary.simpleMessage("帳號已添加！"),
        "watchOnlyAccount": MessageLookupByLibrary.simpleMessage("僅觀看帳戶"),
        "watchOnlySendDisabled":
            MessageLookupByLibrary.simpleMessage("僅監視地址上禁用發送"),
        "weekAgo": MessageLookupByLibrary.simpleMessage("一星期前"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "歡迎來到 Nautilus。接著您可建立新錢包或匯入現有錢包"),
        "welcomeTextLogin": MessageLookupByLibrary.simpleMessage(
            "歡迎來到鸚鵡螺。選擇一個選項以開始使用或使用下面的圖標選擇一個主題。"),
        "welcomeTextUpdated":
            MessageLookupByLibrary.simpleMessage("歡迎來到鸚鵡螺。首先，創建一個新錢包或導入現有錢包。"),
        "welcomeTextWithoutLogin":
            MessageLookupByLibrary.simpleMessage("首先，創建一個新錢包或導入現有錢包。"),
        "withAddress": MessageLookupByLibrary.simpleMessage("有地址"),
        "withFee": MessageLookupByLibrary.simpleMessage("有費用"),
        "withMessage": MessageLookupByLibrary.simpleMessage("有訊息"),
        "xMinute": MessageLookupByLibrary.simpleMessage("%1 分鐘後"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("%1 分鐘後"),
        "xmrStatusConnecting": MessageLookupByLibrary.simpleMessage("連接"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("錯誤"),
        "xmrStatusLoading": MessageLookupByLibrary.simpleMessage("正在加載"),
        "xmrStatusSynchronized": MessageLookupByLibrary.simpleMessage("同步"),
        "xmrStatusSynchronizing": MessageLookupByLibrary.simpleMessage("同步"),
        "yes": MessageLookupByLibrary.simpleMessage("確認"),
        "yesButton": MessageLookupByLibrary.simpleMessage("確認")
      };
}
