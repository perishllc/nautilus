import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/dimens.dart';
import 'package:nautilus_wallet_flutter/styles.dart';
import 'package:nautilus_wallet_flutter/app_icons.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/bus/events.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/model/db/appdb.dart';
import 'package:nautilus_wallet_flutter/ui/contacts/add_contact.dart';
import 'package:nautilus_wallet_flutter/ui/contacts/contact_details.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/buttons.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';

class ContactsList extends StatefulWidget {
  final AnimationController? contactsController;
  bool? contactsOpen;

  ContactsList(this.contactsController, this.contactsOpen);

  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final Logger log = sl.get<Logger>();

  late List<User> _contacts;
  String? documentsDirectory;
  @override
  void initState() {
    super.initState();
    _registerBus();
    // Initial contacts list
    _contacts = [];
    getApplicationDocumentsDirectory().then((directory) {
      documentsDirectory = directory.path;
      setState(() {
        documentsDirectory = directory.path;
      });
      _updateContacts();
    });
  }

  @override
  void dispose() {
    if (_contactAddedSub != null) {
      _contactAddedSub!.cancel();
    }
    if (_contactRemovedSub != null) {
      _contactRemovedSub!.cancel();
    }
    super.dispose();
  }

  StreamSubscription<ContactAddedEvent>? _contactAddedSub;
  StreamSubscription<ContactRemovedEvent>? _contactRemovedSub;

  void _registerBus() {
    // Contact added bus event
    _contactAddedSub = EventTaxiImpl.singleton().registerTo<ContactAddedEvent>().listen((event) {
      // setState(() {
      //   _contacts.add(event.contact);
      //   // Sort by name
      //   _contacts.sort((a, b) {
      //     String c = a.nickname ?? a.username;
      //     String d = b.nickname ?? b.username;
      //     return c.toLowerCase().compareTo(d.toLowerCase());
      //   });
      // });
      // Full update
      _updateContacts();
    });
    // Contact removed bus event
    _contactRemovedSub = EventTaxiImpl.singleton().registerTo<ContactRemovedEvent>().listen((event) {
      // setState(() {
      //   _contacts.remove(event.contact);
      // });
      // Full update
      _updateContacts();
    });
  }

  void _updateContacts() {
    sl.get<DBHelper>().getContacts().then((contacts) {
      if (contacts == null) {
        return;
      }

      // calculate diff:
      List<User> newState = [];

      var aliasMap = Map<String?, List<String?>>();
      List<String?> addressesToRemove = [];

      // search for duplicate address entries:
      for (User user in contacts) {
        if (user.address == null || user.address!.isEmpty) {
          continue;
        }
        if (aliasMap.containsKey(user.address)) {
          // this entry is a duplicate, don't add it to the list:
          if (!addressesToRemove.contains(user.address)) {
            addressesToRemove.add(user.address);
          }
        } else {
          // Create a new entry
          aliasMap[user.address] = [];
        }
        // Add the aliases to the existing entry
        if (user.nickname != null && user.nickname!.isNotEmpty) {
          // check if the alias is already in the list:
          var index = aliasMap[user.address]!.indexOf(user.nickname);
          if (index > -1) {
            if (aliasMap[user.address]![index + 1] != UserTypes.CONTACT) {
              // add it because the matching entry is not a contact
              aliasMap[user.address]!.addAll([user.nickname, UserTypes.CONTACT]);
            }
          } else {
            // add it because it is not in the list
            aliasMap[user.address]!.addAll([user.nickname, UserTypes.CONTACT]);
          }
        }
        if (user.username != null && user.username!.isNotEmpty) {
          aliasMap[user.address]!.addAll([user.username, user.type]);
        }
      }

      // add non-duplicate entries to the list as normal:
      for (User c in contacts) {
        if (addressesToRemove.contains(c.address)) {
          // this entry is a duplicate, don't add it to the list:
          continue;
        }
        newState.add(c);
      }

      // construct the list of users with multiple usernames:
      List<User> multiUsers = [];
      for (String? address in aliasMap.keys) {
        if (!addressesToRemove.contains(address)) {
          // we only want the flagged users
          continue;
        }
        var aliases = aliasMap[address]!;

        String? nickname;
        int? nickNameIndex;
        for (int i = 0; i < aliases.length; i += 2) {
          var alias = aliases[i];
          var type = aliases[i + 1];
          if (type == UserTypes.CONTACT) {
            nickname = alias;
            nickNameIndex = i;
            break;
          }
        }

        if (nickNameIndex != null) {
          aliases.removeAt(nickNameIndex);
          aliases.removeAt(nickNameIndex);
          multiUsers.add(User(address: address, nickname: nickname, username: aliases[0], type: aliases[1], aliases: aliases));
        } else {
          multiUsers.add(User(address: address, username: aliases[0], type: aliases[1], aliases: aliases));
        }
      }

      // add them to the list:
      for (User user in multiUsers) {
        // if (!_contacts.contains(user) && mounted) {
        newState.add(user);
        // }
      }

      // // remove from blocked anything that is not in the newState list:
      // setState(() {
      //   _contacts.removeWhere((e) => !newState.contains(e));
      // });

      // // add anything new:
      // for (User user in newState) {
      //   if (!_contacts.contains(user)) {
      //     setState(() {
      //       _contacts.add(user);
      //     });
      //   }
      // }

      setState(() {
        _contacts = newState;
      });

      // Re-sort list
      setState(() {
        _contacts.sort((a, b) {
          String c = a.nickname ?? a.username!;
          String d = b.nickname ?? b.username!;
          return c.toLowerCase().compareTo(d.toLowerCase());
        });
      });
    });
  }

  Future<void> _exportContacts() async {
    List<User> contacts = await sl.get<DBHelper>().getContacts();
    if (contacts.length == 0) {
      UIUtil.showSnackbar(AppLocalization.of(context)!.noContactsExport, context);
      return;
    }
    List<Map<String, dynamic>> jsonList = [];
    contacts.forEach((contact) {
      jsonList.add(contact.toJson());
    });
    DateTime exportTime = DateTime.now();
    String filename = "nautiluscontacts_${exportTime.year}${exportTime.month}${exportTime.day}${exportTime.hour}${exportTime.minute}${exportTime.second}.txt";
    Directory baseDirectory = await getApplicationDocumentsDirectory();
    File contactsFile = File("${baseDirectory.path}/$filename");
    await contactsFile.writeAsString(json.encode(jsonList));
    UIUtil.cancelLockEvent();
    Share.shareFiles(["${baseDirectory.path}/$filename"]);
  }

  Future<void> _importContacts() async {
    UIUtil.cancelLockEvent();
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ["txt"]);
    if (result != null) {
      File f = File(result.files.single.path!);
      if (!await f.exists()) {
        UIUtil.showSnackbar(AppLocalization.of(context)!.contactsImportErr, context);
        return;
      }
      try {
        String contents = await f.readAsString();
        Iterable contactsJson = json.decode(contents);
        List<User> contacts = [];
        List<User> contactsToAdd = [];
        contactsJson.forEach((contact) {
          contacts.add(User.fromJson(contact));
        });
        for (User contact in contacts) {
          if (!await sl.get<DBHelper>().contactExistsWithName(contact.nickname!) && !await sl.get<DBHelper>().contactExistsWithAddress(contact.address!)) {
            // Contact doesnt exist, make sure name and address are valid
            if (Address(contact.address).isValid()) {
              if (contact.nickname!.startsWith("★") && contact.nickname!.length <= 20) {
                contactsToAdd.add(contact);
              }
            }
          }
        }
        // Save all the new contacts and update states
        int numSaved = await sl.get<DBHelper>().saveContacts(contactsToAdd);
        if (numSaved > 0) {
          _updateContacts();
          EventTaxiImpl.singleton().fire(ContactModifiedEvent(contact: User(nickname: "", address: "")));
          UIUtil.showSnackbar(AppLocalization.of(context)!.contactsImportSuccess.replaceAll("%1", numSaved.toString()), context);
        } else {
          UIUtil.showSnackbar(AppLocalization.of(context)!.noContactsImport, context);
        }
      } catch (e) {
        log.e(e.toString(), e);
        UIUtil.showSnackbar(AppLocalization.of(context)!.contactsImportErr, context);
        return;
      }
    } else {
      // Cancelled by user
      log.e("FilePicker cancelled by user");
      UIUtil.showSnackbar(AppLocalization.of(context)!.contactsImportErr, context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          boxShadow: [
            BoxShadow(color: StateContainer.of(context).curTheme.barrierWeakest!, offset: Offset(-5, 0), blurRadius: 20),
          ],
        ),
        child: SafeArea(
          minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.035,
            top: 60,
          ),
          child: Column(
            children: <Widget>[
              // Back button and Contacts Text
              Container(
                margin: EdgeInsets.only(bottom: 10.0, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        //Back button
                        Container(
                          height: 40,
                          width: 40,
                          margin: EdgeInsets.only(right: 10, left: 10),
                          child: FlatButton(
                              highlightColor: StateContainer.of(context).curTheme.text15,
                              splashColor: StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                setState(() {
                                  widget.contactsOpen = false;
                                });
                                widget.contactsController!.reverse();
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(8.0),
                              child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                        //Contacts Header Text
                        Text(
                          AppLocalization.of(context)!.favoritesHeader,
                          style: AppStyles.textStyleSettingsHeader(context),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        // //Import button
                        Container(
                          height: 40,
                          width: 40,
                          margin: EdgeInsetsDirectional.only(end: 5),
                          child: FlatButton(
                              highlightColor: StateContainer.of(context).curTheme.text15,
                              splashColor: StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                _importContacts();
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(8.0),
                              child: Icon(AppIcons.import_icon, color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                        //Export button
                        Container(
                          height: 40,
                          width: 40,
                          margin: EdgeInsetsDirectional.only(end: 20),
                          child: FlatButton(
                              highlightColor: StateContainer.of(context).curTheme.text15,
                              splashColor: StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                _exportContacts();
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(8.0),
                              child: Icon(AppIcons.export_icon, color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Contacts list + top and bottom gradients
              Expanded(
                child: Stack(
                  children: <Widget>[
                    // Contacts list
                    ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 15.0, bottom: 15),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        // Build contact
                        return buildSingleContact(context, _contacts[index]);
                      },
                    ),
                    //List Top Gradient End
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 20.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [StateContainer.of(context).curTheme.backgroundDark!, StateContainer.of(context).curTheme.backgroundDark00!],
                            begin: AlignmentDirectional(0.5, -1.0),
                            end: AlignmentDirectional(0.5, 1.0),
                          ),
                        ),
                      ),
                    ),
                    //List Bottom Gradient End
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 15.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              StateContainer.of(context).curTheme.backgroundDark00!,
                              StateContainer.of(context).curTheme.backgroundDark!,
                            ],
                            begin: AlignmentDirectional(0.5, -1.0),
                            end: AlignmentDirectional(0.5, 1.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    AppButton.buildAppButton(context, AppButtonType.TEXT_OUTLINE, AppLocalization.of(context)!.addFavorite, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Sheets.showAppHeightEightSheet(context: context, widget: AddContactSheet());
                    }),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  List<Widget> buildItemTexts(User user) {
    if (user.aliases == null) {
      return [
        // nickname
        (user.nickname != null) ? Text("★" + user.nickname!, style: AppStyles.textStyleSettingItemHeader(context)) : SizedBox(),

        (user.username != null)
            ? Text(
                user.getDisplayName(ignoreNickname: true)!,
                style: user.nickname != null ? AppStyles.textStyleTransactionAddress(context) : AppStyles.textStyleSettingItemHeader(context),
              )
            : SizedBox(),

        // Blocked address
        (user.address != null)
            ? Text(
                Address(user.address).getShortString()!,
                style: AppStyles.textStyleTransactionAddress(context),
              )
            : SizedBox(),
      ];
    } else {
      List<Widget> entries = [
        Text(
          user.getDisplayName()!,
          style: AppStyles.textStyleSettingItemHeader(context),
        ),
        Text(
          Address(user.address).getShortString()!,
          style: AppStyles.textStyleTransactionAddress(context),
        )
      ];

      for (var i = 0; i < user.aliases!.length; i += 2) {
        String displayName = User.getDisplayNameWithType(user.aliases![i], user.aliases![i + 1])!;
        entries.add(
          Text(
            displayName,
            style: AppStyles.textStyleTransactionAddress(context),
          ),
        );
      }

      return entries;
    }
  }

  Widget buildSingleContact(BuildContext context, User user) {
    return FlatButton(
      onPressed: () {
        ContactDetailsSheet(user, documentsDirectory).mainBottomSheet(context);
      },
      padding: EdgeInsets.all(0.0),
      child: Column(children: <Widget>[
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        // Main Container
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          margin: new EdgeInsetsDirectional.only(start: 12.0, end: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Contact info
              Expanded(
                child: Container(
                  // height: 60,
                  margin: EdgeInsetsDirectional.only(start: StateContainer.of(context).natriconOn! ? 2.0 : 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildItemTexts(user),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
