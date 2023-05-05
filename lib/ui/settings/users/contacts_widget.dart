import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as cont;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/contacts_setting_change_event.dart';
import 'package:wallet_flutter/bus/events.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/contacts/add_contact.dart';
import 'package:wallet_flutter/ui/contacts/contact_details.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class ContactsList extends StatefulWidget {
  ContactsList(this.contactsController, this.contactsOpen);

  final AnimationController? contactsController;
  bool? contactsOpen;
  bool contactsEnabled = false;

  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final Logger log = sl.get<Logger>();

  late List<User> _contacts;
  String? documentsDirectory;

  Future<bool> _getContactsPermissions() async {
    // reloading prefs:
    await sl.get<SharedPrefsUtil>().reload();
    final bool contactsOn = await sl.get<SharedPrefsUtil>().getContactsOn();

    // ask for contacts permission:
    if (!contactsOn) {
      final bool contactsEnabled = await cont.FlutterContacts.requestPermission();
      await sl.get<SharedPrefsUtil>().setContactsOn(contactsEnabled);
      EventTaxiImpl.singleton().fire(ContactsSettingChangeEvent(isOn: contactsEnabled));
      return contactsEnabled;
    } else {
      EventTaxiImpl.singleton().fire(ContactsSettingChangeEvent(isOn: contactsOn));
      return contactsOn;
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    // Initial contacts list
    _contacts = [];
    getApplicationDocumentsDirectory().then((Directory directory) {
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
    if (_contactSettingSub != null) {
      _contactSettingSub!.cancel();
    }
    super.dispose();
  }

  StreamSubscription<ContactAddedEvent>? _contactAddedSub;
  StreamSubscription<ContactRemovedEvent>? _contactRemovedSub;
  StreamSubscription<ContactsSettingChangeEvent>? _contactSettingSub;

  void _registerBus() {
    // Contact added bus event
    _contactAddedSub = EventTaxiImpl.singleton().registerTo<ContactAddedEvent>().listen((ContactAddedEvent event) {
      // Full update
      _updateContacts();
    });
    // Contact removed bus event
    _contactRemovedSub =
        EventTaxiImpl.singleton().registerTo<ContactRemovedEvent>().listen((ContactRemovedEvent event) {
      // Full update
      _updateContacts();
    });
    // Contact Setting bus event
    _contactSettingSub =
        EventTaxiImpl.singleton().registerTo<ContactsSettingChangeEvent>().listen((ContactsSettingChangeEvent event) {
      setState(() {
        widget.contactsEnabled = event.isOn;
      });
      // Full update
      _updateContacts();
    });
  }

  Future<void> _updateContacts() async {
    // start with an empty list:
    final List<User> newState = [];

    if (widget.contactsEnabled) {
      List<Contact> contacts = [];
      try {
        contacts = await cont.FlutterContacts.getContacts(withProperties: true);
      } catch (e) {
        log.e(e.toString());
        return;
      }

      for (final Contact contact in contacts) {
        if (contact.phones.isNotEmpty) {
          User contactUser = User();
          contactUser.nickname = contact.displayName;
          contactUser.aliases = [contact.phones[0].number, "Number"];
          newState.add(contactUser);
        }
      }
    }

    sl.get<DBHelper>().getContacts().then((List<User> contacts) {
      if (contacts == null) {
        return;
      }

      // calculate diff:

      final Map<String?, List<String?>> aliasMap = Map<String?, List<String?>>();
      final List<String?> addressesToRemove = [];

      // search for duplicate address entries:
      for (final User user in contacts) {
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
          final int index = aliasMap[user.address]!.indexOf(user.nickname);
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
      for (final User c in contacts) {
        if (addressesToRemove.contains(c.address)) {
          // this entry is a duplicate, don't add it to the list:
          continue;
        }
        newState.add(c);
      }

      // construct the list of users with multiple usernames:
      final List<User> multiUsers = [];
      for (final String? address in aliasMap.keys) {
        if (!addressesToRemove.contains(address)) {
          // we only want the flagged users
          continue;
        }
        final List<String?> aliases = aliasMap[address]!;

        String? nickname;
        int? nickNameIndex;
        for (int i = 0; i < aliases.length; i += 2) {
          final String? alias = aliases[i];
          final String? type = aliases[i + 1];
          if (type == UserTypes.CONTACT) {
            nickname = alias;
            nickNameIndex = i;
            break;
          }
        }

        if (nickNameIndex != null) {
          aliases.removeAt(nickNameIndex);
          aliases.removeAt(nickNameIndex);
          multiUsers.add(
              User(address: address, nickname: nickname, username: aliases[0], type: aliases[1], aliases: aliases));
        } else {
          multiUsers.add(User(address: address, username: aliases[0], type: aliases[1], aliases: aliases));
        }
      }

      // add them to the list:
      for (int j = 0; j < multiUsers.length; j++) {
        final User user = multiUsers[j];
        newState.add(user);
      }

      if (mounted) {
        setState(() {
          _contacts = newState;
        });

        // Re-sort list
        setState(() {
          _contacts.sort((User a, User b) {
            final String c = a.nickname ?? a.username!;
            final String d = b.nickname ?? b.username!;
            return c.toLowerCase().compareTo(d.toLowerCase());
          });
        });
      }
    });
  }

  Future<void> _exportContacts() async {
    final List<User> contacts = await sl.get<DBHelper>().getContacts();
    if (!mounted) {
      return;
    }
    if (contacts.isEmpty) {
      UIUtil.showSnackbar(Z.of(context).noContactsExport, context);
      return;
    }
    final List<Map<String, dynamic>> jsonList = [];
    for (final User contact in contacts) {
      jsonList.add(contact.toJson());
    }
    final DateTime exportTime = DateTime.now();
    final String filename =
        "nautilus_contacts_${exportTime.year}${exportTime.month}${exportTime.day}${exportTime.hour}${exportTime.minute}${exportTime.second}.json";
    final Directory baseDirectory = await getApplicationDocumentsDirectory();
    final File contactsFile = File("${baseDirectory.path}/$filename");
    await contactsFile.writeAsString(json.encode(jsonList));
    UIUtil.cancelLockEvent();
    Share.shareFiles(["${baseDirectory.path}/$filename"]);
  }

  Future<void> _importContacts() async {
    UIUtil.cancelLockEvent();
    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ["txt", "json"]);
    if (result != null) {
      final File f = File(result.files.single.path!);
      if (!await f.exists()) {
        if (!mounted) {
          return;
        }
        UIUtil.showSnackbar(Z.of(context).contactsImportErr, context);
        return;
      }
      try {
        final String contents = await f.readAsString();
        final List<dynamic> contactsJson = json.decode(contents) as List<dynamic>;
        final List<User> contacts = [];
        final List<User> contactsToAdd = [];
        for (final dynamic contact in contactsJson) {
          contacts.add(User.fromJson(contact as Map<String, dynamic>));
        }
        for (final User contact in contacts) {
          if (!await sl.get<DBHelper>().contactExistsWithName(contact.nickname!) &&
              !await sl.get<DBHelper>().contactExistsWithAddress(contact.address!)) {
            // Contact doesn't exist, make sure name and address are valid
            if (Address(contact.address).isValid()) {
              if (contact.nickname!.length <= 20) {
                contactsToAdd.add(contact);
              }
            }
          }
        }
        // Save all the new contacts and update states
        final int numSaved = await sl.get<DBHelper>().saveContacts(contactsToAdd);
        if (!mounted) {
          return;
        }
        if (numSaved > 0) {
          _updateContacts();
          EventTaxiImpl.singleton().fire(ContactModifiedEvent(contact: User(nickname: "", address: "")));
          UIUtil.showSnackbar(Z.of(context).contactsImportSuccess.replaceAll("%1", numSaved.toString()), context);
        } else {
          UIUtil.showSnackbar(Z.of(context).noContactsImport, context);
        }
      } catch (e) {
        log.e(e.toString(), e);
        if (!mounted) {
          return;
        }
        UIUtil.showSnackbar(Z.of(context).contactsImportErr, context);
        return;
      }
    } else {
      // Cancelled by user
      log.e("FilePicker cancelled by user");
      if (!mounted) {
        return;
      }
      UIUtil.showSnackbar(Z.of(context).contactsImportErr, context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          boxShadow: [
            BoxShadow(
                color: StateContainer.of(context).curTheme.barrierWeakest!,
                offset: const Offset(-5, 0),
                blurRadius: 20),
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
                margin: const EdgeInsets.only(bottom: 10.0, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Back button
                        Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsets.only(right: 10, left: 10),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: StateContainer.of(context).curTheme.text15,
                                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                padding: const EdgeInsets.all(8.0),
                                // splashColor: StateContainer.of(context).curTheme.text15,
                                // highlightColor: StateContainer.of(context).curTheme.text15,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.contactsOpen = false;
                                });
                                widget.contactsController!.reverse();
                              },
                              child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                        //Contacts Header Text
                        Text(
                          Z.of(context).contactsHeader,
                          style: AppStyles.textStyleSettingsHeader(context),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        // Import button
                        Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsetsDirectional.only(end: 5),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: StateContainer.of(context).curTheme.text15,
                                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                padding: const EdgeInsets.all(8.0),
                                // splashColor: StateContainer.of(context).curTheme.text15,
                                // highlightColor: StateContainer.of(context).curTheme.text15,
                              ),
                              onPressed: () {
                                _importContacts();
                              },
                              child: Icon(AppIcons.file_import,
                                  color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                        // Export button
                        Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsetsDirectional.only(end: 20),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: StateContainer.of(context).curTheme.text15,
                                backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                                padding: const EdgeInsets.all(8.0),
                                // splashColor: StateContainer.of(context).curTheme.text15,
                                // highlightColor: StateContainer.of(context).curTheme.text15,
                              ),
                              onPressed: () {
                                _exportContacts();
                              },
                              child: Icon(AppIcons.file_export,
                                  color: StateContainer.of(context).curTheme.text, size: 24)),
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
                      padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                      itemCount: _contacts.length,
                      itemBuilder: (BuildContext context, int index) {
                        // Build contact
                        return buildSingleContact(context, _contacts[index], index);
                      },
                    ),
                    ListGradient(
                      height: 20,
                      top: true,
                      color: StateContainer.of(context).curTheme.backgroundDark!,
                    ),
                    ListGradient(
                      height: 20,
                      top: false,
                      color: StateContainer.of(context).curTheme.backgroundDark!,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context, AppButtonType.TEXT_OUTLINE, Z.of(context).addContact, Dimens.BUTTON_BOTTOM_DIMENS,
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
        if (user.nickname != null) Text("★${user.nickname!}", style: AppStyles.textStyleSettingItemHeader(context)),

        if (user.username != null)
          Text(
            user.getDisplayName(ignoreNickname: true)!,
            style: user.nickname != null
                ? AppStyles.textStyleTransactionAddress(context)
                : AppStyles.textStyleSettingItemHeader(context),
          ),

        // address
        if (user.address != null)
          Text(
            Address(user.address).getShortString() ?? user.address!,
            style: AppStyles.textStyleTransactionAddress(context),
          ),
      ];
    } else {
      final List<Widget> entries = [
        Text(
          user.getDisplayName()!,
          style: AppStyles.textStyleSettingItemHeader(context),
        ),
        if (user.address != null)
          Text(
            Address(user.address).getShortString()!,
            style: AppStyles.textStyleTransactionAddress(context),
          )
      ];

      for (int i = 0; i < user.aliases!.length; i += 2) {
        final String displayName = User.getDisplayNameWithType(user.aliases![i], user.aliases![i + 1])!;
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

  Widget buildSingleContact(BuildContext context, User user, int index) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      onPressed: () {
        Sheets.showAppHeightEightSheet(
          context: context,
          widget: ContactDetailsSheet(
            contact: user,
            documentsDirectory: documentsDirectory,
          ),
        );
      },
      child: Column(children: <Widget>[
        Divider(
          height: 2,
          color: StateContainer.of(context).curTheme.text15,
        ),
        // Main Container
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          margin: const EdgeInsetsDirectional.only(start: 12.0, end: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Contact info
              Expanded(
                child: Container(
                  // height: 60,
                  margin: const EdgeInsetsDirectional.only(start: 20.0),
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
        if (index == _contacts.length - 1)
          Divider(
            height: 2,
            color: StateContainer.of(context).curTheme.text15,
          ),
      ]),
    );
  }
}
