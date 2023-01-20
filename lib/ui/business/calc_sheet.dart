import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/available_currency.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';

class CalcSheet extends StatefulWidget {
  const CalcSheet({required this.localCurrency, this.address, this.qrWidget, this.amountRaw}) : super();

  final AvailableCurrency localCurrency;
  final Widget? qrWidget;
  final String? address;
  final String? amountRaw;

  @override
  CalcSheetState createState() => CalcSheetState();
}

class CalcSheetState extends State<CalcSheet> {
  final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // On amount focus change
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
      child: GestureDetector(
        onTap: () {
          // clear focus
        },
        child: Column(
          children: <Widget>[
            Center(
              child: Handlebars.horizontal(context),
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                      context,
                      AppButtonType.PRIMARY,
                      Z.of(context).copyAddress,
                      Dimens.BUTTON_COMPACT_LEFT_DIMENS,
                      onPressed: () async {},
                    ),
                    AppButton.buildAppButton(
                      context,
                      AppButtonType.PRIMARY_OUTLINE,
                      Z.of(context).addressShare,
                      Dimens.BUTTON_COMPACT_RIGHT_DIMENS,
                      onPressed: () async {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
