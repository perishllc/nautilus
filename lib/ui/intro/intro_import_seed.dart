import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/network/auth_service.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:wallet_flutter/util/user_data_util.dart';
import 'package:quiver/strings.dart';

class IntroImportSeedPage extends StatefulWidget {
  const IntroImportSeedPage({this.fullIdentifier, this.password});
  final String? fullIdentifier;
  final String? password;

  @override
  IntroImportSeedState createState() => IntroImportSeedState();
}

class IntroImportSeedState extends State<IntroImportSeedPage> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  // Plaintext seed
  final FocusNode _seedInputFocusNode = FocusNode();
  final TextEditingController _seedInputController = TextEditingController();
  // Mnemonic Phrase
  final FocusNode _mnemonicFocusNode = FocusNode();
  final TextEditingController _mnemonicController = TextEditingController();

  // bool _seedMode = false; // False if restoring phrase, true if restoring seed
  // String _seedMode = "nano_phrase"; // "nano_phrase" if restoring phrase, "nano_seed" if restoring seed
  // "bip39_phrase" if restoring bip39 phase "bip39_seed" if restoring bip39 seed

  // String _fullMode = "nano_phrase";
  // String _fullMode = "bip39_phrase";
  bool _seedMode = false;
  // bool _bip39Mode = true;

  bool _seedIsValid = false;
  bool _showSeedError = false;
  bool _mnemonicIsValid = false;
  String? _mnemonicError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        body: TapOutsideUnfocus(
            child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
            minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Back Button
                          Container(
                            margin: EdgeInsetsDirectional.only(start: smallScreen(context) ? 15 : 20),
                            height: 50,
                            width: 50,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: StateContainer.of(context).curTheme.text15,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                          ),
                          // Switch between Secret Phrase and Seed
                          Container(
                            margin: EdgeInsetsDirectional.only(end: smallScreen(context) ? 15 : 20),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: StateContainer.of(context).curTheme.text15,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                padding: const EdgeInsetsDirectional.only(top: 6, bottom: 6, start: 12, end: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  _seedMode = !_seedMode;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsetsDirectional.only(end: 8),
                                    child: Text(
                                      _seedMode ? Z.of(context).secretPhrase : Z.of(context).seed,
                                      style: TextStyle(
                                        color: StateContainer.of(context).curTheme.text,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "NunitoSans",
                                      ),
                                    ),
                                  ),
                                  Icon(_seedMode ? Icons.vpn_key : AppIcons.seed, color: StateContainer.of(context).curTheme.text, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // The header
                      Container(
                        margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 10,
                        ),
                        alignment: AlignmentDirectional.centerStart,
                        child: AutoSizeText(
                          _seedMode ? Z.of(context).importSeed : Z.of(context).importSecretPhrase,
                          style: AppStyles.textStyleHeaderColored(context),
                          maxLines: 1,
                          minFontSize: 12,
                          stepGranularity: 0.1,
                        ),
                      ),
                      // The paragraph
                      Container(
                        margin: EdgeInsets.only(left: smallScreen(context) ? 30 : 40, right: smallScreen(context) ? 30 : 40, top: 15.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _seedMode ? Z.of(context).importSeedHint : Z.of(context).importSecretPhraseHint,
                          style: AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                          child: KeyboardAvoider(
                              duration: Duration.zero,
                              autoScroll: true,
                              focusPadding: 40,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                // The text field for the seed
                                if (_seedMode)
                                  AppTextField(
                                    leftMargin: smallScreen(context) ? 30 : 40,
                                    rightMargin: smallScreen(context) ? 30 : 40,
                                    topMargin: 20,
                                    focusNode: _seedInputFocusNode,
                                    controller: _seedInputController,
                                    inputFormatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(128), UpperCaseTextFormatter()],
                                    textInputAction: TextInputAction.done,
                                    maxLines: null,
                                    autocorrect: false,
                                    prefixButton: TextFieldButton(
                                      icon: AppIcons.scan,
                                      onPressed: () async {
                                        if (NanoUtil.isValidSeed(_seedInputController.text)) {
                                          return;
                                        }
                                        // Scan QR for seed
                                        UIUtil.cancelLockEvent();
                                        final String? result = await UserDataUtil.getQRData(DataType.RAW, context) as String?;
                                        if (result == null) {
                                          return;
                                        }
                                        if (NanoUtil.isValidSeed(result)) {
                                          _seedInputController.text = result;
                                          setState(() {
                                            _seedIsValid = true;
                                          });
                                        } else if (NanoMnemomics.validateMnemonic(result.split(' '))) {
                                          _mnemonicController.text = result;
                                          _mnemonicFocusNode.unfocus();
                                          _seedInputFocusNode.unfocus();
                                          setState(() {
                                            _seedMode = false;
                                            _mnemonicError = null;
                                            _mnemonicIsValid = true;
                                          });
                                        } else {
                                          UIUtil.showSnackbar(Z.of(context).qrInvalidSeed, context);
                                        }
                                      },
                                    ),
                                    fadePrefixOnCondition: true,
                                    prefixShowFirstCondition: !NanoUtil.isValidSeed(_seedInputController.text),
                                    suffixButton: TextFieldButton(
                                      icon: AppIcons.paste,
                                      onPressed: () {
                                        if (NanoUtil.isValidSeed(_seedInputController.text)) {
                                          return;
                                        }
                                        Clipboard.getData("text/plain").then((ClipboardData? data) {
                                          if (data == null || data.text == null) {
                                            return;
                                          } else if (NanoUtil.isValidSeed(data.text!)) {
                                            _seedInputController.text = data.text!;
                                            _seedInputFocusNode.unfocus();
                                            setState(() {
                                              _seedIsValid = true;
                                            });
                                          } else if (NanoMnemomics.validateMnemonic(data.text!.split(' '))) {
                                            _mnemonicController.text = data.text!;
                                            _mnemonicFocusNode.unfocus();
                                            _seedInputFocusNode.unfocus();
                                            setState(() {
                                              _seedMode = false;
                                              _mnemonicError = null;
                                              _mnemonicIsValid = true;
                                            });
                                          }
                                        });
                                      },
                                    ),
                                    fadeSuffixOnCondition: true,
                                    suffixShowFirstCondition: !NanoUtil.isValidSeed(_seedInputController.text),
                                    keyboardType: TextInputType.text,
                                    style: _seedIsValid ? AppStyles.textStyleSeed(context) : AppStyles.textStyleSeedGray(context),
                                    onChanged: (String text) {
                                      // Always reset the error message to be less annoying
                                      if (_showSeedError) {
                                        setState(() {
                                          _showSeedError = false;
                                        });
                                      }
                                      // If valid seed, clear focus/close keyboard
                                      if (NanoUtil.isValidSeed(text)) {
                                        _seedInputFocusNode.unfocus();
                                        setState(() {
                                          _seedIsValid = true;
                                        });
                                      } else {
                                        setState(() {
                                          _seedIsValid = false;
                                        });
                                      }
                                    },
                                  )
                                else if (!_seedMode)
                                  AppTextField(
                                    leftMargin: smallScreen(context) ? 30 : 40,
                                    rightMargin: smallScreen(context) ? 30 : 40,
                                    topMargin: 20,
                                    focusNode: _mnemonicFocusNode,
                                    controller: _mnemonicController,
                                    inputFormatters: [
                                      SingleSpaceInputFormatter(),
                                      LowerCaseTextFormatter(),
                                      FilteringTextInputFormatter(RegExp("[a-zA-Z ]"), allow: true), // bug fix for debug mode when importing a seed
                                    ],
                                    textInputAction: TextInputAction.done,
                                    maxLines: null,
                                    autocorrect: false,
                                    prefixButton: TextFieldButton(
                                      icon: AppIcons.scan,
                                      onPressed: () async {
                                        if (NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))) {
                                          return;
                                        }
                                        // Scan QR for mnemonic
                                        UIUtil.cancelLockEvent();
                                        final String? result = await UserDataUtil.getQRData(DataType.RAW, context) as String?;
                                        if (result == null) {
                                          return;
                                        }
                                        if (NanoMnemomics.validateMnemonic(result.split(' '))) {
                                          _mnemonicController.text = result;
                                          _mnemonicFocusNode.unfocus();
                                          setState(() {
                                            _mnemonicIsValid = true;
                                          });
                                        } else if (NanoUtil.isValidSeed(result)) {
                                          _seedInputController.text = result;
                                          _mnemonicFocusNode.unfocus();
                                          _seedInputFocusNode.unfocus();
                                          setState(() {
                                            _seedMode = true;
                                            _seedIsValid = true;
                                            _showSeedError = false;
                                          });
                                        } else {
                                          UIUtil.showSnackbar(Z.of(context).qrMnemonicError, context);
                                        }
                                      },
                                    ),
                                    fadePrefixOnCondition: true,
                                    prefixShowFirstCondition: !NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' ')),
                                    suffixButton: TextFieldButton(
                                      icon: AppIcons.paste,
                                      onPressed: () {
                                        if (NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))) {
                                          return;
                                        }
                                        Clipboard.getData("text/plain").then((ClipboardData? data) {
                                          if (data == null || data.text == null) {
                                            return;
                                          } else if (NanoMnemomics.validateMnemonic(data.text!.split(' '))) {
                                            _mnemonicController.text = data.text!;
                                            _mnemonicFocusNode.unfocus();
                                            setState(() {
                                              _mnemonicIsValid = true;
                                            });
                                          } else if (NanoUtil.isValidSeed(data.text!)) {
                                            _seedInputController.text = data.text!;
                                            _mnemonicFocusNode.unfocus();
                                            _seedInputFocusNode.unfocus();
                                            setState(() {
                                              _seedMode = true;
                                              _seedIsValid = true;
                                              _showSeedError = false;
                                            });
                                          }
                                        });
                                      },
                                    ),
                                    fadeSuffixOnCondition: true,
                                    suffixShowFirstCondition: !NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' ')),
                                    keyboardType: TextInputType.text,
                                    style: _mnemonicIsValid ? AppStyles.textStyleParagraphPrimary(context) : AppStyles.textStyleParagraph(context),
                                    onChanged: (String text) {
                                      if (text.length < 3) {
                                        setState(() {
                                          _mnemonicError = null;
                                        });
                                      } else if (_mnemonicError != null) {
                                        if (!text.contains(_mnemonicError!.split(' ')[0])) {
                                          setState(() {
                                            _mnemonicError = null;
                                          });
                                        }
                                      }
                                      // If valid mnemonic, clear focus/close keyboard
                                      if (NanoMnemomics.validateMnemonic(text.split(' '))) {
                                        _mnemonicFocusNode.unfocus();
                                        setState(() {
                                          _mnemonicIsValid = true;
                                          _mnemonicError = null;
                                        });
                                      } else {
                                        setState(() {
                                          _mnemonicIsValid = false;
                                        });
                                        // Validate each mnemonic word
                                        if (text.endsWith(" ") && text.length > 1) {
                                          int? lastSpaceIndex = text.substring(0, text.length - 1).lastIndexOf(" ");
                                          if (lastSpaceIndex == -1) {
                                            lastSpaceIndex = 0;
                                          } else {
                                            lastSpaceIndex = lastSpaceIndex + 1;
                                          }
                                          final String lastWord = text.substring(lastSpaceIndex, text.length - 1);
                                          if (!NanoMnemomics.isValidWord(lastWord)) {
                                            setState(() {
                                              _mnemonicIsValid = false;
                                              setState(() {
                                                _mnemonicError = Z.of(context).mnemonicInvalidWord.replaceAll("%1", lastWord);
                                              });
                                            });
                                          }
                                        }
                                      }
                                    },
                                  ),

                                // "Invalid Seed" text that appears if the input is invalid
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                      !_seedMode
                                          ? _mnemonicError == null
                                              ? ""
                                              : _mnemonicError!
                                          : _showSeedError
                                              ? Z.of(context).seedInvalid
                                              : "",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: _seedMode
                                            ? _showSeedError
                                                ? StateContainer.of(context).curTheme.primary
                                                : Colors.transparent
                                            : _mnemonicError != null
                                                ? StateContainer.of(context).curTheme.primary
                                                : Colors.transparent,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                              ])))
                    ],
                  ),
                ),
                // Next Screen Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    // import ledger:
                    AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).importHD, Dimens.BUTTON_COMPACT_LEFT_DIMENS,
                        instanceKey: const Key("new_wallet_button"), onPressed: () async {
                      if (_seedMode) {
                        _seedInputFocusNode.unfocus();
                        // If seed valid, log them in
                        if (NanoUtil.isValidBip39Seed(_seedInputController.text)) {
                          await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
                          await sl.get<Vault>().setSeed(_seedInputController.text);
                          await changingSeed(_seedInputController.text);
                          await sl.get<SharedPrefsUtil>().setKeyDerivationMethod("hd");
                          await sl.get<DBHelper>().dropAccounts();
                          if (!mounted) return;
                          await NanoUtil().loginAccount(_seedInputController.text, context);
                          if (!mounted) return;
                          // final String? pin = await Navigator.of(context).push(MaterialPageRoute<String>(builder: (BuildContext context) {
                          //   return PinScreen(
                          //     PinOverlayType.NEW_PIN,
                          //   );
                          // }));
                          // if (pin != null && pin.length > 5) {
                          //   _pinEnteredCallback(pin);
                          // }
                          skipPin();
                        } else {
                          if (_seedInputController.text.length == 64 && NanoUtil.isValidSeed(_seedInputController.text)) {
                            await AppDialogs.showInfoDialog(
                              context,
                              Z.of(context).logoutAreYouSure,
                              Z.of(context).looksLikeStandardSeed,
                              closeText: Z.of(context).ok,
                            );
                            return;
                          }
                          // Display error
                          setState(() {
                            _showSeedError = true;
                          });
                        }
                      } else {
                        // mnemonic mode
                        _mnemonicFocusNode.unfocus();
                        if (NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))) {
                          await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
                          await sl.get<SharedPrefsUtil>().setKeyDerivationMethod("hd");
                          final String seed = await NanoUtil.hdMnemonicListToSeed(_mnemonicController.text.split(' '));
                          await sl.get<Vault>().setSeed(seed);
                          await changingSeed(seed);
                          await sl.get<DBHelper>().dropAccounts();
                          if (!mounted) return;
                          await NanoUtil().loginAccount(seed, context);
                          if (!mounted) return;
                          skipPin();
                        } else {
                          // Show mnemonic error
                          if (_mnemonicController.text.split(' ').length != 24) {
                            setState(() {
                              _mnemonicIsValid = false;
                              _mnemonicError = Z.of(context).mnemonicSizeError;
                            });
                          } else {
                            _mnemonicController.text.split(' ').forEach((String word) {
                              if (!NanoMnemomics.isValidWord(word)) {
                                setState(() {
                                  _mnemonicIsValid = false;
                                  _mnemonicError = Z.of(context).mnemonicInvalidWord.replaceAll("%1", word);
                                });
                              }
                            });
                          }
                        }
                      }
                    }),

                    AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).importStandard, Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
                        onPressed: () async {
                      if (_seedMode) {
                        _seedInputFocusNode.unfocus();
                        // If seed valid, log them in
                        if (NanoUtil.isValidSeed(_seedInputController.text)) {
                          if (_seedInputController.text.length == 128) {
                            // are you sure?
                            final bool isSure = await AppDialogs.waitableConfirmDialog(context, Z.of(context).logoutAreYouSure,
                                Z.of(context).looksLikeHdSeed, Z.of(context).imSure,
                                cancelText: Z.of(context).goBackButton);

                            if (!isSure) {
                              return;
                            }
                          }

                          await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
                          await sl.get<Vault>().setSeed(_seedInputController.text);
                          await changingSeed(_seedInputController.text);
                          await sl.get<DBHelper>().dropAccounts();
                          if (!mounted) return;
                          await NanoUtil().loginAccount(_seedInputController.text, context);
                          if (!mounted) return;

                          skipPin();
                        } else {
                          // Display error
                          setState(() {
                            _showSeedError = true;
                          });
                        }
                      } else {
                        // mnemonic mode
                        _mnemonicFocusNode.unfocus();
                        if (NanoMnemomics.validateMnemonic(_mnemonicController.text.split(' '))) {
                          await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
                          final String seed = NanoMnemomics.mnemonicListToSeed(_mnemonicController.text.split(' '));
                          await sl.get<Vault>().setSeed(seed);
                          await changingSeed(seed);
                          await sl.get<DBHelper>().dropAccounts();
                          if (!mounted) return;
                          await NanoUtil().loginAccount(seed, context);
                          if (!mounted) return;
                          skipPin();
                        } else {
                          // Show mnemonic error
                          if (_mnemonicController.text.split(' ').length != 24) {
                            setState(() {
                              _mnemonicIsValid = false;
                              _mnemonicError = Z.of(context).mnemonicSizeError;
                            });
                          } else {
                            _mnemonicController.text.split(' ').forEach((String word) {
                              if (!NanoMnemomics.isValidWord(word)) {
                                setState(() {
                                  _mnemonicIsValid = false;
                                  _mnemonicError = Z.of(context).mnemonicInvalidWord.replaceAll("%1", word);
                                });
                              }
                            });
                          }
                        }
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        )));
  }

  Future<void> changingSeed(String seed) async {
    if (isNotEmpty(widget.fullIdentifier)) {
      try {
        final bool identifierExists = await sl.get<AuthService>().entryExists(widget.fullIdentifier!);

        if (identifierExists) {
          await sl.get<AuthService>().deleteEncryptedSeed(widget.fullIdentifier!);
        }

        // upload the seed backup:
        final String encryptedSeed = NanoHelpers.byteToHex(NanoCrypt.encrypt(seed, widget.password!));
        await sl.get<AuthService>().setEncryptedSeed(widget.fullIdentifier!, encryptedSeed);
      } catch (e) {
        sl.get<Logger>().e("Error uploading seed backup", e);
      }
    }
  }

  Future<void> skipPin() async {
    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<Vault>().writePin("000000");
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: conversion);
  }

  Future<void> _pinEnteredCallback(String pin) async {
    // final String? pin = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
    //   return PinScreen(
    //     PinOverlayType.NEW_PIN,
    //   );
    // }));
    // if (pin != null && pin.length > 5) {
    //   _pinEnteredCallback(pin);
    // }
    await sl.get<SharedPrefsUtil>().setSeedBackedUp(true);
    await sl.get<Vault>().writePin(pin);
    final PriceConversion conversion = await sl.get<SharedPrefsUtil>().getPriceConversion();
    if (!mounted) return;
    StateContainer.of(context).requestSubscribe();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: conversion);
  }
}
