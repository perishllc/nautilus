import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nautilus_wallet_flutter/model/db/blocked.dart';
import 'package:nautilus_wallet_flutter/model/db/txdata.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nautilus_wallet_flutter/model/db/account.dart';
import 'package:nautilus_wallet_flutter/model/db/contact.dart';
import 'package:nautilus_wallet_flutter/model/db/user.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';

import 'package:flutter/services.dart';

// for updating the database:
import 'package:http/http.dart' as http;

class DBHelper {
  static const int DB_VERSION = 5;
  static const String CONTACTS_SQL = """CREATE TABLE Contacts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        address TEXT, 
        monkey_path TEXT)""";
  static const String USERS_SQL = """CREATE TABLE Users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        last_updated INTEGER,
        username TEXT,
        nickname TEXT,
        address TEXT,
        blocked BOOLEAN,
        type TEXT)""";
  static const String BLOCKED_SQL = """CREATE TABLE Blocked( 
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT,
        address TEXT)""";
  static const String REPS_SQL = """CREATE TABLE Reps( 
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT, 
        address TEXT,
        uptime TEXT,
        synced TEXT,
        website TEXT
        )""";
  static const String ACCOUNTS_SQL = """CREATE TABLE Accounts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        acct_index INTEGER, 
        selected INTEGER, 
        last_accessed INTEGER,
        private_key TEXT,
        balance TEXT,
        address TEXT)""";
  static const String TX_DATA_SQL = """CREATE TABLE Transactions( 
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_address TEXT,
        to_address TEXT,
        amount_raw TEXT,
        is_request BOOLEAN,
        request_time TEXT,
        is_fulfilled BOOLEAN,
        fulfillment_time TEXT,
        block TEXT,
        link TEXT,
        memo_enc TEXT,
        is_memo BOOLEAN,
        memo TEXT,
        uuid TEXT,
        is_acknowledged BOOLEAN,
        height INTEGER,
        send_height INTEGER,
        recv_height INTEGER,
        record_type TEXT,
        metadata TEXT,
        status TEXT)""";
  static const String USER_ADD_BLOCKED_COLUMN_SQL = """
    ALTER TABLE Users ADD blocked BOOLEAN
    """;
  static const String USER_ADD_NICKNAME_COLUMN_SQL = """
    ALTER TABLE Users ADD nickname TEXT
    """;
  static const String USER_ADD_TYPE_COLUMN_SQL = """
    ALTER TABLE Users ADD type TEXT
    """;
  static Database _db;

  NanoUtil _nanoUtil;

  DBHelper() {
    _nanoUtil = NanoUtil();
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "nautilus.db");
    var theDb = await openDatabase(path, version: DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables
    await db.execute(CONTACTS_SQL);
    await db.execute(USERS_SQL);
    await db.execute(REPS_SQL);
    await db.execute(ACCOUNTS_SQL);
    await db.execute(BLOCKED_SQL);
    await db.execute(TX_DATA_SQL);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 3) {
      // Add blocked table
      await db.execute(BLOCKED_SQL);
    }
    if (oldVersion == 4) {
      // Add to Users table
      await db.execute(USER_ADD_BLOCKED_COLUMN_SQL);
      await db.execute(USER_ADD_NICKNAME_COLUMN_SQL);
      await db.execute(USER_ADD_TYPE_COLUMN_SQL);
    }
  }

  // read json and populate users table:
  Future<void> loadNapiCache() async {
    // get the json from the cache:
    final String userData = await rootBundle.loadString("assets/store/known.json");
    final knownUsers = await json.decode(userData);

    // loop through the data and insert into the users table:
    var users = parseNanoToUsers(knownUsers);
    for (var user in users) {
      await addOrReplaceUser(user);
    }
    // var reps = parseReps(repsUsers);
    // for (var rep in reps) {
    //   await addRep(rep);
    // }
  }

  Future<void> fetchNapiUsernames() async {
    var users = await fetchNapiKnown(http.Client());
    // nuke the old databases:
    await nukeUsers();
    // add the new users:
    for (var user in users) {
      await addOrReplaceUser(user);
    }
  }

  // A function that converts a response body into a list of Users
  List<User> parseNanoToUsers(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) {
      var user = User.fromJson(json);
      user.type = UserTypes.NANOTO;
      return user;
    }).toList();
  }

  Future<List<User>> fetchNapiKnown(http.Client client) async {
    final response = await client.get(Uri.parse("https://nano.to/known?json=true"));
    // Use the compute function to run parseUsers in a separate isolate.
    return parseNanoToUsers(response.body);
  }

  // Future<List<User>> fetchNapiReps(http.Client client) async {
  //   final response = await client.get(Uri.parse("https://nano.to/reps?json=true"));
  //   // Use the compute function to run parseUsers in a separate isolate.
  //   return parseUsers(response.body);
  // }

  // List<User> parseReps(String responseBody) {
  //   final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  //   return parsed.map<User>((json) => User.fromJson(json)).toList();
  // }

  // Contacts
  Future<List<User>> getContacts() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE nickname <> \'\' ORDER BY nickname');
    List<User> contacts = [];
    for (int i = 0; i < list.length; i++) {
      contacts.add(new User(
          nickname: list[i]["nickname"], address: list[i]["address"].replaceAll("xrb_", "nano_"), type: UserTypes.CONTACT, username: list[i]["username"]));
    }
    return contacts;
  }

  // Future<List<Contact>> getContactsWithNameLike(String pattern) async {
  //   var dbClient = await db;
  //   List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts WHERE name LIKE \'%$pattern%\' ORDER BY LOWER(name)');
  //   List<Contact> contacts = new List();
  //   for (int i = 0; i < list.length; i++) {
  //     contacts.add(new Contact(id: list[i]["id"], name: list[i]["name"], address: list[i]["address"], monkeyPath: list[i]["monkey_path"]));
  //   }
  //   return contacts;
  // }

  Future<List<User>> getContactsWithNameLike(String pattern) async {
    var dbClient = await db;
    // List<Map> list =
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE nickname LIKE \'%$pattern%\' AND nickname <> \'\' ORDER BY LOWER(nickname)');
    List<User> contacts = [];
    for (int i = 0; i < list.length; i++) {
      contacts.add(new User(nickname: list[i]["nickname"], address: list[i]["address"], type: list[i]["type"]));
    }
    return contacts;
  }

  // Future<Contact> getContactWithAddress(String address) async {
  //   var dbClient = await db;
  //   List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
  //   if (list.length > 0) {
  //     return Contact(id: list[0]["id"], name: list[0]["name"], address: list[0]["address"], monkeyPath: list[0]["monkey_path"]);
  //   }
  //   return null;
  // }

  Future<User> getContactWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\' AND nickname <> \'\'');
    if (list.length > 0) {
      return User(nickname: list[0]["nickname"], address: list[0]["address"], type: list[0]["type"], username: list[0]["username"]);
    }
    return null;
  }

  Future<User> getContactWithName(String name) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE nickname = ? AND nickname <> \'\'', [name]);
    if (list.length > 0) {
      return User(nickname: list[0]["nickname"], address: list[0]["address"]);
    }
    return null;
  }

  Future<bool> contactExistsWithName(String name) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT count(*) FROM Users WHERE lower(nickname) = ? AND nickname <> \'\'', [name.toLowerCase()]));
    return count > 0;
  }

  Future<bool> contactExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Users WHERE lower(address) like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\' AND nickname <> \'\''));
    return count > 0;
  }

  Future<int> saveContact(User contact) async {
    var dbClient = await db;
    return await dbClient.rawInsert('INSERT INTO Users (nickname, address, username) values(?, ?, ?)', [contact.nickname, contact.address.replaceAll("xrb_", "nano_"), contact.username]);
  }

  Future<int> saveContacts(List<User> contacts) async {
    int count = 0;
    for (User c in contacts) {
      if (await saveContact(c) > 0) {
        count++;
      }
    }
    return count;
  }

  Future<bool> deleteContact(User contact) async {
    var dbClient = await db;
    return await dbClient.rawDelete(
            "DELETE FROM Users WHERE lower(address) like \'%${contact.address.toLowerCase().replaceAll("xrb_", "").replaceAll("nano_", "")}\' AND nickname <> \'\'") >
        0;
  }

  // Users
  Future<List<User>> getUsers() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users ORDER BY username');
    List<User> users = new List();
    for (int i = 0; i < list.length; i++) {
      users.add(new User(
          username: list[i]["username"],
          address: list[i]["address"].replaceAll("xrb_", "nano_"),
          last_updated: list[i]["last_updated"],
          type: list[i]["type"],
          nickname: list[i]["nickname"]));
    }
    return users;
  }

  Future<List<User>> getUsersWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE username LIKE \'%$pattern%\' ORDER BY LOWER(username)');
    List<User> users = [];
    for (int i = 0; i < list.length; i++) {
      users.add(new User(username: list[i]["username"], address: list[i]["address"], last_updated: list[i]["last_updated"]));
    }
    return users;
  }

  Future<List<User>> getUserSuggestionsWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE username LIKE \'%$pattern%\' ORDER BY LOWER(username)');
    List<User> users = [];
    int maxSuggestions = 5;
    int length = list.length;
    // dart doesn't support function overloading so I can't import dart:math for the min() function
    // which is why I'm doing this
    int minned = (maxSuggestions <= list.length) ? maxSuggestions : list.length;
    for (int i = 0; i < minned; i++) {
      users.add(new User(
          username: list[i]["username"],
          nickname: list[i]["nickname"],
          address: list[i]["address"],
          type: list[i]["type"],
          last_updated: list[i]["last_updated"]));
    }
    return users;
  }

  Future<List<User>> getUserContactSuggestionsWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE username LIKE \'%$pattern%\' OR nickname LIKE \'%$pattern%\' ORDER BY LOWER(username)');
    List<User> users = [];
    int maxSuggestions = 5;
    int length = list.length;
    // dart doesn't support function overloading so I can't import dart:math for the min() function
    // which is why I'm doing this
    int minned = (maxSuggestions <= list.length) ? maxSuggestions : list.length;
    for (int i = 0; i < minned; i++) {
      users.add(new User(
          username: list[i]["username"],
          nickname: list[i]["nickname"],
          address: list[i]["address"],
          type: list[i]["type"],
          last_updated: list[i]["last_updated"]));
    }
    return users;
  }

  Future<User> getUserWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    // TODO: Handle multiple users with the same address
    if (list.length > 0) {
      return User(username: list[0]["username"], address: list[0]["address"], last_updated: list[0]["last_updated"]);
    }
    return null;
  }

  Future<String> getUsernameOrReturnAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    // TODO: Handle multiple users with the same address
    if (list.length > 0) {
      return list[0]["username"];
    }
    return address;
  }

  Future<String> getUsernameWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    // TODO: Handle multiple users with the same address
    if (list.length > 0) {
      return list[0]["username"];
    }
    return null;
  }

  Future<dynamic> getUserOrContactWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list;
    list = await dbClient.rawQuery('SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    // TODO: Handle multiple users with the same address
    if (list.length > 0) {
      return User(
          username: list[0]["username"],
          address: list[0]["address"],
          type: list[0]["type"],
          last_updated: list[0]["last_updated"],
          nickname: list[0]["nickname"]);
    }
    return null;
  }

  Future<User> getUserWithName(String name) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE username = ?', [name]);
    if (list.length > 0) {
      return User(
          username: list[0]["username"],
          address: list[0]["address"],
          nickname: list[0]["nickname"],
          last_updated: list[0]["last_updated"],
          blocked: list[0]["blocked"] == 1,
          type: list[0]["type"]);
    }
    return null;
  }

  Future<User> getUserOrContactWithName(String name) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE username = ? OR nickname = ?', [name, name]);
    if (list.length > 0) {
      return User(
          username: list[0]["username"],
          address: list[0]["address"],
          nickname: list[0]["nickname"],
          last_updated: list[0]["last_updated"],
          blocked: list[0]["blocked"] == 1,
          type: list[0]["type"]);
    }
    return null;
  }

  // Future<dynamic> getUserOrContactWithName(String name) async {
  //   var dbClient = await db;
  //   // search through contacts first incase the user has a contact with the same name
  //   List<Map> contactList = await dbClient.rawQuery('SELECT * FROM Contacts WHERE name = ?', [name]);
  //   if (contactList.length > 0) {
  //     return Contact(id: contactList[0]["id"], name: contactList[0]["name"], address: contactList[0]["address"]);
  //   } else {
  //     List<Map> userList = await dbClient.rawQuery('SELECT * FROM Users WHERE username = ?', [name]);
  //     if (userList.length > 0) {
  //       return User(username: userList[0]["username"], address: userList[0]["address"], nickname: userList[0]["nickname"], type: userList[0]["type"]);
  //     }
  //   }
  //   return null;
  // }

  Future<bool> userExistsWithName(String name) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT count(*) FROM Users WHERE lower(username) = ?', [name.toLowerCase()]));
    return count > 0;
  }

  Future<bool> userExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT count(*) FROM Users WHERE lower(address) like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\''));
    return count > 0;
  }

  Future<int> addUser(User user) async {
    var dbClient = await db;
    // return await dbClient.rawInsert('INSERT INTO Users (username, address) values(?, ?)', [user.username, user.address.replaceAll("xrb_", "nano_")]);
    return await dbClient.rawInsert('INSERT INTO Users (username, address, nickname, type, blocked) values(?, ?, ?, ?, ?)',
        [user.username, user.address.replaceAll("xrb_", "nano_"), user.nickname, user.type, user.blocked]);
  }

  Future<int> addOrReplaceUser(User user) async {
    var dbClient = await db;
    // check if it's already in the database:
    bool userExists = await userExistsWithName(user.username);

    if (!userExists) {
      return await addUser(user);
    } else {
      return await dbClient.rawUpdate('UPDATE Users SET address = ? WHERE username = ?', [
        user.address,
        user.username,
      ]);
    }
  }

  Future<bool> deleteUser(User user) async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM Users WHERE lower(username) like \'%${user.username.toLowerCase()}\'") > 0;
  }

  // Blocked
  Future<List<User>> getBlocked() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE blocked = 1 ORDER BY nickname');
    List<User> blocked = [];
    for (int i = 0; i < list.length; i++) {
      blocked.add(new User(
          username: list[i]["username"], address: list[i]["address"], nickname: list[i]["nickname"], type: list[i]["type"], blocked: list[i]["blocked"] == 1));
    }
    return blocked;
  }

  Future<bool> blockUser(User blocked) async {
    var dbClient = await db;
    // return await dbClient.rawInsert(
    //     'INSERT INTO Blocked (username, address, name) values(?, ?, ?)', [blocked.username, blocked.address.replaceAll("xrb_", "nano_"), blocked.nickname]);
    bool username = false;
    bool address = false;
    bool name = false;
    // UPDATE by username / address / nickname:
    if (blocked.username != null) {
      username = await dbClient.rawUpdate('UPDATE Users SET blocked = 1 WHERE lower(username) = ?', [blocked.username.toLowerCase()]) > 0;
    }
    if (blocked.address != null) {
      address =
          await dbClient.rawUpdate('UPDATE Users SET blocked = 1 WHERE lower(address) = ?', [blocked.address.replaceAll("xrb_", "nano_").toLowerCase()]) > 0;
    }
    if (blocked.nickname != null) {
      address = await dbClient.rawUpdate('UPDATE Users SET blocked = 1 WHERE lower(nickname) = ?', [blocked.nickname.toLowerCase()]) > 0;
    }
    return username || address || name;
  }

  Future<bool> unblockUser(User blocked) async {
    var dbClient = await db;
    bool username = false;
    bool address = false;
    bool name = false;
    if (blocked.username != null) {
      username = await dbClient.rawUpdate("UPDATE Users SET blocked = 0 WHERE lower(username) like \'%${blocked.username.toLowerCase()}\'") > 0;
    }
    if (blocked.address != null) {
      address = await dbClient.rawUpdate("UPDATE Users SET blocked = 0 WHERE lower(address) like \'%${blocked.address.toLowerCase()}\'") > 0;
    }
    if (blocked.nickname != null) {
      name = await dbClient.rawUpdate("UPDATE Users SET blocked = 0 WHERE lower(nickname) like \'%${blocked.nickname.toLowerCase()}\'") > 0;
    }
    return username || address || name;
  }

  Future<bool> blockedExistsWithName(String nickname) async {
    var dbClient = await db;
    int count =
        Sqflite.firstIntValue(await dbClient.rawQuery('SELECT count(*) FROM Users WHERE lower(nickname) = ? AND blocked = 1', [nickname.toLowerCase()]));
    return count > 0;
  }

  Future<bool> blockedExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient
        .rawQuery('SELECT count(*) FROM Users WHERE lower(address) like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\' AND blocked = 1'));
    return count > 0;
  }

  Future<bool> blockedExistsWithUsername(String username) async {
    var dbClient = await db;
    int count =
        Sqflite.firstIntValue(await dbClient.rawQuery('SELECT count(*) FROM Users WHERE lower(username) = ? AND blocked = 1', [username.toLowerCase()]));
    return count > 0;
  }

  // txData

  // TODO: make a constructor for this:
  TXData createTXDataFromDB(dynamic dbItem) {
    TXData newData = new TXData();
    if (dbItem["id"] != null) {
      newData.id = dbItem["id"];
    }
    if (dbItem["from_address"] != null) {
      newData.from_address = dbItem["from_address"];
    }
    if (dbItem["to_address"] != null) {
      newData.to_address = dbItem["to_address"];
    }
    if (dbItem["amount_raw"] != null) {
      newData.amount_raw = dbItem["amount_raw"];
    }
    if (dbItem["is_request"] != null) {
      newData.is_request = (dbItem["is_request"] == 0 || dbItem["is_request"] == null) ? false : true;
    }
    if (dbItem["request_time"] != null) {
      newData.request_time = dbItem["request_time"];
    }
    if (dbItem["is_fulfilled"] != null) {
      newData.is_fulfilled = (dbItem["is_fulfilled"] == 0 || dbItem["is_fulfilled"] == null) ? false : true;
    }
    if (dbItem["fulfillment_time"] != null) {
      newData.fulfillment_time = dbItem["fulfillment_time"];
    }
    if (dbItem["block"] != null) {
      newData.block = dbItem["block"];
    }
    if (dbItem["link"] != null) {
      newData.link = dbItem["link"];
    }
    if (dbItem["memo_enc"] != null) {
      newData.memo_enc = dbItem["memo_enc"];
    }
    if (dbItem["is_memo"] != null) {
      newData.is_memo = (dbItem["is_memo"] == 0 || dbItem["is_memo"] == null) ? false : true;
    }
    if (dbItem["memo"] != null) {
      newData.memo = dbItem["memo"];
    }
    if (dbItem["uuid"] != null) {
      newData.uuid = dbItem["uuid"];
    }
    if (dbItem["is_acknowledged"] != null) {
      newData.is_acknowledged = (dbItem["is_acknowledged"] == 0 || dbItem["is_acknowledged"] == null) ? false : true;
    }
    if (dbItem["height"] != null) {
      newData.height = dbItem["height"];
    }
    if (dbItem["send_height"] != null) {
      newData.send_height = dbItem["send_height"];
    }
    if (dbItem["recv_height"] != null) {
      newData.recv_height = dbItem["recv_height"];
    }
    if (dbItem["record_type"] != null) {
      newData.record_type = dbItem["record_type"];
    }
    if (dbItem["metadata"] != null) {
      newData.metadata = dbItem["metadata"];
    }
    if (dbItem["status"] != null) {
      newData.status = dbItem["status"];
    }
    return newData;
  }

  Future<int> addTXData(TXData txData) async {
    var dbClient = await db;
    // id INTEGER PRIMARY KEY AUTOINCREMENT,
    // from_address TEXT,
    // to_address TEXT,
    // amount_raw TEXT,
    // is_request BOOLEAN,
    // request_time TEXT,
    // is_fulfilled BOOLEAN,
    // fulfillment_time TEXT,
    // block TEXT,
    // memo TEXT,
    // uuid TEXT,
    // return await dbClient.rawInsert('INSERT INTO Transactions (username, address) values(?, ?)', [txData.username, user.address.replaceAll("xrb_", "nano_")]);
    // check if txData already exists:
    var existingTXData = await getTXDataByUUID(txData.uuid);
    if (existingTXData != null) {
      throw Exception("TXData already exists");
    }

    return await dbClient.rawInsert(
        'INSERT INTO Transactions (from_address, to_address, amount_raw, is_request, request_time, is_fulfilled, fulfillment_time, block, link, memo_enc, is_memo, memo, uuid, is_acknowledged, height, send_height, recv_height, record_type, metadata, status) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          txData.from_address,
          txData.to_address,
          txData.amount_raw,
          txData.is_request,
          txData.request_time,
          txData.is_fulfilled,
          txData.fulfillment_time,
          txData.block,
          txData.link,
          txData.memo_enc,
          txData.is_memo,
          txData.memo,
          txData.uuid,
          txData.is_acknowledged,
          txData.height,
          txData.send_height,
          txData.recv_height,
          txData.record_type,
          txData.metadata,
          txData.status,
        ]);
  }

  Future<int> replaceTXDataByUUID(TXData txData) async {
    var dbClient = await db;

    if (txData.uuid.isEmpty) {
      throw "this shouldn't happen";
    }

    return await dbClient.rawUpdate(
        // 'UPDATE Transactions SET (from_address, to_address, amount_raw, is_request, request_time, is_fulfilled, fulfillment_time, block, memo, is_acknowledged, height) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) WHERE uuid = ?',
        'UPDATE Transactions SET from_address = ?, to_address = ?, amount_raw = ?, is_request = ?, request_time = ?, is_fulfilled = ?, fulfillment_time = ?, block = ?, link = ?, memo_enc = ?, is_memo = ?, memo = ?, is_acknowledged = ?, height = ?, send_height = ?, recv_height = ?, record_type = ?, metadata = ?, status = ? WHERE uuid = ?',
        [
          txData.from_address,
          txData.to_address,
          (txData.amount_raw == null || txData.amount_raw.isEmpty) ? "" : txData.amount_raw,
          txData.is_request ? 1 : 0,
          (txData.request_time == null || txData.request_time.isEmpty) ? "" : txData.request_time,
          txData.is_fulfilled ? 1 : 0,
          (txData.fulfillment_time == null || txData.fulfillment_time.isEmpty) ? "" : txData.fulfillment_time,
          (txData.block == null || txData.block.isEmpty) ? "" : txData.block,
          (txData.link == null || txData.link.isEmpty) ? "" : txData.link,
          (txData.memo_enc == null || txData.memo_enc.isEmpty) ? "" : txData.memo_enc,
          txData.is_memo ? 1 : 0,
          (txData.memo == null || txData.memo.isEmpty) ? "" : txData.memo,
          txData.is_acknowledged ? 1 : 0,
          txData.height,
          txData.send_height,
          txData.recv_height,
          txData.record_type,
          txData.metadata,
          txData.status,
          // must be last:
          txData.uuid,
        ]);
  }

  // txdata
  Future<List<TXData>> getTXData() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<TXData> getTXDataByBlock(String block) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions WHERE block = ? ORDER BY request_time DESC', [block]);
    if (list.length > 0) {
      return createTXDataFromDB(list[0]);
    }
    return null;
  }

  Future<List<TXData>> getAccountSpecificTXData(String account) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Transactions WHERE from_address = ? OR to_address = ? ORDER BY request_time DESC', [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<List<TXData>> getAccountSpecificRequests(String account) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Transactions WHERE (from_address = ? OR to_address = ?) AND is_request = 1 ORDER BY request_time DESC', [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<List<TXData>> getAccountSpecificRecords(String account) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Transactions WHERE (from_address = ? OR to_address = ?) AND is_request = 0 ORDER BY request_time DESC', [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<TXData> getBlockSpecificTXData(String block) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions WHERE block = ? ORDER BY request_time DESC', [block]);
    if (list.length > 0) {
      return createTXDataFromDB(list[0]);
    }
    return null;
  }

  Future<TXData> getTXDataByRequestTime(String request_time) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions WHERE request_time = ? ORDER BY request_time DESC', [request_time]);
    if (list.length > 0) {
      return createTXDataFromDB(list[0]);
    }
    return null;
  }

  Future<TXData> getTXDataByUUID(String uuid) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("SELECT * FROM Transactions WHERE lower(uuid) like \'%${uuid.toLowerCase()}\'");
    if (list.length > 0) {
      return createTXDataFromDB(list[0]);
    }
    return null;
  }

  Future<bool> deleteTXData(TXData txData) async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE lower(uuid) like \'%${txData.uuid.toLowerCase()}\'") > 0;
  }

  Future<bool> deleteTXDataByUUID(String uuid) async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE lower(uuid) like \'%${uuid.toLowerCase()}\'") > 0;
  }

  Future<bool> deleteTXDataByID(int id) async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE id = ?", [id]) > 0;
  }

  Future<bool> deleteTXDataByBlock(String block) async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE lower(block) like \'%${block.toLowerCase()}\'") > 0;
  }

  Future<bool> deleteTXDataByRequestTime(String request_time) async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE request_time = ?", [request_time]) > 0;
  }

  Future<List<TXData>> getUnfulfilledTXs() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions WHERE (is_fulfilled = 0 AND is_request = 1) ORDER BY request_time');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<int> changeTXFulfillmentStatus(String uuid, bool is_fulfilled) async {
    var dbClient = await db;
    // return await dbClient.rawUpdate('UPDATE Transactions SET is_fulfilled = ? WHERE id = ?', [is_fulfilled ? 1 : 0, txData.id]);
    return await dbClient.rawUpdate('UPDATE Transactions SET is_fulfilled = ? WHERE uuid = ?', [
      is_fulfilled ? 1 : 0,
      uuid,
    ]);
  }

  Future<int> changeTXAckStatus(String uuid, bool is_acknowledged) async {
    var dbClient = await db;
    // return await dbClient.rawUpdate('UPDATE Transactions SET is_fulfilled = ? WHERE id = ?', [is_fulfilled ? 1 : 0, txData.id]);
    return await dbClient.rawUpdate('UPDATE Transactions SET is_acknowledged = ? WHERE uuid = ?', [
      is_acknowledged ? 1 : 0,
      uuid,
    ]);
  }

  Future<void> nukeUsers() async {
    var dbClient = await db;
    await dbClient.rawDelete("DELETE FROM Users");
  }

  // Accounts
  Future<List<Account>> getAccounts(String seed) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts ORDER BY acct_index');
    List<Account> accounts = new List();
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(
          id: list[i]["id"],
          name: list[i]["name"],
          index: list[i]["acct_index"],
          lastAccess: list[i]["last_accessed"],
          selected: list[i]["selected"] == 1 ? true : false,
          balance: list[i]["balance"]));
    }
    accounts.forEach((a) async {
      a.address = NanoUtil.seedToAddress(seed, a.index);
      // check if account has a username:
      String username = await getUsernameWithAddress(a.address);
      if (username != null) {
        a.username = username;
      }
    });
    return accounts;
  }

  Future<List<Account>> getRecentlyUsedAccounts(String seed, {int limit = 2}) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts WHERE selected != 1 ORDER BY last_accessed DESC, acct_index ASC LIMIT ?', [limit]);
    List<Account> accounts = new List();
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(
          id: list[i]["id"],
          name: list[i]["name"],
          index: list[i]["acct_index"],
          lastAccess: list[i]["last_accessed"],
          selected: list[i]["selected"] == 1 ? true : false,
          balance: list[i]["balance"]));
    }
    accounts.forEach((a) async {
      a.address = NanoUtil.seedToAddress(seed, a.index);
      // check if account has a username:
      String username = await getUsernameWithAddress(a.address);
      if (username != null) {
        a.username = username;
      }
    });
    return accounts;
  }

  Future<Account> addAccount(String seed, {String nameBuilder}) async {
    var dbClient = await db;
    Account account;
    await dbClient.transaction((Transaction txn) async {
      int nextIndex = 1;
      int curIndex;
      List<Map> accounts = await txn.rawQuery('SELECT * from Accounts WHERE acct_index > 0 ORDER BY acct_index ASC');
      for (int i = 0; i < accounts.length; i++) {
        curIndex = accounts[i]["acct_index"];
        if (curIndex != nextIndex) {
          break;
        }
        nextIndex++;
      }
      int nextID = nextIndex + 1;
      String nextName = nameBuilder.replaceAll("%1", nextID.toString());
      account = Account(index: nextIndex, name: nextName, lastAccess: 0, selected: false, address: NanoUtil.seedToAddress(seed, nextIndex));
      await txn.rawInsert('INSERT INTO Accounts (name, acct_index, last_accessed, selected, address) values(?, ?, ?, ?, ?)',
          [account.name, account.index, account.lastAccess, account.selected ? 1 : 0, account.address]);
    });
    String username = await getUsernameWithAddress(account.address);
    if (username != null) {
      account.username = username;
    }
    return account;
  }

  Future<int> deleteAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawDelete('DELETE FROM Accounts WHERE acct_index = ?', [account.index]);
  }

  Future<int> saveAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawInsert('INSERT INTO Accounts (name, acct_index, last_accessed, selected) values(?, ?, ?, ?)',
        [account.name, account.index, account.lastAccess, account.selected ? 1 : 0]);
  }

  Future<int> changeAccountName(Account account, String name) async {
    var dbClient = await db;
    return await dbClient.rawUpdate('UPDATE Accounts SET name = ? WHERE acct_index = ?', [name, account.index]);
  }

  Future<void> changeAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.transaction((Transaction txn) async {
      await txn.rawUpdate('UPDATE Accounts set selected = 0');
      // Get access increment count
      List<Map> list = await txn.rawQuery('SELECT max(last_accessed) as last_access FROM Accounts');
      await txn.rawUpdate('UPDATE Accounts set selected = ?, last_accessed = ? where acct_index = ?', [1, list[0]["last_access"] + 1, account.index]);
    });
  }

  Future<void> updateAccountBalance(Account account, String balance) async {
    var dbClient = await db;
    return await dbClient.rawUpdate('UPDATE Accounts set balance = ? where acct_index = ?', [balance, account.index]);
  }

  Future<Account> getSelectedAccount(String seed) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts where selected = 1');
    if (list.length == 0) {
      return null;
    }
    String address = NanoUtil.seedToAddress(seed, list[0]["acct_index"]);
    Account account = Account(
        id: list[0]["id"],
        name: list[0]["name"],
        index: list[0]["acct_index"],
        selected: true,
        lastAccess: list[0]["last_accessed"],
        balance: list[0]["balance"],
        address: address);
    return account;
  }

  Future<Account> getMainAccount(String seed) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts where acct_index = 0');
    if (list.length == 0) {
      return null;
    }
    String address = NanoUtil.seedToAddress(seed, list[0]["acct_index"]);
    Account account = Account(
        id: list[0]["id"],
        name: list[0]["name"],
        index: list[0]["acct_index"],
        selected: true,
        lastAccess: list[0]["last_accessed"],
        balance: list[0]["balance"],
        address: address);
    return account;
  }

  Future<void> dropAccounts() async {
    var dbClient = await db;
    return await dbClient.rawDelete('DELETE FROM ACCOUNTS');
  }
}
