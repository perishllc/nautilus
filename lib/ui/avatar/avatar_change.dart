import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/avatar/nonce_response.dart';
import 'package:wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';

const String NATRICON_ADDRESS = "nano_3natricon9grnc8caqkht19f1fwpz39r3deeyef66m3d4fch3fau7x5q57cj";
const String NATRICON_BASE_RAW = "1234567891234567891234567891";

class AvatarChangePage extends StatefulWidget {
  final String? curAddress;

  AvatarChangePage({this.curAddress});
  @override
  _AvatarChangePageState createState() => _AvatarChangePageState();
}

class _AvatarChangePageState extends State<AvatarChangePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? nonce;
  int? currentNonce;
  late bool loading;

  @override
  void initState() {
    super.initState();
    loading = true;
    String url = 'https://natricon.com/api/v1/nano/nonce?address=${widget.curAddress}';
    http.get(Uri.parse(url), headers: {}).then((http.Response response) {
      if (mounted) {
        if (response.statusCode != 200) {
          setState(() {
            loading = false;
          });
          return;
        }
        try {
          NonceResponse resp = NonceResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
          setState(() {
            loading = false;
            currentNonce = resp.nonce;
          });
        } catch (e) {
          setState(() {
            loading = false;
          });
        }
      }
    });
  }

  void showSendConfirmSheet() {
    BigInt baseAmount = BigInt.parse(NATRICON_BASE_RAW);
    BigInt sendAmount = baseAmount + BigInt.from(nonce!);
    if (StateContainer.of(context).wallet!.accountBalance < sendAmount) {
      UIUtil.showSnackbar(Z.of(context).insufficientBalance, context);
      return;
    }
    Sheets.showAppHeightNineSheet(
        context: context, widget: SendConfirmSheet(amountRaw: sendAmount.toString(), destination: NATRICON_ADDRESS));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
          minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035, top: MediaQuery.of(context).size.height * 0.075),
          child: Column(
            children: <Widget>[
              //A widget that holds the header, the paragraph and Back Button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
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
                                Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                              },
                              child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
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
                        "Change Natricon",
                        maxLines: 3,
                        stepGranularity: 0.5,
                        style: AppStyles.textStyleHeaderColored(context),
                      ),
                    ),
                    // The paragraph
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 16.0),
                      child: AutoSizeText(
                        "You'll be asked to send 0.001~ Nano to the Natricon address to change your Natricon.",
                        style: AppStyles.textStyleParagraph(context),
                        maxLines: 3,
                        stepGranularity: 0.5,
                      ),
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40, end: smallScreen(context) ? 30 : 40, top: 8),
                      child: AutoSizeText(
                        "This amount will be automatically refunded completely.",
                        style: AppStyles.textStyleParagraphPrimary(context),
                        maxLines: 2,
                        stepGranularity: 0.5,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      child: Stack(alignment: Alignment.center, children: [
                        Container(
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.5,
                              maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: const SizedBox(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[],
                        ),
                      ]),
                    ))
                  ],
                ),
              ),

              //A column with 2 buttons
              Column(
                children: <Widget>[
                  Opacity(
                    opacity: nonce != null && !loading ? 1 : 0,
                    child: Row(
                      children: <Widget>[
                        // I want this Button
                        AppButton.buildAppButton(
                            context, AppButtonType.PRIMARY, "I Want This One", Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                          showSendConfirmSheet();
                        }, disabled: nonce == null || loading || nonce == currentNonce),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      // Go Back Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE,
                          Z.of(context).goBackButton, Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).popUntil((Route route) => route.isFirst);
                      }),
                    ],
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
