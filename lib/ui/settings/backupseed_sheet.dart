import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/settings/backupseed_qr_sheet.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/mnemonic_display.dart';
import 'package:wallet_flutter/ui/widgets/plainseed_display.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/user_data_util.dart';
import 'package:wallet_flutter/util/xmr_util.dart';

class AppSeedBackupSheet extends StatefulWidget {
  const AppSeedBackupSheet({required this.seed}) : super();

  final String seed;

  @override
  _AppSeedBackupSheetState createState() => _AppSeedBackupSheetState();
}

class _AppSeedBackupSheetState extends State<AppSeedBackupSheet> {
  String? _seed;
  List<String>? _mnemonic;
  List<String>? mnemonic;
  bool showMnemonic = true;
  late bool _seedCopied;
  Timer? _seedCopiedTimer;
  late bool _xmrSeedCopied;
  Timer? _xmrSeedCopiedTimer;
  late bool _mnemonicCopied;
  Timer? _mnemonicCopiedTimer;
  bool _mnemonicDisabled = false;

  @override
  void initState() {
    super.initState();
    _seed = widget.seed;
    _seedCopied = false;
    _xmrSeedCopied = false;
    _mnemonicCopied = false;
    showMnemonic = true;

    try {
      _mnemonic = NanoMnemomics.seedToMnemonic(_seed!);
    } catch (e) {
      showMnemonic = false;
      _mnemonicDisabled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.035,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 60, height: 60),
                      // Sheet handle and Header
                      Column(
                        children: <Widget>[
                          // Header text
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            height: 5,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              color: StateContainer.of(context).curTheme.text20,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          //A container for the header
                          Container(
                            margin: const EdgeInsets.only(top: 15.0),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                            child: Column(
                              children: <Widget>[
                                AutoSizeText(
                                  CaseChange.toUpperCase(showMnemonic ? Z.of(context).secretPhrase : Z.of(context).seed, context),
                                  style: AppStyles.textStyleHeader(context),
                                  maxLines: 1,
                                  stepGranularity: 0.1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Switch button
                      if (!_mnemonicDisabled)
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsetsDirectional.only(top: 10.0, end: 10.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: StateContainer.of(context).curTheme.text15,
                              padding: const EdgeInsets.all(13.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              tapTargetSize: MaterialTapTargetSize.padded,
                              // highlightColor: StateContainer.of(context).curTheme.text15,
                              // splashColor: StateContainer.of(context).curTheme.text15,
                            ),
                            onPressed: () {
                              setState(() {
                                showMnemonic = !showMnemonic;
                              });
                            },
                            child: Icon(showMnemonic ? AppIcons.seed : Icons.vpn_key, size: 24, color: StateContainer.of(context).curTheme.text),
                          ),
                        )
                      else
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsetsDirectional.only(top: 10.0, end: 10.0),
                        ),
                    ],
                  ),
                ],
              ),

              //A container for the paragraph and seed
              Expanded(
                child: Column(
                  children: <Widget>[
                    if (showMnemonic)
                      MnemonicDisplay(
                        wordList: _mnemonic,
                        obscureSeed: true,
                        showButton: false,
                      )
                    else
                      PlainSeedDisplay(
                        seed: _seed,
                        obscureSeed: true,
                        showButton: false,
                      ),
                  ],
                ),
              ),
              //A row with copy button
              if (showMnemonic)
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Copy Mnemonic Button
                        _mnemonicCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                        _mnemonicCopied ? Z.of(context).secretPhraseCopied : Z.of(context).secretPhraseCopy,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      UserDataUtil.setSecureClipboardItem(_mnemonic!.join(" "));
                      setState(() {
                        // Set copied style
                        _mnemonicCopied = true;
                      });
                      if (_mnemonicCopiedTimer != null) {
                        _mnemonicCopiedTimer!.cancel();
                      }
                      _mnemonicCopiedTimer = Timer(const Duration(milliseconds: 1000), () {
                        try {
                          setState(() {
                            _mnemonicCopied = false;
                          });
                        } catch (e) {}
                      });
                    }),
                  ],
                )
              else
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Copy Seed Button
                        _seedCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                        _seedCopied ? Z.of(context).seedCopiedShort : Z.of(context).copySeed,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      UserDataUtil.setSecureClipboardItem(_seed);
                      setState(() {
                        // Set copied style
                        _seedCopied = true;
                      });
                      if (_seedCopiedTimer != null) {
                        _seedCopiedTimer!.cancel();
                      }
                      _seedCopiedTimer = Timer(const Duration(milliseconds: 1000), () {
                        setState(() {
                          _seedCopied = false;
                        });
                      });
                    }),
                  ],
                ),

              if (StateContainer.of(context).xmrEnabled)
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        // Copy Seed Button
                        _xmrSeedCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                        _xmrSeedCopied ? Z.of(context).seedCopiedShort : Z.of(context).copyXMRSeed,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      if (_seed == null) return;
                      UserDataUtil.setSecureClipboardItem(XmrUtil.seedToXmrSecretKey(_seed!));
                      setState(() {
                        // Set copied style
                        _xmrSeedCopied = true;
                      });
                      if (_xmrSeedCopiedTimer != null) {
                        _xmrSeedCopiedTimer!.cancel();
                      }
                      _xmrSeedCopiedTimer = Timer(const Duration(milliseconds: 1000), () {
                        setState(() {
                          _xmrSeedCopied = false;
                        });
                      });
                    }),
                  ],
                ),

              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                      context,
                      // Show QR Button
                      AppButtonType.PRIMARY_OUTLINE,
                      Z.of(context).showQR,
                      Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                    final Widget qrWidget = SizedBox(width: MediaQuery.of(context).size.width, child: await UIUtil.getQRImage(context, _seed!));
                    Sheets.showAppHeightEightSheet(
                        context: context,
                        widget: BackupSeedQRSheet(
                          data: _seed!,
                          qrWidget: qrWidget,
                        ));
                  }),
                ],
              ),
            ],
          ),
        ));
  }
}
