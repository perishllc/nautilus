import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nautilus_wallet_flutter/model/available_block_explorer.dart';
import 'package:nautilus_wallet_flutter/model/available_language.dart';

import 'l10n/messages_all.dart';

/// Localization
class AppLocalization {
  static Locale currentLocale = Locale('en', 'US');

  static Future<AppLocalization> load(Locale locale) {
    currentLocale = locale;
    final String name = locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalization();
    });
  }

  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  /// -- GENERIC ITEMS
  String get cancel {
    return Intl.message('Cancel', desc: 'dialog_cancel', name: 'cancel');
  }

  String get close {
    return Intl.message('Close', desc: 'dialog_close', name: 'close');
  }

  String get confirm {
    return Intl.message('Confirm', desc: 'dialog_confirm', name: 'confirm');
  }

  String get no {
    return Intl.message('No', desc: 'intro_new_wallet_backup_no', name: 'no');
  }

  String get yes {
    return Intl.message('Yes', desc: 'intro_new_wallet_backup_yes', name: 'yes');
  }

  String get ok {
    return Intl.message('Ok', desc: 'ok', name: 'ok');
  }

  String get onStr {
    return Intl.message('On', desc: 'generic_on', name: 'onStr');
  }

  String get off {
    return Intl.message('Off', desc: 'generic_off', name: 'off');
  }

  String get send {
    return Intl.message('Send', desc: 'home_send_cta', name: 'send');
  }

  String get pay {
    return Intl.message('Pay', desc: 'home_pay_slidable', name: 'pay');
  }

  String get reply {
    return Intl.message('Reply', desc: 'home_reply_slidable', name: 'reply');
  }

  String get receive {
    return Intl.message('Receive', desc: 'home_receive_cta', name: 'receive');
  }

  String get request {
    return Intl.message('Request', desc: 'home_request_cta', name: 'request');
  }

  String get sent {
    return Intl.message('Sent', desc: 'history_sent', name: 'sent');
  }

  String get loaded {
    return Intl.message('Loaded', desc: 'history_loaded', name: 'loaded');
  }

  String get opened {
    return Intl.message('Opened', desc: 'history_opened', name: 'opened');
  }

  String get received {
    return Intl.message('Received', desc: 'history_received', name: 'received');
  }

  String get receivable {
    return Intl.message('receivable', desc: 'history_receivable', name: 'receivable');
  }

  String get requested {
    return Intl.message('Requested', desc: 'home_requested_cta', name: 'requested');
  }

  String get asked {
    return Intl.message('Asked', desc: 'home_asked_cta', name: 'asked');
  }

  String get unconfirmed {
    return Intl.message('unconfirmed', desc: 'history_unconfirmed', name: 'unconfirmed');
  }

  String get unacknowledged {
    return Intl.message('unacknowledged', desc: 'history_unacknowledged', name: 'unacknowledged');
  }

  String get unread {
    return Intl.message('unread', desc: 'history_unread', name: 'unread');
  }

  String get fulfilled {
    return Intl.message('fulfilled', desc: 'history_fulfilled', name: 'fulfilled');
  }

  String get unfulfilled {
    return Intl.message('unfulfilled', desc: 'history_unfulfilled', name: 'unfulfilled');
  }

  String get paid {
    return Intl.message('paid', desc: 'history_paid', name: 'paid');
  }

  String get unpaid {
    return Intl.message('unpaid', desc: 'history_unpaid', name: 'unpaid');
  }

  String get failedMessage {
    return Intl.message('msg failed', desc: 'failed_message', name: 'failedMessage');
  }

  String get notSent {
    return Intl.message('not sent', desc: 'not_sent_message', name: 'notSent');
  }

  String get failed {
    return Intl.message('failed', desc: 'history_failed', name: 'failed');
  }

  String get messageHeader {
    return Intl.message('Message', desc: 'message_header', name: 'messageHeader');
  }

  String get transactions {
    return Intl.message('Transactions', desc: 'transaction_header', name: 'transactions');
  }

  String get addressCopied {
    return Intl.message('Address Copied', desc: 'receive_copied', name: 'addressCopied');
  }

  String get copyAddress {
    return Intl.message('Copy Address', desc: 'receive_copy_cta', name: 'copyAddress');
  }

  String get readMore {
    return Intl.message('Read More', desc: 'read_more', name: 'readMore');
  }

  String get ignore {
    return Intl.message('Ignore', desc: 'ignore', name: 'ignore');
  }

  String get refund {
    return Intl.message('Refund', desc: 'refund', name: 'refund');
  }

  String get dismiss {
    return Intl.message('Dismiss', desc: 'dismiss', name: 'dismiss');
  }

  String get addressShare {
    return Intl.message('Share Address', desc: 'receive_share_cta', name: 'addressShare');
  }

  String get requestPayment {
    return Intl.message('Request Payment', desc: 'request_payment_cta', name: 'requestPayment');
  }

  String get createQR {
    return Intl.message('Create QR Code', desc: 'create_qr_code', name: 'createQR');
  }

  String get addressHint {
    return Intl.message('Enter Address', desc: 'send_address_hint', name: 'addressHint');
  }

  String get searchHint {
    return Intl.message('Search for anything', desc: 'home_search_hint', name: 'searchHint');
  }

  String get noSearchResults {
    return Intl.message('No Search Results!', desc: 'home_search_error', name: 'noSearchResults');
  }

  String get seed {
    return Intl.message('Seed', desc: 'intro_new_wallet_seed_header', name: 'seed');
  }

  String get seedInvalid {
    return Intl.message('Seed is Invalid', desc: 'intro_seed_invalid', name: 'seedInvalid');
  }

  String get seedCopied {
    return Intl.message('Seed Copied to Clipboard\nIt is pasteable for 2 minutes.', desc: 'intro_new_wallet_seed_copied', name: 'seedCopied');
  }

  String get scanQrCode {
    return Intl.message('Scan QR Code', desc: 'send_scan_qr', name: 'scanQrCode');
  }

  String get contactsImportErr {
    return Intl.message('Failed to import contacts', desc: 'contact_import_error', name: 'contactsImportErr');
  }

  String get viewDetails {
    return Intl.message("View Details", desc: "transaction_details", name: 'viewDetails');
  }

  String get qrInvalidSeed {
    return Intl.message("QR code does not contain a valid seed or private key", desc: "qr_invalid_seed", name: 'qrInvalidSeed');
  }

  String get qrInvalidAddress {
    return Intl.message("QR code does not contain a valid destination", desc: "qr_invalid_address", name: 'qrInvalidAddress');
  }

  String get qrInvalidPermissions {
    return Intl.message("Please Grant Camera Permissions to scan QR Codes",
        desc: "User did not grant camera permissions to the app", name: "qrInvalidPermissions");
  }

  String get qrUnknownError {
    return Intl.message("Could not Read QR Code", desc: "An unknown error occurred with the QR scanner", name: "qrUnknownError");
  }

  String get markAsPaid {
    return Intl.message("Mark as Paid", desc: "fulfill_payment", name: 'markAsPaid');
  }

  String get resendMemo {
    return Intl.message("Resend this memo", desc: "resend_memo", name: 'resendMemo');
  }

  String get decryptionError {
    return Intl.message("Decryption Error!", desc: 'decryption_errorc', name: 'decryptionError');
  }

  String get markAsUnpaid {
    return Intl.message("Mark as Unpaid", desc: "unfulfill_payment", name: 'markAsUnpaid');
  }

  String get payRequest {
    return Intl.message("Pay this request", desc: "pay_request", name: 'payRequest');
  }

  String get blockUser {
    return Intl.message("Block this User", desc: "block_user", name: 'blockUser');
  }

  String get deleteRequest {
    return Intl.message("Delete this request", desc: "delete_request", name: 'deleteRequest');
  }

  String get sendRequestAgain {
    return Intl.message("Send Request again", desc: "request_again", name: 'sendRequestAgain');
  }

  /// -- END GENERIC ITEMS

  /// -- CONTACT ITEMS

  String get removeContact {
    return Intl.message('Remove Contact', desc: 'contact_remove_btn', name: 'removeContact');
  }

  String get removeContactConfirmation {
    return Intl.message('Are you sure you want to delete %1?', desc: 'contact_remove_sure', name: 'removeContactConfirmation');
  }

  String get contactHeader {
    return Intl.message('Contact', desc: 'contact_view_header', name: 'contactHeader');
  }

  String get contactsHeader {
    return Intl.message('Contacts', desc: 'contact_header', name: 'contactsHeader');
  }

  String get addContact {
    return Intl.message('Add Contact', desc: 'contact_add_button', name: 'addContact');
  }

  String get contactNameHint {
    return Intl.message('Enter a Nickname', desc: 'contact_name_hint', name: 'contactNameHint');
  }

  String get contactInvalid {
    return Intl.message("Invalid Contact Name", desc: 'contact_invalid_name', name: 'contactInvalid');
  }

  String get noContactsExport {
    return Intl.message("There's no contacts to export.", desc: 'contact_export_none', name: 'noContactsExport');
  }

  String get noContactsImport {
    return Intl.message("No new contacts to import.", desc: 'contact_import_none', name: 'noContactsImport');
  }

  String get contactsImportSuccess {
    return Intl.message("Sucessfully imported %1 contacts.", desc: 'contact_import_success', name: 'contactsImportSuccess');
  }

  String get contactAdded {
    return Intl.message("%1 added to contacts.", desc: 'contact_added', name: 'contactAdded');
  }

  String get contactRemoved {
    return Intl.message("%1 has been removed from contacts!", desc: 'contact_removed', name: 'contactRemoved');
  }

  String get contactNameMissing {
    return Intl.message("Choose a Name for this Contact", desc: 'contact_name_missing', name: 'contactNameMissing');
  }

  String get contactExists {
    return Intl.message("Contact Already Exists", desc: 'contact_name_exists', name: 'contactExists');
  }

  /// -- END CONTACT ITEMS

  /// -- FAVORITE ITEMS

  String get removeFavorite {
    return Intl.message('Remove Favorite', desc: 'favorite_remove_btn', name: 'removeFavorite');
  }

  String get removeFavoriteConfirmation {
    return Intl.message('Are you sure you want to delete %1?', desc: 'favorite_remove_sure', name: 'removeFavoriteConfirmation');
  }

  String get favoriteHeader {
    return Intl.message('Favorite', desc: 'favorite_view_header', name: 'favoriteHeader');
  }

  String get favoritesHeader {
    return Intl.message('Favorites', desc: 'favorite_header', name: 'favoritesHeader');
  }

  String get favoriteRemoved {
    return Intl.message("%1 has been removed from favorites!", desc: 'favorite_removed', name: 'favoriteRemoved');
  }

  String get blockedHeader {
    return Intl.message('Blocked', desc: 'blocked_header', name: 'blockedHeader');
  }

  String get blockedInfo {
    return Intl.message("Block a user by any known alias or address. Any messages, transactions, or requests from them will be ignored.",
        desc: 'blocked_info', name: 'blockedInfo');
  }

  String get blockedInfoHeader {
    return Intl.message("Blocked Info", desc: 'blocked_info', name: 'blockedInfoHeader');
  }

  String get addFavorite {
    return Intl.message('Add Favorite', desc: 'favorite_add_button', name: 'addFavorite');
  }

  String get addBlocked {
    return Intl.message('Block a User', desc: 'blocked_add_button', name: 'addBlocked');
  }

  String get favoriteNameHint {
    return Intl.message('Enter a Nick Name', desc: 'favorite_name_hint', name: 'favoriteNameHint');
  }

  String get domainInvalid {
    return Intl.message("Invalid Domain Name", desc: 'domain_invalid_name', name: 'domainInvalid');
  }

  String get favoriteInvalid {
    return Intl.message("Invalid Favorite Name", desc: 'favorite_invalid_name', name: 'favoriteInvalid');
  }

  String get usernameInvalid {
    return Intl.message("Invalid Username", desc: 'username_invalid_name', name: 'usernameInvalid');
  }

  String get usernameError {
    return Intl.message("Username Error", desc: 'username_unknown_error', name: 'usernameError');
  }

  String get selfSendError {
    return Intl.message("Can't request from self", desc: 'self_send_error', name: 'selfSendError');
  }

  String get favoriteNameMissing {
    return Intl.message("Choose a Name for this Favorite", desc: 'favorite_name_missing', name: 'favoriteNameMissing');
  }

  String get blockedNameMissing {
    return Intl.message("Choose a Nick Name", desc: 'blocked_name_missing', name: 'blockedNameMissing');
  }

  String get favoriteExists {
    return Intl.message("Favorite Already Exists", desc: 'favorite_name_exists', name: 'favoriteExists');
  }

  String get blockedExists {
    return Intl.message("User already Blocked!", desc: 'user_already_blocked', name: 'blockedExists');
  }

  String get blockedNameExists {
    return Intl.message("Nick name already used!", desc: 'blocked_name_used', name: 'blockedNameExists');
  }

  String get userNotFound {
    return Intl.message("User not found!", desc: 'user_not_found', name: 'userNotFound');
  }

  /// -- END FAVORITE ITEMS

  /// -- BLOCKED ITEMS

  String get removeBlocked {
    return Intl.message('Unblock', desc: 'blocked_remove_btn', name: 'removeBlocked');
  }

  String get removeBlockedConfirmation {
    return Intl.message('Are you sure you want to unblock %1?', desc: 'blocked_remove_sure', name: 'removeBlockedConfirmation');
  }

  String get blockedAdded {
    return Intl.message("%1 successfully blocked.", desc: 'blocked_added', name: 'blockedAdded');
  }

  String get blockedRemoved {
    return Intl.message("%1 has been unblocked!", desc: 'blocked_removed', name: 'blockedRemoved');
  }

  /// -- END BLOCKED ITEMS

  /// -- INTRO ITEMS
  String get backupYourSeed {
    return Intl.message('Backup your seed', desc: 'intro_new_wallet_seed_backup_header', name: 'backupYourSeed');
  }

  String get backupSeedConfirm {
    return Intl.message('Are you sure that you backed up your wallet seed?', desc: 'intro_new_wallet_backup', name: 'backupSeedConfirm');
  }

  String get seedBackupInfo {
    return Intl.message("Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.",
        desc: 'intro_new_wallet_seed', name: 'seedBackupInfo');
  }

  String get copySeed {
    return Intl.message("Copy Seed", desc: 'copy_seed_btn', name: 'copySeed');
  }

  String get seedCopiedShort {
    return Intl.message("Seed Copied", desc: 'seed_copied_btn', name: 'seedCopiedShort');
  }

  String get importSeed {
    return Intl.message("Import Seed", desc: 'intro_seed_header', name: 'importSeed');
  }

  String get importSeedHint {
    return Intl.message("Please enter your seed below.", desc: 'intro_seed_info', name: 'importSeedHint');
  }

  String get welcomeText {
    return Intl.message("Welcome to Nautilus. To begin, you may create a new wallet or import an existing one.",
        desc: 'intro_welcome_title', name: 'welcomeText');
  }

  String get newWallet {
    return Intl.message("New Wallet", desc: 'intro_welcome_new_wallet', name: 'newWallet');
  }

  String get importWallet {
    return Intl.message("Import Wallet", desc: 'intro_welcome_have_wallet', name: 'importWallet');
  }

  /// -- END INTRO ITEMS

  /// -- SEND ITEMS
  String get sentTo {
    return Intl.message("Sent To", desc: 'sent_to', name: 'sentTo');
  }

  String get sending {
    return Intl.message("Sending", desc: 'send_sending', name: 'sending');
  }

  String get creatingGiftCard {
    return Intl.message("Creating Gift Card", desc: 'creating_gift_card', name: 'creatingGiftCard');
  }

  String get aliases {
    return Intl.message("Aliases", desc: 'card_details_aliases', name: 'aliases');
  }

  String get requestedFrom {
    return Intl.message("Requested From", desc: 'requested_from', name: 'requestedFrom');
  }

  String get requesting {
    return Intl.message("Requesting", desc: 'request_requesting', name: 'requesting');
  }

  String get registering {
    return Intl.message("Registering", desc: 'register_registering', name: 'registering');
  }

  String get registerFor {
    return Intl.message("for", desc: 'register_for', name: 'registerFor');
  }

  String get withAddress {
    return Intl.message("With Address", desc: 'with_address', name: 'withAddress');
  }

  String get withMessage {
    return Intl.message("With Message", desc: 'with_message', name: 'withMessage');
  }

  String get to {
    return Intl.message("To", desc: 'send_to', name: 'to');
  }

  String get from {
    return Intl.message("From", desc: 'request_from', name: 'from');
  }

  String get sendAmountConfirm {
    return Intl.message("Send %1 %2", desc: 'send_pin_description', name: 'sendAmountConfirm');
  }

  String get sendMessageConfirm {
    return Intl.message("Sending message", desc: 'send_message_description', name: 'sendMessageConfirm');
  }

  String get requestAmountConfirm {
    return Intl.message("Request %1 %2", desc: 'request_pin_description', name: 'requestAmountConfirm');
  }

  String get sendAmountConfirmPin {
    return sendAmountConfirm;
  }

  String get requestAmountConfirmPin {
    return requestAmountConfirm;
  }

  String get sendError {
    return Intl.message("An error occurred. Try again later.", desc: 'send_generic_error', name: 'sendError');
  }

  String get sendMemoError {
    return Intl.message("Sending memo with transaction failed, they may not be a Nautilus user.", desc: 'send_memo_error', name: 'sendMemoError');
  }

  String get memoSentButNotReceived {
    return Intl.message("Memo re-sent! If still unacknowledged, the recipient's device may be offline.",
        desc: 'memo_sent_again', name: 'memoSentButNotReceived');
  }

  String get requestSentButNotReceived {
    return Intl.message("Request re-sent! If still unacknowledged, the recipient's device may be offline.",
        desc: 'request_sent_again', name: 'requestSentButNotReceived');
  }

  String get requestSendError {
    return Intl.message("Error sending payment request, the recipient's device may be offline or unavailable.",
        desc: 'request_send_error', name: 'requestSendError');
  }

  String get requestError {
    return Intl.message("Request Failed: This user doesn't appear to have Nautilus installed, or has notifications disabled.",
        desc: 'request_generic_error', name: 'requestError');
  }

  String get paymentRequestMessage {
    return Intl.message("Someone has requested payment from you! check the payments page for more info.",
        desc: 'payment_request_message', name: 'paymentRequestMessage');
  }

  String get mantaError {
    return Intl.message("Couldn't Verify Request",
        desc: 'Was unable to verify the manta/appia payment request (from scanning QR code, etc.)', name: 'mantaError');
  }

  String get enterAmount {
    return Intl.message("Enter Amount", desc: 'send_amount_hint', name: 'enterAmount');
  }

  String get enterAddress {
    return Intl.message("Enter Address", desc: 'enter_address', name: 'enterAddress');
  }

  String get enterUserOrAddress {
    return Intl.message("Enter User or Address", desc: 'enter_user_address', name: 'enterUserOrAddress');
  }

  String get enterMemo {
    return Intl.message("Enter Message", desc: 'enter_memo', name: 'enterMemo');
  }

  String get enterGiftMemo {
    return Intl.message("Enter Gift Note", desc: 'gift_note', name: 'enterGiftMemo');
  }

  String get enterUsername {
    return Intl.message("Enter a username", desc: 'enter_username', name: 'enterUsername');
  }

  String get invalidAddress {
    return Intl.message("Address entered was invalid", desc: 'send_invalid_address', name: 'invalidAddress');
  }

  String get usernameUnavailable {
    return Intl.message("Username unavailable", desc: 'username_unavailable', name: 'usernameUnavailable');
  }

  String get usernameEmpty {
    return Intl.message("Please Enter a Username", desc: 'username_empty', name: 'usernameEmpty');
  }

  String get usernameAvailable {
    return Intl.message("Username available!", desc: 'username_available', name: 'usernameAvailable');
  }

  String get addressMissing {
    return Intl.message("Please Enter an Address", desc: 'send_enter_address', name: 'addressMissing');
  }

  String get addressOrUserMissing {
    return Intl.message("Please Enter a Username or Address", desc: 'send_enter_user_address', name: 'addressOrUserMissing');
  }

  String get amountMissing {
    return Intl.message("Please Enter an Amount", desc: 'send_enter_amount', name: 'amountMissing');
  }

  String get minimumSend {
    return Intl.message("Minimum send amount is %1 %2", desc: 'send_minimum_error', name: 'minimumSend');
  }

  String get insufficientBalance {
    return Intl.message("Insufficient Balance", desc: 'send_insufficient_balance', name: 'insufficientBalance');
  }

  String get sendFrom {
    return Intl.message("Send From", desc: 'send_title', name: 'sendFrom');
  }

  /// -- END SEND ITEMS

  /// -- PIN SCREEN
  String get pinCreateTitle {
    return Intl.message("Create a 6-digit pin", desc: 'pin_create_title', name: 'pinCreateTitle');
  }

  String get pinConfirmTitle {
    return Intl.message("Confirm your pin", desc: 'pin_confirm_title', name: 'pinConfirmTitle');
  }

  String get pinEnterTitle {
    return Intl.message("Enter pin", desc: 'pin_enter_title', name: 'pinEnterTitle');
  }

  String get pinConfirmError {
    return Intl.message("Pins do not match", desc: 'pin_confirm_error', name: 'pinConfirmError');
  }

  String get pinInvalid {
    return Intl.message("Invalid pin entered", desc: 'pin_error', name: 'pinInvalid');
  }

  /// -- END PIN SCREEN

  /// -- SETTINGS ITEMS

  String get activeMessageHeader {
    return Intl.message("Active Message", desc: 'active_message', name: 'activeMessageHeader');
  }

  String get themeHeader {
    return Intl.message("Theme", desc: 'theme_header', name: 'themeHeader');
  }

  String get receiveMinimum {
    return Intl.message("Receive Minimum", desc: 'receive_minimum', name: 'receiveMinimum');
  }

  String get receiveMinimumInfo {
    return Intl.message("A minimum amount to receive. If a payment or request is received with an amount less than this, it will be ignored.",
        desc: 'receive_minimum_info', name: 'receiveMinimumInfo');
  }

  String get receiveMinimumHeader {
    return Intl.message("Receive Minimum Info", desc: 'receive_minimum_header', name: 'receiveMinimumHeader');
  }

  String get sendSheetInfo {
    return Intl.message(
        "Send or Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other nautilus users.\n\nYou don't need to have a username in order to send or receive payment requests, and you can use them for your own record keeping even if they don't use nautilus.",
        desc: 'send_sheet_info',
        name: 'sendSheetInfo');
  }

  String get sendSheetInfoHeader {
    return Intl.message("Send Sheet Info", desc: 'send_sheet_info_header', name: 'sendSheetInfoHeader');
  }

  String get currencyMode {
    return Intl.message("Currency Mode", desc: 'currency_mode', name: 'currencyMode');
  }

  String get currencyModeInfo {
    return Intl.message("Choose which unit to display amounts in.\n1 nyano = 0.000001 NANO, or \n1,000,000 nyano = 1 NANO",
        desc: 'currency_mode_info', name: 'currencyModeInfo');
  }

  String get currencyModeHeader {
    return Intl.message("Currency Mode Info", desc: 'currency_mode_header', name: 'currencyModeHeader');
  }

  String get changeRepButton {
    return Intl.message("Change", desc: 'change_representative_change', name: 'changeRepButton');
  }

  String get purchaseNano {
    return Intl.message("Purchase Nano", desc: 'purchase_nano', name: 'purchaseNano');
  }

  String get home {
    return Intl.message("Home", desc: 'home', name: 'home');
  }

  String get payments {
    return Intl.message("Payments", desc: 'payments', name: 'payments');
  }

  String get registerUsername {
    return Intl.message("Register Username", desc: 'register_username', name: 'registerUsername');
  }

  String get checkAvailability {
    return Intl.message("Check Availability", desc: 'check_availability', name: 'checkAvailability');
  }

  String get createGiftCard {
    return Intl.message("Create Gift Card", desc: 'create_gift_card', name: 'createGiftCard');
  }

  String get changeRepAuthenticate {
    return Intl.message("Change Representative", desc: 'settings_change_rep', name: 'changeRepAuthenticate');
  }

  String get currentlyRepresented {
    return Intl.message("Currently Represented By", desc: 'change_representative_current_header', name: 'currentlyRepresented');
  }

  String get changeRepSucces {
    return Intl.message("Representative Changed Successfully", desc: 'change_representative_success', name: 'changeRepSucces');
  }

  String get changeRepSame {
    return Intl.message("This is already your representative!", desc: 'change_representative_same', name: 'changeRepSame');
  }

  String get repInfoHeader {
    return Intl.message("What is a representative?", desc: 'change_representative_info_header', name: 'repInfoHeader');
  }

  String get repInfo {
    return Intl.message(
        "A representative is an account that votes for network consensus. Voting power is weighted by balance, you may delegate your balance to increase the voting weight of a representative you trust. Your representative does not have spending power over your funds. You should choose a representative that has little downtime and is trustworthy.",
        desc: 'change_representative_info',
        name: 'repInfo');
  }

  String get pinRepChange {
    return Intl.message("Enter PIN to change representative.", desc: 'change_representative_pin', name: 'pinRepChange');
  }

  String get changeRepHint {
    return Intl.message("Enter New Representative", desc: 'change_representative_hint', name: 'changeRepHint');
  }

  String get representatives {
    return Intl.message("Representatives", desc: 'representatives', name: 'representatives');
  }

  String get pickFromList {
    return Intl.message("Pick From a List", desc: 'pick rep from list', name: 'pickFromList');
  }

  String get useNautilusRep {
    return Intl.message("Use Nautilus Rep", desc: 'use nautilus node as rep', name: 'useNautilusRep');
  }

  String get votingWeight {
    return Intl.message("Voting Weight", desc: 'Representative Voting Weight', name: 'votingWeight');
  }

  String get uptime {
    return Intl.message("Uptime", desc: 'Rep uptime', name: 'uptime');
  }

  String get authMethod {
    return Intl.message("Authentication Method", desc: 'settings_disable_fingerprint', name: 'authMethod');
  }

  String get pinMethod {
    return Intl.message("PIN", desc: 'settings_pin_method', name: 'pinMethod');
  }

  String get privacyPolicy {
    return Intl.message("Privacy Policy", desc: 'settings_privacy_policy', name: 'privacyPolicy');
  }

  String get eula {
    return Intl.message("EULA", desc: 'settings_eula', name: 'eula');
  }

  String get nodeStatus {
    return Intl.message("Node Status", desc: 'settings_node_status', name: 'nodeStatus');
  }

  String get biometricsMethod {
    return Intl.message("Biometrics", desc: 'settings_fingerprint_method', name: 'biometricsMethod');
  }

  String get currency {
    return Intl.message("Currency", desc: 'A settings menu item for changing currency', name: 'currency');
  }

  String get changeCurrency {
    return Intl.message("Change Currency", desc: 'settings_local_currency', name: 'changeCurrency');
  }

  String get language {
    return Intl.message("Language", desc: 'settings_change_language', name: 'language');
  }

  String get blockExplorer {
    return Intl.message("Block Explorer", desc: 'settings_change_block_explorer', name: 'blockExplorer');
  }

  String get blockExplorerInfo {
    return Intl.message("Which block explorer to use to display transaction information", desc: 'block_explorer_info', name: 'blockExplorerInfo');
  }

  String get blockExplorerHeader {
    return Intl.message("Block Explorer Info", desc: 'block_explorer', name: 'blockExplorerHeader');
  }

  String get shareNautilus {
    return Intl.message("Share Nautilus", desc: 'settings_share', name: 'shareNautilus');
  }

  String get resetDatabase {
    return Intl.message("Reset the Database", desc: 'settings_nuke_db', name: 'resetDatabase');
  }

  String get resetDatabaseConfirmation {
    return Intl.message(
        'Are you sure you want to reset the internal database? \n\nThis may fix issues related to updating the app, but will also delete all saved preferences. This will NOT delete your wallet seed. If you\'re having issues you should backup your seed, re-install the app, and if the issue persists feel free to make a bug report on github or discord.',
        desc: 'database_remove_sure',
        name: 'resetDatabaseConfirmation');
  }

  String get shareNautilusText {
    return Intl.message("Check out Nautilus! A premier NANO mobile wallet!", desc: 'share_extra', name: 'shareNautilusText');
  }

  String get logout {
    return Intl.message("Logout", desc: 'settings_logout', name: 'logout');
  }

  String get rootWarning {
    return Intl.message(
        'It appears your device is "rooted", "jailbroken", or modified in a way that compromises security. It is recommended that you reset your device to its original state before proceeding.',
        desc: "Shown to users if they have a rooted Android device or jailbroken iOS device",
        name: 'rootWarning');
  }

  String get iUnderstandTheRisks {
    return Intl.message("I Understand the Risks",
        desc: "Shown to users if they have a rooted Android device or jailbroken iOS device", name: 'iUnderstandTheRisks');
  }

  String get exit {
    return Intl.message("Exit", desc: "Exit action, like a button", name: 'exit');
  }

  String get warning {
    return Intl.message("Warning", desc: 'settings_logout_alert_title', name: 'warning');
  }

  String get logoutDetail {
    return Intl.message(
        "Logging out will remove your seed and all Nautilus-related data from this device. If your seed is not backed up, you will never be able to access your funds again",
        desc: 'settings_logout_alert_message',
        name: 'logoutDetail');
  }

  String get logoutAction {
    return Intl.message("Delete Seed and Logout", desc: 'settings_logout_alert_confirm_cta', name: 'logoutAction');
  }

  String get logoutAreYouSure {
    return Intl.message("Are you sure?", desc: 'settings_logout_warning_title', name: 'logoutAreYouSure');
  }

  String get logoutReassurance {
    return Intl.message("As long as you've backed up your seed you have nothing to worry about.",
        desc: 'settings_logout_warning_message', name: 'logoutReassurance');
  }

  String get settingsHeader {
    return Intl.message("Settings", desc: 'settings_title', name: 'settingsHeader');
  }

  String get preferences {
    return Intl.message("Preferences", desc: 'settings_preferences_header', name: 'preferences');
  }

  String get featured {
    return Intl.message("Featured", desc: 'featured', name: 'featured');
  }

  String get manage {
    return Intl.message("Manage", desc: 'settings_manage_header', name: 'manage');
  }

  String get backupSeed {
    return Intl.message("Backup Seed", desc: 'settings_backup_seed', name: 'backupSeed');
  }

  String get fingerprintSeedBackup {
    return Intl.message("Authenticate to backup seed.", desc: 'settings_fingerprint_title', name: 'fingerprintSeedBackup');
  }

  String get pinSeedBackup {
    return Intl.message("Enter PIN to Backup Seed", desc: 'settings_pin_title', name: 'pinSeedBackup');
  }

  String get systemDefault {
    return Intl.message("System Default", desc: 'settings_default_language_string', name: 'systemDefault');
  }

  String get notifications {
    return Intl.message("Notifications", desc: 'notifications_settings', name: 'notifications');
  }

  String get onramp {
    return Intl.message("Onramp", desc: 'onramp_settings', name: 'onramp');
  }

  String get onramper {
    return Intl.message("Onramper", desc: 'onramper_ramp', name: 'onramper');
  }

  String get moonpay {
    return Intl.message("MoonPay", desc: 'moonpay_ramp', name: 'moonpay');
  }

  String get simplex {
    return Intl.message("Simplex", desc: 'simplex_ramp', name: 'simplex');
  }

  String get copyWalletAddressToClipboard {
    return Intl.message("Copy wallet address to clipboard", desc: 'onramp_copy', name: 'copyWalletAddressToClipboard');
  }

  String get autoImport {
    return Intl.message("Auto Import", desc: 'auto_import', name: 'autoImport');
  }

  String get natricon {
    return Intl.message("Natricon", desc: 'natricon_settings', name: 'natricon');
  }

  String get nyanicon {
    return Intl.message("Nyanicon", desc: 'nyanicon_settings', name: 'nyanicon');
  }

  String get notificationTitle {
    return Intl.message("Received %1 %2", desc: 'notification_title', name: 'notificationTitle');
  }

  String get notificationBody {
    return Intl.message("Open Nautilus to view this transaction", desc: 'notification_body', name: 'notificationBody');
  }

  String get notificationHeaderSupplement {
    return Intl.message("Tap to open", desc: 'notificaiton_header_suplement', name: 'notificationHeaderSupplement');
  }

  /// -- END SETTINGS ITEMS

  /// -- TRANSFER
  // Settings
  String get settingsTransfer {
    return Intl.message("Load from Paper Wallet", desc: 'settings_transfer', name: 'settingsTransfer');
  }

  String get transferError {
    return Intl.message("An error has occurred during the transfer. Please try again later.", desc: 'transfer_error', name: 'transferError');
  }

  String get paperWallet {
    return Intl.message("Paper Wallet", desc: 'paper_wallet', name: 'paperWallet');
  }

  String get kaliumWallet {
    return Intl.message("Nautilus Wallet", desc: 'kalium_wallet', name: 'kaliumWallet');
  }

  String get manualEntry {
    return Intl.message("Manual Entry", desc: 'transfer_manual_entry', name: 'manualEntry');
  }

  String get mnemonicPhrase {
    return Intl.message("Mnemonic Phrase", desc: 'mnemonic_phrase', name: 'mnemonicPhrase');
  }

  String get rawSeed {
    return Intl.message("Raw Seed", desc: 'raw_seed', name: 'rawSeed');
  }

  // Initial Screen

  String get transferHeader {
    return Intl.message("Transfer Funds", desc: 'transfer_header', name: 'transferHeader');
  }

  String get transfer {
    return Intl.message("Transfer", desc: 'transfer_btn', name: 'transfer');
  }

  String get transferManualHint {
    return Intl.message("Please enter the seed below.", desc: 'transfer_hint', name: 'transferManualHint');
  }

  String get transferIntro {
    return Intl.message("This process will transfer the funds from a paper wallet to your Nautilus wallet.\n\nTap the \"%1\" button to start.",
        desc: 'transfer_intro', name: 'transferIntro');
  }

  String get transferIntroShort {
    return Intl.message("This process will transfer the funds from a paper wallet to your Nautilus wallet.",
        desc: 'transfer_intro_short', name: 'transferIntroShort');
  }

  String get transferQrScanHint {
    return Intl.message("Scan a Nano \nseed or private key", desc: 'transfer_qr_scan_hint', name: 'transferQrScanHint');
  }

  String get transferQrScanError {
    return Intl.message("This QR code does not contain a valid seed.", desc: 'transfer_qr_scan_error', name: 'transferQrScanError');
  }

  String get transferNoFunds {
    return Intl.message("This seed does not have any NANO on it", desc: 'transfer_no_funds_toast', name: 'transferNoFunds');
  }

  // Confirm screen

  String get transferConfirmInfo {
    return Intl.message("A wallet with a balance of %1 NANO has been detected.\n", desc: 'transfer_confirm_info_first', name: 'transferConfirmInfo');
  }

  String get transferConfirmInfoSecond {
    return Intl.message("Tap confirm to transfer the funds.\n", desc: 'transfer_confirm_info_second', name: 'transferConfirmInfoSecond');
  }

  String get transferConfirmInfoThird {
    return Intl.message("Transfer may take several seconds to complete.", desc: 'transfer_confirm_info_third', name: 'transferConfirmInfoThird');
  }

  String get transferLoading {
    return Intl.message("Transferring", desc: 'transfer_loading_text', name: 'transferLoading');
  }

  // Compelte screen

  String get transferComplete {
    return Intl.message("%1 %2 successfully transferred to your Nautilus Wallet.\n", desc: 'transfer_complete_text', name: 'transferComplete');
  }

  String get transferClose {
    return Intl.message("Tap anywhere to close the window.", desc: 'transfer_close_text', name: 'transferClose');
  }

  // -- END TRANSFER ITEMS

  // Scan

  String get scanInstructions {
    return Intl.message("Scan a Nano \naddress QR code", desc: 'scan_send_instruction_label', name: 'scanInstructions');
  }

  /// -- LOCK SCREEN

  String get unlockPin {
    return Intl.message("Enter PIN to Unlock Nautilus", desc: 'unlock_kalium_pin', name: 'unlockPin');
  }

  String get unlockBiometrics {
    return Intl.message("Authenticate to Unlock Nautilus", desc: 'unlock_kalium_bio', name: 'unlockBiometrics');
  }

  String get lockAppSetting {
    return Intl.message("Authenticate on Launch", desc: 'authenticate_on_launch', name: 'lockAppSetting');
  }

  String get locked {
    return Intl.message("Locked", desc: 'lockedtxt', name: 'locked');
  }

  String get unlock {
    return Intl.message("Unlock", desc: 'unlocktxt', name: 'unlock');
  }

  String get tooManyFailedAttempts {
    return Intl.message("Too many failed unlock attempts.", desc: 'fail_toomany_attempts', name: 'tooManyFailedAttempts');
  }

  /// -- END LOCK SCREEN

  /// -- SECURITY SETTINGS SUBMENU

  String get securityHeader {
    return Intl.message("Security", desc: 'security_header', name: 'securityHeader');
  }

  String get autoLockHeader {
    return Intl.message("Automatically Lock", desc: 'auto_lock_header', name: 'autoLockHeader');
  }

  String get xMinutes {
    return Intl.message("After %1 minutes", desc: 'after_minutes', name: 'xMinutes');
  }

  String get xMinute {
    return Intl.message("After %1 minute", desc: 'after_minute', name: 'xMinute');
  }

  String get instantly {
    return Intl.message("Instantly", desc: 'insantly', name: 'instantly');
  }

  String get setWalletPassword {
    return Intl.message("Set Wallet Password", desc: 'Allows user to encrypt wallet with a password', name: 'setWalletPassword');
  }

  String get setWalletPin {
    return Intl.message("Set Wallet Pin", desc: 'Allows user to encrypt wallet with a pin', name: 'setWalletPin');
  }

  String get setWalletPlausiblePin {
    return Intl.message("Set Wallet Plausible Pin", desc: 'Allows user to setup a plausible deniability pin', name: 'setWalletPlausiblePin');
  }

  String get setPassword {
    return Intl.message("Set Password", desc: 'A button that sets the wallet password', name: 'setPassword');
  }

  String get disableWalletPassword {
    return Intl.message("Disable Wallet Password", desc: 'Allows user to deencrypt wallet with a password', name: 'disableWalletPassword');
  }

  String get encryptionFailedError {
    return Intl.message("Failed to set a wallet password", desc: 'If encrypting a wallet raised an error', name: 'encryptionFailedError');
  }

  String get setPasswordSuccess {
    return Intl.message("Password has been set successfully", desc: 'Setting a Wallet Password was successful', name: 'setPasswordSuccess');
  }

  String get disablePasswordSuccess {
    return Intl.message("Password has been disabled", desc: 'Disabling a Wallet Password was successful', name: 'disablePasswordSuccess');
  }

  /// -- END SECURITY SETTINGS SUBMENU

  /// -- EXAMPLE HOME SCREEN CARDS

  String get exampleCardIntro {
    return Intl.message("Welcome to Nautilus. Once you receive NANO, transactions will show up like this:",
        desc: 'example_card_intro', name: 'exampleCardIntro');
  }

  String get exampleCardLittle {
    return Intl.message("A little", desc: 'example_card_little', name: 'exampleCardLittle');
  }

  String get exampleCardLot {
    return Intl.message("A lot of", desc: 'example_card_lot', name: 'exampleCardLot');
  }

  String get exampleCardTo {
    return Intl.message("someone", desc: 'example_card_to', name: 'exampleCardTo');
  }

  String get exampleCardFrom {
    return Intl.message("someone", desc: 'example_card_from', name: 'exampleCardFrom');
  }

  /// -- END EXAMPLE HOME SCREEN CARDS

  /// -- EXAMPLE PAYMENTS SCREEN CARDS

  String get examplePaymentIntro {
    return Intl.message("Once you send or receive a payment request, they'll show up here:", desc: 'example_payments_intro', name: 'examplePaymentIntro');
  }

  String get examplePaymentExplainer {
    return Intl.message(
        "Once you send or receive a payment request, they'll show up here like this with the color and tag of the card indicating the status. \n\nGreen indicates the request has been paid.\nYellow indicates the request / memo has not been paid / read.\nRed indicates the request has not been read or received.\n\n Neutral colored cards without an amount are just messages.",
        desc: 'example_payments_explainer',
        name: 'examplePaymentExplainer');
  }

  String get examplePaymentPending {
    return Intl.message("A lot of", desc: 'example_payment_pending', name: 'examplePaymentPending');
  }

  String get examplePaymentFulfilled {
    return Intl.message("Some", desc: 'example_payment_fulfilled', name: 'examplePaymentFulfilled');
  }

  String get examplePaymentPendingMemo {
    return Intl.message("Rent", desc: 'example_payment_pending_memo', name: 'examplePaymentPendingMemo');
  }

  String get examplePaymentFulfilledMemo {
    return Intl.message("Sushi", desc: 'example_payment_fulfilled_memo', name: 'examplePaymentFulfilledMemo');
  }

  String get examplePaymentTo {
    return Intl.message("@best_friend", desc: 'example_payment_to', name: 'examplePaymentTo');
  }

  String get examplePayRecipient {
    return Intl.message("@dad", desc: 'example_pay_recipient', name: 'examplePayRecipient');
  }

  String get examplePayRecipientMessage {
    return Intl.message("Happy Birthday!", desc: 'example_pay_recipient_message', name: 'examplePayRecipientMessage');
  }

  String get exampleRecRecipient {
    return Intl.message("@coworker", desc: 'example_rec_recipient', name: 'exampleReceiveRecipient');
  }

  String get exampleRecRecipientMessage {
    return Intl.message("Gas Money", desc: 'example_rec_recipient_message', name: 'exampleRecRecipientMessage');
  }

  String get examplePaymentFrom {
    return Intl.message("@landlord", desc: 'example_payment_from', name: 'examplePaymentFrom');
  }

  String get examplePaymentMessage {
    return Intl.message("Hey what's up?", desc: 'example_card_message', name: 'examplePaymentMessage');
  }

  /// -- END EXAMPLE HOME SCREEN CARDS

  /// GIFTS

  String get importGift {
    return Intl.message("The link you clicked contains some nano, would you like to import it to this wallet, or refund it to whoever sent it?",
        desc: 'import_gift', name: 'importGift');
  }

  String get importGiftEmpty {
    return Intl.message(
        "Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message.",
        desc: 'import_gift_empty',
        name: 'importGiftEmpty');
  }

  String get giftAlert {
    return Intl.message("You have a gift!", desc: 'import_gift_header', name: 'giftAlert');
  }

  String get giftAlertEmpty {
    return Intl.message("Empty Gift", desc: 'import_gift_empty_header', name: 'giftAlertEmpty');
  }

  String get giftMessage {
    return Intl.message("Gift Message", desc: 'gift_message', name: 'giftMessage');
  }

  String get giftAmount {
    return Intl.message("Gift Amount", desc: 'gift_amount', name: 'giftAmount');
  }

  String get giftFrom {
    return Intl.message("Gift From", desc: 'gift_from', name: 'giftFrom');
  }

  String get createGiftHeader {
    return Intl.message("Create a Gift Card", desc: 'create_gift_header', name: 'createGiftHeader');
  }

  String get giftInfo {
    return Intl.message('''Load a Digital Gift Card with NANO! Set an amount, and an optional message for the recipient to see when they open it!\n
Once created, you'll get a link that you can send to anyone, which when opened will automatically distribute the funds to the recipient after installing Nautilus!\n
If the recipient is already a Nautilus user they will get a prompt to transfer the funds into their account upon opening the link''',
        desc: 'Description for gift card creation', name: 'giftInfo');
  }

  String get giftWarning {
    return Intl.message(
        "You already have a username registered! It's not currently possible to change your username, but you're free to register a new one under a different address.",
        desc: 'Description for username already registered',
        name: 'giftWarning');
  }

  String get loadedInto {
    return Intl.message("Loaded Into", desc: 'loaded_into', name: 'loadedInto');
  }

  String get copyLink {
    return Intl.message("Copy Link", desc: 'copy_link', name: 'copyLink');
  }

  String get linkCopied {
    return Intl.message("Link Copied", desc: 'link_copied', name: 'linkCopied');
  }

  String get shareLink {
    return Intl.message("Share Link", desc: 'share_link', name: 'shareLink');
  }

  /// END GIFTS

  /// USERNAMES

  String get needVerificationAlert {
    return Intl.message(
        "This feature requires you to have a longer transaction history in order to prevent spam.\n\nAlternatively, you can show a QR code for someone to scan.",
        desc: 'verification_needed_header',
        name: 'needVerificationAlert');
  }

  String get goToQRCode {
    return Intl.message('Go to QR', desc: 'go_to_qr_code', name: 'goToQRCode');
  }

  String get needVerificationAlertHeader {
    return Intl.message("Verification Needed", desc: 'verification_needed_header', name: 'needVerificationAlertHeader');
  }

  String get registerUsernameHeader {
    return Intl.message("Register a Username", desc: 'register_username_header', name: 'registerUsernameHeader');
  }

  String get usernameInfo {
    return Intl.message(
        "Pick out a unique @username to make it easy for friends and family to find you!\n\nHaving a Nautilus username updates the UI globally to reflect your new handle.",
        desc: 'Description for username registration',
        name: 'usernameInfo');
  }

  String get usernameAlreadyRegistered {
    return Intl.message(
        "You already have a username registered! It's not currently possible to change your username, but you're free to register a new one under a different address.",
        desc: 'Description for username already registered',
        name: 'usernameAlreadyRegistered');
  }

  String get usernameWarning {
    return Intl.message("Nautilus usernames are a centralized service provided by Nano.to", desc: 'Username centralization warning', name: 'usernameWarning');
  }

  // String get giftMessage {
  //   return Intl.message("Gift Message", desc: 'gift_message', name: 'giftMessage');
  // }

  // String get giftAmount {
  //   return Intl.message("Gift Amount", desc: 'gift_amount', name: 'giftAmount');
  // }

  // String get giftFrom {
  //   return Intl.message("Gift From", desc: 'gift_from', name: 'giftFrom');
  // }

  /// END USERNAMES

  /// FALLBACK

  String get fallbackHeader {
    return Intl.message("Nautilus Disconnected", desc: 'fallback_connected', name: 'fallbackHeader');
  }

  String get fallbackInfo {
    return Intl.message(
        "Nautilus Servers appear to be disconnected, Sending and Receiving (without memos) should still be operational but payment requests may not go through\n\n Come back later or restart the app to try again",
        desc: 'fallback_info',
        name: 'fallbackInfo');
  }

  /// END FALLBACK

  /// NOTIFICATIONS

  String get notificationInfo {
    return Intl.message("In order for this feature to work correctly, notifications must be enabled", desc: 'notification_info', name: 'notificationInfo');
  }

  /// END NOTIFICATION

  /// -- START MULTI-ACCOUNT

  String get defaultAccountName {
    return Intl.message("Main Account", desc: "Default account name", name: 'defaultAccountName');
  }

  String get defaultNewAccountName {
    return Intl.message("Account %1", desc: "Default new account name - e.g. Account 1", name: 'defaultNewAccountName');
  }

  String get newAccountIntro {
    return Intl.message("This is your new account. Once you receive NANO, transactions will show up like this:",
        desc: 'Alternate account intro card', name: 'newAccountIntro');
  }

  String get account {
    return Intl.message("Account", desc: "Account text", name: 'account');
  }

  String get accounts {
    return Intl.message("Accounts", desc: "Accounts header", name: 'accounts');
  }

  String get addAccount {
    return Intl.message("Add Account", desc: "Default new account name - e.g. Account 1", name: 'addAccount');
  }

  String get hideAccountHeader {
    return Intl.message("Hide Account?", desc: "Confirmation dialog header", name: 'hideAccountHeader');
  }

  String get edit {
    return Intl.message("Edit", desc: "accounts_edit_slide", name: 'edit');
  }

  String get hide {
    return Intl.message("Hide", desc: "accounts_hide_slide", name: 'hide');
  }

  String get delete {
    return Intl.message("Delete", desc: "home_delete_slide", name: 'delete');
  }

  String get retry {
    return Intl.message("Retry", desc: "home_retry_slide", name: 'retry');
  }

  String get removeAccountText {
    return Intl.message("Are you sure you want to hide this account? You can re-add it later by tapping the \"%1\" button.",
        desc: "Remove account dialog body", name: 'removeAccountText');
  }

  /// -- END MULTI-ACCOUNT

  String get tapToReveal {
    return Intl.message("Tap to reveal", desc: "Tap to reveal hidden content", name: 'tapToReveal');
  }

  String get tapToHide {
    return Intl.message("Tap to hide", desc: "Tap to hide content", name: 'tapToHide');
  }

  String get copied {
    return Intl.message("Copied", desc: "Copied (to clipboard)", name: 'copied');
  }

  String get copy {
    return Intl.message("Copy", desc: "Copy (to clipboard)", name: 'copy');
  }

  String get seedDescription {
    return Intl.message(
        "A seed bears the same information as a secret phrase, but in a machine-readable way. As long as you have one of them backed up, you'll have access to your funds.",
        desc: "Describing what a seed is",
        name: 'seedDescription');
  }

  String get importSecretPhrase {
    return Intl.message("Import Secret Phrase", desc: "Header for restoring using mnemonic", name: 'importSecretPhrase');
  }

  String get importSecretPhraseHint {
    return Intl.message("Please enter your 24-word secret phrase below. Each word should be separated by a space.",
        desc: 'helper message for importing mnemnic', name: 'importSecretPhraseHint');
  }

  String get qrMnemonicError {
    return Intl.message("QR does not contain a valid secret phrase", desc: 'When QR does not contain a valid mnemonic phrase', name: 'qrMnemonicError');
  }

  String get mnemonicInvalidWord {
    return Intl.message("%1 is not a valid word", desc: 'A word that is not part of bip39', name: 'mnemonicInvalidWord');
  }

  String get mnemonicSizeError {
    return Intl.message("Secret phrase may only contain 24 words", desc: 'err', name: 'mnemonicSizeError');
  }

  String get secretPhrase {
    return Intl.message("Secret Phrase", desc: 'Secret (mnemonic) phrase', name: 'secretPhrase');
  }

  String get backupConfirmButton {
    return Intl.message("I've Backed It Up", desc: 'Has backed up seed confirmation button', name: 'backupConfirmButton');
  }

  String get secretInfoHeader {
    return Intl.message("Safety First!", desc: 'secret info header', name: 'secretInfoHeader');
  }

  String get secretInfo {
    return Intl.message(
        "In the next screen, you will see your secret phrase. It is a password to access your funds. It is crucial that you back it up and never share it with anyone.",
        desc: 'Description for seed',
        name: 'secretInfo');
  }

  String get secretWarning {
    return Intl.message("If you lose your device or uninstall the application, you'll need your secret phrase or seed to recover your funds!",
        desc: 'Secret warning', name: 'secretWarning');
  }

  String get gotItButton {
    return Intl.message("Got It!", desc: 'Got It! Acknowledgement button', name: 'gotItButton');
  }

  String get ackBackedUp {
    return Intl.message("Are you sure that you've backed up your secret phrase or seed?", desc: 'Ack backed up', name: 'ackBackedUp');
  }

  String get secretPhraseCopy {
    return Intl.message("Copy Secret Phrase", desc: 'Copy secret phrase to clipboard', name: 'secretPhraseCopy');
  }

  String get secretPhraseCopied {
    return Intl.message("Secret Phrase Copied", desc: 'Copied secret phrase to clipboard', name: 'secretPhraseCopied');
  }

  String get import {
    return Intl.message("Import", desc: "Generic import", name: 'import');
  }

  String get importSeedInstead {
    return Intl.message("Import Seed Instead", desc: "importSeedInstead", name: 'importSeedInstead');
  }

  String get switchToSeed {
    return Intl.message("Switch to Seed", desc: "switchToSeed", name: 'switchToSeed');
  }

  String get backupSecretPhrase {
    return Intl.message("Backup Secret Phrase", desc: 'backup seed', name: 'backupSecretPhrase');
  }

  /// -- SEED PROCESS

  /// -- END SEED PROCESS

  /// HINTS
  String get createPasswordHint {
    return Intl.message("Create a password", desc: 'A text field hint that tells the user to create a password', name: 'createPasswordHint');
  }

  String get confirmPasswordHint {
    return Intl.message("Confirm the password", desc: 'A text field hint that tells the user to confirm the password', name: 'confirmPasswordHint');
  }

  String get enterPasswordHint {
    return Intl.message("Enter your password", desc: 'A text field hint that tells the users to enter their password', name: 'enterPasswordHint');
  }

  String get passwordsDontMatch {
    return Intl.message("Passwords do not match", desc: 'An error indicating a password has been confirmed incorrectly', name: 'passwordsDontMatch');
  }

  String get passwordBlank {
    return Intl.message("Password cannot be empty", desc: 'An error indicating a password has been entered incorrectly', name: 'passwordBlank');
  }

  String get invalidPassword {
    return Intl.message("Invalid Password", desc: 'An error indicating a password has been entered incorrectly', name: 'invalidPassword');
  }

  /// HINTS END

  /// PARAGRAPS
  String get passwordWillBeRequiredToOpenParagraph {
    return Intl.message("This password will be required to open Nautilus.",
        desc: 'A paragraph that tells the users that the created password will be required to open Nautilus.', name: 'passwordWillBeRequiredToOpenParagraph');
  }

  String get passwordNoLongerRequiredToOpenParagraph {
    return Intl.message("You will not need a password to open Nautilus anymore.",
        desc: 'An info paragraph that tells the user a password will no longer be needed to open Nautilus', name: 'passwordNoLongerRequiredToOpenParagraph');
  }

  String get createPasswordFirstParagraph {
    return Intl.message("You can create a password to add additional security to your wallet.",
        desc: 'A paragraph that tells the users that they can create a password for additional security.', name: 'createPasswordFirstParagraph');
  }

  String get createPasswordSecondParagraph {
    return Intl.message("Password is optional, and your wallet will be protected with your PIN or biometrics regardless.",
        desc:
            'A paragraph that tells the users that the password creation is optional and the wallet will be still protected with biometrics or PIN regardless.',
        name: 'createPasswordSecondParagraph');
  }

  /// PARAGRAPS END

  /// HEADERS
  String get createAPasswordHeader {
    return Intl.message("Create a password.", desc: 'A paragraph that tells the users to create a password.', name: 'createAPasswordHeader');
  }

  String get createPasswordSheetHeader {
    return Intl.message("Create", desc: 'Prompt user to create a new password', name: 'createPasswordSheetHeader');
  }

  String get disablePasswordSheetHeader {
    return Intl.message("Disable", desc: 'Prompt user to disable their password', name: 'disablePasswordSheetHeader');
  }

  String get requireAPasswordToOpenHeader {
    return Intl.message("Require a password to open Nautilus?",
        desc: 'A paragraph that asks the users if they would like a password to be required to open Nautilus.', name: 'requireAPasswordToOpenHeader');
  }

  /// HEADERS END

  /// BUTTONS
  String get noSkipButton {
    return Intl.message("No, Skip", desc: 'A button that declines and skips the mentioned process.', name: 'noSkipButton');
  }

  String get yesButton {
    return Intl.message("Yes", desc: 'A button that accepts the mentioned process.', name: 'yesButton');
  }

  String get nextButton {
    return Intl.message("Next", desc: 'A button that goes to the next screen.', name: 'nextButton');
  }

  String get goBackButton {
    return Intl.message("Go Back", desc: 'A button that goes to the previous screen.', name: 'goBackButton');
  }

  String get supportButton {
    return Intl.message("Support", desc: 'A button to open up the live support window', name: 'supportButton');
  }

  String get liveSupportButton {
    return Intl.message("Support", desc: 'A button to open up the live support window', name: 'liveSupportButton');
  }

  /// BUTTONS END

  // RATE THE APP

  String get rate {
    return Intl.message("Rate", desc: 'rate_app_button', name: 'rate');
  }

  String get maybeLater {
    return Intl.message("Maybe Later", desc: 'maybe_app_button', name: 'maybeLater');
  }

  String get noThanks {
    return Intl.message("No Thanks", desc: 'no_thanks_app_button', name: 'noThanks');
  }

  String get rateTheApp {
    return Intl.message("Rate the App", desc: 'rate_app_header', name: 'rateTheApp');
  }

  String get rateTheAppDescription {
    return Intl.message("If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn\'t take more than a minute.",
        desc: 'rate_app_desc', name: 'rateTheAppDescription');
  }

  // RATE THE APP END

  // CHANGE LOG

  String get changeLog {
    return Intl.message("Change Log", desc: 'change_log_header', name: 'changeLog');
  }

  String get supportTheDeveloper {
    return Intl.message("Support the Developer", desc: 'change_log_support', name: 'supportTheDeveloper');
  }

  // CHANGE LOG END

  /// Live chat
  String get connectingHeader {
    return Intl.message("Connecting",
        desc: 'A header to let the user now that Nautilus is currently connecting to (or loading) live chat.', name: 'connectingHeader');
  }

  /// -- NON-TRANSLATABLE ITEMS
  String getBlockExplorerUrl(String? hash, AvailableBlockExplorer explorer) {
    if (explorer.explorer == AvailableBlockExplorerEnum.NANOCOMMUNITY) {
      return 'https://nano.community/$hash';
    } else if (explorer.explorer == AvailableBlockExplorerEnum.NANOLOOKER) {
      return 'https://nanolooker.com/block/$hash';
    } else if (explorer.explorer == AvailableBlockExplorerEnum.NANOCAFE) {
      return 'https://nanocafe.cc/$hash';
    }
    return 'https://nanocrawler.cc/explorer/block/$hash';
  }

  String getAccountExplorerUrl(String? account, AvailableBlockExplorer explorer) {
    if (explorer.explorer == AvailableBlockExplorerEnum.NANOCOMMUNITY) {
      return 'https://nano.community/$account';
    } else if (explorer.explorer == AvailableBlockExplorerEnum.NANOLOOKER) {
      return 'https://nanolooker.com/account/$account';
    } else if (explorer.explorer == AvailableBlockExplorerEnum.NANOCAFE) {
      return 'https://nanocafe.cc/$account';
    }
    return 'https://nanocrawler.cc/explorer/account/$account';
  }

  String get discordUrl {
    return 'https://chat.perish.co';
  }

  String get discord {
    return 'Discord';
  }

  String get nautilusNodeUrl {
    return 'https://node.perish.co';
  }

  String get eulaUrl {
    return 'https://perish.co/nautilus/eula.html';
  }

  String get privacyUrl {
    return 'https://perish.co/nautilus/privacy.html';
  }

  /// -- END NON-TRANSLATABLE ITEMS
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  final LanguageSetting languageSetting;

  const AppLocalizationsDelegate(this.languageSetting);

  @override
  bool isSupported(Locale locale) {
    return languageSetting != null;
  }

  @override
  Future<AppLocalization> load(Locale locale) {
    if (languageSetting.language == AvailableLanguage.DEFAULT) {
      return AppLocalization.load(locale);
    }
    return AppLocalization.load(Locale(languageSetting.getLocaleString()));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return true;
  }
}
