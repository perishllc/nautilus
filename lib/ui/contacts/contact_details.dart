import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:event_taxi/event_taxi.dart';

import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/model/db/contact.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/ui/send/send_sheet.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/dialog.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheets.dart';
import 'package:nautilus_wallet_flutter/util/caseconverter.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Contact Details Sheet
class ContactDetailsSheet {
  User contact;
  String documentsDirectory;

  ContactDetailsSheet(this.contact, this.documentsDirectory);

  // State variables
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  List<Widget> getAliases(BuildContext context, User user) {
    var aliases = <Widget>[];
    if (user.aliases == null) {
      aliases = [
        (user.username != null)
            ? Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.105,
                  right: MediaQuery.of(context).size.width * 0.105,
                  top: 15.0,
                ),
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: StateContainer.of(context).curTheme.backgroundDarkest,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  user.getDisplayName(ignoreNickname: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: StateContainer.of(context).curTheme.primary,
                    fontFamily: 'NunitoSans',
                  ),
                ),
              )
            : SizedBox(),
      ];
    } else {
      for (var i = 0; i < user.aliases.length; i += 2) {
        String displayName = user.aliases[i];
        String userType = user.aliases[i + 1];
        displayName = User.getDisplayNameWithType(displayName, userType);
        aliases.add(Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.105,
            right: MediaQuery.of(context).size.width * 0.105,
            top: 15.0,
          ),
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: StateContainer.of(context).curTheme.backgroundDarkest,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
              color: StateContainer.of(context).curTheme.primary,
              fontFamily: 'NunitoSans',
            ),
          ),
        ));
      }
    }

    var aliasContainer = Container(
      constraints: BoxConstraints(minHeight: 50, maxHeight: 400),
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
    List<Widget> combinedList = [];
    combinedList.addAll(list2);
    combinedList.addAll(list1);
    return combinedList;
  }

  mainBottomSheet(BuildContext context) {
    AppSheets.showAppHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
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
                          margin: EdgeInsetsDirectional.only(top: 10.0, start: 10.0),
                          child: FlatButton(
                            highlightColor: StateContainer.of(context).curTheme.text15,
                            splashColor: StateContainer.of(context).curTheme.text15,
                            onPressed: () {
                              AppDialogs.showConfirmDialog(
                                  context,
                                  AppLocalization.of(context).removeFavorite,
                                  AppLocalization.of(context).removeFavoriteConfirmation.replaceAll("%1", contact.getDisplayName()),
                                  CaseChange.toUpperCase(AppLocalization.of(context).yes, context), () {
                                sl.get<DBHelper>().deleteContact(contact).then((deleted) {
                                  if (deleted) {
                                    EventTaxiImpl.singleton().fire(ContactRemovedEvent(contact: contact));
                                    EventTaxiImpl.singleton().fire(ContactModifiedEvent(contact: contact));
                                    UIUtil.showSnackbar(AppLocalization.of(context).favoriteRemoved.replaceAll("%1", contact.getDisplayName()), context);
                                    Navigator.of(context).pop();
                                  } else {
                                    // TODO - error for failing to delete contact
                                  }
                                });
                              }, cancelText: CaseChange.toUpperCase(AppLocalization.of(context).no, context));
                            },
                            child: Icon(AppIcons.trashcan, size: 24, color: StateContainer.of(context).curTheme.text),
                            padding: EdgeInsets.all(13.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                          ),
                        ),
                        // The header of the sheet
                        Container(
                          margin: EdgeInsets.only(top: 25.0),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                          child: Column(
                            children: <Widget>[
                              AutoSizeText(
                                CaseChange.toUpperCase(AppLocalization.of(context).favoriteHeader, context),
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
                          margin: EdgeInsetsDirectional.only(top: 10.0, end: 10.0),
                          child: FlatButton(
                            highlightColor: StateContainer.of(context).curTheme.text15,
                            splashColor: StateContainer.of(context).curTheme.text15,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                                return UIUtil.showAccountWebview(context, contact.address);
                              }));
                            },
                            child: Icon(AppIcons.search, size: 24, color: StateContainer.of(context).curTheme.text),
                            padding: EdgeInsets.all(13.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                          ),
                        ),
                      ],
                    ),

                    // The main container that holds Contact Name and Contact Address
                    Expanded(
                      child: Container(
                        padding: EdgeInsetsDirectional.only(top: 4, bottom: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: combineLists(
                            getAliases(context, contact),
                            [
                              // Contact Name container
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.105,
                                  right: MediaQuery.of(context).size.width * 0.105,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: StateContainer.of(context).curTheme.backgroundDarkest,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  contact.getDisplayName(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                    color: StateContainer.of(context).curTheme.primary,
                                    fontFamily: 'NunitoSans',
                                  ),
                                ),
                              ),
                              // Contact Address
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(new ClipboardData(text: contact.address));
                                  setState(() {
                                    _addressCopied = true;
                                  });
                                  if (_addressCopiedTimer != null) {
                                    _addressCopiedTimer.cancel();
                                  }
                                  _addressCopiedTimer = new Timer(const Duration(milliseconds: 800), () {
                                    setState(() {
                                      _addressCopied = false;
                                    });
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width * 0.105, right: MediaQuery.of(context).size.width * 0.105, top: 15),
                                  padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context).curTheme.backgroundDarkest,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: UIUtil.threeLineAddressText(context, contact.address,
                                      type: _addressCopied ? ThreeLineAddressTextType.SUCCESS_FULL : ThreeLineAddressTextType.PRIMARY),
                                ),
                              ),
                              // Address Copied text container
                              Container(
                                margin: EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(_addressCopied ? AppLocalization.of(context).addressCopied : "",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: StateContainer.of(context).curTheme.success,
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              (contact.aliases != null)
                                  ?
                                  // "ALIASES" text container
                                  Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            CaseChange.toUpperCase(AppLocalization.of(context).aliases, context),
                                            style: AppStyles.textStyleHeader(context),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // A column with "Send" and "Close" buttons
                    Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              // Send Button
                              AppButton.buildAppButton(context, AppButtonType.PRIMARY, AppLocalization.of(context).send, Dimens.BUTTON_TOP_DIMENS,
                                  disabled: StateContainer.of(context).wallet.accountBalance == BigInt.zero, onPressed: () {
                                Navigator.of(context).pop();
                                Sheets.showAppHeightNineSheet(
                                    context: context, widget: SendSheet(localCurrency: StateContainer.of(context).curCurrency, user: contact));
                              }),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              // Close Button
                              AppButton.buildAppButton(context, AppButtonType.PRIMARY_OUTLINE, AppLocalization.of(context).close, Dimens.BUTTON_BOTTOM_DIMENS,
                                  onPressed: () {
                                Navigator.pop(context);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          });
        });
  }
}
