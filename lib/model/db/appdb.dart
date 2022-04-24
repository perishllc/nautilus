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
  static const int DB_VERSION = 4;
  static const String CONTACTS_SQL = """CREATE TABLE Contacts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        address TEXT, 
        monkey_path TEXT)""";
  static const String USERS_SQL = """CREATE TABLE Users( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        username TEXT,
        address TEXT,
        blocked BOOLEAN)""";
  static const String BLOCKED_SQL = """CREATE TABLE BlockedUsers( 
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
        send_block TEXT,
        recv_block TEXT,
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
  }

  // read json and populate users table:
  Future<void> populateDBFromCache() async {
    // delete the old databases:
    await nukeUsers();
    // nukeReps();

    // get the json from the cache:
    final String userData = await rootBundle.loadString("assets/store/known.json");
    final String repsData = await rootBundle.loadString("assets/store/reps.json");
    final knownUsers = await json.decode(userData);
    final repsUsers = await json.decode(repsData);

    // loop through the data and insert into the users table:
    var users = parseUsers(knownUsers);
    for (var user in users) {
      await addUser(user);
    }

    // loop through the data and insert into the users table:
    // var reps = parseReps(repsUsers);
    // for (var rep in reps) {
    //   await addRep(rep);
    // }
  }

  Future<void> loadNapiCache() async {
    // get the json from the cache:
    final String userData = await rootBundle.loadString("assets/store/known.json");
    // final String repsData = await rootBundle.loadString("assets/store/reps.json");
    final knownUsers = await json.decode(userData);
    // final repsUsers = await json.decode(repsData);

    // loop through the data and insert into the users table:
    var users = parseUsers(knownUsers);
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
  List<User> parseUsers(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  Future<List<User>> fetchNapiKnown(http.Client client) async {
    final response = await client.get(Uri.parse("https://nano.to/known?json=true"));
    // Use the compute function to run parseUsers in a separate isolate.
    return parseUsers(response.body);
  }

  Future<List<User>> fetchNapiReps(http.Client client) async {
    final response = await client.get(Uri.parse("https://nano.to/reps?json=true"));
    // Use the compute function to run parseUsers in a separate isolate.
    return parseUsers(response.body);
  }

  List<User> parseReps(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  // Contacts
  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts ORDER BY name');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(
          id: list[i]["id"],
          name: list[i]["name"],
          address: list[i]["address"].replaceAll("xrb_", "nano_"),
          monkeyPath: list[i]["monkey_path"]));
    }
    return contacts;
  }

  Future<List<Contact>> getContactsWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Contacts WHERE name LIKE \'%$pattern%\' ORDER BY LOWER(name)');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(
          id: list[i]["id"], name: list[i]["name"], address: list[i]["address"], monkeyPath: list[i]["monkey_path"]));
    }
    return contacts;
  }

  Future<Contact> getContactWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Contacts WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    if (list.length > 0) {
      return Contact(
          id: list[0]["id"], name: list[0]["name"], address: list[0]["address"], monkeyPath: list[0]["monkey_path"]);
    }
    return null;
  }

  Future<Contact> getContactWithName(String name) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Contacts WHERE name = ?', [name]);
    if (list.length > 0) {
      return Contact(
          id: list[0]["id"], name: list[0]["name"], address: list[0]["address"], monkeyPath: list[0]["monkey_path"]);
    }
    return null;
  }

  Future<bool> contactExistsWithName(String name) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT count(*) FROM Contacts WHERE lower(name) = ?', [name.toLowerCase()]));
    return count > 0;
  }

  Future<bool> contactExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Contacts WHERE lower(address) like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\''));
    return count > 0;
  }

  Future<int> saveContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.rawInsert('INSERT INTO Contacts (name, address) values(?, ?)',
        [contact.name, contact.address.replaceAll("xrb_", "nano_")]);
  }

  Future<int> saveContacts(List<Contact> contacts) async {
    int count = 0;
    for (Contact c in contacts) {
      if (await saveContact(c) > 0) {
        count++;
      }
    }
    return count;
  }

  Future<bool> deleteContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.rawDelete(
            "DELETE FROM Contacts WHERE lower(address) like \'%${contact.address.toLowerCase().replaceAll("xrb_", "").replaceAll("nano_", "")}\'") >
        0;
  }

  Future<bool> setMonkeyForContact(Contact contact, String monkeyPath) async {
    var dbClient = await db;
    return await dbClient
            .rawUpdate("UPDATE contacts SET monkey_path = ? WHERE address = ?", [monkeyPath, contact.address]) >
        0;
  }

  // Users
  Future<List<User>> getUsers() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users ORDER BY username');
    List<User> users = new List();
    for (int i = 0; i < list.length; i++) {
      users.add(new User(username: list[i]["username"], address: list[i]["address"].replaceAll("xrb_", "nano_")));
    }
    return users;
  }

  Future<List<User>> getUsersWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Users WHERE username LIKE \'%$pattern%\' ORDER BY LOWER(username)');
    List<User> users = new List();
    for (int i = 0; i < list.length; i++) {
      users.add(new User(username: list[i]["username"], address: list[i]["address"]));
    }
    return users;
  }

  Future<List<User>> getUserSuggestionsWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Users WHERE username LIKE \'%$pattern%\' ORDER BY LOWER(username)');
    List<User> users = [];
    int maxSuggestions = 5;
    int length = list.length;
    // dart doesn't support function overloading so I can't import dart:math for the min() function
    // which is why I'm doing this
    int minned = (maxSuggestions <= list.length) ? maxSuggestions : list.length;
    for (int i = 0; i < minned; i++) {
      users.add(new User(username: list[i]["username"], address: list[i]["address"]));
    }
    return users;
  }

  Future<User> getUserWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    // TODO: Handle multiple users with the same address
    if (list.length > 0) {
      return User(username: list[0]["username"], address: list[0]["address"]);
    }
    return null;
  }

  Future<String> getUsernameOrReturnAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    // TODO: Handle multiple users with the same address
    if (list.length > 0) {
      return list[0]["username"];
    }
    return address;
  }

  Future<String> getUsernameWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    // TODO: Handle multiple users with the same address
    if (list.length > 0) {
      return list[0]["username"];
    }
    return null;
  }

  Future<dynamic> getUserOrContactWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list;
    // check contacts first incase the user has a contact with the same address:
    list = await dbClient.rawQuery(
        'SELECT * FROM Contacts WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
    if (list.length > 0) {
      return Contact(
          id: list[0]["id"], name: list[0]["name"], address: list[0]["address"], monkeyPath: list[0]["monkey_path"]);
    } else {
      list = await dbClient.rawQuery(
          'SELECT * FROM Users WHERE address like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\'');
      // TODO: Handle multiple users with the same address
      if (list.length > 0) {
        return User(username: list[0]["username"], address: list[0]["address"]);
      }
    }
    return null;
  }

  Future<User> getUserWithName(String name) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE username = ?', [name]);
    if (list.length > 0) {
      return User(username: list[0]["username"], address: list[0]["address"]);
    }
    return null;
  }

  Future<dynamic> getUserOrContactWithName(String name) async {
    var dbClient = await db;
    // search through contacts first incase the user has a contact with the same name
    List<Map> contactList = await dbClient.rawQuery('SELECT * FROM Contacts WHERE name = ?', [name]);
    if (contactList.length > 0) {
      return Contact(id: contactList[0]["id"], name: contactList[0]["name"], address: contactList[0]["address"]);
    } else {
      List<Map> userList = await dbClient.rawQuery('SELECT * FROM Users WHERE username = ?', [name]);
      if (userList.length > 0) {
        return User(username: userList[0]["username"], address: userList[0]["address"]);
      }
    }
    return null;
  }

  Future<bool> userExistsWithName(String name) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT count(*) FROM Users WHERE lower(username) = ?', [name.toLowerCase()]));
    return count > 0;
  }

  Future<bool> userExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Users WHERE lower(address) like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\''));
    return count > 0;
  }

  Future<int> addUser(User user) async {
    var dbClient = await db;
    return await dbClient.rawInsert('INSERT INTO Users (username, address) values(?, ?)',
        [user.username, user.address.replaceAll("xrb_", "nano_")]);
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
    return await dbClient
            .rawDelete("DELETE FROM Users WHERE lower(username) like \'%${user.username.toLowerCase()}\'") >
        0;
  }

  // Blocked
  Future<List<Blocked>> getBlockedUsers() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM BlockedUsers ORDER BY name');
    List<Blocked> blocked = [];
    for (int i = 0; i < list.length; i++) {
      blocked.add(new Blocked(username: list[i]["username"], address: list[i]["address"], name: list[i]["name"]));
    }
    return blocked;
  }

  Future<int> blockUser(Blocked blocked) async {
    var dbClient = await db;
    return await dbClient.rawInsert('INSERT INTO BlockedUsers (username, address, name) values(?, ?, ?)',
        [blocked.username, blocked.address.replaceAll("xrb_", "nano_"), blocked.name]);
  }

  Future<bool> unblockUser(Blocked blocked) async {
    var dbClient = await db;
    bool username = false;
    bool address = false;
    bool name = false;
    if (blocked.username != null) {
      username = await dbClient
              .rawDelete("DELETE FROM BlockedUsers WHERE lower(username) like \'%${blocked.username.toLowerCase()}\'") >
          0;
    }
    if (blocked.address != null) {
      address = await dbClient
              .rawDelete("DELETE FROM BlockedUsers WHERE lower(address) like \'%${blocked.address.toLowerCase()}\'") >
          0;
    }
    if (blocked.name != null) {
      name = await dbClient
              .rawDelete("DELETE FROM BlockedUsers WHERE lower(name) like \'%${blocked.name.toLowerCase()}\'") >
          0;
    }
    return username || address || name;
  }

  Future<bool> blockedExistsWithName(String name) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT count(*) FROM BlockedUsers WHERE lower(name) = ?', [name.toLowerCase()]));
    return count > 0;
  }

  Future<bool> blockedExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM BlockedUsers WHERE lower(address) like \'%${address.replaceAll("xrb_", "").replaceAll("nano_", "")}\''));
    return count > 0;
  }

  Future<bool> blockedExistsWithUsername(String username) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient
        .rawQuery('SELECT count(*) FROM BlockedUsers WHERE lower(username) = ?', [username.toLowerCase()]));
    return count > 0;
  }

  // txData

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

    return await dbClient.rawInsert(
        'INSERT INTO Transactions (from_address, to_address, amount_raw, is_request, request_time, is_fulfilled, fulfillment_time, block, link, send_block, recv_block, memo, uuid, is_acknowledged, height, send_height, recv_height, record_type, metadata, status) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
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
          txData.send_block,
          txData.recv_block,
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
        'UPDATE Transactions SET from_address = ?, to_address = ?, amount_raw = ?, is_request = ?, request_time = ?, is_fulfilled = ?, fulfillment_time = ?, block = ?, link = ?, send_block = ?, recv_block = ?, memo = ?, is_acknowledged = ?, height = ?, send_height = ?, recv_height = ?, record_type = ?, metadata = ?, status = ? WHERE uuid = ?',
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
          (txData.send_block == null || txData.send_block.isEmpty) ? "" : txData.send_block,
          (txData.recv_block == null || txData.recv_block.isEmpty) ? "" : txData.recv_block,
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
      transactions.add(new TXData(
          id: list[i]["id"],
          from_address: list[i]["from_address"],
          to_address: list[i]["to_address"],
          amount_raw: list[i]["amount_raw"],
          is_request: list[i]["is_request"] == 0 ? false : true,
          request_time: list[i]["request_time"],
          is_fulfilled: list[i]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[i]["fulfillment_time"],
          block: list[i]["block"],
          memo: list[i]["memo"],
          uuid: list[i]["uuid"],
          is_acknowledged: list[i]["is_acknowledged"] == 0 ? false : true,
          height: list[i]["height"],
          record_type: list[i]["record_type"],
          metadata: list[i]["metadata"],
          status: list[i]["status"]));
    }
    return transactions;
  }

  Future<TXData> getTXDataByBlock(String block) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Transactions WHERE block = ? ORDER BY request_time DESC', [block]);
    if (list.length > 0) {
      return new TXData(
          id: list[0]["id"],
          from_address: list[0]["from_address"],
          to_address: list[0]["to_address"],
          amount_raw: list[0]["amount_raw"],
          is_request: list[0]["is_request"] == 0 ? false : true,
          request_time: list[0]["request_time"],
          is_fulfilled: list[0]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[0]["fulfillment_time"],
          block: list[0]["block"],
          link: list[0]["link"],
          send_block: list[0]["send_block"],
          recv_block: list[0]["recv_block"],
          memo: list[0]["memo"],
          uuid: list[0]["uuid"],
          is_acknowledged: list[0]["is_acknowledged"] == 0 ? false : true,
          height: list[0]["height"],
          send_height: list[0]["send_height"],
          recv_height: list[0]["recv_height"],
          record_type: list[0]["record_type"],
          metadata: list[0]["metadata"],
          status: list[0]["status"]);
    }
    return null;
  }

  Future<List<TXData>> getAccountSpecificTXData(String account) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Transactions WHERE from_address = ? OR to_address = ? ORDER BY request_time DESC',
        [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      // transactions.add(new TXData(username: list[i]["username"], address: list[i]["address"].replaceAll("xrb_", "nano_")));
      transactions.add(new TXData(
          id: list[i]["id"],
          from_address: list[i]["from_address"],
          to_address: list[i]["to_address"],
          amount_raw: list[i]["amount_raw"],
          is_request: list[i]["is_request"] == 0 ? false : true,
          request_time: list[i]["request_time"],
          is_fulfilled: list[i]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[i]["fulfillment_time"],
          block: list[i]["block"],
          link: list[i]["link"],
          send_block: list[i]["send_block"],
          recv_block: list[i]["recv_block"],
          memo: list[i]["memo"],
          uuid: list[i]["uuid"],
          is_acknowledged: list[i]["is_acknowledged"] == 0 ? false : true,
          height: list[i]["height"],
          send_height: list[i]["send_height"],
          recv_height: list[i]["recv_height"],
          record_type: list[i]["record_type"],
          metadata: list[i]["metadata"],
          status: list[i]["status"]));
    }
    return transactions;
  }

  Future<List<TXData>> getAccountSpecificRequests(String account) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Transactions WHERE from_address = ? OR to_address = ? AND is_request = 1 ORDER BY request_time DESC',
        [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      // transactions.add(new TXData(username: list[i]["username"], address: list[i]["address"].replaceAll("xrb_", "nano_")));
      transactions.add(new TXData(
          id: list[i]["id"],
          from_address: list[i]["from_address"],
          to_address: list[i]["to_address"],
          amount_raw: list[i]["amount_raw"],
          is_request: list[i]["is_request"] == 0 ? false : true,
          request_time: list[i]["request_time"],
          is_fulfilled: list[i]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[i]["fulfillment_time"],
          block: list[i]["block"],
          link: list[i]["link"],
          send_block: list[i]["send_block"],
          recv_block: list[i]["recv_block"],
          memo: list[i]["memo"],
          uuid: list[i]["uuid"],
          is_acknowledged: list[i]["is_acknowledged"] == 0 ? false : true,
          height: list[i]["height"],
          send_height: list[i]["send_height"],
          recv_height: list[i]["recv_height"],
          record_type: list[i]["record_type"],
          metadata: list[i]["metadata"],
          status: list[i]["status"]));
    }
    return transactions;
  }

  Future<List<TXData>> getAccountSpecificRecords(String account) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Transactions WHERE from_address = ? OR to_address = ? AND is_request = 0 ORDER BY request_time DESC',
        [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      // transactions.add(new TXData(username: list[i]["username"], address: list[i]["address"].replaceAll("xrb_", "nano_")));
      transactions.add(new TXData(
          id: list[i]["id"],
          from_address: list[i]["from_address"],
          to_address: list[i]["to_address"],
          amount_raw: list[i]["amount_raw"],
          is_request: list[i]["is_request"] == 0 ? false : true,
          request_time: list[i]["request_time"],
          is_fulfilled: list[i]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[i]["fulfillment_time"],
          block: list[i]["block"],
          link: list[i]["link"],
          send_block: list[i]["send_block"],
          recv_block: list[i]["recv_block"],
          memo: list[i]["memo"],
          uuid: list[i]["uuid"],
          is_acknowledged: list[i]["is_acknowledged"] == 0 ? false : true,
          height: list[i]["height"],
          send_height: list[i]["send_height"],
          recv_height: list[i]["recv_height"],
          record_type: list[i]["record_type"],
          metadata: list[i]["metadata"],
          status: list[i]["status"]));
    }
    return transactions;
  }

  Future<TXData> getBlockSpecificTXData(String block) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Transactions WHERE block = ? ORDER BY request_time DESC', [block]);
    if (list.length > 0) {
      return new TXData(
          id: list[0]["id"],
          from_address: list[0]["from_address"],
          to_address: list[0]["to_address"],
          amount_raw: list[0]["amount_raw"],
          is_request: list[0]["is_request"] == 0 ? false : true,
          request_time: list[0]["request_time"],
          is_fulfilled: list[0]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[0]["fulfillment_time"],
          block: list[0]["block"],
          link: list[0]["link"],
          send_block: list[0]["send_block"],
          recv_block: list[0]["recv_block"],
          memo: list[0]["memo"],
          uuid: list[0]["uuid"],
          is_acknowledged: list[0]["is_acknowledged"] == 0 ? false : true,
          height: list[0]["height"],
          send_height: list[0]["send_height"],
          recv_height: list[0]["recv_height"],
          record_type: list[0]["record_type"],
          metadata: list[0]["metadata"],
          status: list[0]["status"]);
    }
    return null;
  }

  Future<TXData> getRequestTimeSpecificTXData(String request_time) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Transactions WHERE request_time = ? ORDER BY request_time DESC', [request_time]);
    if (list.length > 0) {
      return new TXData(
          id: list[0]["id"],
          from_address: list[0]["from_address"],
          to_address: list[0]["to_address"],
          amount_raw: list[0]["amount_raw"],
          is_request: list[0]["is_request"] == 0 ? false : true,
          request_time: list[0]["request_time"],
          is_fulfilled: list[0]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[0]["fulfillment_time"],
          block: list[0]["block"],
          link: list[0]["link"],
          send_block: list[0]["send_block"],
          recv_block: list[0]["recv_block"],
          memo: list[0]["memo"],
          uuid: list[0]["uuid"],
          is_acknowledged: list[0]["is_acknowledged"] == 0 ? false : true,
          height: list[0]["height"],
          send_height: list[0]["send_height"],
          recv_height: list[0]["recv_height"],
          record_type: list[0]["record_type"],
          metadata: list[0]["metadata"],
          status: list[0]["status"]);
    }
    return null;
  }

  Future<TXData> getTXDataByUUID(String uuid) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Transactions WHERE uuid = ? ORDER BY request_time DESC', [uuid]);
    if (list.length > 0) {
      return new TXData(
          id: list[0]["id"],
          from_address: list[0]["from_address"],
          to_address: list[0]["to_address"],
          amount_raw: list[0]["amount_raw"],
          is_request: list[0]["is_request"] == 0 ? false : true,
          request_time: list[0]["request_time"],
          is_fulfilled: list[0]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[0]["fulfillment_time"],
          block: list[0]["block"],
          link: list[0]["link"],
          send_block: list[0]["send_block"],
          recv_block: list[0]["recv_block"],
          memo: list[0]["memo"],
          uuid: list[0]["uuid"],
          is_acknowledged: list[0]["is_acknowledged"] == 0 ? false : true,
          height: list[0]["height"],
          send_height: list[0]["send_height"],
          recv_height: list[0]["recv_height"],
          record_type: list[0]["record_type"],
          metadata: list[0]["metadata"],
          status: list[0]["status"]);
    }
    return null;
  }

  Future<bool> deleteTXData(TXData txData) async {
    var dbClient = await db;
    return await dbClient
            .rawDelete("DELETE FROM Transactions WHERE lower(uuid) like \'%${txData.uuid.toLowerCase()}\'") >
        0;
  }

  Future<bool> deleteTXDataByUuid(String uuid) async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE lower(uuid) like \'%${uuid.toLowerCase()}\'") > 0;
  }

  Future<bool> deleteTXDataByRequestTime(String request_time) async {
    var dbClient = await db;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE request_time = ?", [request_time]) > 0;
  }

  Future<List<TXData>> getUnfulfilledTXs() async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Transactions WHERE is_fulfilled = 0 AND is_request = 1 ORDER BY request_time');
    List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(new TXData(
          id: list[i]["id"],
          from_address: list[i]["from_address"],
          to_address: list[i]["to_address"],
          amount_raw: list[i]["amount_raw"],
          is_request: list[i]["is_request"] == 0 ? false : true,
          request_time: list[i]["request_time"],
          is_fulfilled: list[i]["is_fulfilled"] == 0 ? false : true,
          fulfillment_time: list[i]["fulfillment_time"],
          block: list[i]["block"],
          link: list[i]["link"],
          send_block: list[i]["send_block"],
          recv_block: list[i]["recv_block"],
          memo: list[i]["memo"],
          uuid: list[i]["uuid"],
          is_acknowledged: list[i]["is_acknowledged"] == 0 ? false : true,
          height: list[i]["height"],
          send_height: list[i]["send_height"],
          recv_height: list[i]["recv_height"],
          record_type: list[i]["record_type"],
          metadata: list[i]["metadata"],
          status: list[i]["status"]));
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
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Accounts WHERE selected != 1 ORDER BY last_accessed DESC, acct_index ASC LIMIT ?', [limit]);
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
      account = Account(
          index: nextIndex,
          name: nextName,
          lastAccess: 0,
          selected: false,
          address: NanoUtil.seedToAddress(seed, nextIndex));
      await txn.rawInsert(
          'INSERT INTO Accounts (name, acct_index, last_accessed, selected, address) values(?, ?, ?, ?, ?)',
          [account.name, account.index, account.lastAccess, account.selected ? 1 : 0, account.address]);
    });
    return account;
  }

  Future<int> deleteAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawDelete('DELETE FROM Accounts WHERE acct_index = ?', [account.index]);
  }

  Future<int> saveAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawInsert(
        'INSERT INTO Accounts (name, acct_index, last_accessed, selected) values(?, ?, ?, ?)',
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
      await txn.rawUpdate('UPDATE Accounts set selected = ?, last_accessed = ? where acct_index = ?',
          [1, list[0]["last_access"] + 1, account.index]);
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
