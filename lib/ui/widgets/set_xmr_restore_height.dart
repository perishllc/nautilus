import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class SetXMRRestoreHeightSheet extends StatefulWidget {
  final String? address;

  SetXMRRestoreHeightSheet({this.address}) : super();

  @override
  _SetXMRRestoreHeightSheetState createState() => _SetXMRRestoreHeightSheetState();
}

class _SetXMRRestoreHeightSheetState extends State<SetXMRRestoreHeightSheet> {
  FocusNode? _amountFocusNode;
  TextEditingController? _amountController;

  // State variables
  String? _amountHint;
  String? _amountValidationText;

  @override
  void initState() {
    super.initState();
    // Text field initialization
    _amountFocusNode = FocusNode();
    _amountController = TextEditingController();
    _amountValidationText = "";
    // Add focus listeners
    // On focus change
    _amountFocusNode!.addListener(() {
      if (_amountFocusNode!.hasFocus) {
        setState(() {
          _amountHint = "";
        });
      } else {
        setState(() {
          _amountHint = Z.of(context).enterHeight;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
        child: SafeArea(
      minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
      child: Column(
        children: <Widget>[
          // Top row of the sheet which contains the header and the scan qr button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Empty SizedBox
              const SizedBox(
                width: 60,
                height: 60,
              ),
              // The header of the sheet
              Container(
                margin: EdgeInsets.zero,
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                child: Column(
                  children: <Widget>[
                    Handlebars.horizontal(
                      context,
                      margin: const EdgeInsets.only(top: 10, bottom: 15),
                    ),
                    AutoSizeText(
                      CaseChange.toUpperCase(Z.of(context).setRestoreHeight, context),
                      style: AppStyles.textStyleHeader(context),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      stepGranularity: 0.1,
                    ),
                  ],
                ),
              ),

              // Scan QR Button
              const SizedBox(width: 60, height: 60),
            ],
          ),

          // The main container that holds "Enter Name" and "Enter Address" text fields
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 5, bottom: 5),
              child: GestureDetector(
                onTap: () {
                  // Clear focus of our fields when tapped in this empty space
                  _amountFocusNode!.unfocus();
                },
                child: KeyboardAvoider(
                  duration: Duration.zero,
                  autoScroll: true,
                  focusPadding: 40,
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              // Enter Restore Height Container
                              AppTextField(
                                focusNode: _amountFocusNode,
                                controller: _amountController,
                                // topMargin: MediaQuery.of(context).size.height * 0.14,
                                topMargin: 30,
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                textInputAction: TextInputAction.done,
                                hintText: _amountHint ?? Z.of(context).enterHeight,
                                keyboardType: TextInputType.number,

                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: StateContainer.of(context).curTheme.text,
                                  fontFamily: "NunitoSans",
                                ),
                                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                                onSubmitted: (String text) {
                                  FocusScope.of(context).unfocus();
                                },
                                onChanged: (String text) {
                                  // Always reset the error message to be less annoying
                                  setState(() {
                                    _amountValidationText = "";
                                  });
                                },
                              ),
                              // Enter Amount Error Container
                              Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(_amountValidationText ?? "",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: StateContainer.of(context).curTheme.primary,
                                      fontFamily: "NunitoSans",
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // A column with "Set Restore Height" and "Close" buttons
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  // Set Restore Height Button
                  AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).set, Dimens.BUTTON_TOP_DIMENS,
                      onPressed: () async {
                    if (!await validateForm()) {
                      return;
                    }

                    final int height = int.parse(_amountController!.text);
                    sl.get<SharedPrefsUtil>().setXmrRestoreHeight(height);
                    StateContainer.of(context).setXmrRestoreHeight(height);

                    Navigator.of(context).pop();
                  }),
                ],
              ),
              Row(
                children: <Widget>[
                  // Close Button
                  AppButton.buildAppButton(
                      context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
                      onPressed: () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Future<bool> validateForm() async {
    bool isValid = true;
    final String formAmount = _amountController!.text;
    final int? restoreHeight = int.tryParse(formAmount);

    // if (widget.address == null) {
    if (formAmount.isEmpty) {
      isValid = false;
      setState(() {
        _amountValidationText = Z.of(context).enterHeight;
      });
    } else if (restoreHeight == null || restoreHeight < 0) {
      isValid = false;
      setState(() {
        _amountValidationText = Z.of(context).invalidHeight;
      });
    }
    return isValid;
  }
}
