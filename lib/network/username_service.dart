import 'dart:async';
import 'dart:convert';

import 'package:ens_dart/ens_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:nautilus_wallet_flutter/network/account_service.dart';
import 'package:nautilus_wallet_flutter/network/model/response/account_info_response.dart';
import 'package:nautilus_wallet_flutter/network/model/response/error_response.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/util/blake2b.dart';
import 'package:nautilus_wallet_flutter/util/nanoutil.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

late Web3Client _web3Client;
late Ens ens;

Map? decodeJson(dynamic src) {
  return json.decode(src as String) as Map?;
}

// UsernameService singleton
class UsernameService {
  // Constructor
  UsernameService() {
    initCommunication();
  }

  // Server Connection Strings
  static String BASE_SERVER_ADDRESS = "nautilus.perish.co";
  // static const String DEV_SERVER_ADDRESS = "node-local.perish.co:5076";
  static const String DEV_SERVER_ADDRESS = "35.139.167.170:5076";
  static String HTTP_PROTO = "https://";
  static String WS_PROTO = "wss://";

  static String RPC_URL = "nautilus.perish.co";
  static String WS_URL = "nautilus.perish.co";

  // auth:
  static String AUTH_SERVER = "https://auth.perish.co";

  static const String NANO_TO_USERNAME_LEASE_ENDPOINT = "https://api.nano.to/";
  static const String NANO_TO_KNOWN_ENDPOINT = "https://nano.to/known.json";
  static const String XNO_TO_KNOWN_ENDPOINT = "https://xno.to/known.json";

  // UD / ENS:
  static const String UD_ENDPOINT = "https://unstoppabledomains.g.alchemy.com/domains/";
  static const String ENS_RPC_ENDPOINT = "https://mainnet.infura.io/v3/";
  static const String ENS_WSS_ENDPOINT = "wss://mainnet.infura.io/ws/v3/";
  // UD / ENS:
  static late Web3Client _web3Client;
  static late Ens ens;

  final Logger log = sl.get<Logger>();

  Future<void> initCommunication() async {
    // ENS:
    String rpcUrl = "https://mainnet.infura.io/v3/${dotenv.env["INFURA_API_KEY"]!}";
    String wsUrl = "wss://mainnet.infura.io/ws/v3/${dotenv.env["INFURA_API_KEY"]!}";

    _web3Client = Web3Client(rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    ens = Ens(client: _web3Client);
  }

  Future<String?> checkUnstoppableDomain(String domain) async {
    final http.Response response = await http.get(Uri.parse(UD_ENDPOINT + domain),
        headers: {'Content-type': 'application/json', 'Authorization': 'Bearer ${dotenv.env["UD_API_KEY"]!}'});

    if (response.statusCode != 200) {
      return null;
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    String? address;

    if (decoded != null && decoded["records"] != null && decoded["records"]["crypto.NANO.address"] != null) {
      address = decoded["records"]["crypto.NANO.address"] as String?;
      if (NanoAccounts.isValid(NanoAccountType.NANO, address!)) {
        return address;
      }
    }

    return null;
  }

  Future<String?> checkENSDomain(String domain) async {
    final String pubKey = await ens.withName(domain).getCoinAddress(CoinType.NANO);
    if (pubKey.isEmpty) {
      return null;
    } else {
      final String address = NanoAccounts.createAccount(NanoAccountType.NANO, pubKey);
      // Validating address
      if (NanoAccounts.isValid(NanoAccountType.NANO, address)) {
        return address;
      } else {
        return null;
      }
    }
  }

  Future<String?> checkOpencapDomain(String domain) async {
    // get the SRV record:
    final String tld = domain.split(r"$").last;
    String resolvedDomain = "";

    // GET the SRV record using Cloudflare's DNS over HTTPS API:

    final http.Response dnsSRVResp = await http.get(
        Uri.parse("https://cloudflare-dns.com/dns-query?name=$tld&type=SRV"),
        headers: {"Accept": "application/dns-json"});
    if (dnsSRVResp.statusCode != 200) {
      return null;
    }

    final Map decodedSRVResp = json.decode(dnsSRVResp.body) as Map<dynamic, dynamic>;
    if (decodedSRVResp.containsKey("Answer")) {
      final List<dynamic> decodedAnswer = decodedSRVResp["Answer"] as List<dynamic>;
      for (final dynamic ans in decodedAnswer) {
        if (ans["data"] != null) {
          final String srvRecord = ans["data"] as String;
          final List<String> splitStrs = srvRecord.split(" ");
          resolvedDomain = splitStrs.last;
        }
      }
    }

    if (resolvedDomain.isEmpty) {
      return null;
    }

    // GET /v1/addresses?alias=alice$domain.tld&address_type=300

    final http.Response response = await http.get(
        Uri.parse("https://$resolvedDomain/v1/addresses?alias=$domain&address_type=300"),
        headers: {"Accept": "application/json"});
    if (response.statusCode != 200) {
      return null;
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    if (decoded.containsKey("address")) {
      return decoded["address"] as String?;
    }
    return null;
  }

  Future<dynamic> checkUsernameAvailability(String username) async {
    final http.Response response = await http
        .get(Uri.parse("$NANO_TO_USERNAME_LEASE_ENDPOINT/$username/lease"), headers: {"Accept": "application/json"});
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    return decoded;
  }

  Future<dynamic> checkUsernameUrl(String URL) async {
    final http.Response response = await http.get(Uri.parse(URL), headers: {"Accept": "application/json"});
    if (response.statusCode != 200) {
      return null;
    }
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    if (decoded.containsKey("error")) {
      return ErrorResponse.fromJson(decoded as Map<String, dynamic>);
    }
    return decoded;
  }

  // ON CHAIN USERNAMES:
  // credit where credit is due to plasmapower:

  Future<String?> getAddressFromUsername(String username) async {
// To lookup the account of a username:
// 1. Compute the account A2 which has the private key blake2b("username registration:" + username)
// 2. If it has not been opened, it's unregistered
// 3. If it has been opened, check if the rep field encodes the username. If so, the sender of the send which was received in the open block is the owner of the username. Otherwise, it's permanently unregistered.

    final String a2PrivateKey = NanoHelpers.byteToHex(blake2b(Uint8List.fromList(utf8.encode("username registration:$username"))));
    final String a2Account = NanoUtil.privateKeyToPublicAddress(a2PrivateKey);

    final AccountInfoResponse accountInfo = await sl.get<AccountService>().getAccountInfo(a2Account);

    
    if (accountInfo.unopened) {
      return null;
    }

    // account is opened:
    

    return null;
  }

  Future<String?> getUsernameFromAddress(String username) async {
// To lookup the username of an account:
// 1. Compute the account A3 which has the public key A + blake2b("username registration")*G
// 2. If it has not been opened, this account does not have an associated username
// 3. If it has been opened, its rep field encodes a username
// 4. Important: lookup the account of that username. If it's unregistered or registered to a different account, this account is said to not have an associated username.
// 5. If the username -> account mapping returns the A, then that username is the associated username of the account

    return null;
  }

  // Future<void> registerUsername(String username) async {
  //   // Suppose your private key is P, and your account is A.
  //   // Part 1 to registration: Register a username -> account mapping:
  //   // 1. Compute the account A2 which has the private key: blake2b("username registration:" + username)
  //   Uint8List privateKey = NanoHelpers.stringToBytesUtf8("username registration:$username");
  //   // TODO: check if the username is already registered:
  //   bool isRegistered = isUsernameRegistered(username) == null;
  //   if (isRegistered) {
  //     throw Exception("Username is already registered");
  //   }
  //   // send 1 raw to
  //   // blake2b()
  // }
}
