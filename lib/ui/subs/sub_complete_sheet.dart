import 'package:flutter/material.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class SubCompleteSheet extends StatefulWidget {
  final String? label;

  SubCompleteSheet({this.label}) : super();

  _SubCompleteSheetState createState() => _SubCompleteSheetState();
}

class _SubCompleteSheetState extends State<SubCompleteSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            Handlebars.horizontal(
              context,
              width: MediaQuery.of(context).size.width * 0.15,
            ),
            //A main container that holds the amount, address and "SENT TO" texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Success tick (icon)
                  Container(
                    alignment: AlignmentDirectional.center,
                    margin: const EdgeInsets.only(bottom: 25),
                    child: Icon(AppIcons.success, size: 100, color: StateContainer.of(context).curTheme.success),
                  ),
                  // Container for the "SENT TO" text
                  Container(
                    margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        // "SENT TO" text
                        Text(
                          CaseChange.toUpperCase(Z.of(context).subscribed, context),
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w700,
                            color: StateContainer.of(context).curTheme.success,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CLOSE Button
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.SUCCESS_OUTLINE,
                        CaseChange.toUpperCase(Z.of(context).close, context),
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
