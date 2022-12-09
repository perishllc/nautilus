import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/vault.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/mnemonic_display.dart';
import 'package:wallet_flutter/ui/widgets/plainseed_display.dart';
import 'package:wallet_flutter/util/nanoutil.dart';

class IntroBackupSeedPage extends StatefulWidget {
  const IntroBackupSeedPage({this.encryptedSeed}) : super();
  final String? encryptedSeed;

  @override
  IntroBackupSeedState createState() => IntroBackupSeedState();
}

class IntroBackupSeedState extends State<IntroBackupSeedPage> {
  String? _seed;
  List<String>? _mnemonic;
  late bool _showMnemonic;

  @override
  void initState() {
    super.initState();
    if (widget.encryptedSeed == null) {
      sl.get<Vault>().getSeed().then((String? seed) {
        setState(() {
          _seed = seed;
          _mnemonic = NanoMnemomics.seedToMnemonic(seed!);
        });
      });
    } else {
      sl.get<Vault>().getSessionKey().then((String key) {
        setState(() {
          _seed = NanoHelpers.byteToHex(NanoCrypt.decrypt(widget.encryptedSeed, key));
          _mnemonic = NanoMnemomics.seedToMnemonic(_seed!);
        });
      });
    }
    _showMnemonic = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              //A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
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
                                // highlightColor: StateContainer.of(context).curTheme.text15,
                                // splashColor: StateContainer.of(context).curTheme.text15,
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: const EdgeInsetsDirectional.only(top: 6, bottom: 6, start: 12, end: 12),
                              // highlightColor: StateContainer.of(context).curTheme.text15,
                              // splashColor: StateContainer.of(context).curTheme.text15,
                            ),
                            onPressed: () {
                              setState(() {
                                _showMnemonic = !_showMnemonic;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsetsDirectional.only(end: 8),
                                  child: Text(
                                    !_showMnemonic ? Z.of(context).secretPhrase : Z.of(context).seed,
                                    style: TextStyle(
                                      color: StateContainer.of(context).curTheme.text,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "NunitoSans",
                                    ),
                                  ),
                                ),
                                Icon(!_showMnemonic ? Icons.vpn_key : AppIcons.seed, color: StateContainer.of(context).curTheme.text, size: 18),
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
                      child: Row(
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - (smallScreen(context) ? 120 : 140)),
                            child: AutoSizeText(
                              _showMnemonic ? Z.of(context).secretPhrase : Z.of(context).seed,
                              style: AppStyles.textStyleHeaderColored(context),
                              stepGranularity: 0.1,
                              minFontSize: 12.0,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsetsDirectional.only(start: 10, end: 10),
                            child: Icon(
                              _showMnemonic ? Icons.vpn_key : AppIcons.seed,
                              size: _showMnemonic ? 36 : 24,
                              color: StateContainer.of(context).curTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mnemonic word list
                    if (_seed != null && _mnemonic != null)
                      _showMnemonic ? MnemonicDisplay(wordList: _mnemonic) : PlainSeedDisplay(seed: _seed)
                    else
                      const Text('')
                  ],
                ),
              ),
              // Next Screen Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY,
                    Z.of(context).backupConfirmButton,
                    Dimens.BUTTON_BOTTOM_DIMENS,
                    instanceKey: const Key("backed_it_up_button"),
                    onPressed: () {
                      // Update wallet
                      sl.get<DBHelper>().dropAccounts().then((_) {
                        StateContainer.of(context).getSeed().then((String seed) {
                          NanoUtil().loginAccount(seed, context).then((_) {
                            Navigator.of(context).pushNamed('/intro_backup_confirm');
                          });
                        });
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
