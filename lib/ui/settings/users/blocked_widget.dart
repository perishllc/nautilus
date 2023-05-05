import 'dart:async';
import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/app_icons.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/blocked_added_event.dart';
import 'package:wallet_flutter/bus/blocked_removed_event.dart';
import 'package:wallet_flutter/dimens.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/users/add_blocked.dart';
import 'package:wallet_flutter/ui/users/blocked_details.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';
import 'package:wallet_flutter/ui/widgets/dialog.dart';
import 'package:wallet_flutter/ui/widgets/list_gradient.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:path_provider/path_provider.dart';

class BlockedList extends StatefulWidget {
  BlockedList(this.blockedController, this.blockedOpen);
  final AnimationController? blockedController;
  bool? blockedOpen;

  @override
  BlockedListState createState() => BlockedListState();
}

class BlockedListState extends State<BlockedList> {
  final Logger log = sl.get<Logger>();

  late List<User> _blocked;
  String? documentsDirectory;
  @override
  void initState() {
    super.initState();
    _registerBus();
    // Initial contacts list
    _blocked = [];
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
    if (_blockedAddedSub != null) {
      _blockedAddedSub!.cancel();
    }
    if (_blockedRemovedSub != null) {
      _blockedRemovedSub!.cancel();
    }
    super.dispose();
  }

  StreamSubscription<BlockedAddedEvent>? _blockedAddedSub;
  StreamSubscription<BlockedRemovedEvent>? _blockedRemovedSub;

  void _registerBus() {
    // Contact added bus event
    _blockedAddedSub = EventTaxiImpl.singleton().registerTo<BlockedAddedEvent>().listen((BlockedAddedEvent event) {
      // Full update:
      _updateContacts();
    });
    // Contact removed bus event
    _blockedRemovedSub =
        EventTaxiImpl.singleton().registerTo<BlockedRemovedEvent>().listen((BlockedRemovedEvent event) {
      // Full update:
      _updateContacts();
    });
  }

  void _updateContacts() {
    sl.get<DBHelper>().getBlocked().then((List<User> blocked) {
      if (blocked == null) {
        return;
      }

      // calculate diff:
      final List<User> newState = [];

      final Map<String?, List<String?>> aliasMap = Map<String?, List<String?>>();
      final List<String?> addressesToRemove = [];

      // search for duplicate address entries:
      for (final User user in blocked) {
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
      for (final User b in blocked) {
        if (addressesToRemove.contains(b.address)) {
          // this entry is a duplicate, don't add it to the list:
          continue;
        }
        newState.add(b);
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
      multiUsers.forEach(newState.add);

      if (mounted) {
        setState(() {
          _blocked = newState;
        });

        // Re-sort list
        setState(() {
          _blocked.sort((User a, User b) {
            final String c = a.nickname ?? a.username!;
            final String d = b.nickname ?? b.username!;
            return c.toLowerCase().compareTo(d.toLowerCase());
          });
        });
      }
    });
  }

  // Future<void> _exportContacts() async {
  //   List<User> contacts = await sl.get<DBHelper>().getBlockedUsers();
  //   if (contacts.length == 0) {
  //     UIUtil.showSnackbar(Z.of(context).noContactsExport, context);
  //     return;
  //   }
  //   List<Map<String, dynamic>> jsonList = [];
  //   contacts.forEach((contact) {
  //     jsonList.add(contact.toJson());
  //   });
  //   DateTime exportTime = DateTime.now();
  //   String filename = "nautilusblocked_${exportTime.year}${exportTime.month}${exportTime.day}${exportTime.hour}${exportTime.minute}${exportTime.second}.txt";
  //   Directory baseDirectory = await getApplicationDocumentsDirectory();
  //   File contactsFile = File("${baseDirectory.path}/$filename");
  //   await contactsFile.writeAsString(json.encode(jsonList));
  //   UIUtil.cancelLockEvent();
  //   Share.shareFile(contactsFile);
  // }

  // Future<void> _importContacts() async {
  //   UIUtil.cancelLockEvent();
  //   FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ["txt"]);
  //   if (result != null) {
  //     File f = File(result.files.single.path);
  //     if (!await f.exists()) {
  //       UIUtil.showSnackbar(Z.of(context).contactsImportErr, context);
  //       return;
  //     }
  //     try {
  //       String contents = await f.readAsString();
  //       Iterable contactsJson = json.decode(contents);
  //       List<User> contacts = [];
  //       List<User> contactsToAdd = List();
  //       contactsJson.forEach((contact) {
  //         contacts.add(User.fromJson(contact));
  //       });
  //       for (User contact in contacts) {
  //         if (!await sl.get<DBHelper>().contactExistsWithName(contact.username) && !await sl.get<DBHelper>().userExistsWithAddress(contact.address)) {
  //           // Contact doesnt exist, make sure name and address are valid
  //           if (Address(contact.address).isValid()) {
  //             if (contact.username.startsWith("★") && contact.username.length <= 20) {
  //               contactsToAdd.add(contact);
  //             }
  //           }
  //         }
  //       }
  //       // Save all the new contacts and update states
  //       int numSaved = await sl.get<DBHelper>().saveContacts(contactsToAdd);
  //       if (numSaved > 0) {
  //         _updateContacts();
  //         EventTaxiImpl.singleton().fire(ContactModifiedEvent(contact: Contact(name: "", address: "")));
  //         UIUtil.showSnackbar(Z.of(context).contactsImportSuccess.replaceAll("%1", numSaved.toString()), context);
  //       } else {
  //         UIUtil.showSnackbar(Z.of(context).noContactsImport, context);
  //       }
  //     } catch (e) {
  //       log.e(e.toString(), e);
  //       UIUtil.showSnackbar(Z.of(context).contactsImportErr, context);
  //       return;
  //     }
  //   } else {
  //     // Cancelled by user
  //     log.e("FilePicker cancelled by user");
  //     UIUtil.showSnackbar(Z.of(context).contactsImportErr, context);
  //     return;
  //   }
  // }

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
                                  widget.blockedOpen = false;
                                });
                                widget.blockedController!.reverse();
                              },
                              child: Icon(AppIcons.back, color: StateContainer.of(context).curTheme.text, size: 24)),
                        ),
                        //Contacts Header Text
                        Text(
                          Z.of(context).blockedHeader,
                          style: AppStyles.textStyleSettingsHeader(context),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 25),
                      child: AppDialogs.infoButton(context, () {
                        AppDialogs.showInfoDialog(context, Z.of(context).blockedInfoHeader, Z.of(context).blockedInfo);
                      }),
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
                      itemCount: _blocked.length,
                      itemBuilder: (BuildContext context, int index) {
                        // Build contact
                        return buildSingleContact(context, _blocked[index], index);
                      },
                    ),
                    ListGradient(
                      height: 20,
                      top: true,
                      color: StateContainer.of(context).curTheme.backgroundDark!,
                    ),
                    ListGradient(
                      height: 15,
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
                        context, AppButtonType.TEXT_OUTLINE, Z.of(context).addBlocked, Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                      Sheets.showAppHeightEightSheet(context: context, widget: AddBlockedSheet());
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
        // Blocked name
        if (user.nickname != null && user.nickname!.isNotEmpty)
          Text("★${user.nickname!}", style: AppStyles.textStyleSettingItemHeader(context)),

        if (user.username != null)
          Text(
            user.getDisplayName(ignoreNickname: true)!,
            style: user.nickname != null
                ? AppStyles.textStyleTransactionAddress(context)
                : AppStyles.textStyleSettingItemHeader(context),
          ),

        // Blocked address
        if (user.address != null)
          Text(
            Address(user.address).getShortString()!,
            style: AppStyles.textStyleTransactionAddress(context),
          ),
      ];
    } else {
      final List<Widget> entries = [
        Text(
          Address(user.address).getShortString()!,
          style: user.nickname != null
              ? AppStyles.textStyleTransactionAddress(context)
              : AppStyles.textStyleSettingItemHeader(context),
        )
      ];

      if (user.nickname != null && user.nickname!.isNotEmpty) {
        entries.insert(0, Text(user.getDisplayName()!, style: AppStyles.textStyleSettingItemHeader(context)));
      }

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
          widget: BlockedDetailsSheet(
            blocked: user,
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
        if (index == _blocked.length - 1)
          Divider(
            height: 2,
            color: StateContainer.of(context).curTheme.text15,
          ),
      ]),
    );
  }
}
