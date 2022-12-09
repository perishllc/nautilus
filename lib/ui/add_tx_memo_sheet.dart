
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class AddMemoSheet extends StatefulWidget {
  const AddMemoSheet({Key? key}) : super(key: key);

  

  @override
  _AddMemoSheetState createState() => _AddMemoSheetState();
}

class _AddMemoSheetState extends State<AddMemoSheet> {
  final GlobalKey expandedKey = GlobalKey();
  final FocusNode _memoFocusNode = FocusNode();
  final TextEditingController _memoController = TextEditingController();
  String _memoHint = "";
  String _memoValidationText = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              //A container for the header
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                child: Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text20,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          AutoSizeText(
                            CaseChange.toUpperCase(Z.of(context).watchOnlyAccount, context),
                            style: AppStyles.textStyleHeader(context),
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // The main container that holds "Enter Name" and "Enter Address" text fields
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  child: GestureDetector(
                    onTap: () {
                      // Clear focus of our fields when tapped in this empty space
                      _memoFocusNode.unfocus();
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
                                  // Enter Name Container
                                  AppTextField(
                                    focusNode: _memoFocusNode,
                                    controller: _memoController,
                                    // topMargin: MediaQuery.of(context).size.height * 0.14,
                                    topMargin: 30,
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    textInputAction: TextInputAction.next,
                                    hintText: Z.of(context).enterMemo,
                                    keyboardType: TextInputType.text,

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
                                        _memoValidationText = "";
                                      });
                                    },
                                  ),
                                  // Enter Memo Error Container
                                  Container(
                                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                                    child: Text(_memoValidationText,
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

              const SizedBox(
                height: 15,
              ),
              //A row with Add Account button
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY,
                    Z.of(context).addWatchOnlyAccount,
                    Dimens.BUTTON_TOP_DIMENS,
                    // disabled: _addingAccount,
                    onPressed: () async {
                      TXData txDetails = TXData();
                    },
                  ),
                ],
              ),
              //A row with Close button
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY_OUTLINE,
                    Z.of(context).close,
                    Dimens.BUTTON_BOTTOM_DIMENS,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
