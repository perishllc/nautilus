import 'dart:convert';

class LedgerStatus {
  static const String NOT_CONNECTED = "NOT_CONNECTED";
  static const String READY = "READY";
  static const String LOCKED = "LOCKED";
}

class StatusCodes {
    static const int SECURITY_STATUS_NOT_SATISFIED = 0x6982;
    static const int CONDITIONS_OF_USE_NOT_SATISFIED = 0x6985;
    static const int INVALID_SIGNATURE = 0x6a81;
    static const int CACHE_MISS = 0x6a82;
}

const String zeroBlock = '0000000000000000000000000000000000000000000000000000000000000000';

class LedgerService {
  LedgerService();

  String walletPrefix = "44'/165'/";

  int waitTimeout = 300000;
  int normalTimeout = 5000;
  int pollInterval = 15000;

  bool pollingLedger = false;

  String transportMode = 'USB';
  var DynamicTransport = TransportUSB;

  var ledger = {
    "status": LedgerStatus.NOT_CONNECTED,
    "nano": null,
    "transport": null,
  };

  // Scraps binding to any existing transport/nano object
  void resetLedger() {
    ledger["transport"] = null;
    ledger["nano"] = null;
  }

  Future<dynamic> loadTransport() async {
    // return new Promise((resolve, reject) => {
    //   this.DynamicTransport.create().then(trans => {

    //     // LedgerLogs.listen((log: LedgerLog) => console.log(`Ledger: ${log.type}: ${log.message}`));
    //     this.ledger.transport = trans;
    //     this.ledger.transport.setExchangeTimeout(this.waitTimeout); // 5 minutes
    //     ledger["nano"] = new Nano(ledger["transport"]);

    //     resolve(this.ledger.transport);
    //   }).catch(reject);
    // });
  }

  /**
   * Detect the optimal USB transport protocol for the current browser and OS
   */
  void detectUsbTransport() {
    // const isWindows = window.navigator.platform.includes('Win');

    // if (isWindows && this.supportsWebHID) {
    //   // Prefer WebHID on Windows due to stability issues with WebUSB
    //   this.transportMode = 'HID';
    //   this.DynamicTransport = TransportHID;
    // } else if (this.supportsWebUSB) {
    //   // Else prefer WebUSB
    //   this.transportMode = 'USB';
    //   this.DynamicTransport = TransportUSB;
    // } else if (this.supportsWebHID) {
    //   // Fallback to WebHID
    //   this.transportMode = 'HID';
    //   this.DynamicTransport = TransportHID;
    // } else {
    //   // Legacy browsers
    //   this.transportMode = 'U2F';
    //   this.DynamicTransport = TransportU2F;
    // }
    // Else prefer WebUSB
    transportMode = "USB";
    DynamicTransport = TransportUSB;
  }

  /**
   * Main ledger loading function.  Can be called multiple times to attempt a reconnect.
   * @param {boolean} hideNotifications
   * @returns {Promise<any>}
   */
  dynamic loadLedger([bool hideNotifications = false]) async {
    // return new Promise(async (resolve, reject) => {

    // if (!ledger["transport"]) {
    if (ledger["transport"] != null) {
      // If in USB mode, detect best transport option
      if (transportMode != "Bluetooth") {
        detectUsbTransport();
        // TODO:
        // this.appSettings.setAppSetting('ledgerReconnect', 'usb');
      } else {
        // this.appSettings.setAppSetting('ledgerReconnect', 'bluetooth');
      }

      try {
        await loadTransport();
      } catch (err) {
        // TODO:
        // if (err.name !== 'TransportOpenUserCancelled') {
        print("Error loading ${transportMode} transport $err");
        ledger["status"] = LedgerStatus.NOT_CONNECTED;
        // ledgerStatus$.next({ status: this.ledger.status, statusText: `Unable to load Ledger transport: ${err.message || err}` });
        // }
        resetLedger();
        // resolve(false);
        return false;
      }
    }

    if (ledger["transport"] == null || ledger["nano"] == null) {
      return false;
    }

    if (ledger["status"] == LedgerStatus.READY) {
      return true; // Already ready?
    }
    bool resolved = false;

    // Set up a timeout when things are not ready
    // setTimeout(() => {
    Future.delayed(const Duration(seconds: 10), () {
      if (resolved) return true;
      print("Timeout expired, sending not connected");
      ledger["status"] = LedgerStatus.NOT_CONNECTED;
      //ledgerStatus$.next({ status: this.ledger.status, statusText: `Unable to detect Nano Ledger application (Timeout)` });
      // if (!hideNotifications) {
      //   notifications.sendWarning(`Unable to connect to the Ledger device.  Make sure it is unlocked and the nano application is open`);
      // }
      resolved = true;
      return false;
    });
    // }, 10000);

    // Try to load the app config
    try {
      var ledgerConfig = await ledger["nano"]?.getAppConfiguration();
      resolved = true;

      if (ledgerConfig == null) return false;
      if (ledgerConfig != null && ledgerConfig["version"] != null) {
        ledger["status"] = LedgerStatus.LOCKED;
        //ledgerStatus$.next({ status: ledger.status, statusText: `Nano app detected, but ledger is locked` });
      }
    } catch (err) {
      print("App config error: $err");
      // if (err.statusText === 'HALTED') {
      //   resetLedger();
      // }
      if (!hideNotifications && !resolved) {
        print("Unable to connect to the Ledger device.  Make sure your Ledger is unlocked.  Restart the nano app on your Ledger if the error persists");
      }
      resolved = true;
      return false;
    }

    // Attempt to load account 0 - which confirms the app is unlocked and ready
    try {
      var accountDetails = await getLedgerAccount(0);
      ledger["status"] = LedgerStatus.READY;
      // ledgerStatus$.next({ status: this.ledger.status, statusText: `Nano Ledger application connected` });

      if (!pollingLedger) {
        pollingLedger = true;
        pollLedgerStatus();
      }
    } catch (err) {
      print("Error on account details: $err");
      // if (err.statusCode === STATUS_CODES.SECURITY_STATUS_NOT_SATISFIED) {
      //   this.ledger.status = LedgerStatus.LOCKED;
      //   if (!hideNotifications) {
      //     this.notifications.sendWarning(`Ledger device locked.  Unlock and open the nano application`);
      //   }
      // }
    }

    // resolve(true);
    // }).catch(err => {
    //   console.log(`error when loading ledger `, err);
    //   if (!hideNotifications) {
    //     this.notifications.sendWarning(`Error loading Ledger device: ${typeof err === 'string' ? err : err.message}`, { length: 6000 });
    //   }

    //   return null;
    // });
  }

  updateCache(int accountIndex, String blockHash) async {
    if (ledger["status"] != LedgerStatus.READY) {
      await loadLedger(); // Make sure ledger is ready
    }
    var blockResponse = await api.blocksInfo([blockHash]);
    var blockData = blockResponse.blocks[blockHash];
    if (!blockData) throw Error("Unable to load block data");
    blockData.contents = jsonDecode(blockData.contents);

    var cacheData = {
      "representative": blockData.contents.representative,
      "balance": blockData.contents.balance,
      "previousBlock": blockData.contents.previous == zeroBlock ? null : blockData.contents.previous,
      "sourceBlock": blockData.contents.link,
    };

    return await ledger["nano"]?.cacheBlock(ledgerPath(accountIndex), cacheData, blockData.contents.signature);
  }

  dynamic updateCacheOffline(int accountIndex, blockData) async {
    if (ledger["status"] != LedgerStatus.READY) {
      await loadLedger(); // Make sure ledger is ready
    }

    var cacheData = {
      "representative": blockData.representative,
      "balance": blockData.balance,
      "previousBlock": blockData.previous == zeroBlock ? null : blockData.previous,
      "sourceBlock": blockData.link,
    };
    return await ledger["nano"]?.cacheBlock(ledgerPath(accountIndex), cacheData, blockData.signature);
  }

  dynamic signBlock(int accountIndex, dynamic blockData) async {
    if (ledger["status"] != LedgerStatus.READY) {
      await loadLedger(); // Make sure ledger is ready
    }
    ledger["transport"].setExchangeTimeout(waitTimeout);
    return await ledger["nano"]!.signBlock(ledgerPath(accountIndex), blockData);
  }

  String ledgerPath(int accountIndex) {
    return "$walletPrefix$accountIndex'";
  }

  dynamic getLedgerAccountWeb(int accountIndex, [bool showOnScreen = false]) async {
    ledger["transport"].setExchangeTimeout(showOnScreen ? waitTimeout : normalTimeout);
    try {
      return await ledger["nano"]?.getAddress(ledgerPath(accountIndex), showOnScreen);
    } catch (err) {
      throw err;
    }
  }

  dynamic getLedgerAccount(int accountIndex, [bool showOnScreen = false]) async {
    return await getLedgerAccountWeb(accountIndex, showOnScreen);
  }

  void pollLedgerStatus() {
    if (!pollingLedger) return;
    // TODO:
    // setTimeout(async () => {
    //   await this.checkLedgerStatus();
    //   this.pollLedgerStatus();
    // }, this.pollInterval);
  }

  Future<void> checkLedgerStatus() async {
    if (ledger["status"] != LedgerStatus.READY) {
      return;
    }

    try {
      var accountDetails = await getLedgerAccount(0);
      ledger["status"] = LedgerStatus.READY;
    } catch (err) {
      // Ignore race condition error, which means an action is pending on the ledger (such as block confirmation)
      // TODO:
      // if (err["name"] != 'TransportRaceCondition') {
      print("Check ledger status failed $err");
      ledger["status"] = "NOT_CONNECTED";
      pollingLedger = false;
      resetLedger();
      // }
    }

    // TODO:
    // ledgerStatus$.next({ status: ledger["status"], statusText: `` });
  }
}
