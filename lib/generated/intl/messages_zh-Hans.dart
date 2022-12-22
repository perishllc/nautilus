// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hans locale. All the
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
  String get localeName => 'zh_Hans';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("账户"),
        "accountNameHint": MessageLookupByLibrary.simpleMessage("输入名称"),
        "accountNameMissing": MessageLookupByLibrary.simpleMessage("选择一个帐户名称"),
        "accounts": MessageLookupByLibrary.simpleMessage("账户"),
        "ackBackedUp":
            MessageLookupByLibrary.simpleMessage("您确定已经将您的种子或秘密词语备份了吗？"),
        "activeMessageHeader": MessageLookupByLibrary.simpleMessage("活动消息"),
        "addAccount": MessageLookupByLibrary.simpleMessage("添加账户"),
        "addAddress": MessageLookupByLibrary.simpleMessage("添加地址"),
        "addBlocked": MessageLookupByLibrary.simpleMessage("屏蔽用户"),
        "addContact": MessageLookupByLibrary.simpleMessage("添加联系人"),
        "addFavorite": MessageLookupByLibrary.simpleMessage("添加收藏夹"),
        "addNode": MessageLookupByLibrary.simpleMessage("添加节点"),
        "addUser": MessageLookupByLibrary.simpleMessage("添加用户"),
        "addWatchOnlyAccount": MessageLookupByLibrary.simpleMessage("添加仅观看帐户"),
        "addWatchOnlyAccountError":
            MessageLookupByLibrary.simpleMessage("添加仅观看帐户时出错：帐户为空"),
        "addWatchOnlyAccountSuccess":
            MessageLookupByLibrary.simpleMessage("已成功创建仅限观看的帐户！"),
        "address": MessageLookupByLibrary.simpleMessage("地址"),
        "addressCopied": MessageLookupByLibrary.simpleMessage("地址已复制"),
        "addressHint": MessageLookupByLibrary.simpleMessage("输入地址"),
        "addressMissing": MessageLookupByLibrary.simpleMessage("请输入目标地址"),
        "addressOrUserMissing":
            MessageLookupByLibrary.simpleMessage("请输入用户名或地址"),
        "addressShare": MessageLookupByLibrary.simpleMessage("分享地址"),
        "advanced": MessageLookupByLibrary.simpleMessage(""),
        "aliases": MessageLookupByLibrary.simpleMessage("别名"),
        "amountGiftGreaterError":
            MessageLookupByLibrary.simpleMessage("分割金额不能大于礼物余额"),
        "amountMissing": MessageLookupByLibrary.simpleMessage("请输入金额"),
        "askSkipSetup": MessageLookupByLibrary.simpleMessage(
            "我们注意到您单击了包含一些 nano 的链接，您想跳过设置过程吗？你以后总是可以改变的。\n\n 但是，如果您有要导入的现有种子，则应选择否。"),
        "askTracking": MessageLookupByLibrary.simpleMessage(
            "我们即将请求“跟踪”权限，这*严格*用于归因链接/推荐和次要分析（例如安装数量、应用版本等）我们相信您有权享有您的隐私并且对您的任何个人数据不感兴趣，我们只需要获得许可，链接属性才能正常工作。"),
        "asked": MessageLookupByLibrary.simpleMessage("问"),
        "authConfirm": MessageLookupByLibrary.simpleMessage("认证"),
        "authError": MessageLookupByLibrary.simpleMessage("验证时出错。稍后再试。"),
        "authMethod": MessageLookupByLibrary.simpleMessage("验证方法"),
        "authenticating": MessageLookupByLibrary.simpleMessage("认证"),
        "autoImport": MessageLookupByLibrary.simpleMessage("自动导入"),
        "autoLockHeader": MessageLookupByLibrary.simpleMessage("自动锁定"),
        "autoRenewSub": MessageLookupByLibrary.simpleMessage("自动续订"),
        "backupConfirmButton": MessageLookupByLibrary.simpleMessage("我已备份"),
        "backupSecretPhrase": MessageLookupByLibrary.simpleMessage("备份秘密词语"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("备份种子"),
        "backupSeedConfirm":
            MessageLookupByLibrary.simpleMessage("您确认您备份了您的钱包种子吗？"),
        "backupYourSeed": MessageLookupByLibrary.simpleMessage("备份您的种子"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("生物识别技术"),
        "blockExplorer": MessageLookupByLibrary.simpleMessage("区块浏览器"),
        "blockExplorerHeader": MessageLookupByLibrary.simpleMessage("区块浏览器信息"),
        "blockExplorerInfo":
            MessageLookupByLibrary.simpleMessage("使用哪个区块浏览器显示交易信息"),
        "blockUser": MessageLookupByLibrary.simpleMessage("屏蔽此用户"),
        "blockedAdded": MessageLookupByLibrary.simpleMessage("%1 已成功阻止。"),
        "blockedExists": MessageLookupByLibrary.simpleMessage("用户已被封锁！"),
        "blockedHeader": MessageLookupByLibrary.simpleMessage("已封锁"),
        "blockedInfo": MessageLookupByLibrary.simpleMessage(
            "通过任何已知的别名或地址屏蔽用户。任何消息、事务或来自它们的请求都将被忽略。"),
        "blockedInfoHeader": MessageLookupByLibrary.simpleMessage("封锁信息"),
        "blockedNameExists": MessageLookupByLibrary.simpleMessage("昵称已经使用了！"),
        "blockedNameMissing": MessageLookupByLibrary.simpleMessage("选择一个昵称"),
        "blockedRemoved": MessageLookupByLibrary.simpleMessage("%1 已解除封锁！"),
        "branchConnectErrorLongDesc": MessageLookupByLibrary.simpleMessage(
            "我们似乎无法访问 Branch API，这通常是由某种网络问题或 VPN 阻止连接引起的。\n\n 您应该仍然可以正常使用该应用程序，但发送和接收礼品卡可能无法正常工作。"),
        "branchConnectErrorShortDesc":
            MessageLookupByLibrary.simpleMessage("错误：无法访问分支 API"),
        "branchConnectErrorTitle": MessageLookupByLibrary.simpleMessage("连接警告"),
        "businessButton": MessageLookupByLibrary.simpleMessage("商业"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "captchaWarning": MessageLookupByLibrary.simpleMessage("验证码"),
        "captchaWarningBody": MessageLookupByLibrary.simpleMessage(
            "为了防止滥用，我们要求您解决验证码才能在下一页领取礼品卡。"),
        "changeCurrency": MessageLookupByLibrary.simpleMessage("更改货币"),
        "changeLog": MessageLookupByLibrary.simpleMessage("更改日志"),
        "changeNode": MessageLookupByLibrary.simpleMessage("改变节点"),
        "changePassword": MessageLookupByLibrary.simpleMessage("更改密码"),
        "changePasswordParagraph": MessageLookupByLibrary.simpleMessage(
            "更改现有密码。如果您不知道当前密码，请做出最佳猜测，因为实际上不需要更改它（因为您已经登录），但它确实让我们删除了现有的备份条目。"),
        "changePin": MessageLookupByLibrary.simpleMessage("更改引脚"),
        "changePinHint": MessageLookupByLibrary.simpleMessage("设置引脚"),
        "changeRepAuthenticate": MessageLookupByLibrary.simpleMessage("更改代表"),
        "changeRepButton": MessageLookupByLibrary.simpleMessage("更改"),
        "changeRepHint": MessageLookupByLibrary.simpleMessage("输入新代表"),
        "changeRepSame": MessageLookupByLibrary.simpleMessage("这已经是你的代表了！"),
        "changeRepSucces": MessageLookupByLibrary.simpleMessage("代表更改成功"),
        "changeSeed": MessageLookupByLibrary.simpleMessage("改变种子"),
        "changeSeedParagraph": MessageLookupByLibrary.simpleMessage(
            "更改与此magic-link authed 帐户关联的种子/短语，您在此处设置的任何密码都将覆盖您现有的密码，但您可以选择使用相同的密码。"),
        "checkAvailability": MessageLookupByLibrary.simpleMessage("查看空房情况"),
        "close": MessageLookupByLibrary.simpleMessage("关闭"),
        "confirm": MessageLookupByLibrary.simpleMessage("确认"),
        "confirmPasswordHint": MessageLookupByLibrary.simpleMessage("确认密码"),
        "confirmPinHint": MessageLookupByLibrary.simpleMessage("确认引脚"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("连接中"),
        "connectionWarning": MessageLookupByLibrary.simpleMessage("无法连接"),
        "connectionWarningBody": MessageLookupByLibrary.simpleMessage(
            "我们似乎无法连接到后端，这可能只是您的连接，或者如果问题仍然存在，后端可能会因维护甚至中断而停机。如果一个多小时后仍然有问题，请在 discord 服务器@chat.perish.co 的#bug-reports 中提交报告"),
        "connectionWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "我们似乎无法连接到后端，这可能只是您的连接，或者如果问题仍然存在，后端可能会因维护甚至中断而停机。如果一个多小时后仍然有问题，请在 discord 服务器@chat.perish.co 的#bug-reports 中提交报告"),
        "connectionWarningBodyShort":
            MessageLookupByLibrary.simpleMessage("我们似乎无法连接到后端"),
        "contactAdded": MessageLookupByLibrary.simpleMessage("%1已被添加到联系人！"),
        "contactExists": MessageLookupByLibrary.simpleMessage("联系人已存在"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("联系人"),
        "contactInvalid": MessageLookupByLibrary.simpleMessage("联系人姓名无效"),
        "contactNameHint": MessageLookupByLibrary.simpleMessage("输入姓名@"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage("没有要导出的联系人"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage("%1已从联系人名单中刪除!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("联系人名单"),
        "contactsImportErr": MessageLookupByLibrary.simpleMessage("无法导入联系人"),
        "contactsImportSuccess":
            MessageLookupByLibrary.simpleMessage("已成功导入％1个联系人"),
        "continueButton": MessageLookupByLibrary.simpleMessage("继续"),
        "continueWithoutLogin":
            MessageLookupByLibrary.simpleMessage("无需登录即可继续"),
        "copied": MessageLookupByLibrary.simpleMessage("已复制"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("复制地址"),
        "copyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
        "copyMessage": MessageLookupByLibrary.simpleMessage("复制消息"),
        "copySeed": MessageLookupByLibrary.simpleMessage("复制种子"),
        "copyWalletAddressToClipboard":
            MessageLookupByLibrary.simpleMessage("将钱包地址复制到剪贴板"),
        "copyXMRSeed": MessageLookupByLibrary.simpleMessage("复制门罗币种子"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("创建一个密码。"),
        "createGiftCard": MessageLookupByLibrary.simpleMessage("创建礼品卡"),
        "createGiftHeader": MessageLookupByLibrary.simpleMessage("创建礼品卡"),
        "createPasswordFirstParagraph":
            MessageLookupByLibrary.simpleMessage("您可以创建一个密码来加强您钱包的安全性。"),
        "createPasswordHint": MessageLookupByLibrary.simpleMessage("创建密码"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "密码是可选的，无论如何您的钱包仍会被识别码或生物识别技术保护。"),
        "createPasswordSheetHeader": MessageLookupByLibrary.simpleMessage("创建"),
        "createPinHint": MessageLookupByLibrary.simpleMessage("创建图钉"),
        "createQR": MessageLookupByLibrary.simpleMessage("创建二维码"),
        "created": MessageLookupByLibrary.simpleMessage("创建"),
        "creatingGiftCard": MessageLookupByLibrary.simpleMessage("创建礼品卡"),
        "currency": MessageLookupByLibrary.simpleMessage("货币"),
        "currencyMode": MessageLookupByLibrary.simpleMessage("货币模式"),
        "currencyModeHeader": MessageLookupByLibrary.simpleMessage("货币模式信息"),
        "currencyModeInfo": MessageLookupByLibrary.simpleMessage(
            "选择要显示金额的单位。\n1 nyano = 0.000001 NANO，或者 \n1,000,000 nyano = 1 NANO"),
        "currentlyRepresented": MessageLookupByLibrary.simpleMessage("当前代表"),
        "dayAgo": MessageLookupByLibrary.simpleMessage("一天前"),
        "decryptionError": MessageLookupByLibrary.simpleMessage("解密错误！"),
        "defaultAccountName": MessageLookupByLibrary.simpleMessage("主要账户"),
        "defaultGiftMessage":
            MessageLookupByLibrary.simpleMessage("看看鹦鹉螺！我用这个链接给你发了一些 nano："),
        "defaultNewAccountName": MessageLookupByLibrary.simpleMessage("账户 %1"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "deleteNodeConfirmation": MessageLookupByLibrary.simpleMessage(
            "您确定要删除此节点吗？\n\n您以后随时可以通过点击“添加节点”按钮重新添加它"),
        "deleteNodeHeader": MessageLookupByLibrary.simpleMessage("删除节点？"),
        "deleteRequest":
            MessageLookupByLibrary.simpleMessage("Delete this request"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("解除"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("钱包密码已被解除"),
        "disableWalletPassword": MessageLookupByLibrary.simpleMessage("解除钱包密码"),
        "dismiss": MessageLookupByLibrary.simpleMessage("解雇"),
        "doYouHaveSeedBody": MessageLookupByLibrary.simpleMessage(
            "如果您不确定这意味着什么，那么您可能没有要导入的种子，可以按继续。"),
        "doYouHaveSeedHeader":
            MessageLookupByLibrary.simpleMessage("你有种子要进口吗？"),
        "domainInvalid": MessageLookupByLibrary.simpleMessage("域名无效"),
        "donateButton": MessageLookupByLibrary.simpleMessage("捐"),
        "donateToSupport": MessageLookupByLibrary.simpleMessage("支持项目"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "enableNotifications": MessageLookupByLibrary.simpleMessage("启用通知"),
        "enableTracking": MessageLookupByLibrary.simpleMessage("启用跟踪"),
        "encryptionFailedError":
            MessageLookupByLibrary.simpleMessage("钱包密码设置失败"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("输入地址"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("输入金额"),
        "enterEmail": MessageLookupByLibrary.simpleMessage("输入电子邮件"),
        "enterGiftMemo": MessageLookupByLibrary.simpleMessage("输入礼品备注"),
        "enterHeight": MessageLookupByLibrary.simpleMessage("输入高度"),
        "enterHttpUrl": MessageLookupByLibrary.simpleMessage("输入 HTTP 网址"),
        "enterMemo": MessageLookupByLibrary.simpleMessage("输入消息"),
        "enterMoneroAddress": MessageLookupByLibrary.simpleMessage("输入 XMR 地址"),
        "enterNodeName": MessageLookupByLibrary.simpleMessage("输入节点名称"),
        "enterPasswordHint": MessageLookupByLibrary.simpleMessage("输入您的密码"),
        "enterSplitAmount": MessageLookupByLibrary.simpleMessage("输入分割金额"),
        "enterUserOrAddress": MessageLookupByLibrary.simpleMessage("输入用户或地址"),
        "enterUsername": MessageLookupByLibrary.simpleMessage("输入用户名"),
        "enterWsUrl": MessageLookupByLibrary.simpleMessage("输入 WebSocket 网址"),
        "errorProcessingGiftCard":
            MessageLookupByLibrary.simpleMessage("处理此礼品卡时出错，它可能无效、过期或为空。"),
        "eula": MessageLookupByLibrary.simpleMessage("EULA"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("来自某人"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "欢迎来到Nautilus。当您收到或发送NANO时，交易将如下出现。"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("一点"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("很多"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("发给某人"),
        "examplePayRecipient": MessageLookupByLibrary.simpleMessage("@dad"),
        "examplePayRecipientMessage":
            MessageLookupByLibrary.simpleMessage("生日快乐！"),
        "examplePaymentExplainer": MessageLookupByLibrary.simpleMessage(
            "一旦你发送或收到付款请求，它们就会像这样显示在这里，卡片的颜色和标签表示状态。 \n\n绿色表示请求已付款。\n黄色表示请求/备忘录尚未付款/已读。\n红色表示请求尚未被读取或接收。\n\n 没有金额的中性色卡片只是信息。"),
        "examplePaymentFrom": MessageLookupByLibrary.simpleMessage("@landlord"),
        "examplePaymentFulfilled": MessageLookupByLibrary.simpleMessage("一些"),
        "examplePaymentFulfilledMemo":
            MessageLookupByLibrary.simpleMessage("寿司"),
        "examplePaymentIntro":
            MessageLookupByLibrary.simpleMessage("一旦您发送或收到付款请求，它们将显示在此处："),
        "examplePaymentMessage": MessageLookupByLibrary.simpleMessage("嘿怎么了？"),
        "examplePaymentReceivable": MessageLookupByLibrary.simpleMessage("很多"),
        "examplePaymentReceivableMemo":
            MessageLookupByLibrary.simpleMessage("租"),
        "examplePaymentTo":
            MessageLookupByLibrary.simpleMessage("@best_friend"),
        "exampleRecRecipient":
            MessageLookupByLibrary.simpleMessage("@coworker"),
        "exampleRecRecipientMessage":
            MessageLookupByLibrary.simpleMessage("煤气钱"),
        "exchangeNano": MessageLookupByLibrary.simpleMessage("交换纳米"),
        "existingPasswordHint": MessageLookupByLibrary.simpleMessage("输入当前密码"),
        "existingPinHint": MessageLookupByLibrary.simpleMessage("输入当前引脚"),
        "exit": MessageLookupByLibrary.simpleMessage("退出"),
        "exportTXData": MessageLookupByLibrary.simpleMessage("出口交易"),
        "failed": MessageLookupByLibrary.simpleMessage("失败了"),
        "failedMessage": MessageLookupByLibrary.simpleMessage("msg failed"),
        "fallbackHeader": MessageLookupByLibrary.simpleMessage("鹦鹉螺已断开连接"),
        "fallbackInfo": MessageLookupByLibrary.simpleMessage(
            "Nautilus 服务器似乎已断开连接，发送和接收（无备忘录）应该仍然可以运行，但付款请求可能无法通过\n\n 稍后再回来或重启应用程序再试一次"),
        "favoriteExists": MessageLookupByLibrary.simpleMessage("收藏夹已存在"),
        "favoriteHeader": MessageLookupByLibrary.simpleMessage("最喜欢的"),
        "favoriteInvalid": MessageLookupByLibrary.simpleMessage("收藏名称无效"),
        "favoriteNameHint": MessageLookupByLibrary.simpleMessage("输入昵称"),
        "favoriteNameMissing":
            MessageLookupByLibrary.simpleMessage("为此收藏夹选择一个名字"),
        "favoriteRemoved": MessageLookupByLibrary.simpleMessage("%1 已从收藏夹中删除！"),
        "favoritesHeader": MessageLookupByLibrary.simpleMessage("收藏夹"),
        "featured": MessageLookupByLibrary.simpleMessage("精选"),
        "fewDaysAgo": MessageLookupByLibrary.simpleMessage("几天之前"),
        "fewHoursAgo": MessageLookupByLibrary.simpleMessage("几个小时前"),
        "fewMinutesAgo": MessageLookupByLibrary.simpleMessage("几分钟前"),
        "fewSecondsAgo": MessageLookupByLibrary.simpleMessage("几秒钟前"),
        "fingerprintSeedBackup":
            MessageLookupByLibrary.simpleMessage("确认指纹，备份钱包种子。"),
        "from": MessageLookupByLibrary.simpleMessage("来自"),
        "fulfilled": MessageLookupByLibrary.simpleMessage("完成"),
        "fundingBannerHeader": MessageLookupByLibrary.simpleMessage("资金横幅"),
        "fundingHeader": MessageLookupByLibrary.simpleMessage("资金"),
        "getNano": MessageLookupByLibrary.simpleMessage("获取纳米"),
        "giftAlert": MessageLookupByLibrary.simpleMessage("你有天赋！"),
        "giftAlertEmpty": MessageLookupByLibrary.simpleMessage("空礼物"),
        "giftAmount": MessageLookupByLibrary.simpleMessage("礼物金额"),
        "giftCardCreationError":
            MessageLookupByLibrary.simpleMessage("尝试创建礼品卡链接时出错"),
        "giftCardCreationErrorSent": MessageLookupByLibrary.simpleMessage(
            "尝试创建礼品卡时发生错误，礼品卡链接或种子已复制到您的剪贴板，您的资金可能包含在其中，具体取决于出现的问题。"),
        "giftCardInfoHeader": MessageLookupByLibrary.simpleMessage("礼品单信息"),
        "giftFrom": MessageLookupByLibrary.simpleMessage("礼物来自"),
        "giftInfo": MessageLookupByLibrary.simpleMessage(
            "使用 NANO 加载一张数字礼品卡！设置金额和一条可选消息，供收件人打开时查看！\n\n创建后，您将获得一个可以发送给任何人的链接，该链接打开后将在安装Nautilus后自动将资金分配给收款人！\n\n如果收款人已经是Nautilus用户，他们将在打开链接时收到将资金转入其账户的提示。"),
        "giftMessage": MessageLookupByLibrary.simpleMessage("礼物留言"),
        "giftProcessError": MessageLookupByLibrary.simpleMessage(
            "处理此礼品卡时出错。也许检查您的连接并尝试再次单击礼物链接。"),
        "giftProcessSuccess":
            MessageLookupByLibrary.simpleMessage("礼物已成功收到，可能需要一点时间才会出现在您的钱包中。"),
        "giftRefundSuccess": MessageLookupByLibrary.simpleMessage("礼品成功退还！"),
        "giftWarning": MessageLookupByLibrary.simpleMessage(
            "You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("返回"),
        "goToQRCode": MessageLookupByLibrary.simpleMessage("前往二维码"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("明白！"),
        "handoff": MessageLookupByLibrary.simpleMessage("不可触摸"),
        "handoffFailed": MessageLookupByLibrary.simpleMessage("尝试切换块时出现问题！"),
        "handoffSupportedMethodNotFound":
            MessageLookupByLibrary.simpleMessage("找不到受支持的切换方法！"),
        "haveSeedToImport": MessageLookupByLibrary.simpleMessage("我有一颗种子"),
        "hide": MessageLookupByLibrary.simpleMessage("隐藏"),
        "hideAccountHeader": MessageLookupByLibrary.simpleMessage("隐藏账户？"),
        "hideAccountsConfirmation": MessageLookupByLibrary.simpleMessage(
            "您确定要隐藏空帐户吗？\n\n这将隐藏所有余额为 0 的帐户（不包括仅观看地址和您的主帐户），但您以后可以随时通过点击“添加帐户”按钮重新添加它们"),
        "hideAccountsHeader": MessageLookupByLibrary.simpleMessage("隐藏帐户？"),
        "hideEmptyAccounts": MessageLookupByLibrary.simpleMessage("隐藏空账户"),
        "home": MessageLookupByLibrary.simpleMessage("家"),
        "homeButton": MessageLookupByLibrary.simpleMessage("家"),
        "hourAgo": MessageLookupByLibrary.simpleMessage("一小时前"),
        "iUnderstandTheRisks": MessageLookupByLibrary.simpleMessage("我已明白风险"),
        "ignore": MessageLookupByLibrary.simpleMessage("忽略"),
        "imSure": MessageLookupByLibrary.simpleMessage("我确定"),
        "import": MessageLookupByLibrary.simpleMessage("导入"),
        "importGift": MessageLookupByLibrary.simpleMessage(
            "你点击的链接包含一些 nano，你想把它导入这个钱包，还是退款给发送它的人？"),
        "importGiftEmpty": MessageLookupByLibrary.simpleMessage(
            "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message."),
        "importGiftIntro": MessageLookupByLibrary.simpleMessage(
            "看起来你点击了一个包含一些 NANO 的链接，为了接收这些资金，我们只需要你完成设置你的钱包。"),
        "importGiftv2":
            MessageLookupByLibrary.simpleMessage("您点击的链接包含一些 NANO，您想将其导入此钱包吗？"),
        "importHD": MessageLookupByLibrary.simpleMessage("导入高清"),
        "importSecretPhrase": MessageLookupByLibrary.simpleMessage("输入秘密词语"),
        "importSecretPhraseHint":
            MessageLookupByLibrary.simpleMessage("请输入您的24个秘密词语。每个词语应该由空格分隔。"),
        "importSeed": MessageLookupByLibrary.simpleMessage("导入种子"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage("请在下面输入您的种子。"),
        "importSeedInstead": MessageLookupByLibrary.simpleMessage("导入种子"),
        "importStandard": MessageLookupByLibrary.simpleMessage("进口标准"),
        "importWallet": MessageLookupByLibrary.simpleMessage("导入现有钱包"),
        "instantly": MessageLookupByLibrary.simpleMessage("立刻"),
        "insufficientBalance": MessageLookupByLibrary.simpleMessage("余额不足"),
        "introSkippedWarningContent": MessageLookupByLibrary.simpleMessage(
            "我们跳过了介绍过程以节省您的时间，但您应该立即备份新创建的种子。\n\n如果您失去种子，您将无法使用您的资金。\n\n此外，您的密码已设置为“000000”，您也应立即更改。"),
        "introSkippedWarningHeader":
            MessageLookupByLibrary.simpleMessage("备份你的种子！"),
        "invalidAddress": MessageLookupByLibrary.simpleMessage("无效的目标地址"),
        "invalidHeight": MessageLookupByLibrary.simpleMessage("无效高度"),
        "invalidPassword": MessageLookupByLibrary.simpleMessage("无效密码"),
        "invalidPin": MessageLookupByLibrary.simpleMessage("无效引脚"),
        "iosFundingMessage": MessageLookupByLibrary.simpleMessage(
            "由于 iOS App Store 指南和限制，我们无法将您链接到我们的捐赠页面。如果您想支持该项目，请考虑发送到 nautilus 节点的地址。"),
        "language": MessageLookupByLibrary.simpleMessage("语言"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("链接已复制"),
        "loaded": MessageLookupByLibrary.simpleMessage("已加载"),
        "loadedInto": MessageLookupByLibrary.simpleMessage("已加载到"),
        "lockAppSetting": MessageLookupByLibrary.simpleMessage("启动时要求验证"),
        "locked": MessageLookupByLibrary.simpleMessage("已锁定"),
        "loginButton": MessageLookupByLibrary.simpleMessage("登录"),
        "loginOrRegisterHeader": MessageLookupByLibrary.simpleMessage("登录或注册"),
        "logout": MessageLookupByLibrary.simpleMessage("登出"),
        "logoutAction": MessageLookupByLibrary.simpleMessage("删除种子并登出"),
        "logoutAreYouSure": MessageLookupByLibrary.simpleMessage("您确定？"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "注销将从此设备中删除您的种子和所有与Nautilus相关的数据。如果您的种子代码没有备份，您将永远无法再次访问您的帐户"),
        "logoutReassurance":
            MessageLookupByLibrary.simpleMessage("只要您有备份您的种子，就没有什么可担心的。"),
        "looksLikeHdSeed": MessageLookupByLibrary.simpleMessage(
            "这似乎是一个高清种子，除非你确定你知道你在做什么，否则你应该使用“导入高清”选项。"),
        "looksLikeStandardSeed":
            MessageLookupByLibrary.simpleMessage("这似乎是一个标准种子，您应该改用“导入标准”选项。"),
        "manage": MessageLookupByLibrary.simpleMessage("管理"),
        "mantaError": MessageLookupByLibrary.simpleMessage("无法验证请求"),
        "manualEntry": MessageLookupByLibrary.simpleMessage("手动输入"),
        "markAsPaid": MessageLookupByLibrary.simpleMessage("标记为已付款"),
        "markAsUnpaid": MessageLookupByLibrary.simpleMessage("标记为未付款"),
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "memoSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "备忘录已重新发送！如果仍未确认，则收件人的设备可能处于脱机状态。"),
        "messageCopied": MessageLookupByLibrary.simpleMessage("消息已复制"),
        "messageHeader": MessageLookupByLibrary.simpleMessage("留言"),
        "minimumSend": MessageLookupByLibrary.simpleMessage("最小发送金额为 %1 %2"),
        "minuteAgo": MessageLookupByLibrary.simpleMessage("一分钟前"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 不是有效的词语"),
        "mnemonicPhrase": MessageLookupByLibrary.simpleMessage("秘密短语"),
        "mnemonicSizeError":
            MessageLookupByLibrary.simpleMessage("秘密词语一定要包含 24 个词语"),
        "monthlyServerCosts": MessageLookupByLibrary.simpleMessage("每月服务器成本"),
        "moonpay": MessageLookupByLibrary.simpleMessage("MoonPay"),
        "moreSettings": MessageLookupByLibrary.simpleMessage("更多设置"),
        "nameEmpty": MessageLookupByLibrary.simpleMessage("请输入姓名"),
        "natricon": MessageLookupByLibrary.simpleMessage("Natricon"),
        "nearby": MessageLookupByLibrary.simpleMessage("附近"),
        "needVerificationAlert": MessageLookupByLibrary.simpleMessage(
            "此功能要求您具有更长的交易历史记录，以防止垃圾邮件。\n\n或者，您可以显示二维码供他人扫描。"),
        "needVerificationAlertHeader":
            MessageLookupByLibrary.simpleMessage("需要验证"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "这是您的新账户。当您收到 NANO 时, 交易会如下出现："),
        "newWallet": MessageLookupByLibrary.simpleMessage("创建新钱包"),
        "nextButton": MessageLookupByLibrary.simpleMessage("继续"),
        "no": MessageLookupByLibrary.simpleMessage("否认"),
        "noContactsExport": MessageLookupByLibrary.simpleMessage("没有要导出的联系人"),
        "noContactsImport": MessageLookupByLibrary.simpleMessage("找不到要导入的联系人"),
        "noSearchResults": MessageLookupByLibrary.simpleMessage("没有搜索结果！"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("不，跳过"),
        "noTXDataExport": MessageLookupByLibrary.simpleMessage("没有要导出的交易。"),
        "noThanks": MessageLookupByLibrary.simpleMessage("No Thanks"),
        "node": MessageLookupByLibrary.simpleMessage("节点"),
        "nodeStatus": MessageLookupByLibrary.simpleMessage("节点状态"),
        "nodes": MessageLookupByLibrary.simpleMessage("节点"),
        "noneMethod": MessageLookupByLibrary.simpleMessage("没有任何"),
        "notSent": MessageLookupByLibrary.simpleMessage("未发送"),
        "notificationBody":
            MessageLookupByLibrary.simpleMessage("打开Nautilus查看此交易"),
        "notificationHeaderSupplement":
            MessageLookupByLibrary.simpleMessage("点击打开"),
        "notificationInfo":
            MessageLookupByLibrary.simpleMessage("为了使此功能正常工作，必须启用通知"),
        "notificationTitle": MessageLookupByLibrary.simpleMessage("收到 %1 NANO"),
        "notificationWarning": MessageLookupByLibrary.simpleMessage("通知已禁用"),
        "notificationWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "付款请求、备忘录和消息都需要启用通知才能正常工作，因为它们使用 FCM 通知服务来确保消息传递。\n\n如果您不想使用这些功能，可以使用下面的按钮启用通知或关闭此卡。"),
        "notificationWarningBodyShort":
            MessageLookupByLibrary.simpleMessage("付款请求、备忘录和消息将无法正常运行。"),
        "notifications": MessageLookupByLibrary.simpleMessage("通知"),
        "nyanicon": MessageLookupByLibrary.simpleMessage("Nyanicon"),
        "obscureInfoHeader": MessageLookupByLibrary.simpleMessage("模糊的交易信息"),
        "obscureTransaction": MessageLookupByLibrary.simpleMessage("模糊交易"),
        "obscureTransactionBody": MessageLookupByLibrary.simpleMessage(
            "这不是真正的隐私，但它会让收款人更难看到是谁给他们汇款的。"),
        "off": MessageLookupByLibrary.simpleMessage("关闭"),
        "ok": MessageLookupByLibrary.simpleMessage("好的"),
        "onStr": MessageLookupByLibrary.simpleMessage("开启"),
        "onboard": MessageLookupByLibrary.simpleMessage("邀请某人"),
        "onboarding": MessageLookupByLibrary.simpleMessage("入职"),
        "onramp": MessageLookupByLibrary.simpleMessage("入口匝道"),
        "onramper": MessageLookupByLibrary.simpleMessage("Onramper"),
        "opened": MessageLookupByLibrary.simpleMessage("已开业"),
        "paid": MessageLookupByLibrary.simpleMessage("已支付"),
        "paperWallet": MessageLookupByLibrary.simpleMessage("纸钱包"),
        "passwordBlank": MessageLookupByLibrary.simpleMessage("密码不能为空"),
        "passwordCapitalLetter":
            MessageLookupByLibrary.simpleMessage("密码必须至少包含 1 个大写和小写字母"),
        "passwordDisclaimer": MessageLookupByLibrary.simpleMessage(
            "如果您忘记了密码，我们概不负责，并且我们无法为您重置或更改密码。"),
        "passwordIncorrect": MessageLookupByLibrary.simpleMessage("密码错误"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage("您以后打开Nautilus不再需要密码了。"),
        "passwordNumber":
            MessageLookupByLibrary.simpleMessage("密码必须至少包含 1 个数字"),
        "passwordSpecialCharacter":
            MessageLookupByLibrary.simpleMessage("密码必须至少包含 1 个特殊字符"),
        "passwordTooShort": MessageLookupByLibrary.simpleMessage("密码太短"),
        "passwordWarning":
            MessageLookupByLibrary.simpleMessage("打开 Nautilus 需要此密码。"),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage("以后需要这个密码才能打开Nautilus。"),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage("密码不匹配"),
        "pay": MessageLookupByLibrary.simpleMessage("付钱"),
        "payRequest": MessageLookupByLibrary.simpleMessage("支付此申请"),
        "paymentRequestMessage":
            MessageLookupByLibrary.simpleMessage("有人要求你付款！查看付款页面了解更多信息。"),
        "payments": MessageLookupByLibrary.simpleMessage("付款"),
        "pickFromList": MessageLookupByLibrary.simpleMessage("从代表名单选择"),
        "pinBlank": MessageLookupByLibrary.simpleMessage("引脚不能为空"),
        "pinConfirmError": MessageLookupByLibrary.simpleMessage("识别码不匹配"),
        "pinConfirmTitle": MessageLookupByLibrary.simpleMessage("确认您的识别码"),
        "pinCreateTitle": MessageLookupByLibrary.simpleMessage("创建一个6位数的识别码"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("输入识别码"),
        "pinIncorrect": MessageLookupByLibrary.simpleMessage("输入的密码不正确"),
        "pinInvalid": MessageLookupByLibrary.simpleMessage("输入的识别码无效"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("识别码"),
        "pinRepChange": MessageLookupByLibrary.simpleMessage("输入识别码以更改代表。"),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage("输入识别码以查看钱包种子。"),
        "pinsDontMatch": MessageLookupByLibrary.simpleMessage("引脚不匹配"),
        "plausibleDeniabilityParagraph":
            MessageLookupByLibrary.simpleMessage("这与您用于创建钱包的密码不同。按信息按钮了解更多信息。"),
        "plausibleInfoHeader":
            MessageLookupByLibrary.simpleMessage("似是而非的否认信息"),
        "plausibleSheetInfo": MessageLookupByLibrary.simpleMessage(
            "为似是而非的否认模式设置辅助引脚。\n\n如果您的钱包使用此辅助密码解锁，您的种子将替换为现有种子的哈希值。这是一项安全功能，旨在在您被迫打开钱包的情况下使用。\n\n除了解锁你的钱包时，这个密码就像一个正常的（正确的）密码，这是在合理的否认模式将激活的时候。\n\n如果您没有备份您的种子，您的资金将在进入合理否认模式时丢失！"),
        "preferences": MessageLookupByLibrary.simpleMessage("偏好"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("隐私政策"),
        "proSubRequiredHeader":
            MessageLookupByLibrary.simpleMessage("需要订阅 Nautilus Pro"),
        "proSubRequiredParagraph": MessageLookupByLibrary.simpleMessage(
            "每月只需 1 NANO，您就可以解锁 Nautilus Pro 的所有功能。"),
        "promotionalLink": MessageLookupByLibrary.simpleMessage("免费纳米"),
        "purchaseNano": MessageLookupByLibrary.simpleMessage("购买 Nano"),
        "qrInvalidAddress":
            MessageLookupByLibrary.simpleMessage("二维码不包含一个有效的地址"),
        "qrInvalidPermissions":
            MessageLookupByLibrary.simpleMessage("请提供相机许可来扫描二维码"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage("二维码没有包含任何有效的种子"),
        "qrMnemonicError":
            MessageLookupByLibrary.simpleMessage("二维码不包含有效的秘密词语"),
        "qrUnknownError": MessageLookupByLibrary.simpleMessage("无法读取二维码"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate"),
        "rateTheApp": MessageLookupByLibrary.simpleMessage("为应用程序评分"),
        "rateTheAppDescription": MessageLookupByLibrary.simpleMessage(
            "如果你喜欢这个应用程序，可以考虑花点时间查看它，\n它确实有帮助，而且花费的时间不应超过一分钟。"),
        "rawSeed": MessageLookupByLibrary.simpleMessage("种子"),
        "readMore": MessageLookupByLibrary.simpleMessage("阅读更多"),
        "receivable": MessageLookupByLibrary.simpleMessage("应收账款"),
        "receive": MessageLookupByLibrary.simpleMessage("接收"),
        "receiveMinimum": MessageLookupByLibrary.simpleMessage("最低收益"),
        "receiveMinimumHeader":
            MessageLookupByLibrary.simpleMessage("接收最低限度信息"),
        "receiveMinimumInfo": MessageLookupByLibrary.simpleMessage(
            "收取的最低金额。如果收到的金额低于此金额的付款或请求，则会被忽略。"),
        "received": MessageLookupByLibrary.simpleMessage("收到"),
        "refund": MessageLookupByLibrary.simpleMessage("退款"),
        "registerButton": MessageLookupByLibrary.simpleMessage("登记"),
        "registerFor": MessageLookupByLibrary.simpleMessage("为了"),
        "registerUsername": MessageLookupByLibrary.simpleMessage("注册用户名"),
        "registerUsernameHeader":
            MessageLookupByLibrary.simpleMessage("注册一个用户名"),
        "registering": MessageLookupByLibrary.simpleMessage("正在注册"),
        "remove": MessageLookupByLibrary.simpleMessage("消除"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "您确定要隐藏此账户？ 您之后可以点 \"%1\" 键来重新添加此账户。"),
        "removeBlocked": MessageLookupByLibrary.simpleMessage("解除封锁"),
        "removeBlockedConfirmation":
            MessageLookupByLibrary.simpleMessage("您确定要解除封锁 %1 吗？"),
        "removeContact": MessageLookupByLibrary.simpleMessage("删除联系人"),
        "removeContactConfirmation":
            MessageLookupByLibrary.simpleMessage("您确认要刪除%1吗？"),
        "removeFavorite": MessageLookupByLibrary.simpleMessage("移除收藏夹"),
        "removeFavoriteConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "repInfo": MessageLookupByLibrary.simpleMessage(
            "代表是投票支持网络共识的帐户。代表的投票权重由账户余额加权，您可以用余额投票来增加您信任的代表的投票权重。您的代表对您的资金没有控制权。您应该选择一个下线时间很少并且值得信赖的代表。"),
        "repInfoHeader": MessageLookupByLibrary.simpleMessage("什么是代表？"),
        "reply": MessageLookupByLibrary.simpleMessage("回复"),
        "representatives": MessageLookupByLibrary.simpleMessage("代表"),
        "request": MessageLookupByLibrary.simpleMessage("申请"),
        "requestAmountConfirm":
            MessageLookupByLibrary.simpleMessage("请求 %1 %2"),
        "requestError": MessageLookupByLibrary.simpleMessage(
            "请求失败：此用户似乎没有安装 Nautilus，或者禁用了通知。"),
        "requestFrom": MessageLookupByLibrary.simpleMessage("请求来自"),
        "requestPayment": MessageLookupByLibrary.simpleMessage("申请付款"),
        "requestSendError": MessageLookupByLibrary.simpleMessage(
            "发送付款请求时出错，收款人的设备可能处于离线状态或不可用。"),
        "requestSentButNotReceived": MessageLookupByLibrary.simpleMessage(
            "请求重新发送！如果仍未确认，则收件人的设备可能处于脱机状态。"),
        "requestSheetInfo": MessageLookupByLibrary.simpleMessage(
            "使用端到端加密消息请求付款！\n\n付款请求、备忘录和消息只能由其他 nautilus 用户接收，但即使收件人不使用 nautilus，您也可以将它们用于自己的记录保存。"),
        "requestSheetInfoHeader": MessageLookupByLibrary.simpleMessage("请求表信息"),
        "requested": MessageLookupByLibrary.simpleMessage("已请求"),
        "requestedFrom": MessageLookupByLibrary.simpleMessage("请求自"),
        "requesting": MessageLookupByLibrary.simpleMessage("正在申请"),
        "requireAPasswordToOpenHeader":
            MessageLookupByLibrary.simpleMessage("需要密码来打开Nautilus吗？"),
        "requireCaptcha":
            MessageLookupByLibrary.simpleMessage("要求 CAPTCHA 领取礼品卡"),
        "resendMemo": MessageLookupByLibrary.simpleMessage("重新发送此备忘录"),
        "resetAccountButton": MessageLookupByLibrary.simpleMessage("重置帐户"),
        "resetAccountParagraph": MessageLookupByLibrary.simpleMessage(
            "这将使用您刚刚设置的密码创建一个新帐户，除非选择的密码相同，否则旧帐户不会被删除。"),
        "resetDatabase": MessageLookupByLibrary.simpleMessage("重置数据库"),
        "resetDatabaseConfirmation": MessageLookupByLibrary.simpleMessage(
            "确实要重置内部数据库吗？ \n\n这可能会解决与更新应用程序有关的问题，但也会删除所有已保存的首选项。这不会删除你的钱包种子。如果你遇到问题，你应该备份你的种子，重新安装应用程序，如果问题仍然存在，请随时在github或Discord上提交错误报告。"),
        "retry": MessageLookupByLibrary.simpleMessage("重试"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "您的设备似乎被“越狱”或被修改，从而存在安全隐患。建议您在继续之前把设备还原到初始状态。"),
        "scanInstructions": MessageLookupByLibrary.simpleMessage("扫描NANO二维码地址"),
        "scanNFC": MessageLookupByLibrary.simpleMessage("通过 NFC 发送"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("扫描二维码"),
        "searchHint": MessageLookupByLibrary.simpleMessage("搜索任何东西"),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "您将会看到您的秘密词语，它是存取您的币的密匙。您要确保把它备份好，并且不要和任何人分享。"),
        "secretInfoHeader": MessageLookupByLibrary.simpleMessage("安全第一！"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("秘密词语"),
        "secretPhraseCopied": MessageLookupByLibrary.simpleMessage("已复制秘密词语"),
        "secretPhraseCopy": MessageLookupByLibrary.simpleMessage("复制秘密词语"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "如果您丢了您的手机或卸载这程序，您就需要您的种子或秘密词语才可以重获您的币！"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("安全性"),
        "seed": MessageLookupByLibrary.simpleMessage("种子"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "以下是您钱包的种子。请您务必备份此种子，但为了安全请永远不要用纯文本或屏幕截图来储存它。"),
        "seedCopied": MessageLookupByLibrary.simpleMessage("种子复制到剪贴板。 2分钟后失效"),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("种子已复制"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "种子和秘密词语对机器来说是同一个东西，只要有种子或秘密词语的备份，就可以存取您的币。"),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("无效的种子"),
        "selfSendError": MessageLookupByLibrary.simpleMessage("无法向自己申请"),
        "send": MessageLookupByLibrary.simpleMessage("发送"),
        "sendAmountConfirm": MessageLookupByLibrary.simpleMessage("发送 %1 NANO"),
        "sendAmounts": MessageLookupByLibrary.simpleMessage("发送金额"),
        "sendError": MessageLookupByLibrary.simpleMessage("发生错误。请稍后再试。"),
        "sendFrom": MessageLookupByLibrary.simpleMessage("发送自"),
        "sendMemoError": MessageLookupByLibrary.simpleMessage(
            "发送包含交易的备忘录失败，他们可能不是Nautilus用户。"),
        "sendMessageConfirm": MessageLookupByLibrary.simpleMessage("正在发送消息"),
        "sendRequestAgain": MessageLookupByLibrary.simpleMessage("再次发送请求"),
        "sendRequests": MessageLookupByLibrary.simpleMessage("发送请求"),
        "sendSheetInfo": MessageLookupByLibrary.simpleMessage(
            "使用端到端加密消息发送或请求付款！\n\n付款请求、备忘录和消息只能由其他 nautilus 用户接收。\n\n您无需拥有用户名即可发送或接收付款请求，即使他们不使用nautilus，您也可以将其用于自己的记录保存。"),
        "sendSheetInfoHeader": MessageLookupByLibrary.simpleMessage("发送工作表信息"),
        "sending": MessageLookupByLibrary.simpleMessage("发出"),
        "sent": MessageLookupByLibrary.simpleMessage("发送"),
        "sentTo": MessageLookupByLibrary.simpleMessage("发给"),
        "set": MessageLookupByLibrary.simpleMessage("放"),
        "setPassword": MessageLookupByLibrary.simpleMessage("设置密码"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage("密码设置成功"),
        "setPin": MessageLookupByLibrary.simpleMessage("设置引脚"),
        "setPinParagraph": MessageLookupByLibrary.simpleMessage(
            "设置或更改您现有的 PIN。如果您尚未设置 PIN，则默认 PIN 为 000000。"),
        "setPinSuccess": MessageLookupByLibrary.simpleMessage("已成功设置引脚"),
        "setPlausibleDeniabilityPin":
            MessageLookupByLibrary.simpleMessage("设置合理的引脚"),
        "setRestoreHeight": MessageLookupByLibrary.simpleMessage("设置恢复高度"),
        "setWalletPassword": MessageLookupByLibrary.simpleMessage("设置钱包密码"),
        "setWalletPin": MessageLookupByLibrary.simpleMessage("Set Wallet Pin"),
        "setWalletPlausiblePin":
            MessageLookupByLibrary.simpleMessage("Set Wallet Plausible Pin"),
        "setXMRRestoreHeight":
            MessageLookupByLibrary.simpleMessage("设置 XMR 恢复高度"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("设置"),
        "settingsTransfer": MessageLookupByLibrary.simpleMessage("用纸钱包充值"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "shareLink": MessageLookupByLibrary.simpleMessage("分享链接"),
        "shareMessage": MessageLookupByLibrary.simpleMessage("分享讯息"),
        "shareText": MessageLookupByLibrary.simpleMessage("分享文字"),
        "shopButton": MessageLookupByLibrary.simpleMessage("店铺"),
        "show": MessageLookupByLibrary.simpleMessage("节目"),
        "showAccountInfo": MessageLookupByLibrary.simpleMessage("帐户信息"),
        "showAccountQR": MessageLookupByLibrary.simpleMessage("显示账户二维码"),
        "showContacts": MessageLookupByLibrary.simpleMessage("显示联系人"),
        "showFunding": MessageLookupByLibrary.simpleMessage("显示资金横幅"),
        "showLinkOptions": MessageLookupByLibrary.simpleMessage("显示链接选项"),
        "showLinkQR": MessageLookupByLibrary.simpleMessage("显示链接二维码"),
        "showMoneroHeader": MessageLookupByLibrary.simpleMessage("显示门罗币"),
        "showMoneroInfo": MessageLookupByLibrary.simpleMessage("启用门罗币部分"),
        "showQR": MessageLookupByLibrary.simpleMessage("显示二维码"),
        "showUnopenedWarning": MessageLookupByLibrary.simpleMessage("未开封警告"),
        "simplex": MessageLookupByLibrary.simpleMessage("Simplex"),
        "social": MessageLookupByLibrary.simpleMessage("社会的"),
        "someone": MessageLookupByLibrary.simpleMessage("某人"),
        "spendNano": MessageLookupByLibrary.simpleMessage("花费 NANO"),
        "splitBill": MessageLookupByLibrary.simpleMessage("拆分账单"),
        "splitBillHeader": MessageLookupByLibrary.simpleMessage("拆分账单"),
        "splitBillInfo": MessageLookupByLibrary.simpleMessage(
            "一次发送一堆付款请求！例如，它可以很容易地在餐厅拆分账单。"),
        "splitBillInfoHeader": MessageLookupByLibrary.simpleMessage("拆分账单信息"),
        "splitBy": MessageLookupByLibrary.simpleMessage("拆分依据"),
        "subsButton": MessageLookupByLibrary.simpleMessage(""),
        "subscribeButton": MessageLookupByLibrary.simpleMessage("订阅"),
        "subscribeWithApple":
            MessageLookupByLibrary.simpleMessage("通过 Apple Pay 订阅"),
        "supportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "supportDevelopment": MessageLookupByLibrary.simpleMessage("帮助支持发展"),
        "supportTheDeveloper": MessageLookupByLibrary.simpleMessage("支持开发者"),
        "swapXMR": MessageLookupByLibrary.simpleMessage("交换 XMR"),
        "swapXMRHeader": MessageLookupByLibrary.simpleMessage("交换门罗币"),
        "swapXMRInfo": MessageLookupByLibrary.simpleMessage(
            "门罗币是一种以隐私为中心的加密货币，它使得追踪交易变得非常困难甚至不可能。同时，NANO 是一种以支付为中心的加密货币，速度快，费用低。它们一起提供了加密货币的一些最有用的方面！\n\n使用此页面轻松将您的 NANO 换成 XMR！"),
        "swapping": MessageLookupByLibrary.simpleMessage("交换"),
        "switchToSeed": MessageLookupByLibrary.simpleMessage("转换成种子"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("系统默认"),
        "tapMessageToEdit": MessageLookupByLibrary.simpleMessage("点按消息进行编辑"),
        "tapToHide": MessageLookupByLibrary.simpleMessage("点击隐藏"),
        "tapToReveal": MessageLookupByLibrary.simpleMessage("点击揭示"),
        "themeHeader": MessageLookupByLibrary.simpleMessage("主题"),
        "thisMayTakeSomeTime":
            MessageLookupByLibrary.simpleMessage("可能还要等一下..."),
        "to": MessageLookupByLibrary.simpleMessage("至"),
        "tooManyFailedAttempts":
            MessageLookupByLibrary.simpleMessage("解锁失败太多次。"),
        "trackingHeader": MessageLookupByLibrary.simpleMessage("追踪授权"),
        "trackingWarning": MessageLookupByLibrary.simpleMessage("跟踪已禁用"),
        "trackingWarningBodyLong": MessageLookupByLibrary.simpleMessage(
            "如果禁用跟踪，礼品卡功能可能会减少或根本无法使用。我们将此权限专门用于此功能。绝对不会出于任何不必要的目的在后端出售、收集或跟踪您的任何数据"),
        "trackingWarningBodyShort":
            MessageLookupByLibrary.simpleMessage("礼品卡链接无法正常工作"),
        "transactions": MessageLookupByLibrary.simpleMessage("交易"),
        "transfer": MessageLookupByLibrary.simpleMessage("传送"),
        "transferClose": MessageLookupByLibrary.simpleMessage("点击任意位置关闭窗口。"),
        "transferComplete": MessageLookupByLibrary.simpleMessage(
            "%1 NANO 成功传送到您的 Nautilus 钱包。\n"),
        "transferConfirmInfo":
            MessageLookupByLibrary.simpleMessage("检测到一个包含 %1 NANO 的钱包。\n"),
        "transferConfirmInfoSecond":
            MessageLookupByLibrary.simpleMessage("按键确定传送钱币。\n"),
        "transferConfirmInfoThird":
            MessageLookupByLibrary.simpleMessage("传送需要几秒钟完成，请稍等一下。"),
        "transferError":
            MessageLookupByLibrary.simpleMessage("传送出现了问题，请稍后再尝试。"),
        "transferHeader": MessageLookupByLibrary.simpleMessage("传送钱币"),
        "transferIntro": MessageLookupByLibrary.simpleMessage(
            "这个过程会将纸钱包的钱币转移到您的 Nautilus 钱包。\n\n请按 \"%1\" 键开始。"),
        "transferIntroShort": MessageLookupByLibrary.simpleMessage(
            "此过程会将资金从纸质钱包转移到您的Nautilus钱包。"),
        "transferLoading": MessageLookupByLibrary.simpleMessage("传送中"),
        "transferManualHint": MessageLookupByLibrary.simpleMessage("请输入种子。"),
        "transferNoFunds":
            MessageLookupByLibrary.simpleMessage("这个种子没有包含任何 NANO"),
        "transferQrScanError":
            MessageLookupByLibrary.simpleMessage("这个二维码没有包含任何有效的种子。"),
        "transferQrScanHint":
            MessageLookupByLibrary.simpleMessage("请扫描 NANO \n种子"),
        "unacknowledged": MessageLookupByLibrary.simpleMessage("未被承认"),
        "unconfirmed": MessageLookupByLibrary.simpleMessage("未经证实"),
        "unfulfilled": MessageLookupByLibrary.simpleMessage("未了"),
        "unlock": MessageLookupByLibrary.simpleMessage("解锁"),
        "unlockBiometrics":
            MessageLookupByLibrary.simpleMessage("验证并解锁 Nautilus"),
        "unlockPin": MessageLookupByLibrary.simpleMessage("请输入识别码来解锁 Nautilus"),
        "unopenedWarningHeader":
            MessageLookupByLibrary.simpleMessage("显示未打开的警告"),
        "unopenedWarningInfo": MessageLookupByLibrary.simpleMessage(
            "在向未开立的账户发送资金时显示警告，这很有用，因为您发送到的大多数时间地址都会有余额，而发送到新地址可能是拼写错误的结果。"),
        "unopenedWarningWarning": MessageLookupByLibrary.simpleMessage(
            "你确定这是正确的地址吗？\n此帐户似乎未开通\n\n您可以在“未打开警告”下的设置抽屉中禁用此警告"),
        "unopenedWarningWarningHeader":
            MessageLookupByLibrary.simpleMessage("未开户"),
        "unpaid": MessageLookupByLibrary.simpleMessage("未付款"),
        "unread": MessageLookupByLibrary.simpleMessage("未读"),
        "uptime": MessageLookupByLibrary.simpleMessage("上线时间"),
        "urlEmpty": MessageLookupByLibrary.simpleMessage("请输入网址"),
        "useNano": MessageLookupByLibrary.simpleMessage("使用纳米"),
        "userAlreadyAddedError": MessageLookupByLibrary.simpleMessage("用户已添加！"),
        "userNotFound": MessageLookupByLibrary.simpleMessage("找不到用户！"),
        "usernameAlreadyRegistered": MessageLookupByLibrary.simpleMessage(
            "您已经注册了用户名！目前无法更改您的用户名，但您可以自由地在其他地址下注册一个新用户名。"),
        "usernameAvailable": MessageLookupByLibrary.simpleMessage("用户名可用！"),
        "usernameEmpty": MessageLookupByLibrary.simpleMessage("请输入用户名"),
        "usernameError": MessageLookupByLibrary.simpleMessage("用户名错误"),
        "usernameInfo": MessageLookupByLibrary.simpleMessage(
            "挑选一个独特的 @username 让亲朋好友轻松找到你！\n\n拥有 Nautilus 用户名可在全局范围内更新用户界面，以反映您的新用户名。"),
        "usernameInvalid": MessageLookupByLibrary.simpleMessage("用户名无效"),
        "usernameUnavailable": MessageLookupByLibrary.simpleMessage("用户名不可用"),
        "usernameWarning":
            MessageLookupByLibrary.simpleMessage("鹦鹉螺用户名是由 nano.to 提供的集中式服务"),
        "using": MessageLookupByLibrary.simpleMessage("使用"),
        "viewDetails": MessageLookupByLibrary.simpleMessage("查看详情"),
        "viewTX": MessageLookupByLibrary.simpleMessage("查看交易"),
        "votingWeight": MessageLookupByLibrary.simpleMessage("投票比重"),
        "warning": MessageLookupByLibrary.simpleMessage("警告"),
        "watchAccountExists": MessageLookupByLibrary.simpleMessage("帐号已添加！"),
        "watchOnlyAccount": MessageLookupByLibrary.simpleMessage("仅观看帐户"),
        "watchOnlySendDisabled":
            MessageLookupByLibrary.simpleMessage("仅监视地址上禁用发送"),
        "weekAgo": MessageLookupByLibrary.simpleMessage("一星期前"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "欢迎来到Nautilus。下一步，您可以创建新钱包或导入已有钱包。"),
        "welcomeTextLogin": MessageLookupByLibrary.simpleMessage(
            "欢迎来到鹦鹉螺。选择一个选项以开始使用或使用下面的图标选择一个主题。"),
        "welcomeTextUpdated":
            MessageLookupByLibrary.simpleMessage("欢迎来到鹦鹉螺。首先，创建一个新钱包或导入现有钱包。"),
        "welcomeTextWithoutLogin":
            MessageLookupByLibrary.simpleMessage("首先，创建一个新钱包或导入现有钱包。"),
        "withAddress": MessageLookupByLibrary.simpleMessage("有地址"),
        "withFee": MessageLookupByLibrary.simpleMessage("有费用"),
        "withMessage": MessageLookupByLibrary.simpleMessage("带消息"),
        "xMinute": MessageLookupByLibrary.simpleMessage("%1 分钟后"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("%1 分钟后"),
        "xmrStatusConnecting": MessageLookupByLibrary.simpleMessage("连接"),
        "xmrStatusError": MessageLookupByLibrary.simpleMessage("错误"),
        "xmrStatusLoading": MessageLookupByLibrary.simpleMessage("正在加载"),
        "xmrStatusSynchronized": MessageLookupByLibrary.simpleMessage("同步"),
        "xmrStatusSynchronizing": MessageLookupByLibrary.simpleMessage("同步"),
        "yes": MessageLookupByLibrary.simpleMessage("确认"),
        "yesButton": MessageLookupByLibrary.simpleMessage("确认")
      };
}
