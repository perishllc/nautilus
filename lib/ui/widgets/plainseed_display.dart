import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/generated/l10n.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/util/user_data_util.dart';

/// A widget for displaying a mnemonic phrase
class PlainSeedDisplay extends StatefulWidget {
  const PlainSeedDisplay({required this.seed, this.obscureSeed = false, this.showButton = true});

  final String? seed;
  final bool obscureSeed;
  final bool showButton;

  @override
  _PlainSeedDisplayState createState() => _PlainSeedDisplayState();
}

class _PlainSeedDisplayState extends State<PlainSeedDisplay> {
  String _obscuredSeed = '•' * 64;

  late bool _seedCopied;
  late bool _seedObscured;
  Timer? _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
    _seedCopied = false;
    _seedObscured = true;
    _obscuredSeed = '•' * widget.seed!.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // The paragraph
        Container(
          margin: EdgeInsets.only(left: smallScreen(context) ? 30 : 40, right: smallScreen(context) ? 30 : 40, top: 15.0),
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            Z.of(context).seedDescription,
            style: AppStyles.textStyleParagraph(context),
            maxLines: 5,
            stepGranularity: 0.5,
          ),
        ),
        // Container for the seed
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (widget.obscureSeed) {
                setState(() {
                  _seedObscured = !_seedObscured;
                });
              }
            },
            child: Column(
              children: <Widget>[
                if (widget.seed!.length == 64)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                    margin: const EdgeInsets.only(top: 25),
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: UIUtil.threeLineSeedText(context, widget.obscureSeed && _seedObscured ? _obscuredSeed : widget.seed!,
                        textStyle: _seedCopied ? AppStyles.textStyleSeedGreen(context) : AppStyles.textStyleSeed(context)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                    margin: const EdgeInsets.only(top: 25),
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: UIUtil.sixLineSeedText(context, widget.obscureSeed && _seedObscured ? _obscuredSeed : widget.seed!,
                        textStyle: _seedCopied ? AppStyles.textStyleSeedGreen(context) : AppStyles.textStyleSeed(context)),
                  ),
                // Tap to reveal or hide
                if (widget.obscureSeed)
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: 8),
                    child: _seedObscured
                        ? AutoSizeText(
                            Z.of(context).tapToReveal,
                            style: AppStyles.textStyleParagraphThinPrimary(context),
                          )
                        : Text(
                            Z.of(context).tapToHide,
                            style: AppStyles.textStyleParagraphThinPrimary(context),
                          ),
                  ),
              ],
            )),
        // Container for the copy button
        if (widget.showButton)
          Container(
            margin: const EdgeInsetsDirectional.only(top: 5),
            padding: EdgeInsets.zero,
            child: OutlinedButton(
              onPressed: () {
                UserDataUtil.setSecureClipboardItem(widget.seed);
                setState(() {
                  _seedCopied = true;
                });
                if (_seedCopiedTimer != null) {
                  _seedCopiedTimer!.cancel();
                }
                _seedCopiedTimer = Timer(const Duration(milliseconds: 1500), () {
                  setState(() {
                    _seedCopied = false;
                  });
                });
              },
              // TODO:
              // splashColor: _seedCopied ? Colors.transparent : StateContainer.of(context).curTheme.primary30,
              // highlightColor: _seedCopied ? Colors.transparent : StateContainer.of(context).curTheme.primary15,
              // highlightedBorderColor: _seedCopied ? StateContainer.of(context).curTheme.success : StateContainer.of(context).curTheme.primary,
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              // borderSide:
              //     BorderSide(color: _seedCopied ? StateContainer.of(context).curTheme.success : StateContainer.of(context).curTheme.primary, width: 1.0),
              child: AutoSizeText(
                _seedCopied ? Z.of(context).copied : Z.of(context).copy,
                textAlign: TextAlign.center,
                style: _seedCopied ? AppStyles.textStyleButtonSuccessSmallOutline(context) : AppStyles.textStyleButtonPrimarySmallOutline(context),
                maxLines: 1,
                stepGranularity: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}
