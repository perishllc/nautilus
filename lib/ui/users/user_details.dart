import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';

class UserDetailsSheet extends StatefulWidget {
  const UserDetailsSheet({required this.user, required this.documentsDirectory}) : super();

  final User user;
  final String documentsDirectory;

  @override
  UserDetailsSheetState createState() => UserDetailsSheetState();
}

enum AddressStyle { TEXT60, TEXT90, PRIMARY }

class UserDetailsSheetState extends State<UserDetailsSheet> {
  // State variables
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Trashcan Button
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsetsDirectional.only(top: 10.0, start: 10.0),
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
                        AppDialogs.showConfirmDialog(
                            context,
                            Z.of(context).removeContact,
                            Z.of(context).removeContactConfirmation.replaceAll('%1', widget.user.username!),
                            CaseChange.toUpperCase(Z.of(context).yes, context), () {
                          // sl.get<DBHelper>().deleteContact(user).then((deleted) {
                          //   if (deleted) {
                          //     // Delete image if exists
                          //     EventTaxiImpl.singleton().fire(RemovedEvent(contact: user));
                          //     EventTaxiImpl.singleton().fire(ContactModifiedEvent(contact: user));
                          //     UIUtil.showSnackbar(Z.of(context).contactRemoved.replaceAll("%1", user.username), context);
                          //     Navigator.of(context).pop();
                          //   } else {
                          //     // TODO - error for failing to delete contact
                          //   }
                          // });
                        }, cancelText: CaseChange.toUpperCase(Z.of(context).no, context));
                      },
                      child: Icon(AppIcons.trashcan, size: 24, color: StateContainer.of(context).curTheme.text),
                    ),
                  ),
                  // The header of the sheet
                  Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                    child: Column(
                      children: <Widget>[
                        AutoSizeText(
                          CaseChange.toUpperCase(Z.of(context).favoriteHeader, context),
                          style: AppStyles.textStyleHeader(context),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          stepGranularity: 0.1,
                        ),
                      ],
                    ),
                  ),
                  // Search Button
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
                        Navigator.of(context).push(MaterialPageRoute<dynamic>(builder: (BuildContext context) {
                          UIUtil.showAccountWebview(context, widget.user.address);
                          return const SizedBox();
                        }));
                      },
                      child: Icon(AppIcons.search, size: 24, color: StateContainer.of(context).curTheme.text),
                    ),
                  ),
                ],
              ),

              // The main container that holds Contact Name and Contact Address
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(top: 4, bottom: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Contact Name container
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.105,
                          right: MediaQuery.of(context).size.width * 0.105,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: StateContainer.of(context).curTheme.backgroundDarkest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "★${widget.user.username!}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: StateContainer.of(context).curTheme.primary,
                            fontFamily: "NunitoSans",
                          ),
                        ),
                      ),
                      // Contact Address
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.user.address));
                          setState(() {
                            _addressCopied = true;
                          });
                          if (_addressCopiedTimer != null) {
                            _addressCopiedTimer!.cancel();
                          }
                          _addressCopiedTimer = Timer(const Duration(milliseconds: 800), () {
                            setState(() {
                              _addressCopied = false;
                            });
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.105,
                              right: MediaQuery.of(context).size.width * 0.105,
                              top: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: StateContainer.of(context).curTheme.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: UIUtil.threeLineAddressText(context, widget.user.address!,
                              type: _addressCopied
                                  ? ThreeLineAddressTextType.SUCCESS_FULL
                                  : ThreeLineAddressTextType.PRIMARY),
                        ),
                      ),
                      // Address Copied text container
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(_addressCopied ? Z.of(context).addressCopied : "",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: StateContainer.of(context).curTheme.success,
                              fontFamily: "NunitoSans",
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),
              ),

              // A column with "Send" and "Close" buttons
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Send Button
                      AppButton.buildAppButton(
                          context, AppButtonType.PRIMARY, Z.of(context).send, Dimens.BUTTON_TOP_DIMENS,
                          disabled: StateContainer.of(context).wallet!.accountBalance == BigInt.zero, onPressed: () {
                        Navigator.of(context).pop();
                        Sheets.showAppHeightNineSheet(
                            context: context,
                            widget: SendSheet(localCurrency: StateContainer.of(context).curCurrency, user: widget.user));
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
          ));
    });
  }
}
