import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/account.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/util/formatters.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/app_text_field.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/tap_outside_unfocus.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

// Account Details Sheet
// ignore: must_be_immutable
class AccountDetailsSheet extends StatefulWidget {
  AccountDetailsSheet({required this.account}) : super();
  Account account;

  @override
  AccountDetailsSheetState createState() => AccountDetailsSheetState();
}

class AccountDetailsSheetState extends State<AccountDetailsSheet> {
  String? originalName;
  TextEditingController? _nameController;
  FocusNode? _nameFocusNode;
  bool deleted = false;
  // Address copied or not
  late bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  @override
  void initState() {
    super.initState();
    originalName = widget.account.name;
  }

  Future<bool> _save() async {
    // Update name if changed and valid
    if (originalName != _nameController!.text && _nameController!.text.trim().isNotEmpty && !deleted) {
      sl.get<DBHelper>().changeAccountName(widget.account, _nameController!.text);
      widget.account.name = _nameController!.text;
      EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: widget.account));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _addressCopied = false;
    _nameController = TextEditingController(text: widget.account.name);
    _nameFocusNode = FocusNode();
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return TapOutsideUnfocus(
        child: SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Trashcan Button
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: widget.account.index == 0
                        ? const SizedBox()
                        : AppDialogs.infoButton(
                            context,
                            () {
                              AppDialogs.showConfirmDialog(
                                  context,
                                  Z.of(context).hideAccountHeader,
                                  Z.of(context).removeAccountText.replaceAll("%1", Z.of(context).addAccount),
                                  CaseChange.toUpperCase(Z.of(context).yes, context), () {
                                // Remove account
                                deleted = true;
                                sl.get<DBHelper>().deleteAccount(widget.account).then((int id) {
                                  EventTaxiImpl.singleton()
                                      .fire(AccountModifiedEvent(account: widget.account, deleted: true));
                                  Navigator.of(context).pop();
                                });
                              }, cancelText: CaseChange.toUpperCase(Z.of(context).no, context));
                            },
                            icon: AppIcons.trashcan,
                          ),
                  ),

                  // The header of the sheet
                  Column(
                    children: [
                      Handlebars.horizontal(
                        context,
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 25.0),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              CaseChange.toUpperCase(Z.of(context).account, context),
                              style: AppStyles.textStyleHeader(context),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              stepGranularity: 0.1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Search Button
                  const SizedBox(height: 60, width: 60),
                ],
              ),
              // Address Text
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: widget.account.address != null
                    ? UIUtil.threeLineAddressText(context, widget.account.address!,
                        type: ThreeLineAddressTextType.PRIMARY60)
                    : widget.account.selected
                        ? UIUtil.threeLineAddressText(context, StateContainer.of(context).wallet!.address!,
                            type: ThreeLineAddressTextType.PRIMARY60)
                        : const SizedBox(),
              ),
              // Balance Text
              if (widget.account.balance != null || widget.account.selected)
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                          text: "(",
                          style: TextStyle(
                            color: StateContainer.of(context).curTheme.primary60,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w100,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                        TextSpan(
                          text: getRawAsThemeAwareFormattedAmount(
                              context,
                              widget.account.balance ??
                                  StateContainer.of(context).wallet?.accountBalance.toString() ??
                                  "0"),
                          style: TextStyle(
                            color: StateContainer.of(context).curTheme.primary60,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                        TextSpan(
                          text: getCurrencySuffix(context),
                          style: TextStyle(
                            color: StateContainer.of(context).curTheme.primary60,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w100,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // The main container that holds Contact Name and Contact Address
              Expanded(
                child: KeyboardAvoider(
                    duration: Duration.zero,
                    autoScroll: true,
                    focusPadding: 40,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      AppTextField(
                        topMargin: MediaQuery.of(context).size.width * 0.14,
                        rightMargin: MediaQuery.of(context).size.width * 0.105,
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                        ],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: StateContainer.of(context).curTheme.primary,
                          fontFamily: "NunitoSans",
                        ),
                      ),
                    ])),
              ),
              Column(
                children: <Widget>[
                  // Row(
                  //   children: <Widget>[
                  //     AppButton.buildAppButton(
                  //         context,
                  //         // Share Address Button
                  //         _addressCopied ? AppButtonType.SUCCESS : AppButtonType.PRIMARY,
                  //         _addressCopied ? Z.of(context).addressCopied : Z.of(context).copyAddress,
                  //         Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                  //       Clipboard.setData(ClipboardData(text: widget.account.address ?? ""));
                  //       setState(() {
                  //         // Set copied style
                  //         _addressCopied = true;
                  //       });
                  //       if (_addressCopiedTimer != null) {
                  //         _addressCopiedTimer!.cancel();
                  //       }
                  //       _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                  //         setState(() {
                  //           _addressCopied = false;
                  //         });
                  //       });
                  //     }),
                  //   ],
                  // ),
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, Z.of(context).save, Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        _save();
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY_OUTLINE, Z.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
                          onPressed: () {
                        _save();
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
