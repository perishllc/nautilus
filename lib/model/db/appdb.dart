import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallet_flutter/model/db/account.dart';
import 'package:wallet_flutter/model/db/node.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';

class DBHelper {
  DBHelper() {
    _nanoUtil = NanoUtil();
  }
  static const int DB_VERSION = 10;
  static const String CONTACTS_SQL = """
        CREATE TABLE Contacts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        address TEXT, 
        monkey_path TEXT
        )""";
  static const String USERS_SQL = """
        CREATE TABLE Users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        last_updated INTEGER,
        username TEXT,
        nickname TEXT,
        address TEXT,
        is_blocked BOOLEAN,
        type TEXT
        )""";
  static const String BLOCKED_SQL = """
        CREATE TABLE Blocked( 
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT,
        address TEXT
        )""";
  static const String REPS_SQL = """
        CREATE TABLE Reps( 
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        username TEXT, 
        address TEXT,
        uptime TEXT,
        synced TEXT,
        website TEXT
        )""";
  static const String ACCOUNTS_SQL = """
        CREATE TABLE Accounts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        acct_index INTEGER,
        selected INTEGER,
        watch_only BOOLEAN,
        last_accessed INTEGER,
        private_key TEXT,
        balance TEXT,
        address TEXT
        )""";
  static const String TX_DATA_SQL = """
        CREATE TABLE Transactions( 
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_address TEXT,
        to_address TEXT,
        amount_raw TEXT,
        is_request BOOLEAN,
        request_time INTEGER,
        is_fulfilled BOOLEAN,
        fulfillment_time INTEGER,
        block TEXT,
        link TEXT,
        memo_enc TEXT,
        is_memo BOOLEAN,
        is_message BOOLEAN,
        is_tx BOOLEAN,
        memo TEXT,
        uuid TEXT,
        is_acknowledged BOOLEAN,
        height INTEGER,
        send_height INTEGER,
        recv_height INTEGER,
        record_type TEXT,
        sub_type TEXT,
        metadata TEXT,
        status TEXT
        )""";
  static const String NODES_SQL = """
        CREATE TABLE Nodes( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT,
        selected BOOLEAN,
        http_url TEXT,
        ws_url TEXT
        )""";
  static const String SUBS_SQL = """
        CREATE TABLE Subscriptions( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT,
        active BOOLEAN,
        frequency TEXT,
        address TEXT,
        amount_raw TEXT
        )""";
  static const String USER_ADD_BLOCKED_COLUMN_SQL = """
    ALTER TABLE Users ADD is_blocked BOOLEAN
    """;
  static const String USER_ADD_NICKNAME_COLUMN_SQL = """
    ALTER TABLE Users ADD nickname TEXT
    """;
  static const String USER_ADD_TYPE_COLUMN_SQL = """
    ALTER TABLE Users ADD type TEXT
    """;
  static const String TXDATA_ADD_MESSAGE_COLUMN_SQL = """
    ALTER TABLE Transactions ADD is_message BOOLEAN
    """;
  static const String TXDATA_TIME_INT_SQL = """
    CREATE TEMPORARY TABLE t1_backup(id, from_address, to_address, amount_raw, is_request, is_fulfilled, block, link, memo_enc, is_memo, is_message, memo, uuid, is_acknowledged, height, send_height, recv_height, record_type, metadata, status);
    INSERT INTO t1_backup SELECT * FROM Transactions;
    DROP TABLE Transactions;
    CREATE TABLE Transactions(id, from_address, to_address, amount_raw, is_request, is_fulfilled, block, link, memo_enc, is_memo, is_message, memo, uuid, is_acknowledged, height, send_height, recv_height, record_type, metadata, status);
    INSERT INTO Transactions SELECT * FROM t1_backup;
    DROP TABLE t1_backup;
    ALTER TABLE Transactions ADD request_time INTEGER;
    ALTER TABLE Transactions ADD fulfillment_time INTEGER;
    """;
  static const String TXDATA_ADD_IS_TX_SUB_TYPE_COLUMN_SQL = """
    ALTER TABLE Transactions ADD is_tx BOOLEAN;
    ALTER TABLE Transactions ADD sub_type TEXT;
    """;
  static const String ACCOUNTS_ADD_WATCH_ONLY_COLUMN_SQL = """
    ALTER TABLE Accounts ADD watch_only BOOLEAN
    """;

  // TODO: prerelease
  static const String NODES_REMOVE_INDEX_SQL = """
    ALTER TABLE Nodes REMOVE node_index INTEGER
    """;

  static Database? _db;

  NanoUtil? _nanoUtil;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    final io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, "nautilus.db");
    final Database theDb = await openDatabase(
      path,
      version: DB_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return theDb;
  }

  // ignore: avoid_void_async
  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables
    await db.execute(CONTACTS_SQL);
    await db.execute(USERS_SQL);
    await db.execute(REPS_SQL);
    await db.execute(ACCOUNTS_SQL);
    await db.execute(BLOCKED_SQL);
    await db.execute(TX_DATA_SQL);
    await db.execute(NODES_SQL);
    await db.execute(SUBS_SQL);

    // add default nodes:
    await _addDefaultNodes(dbClient: db);
  }

  // ignore: avoid_void_async
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 3) {
      await db.execute(BLOCKED_SQL);
      await db.execute(USER_ADD_TYPE_COLUMN_SQL);
    }

    if (oldVersion == 4) {
      await db.execute(USER_ADD_BLOCKED_COLUMN_SQL);
      await db.execute(USER_ADD_NICKNAME_COLUMN_SQL);
      await db.execute(TXDATA_ADD_MESSAGE_COLUMN_SQL);
    }

    if (oldVersion == 5) {
      // change TXData:
      //  request_time TEXT     -> request_time INTEGER
      //  fulfillment_time TEXT -> fulfillment_time INTEGER
      await db.execute(TXDATA_TIME_INT_SQL);
    }

    if (oldVersion == 6) {
      // change TXData:
      //  request_time TEXT     -> request_time INTEGER
      //  fulfillment_time TEXT -> fulfillment_time INTEGER
      await db.execute(TXDATA_ADD_IS_TX_SUB_TYPE_COLUMN_SQL);
    }

    if (oldVersion == 7) {
      // add watch_only column to accounts table:
      await db.execute(ACCOUNTS_ADD_WATCH_ONLY_COLUMN_SQL);
    }
    if (oldVersion == 8) {
      await db.execute(NODES_SQL);
      await _addDefaultNodes(dbClient: db);
    }
    if (oldVersion == 9) {
      await db.execute(SUBS_SQL);
    }
  }

  Future<void> _addDefaultNodes({Database? dbClient}) async {
    // add default nodes:
    await saveNode(
      Node(
        id: 0,
        name: "Perish Node",
        selected: true,
        http_url: "https://nautilus.perish.co/api",
        ws_url: "wss://nautilus.perish.co",
      ),
      dbClient: dbClient,
    );
    await saveNode(
      Node(
        id: 1,
        name: "Natrium Node",
        selected: false,
        http_url: "https://app.natrium.io/api",
        ws_url: "wss://app.natrium.io",
      ),
      dbClient: dbClient,
    );
  }

  Future<void> nukeDatabase() async {
    final Database dbClient = (await db)!;
    // remove the tables:
    await dbClient.execute("DROP TABLE IF EXISTS Contacts");
    await dbClient.execute("DROP TABLE IF EXISTS Users");
    await dbClient.execute("DROP TABLE IF EXISTS Blocked");
    await dbClient.execute("DROP TABLE IF EXISTS Reps");
    await dbClient.execute("DROP TABLE IF EXISTS Accounts");
    await dbClient.execute("DROP TABLE IF EXISTS Transactions");
    await dbClient.execute("DROP TABLE IF EXISTS Nodes");
    await dbClient.execute("DROP TABLE IF EXISTS Subscriptions");

    _onCreate(dbClient, DB_VERSION);
  }

  String lowerStripAddress(String address) {
    return address.toLowerCase().replaceAll("xrb_", "").replaceAll("nano_", "");
  }

  String? formatAddress(String? address) {
    if (address == null) {
      return null;
    }
    // nano mode:
    return "nano_${lowerStripAddress(address)}";
  }

  // NODES:

  // Nodes
  Future<List<Node>> getNodes() async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery("SELECT * FROM Nodes");
    final List<Node> nodes = [];
    for (int i = 0; i < list.length; i++) {
      nodes.add(
        Node(
          id: list[i]["id"] as int? ?? 0,
          name: list[i]["name"] as String,
          http_url: list[i]["http_url"] as String,
          ws_url: list[i]["ws_url"] as String,
          selected: list[i]["selected"] == 1,
        ),
      );
    }
    return nodes;
  }

  Future<Node> getSelectedNode() async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery("SELECT * FROM Nodes where selected = 1");
    final Node node = Node(
      id: list[0]["id"] as int?,
      name: list[0]["name"] as String,
      selected: true,
      http_url: list[0]["http_url"] as String,
      ws_url: list[0]["ws_url"] as String,
    );
    return node;
  }

  Future<void> changeNode(Node node) async {
    final Database dbClient = (await db)!;
    return dbClient.transaction((Transaction txn) async {
      await txn.rawUpdate('UPDATE Nodes set selected = false');
      // Get access increment count
      final List<Map> list = await txn.rawQuery('SELECT * FROM Nodes');
      await txn.rawUpdate('UPDATE Nodes set selected = ? WHERE id = ?', [1, node.id]);
    });
  }

  // TODO: prerelease: test if null id works here:
  Future<Node?> saveNode(Node node, {Database? dbClient}) async {
    dbClient ??= (await db)!;
    await dbClient.transaction((Transaction txn) async {
      await txn.rawInsert('INSERT INTO Nodes (name, id, selected, http_url, ws_url) values(?, ?, ?, ?, ?)', [
        node.name,
        node.id,
        if (node.selected) 1 else 0,
        node.http_url,
        node.ws_url,
      ]);
    });
    return node;
  }

  Future<int> deleteNode(Node node) async {
    final Database dbClient = (await db)!;
    return dbClient.rawDelete('DELETE FROM Nodes WHERE id = ?', [node.id]);
  }

  Future<int> changeNodeName(Node node, String name) async {
    final Database dbClient = (await db)!;
    return dbClient.rawUpdate('UPDATE Nodes SET name = ? WHERE id = ?', [name, node.id]);
  }

  // subscriptions:
  Future<List<Subscription>> getSubscriptions() async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery('SELECT * FROM Subscriptions');
    final List<Subscription> subs = [];
    for (int i = 0; i < list.length; i++) {
      subs.add(
        Subscription(
          name: list[i]["name"] as String,
          address: list[i]["address"] as String,
          amount_raw: list[i]["amount_raw"] as String,
          frequency: list[i]["frequency"] as String,
          active: list[i]["active"] == 1,
        ),
      );
    }
    return subs;
  }

  Future<Subscription?> saveSubscription(Subscription sub, {Database? dbClient}) async {
    dbClient ??= (await db)!;
    await dbClient.transaction((Transaction txn) async {
      await txn.rawInsert(
          'INSERT INTO Subscriptions (name, active, address, amount_raw, frequency) values(?, ?, ?, ?, ?)',
          [
            sub.name,
            if (sub.active) 1 else 0,
            sub.address,
            sub.amount_raw,
            sub.frequency,
          ]);
    });
    return sub;
  }

  Future<int> deleteSubscription(Subscription sub) async {
    final Database dbClient = (await db)!;
    return dbClient.rawDelete('DELETE FROM Subscriptions WHERE id = ?', [sub.id]);
  }

  Future<int> changeSubscriptionName(Subscription sub, String name) async {
    final Database dbClient = (await db)!;
    return dbClient.rawUpdate('UPDATE Subscriptions SET name = ? WHERE id = ?', [name, sub.id]);
  }

  // Contacts
  Future<List<User>> getContacts() async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery("SELECT * FROM Users WHERE nickname <> '' ORDER BY nickname");
    final List<User> contacts = [];
    for (int i = 0; i < list.length; i++) {
      contacts.add(User(
          username: list[i]["username"] as String?,
          nickname: list[i]["nickname"] as String?,
          address: list[i]["address"] as String?,
          type: list[i]["type"] as String?,
          last_updated: list[i]["last_updated"] as int?));
    }
    return contacts;
  }

  Future<List<User>> getContactsWithNameLike(String pattern) async {
    final Database dbClient = (await db)!;
    // List<Map> list =
    final List<Map> list = await dbClient
        .rawQuery("SELECT * FROM Users WHERE nickname LIKE '%$pattern%' AND nickname <> '' ORDER BY LOWER(nickname)");
    final List<User> contacts = [];
    for (int i = 0; i < list.length; i++) {
      contacts.add(User(
          username: list[i]["username"] as String?,
          nickname: list[i]["nickname"] as String?,
          address: list[i]["address"] as String?,
          type: list[i]["type"] as String?,
          last_updated: list[i]["last_updated"] as int?));
    }
    return contacts;
  }

  Future<User?> getContactWithAddress(String address) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient
        .rawQuery("SELECT * FROM Users WHERE lower(address) = '${formatAddress(address)}' AND nickname <> ''");
    if (list.isNotEmpty) {
      return User(
          nickname: list[0]["nickname"] as String?,
          address: list[0]["address"] as String?,
          type: list[0]["type"] as String?,
          username: list[0]["username"] as String?,
          last_updated: list[0]["last_updated"] as int?);
    }
    return null;
  }

  Future<User?> getContactWithName(String name) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery("SELECT * FROM Users WHERE nickname = ? AND nickname <> ''", [name]);
    if (list.isNotEmpty) {
      return User(nickname: list[0]["nickname"] as String?, address: list[0]["address"] as String?);
    }
    return null;
  }

  Future<bool> contactExistsWithName(String name) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(await dbClient
        .rawQuery("SELECT count(*) FROM Users WHERE lower(nickname) = ? AND nickname <> ''", [name.toLowerCase()]))!;
    return count > 0;
  }

  Future<bool> contactExistsWithAddress(String address) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(await dbClient
        .rawQuery("SELECT count(*) FROM Users WHERE lower(address) = '${formatAddress(address)}' AND nickname <> ''"))!;
    return count > 0;
  }

  Future<bool> watchAccountExistsWithAddress(String address) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        "SELECT count(*) FROM Accounts WHERE lower(address) = '${formatAddress(address)}' AND watch_only = 1"))!;
    return count > 0;
  }

  Future<bool> contactExistsWithAddressOrUser(String addressOrUsername) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        "SELECT count(*) FROM Users WHERE (lower(address) = '${formatAddress(addressOrUsername)}' OR lower(username) = '${addressOrUsername.toLowerCase()}') AND nickname <> ''"))!;
    return count > 0;
  }

  Future<bool> contactExistsWithUsername(String username) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        "SELECT count(*) FROM Users WHERE lower(username) = '${username.toLowerCase()}' AND nickname <> ''"))!;
    return count > 0;
  }

  Future<int> saveContacts(List<User> contacts) async {
    int count = 0;
    for (final User c in contacts) {
      if (await saveContact(c)) {
        count++;
      }
    }
    return count;
  }

  Future<bool> saveContact(User contact) async {
    final Database? dbClient = await db;
    bool username = false;
    bool address = false;
    bool name = false;
    // UPDATE by username / address / nickname:
    if (contact.nickname != null) {
      if (contact.username != null) {
        username = await dbClient!.rawUpdate(
                "UPDATE Users SET nickname = ? WHERE lower(username) = '${contact.username!.toLowerCase()}'",
                [contact.nickname]) >
            0;
      }
      if (contact.address != null) {
        // check if user with address exists, if not we have to make it:
        if (!(await userExistsWithAddress(contact.address!))) {
          contact.type = UserTypes.CONTACT;
          // save the user:
          address = await addUser(contact) > 0;
        } else {
          address = await dbClient!.rawUpdate(
                  "UPDATE Users SET nickname = ? WHERE lower(address) = '${contact.address!.toLowerCase()}'",
                  [contact.nickname]) >
              0;
        }
      }
    }
    return username || address || name;
  }

  Future<bool> deleteContact(User contact) async {
    final Database? dbClient = await db;
    // bool username = false;
    // bool address = false;
    bool nickname = false;
    if (contact.nickname != null) {
      nickname = await dbClient!.rawUpdate(
              "UPDATE Users SET nickname = '' WHERE lower(nickname) = '${contact.nickname!.toLowerCase()}'") >
          0;
    }
    return /*username || address || */ nickname;
  }

  // Users
  Future<List<User>> getUsers() async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery('SELECT * FROM Users ORDER BY username');
    final List<User> users = [];
    for (int i = 0; i < list.length; i++) {
      users.add(User(
          username: list[i]["username"] as String?,
          nickname: list[i]["nickname"] as String?,
          address: list[i]["address"] as String?,
          type: list[i]["type"] as String?,
          last_updated: list[i]["last_updated"] as int?));
    }
    return users;
  }

  Future<List<User>> getUsersWithNameLike(String pattern) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery("SELECT * FROM Users WHERE username LIKE '%$pattern%' ORDER BY LOWER(username)");
    final List<User> users = [];
    for (int i = 0; i < list.length; i++) {
      users.add(User(
          username: list[i]["username"] as String?,
          nickname: list[i]["nickname"] as String?,
          address: list[i]["address"] as String?,
          type: list[i]["type"] as String?,
          last_updated: list[i]["last_updated"] as int?));
    }
    return users;
  }

  Future<List<User>> getUserContactSuggestionsWithNameLike(String pattern) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM Users WHERE username LIKE '%$pattern%' OR nickname LIKE '%$pattern%' ORDER BY LOWER(username)");
    final List<User> users = [];
    const int maxSuggestions = 5;
    // dart doesn't support function overloading so I can't import dart:math for the min() function
    // which is why I'm doing this
    final int minned = (maxSuggestions <= list.length) ? maxSuggestions : list.length;
    for (int i = 0; i < minned; i++) {
      users.add(User(
          username: list[i]["username"] as String?,
          nickname: list[i]["nickname"] as String?,
          address: list[i]["address"] as String?,
          type: list[i]["type"] as String?,
          last_updated: list[i]["last_updated"] as int?));
    }
    return users;
  }

  Future<List<User>> getUserSuggestionsWithUsernameLike(String pattern) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery("SELECT * FROM Users WHERE username LIKE '%$pattern%' ORDER BY LOWER(username)");
    final List<User> users = [];
    const int maxSuggestions = 5;
    // dart doesn't support function overloading so I can't import dart:math for the min() function
    // which is why I'm doing this
    final int minned = (maxSuggestions <= list.length) ? maxSuggestions : list.length;
    for (int i = 0; i < minned; i++) {
      users.add(User(
          username: list[i]["username"] as String?,
          nickname: list[i]["nickname"] as String?,
          address: list[i]["address"] as String?,
          type: list[i]["type"] as String?,
          last_updated: list[i]["last_updated"] as int?));
    }
    return users;
  }

  Future<List<User>> getUserSuggestionsNoContacts(String pattern) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM Users WHERE username LIKE '%$pattern%' AND (nickname IS NULL OR nickname = '') ORDER BY LOWER(username)");
    final List<User> users = [];
    const int maxSuggestions = 5;
    // dart doesn't support function overloading so I can't import dart:math for the min() function
    // which is why I'm doing this
    final int minned = (maxSuggestions <= list.length) ? maxSuggestions : list.length;
    for (int i = 0; i < minned; i++) {
      users.add(User(
          username: list[i]["username"] as String?,
          nickname: list[i]["nickname"] as String?,
          address: list[i]["address"] as String?,
          type: list[i]["type"] as String?,
          last_updated: list[i]["last_updated"] as int?));
    }
    return users;
  }

  Future<User?> getUserWithAddress(String address) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery("SELECT * FROM Users WHERE lower(address) = '${formatAddress(address)}'");
    // TODO: Handle multiple users with the same address
    if (list.isNotEmpty) {
      return User(
          username: list[0]["username"] as String?,
          address: list[0]["address"] as String?,
          last_updated: list[0]["last_updated"] as int?,
          type: list[0]["type"] as String?,
          nickname: list[0]["nickname"] as String?);
    }
    return null;
  }

  Future<String?> getUsernameOrReturnAddress(String address) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery("SELECT * FROM Users WHERE lower(address) = '${formatAddress(address)}'");
    // TODO: Handle multiple users with the same address
    if (list.isNotEmpty) {
      return list[0]["username"] as String?;
    }
    return address;
  }

  Future<String?> getUsernameWithAddress(String address) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery("SELECT * FROM Users WHERE lower(address) = '${formatAddress(address)}'");
    // TODO: Handle multiple users with the same address
    if (list.isNotEmpty) {
      return list[0]["username"] as String?;
    }
    return null;
  }

  Future<User?> getUserOrContactWithAddress(String address) async {
    final Database dbClient = (await db)!;
    List<Map> list;
    list = await dbClient.rawQuery("SELECT * FROM Users WHERE lower(address) = '${formatAddress(address)}'");
    // TODO: Handle multiple users with the same address
    if (list.isNotEmpty) {
      return User(
          username: list[0]["username"] as String?,
          address: list[0]["address"] as String?,
          type: list[0]["type"] as String?,
          last_updated: list[0]["last_updated"] as int?,
          nickname: list[0]["nickname"] as String?);
    }
    return null;
  }

  Future<User?> isOnchainUsernameRecorded(String address) async {
    final Database dbClient = (await db)!;
    List<Map> list;
    list = await dbClient
        .rawQuery("SELECT * FROM Users WHERE type = 'ONCHAIN' AND lower(address) = '${formatAddress(address)}'");
    // TODO: Handle multiple users with the same address
    if (list.isNotEmpty) {
      return User(
          username: list[0]["username"] as String?,
          address: list[0]["address"] as String?,
          type: list[0]["type"] as String?,
          last_updated: list[0]["last_updated"] as int?,
          nickname: list[0]["nickname"] as String?);
    }
    return null;
  }

  Future<User?> getUserWithName(String name) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Users WHERE lower(username) = ?', [name.toLowerCase()]);
    if (list.isNotEmpty) {
      return User(
          username: list[0]["username"] as String?,
          address: list[0]["address"] as String?,
          nickname: list[0]["nickname"] as String?,
          last_updated: list[0]["last_updated"] as int?,
          is_blocked: list[0]["is_blocked"] == 1,
          type: list[0]["type"] as String?);
    }
    return null;
  }

  Future<User?> getUserOrContactWithName(String name) async {
    final Database dbClient = (await db)!;
    List<Map> list = [];
    if (name.contains("@") || name.contains(".") || name.contains("#")) {
      list = await dbClient.rawQuery(
          'SELECT * FROM Users WHERE lower(username) = ?', [SendSheetHelpers.stripPrefixes(name.toLowerCase())]);
    } else if (name.contains("★")) {
      list = await dbClient.rawQuery(
          'SELECT * FROM Users WHERE lower(nickname) = ?', [SendSheetHelpers.stripPrefixes(name.toLowerCase())]);
    } else {
      list = await dbClient.rawQuery('SELECT * FROM Users WHERE lower(username) = ? OR lower(nickname) = ?',
          [name.toLowerCase(), name.toLowerCase()]);
    }

    if (list.isNotEmpty) {
      return User(
          username: list[0]["username"] as String?,
          address: list[0]["address"] as String?,
          nickname: list[0]["nickname"] as String?,
          last_updated: list[0]["last_updated"] as int?,
          is_blocked: list[0]["is_blocked"] == 1,
          type: list[0]["type"] as String?);
    }
    return null;
  }

  Future<bool> userExistsWithName(String name) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT count(*) FROM Users WHERE lower(username) = ?', [name.toLowerCase()]))!;
    return count > 0;
  }

  Future<bool> userExistsWithAddress(String address) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT count(*) FROM Users WHERE lower(address) = '${formatAddress(address)}'"))!;
    return count > 0;
  }

  Future<int> addUser(User user) async {
    final Database dbClient = (await db)!;
    return dbClient.rawInsert('INSERT INTO Users (username, address, nickname, type, is_blocked) values(?, ?, ?, ?, ?)',
        [user.username, user.address, user.nickname, user.type, user.is_blocked]);
  }

  Future<int> addOrReplaceUser(User user) async {
    final Database? dbClient = await db;
    // check if it's already in the database:
    final bool userExists = await userExistsWithName(user.username!);

    if (!userExists) {
      return addUser(user);
    } else {
      return dbClient!.rawUpdate('UPDATE Users SET address = ? WHERE username = ?', [
        user.address,
        user.username,
      ]);
    }
  }

  Future<bool> deleteUser(User user) async {
    final Database dbClient = (await db)!;
    return await dbClient.rawDelete("DELETE FROM Users WHERE lower(username) = '${user.username!.toLowerCase()}'") > 0;
  }

  // Blocked
  Future<List<User>> getBlocked() async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery('SELECT * FROM Users WHERE is_blocked = 1 ORDER BY nickname');
    final List<User> users = [];
    for (int i = 0; i < list.length; i++) {
      users.add(User(
        username: list[i]["username"] as String?,
        address: list[i]["address"] as String?,
        nickname: list[i]["nickname"] as String?,
        type: list[i]["type"] as String?,
        is_blocked: list[i]["is_blocked"] == 1,
      ));
    }
    return users;
  }

  Future<bool> blockUser(User user) async {
    final Database? dbClient = await db;
    bool username = false;
    bool address = false;
    final bool nickname = false;
    // UPDATE by username / address / nickname:
    if (user.username != null) {
      username = await dbClient!
              .rawUpdate('UPDATE Users SET is_blocked = 1 WHERE lower(username) = ?', [user.username!.toLowerCase()]) >
          0;
    }
    if (user.address != null) {
      address = await dbClient!
              .rawUpdate('UPDATE Users SET is_blocked = 1 WHERE lower(address) = ?', [user.address!.toLowerCase()]) >
          0;
    }
    if (user.nickname != null) {
      address = await dbClient!
              .rawUpdate('UPDATE Users SET is_blocked = 1 WHERE lower(nickname) = ?', [user.nickname!.toLowerCase()]) >
          0;
    }
    return username || address || nickname;
  }

  Future<bool> unblockUser(User user) async {
    final Database? dbClient = await db;
    bool username = false;
    bool address = false;
    bool nickname = false;
    if (user.username != null) {
      username = await dbClient!
              .rawUpdate("UPDATE Users SET is_blocked = 0 WHERE lower(username) = '${user.username!.toLowerCase()}'") >
          0;
    }
    if (user.address != null) {
      address = await dbClient!
              .rawUpdate("UPDATE Users SET is_blocked = 0 WHERE lower(address) = '${user.address!.toLowerCase()}'") >
          0;
    }
    if (user.nickname != null) {
      nickname = await dbClient!
              .rawUpdate("UPDATE Users SET is_blocked = 0 WHERE lower(nickname) = '${user.nickname!.toLowerCase()}'") >
          0;
    }
    return username || address || nickname;
  }

  Future<bool> blockedExistsWithName(String nickname) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Users WHERE lower(nickname) = ? AND is_blocked = 1', [nickname.toLowerCase()]))!;
    return count > 0;
  }

  Future<bool> blockedExistsWithAddress(String address) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(await dbClient
        .rawQuery("SELECT count(*) FROM Users WHERE lower(address) = '${formatAddress(address)}' AND is_blocked = 1"))!;
    return count > 0;
  }

  Future<bool> blockedExistsWithUsername(String username) async {
    final Database dbClient = (await db)!;
    final int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Users WHERE lower(username) = ? AND is_blocked = 1', [username.toLowerCase()]))!;
    return count > 0;
  }

  // txData

  // TODO: make a constructor for this:
  TXData createTXDataFromDB(dynamic dbItem) {
    final TXData newData = TXData();
    if (dbItem["id"] != null) {
      newData.id = dbItem["id"] as int?;
    }
    if (dbItem["from_address"] != null) {
      newData.from_address = dbItem["from_address"] as String?;
    }
    if (dbItem["to_address"] != null) {
      newData.to_address = dbItem["to_address"] as String?;
    }
    if (dbItem["amount_raw"] != null && dbItem["amount_raw"] != "" && dbItem["amount_raw"] != "0") {
      newData.amount_raw = dbItem["amount_raw"] as String?;
    }
    if (dbItem["is_request"] != null) {
      if (dbItem["is_request"] == 0 || dbItem["is_request"] == null) {
        newData.is_request = false;
      } else {
        newData.is_request = true;
      }
    }
    if (dbItem["request_time"] != null) {
      if (dbItem["request_time"] is int) {
        newData.request_time = dbItem["request_time"] as int?;
      } else {
        newData.request_time = int.tryParse(dbItem["request_time"] as String);
      }
    }
    if (dbItem["is_fulfilled"] != null) {
      if (dbItem["is_fulfilled"] == 0 || dbItem["is_fulfilled"] == null) {
        newData.is_fulfilled = false;
      } else {
        newData.is_fulfilled = true;
      }
    }
    if (dbItem["fulfillment_time"] != null) {
      if (dbItem["fulfillment_time"] is int) {
        newData.fulfillment_time = dbItem["fulfillment_time"] as int?;
      } else {
        newData.fulfillment_time = int.tryParse(dbItem["fulfillment_time"] as String);
      }
    }
    if (dbItem["block"] != null) {
      newData.block = dbItem["block"] as String?;
    }
    if (dbItem["link"] != null) {
      newData.link = dbItem["link"] as String?;
    }
    if (dbItem["memo_enc"] != null) {
      newData.memo_enc = dbItem["memo_enc"] as String?;
    }
    if (dbItem["is_memo"] != null) {
      if (dbItem["is_memo"] == 0 || dbItem["is_memo"] == null) {
        newData.is_memo = false;
      } else {
        newData.is_memo = true;
      }
    }
    if (dbItem["is_message"] != null) {
      if (dbItem["is_message"] == 0 || dbItem["is_message"] == null) {
        newData.is_message = false;
      } else {
        newData.is_message = true;
      }
    }
    if (dbItem["is_tx"] != null) {
      if (dbItem["is_tx"] == 0 || dbItem["is_tx"] == null) {
        newData.is_tx = false;
      } else {
        newData.is_tx = true;
      }
    }
    if (dbItem["memo"] != null) {
      newData.memo = dbItem["memo"] as String?;
    }
    if (dbItem["uuid"] != null) {
      newData.uuid = dbItem["uuid"] as String?;
    }
    if (dbItem["is_acknowledged"] != null) {
      if (dbItem["is_acknowledged"] == 0 || dbItem["is_acknowledged"] == null) {
        newData.is_acknowledged = false;
      } else {
        newData.is_acknowledged = true;
      }
    }
    if (dbItem["height"] != null) {
      newData.height = dbItem["height"] as int?;
    }
    if (dbItem["send_height"] != null) {
      newData.send_height = dbItem["send_height"] as int?;
    }
    if (dbItem["recv_height"] != null) {
      newData.recv_height = dbItem["recv_height"] as int?;
    }
    if (dbItem["record_type"] != null) {
      newData.record_type = dbItem["record_type"] as String?;
    }
    if (dbItem["sub_type"] != null) {
      newData.sub_type = dbItem["sub_type"] as String?;
    }
    if (dbItem["metadata"] != null) {
      newData.metadata = dbItem["metadata"] as String?;
    }
    if (dbItem["status"] != null) {
      newData.status = dbItem["status"] as String?;
    }
    return newData;
  }

  Future<int> addTXData(TXData txData) async {
    final Database dbClient = (await db)!;
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
    final TXData? existingTXData = await getTXDataByUUID(txData.uuid!);
    if (existingTXData != null) {
      throw Exception("TXData already exists");
    }

    return dbClient.rawInsert(
        'INSERT INTO Transactions (from_address, to_address, amount_raw, is_request, request_time, is_fulfilled, fulfillment_time, block, link, memo_enc, is_memo, is_message, is_tx, memo, uuid, is_acknowledged, height, send_height, recv_height, record_type, sub_type, metadata, status) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
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
          txData.is_message,
          txData.is_tx,
          txData.memo,
          txData.uuid,
          txData.is_acknowledged,
          txData.height,
          txData.send_height,
          txData.recv_height,
          txData.record_type,
          txData.sub_type,
          txData.metadata,
          txData.status,
        ]);
  }

  Future<int> replaceTXDataByUUID(TXData txData) async {
    final Database dbClient = (await db)!;

    if (txData.uuid!.isEmpty) {
      throw Exception("this shouldn't happen");
    }

    return dbClient.rawUpdate(
        // 'UPDATE Transactions SET (from_address, to_address, amount_raw, is_request, request_time, is_fulfilled, fulfillment_time, block, memo, is_acknowledged, height) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) WHERE uuid = ?',
        'UPDATE Transactions SET from_address = ?, to_address = ?, amount_raw = ?, is_request = ?, request_time = ?, is_fulfilled = ?, fulfillment_time = ?, block = ?, link = ?, memo_enc = ?, is_memo = ?, is_message = ?, is_tx = ?, memo = ?, is_acknowledged = ?, height = ?, send_height = ?, recv_height = ?, record_type = ?, sub_type = ?, metadata = ?, status = ? WHERE uuid = ?',
        [
          txData.from_address,
          txData.to_address,
          if (txData.amount_raw == null || txData.amount_raw!.isEmpty) "" else txData.amount_raw,
          if (txData.is_request) 1 else 0,
          txData.request_time,
          if (txData.is_fulfilled) 1 else 0,
          txData.fulfillment_time,
          if (txData.block == null || txData.block!.isEmpty) "" else txData.block,
          if (txData.link == null || txData.link!.isEmpty) "" else txData.link,
          if (txData.memo_enc == null || txData.memo_enc!.isEmpty) "" else txData.memo_enc,
          if (txData.is_memo) 1 else 0,
          if (txData.is_message) 1 else 0,
          if (txData.is_tx) 1 else 0,
          if (txData.memo == null || txData.memo!.isEmpty) "" else txData.memo,
          if (txData.is_acknowledged) 1 else 0,
          txData.height,
          txData.send_height,
          txData.recv_height,
          txData.record_type,
          txData.sub_type,
          txData.metadata,
          txData.status,
          // must be last:
          txData.uuid,
        ]);
  }

  // txdata
  Future<List<TXData>> getTXData() async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    final List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<TXData?> getTXDataByBlock(String? block) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Transactions WHERE block = ? ORDER BY request_time DESC', [block]);
    if (list.isNotEmpty) {
      return createTXDataFromDB(list[0]);
    }
    return null;
  }

  Future<List<TXData>> getAccountSpecificTXData(String? account) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Transactions WHERE from_address = ? OR to_address = ? ORDER BY request_time DESC',
        [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    final List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<List<TXData>> getAccountSpecificSolids(String? account) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Transactions WHERE (from_address = ? OR to_address = ?) AND (is_request = 1 OR is_message = 1 OR is_tx = 1) ORDER BY request_time DESC',
        [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    final List<TXData> solids = [];
    for (int i = 0; i < list.length; i++) {
      solids.add(createTXDataFromDB(list[i]));
    }
    return solids;
  }

  Future<List<TXData>> getAccountSpecificRecords(String account) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Transactions WHERE (from_address = ? OR to_address = ?) AND (is_request = 0 AND is_message = 0 AND is_tx = 0) ORDER BY request_time DESC',
        [account, account]);
    // List<Map> list = await dbClient.rawQuery('SELECT * FROM Transactions ORDER BY request_time DESC');
    final List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<TXData?> getBlockSpecificTXData(String block) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Transactions WHERE block = ? ORDER BY request_time DESC', [block]);
    if (list.isNotEmpty) {
      return createTXDataFromDB(list[0]);
    }
    return null;
  }

  Future<TXData?> getTXDataByRequestTime(String request_time) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Transactions WHERE request_time = ? ORDER BY request_time DESC', [request_time]);
    if (list.isNotEmpty) {
      return createTXDataFromDB(list[0]);
    }
    return null;
  }

  Future<TXData?> getTXDataByUUID(String uuid) async {
    final Database dbClient = (await db)!;
    final List<Map> list =
        await dbClient.rawQuery("SELECT * FROM Transactions WHERE lower(uuid) = '${uuid.toLowerCase()}'");
    if (list.isNotEmpty) {
      return createTXDataFromDB(list[0]);
    }
    return null;
  }

  Future<bool> deleteTXData(TXData txData) async {
    final Database dbClient = (await db)!;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE lower(uuid) = '${txData.uuid!.toLowerCase()}'") > 0;
  }

  Future<bool> deleteTXDataByUUID(String uuid) async {
    final Database dbClient = (await db)!;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE lower(uuid) = '${uuid.toLowerCase()}'") > 0;
  }

  Future<bool> deleteTXDataByID(int? id) async {
    final Database dbClient = (await db)!;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE id = ?", [id]) > 0;
  }

  Future<bool> deleteTXDataByBlock(String block) async {
    final Database dbClient = (await db)!;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE lower(block) = '${block.toLowerCase()}'") > 0;
  }

  Future<bool> deleteTXDataByRequestTime(String request_time) async {
    final Database dbClient = (await db)!;
    return await dbClient.rawDelete("DELETE FROM Transactions WHERE request_time = ?", [request_time]) > 0;
  }

  Future<List<TXData>> getUnfulfilledTXs() async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Transactions WHERE (is_fulfilled = 0 AND is_request = 1) ORDER BY request_time');
    final List<TXData> transactions = [];
    for (int i = 0; i < list.length; i++) {
      transactions.add(createTXDataFromDB(list[i]));
    }
    return transactions;
  }

  Future<int> changeTXFulfillmentStatus(String? uuid, bool is_fulfilled) async {
    final Database dbClient = (await db)!;
    // return await dbClient.rawUpdate('UPDATE Transactions SET is_fulfilled = ? WHERE id = ?', [is_fulfilled ? 1 : 0, txData.id]);
    return dbClient.rawUpdate('UPDATE Transactions SET is_fulfilled = ? WHERE uuid = ?', [
      if (is_fulfilled) 1 else 0,
      uuid,
    ]);
  }

  Future<int> changeTXAckStatus(String uuid, bool is_acknowledged) async {
    final Database dbClient = (await db)!;
    // return await dbClient.rawUpdate('UPDATE Transactions SET is_fulfilled = ? WHERE id = ?', [is_fulfilled ? 1 : 0, txData.id]);
    return dbClient.rawUpdate('UPDATE Transactions SET is_acknowledged = ? WHERE uuid = ?', [
      if (is_acknowledged) 1 else 0,
      uuid,
    ]);
  }

  Future<void> nukeUsers() async {
    final Database dbClient = (await db)!;
    await dbClient.rawDelete("DELETE FROM Users");
  }

  Future<void> removeNanoToUsers() async {
    final Database dbClient = (await db)!;
    await dbClient.rawDelete("DELETE FROM Users WHERE type = '${UserTypes.NANO_TO}'");
  }

  // Accounts
  Future<List<Account>> getAccounts(String? seed) async {
    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts ORDER BY acct_index');
    final List<Account> accounts = [];
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(
          id: list[i]["id"] as int?,
          name: list[i]["name"] as String?,
          address: list[i]["address"] as String?,
          index: list[i]["acct_index"] as int?,
          lastAccess: list[i]["last_accessed"] as int?,
          selected: list[i]["selected"] == 1,
          watchOnly: list[i]["watch_only"] == 1,
          balance: list[i]["balance"] as String?));
    }
    for (final Account acc in accounts) {
      acc.address ??= await NanoUtil.uniSeedToAddress(seed!, acc.index!, derivationMethod);
      // check if account has a user:
      final User? user = await getUserWithAddress(acc.address!);
      if (user != null) {
        acc.user = user;
      }
    }
    return accounts;
  }

  Future<List<Account>> getRecentlyUsedAccounts(String? seed, {int limit = 2}) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Accounts WHERE selected != 1 ORDER BY last_accessed DESC, acct_index ASC LIMIT ?', [limit]);
    final List<Account> accounts = [];
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(
          id: list[i]["id"] as int?,
          name: list[i]["name"] as String?,
          address: list[i]["address"] as String?,
          index: list[i]["acct_index"] as int?,
          lastAccess: list[i]["last_accessed"] as int?,
          selected: list[i]["selected"] == 1,
          watchOnly: list[i]["watch_only"] == 1,
          balance: list[i]["balance"] as String?));
    }
    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    // check if account has a user:
    for (final Account acc in accounts) {
      acc.address ??= await NanoUtil.uniSeedToAddress(seed!, acc.index!, derivationMethod);
      final User? user = await getUserWithAddress(acc.address!);
      if (user != null) {
        acc.user = user;
      }
    }
    return accounts;
  }

  Future<Account?> addAccount(String? seed, {String? nameBuilder}) async {
    final Database dbClient = (await db)!;
    Account? account;
    await dbClient.transaction((Transaction txn) async {
      int nextIndex = 0;
      int? curIndex;
      final List<Map> accounts =
          await txn.rawQuery('SELECT * from Accounts WHERE acct_index >= 0 ORDER BY acct_index ASC');
      for (int i = 0; i < accounts.length; i++) {
        curIndex = accounts[i]["acct_index"] as int?;
        if (curIndex != nextIndex) {
          break;
        }
        nextIndex++;
      }
      final int nextID = nextIndex + 1;
      final String nextName = nameBuilder!.replaceAll("%1", nextID.toString());
      final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
      account = Account(
        index: nextIndex,
        name: nextName,
        lastAccess: 0,
        selected: false,
        watchOnly: false,
        address: await NanoUtil.uniSeedToAddress(
          seed!,
          nextIndex,
          derivationMethod,
        ),
      );
      await txn.rawInsert(
          'INSERT INTO Accounts (name, acct_index, last_accessed, selected, address) values(?, ?, ?, ?, ?)',
          [account!.name, account!.index, account!.lastAccess, if (account!.selected) 1 else 0, account!.address]);
    });
    // check if account has a user:
    final User? user = await getUserWithAddress(account!.address!);
    if (user != null) {
      account!.user = user;
    }
    return account;
  }

  Future<Account?> addWatchOnlyAccount(String accountName, String watchAddress) async {
    final Database dbClient = (await db)!;
    Account? account;
    await dbClient.transaction((Transaction txn) async {
      int nextIndex = 0;
      int? curIndex;
      final List<Map> accounts =
          await txn.rawQuery('SELECT * from Accounts WHERE acct_index >= 0 ORDER BY acct_index ASC');
      for (int i = 0; i < accounts.length; i++) {
        curIndex = accounts[i]["acct_index"] as int?;
        if (curIndex != nextIndex) {
          break;
        }
        nextIndex++;
      }
      final int nextID = nextIndex + 1;
      account = Account(
          index: nextIndex, name: accountName, lastAccess: 0, selected: false, watchOnly: true, address: watchAddress);
      await txn.rawInsert(
          'INSERT INTO Accounts (name, acct_index, last_accessed, selected, watch_only, address) values(?, ?, ?, ?, ?, ?)',
          [
            account!.name,
            account!.index,
            account!.lastAccess,
            if (account!.selected) 1 else 0,
            if (account!.watchOnly) 1 else 0,
            account!.address
          ]);
    });
    // check if account has a user:
    final User? user = await getUserWithAddress(account!.address!);
    if (user != null) {
      account!.user = user;
    }
    return account;
  }

  Future<Account?> addNewMainAccount(String? seed, {String? nameBuilder, int offset = 0}) async {
    final Database dbClient = (await db)!;
    Account? account;
    await dbClient.transaction((Transaction txn) async {
      int nextIndex = offset;
      final int nextID = nextIndex + 1;
      final String nextName = nameBuilder!.replaceAll("%1", nextID.toString());
      final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
      account = Account(
        index: nextIndex,
        name: nextName,
        lastAccess: 0,
        selected: true,
        address: await NanoUtil.uniSeedToAddress(
          seed!,
          nextIndex,
          derivationMethod,
        ),
      );
      await txn.rawInsert(
          'INSERT INTO Accounts (name, acct_index, last_accessed, selected, address) values(?, ?, ?, ?, ?)',
          [account!.name, account!.index, account!.lastAccess, if (account!.selected) 1 else 0, account!.address]);
    });
    // check if account has a user:
    final User? user = await getUserWithAddress(account!.address!);
    if (user != null) {
      account!.user = user;
    }
    return account;
  }

  Future<int> deleteAccount(Account account) async {
    final Database dbClient = (await db)!;
    return dbClient.rawDelete('DELETE FROM Accounts WHERE acct_index = ?', [account.index]);
  }

  Future<int> saveAccount(Account account) async {
    final Database dbClient = (await db)!;
    return dbClient.rawInsert('INSERT INTO Accounts (name, acct_index, last_accessed, selected) values(?, ?, ?, ?)',
        [account.name, account.index, account.lastAccess, if (account.selected) 1 else 0]);
  }

  Future<int> changeAccountName(Account account, String name) async {
    final Database dbClient = (await db)!;
    return dbClient.rawUpdate('UPDATE Accounts SET name = ? WHERE acct_index = ?', [name, account.index]);
  }

  Future<void> changeAccount(Account? account) async {
    final Database dbClient = (await db)!;
    return dbClient.transaction((Transaction txn) async {
      await txn.rawUpdate('UPDATE Accounts set selected = 0');
      // Get access increment count
      final List<Map> list = await txn.rawQuery('SELECT max(last_accessed) as last_access FROM Accounts');
      await txn.rawUpdate('UPDATE Accounts set selected = ?, last_accessed = ? where acct_index = ?',
          [1, list[0]["last_access"] + 1, account!.index]);
    });
  }

  Future<int> updateAccountBalance(Account account, String balance) async {
    final Database dbClient = (await db)!;
    return dbClient.rawUpdate('UPDATE Accounts set balance = ? where acct_index = ?', [balance, account.index]);
  }

  Future<Account?> getSelectedAccount(String? seed) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts where selected = 1');
    if (list.isEmpty) {
      return null;
    }
    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    final String address = (list[0]["address"] as String?) ??
        await NanoUtil.uniSeedToAddress(seed!, list[0]["acct_index"] as int, derivationMethod);
    final Account account = Account(
        id: list[0]["id"] as int?,
        name: list[0]["name"] as String?,
        index: list[0]["acct_index"] as int?,
        selected: true,
        lastAccess: list[0]["last_accessed"] as int?,
        balance: list[0]["balance"] as String?,
        watchOnly: list[0]["watch_only"] == 1,
        address: address);
    // check if account has a user:
    final User? user = await getUserWithAddress(account.address!);
    if (user != null) {
      account.user = user;
    }
    return account;
  }

  Future<Account?> getMainAccount(String? seed) async {
    final Database dbClient = (await db)!;
    final List<Map> list = await dbClient.rawQuery('SELECT * FROM Accounts where acct_index = 0');
    if (list.isEmpty) {
      return null;
    }
    final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
    final String address = await NanoUtil.uniSeedToAddress(seed!, list[0]["acct_index"] as int, derivationMethod);
    final Account account = Account(
        id: list[0]["id"] as int?,
        name: list[0]["name"] as String?,
        index: list[0]["acct_index"] as int?,
        selected: true,
        lastAccess: list[0]["last_accessed"] as int?,
        balance: list[0]["balance"] as String?,
        address: address);
    // check if account has a user:
    final User? user = await getUserWithAddress(account.address!);
    if (user != null) {
      account.user = user;
    }
    return account;
  }

  Future<int> dropAccounts() async {
    final Database dbClient = (await db)!;
    return dbClient.rawDelete('DELETE FROM ACCOUNTS');
  }
}
