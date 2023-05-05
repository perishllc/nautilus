import 'package:flutter/material.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheets.dart';

class AppTransferCompleteSheet extends StatefulWidget {
  const AppTransferCompleteSheet({required this.transferAmount}) : super();

  final String transferAmount;

  @override
  AppTransferCompleteSheetState createState() => AppTransferCompleteSheetState();
}

class AppTransferCompleteSheetState extends State<AppTransferCompleteSheet> {
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
            //A container for the paragraph and seed
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Success tick (icon)
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Icon(AppIcons.success, size: 100, color: StateContainer.of(context).curTheme.success),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.2,
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                    // child: Stack(
                    //   children: <Widget>[
                    //     Center(
                    //       child: SvgPicture.asset('legacy_assets/transferfunds_illustration_end_paperwalletonly.svg',
                    //           color: StateContainer.of(context).curTheme.text45, width: MediaQuery.of(context).size.width),
                    //     ),
                    //     Center(
                    //       child: SvgPicture.asset('legacy_assets/transferfunds_illustration_end_nautiluswalletonly.svg',
                    //           color: StateContainer.of(context).curTheme.success, width: MediaQuery.of(context).size.width),
                    //     ),
                    //   ],
                    // ),
                  ),
                  Container(
                      alignment: AlignmentDirectional.centerStart,
                      margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 35 : 60),
                      child: Text(
                        Z
                            .of(context)
                            .transferComplete
                            .replaceAll("%1", widget.transferAmount)
                            .replaceAll("%2", StateContainer.of(context).currencyMode)
                            .replaceAll("%3", NonTranslatable.appName),
                        style: AppStyles.textStyleParagraphSuccess(context),
                        textAlign: TextAlign.start,
                      )),
                  Container(
                      alignment: AlignmentDirectional.centerStart,
                      margin: EdgeInsets.symmetric(horizontal: smallScreen(context) ? 35 : 60),
                      child: Text(
                        Z.of(context).transferClose,
                        style: AppStyles.textStyleParagraph(context),
                        textAlign: TextAlign.start,
                      )),
                ],
              ),
            ),

            Row(
              children: <Widget>[
                AppButton.buildAppButton(
                  context,
                  AppButtonType.SUCCESS_OUTLINE,
                  Z.of(context).close.toUpperCase(),
                  Dimens.BUTTON_BOTTOM_DIMENS,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
