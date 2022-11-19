// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalization {
  AppLocalization();

  static AppLocalization? _current;

  static AppLocalization get current {
    assert(_current != null,
        'No instance of AppLocalization was loaded. Try to initialize the AppLocalization delegate before accessing AppLocalization.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalization();
      AppLocalization._current = instance;

      return instance;
    });
  }

  static AppLocalization of(BuildContext context) {
    final instance = AppLocalization.maybeOf(context);
    assert(instance != null,
        'No instance of AppLocalization present in the widget tree. Did you add AppLocalization.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppLocalization? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: 'Account text',
      args: [],
    );
  }

  /// `Enter a Name`
  String get accountNameHint {
    return Intl.message(
      'Enter a Name',
      name: 'accountNameHint',
      desc: 'enter_name_hint',
      args: [],
    );
  }

  /// `Choose an Account Name`
  String get accountNameMissing {
    return Intl.message(
      'Choose an Account Name',
      name: 'accountNameMissing',
      desc: 'account_name_missing',
      args: [],
    );
  }

  /// `Accounts`
  String get accounts {
    return Intl.message(
      'Accounts',
      name: 'accounts',
      desc: 'Accounts header',
      args: [],
    );
  }

  /// `Are you sure that you've backed up your secret phrase or seed?`
  String get ackBackedUp {
    return Intl.message(
      'Are you sure that you\'ve backed up your secret phrase or seed?',
      name: 'ackBackedUp',
      desc: 'Ack backed up',
      args: [],
    );
  }

  /// `Active Message`
  String get activeMessageHeader {
    return Intl.message(
      'Active Message',
      name: 'activeMessageHeader',
      desc: 'active_message',
      args: [],
    );
  }

  /// `Add Account`
  String get addAccount {
    return Intl.message(
      'Add Account',
      name: 'addAccount',
      desc: 'Default new account name - e.g. Account 1',
      args: [],
    );
  }

  /// `Add an Address`
  String get addAddress {
    return Intl.message(
      'Add an Address',
      name: 'addAddress',
      desc: 'split_add_address_header',
      args: [],
    );
  }

  /// `Block a User`
  String get addBlocked {
    return Intl.message(
      'Block a User',
      name: 'addBlocked',
      desc: 'blocked_add_button',
      args: [],
    );
  }

  /// `Add Contact`
  String get addContact {
    return Intl.message(
      'Add Contact',
      name: 'addContact',
      desc: 'contact_add_button',
      args: [],
    );
  }

  /// `Add Favorite`
  String get addFavorite {
    return Intl.message(
      'Add Favorite',
      name: 'addFavorite',
      desc: 'favorite_add_button',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: 'send_warning_address',
      args: [],
    );
  }

  /// `Address Copied`
  String get addressCopied {
    return Intl.message(
      'Address Copied',
      name: 'addressCopied',
      desc: 'receive_copied',
      args: [],
    );
  }

  /// `Enter Address`
  String get addressHint {
    return Intl.message(
      'Enter Address',
      name: 'addressHint',
      desc: 'send_address_hint',
      args: [],
    );
  }

  /// `Please enter an Address`
  String get addressMissing {
    return Intl.message(
      'Please enter an Address',
      name: 'addressMissing',
      desc: 'send_enter_address',
      args: [],
    );
  }

  /// `Please enter a Username or Address`
  String get addressOrUserMissing {
    return Intl.message(
      'Please enter a Username or Address',
      name: 'addressOrUserMissing',
      desc: 'send_enter_user_address',
      args: [],
    );
  }

  /// `Share Address`
  String get addressShare {
    return Intl.message(
      'Share Address',
      name: 'addressShare',
      desc: 'receive_share_cta',
      args: [],
    );
  }

  /// `Add a User`
  String get addUser {
    return Intl.message(
      'Add a User',
      name: 'addUser',
      desc: 'split_add_user_header',
      args: [],
    );
  }

  /// `Add Watch Only Account`
  String get addWatchOnlyAccount {
    return Intl.message(
      'Add Watch Only Account',
      name: 'addWatchOnlyAccount',
      desc: 'watch_only_add',
      args: [],
    );
  }

  /// `Error adding Watch Only Account: Account was null`
  String get addWatchOnlyAccountError {
    return Intl.message(
      'Error adding Watch Only Account: Account was null',
      name: 'addWatchOnlyAccountError',
      desc: 'watch_only_add_error',
      args: [],
    );
  }

  /// `Successfully created watch only account!`
  String get addWatchOnlyAccountSuccess {
    return Intl.message(
      'Successfully created watch only account!',
      name: 'addWatchOnlyAccountSuccess',
      desc: 'watch_only_add_success',
      args: [],
    );
  }

  /// `Aliases`
  String get aliases {
    return Intl.message(
      'Aliases',
      name: 'aliases',
      desc: 'card_details_aliases',
      args: [],
    );
  }

  /// `Split Amount can't be greater than gift balance`
  String get amountGiftGreaterError {
    return Intl.message(
      'Split Amount can\'t be greater than gift balance',
      name: 'amountGiftGreaterError',
      desc: 'gift_split_greater_error',
      args: [],
    );
  }

  /// `Please enter an Amount`
  String get amountMissing {
    return Intl.message(
      'Please enter an Amount',
      name: 'amountMissing',
      desc: 'send_enter_amount',
      args: [],
    );
  }

  /// `Asked`
  String get asked {
    return Intl.message(
      'Asked',
      name: 'asked',
      desc: 'home_asked_cta',
      args: [],
    );
  }

  /// `We noticed you clicked on a link that contains some nano, would you like to skip the setup process? You can always change things later.\n\n If you have an existing seed that you want to import however, you should select no.`
  String get askSkipSetup {
    return Intl.message(
      'We noticed you clicked on a link that contains some nano, would you like to skip the setup process? You can always change things later.\n\n If you have an existing seed that you want to import however, you should select no.',
      name: 'askSkipSetup',
      desc: 'prompt_skip_setup',
      args: [],
    );
  }

  /// `We're about to ask for the "tracking" permission, this is used *strictly* for attributing links / referrals, and minor analytics (things like number of installs, what app version, etc.) We believe you are entitled to your privacy and are not interested in any of your personal data, we just need the permission in order for link attributions to work correctly.`
  String get askTracking {
    return Intl.message(
      'We\'re about to ask for the "tracking" permission, this is used *strictly* for attributing links / referrals, and minor analytics (things like number of installs, what app version, etc.) We believe you are entitled to your privacy and are not interested in any of your personal data, we just need the permission in order for link attributions to work correctly.',
      name: 'askTracking',
      desc: 'prompt_ask_tracking',
      args: [],
    );
  }

  /// `Authenticating`
  String get authConfirm {
    return Intl.message(
      'Authenticating',
      name: 'authConfirm',
      desc: 'auth_confirm_message',
      args: [],
    );
  }

  /// `Authenticating`
  String get authenticating {
    return Intl.message(
      'Authenticating',
      name: 'authenticating',
      desc: 'auth_authenticating',
      args: [],
    );
  }

  /// `An error occurred while authenticating. Try again later.`
  String get authError {
    return Intl.message(
      'An error occurred while authenticating. Try again later.',
      name: 'authError',
      desc: 'auth_generic_error',
      args: [],
    );
  }

  /// `Authentication Method`
  String get authMethod {
    return Intl.message(
      'Authentication Method',
      name: 'authMethod',
      desc: 'settings_disable_fingerprint',
      args: [],
    );
  }

  /// `Auto Import`
  String get autoImport {
    return Intl.message(
      'Auto Import',
      name: 'autoImport',
      desc: 'auto_import',
      args: [],
    );
  }

  /// `Automatically Lock`
  String get autoLockHeader {
    return Intl.message(
      'Automatically Lock',
      name: 'autoLockHeader',
      desc: 'auto_lock_header',
      args: [],
    );
  }

  /// `I've Backed It Up`
  String get backupConfirmButton {
    return Intl.message(
      'I\'ve Backed It Up',
      name: 'backupConfirmButton',
      desc: 'Has backed up seed confirmation button',
      args: [],
    );
  }

  /// `Backup Secret Phrase`
  String get backupSecretPhrase {
    return Intl.message(
      'Backup Secret Phrase',
      name: 'backupSecretPhrase',
      desc: 'backup seed',
      args: [],
    );
  }

  /// `Backup Seed`
  String get backupSeed {
    return Intl.message(
      'Backup Seed',
      name: 'backupSeed',
      desc: 'settings_backup_seed',
      args: [],
    );
  }

  /// `Are you sure that you backed up your wallet seed?`
  String get backupSeedConfirm {
    return Intl.message(
      'Are you sure that you backed up your wallet seed?',
      name: 'backupSeedConfirm',
      desc: 'intro_new_wallet_backup',
      args: [],
    );
  }

  /// `Backup your seed`
  String get backupYourSeed {
    return Intl.message(
      'Backup your seed',
      name: 'backupYourSeed',
      desc: 'intro_new_wallet_seed_backup_header',
      args: [],
    );
  }

  /// `Biometrics`
  String get biometricsMethod {
    return Intl.message(
      'Biometrics',
      name: 'biometricsMethod',
      desc: 'settings_fingerprint_method',
      args: [],
    );
  }

  /// `%1 successfully blocked.`
  String get blockedAdded {
    return Intl.message(
      '%1 successfully blocked.',
      name: 'blockedAdded',
      desc: 'blocked_added',
      args: [],
    );
  }

  /// `User already Blocked!`
  String get blockedExists {
    return Intl.message(
      'User already Blocked!',
      name: 'blockedExists',
      desc: 'user_already_blocked',
      args: [],
    );
  }

  /// `Blocked`
  String get blockedHeader {
    return Intl.message(
      'Blocked',
      name: 'blockedHeader',
      desc: 'blocked_header',
      args: [],
    );
  }

  /// `Block a user by any known alias or address. Any messages, transactions, or requests from them will be ignored.`
  String get blockedInfo {
    return Intl.message(
      'Block a user by any known alias or address. Any messages, transactions, or requests from them will be ignored.',
      name: 'blockedInfo',
      desc: 'blocked_info',
      args: [],
    );
  }

  /// `Blocked Info`
  String get blockedInfoHeader {
    return Intl.message(
      'Blocked Info',
      name: 'blockedInfoHeader',
      desc: 'blocked_info',
      args: [],
    );
  }

  /// `Nick name already used!`
  String get blockedNameExists {
    return Intl.message(
      'Nick name already used!',
      name: 'blockedNameExists',
      desc: 'blocked_name_used',
      args: [],
    );
  }

  /// `Choose a Nick Name`
  String get blockedNameMissing {
    return Intl.message(
      'Choose a Nick Name',
      name: 'blockedNameMissing',
      desc: 'blocked_name_missing',
      args: [],
    );
  }

  /// `%1 has been unblocked!`
  String get blockedRemoved {
    return Intl.message(
      '%1 has been unblocked!',
      name: 'blockedRemoved',
      desc: 'blocked_removed',
      args: [],
    );
  }

  /// `Block Explorer`
  String get blockExplorer {
    return Intl.message(
      'Block Explorer',
      name: 'blockExplorer',
      desc: 'settings_change_block_explorer',
      args: [],
    );
  }

  /// `Block Explorer Info`
  String get blockExplorerHeader {
    return Intl.message(
      'Block Explorer Info',
      name: 'blockExplorerHeader',
      desc: 'block_explorer',
      args: [],
    );
  }

  /// `Which block explorer to use to display transaction information`
  String get blockExplorerInfo {
    return Intl.message(
      'Which block explorer to use to display transaction information',
      name: 'blockExplorerInfo',
      desc: 'block_explorer_info',
      args: [],
    );
  }

  /// `Block this User`
  String get blockUser {
    return Intl.message(
      'Block this User',
      name: 'blockUser',
      desc: 'block_user',
      args: [],
    );
  }

  /// `We can't seem to reach the Branch API, this is usually cause by some sort of network issue or VPN blocking the connection.\n\n You should still be able to use the app as normal, however sending and receiving gift cards may not work.`
  String get branchConnectErrorLongDesc {
    return Intl.message(
      'We can\'t seem to reach the Branch API, this is usually cause by some sort of network issue or VPN blocking the connection.\n\n You should still be able to use the app as normal, however sending and receiving gift cards may not work.',
      name: 'branchConnectErrorLongDesc',
      desc: 'branch_connection_error_long_desc',
      args: [],
    );
  }

  /// `Error: can't reach Branch API`
  String get branchConnectErrorShortDesc {
    return Intl.message(
      'Error: can\'t reach Branch API',
      name: 'branchConnectErrorShortDesc',
      desc: 'branch_connection_error_short_desc',
      args: [],
    );
  }

  /// `Connection Warning`
  String get branchConnectErrorTitle {
    return Intl.message(
      'Connection Warning',
      name: 'branchConnectErrorTitle',
      desc: 'branch_connection_error_title',
      args: [],
    );
  }

  /// `Business`
  String get businessButton {
    return Intl.message(
      'Business',
      name: 'businessButton',
      desc: 'business_button',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'dialog_cancel',
      args: [],
    );
  }

  /// `Captcha`
  String get captchaWarning {
    return Intl.message(
      'Captcha',
      name: 'captchaWarning',
      desc: 'gift_claim_captcha_warning_header',
      args: [],
    );
  }

  /// `In order to prevent abuse, we require you to solve a quick captcha on the next page to claim this gift card.`
  String get captchaWarningBody {
    return Intl.message(
      'In order to prevent abuse, we require you to solve a quick captcha on the next page to claim this gift card.',
      name: 'captchaWarningBody',
      desc: 'gift_claim_captcha_warning_body',
      args: [],
    );
  }

  /// `Change Currency`
  String get changeCurrency {
    return Intl.message(
      'Change Currency',
      name: 'changeCurrency',
      desc: 'settings_local_currency',
      args: [],
    );
  }

  /// `Change Log`
  String get changeLog {
    return Intl.message(
      'Change Log',
      name: 'changeLog',
      desc: 'change_log_header',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: 'A button that changes the magic password',
      args: [],
    );
  }

  /// `Change your existing password. If you don't know your current password, just make your best guess as it's not actually required to change it (since you are already logged in), but it does let us delete the existing backup entry.`
  String get changePasswordParagraph {
    return Intl.message(
      'Change your existing password. If you don\'t know your current password, just make your best guess as it\'s not actually required to change it (since you are already logged in), but it does let us delete the existing backup entry.',
      name: 'changePasswordParagraph',
      desc:
          'A paragraph that explains the user can set or change their existing magic password.',
      args: [],
    );
  }

  /// `Change Pin`
  String get changePin {
    return Intl.message(
      'Change Pin',
      name: 'changePin',
      desc: 'change_pin',
      args: [],
    );
  }

  /// `Set pin`
  String get changePinHint {
    return Intl.message(
      'Set pin',
      name: 'changePinHint',
      desc: 'A text field hint that tells the user to set a pin',
      args: [],
    );
  }

  /// `Change Representative`
  String get changeRepAuthenticate {
    return Intl.message(
      'Change Representative',
      name: 'changeRepAuthenticate',
      desc: 'settings_change_rep',
      args: [],
    );
  }

  /// `Change`
  String get changeRepButton {
    return Intl.message(
      'Change',
      name: 'changeRepButton',
      desc: 'change_representative_change',
      args: [],
    );
  }

  /// `Enter New Representative`
  String get changeRepHint {
    return Intl.message(
      'Enter New Representative',
      name: 'changeRepHint',
      desc: 'change_representative_hint',
      args: [],
    );
  }

  /// `This is already your representative!`
  String get changeRepSame {
    return Intl.message(
      'This is already your representative!',
      name: 'changeRepSame',
      desc: 'change_representative_same',
      args: [],
    );
  }

  /// `Representative Changed Successfully`
  String get changeRepSucces {
    return Intl.message(
      'Representative Changed Successfully',
      name: 'changeRepSucces',
      desc: 'change_representative_success',
      args: [],
    );
  }

  /// `Change Seed`
  String get changeSeed {
    return Intl.message(
      'Change Seed',
      name: 'changeSeed',
      desc: 'A button that changes the magic seed',
      args: [],
    );
  }

  /// `Change the seed/phrase associated with this magic-link authed account, whatever password you set here will overwrite your existing password, but you can use the same password if you choose.`
  String get changeSeedParagraph {
    return Intl.message(
      'Change the seed/phrase associated with this magic-link authed account, whatever password you set here will overwrite your existing password, but you can use the same password if you choose.',
      name: 'changeSeedParagraph',
      desc:
          'A paragraph that explains the user can set or change their existing magic seed.',
      args: [],
    );
  }

  /// `Check Availability`
  String get checkAvailability {
    return Intl.message(
      'Check Availability',
      name: 'checkAvailability',
      desc: 'check_availability',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: 'dialog_close',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: 'dialog_confirm',
      args: [],
    );
  }

  /// `Confirm the password`
  String get confirmPasswordHint {
    return Intl.message(
      'Confirm the password',
      name: 'confirmPasswordHint',
      desc: 'A text field hint that tells the user to confirm the password',
      args: [],
    );
  }

  /// `Confirm the pin`
  String get confirmPinHint {
    return Intl.message(
      'Confirm the pin',
      name: 'confirmPinHint',
      desc: 'A text field hint that tells the user to confirm the pin',
      args: [],
    );
  }

  /// `Connecting`
  String get connectingHeader {
    return Intl.message(
      'Connecting',
      name: 'connectingHeader',
      desc:
          'A header to let the user now that Nautilus is currently connecting to (or loading) live chat.',
      args: [],
    );
  }

  /// `Can't Connect`
  String get connectionWarning {
    return Intl.message(
      'Can\'t Connect',
      name: 'connectionWarning',
      desc: 'home_connection_warning',
      args: [],
    );
  }

  /// `We can't seem to connect to the backend, this could just be your connection or if the issue persists, the backend might be down for maintanence or even an outage. If it's been more than an hour and you're still having issues, please submit a report in #bug-reports in the discord server @ chat.perish.co`
  String get connectionWarningBody {
    return Intl.message(
      'We can\'t seem to connect to the backend, this could just be your connection or if the issue persists, the backend might be down for maintanence or even an outage. If it\'s been more than an hour and you\'re still having issues, please submit a report in #bug-reports in the discord server @ chat.perish.co',
      name: 'connectionWarningBody',
      desc: 'connection_warning_body',
      args: [],
    );
  }

  /// `We can't seem to connect to the backend, this could just be your connection or if the issue persists, the backend might be down for maintanence or even an outage. If it's been more than an hour and you're still having issues, please submit a report in #bug-reports in the discord server @ chat.perish.co`
  String get connectionWarningBodyLong {
    return Intl.message(
      'We can\'t seem to connect to the backend, this could just be your connection or if the issue persists, the backend might be down for maintanence or even an outage. If it\'s been more than an hour and you\'re still having issues, please submit a report in #bug-reports in the discord server @ chat.perish.co',
      name: 'connectionWarningBodyLong',
      desc: 'connection_warning_body_long',
      args: [],
    );
  }

  /// `We can't seem to connect to the backend`
  String get connectionWarningBodyShort {
    return Intl.message(
      'We can\'t seem to connect to the backend',
      name: 'connectionWarningBodyShort',
      desc: 'connection_warning_body_short',
      args: [],
    );
  }

  /// `%1 added to contacts.`
  String get contactAdded {
    return Intl.message(
      '%1 added to contacts.',
      name: 'contactAdded',
      desc: 'contact_added',
      args: [],
    );
  }

  /// `Contact Already Exists`
  String get contactExists {
    return Intl.message(
      'Contact Already Exists',
      name: 'contactExists',
      desc: 'contact_name_exists',
      args: [],
    );
  }

  /// `Contact`
  String get contactHeader {
    return Intl.message(
      'Contact',
      name: 'contactHeader',
      desc: 'contact_view_header',
      args: [],
    );
  }

  /// `Invalid Contact Name`
  String get contactInvalid {
    return Intl.message(
      'Invalid Contact Name',
      name: 'contactInvalid',
      desc: 'contact_invalid_name',
      args: [],
    );
  }

  /// `Enter a Nickname`
  String get contactNameHint {
    return Intl.message(
      'Enter a Nickname',
      name: 'contactNameHint',
      desc: 'contact_name_hint',
      args: [],
    );
  }

  /// `Choose a Name for this Contact`
  String get contactNameMissing {
    return Intl.message(
      'Choose a Name for this Contact',
      name: 'contactNameMissing',
      desc: 'contact_name_missing',
      args: [],
    );
  }

  /// `%1 has been removed from contacts!`
  String get contactRemoved {
    return Intl.message(
      '%1 has been removed from contacts!',
      name: 'contactRemoved',
      desc: 'contact_removed',
      args: [],
    );
  }

  /// `Contacts`
  String get contactsHeader {
    return Intl.message(
      'Contacts',
      name: 'contactsHeader',
      desc: 'contact_header',
      args: [],
    );
  }

  /// `Failed to import contacts`
  String get contactsImportErr {
    return Intl.message(
      'Failed to import contacts',
      name: 'contactsImportErr',
      desc: 'contact_import_error',
      args: [],
    );
  }

  /// `Sucessfully imported %1 contacts.`
  String get contactsImportSuccess {
    return Intl.message(
      'Sucessfully imported %1 contacts.',
      name: 'contactsImportSuccess',
      desc: 'contact_import_success',
      args: [],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message(
      'Continue',
      name: 'continueButton',
      desc: 'A continue button that goes to the next screen.',
      args: [],
    );
  }

  /// `Continue without login`
  String get continueWithoutLogin {
    return Intl.message(
      'Continue without login',
      name: 'continueWithoutLogin',
      desc: 'alternative_to_login',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
      desc: 'Copied (to clipboard)',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: 'Copy (to clipboard)',
      args: [],
    );
  }

  /// `Copy Address`
  String get copyAddress {
    return Intl.message(
      'Copy Address',
      name: 'copyAddress',
      desc: 'receive_copy_cta',
      args: [],
    );
  }

  /// `Copy Link`
  String get copyLink {
    return Intl.message(
      'Copy Link',
      name: 'copyLink',
      desc: 'copy_link',
      args: [],
    );
  }

  /// `Copy Message`
  String get copyMessage {
    return Intl.message(
      'Copy Message',
      name: 'copyMessage',
      desc: 'copy_message',
      args: [],
    );
  }

  /// `Copy Seed`
  String get copySeed {
    return Intl.message(
      'Copy Seed',
      name: 'copySeed',
      desc: 'copy_seed_btn',
      args: [],
    );
  }

  /// `Copy wallet address to clipboard`
  String get copyWalletAddressToClipboard {
    return Intl.message(
      'Copy wallet address to clipboard',
      name: 'copyWalletAddressToClipboard',
      desc: 'onramp_copy',
      args: [],
    );
  }

  /// `Copy Monero Seed`
  String get copyXMRSeed {
    return Intl.message(
      'Copy Monero Seed',
      name: 'copyXMRSeed',
      desc: 'copy_xmr_seed_btn',
      args: [],
    );
  }

  /// `Create a password.`
  String get createAPasswordHeader {
    return Intl.message(
      'Create a password.',
      name: 'createAPasswordHeader',
      desc: 'A paragraph that tells the users to create a password.',
      args: [],
    );
  }

  /// `created`
  String get created {
    return Intl.message(
      'created',
      name: 'created',
      desc: 'gift_created',
      args: [],
    );
  }

  /// `Create Gift Card`
  String get createGiftCard {
    return Intl.message(
      'Create Gift Card',
      name: 'createGiftCard',
      desc: 'create_gift_card',
      args: [],
    );
  }

  /// `Create a Gift Card`
  String get createGiftHeader {
    return Intl.message(
      'Create a Gift Card',
      name: 'createGiftHeader',
      desc: 'create_gift_header',
      args: [],
    );
  }

  /// `You can create a password to add additional security to your wallet.`
  String get createPasswordFirstParagraph {
    return Intl.message(
      'You can create a password to add additional security to your wallet.',
      name: 'createPasswordFirstParagraph',
      desc:
          'A paragraph that tells the users that they can create a password for additional security.',
      args: [],
    );
  }

  /// `Create a password`
  String get createPasswordHint {
    return Intl.message(
      'Create a password',
      name: 'createPasswordHint',
      desc: 'A text field hint that tells the user to create a password',
      args: [],
    );
  }

  /// `Password is optional, and your wallet will be protected with your PIN or biometrics regardless.`
  String get createPasswordSecondParagraph {
    return Intl.message(
      'Password is optional, and your wallet will be protected with your PIN or biometrics regardless.',
      name: 'createPasswordSecondParagraph',
      desc:
          'A paragraph that tells the users that the password creation is optional and the wallet will be still protected with biometrics or PIN regardless.',
      args: [],
    );
  }

  /// `Create`
  String get createPasswordSheetHeader {
    return Intl.message(
      'Create',
      name: 'createPasswordSheetHeader',
      desc: 'Prompt user to create a new password',
      args: [],
    );
  }

  /// `Create a pin`
  String get createPinHint {
    return Intl.message(
      'Create a pin',
      name: 'createPinHint',
      desc: 'A text field hint that tells the user to create a pin',
      args: [],
    );
  }

  /// `Create QR Code`
  String get createQR {
    return Intl.message(
      'Create QR Code',
      name: 'createQR',
      desc: 'create_qr_code',
      args: [],
    );
  }

  /// `Creating Gift Card`
  String get creatingGiftCard {
    return Intl.message(
      'Creating Gift Card',
      name: 'creatingGiftCard',
      desc: 'creating_gift_card',
      args: [],
    );
  }

  /// `Currency`
  String get currency {
    return Intl.message(
      'Currency',
      name: 'currency',
      desc: 'A settings menu item for changing currency',
      args: [],
    );
  }

  /// `Currency Mode`
  String get currencyMode {
    return Intl.message(
      'Currency Mode',
      name: 'currencyMode',
      desc: 'currency_mode',
      args: [],
    );
  }

  /// `Currency Mode Info`
  String get currencyModeHeader {
    return Intl.message(
      'Currency Mode Info',
      name: 'currencyModeHeader',
      desc: 'currency_mode_header',
      args: [],
    );
  }

  /// `Choose which unit to display amounts in.\n1 nyano = 0.000001 NANO, or \n1,000,000 nyano = 1 NANO`
  String get currencyModeInfo {
    return Intl.message(
      'Choose which unit to display amounts in.\n1 nyano = 0.000001 NANO, or \n1,000,000 nyano = 1 NANO',
      name: 'currencyModeInfo',
      desc: 'currency_mode_info',
      args: [],
    );
  }

  /// `Currently Represented By`
  String get currentlyRepresented {
    return Intl.message(
      'Currently Represented By',
      name: 'currentlyRepresented',
      desc: 'change_representative_current_header',
      args: [],
    );
  }

  /// `A day ago`
  String get dayAgo {
    return Intl.message(
      'A day ago',
      name: 'dayAgo',
      desc: 'history_day_ago',
      args: [],
    );
  }

  /// `Decryption Error!`
  String get decryptionError {
    return Intl.message(
      'Decryption Error!',
      name: 'decryptionError',
      desc: 'decryption_errorc',
      args: [],
    );
  }

  /// `Main Account`
  String get defaultAccountName {
    return Intl.message(
      'Main Account',
      name: 'defaultAccountName',
      desc: 'Default account name',
      args: [],
    );
  }

  /// `Check out Nautilus! I sent you some nano with this link:`
  String get defaultGiftMessage {
    return Intl.message(
      'Check out Nautilus! I sent you some nano with this link:',
      name: 'defaultGiftMessage',
      desc: 'default_gift_message',
      args: [],
    );
  }

  /// `Account %1`
  String get defaultNewAccountName {
    return Intl.message(
      'Account %1',
      name: 'defaultNewAccountName',
      desc: 'Default new account name - e.g. Account 1',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: 'home_delete_slide',
      args: [],
    );
  }

  /// `Delete this request`
  String get deleteRequest {
    return Intl.message(
      'Delete this request',
      name: 'deleteRequest',
      desc: 'delete_request',
      args: [],
    );
  }

  /// `Disable`
  String get disablePasswordSheetHeader {
    return Intl.message(
      'Disable',
      name: 'disablePasswordSheetHeader',
      desc: 'Prompt user to disable their password',
      args: [],
    );
  }

  /// `Password has been disabled`
  String get disablePasswordSuccess {
    return Intl.message(
      'Password has been disabled',
      name: 'disablePasswordSuccess',
      desc: 'Disabling a Wallet Password was successful',
      args: [],
    );
  }

  /// `Disable Wallet Password`
  String get disableWalletPassword {
    return Intl.message(
      'Disable Wallet Password',
      name: 'disableWalletPassword',
      desc: 'Allows user to deencrypt wallet with a password',
      args: [],
    );
  }

  /// `Dismiss`
  String get dismiss {
    return Intl.message(
      'Dismiss',
      name: 'dismiss',
      desc: 'dismiss',
      args: [],
    );
  }

  /// `Invalid Domain Name`
  String get domainInvalid {
    return Intl.message(
      'Invalid Domain Name',
      name: 'domainInvalid',
      desc: 'domain_invalid_name',
      args: [],
    );
  }

  /// `Donate`
  String get donateButton {
    return Intl.message(
      'Donate',
      name: 'donateButton',
      desc: 'donate_button',
      args: [],
    );
  }

  /// `Support the Project`
  String get donateToSupport {
    return Intl.message(
      'Support the Project',
      name: 'donateToSupport',
      desc: 'settings_support_donate',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: 'accounts_edit_slide',
      args: [],
    );
  }

  /// `Enable Notifications`
  String get enableNotifications {
    return Intl.message(
      'Enable Notifications',
      name: 'enableNotifications',
      desc: 'notification_warning_enable_button',
      args: [],
    );
  }

  /// `Enable Tracking`
  String get enableTracking {
    return Intl.message(
      'Enable Tracking',
      name: 'enableTracking',
      desc: 'tracking_warning_enable_button',
      args: [],
    );
  }

  /// `Failed to set a wallet password`
  String get encryptionFailedError {
    return Intl.message(
      'Failed to set a wallet password',
      name: 'encryptionFailedError',
      desc: 'If encrypting a wallet raised an error',
      args: [],
    );
  }

  /// `Enter Address`
  String get enterAddress {
    return Intl.message(
      'Enter Address',
      name: 'enterAddress',
      desc: 'enter_address',
      args: [],
    );
  }

  /// `Enter Amount`
  String get enterAmount {
    return Intl.message(
      'Enter Amount',
      name: 'enterAmount',
      desc: 'send_amount_hint',
      args: [],
    );
  }

  /// `Enter Email`
  String get enterEmail {
    return Intl.message(
      'Enter Email',
      name: 'enterEmail',
      desc: 'enter_email',
      args: [],
    );
  }

  /// `Enter Gift Note`
  String get enterGiftMemo {
    return Intl.message(
      'Enter Gift Note',
      name: 'enterGiftMemo',
      desc: 'gift_note',
      args: [],
    );
  }

  /// `Enter Height`
  String get enterHeight {
    return Intl.message(
      'Enter Height',
      name: 'enterHeight',
      desc: 'enter_height_hint',
      args: [],
    );
  }

  /// `Enter Message`
  String get enterMemo {
    return Intl.message(
      'Enter Message',
      name: 'enterMemo',
      desc: 'enter_memo',
      args: [],
    );
  }

  /// `Enter XMR Address`
  String get enterMoneroAddress {
    return Intl.message(
      'Enter XMR Address',
      name: 'enterMoneroAddress',
      desc: 'enter_xmr_address',
      args: [],
    );
  }

  /// `Enter your password`
  String get enterPasswordHint {
    return Intl.message(
      'Enter your password',
      name: 'enterPasswordHint',
      desc: 'A text field hint that tells the users to enter their password',
      args: [],
    );
  }

  /// `Enter Split Amount`
  String get enterSplitAmount {
    return Intl.message(
      'Enter Split Amount',
      name: 'enterSplitAmount',
      desc: 'gift_split_amount_hint',
      args: [],
    );
  }

  /// `Enter a username`
  String get enterUsername {
    return Intl.message(
      'Enter a username',
      name: 'enterUsername',
      desc: 'enter_username',
      args: [],
    );
  }

  /// `Enter User or Address`
  String get enterUserOrAddress {
    return Intl.message(
      'Enter User or Address',
      name: 'enterUserOrAddress',
      desc: 'enter_user_address',
      args: [],
    );
  }

  /// `There was an error while processing this gift card, it may be invalid, expired, or empty.\n\nAdditionally, you may need to update the app to the latest version in order to redeem this gift.`
  String get errorProcessingGiftCard {
    return Intl.message(
      'There was an error while processing this gift card, it may be invalid, expired, or empty.\n\nAdditionally, you may need to update the app to the latest version in order to redeem this gift.',
      name: 'errorProcessingGiftCard',
      desc: 'gift_process_error',
      args: [],
    );
  }

  /// `EULA`
  String get eula {
    return Intl.message(
      'EULA',
      name: 'eula',
      desc: 'settings_eula',
      args: [],
    );
  }

  /// `someone`
  String get exampleCardFrom {
    return Intl.message(
      'someone',
      name: 'exampleCardFrom',
      desc: 'example_card_from',
      args: [],
    );
  }

  /// `Welcome to Nautilus. Once you receive NANO, transactions will show up like this:`
  String get exampleCardIntro {
    return Intl.message(
      'Welcome to Nautilus. Once you receive NANO, transactions will show up like this:',
      name: 'exampleCardIntro',
      desc: 'example_card_intro',
      args: [],
    );
  }

  /// `A little`
  String get exampleCardLittle {
    return Intl.message(
      'A little',
      name: 'exampleCardLittle',
      desc: 'example_card_little',
      args: [],
    );
  }

  /// `A lot of`
  String get exampleCardLot {
    return Intl.message(
      'A lot of',
      name: 'exampleCardLot',
      desc: 'example_card_lot',
      args: [],
    );
  }

  /// `someone`
  String get exampleCardTo {
    return Intl.message(
      'someone',
      name: 'exampleCardTo',
      desc: 'example_card_to',
      args: [],
    );
  }

  /// `Once you send or receive a payment request, they'll show up here like this with the color and tag of the card indicating the status. \n\nGreen indicates the request has been paid.\nYellow indicates the request / memo has not been paid / read.\nRed indicates the request has not been read or received.\n\n Neutral colored cards without an amount are just messages.`
  String get examplePaymentExplainer {
    return Intl.message(
      'Once you send or receive a payment request, they\'ll show up here like this with the color and tag of the card indicating the status. \n\nGreen indicates the request has been paid.\nYellow indicates the request / memo has not been paid / read.\nRed indicates the request has not been read or received.\n\n Neutral colored cards without an amount are just messages.',
      name: 'examplePaymentExplainer',
      desc: 'example_payments_explainer',
      args: [],
    );
  }

  /// `@landlord`
  String get examplePaymentFrom {
    return Intl.message(
      '@landlord',
      name: 'examplePaymentFrom',
      desc: 'example_payment_from',
      args: [],
    );
  }

  /// `Some`
  String get examplePaymentFulfilled {
    return Intl.message(
      'Some',
      name: 'examplePaymentFulfilled',
      desc: 'example_payment_fulfilled',
      args: [],
    );
  }

  /// `Sushi`
  String get examplePaymentFulfilledMemo {
    return Intl.message(
      'Sushi',
      name: 'examplePaymentFulfilledMemo',
      desc: 'example_payment_fulfilled_memo',
      args: [],
    );
  }

  /// `Once you send or receive a payment request, they'll show up here:`
  String get examplePaymentIntro {
    return Intl.message(
      'Once you send or receive a payment request, they\'ll show up here:',
      name: 'examplePaymentIntro',
      desc: 'example_payments_intro',
      args: [],
    );
  }

  /// `Hey what's up?`
  String get examplePaymentMessage {
    return Intl.message(
      'Hey what\'s up?',
      name: 'examplePaymentMessage',
      desc: 'example_card_message',
      args: [],
    );
  }

  /// `A lot of`
  String get examplePaymentReceivable {
    return Intl.message(
      'A lot of',
      name: 'examplePaymentReceivable',
      desc: 'example_payment_receivable',
      args: [],
    );
  }

  /// `Rent`
  String get examplePaymentReceivableMemo {
    return Intl.message(
      'Rent',
      name: 'examplePaymentReceivableMemo',
      desc: 'example_payment_receivable_memo',
      args: [],
    );
  }

  /// `@best_friend`
  String get examplePaymentTo {
    return Intl.message(
      '@best_friend',
      name: 'examplePaymentTo',
      desc: 'example_payment_to',
      args: [],
    );
  }

  /// `@dad`
  String get examplePayRecipient {
    return Intl.message(
      '@dad',
      name: 'examplePayRecipient',
      desc: 'example_pay_recipient',
      args: [],
    );
  }

  /// `Happy Birthday!`
  String get examplePayRecipientMessage {
    return Intl.message(
      'Happy Birthday!',
      name: 'examplePayRecipientMessage',
      desc: 'example_pay_recipient_message',
      args: [],
    );
  }

  /// `@coworker`
  String get exampleRecRecipient {
    return Intl.message(
      '@coworker',
      name: 'exampleRecRecipient',
      desc: 'example_rec_recipient',
      args: [],
    );
  }

  /// `Gas Money`
  String get exampleRecRecipientMessage {
    return Intl.message(
      'Gas Money',
      name: 'exampleRecRecipientMessage',
      desc: 'example_rec_recipient_message',
      args: [],
    );
  }

  /// `Exchange NANO`
  String get exchangeNano {
    return Intl.message(
      'Exchange NANO',
      name: 'exchangeNano',
      desc: 'exchange_nano',
      args: [],
    );
  }

  /// `Enter current password`
  String get existingPasswordHint {
    return Intl.message(
      'Enter current password',
      name: 'existingPasswordHint',
      desc:
          'A text field hint that tells the user to enter their current password',
      args: [],
    );
  }

  /// `Enter current pin`
  String get existingPinHint {
    return Intl.message(
      'Enter current pin',
      name: 'existingPinHint',
      desc: 'A text field hint that tells the user to enter their current pin',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: 'Exit action, like a button',
      args: [],
    );
  }

  /// `Export Transactions`
  String get exportTXData {
    return Intl.message(
      'Export Transactions',
      name: 'exportTXData',
      desc: 'export_tx_data',
      args: [],
    );
  }

  /// `failed`
  String get failed {
    return Intl.message(
      'failed',
      name: 'failed',
      desc: 'history_failed',
      args: [],
    );
  }

  /// `msg failed`
  String get failedMessage {
    return Intl.message(
      'msg failed',
      name: 'failedMessage',
      desc: 'failed_message',
      args: [],
    );
  }

  /// `Nautilus Disconnected`
  String get fallbackHeader {
    return Intl.message(
      'Nautilus Disconnected',
      name: 'fallbackHeader',
      desc: 'fallback_connected',
      args: [],
    );
  }

  /// `Nautilus Servers appear to be disconnected, Sending and Receiving (without memos) should still be operational but payment requests may not go through\n\n Come back later or restart the app to try again`
  String get fallbackInfo {
    return Intl.message(
      'Nautilus Servers appear to be disconnected, Sending and Receiving (without memos) should still be operational but payment requests may not go through\n\n Come back later or restart the app to try again',
      name: 'fallbackInfo',
      desc: 'fallback_info',
      args: [],
    );
  }

  /// `Favorite Already Exists`
  String get favoriteExists {
    return Intl.message(
      'Favorite Already Exists',
      name: 'favoriteExists',
      desc: 'favorite_name_exists',
      args: [],
    );
  }

  /// `Favorite`
  String get favoriteHeader {
    return Intl.message(
      'Favorite',
      name: 'favoriteHeader',
      desc: 'favorite_view_header',
      args: [],
    );
  }

  /// `Invalid Favorite Name`
  String get favoriteInvalid {
    return Intl.message(
      'Invalid Favorite Name',
      name: 'favoriteInvalid',
      desc: 'favorite_invalid_name',
      args: [],
    );
  }

  /// `Enter a Nick Name`
  String get favoriteNameHint {
    return Intl.message(
      'Enter a Nick Name',
      name: 'favoriteNameHint',
      desc: 'favorite_name_hint',
      args: [],
    );
  }

  /// `Choose a Name for this Favorite`
  String get favoriteNameMissing {
    return Intl.message(
      'Choose a Name for this Favorite',
      name: 'favoriteNameMissing',
      desc: 'favorite_name_missing',
      args: [],
    );
  }

  /// `%1 has been removed from favorites!`
  String get favoriteRemoved {
    return Intl.message(
      '%1 has been removed from favorites!',
      name: 'favoriteRemoved',
      desc: 'favorite_removed',
      args: [],
    );
  }

  /// `Favorites`
  String get favoritesHeader {
    return Intl.message(
      'Favorites',
      name: 'favoritesHeader',
      desc: 'favorite_header',
      args: [],
    );
  }

  /// `Featured`
  String get featured {
    return Intl.message(
      'Featured',
      name: 'featured',
      desc: 'featured',
      args: [],
    );
  }

  /// `A few days ago`
  String get fewDaysAgo {
    return Intl.message(
      'A few days ago',
      name: 'fewDaysAgo',
      desc: 'history_few_days_ago',
      args: [],
    );
  }

  /// `A few hours ago`
  String get fewHoursAgo {
    return Intl.message(
      'A few hours ago',
      name: 'fewHoursAgo',
      desc: 'history_few_hours_ago',
      args: [],
    );
  }

  /// `A few minutes ago`
  String get fewMinutesAgo {
    return Intl.message(
      'A few minutes ago',
      name: 'fewMinutesAgo',
      desc: 'history_few_minutes_ago',
      args: [],
    );
  }

  /// `A few seconds ago`
  String get fewSecondsAgo {
    return Intl.message(
      'A few seconds ago',
      name: 'fewSecondsAgo',
      desc: 'history_few_seconds_ago',
      args: [],
    );
  }

  /// `Authenticate to backup seed.`
  String get fingerprintSeedBackup {
    return Intl.message(
      'Authenticate to backup seed.',
      name: 'fingerprintSeedBackup',
      desc: 'settings_fingerprint_title',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message(
      'From',
      name: 'from',
      desc: 'request_from',
      args: [],
    );
  }

  /// `fulfilled`
  String get fulfilled {
    return Intl.message(
      'fulfilled',
      name: 'fulfilled',
      desc: 'history_fulfilled',
      args: [],
    );
  }

  /// `Funding Banner`
  String get fundingBannerHeader {
    return Intl.message(
      'Funding Banner',
      name: 'fundingBannerHeader',
      desc: 'funding_banner_header',
      args: [],
    );
  }

  /// `Funding`
  String get fundingHeader {
    return Intl.message(
      'Funding',
      name: 'fundingHeader',
      desc: 'funding_header',
      args: [],
    );
  }

  /// `Get NANO`
  String get getNano {
    return Intl.message(
      'Get NANO',
      name: 'getNano',
      desc: 'get_nano',
      args: [],
    );
  }

  /// `You have a gift!`
  String get giftAlert {
    return Intl.message(
      'You have a gift!',
      name: 'giftAlert',
      desc: 'import_gift_header',
      args: [],
    );
  }

  /// `Empty Gift`
  String get giftAlertEmpty {
    return Intl.message(
      'Empty Gift',
      name: 'giftAlertEmpty',
      desc: 'import_gift_empty_header',
      args: [],
    );
  }

  /// `Gift Amount`
  String get giftAmount {
    return Intl.message(
      'Gift Amount',
      name: 'giftAmount',
      desc: 'gift_amount',
      args: [],
    );
  }

  /// `An error occured while trying to create a gift card link`
  String get giftCardCreationError {
    return Intl.message(
      'An error occured while trying to create a gift card link',
      name: 'giftCardCreationError',
      desc: 'create_gift_error',
      args: [],
    );
  }

  /// `An error occured while trying to create a gift card, THE GIFT CARD LINK OR SEED HAS BEEN COPIED TO YOUR CLIPBOARD, YOUR FUNDS MAY BE CONTAINED WITHIN IT DEPENDING ON WHAT WENT WRONG.`
  String get giftCardCreationErrorSent {
    return Intl.message(
      'An error occured while trying to create a gift card, THE GIFT CARD LINK OR SEED HAS BEEN COPIED TO YOUR CLIPBOARD, YOUR FUNDS MAY BE CONTAINED WITHIN IT DEPENDING ON WHAT WENT WRONG.',
      name: 'giftCardCreationErrorSent',
      desc: 'gift_generic_error',
      args: [],
    );
  }

  /// `Gift Sheet Info`
  String get giftCardInfoHeader {
    return Intl.message(
      'Gift Sheet Info',
      name: 'giftCardInfoHeader',
      desc: 'gift_card_sheet_info_header',
      args: [],
    );
  }

  /// `Gift From`
  String get giftFrom {
    return Intl.message(
      'Gift From',
      name: 'giftFrom',
      desc: 'gift_from',
      args: [],
    );
  }

  /// `Load a Digital Gift Card with NANO! Set an amount, and an optional message for the recipient to see when they open it!\n\nOnce created, you'll get a link that you can send to anyone, which when opened will automatically distribute the funds to the recipient after installing Nautilus!\n\nIf the recipient is already a Nautilus user they'll get a prompt to transfer the funds into their account upon opening the link\n\nYou can also set a split amount to distribute from the gift card rather than the entire balance.`
  String get giftInfo {
    return Intl.message(
      'Load a Digital Gift Card with NANO! Set an amount, and an optional message for the recipient to see when they open it!\n\nOnce created, you\'ll get a link that you can send to anyone, which when opened will automatically distribute the funds to the recipient after installing Nautilus!\n\nIf the recipient is already a Nautilus user they\'ll get a prompt to transfer the funds into their account upon opening the link\n\nYou can also set a split amount to distribute from the gift card rather than the entire balance.',
      name: 'giftInfo',
      desc: 'Description for gift card creation',
      args: [],
    );
  }

  /// `Gift Message`
  String get giftMessage {
    return Intl.message(
      'Gift Message',
      name: 'giftMessage',
      desc: 'gift_message',
      args: [],
    );
  }

  /// `There was an error while processing this gift card. Maybe check your connection and try clicking the gift link again.`
  String get giftProcessError {
    return Intl.message(
      'There was an error while processing this gift card. Maybe check your connection and try clicking the gift link again.',
      name: 'giftProcessError',
      desc: 'gift_process_error',
      args: [],
    );
  }

  /// `Gift Successfully Received, it may take a moment to appear in your wallet.`
  String get giftProcessSuccess {
    return Intl.message(
      'Gift Successfully Received, it may take a moment to appear in your wallet.',
      name: 'giftProcessSuccess',
      desc: 'gift_process_success',
      args: [],
    );
  }

  /// `Gift Successfully Refunded!`
  String get giftRefundSuccess {
    return Intl.message(
      'Gift Successfully Refunded!',
      name: 'giftRefundSuccess',
      desc: 'gift_refund_success',
      args: [],
    );
  }

  /// `You already have a username registered! It's not currently possible to change your username, but you're free to register a new one under a different address.`
  String get giftWarning {
    return Intl.message(
      'You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address.',
      name: 'giftWarning',
      desc: 'Description for username already registered',
      args: [],
    );
  }

  /// `Go Back`
  String get goBackButton {
    return Intl.message(
      'Go Back',
      name: 'goBackButton',
      desc: 'A button that goes to the previous screen.',
      args: [],
    );
  }

  /// `Got It!`
  String get gotItButton {
    return Intl.message(
      'Got It!',
      name: 'gotItButton',
      desc: 'Got It! Acknowledgement button',
      args: [],
    );
  }

  /// `Go to QR`
  String get goToQRCode {
    return Intl.message(
      'Go to QR',
      name: 'goToQRCode',
      desc: 'go_to_qr_code',
      args: [],
    );
  }

  /// `handoff`
  String get handoff {
    return Intl.message(
      'handoff',
      name: 'handoff',
      desc: 'send_handoff',
      args: [],
    );
  }

  /// `Something went wrong while trying to handoff block!`
  String get handoffFailed {
    return Intl.message(
      'Something went wrong while trying to handoff block!',
      name: 'handoffFailed',
      desc: 'handoff_failed',
      args: [],
    );
  }

  /// `A supported handoff method couldn't be found!`
  String get handoffSupportedMethodNotFound {
    return Intl.message(
      'A supported handoff method couldn\'t be found!',
      name: 'handoffSupportedMethodNotFound',
      desc: 'handoff_method_not_found',
      args: [],
    );
  }

  /// `Hide`
  String get hide {
    return Intl.message(
      'Hide',
      name: 'hide',
      desc: 'accounts_hide_slide',
      args: [],
    );
  }

  /// `Hide Account?`
  String get hideAccountHeader {
    return Intl.message(
      'Hide Account?',
      name: 'hideAccountHeader',
      desc: 'Confirmation dialog header',
      args: [],
    );
  }

  /// `Are you sure you want to hide empty accounts?\n\nThis will hide all accounts with a balance of exactly 0 (excluding watch only addresses and your main account), but you can always re-add them later by tapping the "Add Account" button`
  String get hideAccountsConfirmation {
    return Intl.message(
      'Are you sure you want to hide empty accounts?\n\nThis will hide all accounts with a balance of exactly 0 (excluding watch only addresses and your main account), but you can always re-add them later by tapping the "Add Account" button',
      name: 'hideAccountsConfirmation',
      desc: 'hide accounts confirmation info',
      args: [],
    );
  }

  /// `Hide Accounts?`
  String get hideAccountsHeader {
    return Intl.message(
      'Hide Accounts?',
      name: 'hideAccountsHeader',
      desc: 'Confirmation dialog header',
      args: [],
    );
  }

  /// `Hide Empty Accounts`
  String get hideEmptyAccounts {
    return Intl.message(
      'Hide Empty Accounts',
      name: 'hideEmptyAccounts',
      desc: 'hide_empty_accounts',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: 'home',
      args: [],
    );
  }

  /// `Home`
  String get homeButton {
    return Intl.message(
      'Home',
      name: 'homeButton',
      desc: 'home_button',
      args: [],
    );
  }

  /// `An hour ago`
  String get hourAgo {
    return Intl.message(
      'An hour ago',
      name: 'hourAgo',
      desc: 'history_hour_ago',
      args: [],
    );
  }

  /// `Ignore`
  String get ignore {
    return Intl.message(
      'Ignore',
      name: 'ignore',
      desc: 'ignore',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message(
      'Import',
      name: 'import',
      desc: 'Generic import',
      args: [],
    );
  }

  /// `The link you clicked contains some nano, would you like to import it to this wallet, or refund it to whoever sent it?`
  String get importGift {
    return Intl.message(
      'The link you clicked contains some nano, would you like to import it to this wallet, or refund it to whoever sent it?',
      name: 'importGift',
      desc: 'import_gift',
      args: [],
    );
  }

  /// `Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message.`
  String get importGiftEmpty {
    return Intl.message(
      'Unfortunately the link you clicked that contained some nano appears to be empty, but you can still see the amount and associated message.',
      name: 'importGiftEmpty',
      desc: 'import_gift_empty',
      args: [],
    );
  }

  /// `It looks like you clicked a link that contains some NANO, in order to receive these funds we just need for you to finish setting up your wallet.`
  String get importGiftIntro {
    return Intl.message(
      'It looks like you clicked a link that contains some NANO, in order to receive these funds we just need for you to finish setting up your wallet.',
      name: 'importGiftIntro',
      desc: 'import_gift_intro',
      args: [],
    );
  }

  /// `The link you clicked contains some NANO, would you like to import it to this wallet?`
  String get importGiftv2 {
    return Intl.message(
      'The link you clicked contains some NANO, would you like to import it to this wallet?',
      name: 'importGiftv2',
      desc: 'import_gift_v2',
      args: [],
    );
  }

  /// `Import HD`
  String get importHD {
    return Intl.message(
      'Import HD',
      name: 'importHD',
      desc: 'intro_import_hd',
      args: [],
    );
  }

  /// `Import Secret Phrase`
  String get importSecretPhrase {
    return Intl.message(
      'Import Secret Phrase',
      name: 'importSecretPhrase',
      desc: 'Header for restoring using mnemonic',
      args: [],
    );
  }

  /// `Please enter your 24-word secret phrase below. Each word should be separated by a space.`
  String get importSecretPhraseHint {
    return Intl.message(
      'Please enter your 24-word secret phrase below. Each word should be separated by a space.',
      name: 'importSecretPhraseHint',
      desc: 'helper message for importing mnemnic',
      args: [],
    );
  }

  /// `Import Seed`
  String get importSeed {
    return Intl.message(
      'Import Seed',
      name: 'importSeed',
      desc: 'intro_seed_header',
      args: [],
    );
  }

  /// `Please enter your seed below.`
  String get importSeedHint {
    return Intl.message(
      'Please enter your seed below.',
      name: 'importSeedHint',
      desc: 'intro_seed_info',
      args: [],
    );
  }

  /// `Import Seed Instead`
  String get importSeedInstead {
    return Intl.message(
      'Import Seed Instead',
      name: 'importSeedInstead',
      desc: 'importSeedInstead',
      args: [],
    );
  }

  /// `Import Standard`
  String get importStandard {
    return Intl.message(
      'Import Standard',
      name: 'importStandard',
      desc: 'intro_import_standard',
      args: [],
    );
  }

  /// `Import Wallet`
  String get importWallet {
    return Intl.message(
      'Import Wallet',
      name: 'importWallet',
      desc: 'intro_welcome_have_wallet',
      args: [],
    );
  }

  /// `I'm Sure`
  String get imSure {
    return Intl.message(
      'I\'m Sure',
      name: 'imSure',
      desc: 'send_confirm_warning',
      args: [],
    );
  }

  /// `I have a seed`
  String get haveSeedToImport {
    return Intl.message(
      'I have a seed',
      name: 'haveSeedToImport',
      desc: 'have_seed_to_import',
      args: [],
    );
  }

  /// `Do you have a seed to import?`
  String get doYouHaveSeedHeader {
    return Intl.message(
      'Do you have a seed to import?',
      name: 'doYouHaveSeedHeader',
      desc: 'do_have_seed_to_import',
      args: [],
    );
  }

  /// `If you're not sure what this means then you probably don't have a seed to import and can just press continue.`
  String get doYouHaveSeedBody {
    return Intl.message(
      'If you\'re not sure what this means then you probably don\'t have a seed to import and can just press continue.',
      name: 'doYouHaveSeedBody',
      desc: 'do_have_seed_to_import_body',
      args: [],
    );
  }

  /// `Instantly`
  String get instantly {
    return Intl.message(
      'Instantly',
      name: 'instantly',
      desc: 'insantly',
      args: [],
    );
  }

  /// `Insufficient Balance`
  String get insufficientBalance {
    return Intl.message(
      'Insufficient Balance',
      name: 'insufficientBalance',
      desc: 'send_insufficient_balance',
      args: [],
    );
  }

  /// `We skipped the intro process to save you time, but you should backup your newly created seed immediately.\n\nIf you lose your seed you will lose access to your funds.\n\nAdditionally, your passcode has been set to "000000" which you should also change immediately.`
  String get introSkippedWarningContent {
    return Intl.message(
      'We skipped the intro process to save you time, but you should backup your newly created seed immediately.\n\nIf you lose your seed you will lose access to your funds.\n\nAdditionally, your passcode has been set to "000000" which you should also change immediately.',
      name: 'introSkippedWarningContent',
      desc: 'intro_skipped_warning_content',
      args: [],
    );
  }

  /// `Backup your seed!`
  String get introSkippedWarningHeader {
    return Intl.message(
      'Backup your seed!',
      name: 'introSkippedWarningHeader',
      desc: 'intro_skipped_warning_header',
      args: [],
    );
  }

  /// `Address entered was invalid`
  String get invalidAddress {
    return Intl.message(
      'Address entered was invalid',
      name: 'invalidAddress',
      desc: 'send_invalid_address',
      args: [],
    );
  }

  /// `Invalid Height`
  String get invalidHeight {
    return Intl.message(
      'Invalid Height',
      name: 'invalidHeight',
      desc: 'height_invalid',
      args: [],
    );
  }

  /// `Invalid Password`
  String get invalidPassword {
    return Intl.message(
      'Invalid Password',
      name: 'invalidPassword',
      desc: 'An error indicating a password has been entered incorrectly',
      args: [],
    );
  }

  /// `Invalid Pin`
  String get invalidPin {
    return Intl.message(
      'Invalid Pin',
      name: 'invalidPin',
      desc: 'An error indicating a pin has been entered incorrectly',
      args: [],
    );
  }

  /// `Due to iOS App Store guidelines and restrictions, we can't link you to our donations page. If you'd like to support the project, consider sending to the nautilus node's address.`
  String get iosFundingMessage {
    return Intl.message(
      'Due to iOS App Store guidelines and restrictions, we can\'t link you to our donations page. If you\'d like to support the project, consider sending to the nautilus node\'s address.',
      name: 'iosFundingMessage',
      desc: 'ios_funding_message',
      args: [],
    );
  }

  /// `I Understand the Risks`
  String get iUnderstandTheRisks {
    return Intl.message(
      'I Understand the Risks',
      name: 'iUnderstandTheRisks',
      desc:
          'Shown to users if they have a rooted Android device or jailbroken iOS device',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'settings_change_language',
      args: [],
    );
  }

  /// `Link Copied`
  String get linkCopied {
    return Intl.message(
      'Link Copied',
      name: 'linkCopied',
      desc: 'link_copied',
      args: [],
    );
  }

  /// `Loaded`
  String get loaded {
    return Intl.message(
      'Loaded',
      name: 'loaded',
      desc: 'history_loaded',
      args: [],
    );
  }

  /// `Loaded Into`
  String get loadedInto {
    return Intl.message(
      'Loaded Into',
      name: 'loadedInto',
      desc: 'loaded_into',
      args: [],
    );
  }

  /// `Authenticate on Launch`
  String get lockAppSetting {
    return Intl.message(
      'Authenticate on Launch',
      name: 'lockAppSetting',
      desc: 'authenticate_on_launch',
      args: [],
    );
  }

  /// `Locked`
  String get locked {
    return Intl.message(
      'Locked',
      name: 'locked',
      desc: 'lockedtxt',
      args: [],
    );
  }

  /// `Login`
  String get loginButton {
    return Intl.message(
      'Login',
      name: 'loginButton',
      desc: 'login_button',
      args: [],
    );
  }

  /// `Login or Register`
  String get loginOrRegisterHeader {
    return Intl.message(
      'Login or Register',
      name: 'loginOrRegisterHeader',
      desc: 'login_register_header',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: 'settings_logout',
      args: [],
    );
  }

  /// `Delete Seed and Logout`
  String get logoutAction {
    return Intl.message(
      'Delete Seed and Logout',
      name: 'logoutAction',
      desc: 'settings_logout_alert_confirm_cta',
      args: [],
    );
  }

  /// `Are you sure?`
  String get logoutAreYouSure {
    return Intl.message(
      'Are you sure?',
      name: 'logoutAreYouSure',
      desc: 'settings_logout_warning_title',
      args: [],
    );
  }

  /// `Logging out will remove your seed and all Nautilus-related data from this device. If your seed is not backed up, you will never be able to access your funds again`
  String get logoutDetail {
    return Intl.message(
      'Logging out will remove your seed and all Nautilus-related data from this device. If your seed is not backed up, you will never be able to access your funds again',
      name: 'logoutDetail',
      desc: 'settings_logout_alert_message',
      args: [],
    );
  }

  /// `As long as you've backed up your seed you have nothing to worry about.`
  String get logoutReassurance {
    return Intl.message(
      'As long as you\'ve backed up your seed you have nothing to worry about.',
      name: 'logoutReassurance',
      desc: 'settings_logout_warning_message',
      args: [],
    );
  }

  /// `This appears to be an HD seed, unless you're sure you know what you're doing, you should use the "Import HD" option instead.`
  String get looksLikeHdSeed {
    return Intl.message(
      'This appears to be an HD seed, unless you\'re sure you know what you\'re doing, you should use the "Import HD" option instead.',
      name: 'looksLikeHdSeed',
      desc: 'settings_import_hd_warning',
      args: [],
    );
  }

  /// `This appears to be a standard seed, you should use the "Import Standard" option instead.`
  String get looksLikeStandardSeed {
    return Intl.message(
      'This appears to be a standard seed, you should use the "Import Standard" option instead.',
      name: 'looksLikeStandardSeed',
      desc: 'settings_import_standard_warning',
      args: [],
    );
  }

  /// `Manage`
  String get manage {
    return Intl.message(
      'Manage',
      name: 'manage',
      desc: 'settings_manage_header',
      args: [],
    );
  }

  /// `Couldn't Verify Request`
  String get mantaError {
    return Intl.message(
      'Couldn\'t Verify Request',
      name: 'mantaError',
      desc:
          'Was unable to verify the manta/appia payment request (from scanning QR code, etc.)',
      args: [],
    );
  }

  /// `Manual Entry`
  String get manualEntry {
    return Intl.message(
      'Manual Entry',
      name: 'manualEntry',
      desc: 'transfer_manual_entry',
      args: [],
    );
  }

  /// `Mark as Paid`
  String get markAsPaid {
    return Intl.message(
      'Mark as Paid',
      name: 'markAsPaid',
      desc: 'fulfill_payment',
      args: [],
    );
  }

  /// `Mark as Unpaid`
  String get markAsUnpaid {
    return Intl.message(
      'Mark as Unpaid',
      name: 'markAsUnpaid',
      desc: 'unfulfill_payment',
      args: [],
    );
  }

  /// `Maybe Later`
  String get maybeLater {
    return Intl.message(
      'Maybe Later',
      name: 'maybeLater',
      desc: 'maybe_app_button',
      args: [],
    );
  }

  /// `Message re-sent! If still unread, the recipient's device may be offline.`
  String get memoSentButNotReceived {
    return Intl.message(
      'Message re-sent! If still unread, the recipient\'s device may be offline.',
      name: 'memoSentButNotReceived',
      desc: 'memo_sent_again',
      args: [],
    );
  }

  /// `Message Copied`
  String get messageCopied {
    return Intl.message(
      'Message Copied',
      name: 'messageCopied',
      desc: 'message_copied',
      args: [],
    );
  }

  /// `Message`
  String get messageHeader {
    return Intl.message(
      'Message',
      name: 'messageHeader',
      desc: 'message_header',
      args: [],
    );
  }

  /// `Minimum send amount is %1 %2`
  String get minimumSend {
    return Intl.message(
      'Minimum send amount is %1 %2',
      name: 'minimumSend',
      desc: 'send_minimum_error',
      args: [],
    );
  }

  /// `A minute ago`
  String get minuteAgo {
    return Intl.message(
      'A minute ago',
      name: 'minuteAgo',
      desc: 'history_minute_ago',
      args: [],
    );
  }

  /// `%1 is not a valid word`
  String get mnemonicInvalidWord {
    return Intl.message(
      '%1 is not a valid word',
      name: 'mnemonicInvalidWord',
      desc: 'A word that is not part of bip39',
      args: [],
    );
  }

  /// `Mnemonic Phrase`
  String get mnemonicPhrase {
    return Intl.message(
      'Mnemonic Phrase',
      name: 'mnemonicPhrase',
      desc: 'mnemonic_phrase',
      args: [],
    );
  }

  /// `Secret phrase may only contain 24 words`
  String get mnemonicSizeError {
    return Intl.message(
      'Secret phrase may only contain 24 words',
      name: 'mnemonicSizeError',
      desc: 'err',
      args: [],
    );
  }

  /// `Monthly Server Costs`
  String get monthlyServerCosts {
    return Intl.message(
      'Monthly Server Costs',
      name: 'monthlyServerCosts',
      desc: 'support_monthly_costs',
      args: [],
    );
  }

  /// `MoonPay`
  String get moonpay {
    return Intl.message(
      'MoonPay',
      name: 'moonpay',
      desc: 'moonpay_ramp',
      args: [],
    );
  }

  /// `More Settings`
  String get moreSettings {
    return Intl.message(
      'More Settings',
      name: 'moreSettings',
      desc: 'settings_more',
      args: [],
    );
  }

  /// `Natricon`
  String get natricon {
    return Intl.message(
      'Natricon',
      name: 'natricon',
      desc: 'natricon_settings',
      args: [],
    );
  }

  /// `Nautilus Wallet`
  String get nautilusWallet {
    return Intl.message(
      'Nautilus Wallet',
      name: 'nautilusWallet',
      desc: 'nautilus_wallet',
      args: [],
    );
  }

  /// `Nearby`
  String get nearby {
    return Intl.message(
      'Nearby',
      name: 'nearby',
      desc: 'nearby_devices',
      args: [],
    );
  }

  /// `This feature requires you to have a longer transaction history in order to prevent spam.\n\nAlternatively, you can show a QR code for someone to scan.`
  String get needVerificationAlert {
    return Intl.message(
      'This feature requires you to have a longer transaction history in order to prevent spam.\n\nAlternatively, you can show a QR code for someone to scan.',
      name: 'needVerificationAlert',
      desc: 'verification_needed_header',
      args: [],
    );
  }

  /// `Verification Needed`
  String get needVerificationAlertHeader {
    return Intl.message(
      'Verification Needed',
      name: 'needVerificationAlertHeader',
      desc: 'verification_needed_header',
      args: [],
    );
  }

  /// `This is your new account. Once you receive NANO, transactions will show up like this:`
  String get newAccountIntro {
    return Intl.message(
      'This is your new account. Once you receive NANO, transactions will show up like this:',
      name: 'newAccountIntro',
      desc: 'Alternate account intro card',
      args: [],
    );
  }

  /// `New Wallet`
  String get newWallet {
    return Intl.message(
      'New Wallet',
      name: 'newWallet',
      desc: 'intro_welcome_new_wallet',
      args: [],
    );
  }

  /// `Next`
  String get nextButton {
    return Intl.message(
      'Next',
      name: 'nextButton',
      desc: 'A button that goes to the next screen.',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: 'intro_new_wallet_backup_no',
      args: [],
    );
  }

  /// `There's no contacts to export.`
  String get noContactsExport {
    return Intl.message(
      'There\'s no contacts to export.',
      name: 'noContactsExport',
      desc: 'contact_export_none',
      args: [],
    );
  }

  /// `No new contacts to import.`
  String get noContactsImport {
    return Intl.message(
      'No new contacts to import.',
      name: 'noContactsImport',
      desc: 'contact_import_none',
      args: [],
    );
  }

  /// `Node Status`
  String get nodeStatus {
    return Intl.message(
      'Node Status',
      name: 'nodeStatus',
      desc: 'settings_node_status',
      args: [],
    );
  }

  /// `None`
  String get noneMethod {
    return Intl.message(
      'None',
      name: 'noneMethod',
      desc: 'settings_none_method',
      args: [],
    );
  }

  /// `No Search Results!`
  String get noSearchResults {
    return Intl.message(
      'No Search Results!',
      name: 'noSearchResults',
      desc: 'home_search_error',
      args: [],
    );
  }

  /// `No, Skip`
  String get noSkipButton {
    return Intl.message(
      'No, Skip',
      name: 'noSkipButton',
      desc: 'A button that declines and skips the mentioned process.',
      args: [],
    );
  }

  /// `No Thanks`
  String get noThanks {
    return Intl.message(
      'No Thanks',
      name: 'noThanks',
      desc: 'no_thanks_app_button',
      args: [],
    );
  }

  /// `Open Nautilus to view this transaction`
  String get notificationBody {
    return Intl.message(
      'Open Nautilus to view this transaction',
      name: 'notificationBody',
      desc: 'notification_body',
      args: [],
    );
  }

  /// `Tap to open`
  String get notificationHeaderSupplement {
    return Intl.message(
      'Tap to open',
      name: 'notificationHeaderSupplement',
      desc: 'notificaiton_header_suplement',
      args: [],
    );
  }

  /// `In order for this feature to work correctly, notifications must be enabled`
  String get notificationInfo {
    return Intl.message(
      'In order for this feature to work correctly, notifications must be enabled',
      name: 'notificationInfo',
      desc: 'notification_info',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: 'notifications_settings',
      args: [],
    );
  }

  /// `Received %1 %2`
  String get notificationTitle {
    return Intl.message(
      'Received %1 %2',
      name: 'notificationTitle',
      desc: 'notification_title',
      args: [],
    );
  }

  /// `Notifications Disabled`
  String get notificationWarning {
    return Intl.message(
      'Notifications Disabled',
      name: 'notificationWarning',
      desc: 'home_notification_warning',
      args: [],
    );
  }

  /// `Payment Requests, Memos, and Messages all require notifications to be enabled in order to work properly as they use the FCM notifications service to ensure message delivery.\n\nYou can enable notifications with the button below or dismiss this card if you don't care to use these features.`
  String get notificationWarningBodyLong {
    return Intl.message(
      'Payment Requests, Memos, and Messages all require notifications to be enabled in order to work properly as they use the FCM notifications service to ensure message delivery.\n\nYou can enable notifications with the button below or dismiss this card if you don\'t care to use these features.',
      name: 'notificationWarningBodyLong',
      desc: 'notification_warning_body_long',
      args: [],
    );
  }

  /// `Payment Requests, Memos, and Messages will not function properly.`
  String get notificationWarningBodyShort {
    return Intl.message(
      'Payment Requests, Memos, and Messages will not function properly.',
      name: 'notificationWarningBodyShort',
      desc: 'notification_warning_body_short',
      args: [],
    );
  }

  /// `not sent`
  String get notSent {
    return Intl.message(
      'not sent',
      name: 'notSent',
      desc: 'not_sent_message',
      args: [],
    );
  }

  /// `There's no transactions to export.`
  String get noTXDataExport {
    return Intl.message(
      'There\'s no transactions to export.',
      name: 'noTXDataExport',
      desc: 'tx_export_none',
      args: [],
    );
  }

  /// `Nyanicon`
  String get nyanicon {
    return Intl.message(
      'Nyanicon',
      name: 'nyanicon',
      desc: 'nyanicon_settings',
      args: [],
    );
  }

  /// `Obscure Transaction Info`
  String get obscureInfoHeader {
    return Intl.message(
      'Obscure Transaction Info',
      name: 'obscureInfoHeader',
      desc: 'obscure_tx_info',
      args: [],
    );
  }

  /// `Obscure Transaction`
  String get obscureTransaction {
    return Intl.message(
      'Obscure Transaction',
      name: 'obscureTransaction',
      desc: 'obscure_tx',
      args: [],
    );
  }

  /// `This is NOT true privacy, but it will make it harder for the recipient to see who sent them funds.`
  String get obscureTransactionBody {
    return Intl.message(
      'This is NOT true privacy, but it will make it harder for the recipient to see who sent them funds.',
      name: 'obscureTransactionBody',
      desc: 'obscure_tx_body',
      args: [],
    );
  }

  /// `Off`
  String get off {
    return Intl.message(
      'Off',
      name: 'off',
      desc: 'generic_off',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: 'ok',
      args: [],
    );
  }

  /// `Invite Someone`
  String get onboard {
    return Intl.message(
      'Invite Someone',
      name: 'onboard',
      desc: 'featured_onboard',
      args: [],
    );
  }

  /// `Onboarding`
  String get onboarding {
    return Intl.message(
      'Onboarding',
      name: 'onboarding',
      desc: 'share_onboarding',
      args: [],
    );
  }

  /// `Onramp`
  String get onramp {
    return Intl.message(
      'Onramp',
      name: 'onramp',
      desc: 'onramp_settings',
      args: [],
    );
  }

  /// `Onramper`
  String get onramper {
    return Intl.message(
      'Onramper',
      name: 'onramper',
      desc: 'onramper_ramp',
      args: [],
    );
  }

  /// `On`
  String get onStr {
    return Intl.message(
      'On',
      name: 'onStr',
      desc: 'generic_on',
      args: [],
    );
  }

  /// `Opened`
  String get opened {
    return Intl.message(
      'Opened',
      name: 'opened',
      desc: 'history_opened',
      args: [],
    );
  }

  /// `paid`
  String get paid {
    return Intl.message(
      'paid',
      name: 'paid',
      desc: 'history_paid',
      args: [],
    );
  }

  /// `Paper Wallet`
  String get paperWallet {
    return Intl.message(
      'Paper Wallet',
      name: 'paperWallet',
      desc: 'paper_wallet',
      args: [],
    );
  }

  /// `Password cannot be empty`
  String get passwordBlank {
    return Intl.message(
      'Password cannot be empty',
      name: 'passwordBlank',
      desc: 'An error indicating a password has been entered incorrectly',
      args: [],
    );
  }

  /// `Password must contain at least 1 upper case and lower case letter`
  String get passwordCapitalLetter {
    return Intl.message(
      'Password must contain at least 1 upper case and lower case letter',
      name: 'passwordCapitalLetter',
      desc: 'password_uppercase_lowercase',
      args: [],
    );
  }

  /// `We're not responsible if you forget your password, and by design we are unable to reset or change it for you.`
  String get passwordDisclaimer {
    return Intl.message(
      'We\'re not responsible if you forget your password, and by design we are unable to reset or change it for you.',
      name: 'passwordDisclaimer',
      desc:
          'A paragraph that we\'re not responsible if you lose your password.',
      args: [],
    );
  }

  /// `Incorrect password`
  String get passwordIncorrect {
    return Intl.message(
      'Incorrect password',
      name: 'passwordIncorrect',
      desc: 'An error indicating the password is incorrect',
      args: [],
    );
  }

  /// `You will not need a password to open Nautilus anymore.`
  String get passwordNoLongerRequiredToOpenParagraph {
    return Intl.message(
      'You will not need a password to open Nautilus anymore.',
      name: 'passwordNoLongerRequiredToOpenParagraph',
      desc:
          'An info paragraph that tells the user a password will no longer be needed to open Nautilus',
      args: [],
    );
  }

  /// `Password must contain at least 1 number`
  String get passwordNumber {
    return Intl.message(
      'Password must contain at least 1 number',
      name: 'passwordNumber',
      desc: 'password_number',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDontMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDontMatch',
      desc: 'An error indicating a password has been confirmed incorrectly',
      args: [],
    );
  }

  /// `Password must contain at least 1 special character`
  String get passwordSpecialCharacter {
    return Intl.message(
      'Password must contain at least 1 special character',
      name: 'passwordSpecialCharacter',
      desc: 'password_special_character',
      args: [],
    );
  }

  /// `Password is too short`
  String get passwordTooShort {
    return Intl.message(
      'Password is too short',
      name: 'passwordTooShort',
      desc: 'An error indicating the password is too short',
      args: [],
    );
  }

  /// `This password will be required to open Nautilus.`
  String get passwordWarning {
    return Intl.message(
      'This password will be required to open Nautilus.',
      name: 'passwordWarning',
      desc: 'A paragraph that warns the user to not lose their password.',
      args: [],
    );
  }

  /// `This password will be required to open Nautilus.`
  String get passwordWillBeRequiredToOpenParagraph {
    return Intl.message(
      'This password will be required to open Nautilus.',
      name: 'passwordWillBeRequiredToOpenParagraph',
      desc:
          'A paragraph that tells the users that the created password will be required to open Nautilus.',
      args: [],
    );
  }

  /// `Pay`
  String get pay {
    return Intl.message(
      'Pay',
      name: 'pay',
      desc: 'home_pay_slidable',
      args: [],
    );
  }

  /// `Someone has requested payment from you! check the payments page for more info.`
  String get paymentRequestMessage {
    return Intl.message(
      'Someone has requested payment from you! check the payments page for more info.',
      name: 'paymentRequestMessage',
      desc: 'payment_request_message',
      args: [],
    );
  }

  /// `Payments`
  String get payments {
    return Intl.message(
      'Payments',
      name: 'payments',
      desc: 'payments',
      args: [],
    );
  }

  /// `Pay this request`
  String get payRequest {
    return Intl.message(
      'Pay this request',
      name: 'payRequest',
      desc: 'pay_request',
      args: [],
    );
  }

  /// `Pick From a List`
  String get pickFromList {
    return Intl.message(
      'Pick From a List',
      name: 'pickFromList',
      desc: 'pick rep from list',
      args: [],
    );
  }

  /// `Pin cannot be empty`
  String get pinBlank {
    return Intl.message(
      'Pin cannot be empty',
      name: 'pinBlank',
      desc: 'An error indicating a pin has been entered incorrectly',
      args: [],
    );
  }

  /// `Pins do not match`
  String get pinConfirmError {
    return Intl.message(
      'Pins do not match',
      name: 'pinConfirmError',
      desc: 'pin_confirm_error',
      args: [],
    );
  }

  /// `Confirm your pin`
  String get pinConfirmTitle {
    return Intl.message(
      'Confirm your pin',
      name: 'pinConfirmTitle',
      desc: 'pin_confirm_title',
      args: [],
    );
  }

  /// `Create a 6-digit pin`
  String get pinCreateTitle {
    return Intl.message(
      'Create a 6-digit pin',
      name: 'pinCreateTitle',
      desc: 'pin_create_title',
      args: [],
    );
  }

  /// `Enter pin`
  String get pinEnterTitle {
    return Intl.message(
      'Enter pin',
      name: 'pinEnterTitle',
      desc: 'pin_enter_title',
      args: [],
    );
  }

  /// `Incorrect pin entered`
  String get pinIncorrect {
    return Intl.message(
      'Incorrect pin entered',
      name: 'pinIncorrect',
      desc: 'pin_error',
      args: [],
    );
  }

  /// `Invalid pin entered`
  String get pinInvalid {
    return Intl.message(
      'Invalid pin entered',
      name: 'pinInvalid',
      desc: 'pin_error',
      args: [],
    );
  }

  /// `PIN`
  String get pinMethod {
    return Intl.message(
      'PIN',
      name: 'pinMethod',
      desc: 'settings_pin_method',
      args: [],
    );
  }

  /// `Enter PIN to change representative.`
  String get pinRepChange {
    return Intl.message(
      'Enter PIN to change representative.',
      name: 'pinRepChange',
      desc: 'change_representative_pin',
      args: [],
    );
  }

  /// `Pins do not match`
  String get pinsDontMatch {
    return Intl.message(
      'Pins do not match',
      name: 'pinsDontMatch',
      desc: 'An error indicating a pin has been confirmed incorrectly',
      args: [],
    );
  }

  /// `Enter PIN to Backup Seed`
  String get pinSeedBackup {
    return Intl.message(
      'Enter PIN to Backup Seed',
      name: 'pinSeedBackup',
      desc: 'settings_pin_title',
      args: [],
    );
  }

  /// `This is NOT the same pin you used to create your wallet. Press the info button for more information.`
  String get plausibleDeniabilityParagraph {
    return Intl.message(
      'This is NOT the same pin you used to create your wallet. Press the info button for more information.',
      name: 'plausibleDeniabilityParagraph',
      desc:
          'A paragraph that tells warns the user this is plausible deniability pin.',
      args: [],
    );
  }

  /// `Plausible Deniability Info`
  String get plausibleInfoHeader {
    return Intl.message(
      'Plausible Deniability Info',
      name: 'plausibleInfoHeader',
      desc: 'plausible_info_header',
      args: [],
    );
  }

  /// `Set a secondary pin for plausible deniability mode.\n\nIf your wallet is unlocked using this secondary pin, your seed will be replaced with a hash of the existing seed. This is a security feature intended to be used in the event you are forced to open your wallet.\n\nThis pin will act like a normal (correct) pin EXCEPT when unlocking your wallet, which is when plausible deniability mode will activate.\n\nYour funds WILL BE LOST upon entering plausible deniability mode if you have not backed up your seed!`
  String get plausibleSheetInfo {
    return Intl.message(
      'Set a secondary pin for plausible deniability mode.\n\nIf your wallet is unlocked using this secondary pin, your seed will be replaced with a hash of the existing seed. This is a security feature intended to be used in the event you are forced to open your wallet.\n\nThis pin will act like a normal (correct) pin EXCEPT when unlocking your wallet, which is when plausible deniability mode will activate.\n\nYour funds WILL BE LOST upon entering plausible deniability mode if you have not backed up your seed!',
      name: 'plausibleSheetInfo',
      desc: 'plausible_sheet_info',
      args: [],
    );
  }

  /// `Preferences`
  String get preferences {
    return Intl.message(
      'Preferences',
      name: 'preferences',
      desc: 'settings_preferences_header',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: 'settings_privacy_policy',
      args: [],
    );
  }

  /// `Free NANO`
  String get promotionalLink {
    return Intl.message(
      'Free NANO',
      name: 'promotionalLink',
      desc: 'promo_Link',
      args: [],
    );
  }

  /// `Purchase Nano`
  String get purchaseNano {
    return Intl.message(
      'Purchase Nano',
      name: 'purchaseNano',
      desc: 'purchase_nano',
      args: [],
    );
  }

  /// `QR code does not contain a valid destination`
  String get qrInvalidAddress {
    return Intl.message(
      'QR code does not contain a valid destination',
      name: 'qrInvalidAddress',
      desc: 'qr_invalid_address',
      args: [],
    );
  }

  /// `Please Grant Camera Permissions to scan QR Codes`
  String get qrInvalidPermissions {
    return Intl.message(
      'Please Grant Camera Permissions to scan QR Codes',
      name: 'qrInvalidPermissions',
      desc: 'User did not grant camera permissions to the app',
      args: [],
    );
  }

  /// `QR code does not contain a valid seed or private key`
  String get qrInvalidSeed {
    return Intl.message(
      'QR code does not contain a valid seed or private key',
      name: 'qrInvalidSeed',
      desc: 'qr_invalid_seed',
      args: [],
    );
  }

  /// `QR does not contain a valid secret phrase`
  String get qrMnemonicError {
    return Intl.message(
      'QR does not contain a valid secret phrase',
      name: 'qrMnemonicError',
      desc: 'When QR does not contain a valid mnemonic phrase',
      args: [],
    );
  }

  /// `Could not Read QR Code`
  String get qrUnknownError {
    return Intl.message(
      'Could not Read QR Code',
      name: 'qrUnknownError',
      desc: 'An unknown error occurred with the QR scanner',
      args: [],
    );
  }

  /// `Rate`
  String get rate {
    return Intl.message(
      'Rate',
      name: 'rate',
      desc: 'rate_app_button',
      args: [],
    );
  }

  /// `Rate the App`
  String get rateTheApp {
    return Intl.message(
      'Rate the App',
      name: 'rateTheApp',
      desc: 'rate_app_header',
      args: [],
    );
  }

  /// `If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn't take more than a minute.`
  String get rateTheAppDescription {
    return Intl.message(
      'If you enjoy the app, consider taking the time to review it,\nIt really helps and it shouldn\'t take more than a minute.',
      name: 'rateTheAppDescription',
      desc: 'rate_app_desc',
      args: [],
    );
  }

  /// `Raw Seed`
  String get rawSeed {
    return Intl.message(
      'Raw Seed',
      name: 'rawSeed',
      desc: 'raw_seed',
      args: [],
    );
  }

  /// `Read More`
  String get readMore {
    return Intl.message(
      'Read More',
      name: 'readMore',
      desc: 'read_more',
      args: [],
    );
  }

  /// `receivable`
  String get receivable {
    return Intl.message(
      'receivable',
      name: 'receivable',
      desc: 'history_receivable',
      args: [],
    );
  }

  /// `Receive`
  String get receive {
    return Intl.message(
      'Receive',
      name: 'receive',
      desc: 'home_receive_cta',
      args: [],
    );
  }

  /// `Received`
  String get received {
    return Intl.message(
      'Received',
      name: 'received',
      desc: 'history_received',
      args: [],
    );
  }

  /// `Receive Minimum`
  String get receiveMinimum {
    return Intl.message(
      'Receive Minimum',
      name: 'receiveMinimum',
      desc: 'receive_minimum',
      args: [],
    );
  }

  /// `Receive Minimum Info`
  String get receiveMinimumHeader {
    return Intl.message(
      'Receive Minimum Info',
      name: 'receiveMinimumHeader',
      desc: 'receive_minimum_header',
      args: [],
    );
  }

  /// `A minimum amount to receive. If a payment or request is received with an amount less than this, it will be ignored.`
  String get receiveMinimumInfo {
    return Intl.message(
      'A minimum amount to receive. If a payment or request is received with an amount less than this, it will be ignored.',
      name: 'receiveMinimumInfo',
      desc: 'receive_minimum_info',
      args: [],
    );
  }

  /// `Refund`
  String get refund {
    return Intl.message(
      'Refund',
      name: 'refund',
      desc: 'refund',
      args: [],
    );
  }

  /// `Register`
  String get registerButton {
    return Intl.message(
      'Register',
      name: 'registerButton',
      desc: 'register_button',
      args: [],
    );
  }

  /// `for`
  String get registerFor {
    return Intl.message(
      'for',
      name: 'registerFor',
      desc: 'register_for',
      args: [],
    );
  }

  /// `Registering`
  String get registering {
    return Intl.message(
      'Registering',
      name: 'registering',
      desc: 'register_registering',
      args: [],
    );
  }

  /// `Register Username`
  String get registerUsername {
    return Intl.message(
      'Register Username',
      name: 'registerUsername',
      desc: 'register_username',
      args: [],
    );
  }

  /// `Register a Username`
  String get registerUsernameHeader {
    return Intl.message(
      'Register a Username',
      name: 'registerUsernameHeader',
      desc: 'register_username_header',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: 'accounts_remove_slide',
      args: [],
    );
  }

  /// `Are you sure you want to hide this account? You can re-add it later by tapping the "%1" button.`
  String get removeAccountText {
    return Intl.message(
      'Are you sure you want to hide this account? You can re-add it later by tapping the "%1" button.',
      name: 'removeAccountText',
      desc: 'Remove account dialog body',
      args: [],
    );
  }

  /// `Unblock`
  String get removeBlocked {
    return Intl.message(
      'Unblock',
      name: 'removeBlocked',
      desc: 'blocked_remove_btn',
      args: [],
    );
  }

  /// `Are you sure you want to unblock %1?`
  String get removeBlockedConfirmation {
    return Intl.message(
      'Are you sure you want to unblock %1?',
      name: 'removeBlockedConfirmation',
      desc: 'blocked_remove_sure',
      args: [],
    );
  }

  /// `Remove Contact`
  String get removeContact {
    return Intl.message(
      'Remove Contact',
      name: 'removeContact',
      desc: 'contact_remove_btn',
      args: [],
    );
  }

  /// `Are you sure you want to delete %1?`
  String get removeContactConfirmation {
    return Intl.message(
      'Are you sure you want to delete %1?',
      name: 'removeContactConfirmation',
      desc: 'contact_remove_sure',
      args: [],
    );
  }

  /// `Remove Favorite`
  String get removeFavorite {
    return Intl.message(
      'Remove Favorite',
      name: 'removeFavorite',
      desc: 'favorite_remove_btn',
      args: [],
    );
  }

  /// `Are you sure you want to delete %1?`
  String get removeFavoriteConfirmation {
    return Intl.message(
      'Are you sure you want to delete %1?',
      name: 'removeFavoriteConfirmation',
      desc: 'favorite_remove_sure',
      args: [],
    );
  }

  /// `A representative is an account that votes for network consensus. Voting power is weighted by balance, you may delegate your balance to increase the voting weight of a representative you trust. Your representative does not have spending power over your funds. You should choose a representative that has little downtime and is trustworthy.`
  String get repInfo {
    return Intl.message(
      'A representative is an account that votes for network consensus. Voting power is weighted by balance, you may delegate your balance to increase the voting weight of a representative you trust. Your representative does not have spending power over your funds. You should choose a representative that has little downtime and is trustworthy.',
      name: 'repInfo',
      desc: 'change_representative_info',
      args: [],
    );
  }

  /// `What is a representative?`
  String get repInfoHeader {
    return Intl.message(
      'What is a representative?',
      name: 'repInfoHeader',
      desc: 'change_representative_info_header',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: 'home_reply_slidable',
      args: [],
    );
  }

  /// `Representatives`
  String get representatives {
    return Intl.message(
      'Representatives',
      name: 'representatives',
      desc: 'representatives',
      args: [],
    );
  }

  /// `Request`
  String get request {
    return Intl.message(
      'Request',
      name: 'request',
      desc: 'home_request_cta',
      args: [],
    );
  }

  /// `Request %1 %2`
  String get requestAmountConfirm {
    return Intl.message(
      'Request %1 %2',
      name: 'requestAmountConfirm',
      desc: 'request_pin_description',
      args: [],
    );
  }

  /// `Requested`
  String get requested {
    return Intl.message(
      'Requested',
      name: 'requested',
      desc: 'home_requested_cta',
      args: [],
    );
  }

  /// `Requested From`
  String get requestedFrom {
    return Intl.message(
      'Requested From',
      name: 'requestedFrom',
      desc: 'requested_from',
      args: [],
    );
  }

  /// `Request Failed: This user doesn't appear to have Nautilus installed, or has notifications disabled.`
  String get requestError {
    return Intl.message(
      'Request Failed: This user doesn\'t appear to have Nautilus installed, or has notifications disabled.',
      name: 'requestError',
      desc: 'request_generic_error',
      args: [],
    );
  }

  /// `Request From`
  String get requestFrom {
    return Intl.message(
      'Request From',
      name: 'requestFrom',
      desc: 'request_title',
      args: [],
    );
  }

  /// `Requesting`
  String get requesting {
    return Intl.message(
      'Requesting',
      name: 'requesting',
      desc: 'request_requesting',
      args: [],
    );
  }

  /// `Request Payment`
  String get requestPayment {
    return Intl.message(
      'Request Payment',
      name: 'requestPayment',
      desc: 'request_payment_cta',
      args: [],
    );
  }

  /// `Error sending payment request, the recipient's device may be offline or unavailable.`
  String get requestSendError {
    return Intl.message(
      'Error sending payment request, the recipient\'s device may be offline or unavailable.',
      name: 'requestSendError',
      desc: 'request_send_error',
      args: [],
    );
  }

  /// `Request re-sent! If still unread, the recipient's device may be offline.`
  String get requestSentButNotReceived {
    return Intl.message(
      'Request re-sent! If still unread, the recipient\'s device may be offline.',
      name: 'requestSentButNotReceived',
      desc: 'request_sent_again',
      args: [],
    );
  }

  /// `Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other nautilus users, but you can use them for your own record keeping even if the recipient doesn't use nautilus.`
  String get requestSheetInfo {
    return Intl.message(
      'Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other nautilus users, but you can use them for your own record keeping even if the recipient doesn\'t use nautilus.',
      name: 'requestSheetInfo',
      desc: 'request_sheet_info',
      args: [],
    );
  }

  /// `Request Sheet Info`
  String get requestSheetInfoHeader {
    return Intl.message(
      'Request Sheet Info',
      name: 'requestSheetInfoHeader',
      desc: 'request_sheet_info_header',
      args: [],
    );
  }

  /// `Require a password to open Nautilus?`
  String get requireAPasswordToOpenHeader {
    return Intl.message(
      'Require a password to open Nautilus?',
      name: 'requireAPasswordToOpenHeader',
      desc:
          'A paragraph that asks the users if they would like a password to be required to open Nautilus.',
      args: [],
    );
  }

  /// `Require CAPTCHA to claim gift card`
  String get requireCaptcha {
    return Intl.message(
      'Require CAPTCHA to claim gift card',
      name: 'requireCaptcha',
      desc: 'gift_claim_require_captcha',
      args: [],
    );
  }

  /// `Resend this memo`
  String get resendMemo {
    return Intl.message(
      'Resend this memo',
      name: 'resendMemo',
      desc: 'resend_memo',
      args: [],
    );
  }

  /// `Reset Account`
  String get resetAccountButton {
    return Intl.message(
      'Reset Account',
      name: 'resetAccountButton',
      desc: 'reset_account_button',
      args: [],
    );
  }

  /// `This will make a new account with the password you have just set, the old account won't be deleted unless the passwords chosen are the same.`
  String get resetAccountParagraph {
    return Intl.message(
      'This will make a new account with the password you have just set, the old account won\'t be deleted unless the passwords chosen are the same.',
      name: 'resetAccountParagraph',
      desc: 'reset_account_warning',
      args: [],
    );
  }

  /// `Reset the App`
  String get resetDatabase {
    return Intl.message(
      'Reset the App',
      name: 'resetDatabase',
      desc: 'settings_nuke_db',
      args: [],
    );
  }

  /// `Are you sure? This will delete any gift cards you have created, memos, messages, and contacts will all be erased.\n\nThis will NOT delete your wallet's internal seed, but you should still back it up if you haven't done so already. If you're having issues or encountering a bug, you should report it on the discord server (the link to it is at the bottom of the settings drawer).`
  String get resetDatabaseConfirmation {
    return Intl.message(
      'Are you sure? This will delete any gift cards you have created, memos, messages, and contacts will all be erased.\n\nThis will NOT delete your wallet\'s internal seed, but you should still back it up if you haven\'t done so already. If you\'re having issues or encountering a bug, you should report it on the discord server (the link to it is at the bottom of the settings drawer).',
      name: 'resetDatabaseConfirmation',
      desc: 'database_remove_sure',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: 'home_retry_slide',
      args: [],
    );
  }

  /// `It appears your device is "rooted", "jailbroken", or modified in a way that compromises security. It is recommended that you reset your device to its original state before proceeding.`
  String get rootWarning {
    return Intl.message(
      'It appears your device is "rooted", "jailbroken", or modified in a way that compromises security. It is recommended that you reset your device to its original state before proceeding.',
      name: 'rootWarning',
      desc:
          'Shown to users if they have a rooted Android device or jailbroken iOS device',
      args: [],
    );
  }

  /// `Scan a Nano \naddress QR code`
  String get scanInstructions {
    return Intl.message(
      'Scan a Nano \naddress QR code',
      name: 'scanInstructions',
      desc: 'scan_send_instruction_label',
      args: [],
    );
  }

  /// `Scan NFC`
  String get scanNFC {
    return Intl.message(
      'Scan NFC',
      name: 'scanNFC',
      desc: 'scan_nfc',
      args: [],
    );
  }

  /// `Scan QR Code`
  String get scanQrCode {
    return Intl.message(
      'Scan QR Code',
      name: 'scanQrCode',
      desc: 'send_scan_qr',
      args: [],
    );
  }

  /// `Search for anything`
  String get searchHint {
    return Intl.message(
      'Search for anything',
      name: 'searchHint',
      desc: 'home_search_hint',
      args: [],
    );
  }

  /// `In the next screen, you will see your secret phrase. It is a password to access your funds. It is crucial that you back it up and never share it with anyone.`
  String get secretInfo {
    return Intl.message(
      'In the next screen, you will see your secret phrase. It is a password to access your funds. It is crucial that you back it up and never share it with anyone.',
      name: 'secretInfo',
      desc: 'Description for seed',
      args: [],
    );
  }

  /// `Safety First!`
  String get secretInfoHeader {
    return Intl.message(
      'Safety First!',
      name: 'secretInfoHeader',
      desc: 'secret info header',
      args: [],
    );
  }

  /// `Secret Phrase`
  String get secretPhrase {
    return Intl.message(
      'Secret Phrase',
      name: 'secretPhrase',
      desc: 'Secret (mnemonic) phrase',
      args: [],
    );
  }

  /// `Secret Phrase Copied`
  String get secretPhraseCopied {
    return Intl.message(
      'Secret Phrase Copied',
      name: 'secretPhraseCopied',
      desc: 'Copied secret phrase to clipboard',
      args: [],
    );
  }

  /// `Copy Secret Phrase`
  String get secretPhraseCopy {
    return Intl.message(
      'Copy Secret Phrase',
      name: 'secretPhraseCopy',
      desc: 'Copy secret phrase to clipboard',
      args: [],
    );
  }

  /// `If you lose your device or uninstall the application, you'll need your secret phrase or seed to recover your funds!`
  String get secretWarning {
    return Intl.message(
      'If you lose your device or uninstall the application, you\'ll need your secret phrase or seed to recover your funds!',
      name: 'secretWarning',
      desc: 'Secret warning',
      args: [],
    );
  }

  /// `Security`
  String get securityHeader {
    return Intl.message(
      'Security',
      name: 'securityHeader',
      desc: 'security_header',
      args: [],
    );
  }

  /// `Seed`
  String get seed {
    return Intl.message(
      'Seed',
      name: 'seed',
      desc: 'intro_new_wallet_seed_header',
      args: [],
    );
  }

  /// `Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.`
  String get seedBackupInfo {
    return Intl.message(
      'Below is your wallet\'s seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.',
      name: 'seedBackupInfo',
      desc: 'intro_new_wallet_seed',
      args: [],
    );
  }

  /// `Seed Copied to Clipboard\nIt is pasteable for 2 minutes.`
  String get seedCopied {
    return Intl.message(
      'Seed Copied to Clipboard\nIt is pasteable for 2 minutes.',
      name: 'seedCopied',
      desc: 'intro_new_wallet_seed_copied',
      args: [],
    );
  }

  /// `Seed Copied`
  String get seedCopiedShort {
    return Intl.message(
      'Seed Copied',
      name: 'seedCopiedShort',
      desc: 'seed_copied_btn',
      args: [],
    );
  }

  /// `A seed bears the same information as a secret phrase, but in a machine-readable way. As long as you have one of them backed up, you'll have access to your funds.`
  String get seedDescription {
    return Intl.message(
      'A seed bears the same information as a secret phrase, but in a machine-readable way. As long as you have one of them backed up, you\'ll have access to your funds.',
      name: 'seedDescription',
      desc: 'Describing what a seed is',
      args: [],
    );
  }

  /// `Seed is Invalid`
  String get seedInvalid {
    return Intl.message(
      'Seed is Invalid',
      name: 'seedInvalid',
      desc: 'intro_seed_invalid',
      args: [],
    );
  }

  /// `Can't request from self`
  String get selfSendError {
    return Intl.message(
      'Can\'t request from self',
      name: 'selfSendError',
      desc: 'self_send_error',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: 'home_send_cta',
      args: [],
    );
  }

  /// `Send %1 %2`
  String get sendAmountConfirm {
    return Intl.message(
      'Send %1 %2',
      name: 'sendAmountConfirm',
      desc: 'send_amount_confirm',
      args: [],
    );
  }

  /// `Send Amounts`
  String get sendAmounts {
    return Intl.message(
      'Send Amounts',
      name: 'sendAmounts',
      desc: 'split_bill_send_amounts',
      args: [],
    );
  }

  /// `An error occurred. Try again later.`
  String get sendError {
    return Intl.message(
      'An error occurred. Try again later.',
      name: 'sendError',
      desc: 'send_generic_error',
      args: [],
    );
  }

  /// `Send From`
  String get sendFrom {
    return Intl.message(
      'Send From',
      name: 'sendFrom',
      desc: 'send_title',
      args: [],
    );
  }

  /// `Sending`
  String get sending {
    return Intl.message(
      'Sending',
      name: 'sending',
      desc: 'send_sending',
      args: [],
    );
  }

  /// `Sending memo with transaction failed, they may not be a Nautilus user.`
  String get sendMemoError {
    return Intl.message(
      'Sending memo with transaction failed, they may not be a Nautilus user.',
      name: 'sendMemoError',
      desc: 'send_memo_error',
      args: [],
    );
  }

  /// `Sending message`
  String get sendMessageConfirm {
    return Intl.message(
      'Sending message',
      name: 'sendMessageConfirm',
      desc: 'send_message_description',
      args: [],
    );
  }

  /// `Send Request again`
  String get sendRequestAgain {
    return Intl.message(
      'Send Request again',
      name: 'sendRequestAgain',
      desc: 'request_again',
      args: [],
    );
  }

  /// `Send Requests`
  String get sendRequests {
    return Intl.message(
      'Send Requests',
      name: 'sendRequests',
      desc: 'split_bill_send_requests',
      args: [],
    );
  }

  /// `Send or Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other nautilus users.\n\nYou don't need to have a username in order to send or receive payment requests, and you can use them for your own record keeping even if they don't use nautilus.`
  String get sendSheetInfo {
    return Intl.message(
      'Send or Request a payment, with End to End Encrypted messages!\n\nPayment requests, memos, and messages will only be receivable by other nautilus users.\n\nYou don\'t need to have a username in order to send or receive payment requests, and you can use them for your own record keeping even if they don\'t use nautilus.',
      name: 'sendSheetInfo',
      desc: 'send_sheet_info',
      args: [],
    );
  }

  /// `Send Sheet Info`
  String get sendSheetInfoHeader {
    return Intl.message(
      'Send Sheet Info',
      name: 'sendSheetInfoHeader',
      desc: 'send_sheet_info_header',
      args: [],
    );
  }

  /// `Sent`
  String get sent {
    return Intl.message(
      'Sent',
      name: 'sent',
      desc: 'history_sent',
      args: [],
    );
  }

  /// `Sent To`
  String get sentTo {
    return Intl.message(
      'Sent To',
      name: 'sentTo',
      desc: 'sent_to',
      args: [],
    );
  }

  /// `Set`
  String get set {
    return Intl.message(
      'Set',
      name: 'set',
      desc: 'dialog_set',
      args: [],
    );
  }

  /// `Set Password`
  String get setPassword {
    return Intl.message(
      'Set Password',
      name: 'setPassword',
      desc: 'A button that sets the wallet password',
      args: [],
    );
  }

  /// `Password has been set successfully`
  String get setPasswordSuccess {
    return Intl.message(
      'Password has been set successfully',
      name: 'setPasswordSuccess',
      desc: 'Setting a Wallet Password was successful',
      args: [],
    );
  }

  /// `Set Pin`
  String get setPin {
    return Intl.message(
      'Set Pin',
      name: 'setPin',
      desc: 'A button that sets the plausible deniability password',
      args: [],
    );
  }

  /// `Set or change your existing PIN. If you haven't set a PIN yet, the default PIN is 000000.`
  String get setPinParagraph {
    return Intl.message(
      'Set or change your existing PIN. If you haven\'t set a PIN yet, the default PIN is 000000.',
      name: 'setPinParagraph',
      desc:
          'A paragraph that explains the user can set or change their existing pin.',
      args: [],
    );
  }

  /// `Pin has been set successfully`
  String get setPinSuccess {
    return Intl.message(
      'Pin has been set successfully',
      name: 'setPinSuccess',
      desc: 'Setting a Wallet Pin was successful',
      args: [],
    );
  }

  /// `Set Plausible Pin`
  String get setPlausibleDeniabilityPin {
    return Intl.message(
      'Set Plausible Pin',
      name: 'setPlausibleDeniabilityPin',
      desc: 'Allows user to setup a plausible deniability pin',
      args: [],
    );
  }

  /// `Set Restore Height`
  String get setRestoreHeight {
    return Intl.message(
      'Set Restore Height',
      name: 'setRestoreHeight',
      desc: 'set_restore_height',
      args: [],
    );
  }

  /// `Settings`
  String get settingsHeader {
    return Intl.message(
      'Settings',
      name: 'settingsHeader',
      desc: 'settings_title',
      args: [],
    );
  }

  /// `Load from Paper Wallet`
  String get settingsTransfer {
    return Intl.message(
      'Load from Paper Wallet',
      name: 'settingsTransfer',
      desc: 'settings_transfer',
      args: [],
    );
  }

  /// `Set Wallet Password`
  String get setWalletPassword {
    return Intl.message(
      'Set Wallet Password',
      name: 'setWalletPassword',
      desc: 'Allows user to encrypt wallet with a password',
      args: [],
    );
  }

  /// `Set Wallet Pin`
  String get setWalletPin {
    return Intl.message(
      'Set Wallet Pin',
      name: 'setWalletPin',
      desc: 'Allows user to encrypt wallet with a pin',
      args: [],
    );
  }

  /// ``
  String get setWalletPlausiblePin {
    return Intl.message(
      '',
      name: 'setWalletPlausiblePin',
      desc: 'Allows user to setup a plausible deniability pin',
      args: [],
    );
  }

  /// `Set XMR Restore Height`
  String get setXMRRestoreHeight {
    return Intl.message(
      'Set XMR Restore Height',
      name: 'setXMRRestoreHeight',
      desc: 'set_xmr_restore_height',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: 'nautilus_share',
      args: [],
    );
  }

  /// `Share Link`
  String get shareLink {
    return Intl.message(
      'Share Link',
      name: 'shareLink',
      desc: 'share_link',
      args: [],
    );
  }

  /// `Share Message`
  String get shareMessage {
    return Intl.message(
      'Share Message',
      name: 'shareMessage',
      desc: 'share_message',
      args: [],
    );
  }

  /// `Share Nautilus`
  String get shareNautilus {
    return Intl.message(
      'Share Nautilus',
      name: 'shareNautilus',
      desc: 'settings_share',
      args: [],
    );
  }

  /// `Check out Nautilus! A premier NANO mobile wallet!`
  String get shareNautilusText {
    return Intl.message(
      'Check out Nautilus! A premier NANO mobile wallet!',
      name: 'shareNautilusText',
      desc: 'share_extra',
      args: [],
    );
  }

  /// `Share Text`
  String get shareText {
    return Intl.message(
      'Share Text',
      name: 'shareText',
      desc: 'settings_share_text',
      args: [],
    );
  }

  /// `Shop`
  String get shopButton {
    return Intl.message(
      'Shop',
      name: 'shopButton',
      desc: 'shop_button',
      args: [],
    );
  }

  /// `Show`
  String get show {
    return Intl.message(
      'Show',
      name: 'show',
      desc: 'funding_show',
      args: [],
    );
  }

  /// `Account Info`
  String get showAccountInfo {
    return Intl.message(
      'Account Info',
      name: 'showAccountInfo',
      desc: 'show_account_info',
      args: [],
    );
  }

  /// `Show Account QR Code`
  String get showAccountQR {
    return Intl.message(
      'Show Account QR Code',
      name: 'showAccountQR',
      desc: 'show_account_qr',
      args: [],
    );
  }

  /// `Show Contacts`
  String get showContacts {
    return Intl.message(
      'Show Contacts',
      name: 'showContacts',
      desc: 'contacts_enabled',
      args: [],
    );
  }

  /// `Show Funding Banner`
  String get showFunding {
    return Intl.message(
      'Show Funding Banner',
      name: 'showFunding',
      desc: 'show_funding_banner',
      args: [],
    );
  }

  /// `Show Link Options`
  String get showLinkOptions {
    return Intl.message(
      'Show Link Options',
      name: 'showLinkOptions',
      desc: 'show_link_options',
      args: [],
    );
  }

  /// `Show Link QR`
  String get showLinkQR {
    return Intl.message(
      'Show Link QR',
      name: 'showLinkQR',
      desc: 'show_link_qr',
      args: [],
    );
  }

  /// `Show Monero`
  String get showMoneroHeader {
    return Intl.message(
      'Show Monero',
      name: 'showMoneroHeader',
      desc: 'show_monero_header',
      args: [],
    );
  }

  /// `Enable Monero Section`
  String get showMoneroInfo {
    return Intl.message(
      'Enable Monero Section',
      name: 'showMoneroInfo',
      desc: 'show_monero_info',
      args: [],
    );
  }

  /// `Show QR Code`
  String get showQR {
    return Intl.message(
      'Show QR Code',
      name: 'showQR',
      desc: 'show_qr',
      args: [],
    );
  }

  /// `Unopened Warning`
  String get showUnopenedWarning {
    return Intl.message(
      'Unopened Warning',
      name: 'showUnopenedWarning',
      desc: 'warn_unsafe_send',
      args: [],
    );
  }

  /// `Simplex`
  String get simplex {
    return Intl.message(
      'Simplex',
      name: 'simplex',
      desc: 'simplex_ramp',
      args: [],
    );
  }

  /// `Social`
  String get social {
    return Intl.message(
      'Social',
      name: 'social',
      desc: 'share_social',
      args: [],
    );
  }

  /// `someone`
  String get someone {
    return Intl.message(
      'someone',
      name: 'someone',
      desc: 'send_someone',
      args: [],
    );
  }

  /// `Spend NANO`
  String get spendNano {
    return Intl.message(
      'Spend NANO',
      name: 'spendNano',
      desc: 'spend_nano',
      args: [],
    );
  }

  /// `Split Bill`
  String get splitBill {
    return Intl.message(
      'Split Bill',
      name: 'splitBill',
      desc: 'show_split_bill',
      args: [],
    );
  }

  /// `Split A Bill`
  String get splitBillHeader {
    return Intl.message(
      'Split A Bill',
      name: 'splitBillHeader',
      desc: 'show_split_bill_header',
      args: [],
    );
  }

  /// `Send a bunch of payment requests at once! Makes it easy it split a bill at a restaurant for example.`
  String get splitBillInfo {
    return Intl.message(
      'Send a bunch of payment requests at once! Makes it easy it split a bill at a restaurant for example.',
      name: 'splitBillInfo',
      desc: 'split_bill_info',
      args: [],
    );
  }

  /// `Split Bill Info`
  String get splitBillInfoHeader {
    return Intl.message(
      'Split Bill Info',
      name: 'splitBillInfoHeader',
      desc: 'split_bill_info_header',
      args: [],
    );
  }

  /// `Split By`
  String get splitBy {
    return Intl.message(
      'Split By',
      name: 'splitBy',
      desc: 'gift_card_split_by',
      args: [],
    );
  }

  /// `Support`
  String get supportButton {
    return Intl.message(
      'Support',
      name: 'supportButton',
      desc: 'A button to open up the live support window',
      args: [],
    );
  }

  /// `Help Support Development`
  String get supportDevelopment {
    return Intl.message(
      'Help Support Development',
      name: 'supportDevelopment',
      desc: 'settings_support_development',
      args: [],
    );
  }

  /// `Support the Developer`
  String get supportTheDeveloper {
    return Intl.message(
      'Support the Developer',
      name: 'supportTheDeveloper',
      desc: 'change_log_support',
      args: [],
    );
  }

  /// `Swapping`
  String get swapping {
    return Intl.message(
      'Swapping',
      name: 'swapping',
      desc: 'swapping_xmr',
      args: [],
    );
  }

  /// `Swap XMR`
  String get swapXMR {
    return Intl.message(
      'Swap XMR',
      name: 'swapXMR',
      desc: 'swap_xmr',
      args: [],
    );
  }

  /// `Swap Monero`
  String get swapXMRHeader {
    return Intl.message(
      'Swap Monero',
      name: 'swapXMRHeader',
      desc: 'swap_xmr_header',
      args: [],
    );
  }

  /// `Monero is a privacy-focused cryptocurrency that makes it very hard or even impossible to trace transactions. Meanwhile NANO is a payments-focused cryptocurrency that is fast and fee-less. Together they provide some of the most useful aspects of cryptocurrencies!\n\nUse this page to easily swap your NANO for XMR!`
  String get swapXMRInfo {
    return Intl.message(
      'Monero is a privacy-focused cryptocurrency that makes it very hard or even impossible to trace transactions. Meanwhile NANO is a payments-focused cryptocurrency that is fast and fee-less. Together they provide some of the most useful aspects of cryptocurrencies!\n\nUse this page to easily swap your NANO for XMR!',
      name: 'swapXMRInfo',
      desc: 'swap_xmr_header',
      args: [],
    );
  }

  /// `Switch to Seed`
  String get switchToSeed {
    return Intl.message(
      'Switch to Seed',
      name: 'switchToSeed',
      desc: 'switchToSeed',
      args: [],
    );
  }

  /// `System Default`
  String get systemDefault {
    return Intl.message(
      'System Default',
      name: 'systemDefault',
      desc: 'settings_default_language_string',
      args: [],
    );
  }

  /// `Tap message to edit`
  String get tapMessageToEdit {
    return Intl.message(
      'Tap message to edit',
      name: 'tapMessageToEdit',
      desc: 'gift_creation_message_edit_hint',
      args: [],
    );
  }

  /// `Tap to hide`
  String get tapToHide {
    return Intl.message(
      'Tap to hide',
      name: 'tapToHide',
      desc: 'Tap to hide content',
      args: [],
    );
  }

  /// `Tap to reveal`
  String get tapToReveal {
    return Intl.message(
      'Tap to reveal',
      name: 'tapToReveal',
      desc: 'Tap to reveal hidden content',
      args: [],
    );
  }

  /// `Theme`
  String get themeHeader {
    return Intl.message(
      'Theme',
      name: 'themeHeader',
      desc: 'theme_header',
      args: [],
    );
  }

  /// `this may take a while...`
  String get thisMayTakeSomeTime {
    return Intl.message(
      'this may take a while...',
      name: 'thisMayTakeSomeTime',
      desc: 'xmr_loading_takes_time',
      args: [],
    );
  }

  /// `To`
  String get to {
    return Intl.message(
      'To',
      name: 'to',
      desc: 'send_to',
      args: [],
    );
  }

  /// `Too many failed unlock attempts.`
  String get tooManyFailedAttempts {
    return Intl.message(
      'Too many failed unlock attempts.',
      name: 'tooManyFailedAttempts',
      desc: 'fail_toomany_attempts',
      args: [],
    );
  }

  /// `Tracking Authorization`
  String get trackingHeader {
    return Intl.message(
      'Tracking Authorization',
      name: 'trackingHeader',
      desc: 'prompt_ask_tracking_header',
      args: [],
    );
  }

  /// `Tracking Disabled`
  String get trackingWarning {
    return Intl.message(
      'Tracking Disabled',
      name: 'trackingWarning',
      desc: 'home_tracking_warning',
      args: [],
    );
  }

  /// `Gift Card functionality may be reduced or not work at all if tracking is disabled. We use this permission EXCLUSIVELY for this feature. Absolutely none of your data is sold, collected or tracked on the backend for any purpose beyond necessary`
  String get trackingWarningBodyLong {
    return Intl.message(
      'Gift Card functionality may be reduced or not work at all if tracking is disabled. We use this permission EXCLUSIVELY for this feature. Absolutely none of your data is sold, collected or tracked on the backend for any purpose beyond necessary',
      name: 'trackingWarningBodyLong',
      desc: 'tracking_warning_body_long',
      args: [],
    );
  }

  /// `Gift Card Links will not function properly`
  String get trackingWarningBodyShort {
    return Intl.message(
      'Gift Card Links will not function properly',
      name: 'trackingWarningBodyShort',
      desc: 'tracking_warning_body_short',
      args: [],
    );
  }

  /// `Transactions`
  String get transactions {
    return Intl.message(
      'Transactions',
      name: 'transactions',
      desc: 'transaction_header',
      args: [],
    );
  }

  /// `Transfer`
  String get transfer {
    return Intl.message(
      'Transfer',
      name: 'transfer',
      desc: 'transfer_btn',
      args: [],
    );
  }

  /// `Tap anywhere to close the window.`
  String get transferClose {
    return Intl.message(
      'Tap anywhere to close the window.',
      name: 'transferClose',
      desc: 'transfer_close_text',
      args: [],
    );
  }

  /// `%1 %2 successfully transferred to your Nautilus Wallet.\n`
  String get transferComplete {
    return Intl.message(
      '%1 %2 successfully transferred to your Nautilus Wallet.\n',
      name: 'transferComplete',
      desc: 'transfer_complete_text',
      args: [],
    );
  }

  /// `A wallet with a balance of %1 NANO has been detected.\n`
  String get transferConfirmInfo {
    return Intl.message(
      'A wallet with a balance of %1 NANO has been detected.\n',
      name: 'transferConfirmInfo',
      desc: 'transfer_confirm_info_first',
      args: [],
    );
  }

  /// `Tap confirm to transfer the funds.\n`
  String get transferConfirmInfoSecond {
    return Intl.message(
      'Tap confirm to transfer the funds.\n',
      name: 'transferConfirmInfoSecond',
      desc: 'transfer_confirm_info_second',
      args: [],
    );
  }

  /// `Transfer may take several seconds to complete.`
  String get transferConfirmInfoThird {
    return Intl.message(
      'Transfer may take several seconds to complete.',
      name: 'transferConfirmInfoThird',
      desc: 'transfer_confirm_info_third',
      args: [],
    );
  }

  /// `An error has occurred during the transfer. Please try again later.`
  String get transferError {
    return Intl.message(
      'An error has occurred during the transfer. Please try again later.',
      name: 'transferError',
      desc: 'transfer_error',
      args: [],
    );
  }

  /// `Transfer Funds`
  String get transferHeader {
    return Intl.message(
      'Transfer Funds',
      name: 'transferHeader',
      desc: 'transfer_header',
      args: [],
    );
  }

  /// `This process will transfer the funds from a paper wallet to your Nautilus wallet.\n\nTap the "%1" button to start.`
  String get transferIntro {
    return Intl.message(
      'This process will transfer the funds from a paper wallet to your Nautilus wallet.\n\nTap the "%1" button to start.',
      name: 'transferIntro',
      desc: 'transfer_intro',
      args: [],
    );
  }

  /// `This process will transfer the funds from a paper wallet to your Nautilus wallet.`
  String get transferIntroShort {
    return Intl.message(
      'This process will transfer the funds from a paper wallet to your Nautilus wallet.',
      name: 'transferIntroShort',
      desc: 'transfer_intro_short',
      args: [],
    );
  }

  /// `Transferring`
  String get transferLoading {
    return Intl.message(
      'Transferring',
      name: 'transferLoading',
      desc: 'transfer_loading_text',
      args: [],
    );
  }

  /// `Please enter the seed below.`
  String get transferManualHint {
    return Intl.message(
      'Please enter the seed below.',
      name: 'transferManualHint',
      desc: 'transfer_hint',
      args: [],
    );
  }

  /// `This seed does not have any NANO on it`
  String get transferNoFunds {
    return Intl.message(
      'This seed does not have any NANO on it',
      name: 'transferNoFunds',
      desc: 'transfer_no_funds_toast',
      args: [],
    );
  }

  /// `This QR code does not contain a valid seed.`
  String get transferQrScanError {
    return Intl.message(
      'This QR code does not contain a valid seed.',
      name: 'transferQrScanError',
      desc: 'transfer_qr_scan_error',
      args: [],
    );
  }

  /// `Scan a Nano \nseed or private key`
  String get transferQrScanHint {
    return Intl.message(
      'Scan a Nano \nseed or private key',
      name: 'transferQrScanHint',
      desc: 'transfer_qr_scan_hint',
      args: [],
    );
  }

  /// `unacknowledged`
  String get unacknowledged {
    return Intl.message(
      'unacknowledged',
      name: 'unacknowledged',
      desc: 'history_unacknowledged',
      args: [],
    );
  }

  /// `unconfirmed`
  String get unconfirmed {
    return Intl.message(
      'unconfirmed',
      name: 'unconfirmed',
      desc: 'history_unconfirmed',
      args: [],
    );
  }

  /// `unfulfilled`
  String get unfulfilled {
    return Intl.message(
      'unfulfilled',
      name: 'unfulfilled',
      desc: 'history_unfulfilled',
      args: [],
    );
  }

  /// `Unlock`
  String get unlock {
    return Intl.message(
      'Unlock',
      name: 'unlock',
      desc: 'unlocktxt',
      args: [],
    );
  }

  /// `Authenticate to Unlock Nautilus`
  String get unlockBiometrics {
    return Intl.message(
      'Authenticate to Unlock Nautilus',
      name: 'unlockBiometrics',
      desc: 'unlock_bio',
      args: [],
    );
  }

  /// `Enter PIN to Unlock Nautilus`
  String get unlockPin {
    return Intl.message(
      'Enter PIN to Unlock Nautilus',
      name: 'unlockPin',
      desc: 'unlock_pin',
      args: [],
    );
  }

  /// `Show Unopened Warning`
  String get unopenedWarningHeader {
    return Intl.message(
      'Show Unopened Warning',
      name: 'unopenedWarningHeader',
      desc: 'unopened_warning_header',
      args: [],
    );
  }

  /// `Show a warning when sending funds to an unopened account, this is useful because most of the time addresses you send to will have a balance, and sending to a new address may be the result of a typo.`
  String get unopenedWarningInfo {
    return Intl.message(
      'Show a warning when sending funds to an unopened account, this is useful because most of the time addresses you send to will have a balance, and sending to a new address may be the result of a typo.',
      name: 'unopenedWarningInfo',
      desc: 'unopened_warning_info',
      args: [],
    );
  }

  /// `Are you sure this is the right address?\nThis account appears to be unopened\n\nYou can disable this warning in the settings drawer under "Unopened Warning"`
  String get unopenedWarningWarning {
    return Intl.message(
      'Are you sure this is the right address?\nThis account appears to be unopened\n\nYou can disable this warning in the settings drawer under "Unopened Warning"',
      name: 'unopenedWarningWarning',
      desc: 'unopened_warning_warning',
      args: [],
    );
  }

  /// `Account Unopened`
  String get unopenedWarningWarningHeader {
    return Intl.message(
      'Account Unopened',
      name: 'unopenedWarningWarningHeader',
      desc: 'unopened_warning_warning_header',
      args: [],
    );
  }

  /// `unpaid`
  String get unpaid {
    return Intl.message(
      'unpaid',
      name: 'unpaid',
      desc: 'history_unpaid',
      args: [],
    );
  }

  /// `unread`
  String get unread {
    return Intl.message(
      'unread',
      name: 'unread',
      desc: 'history_unread',
      args: [],
    );
  }

  /// `Uptime`
  String get uptime {
    return Intl.message(
      'Uptime',
      name: 'uptime',
      desc: 'Rep uptime',
      args: [],
    );
  }

  /// `Use NANO`
  String get useNano {
    return Intl.message(
      'Use NANO',
      name: 'useNano',
      desc: 'use_nano',
      args: [],
    );
  }

  /// `Use Nautilus Rep`
  String get useNautilusRep {
    return Intl.message(
      'Use Nautilus Rep',
      name: 'useNautilusRep',
      desc: 'use nautilus node as rep',
      args: [],
    );
  }

  /// `User already added!`
  String get userAlreadyAddedError {
    return Intl.message(
      'User already added!',
      name: 'userAlreadyAddedError',
      desc: 'split_bill_duplicate_error',
      args: [],
    );
  }

  /// `You already have a username registered! It's not currently possible to change your username, but you're free to register a new one under a different address.`
  String get usernameAlreadyRegistered {
    return Intl.message(
      'You already have a username registered! It\'s not currently possible to change your username, but you\'re free to register a new one under a different address.',
      name: 'usernameAlreadyRegistered',
      desc: 'Description for username already registered',
      args: [],
    );
  }

  /// `Username available!`
  String get usernameAvailable {
    return Intl.message(
      'Username available!',
      name: 'usernameAvailable',
      desc: 'username_available',
      args: [],
    );
  }

  /// `Please enter a Username`
  String get usernameEmpty {
    return Intl.message(
      'Please enter a Username',
      name: 'usernameEmpty',
      desc: 'username_empty',
      args: [],
    );
  }

  /// `Username Error`
  String get usernameError {
    return Intl.message(
      'Username Error',
      name: 'usernameError',
      desc: 'username_unknown_error',
      args: [],
    );
  }

  /// `Pick out a unique @username to make it easy for friends and family to find you!\n\nHaving a Nautilus username updates the UI globally to reflect your new handle.`
  String get usernameInfo {
    return Intl.message(
      'Pick out a unique @username to make it easy for friends and family to find you!\n\nHaving a Nautilus username updates the UI globally to reflect your new handle.',
      name: 'usernameInfo',
      desc: 'Description for username registration',
      args: [],
    );
  }

  /// `Invalid Username`
  String get usernameInvalid {
    return Intl.message(
      'Invalid Username',
      name: 'usernameInvalid',
      desc: 'username_invalid_name',
      args: [],
    );
  }

  /// `Username unavailable`
  String get usernameUnavailable {
    return Intl.message(
      'Username unavailable',
      name: 'usernameUnavailable',
      desc: 'username_unavailable',
      args: [],
    );
  }

  /// `Nautilus usernames are a centralized service provided by Nano.to`
  String get usernameWarning {
    return Intl.message(
      'Nautilus usernames are a centralized service provided by Nano.to',
      name: 'usernameWarning',
      desc: 'Username centralization warning',
      args: [],
    );
  }

  /// `User not found!`
  String get userNotFound {
    return Intl.message(
      'User not found!',
      name: 'userNotFound',
      desc: 'user_not_found',
      args: [],
    );
  }

  /// `Using`
  String get using {
    return Intl.message(
      'Using',
      name: 'using',
      desc: 'gift_message_using',
      args: [],
    );
  }

  /// `View Details`
  String get viewDetails {
    return Intl.message(
      'View Details',
      name: 'viewDetails',
      desc: 'transaction_details',
      args: [],
    );
  }

  /// `View Transaction`
  String get viewTX {
    return Intl.message(
      'View Transaction',
      name: 'viewTX',
      desc: 'transaction_transaction',
      args: [],
    );
  }

  /// `Voting Weight`
  String get votingWeight {
    return Intl.message(
      'Voting Weight',
      name: 'votingWeight',
      desc: 'Representative Voting Weight',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: 'settings_logout_alert_title',
      args: [],
    );
  }

  /// `Account already added!`
  String get watchAccountExists {
    return Intl.message(
      'Account already added!',
      name: 'watchAccountExists',
      desc: 'account_entry_exists',
      args: [],
    );
  }

  /// `Watch Only Account`
  String get watchOnlyAccount {
    return Intl.message(
      'Watch Only Account',
      name: 'watchOnlyAccount',
      desc: 'watch_only_account',
      args: [],
    );
  }

  /// `Sends are disabled on watch only addresses`
  String get watchOnlySendDisabled {
    return Intl.message(
      'Sends are disabled on watch only addresses',
      name: 'watchOnlySendDisabled',
      desc: 'watch_only_send_disabled',
      args: [],
    );
  }

  /// `A week ago`
  String get weekAgo {
    return Intl.message(
      'A week ago',
      name: 'weekAgo',
      desc: 'history_week_ago',
      args: [],
    );
  }

  /// ``
  String get welcomeText {
    return Intl.message(
      '',
      name: 'welcomeText',
      desc: 'intro_welcome_title',
      args: [],
    );
  }

  /// `Welcome to Nautilus. Choose an option to get started or pick a theme using the icon below.`
  String get welcomeTextLogin {
    return Intl.message(
      'Welcome to Nautilus. Choose an option to get started or pick a theme using the icon below.',
      name: 'welcomeTextLogin',
      desc: 'intro_welcome_login',
      args: [],
    );
  }

  /// `Welcome to Nautilus. To start, create a new wallet or import an existing one.`
  String get welcomeTextUpdated {
    return Intl.message(
      'Welcome to Nautilus. To start, create a new wallet or import an existing one.',
      name: 'welcomeTextUpdated',
      desc: 'intro_welcome_title',
      args: [],
    );
  }

  /// `To start, create a new wallet or import an existing one.`
  String get welcomeTextWithoutLogin {
    return Intl.message(
      'To start, create a new wallet or import an existing one.',
      name: 'welcomeTextWithoutLogin',
      desc: 'intro_welcome_no_login',
      args: [],
    );
  }

  /// `With Address`
  String get withAddress {
    return Intl.message(
      'With Address',
      name: 'withAddress',
      desc: 'with_address',
      args: [],
    );
  }

  /// `With Fee`
  String get withFee {
    return Intl.message(
      'With Fee',
      name: 'withFee',
      desc: 'with_fee',
      args: [],
    );
  }

  /// `With Message`
  String get withMessage {
    return Intl.message(
      'With Message',
      name: 'withMessage',
      desc: 'with_message',
      args: [],
    );
  }

  /// `After %1 minute`
  String get xMinute {
    return Intl.message(
      'After %1 minute',
      name: 'xMinute',
      desc: 'after_minute',
      args: [],
    );
  }

  /// `After %1 minutes`
  String get xMinutes {
    return Intl.message(
      'After %1 minutes',
      name: 'xMinutes',
      desc: 'after_minutes',
      args: [],
    );
  }

  /// `Connecting`
  String get xmrStatusConnecting {
    return Intl.message(
      'Connecting',
      name: 'xmrStatusConnecting',
      desc: 'xmr_connecting_status',
      args: [],
    );
  }

  /// `Error`
  String get xmrStatusError {
    return Intl.message(
      'Error',
      name: 'xmrStatusError',
      desc: 'xmr_error_status',
      args: [],
    );
  }

  /// `Loading`
  String get xmrStatusLoading {
    return Intl.message(
      'Loading',
      name: 'xmrStatusLoading',
      desc: 'xmr_loading_status',
      args: [],
    );
  }

  /// `Synced`
  String get xmrStatusSynchronized {
    return Intl.message(
      'Synced',
      name: 'xmrStatusSynchronized',
      desc: 'xmr_synced_status',
      args: [],
    );
  }

  /// `Syncing`
  String get xmrStatusSynchronizing {
    return Intl.message(
      'Syncing',
      name: 'xmrStatusSynchronizing',
      desc: 'xmr_syncing_status',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: 'intro_new_wallet_backup_yes',
      args: [],
    );
  }

  /// `Yes`
  String get yesButton {
    return Intl.message(
      'Yes',
      name: 'yesButton',
      desc: 'A button that accepts the mentioned process.',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'bg'),
      Locale.fromSubtags(languageCode: 'bn'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'he'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'hu'),
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'lv'),
      Locale.fromSubtags(languageCode: 'ms'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'no'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ro'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'sl'),
      Locale.fromSubtags(languageCode: 'sv'),
      Locale.fromSubtags(languageCode: 'tl'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'uk'),
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalization> load(Locale locale) => AppLocalization.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
