import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/ui/util/handlebars.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/caseconverter.dart';


class ContactDetailsSheet extends StatefulWidget {
  const ContactDetailsSheet({super.key, required this.contact, this.documentsDirectory});

  final User contact;
  final String? documentsDirectory;

  @override
  ContactDetailsSheetState createState() => ContactDetailsSheetState();
}

class ContactDetailsSheetState extends State<ContactDetailsSheet> {

  // State variables
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer? _addressCopiedTimer;

  List<Widget> getAliases(BuildContext context, User user) {
    List<Widget> aliases = <Widget>[];
    if (user.aliases == null) {
      aliases = [
        if (user.username != null)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.105,
              right: MediaQuery.of(context).size.width * 0.105,
              top: 15.0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: StateContainer.of(context).curTheme.backgroundDarkest,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              user.getDisplayName(ignoreNickname: true)!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                color: StateContainer.of(context).curTheme.primary,
                fontFamily: "NunitoSans",
              ),
            ),
          ),
      ];
    } else {
      for (int i = 0; i < user.aliases!.length; i += 2) {
        String? displayName = user.aliases![i];
        final String? userType = user.aliases![i + 1];
        displayName = User.getDisplayNameWithType(displayName, userType);
        aliases.add(Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.105,
            right: MediaQuery.of(context).size.width * 0.105,
            top: 15.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: StateContainer.of(context).curTheme.backgroundDarkest,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            displayName!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
              color: StateContainer.of(context).curTheme.primary,
              fontFamily: "NunitoSans",
            ),
          ),
        ));
      }
    }

    final Container aliasContainer = Container(
      constraints: const BoxConstraints(minHeight: 50, maxHeight: 400),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: aliases,
          ),
        ),
      ),
    );

    return [aliasContainer];
  }

  List<Widget> combineLists(List<Widget> list1, List<Widget> list2) {
    final List<Widget> combinedList = [];
    combinedList.addAll(list2);
    combinedList.addAll(list1);
    return combinedList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
      child: Column(
        children: <Widget>[
          Handlebars.horizontal(context),
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
                        Z.of(context).removeContactConfirmation.replaceAll("%1", widget.contact.getDisplayName()!),
                        CaseChange.toUpperCase(Z.of(context).yes, context), () {
                      sl.get<DBHelper>().deleteContact(widget.contact).then((bool deleted) {
                        if (deleted) {
                          EventTaxiImpl.singleton().fire(ContactRemovedEvent(contact: widget.contact));
                          EventTaxiImpl.singleton().fire(ContactModifiedEvent(contact: widget.contact));
                          UIUtil.showSnackbar(
                              Z.of(context).contactRemoved.replaceAll("%1", widget.contact.getDisplayName()!), context);
                          Navigator.of(context).pop();
                        } else {
                          // TODO - error for failing to delete contact
                        }
                      });
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
                      CaseChange.toUpperCase(Z.of(context).contactHeader, context),
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
                  ),
                  // highlightColor: StateContainer.of(context).curTheme.text15,
                  // splashColor: StateContainer.of(context).curTheme.text15,
                  onPressed: () async {
                    await UIUtil.showAccountWebview(context, widget.contact.address);
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
                children: combineLists(
                  getAliases(context, widget.contact),
                  [
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
                        widget.contact.getDisplayName()!,
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
                    if (widget.contact.address != null)
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.contact.address ?? ""));
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
                          child: UIUtil.threeLineAddressText(context, widget.contact.address!,
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
                    if (widget.contact.aliases != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              CaseChange.toUpperCase(Z.of(context).aliases, context),
                              style: AppStyles.textStyleHeader(context),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // A column with "Send" and "Close" buttons
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  // Send Button
                  AppButton.buildAppButton(context, AppButtonType.PRIMARY, Z.of(context).send, Dimens.BUTTON_TOP_DIMENS,
                      disabled: StateContainer.of(context).wallet!.accountBalance == BigInt.zero, onPressed: () {
                    Navigator.of(context).pop();
                    Sheets.showAppHeightNineSheet(
                        context: context,
                        widget: SendSheet(localCurrency: StateContainer.of(context).curCurrency, user: widget.contact));
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
    );
  }
}
