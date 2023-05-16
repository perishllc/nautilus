// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ens_dart/ens_dart.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/bus/contact_modified_event.dart';
import 'package:wallet_flutter/bus/payments_home_event.dart';
import 'package:wallet_flutter/localize.dart';
import 'package:wallet_flutter/model/db/appdb.dart';
import 'package:wallet_flutter/model/db/txdata.dart';
import 'package:wallet_flutter/model/db/user.dart';
import 'package:wallet_flutter/model/state_block.dart';
import 'package:wallet_flutter/network/account_service.dart';
import 'package:wallet_flutter/network/model/block_types.dart';
import 'package:wallet_flutter/network/model/request/process_request.dart';
import 'package:wallet_flutter/network/model/response/account_info_response.dart';
import 'package:wallet_flutter/network/model/response/block_info_item.dart';
import 'package:wallet_flutter/network/model/response/error_response.dart';
import 'package:wallet_flutter/network/model/response/process_response.dart';
import 'package:wallet_flutter/network/model/response/receivable_response.dart';
import 'package:wallet_flutter/network/model/response/receivable_response_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/ui/send/send_sheet.dart';
import 'package:wallet_flutter/util/blake2b.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:wallet_flutter/util/sharedprefsutil.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

// rust libs:
const String libbase = "perish";
final String path = Platform.isWindows ? "$libbase.dll" : "lib$libbase.so";
// final DynamicLibrary dylib = Platform.isIOS
//     ? DynamicLibrary.process()
//     : Platform.isMacOS
//         ? DynamicLibrary.executable()
//         : DynamicLibrary.open(path);
// final UsernameRegistrationImpl api = UsernameRegistrationImpl(dylib);

late Web3Client _web3Client;
late Ens ens;

Map? decodeJson(dynamic src) {
  return json.decode(src as String) as Map?;
}

// const String USERNAME_SPACE = "username registration";

// UsernameService singleton
class UsernameService {
  String USERNAME_SPACE = "username_registration_v1.0.0";

  // Constructor
  UsernameService() {
    if (kDebugMode) {
      USERNAME_SPACE = "username_registration_test";
    }
    initCommunication();
  }

  // auth:
  static String AUTH_SERVER = "https://auth.perish.co";

  static const String NANO_TO_USERNAME_LEASE_ENDPOINT = "https://api.nano.to/";
  static const String NANO_TO_KNOWN_ENDPOINT = "https://nano.to/known.json";
  static const String XNO_TO_KNOWN_ENDPOINT = "https://xno.to/known.json";

  // UD / ENS:
  static const String UD_ENDPOINT = "https://unstoppabledomains.g.alchemy.com/domains/";
  static const String ENS_RPC_ENDPOINT = "https://mainnet.infura.io/v3/";
  static const String ENS_WSS_ENDPOINT = "wss://mainnet.infura.io/ws/v3/";
  static late Web3Client _web3Client;
  static late Ens ens;

  final Logger log = sl.get<Logger>();

  Future<void> initCommunication() async {
    // ENS:
    final String rpcUrl = "https://mainnet.infura.io/v3/${dotenv.env["INFURA_API_KEY"]!}";
    final String wsUrl = "wss://mainnet.infura.io/ws/v3/${dotenv.env["INFURA_API_KEY"]!}";

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
      address = decoded["records"]["crypto.${NonTranslatable.currencyName.toUpperCase()}.address"] as String?;
      if (NanoAccounts.isValid(NonTranslatable.accountType, address!)) {
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
      final String address = NanoAccounts.createAccount(NonTranslatable.accountType, pubKey);
      // Validating address
      if (NanoAccounts.isValid(NonTranslatable.accountType, address)) {
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

  // NANO.TO:
  Future<dynamic> checkNanoToUsernameAvailability(String username) async {
    final http.Response response = await http
        .get(Uri.parse("$NANO_TO_USERNAME_LEASE_ENDPOINT/$username/lease"), headers: {"Accept": "application/json"});
    final Map decoded = json.decode(response.body) as Map<dynamic, dynamic>;
    return decoded;
  }

  Future<dynamic> checkNanoToUsernameUrl(String URL) async {
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

  Future<List<User>?> fetchNanoToKnown(http.Client client) async {
    final http.Response response = await client.get(Uri.parse(NANO_TO_KNOWN_ENDPOINT));
    // todo: use the compute function to run parseUsers in a separate isolate

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) {
      final User user = User.fromJson(json as Map<String, dynamic>);
      user.type = UserTypes.NANO_TO;
      user.nickname = null;
      return user;
    }).toList() as List<User>;
  }

  Future<String?> checkNanoToUsername(String username) async {
    try {
      final List<User>? users = await fetchNanoToKnown(http.Client());
      if (users == null) return null;
      for (final User user in users) {
        if (user.username == username) {
          return user.address;
        }
      }
    } catch (e) {
      log.e("Error checking nano.to username: $e");
    }
    return null;
  }

  Future<String?> checkNanoToAddress(String address) async {
    return checkWellKnownAddress("nano.to", address);
  }

  // END NANO.TO

  // ON CHAIN USERNAMES:
  // credit where credit is due to plasmapower:

  // Future<void> registerOnchainUsername(BuildContext context, String username) async {
  //   try {
  //     await registerUsernameToAccountMap(context, username);
  //   } catch (error) {
  //     throw Exception("Error registering username to account map: $error");
  //   }
  // }

  // Future<void> registerUsernameToAccountMap(BuildContext context, String username) async {
  //   // Suppose your private key is P, and your account is A.
  //   // Part 1 to registration: Register a username -> account mapping:
  //   // 1. Compute the account A2 which has the private key: blake2b("username registration:" + username)

  //   final bool isAvailable = await checkOnchainUsernameAvailability(username);
  //   if (!isAvailable) {
  //     throw Exception("Username is already registered");
  //   }

  //   final String A2PrivateKey = NanoHelpers.byteToHex(blake2b(
  //     NanoHelpers.stringToBytesUtf8(
  //       "$USERNAME_SPACE:$username",
  //     ),
  //   ));
  //   final String A2PublicKey = NanoUtil.privateKeyToPublic(A2PrivateKey);
  //   final String A2Account = NanoUtil.privateKeyToAddress(A2PrivateKey);

  //   const String ONE_RAW = "1";

  //   // register the username -> account mapping:
  //   final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
  //   final String privKey = await NanoUtil.uniSeedToPrivate(
  //     await StateContainer.of(context).getSeed(),
  //     StateContainer.of(context).selectedAccount!.index!,
  //     derivationMethod,
  //   );

  //   // send raw to A2:
  //   final ProcessResponse resp = await sl.get<AccountService>().requestSend(
  //         StateContainer.of(context).wallet!.representative,
  //         StateContainer.of(context).wallet!.frontier,
  //         ONE_RAW,
  //         A2Account,
  //         StateContainer.of(context).wallet!.address,
  //         privKey,
  //         max: false,
  //       );

  //   // TODO: check confirmation:
  //   await Future<dynamic>.delayed(const Duration(milliseconds: 3000));

  //   // update the wallet history:
  //   await StateContainer.of(context).requestUpdate();

  //   // receive the open block on A2:
  //   Uint8List usernameEncodedBytes = NanoHelpers.stringToBytesUtf8(username);
  //   while (usernameEncodedBytes.length < 32) {
  //     usernameEncodedBytes = Uint8List.fromList(usernameEncodedBytes.toList()..add(0));
  //   }
  //   final String representativeEncodedUsername = NanoUtil.publicKeyToAddress(
  //     NanoHelpers.byteToHex(usernameEncodedBytes),
  //   );

  //   // Receive receivable blocks
  //   final ReceivableResponse pr = await sl.get<AccountService>().getReceivable(A2Account, 10, threshold: "0");
  //   final Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks!;
  //   String? receivedHash;
  //   for (final String hash in receivableBlocks.keys) {
  //     final ReceivableResponseItem? item = receivableBlocks[hash];
  //     final ProcessResponse resp = await sl.get<AccountService>().requestOpen(
  //           item!.amount,
  //           hash,
  //           A2Account,
  //           A2PrivateKey,
  //           representative: representativeEncodedUsername,
  //         );
  //     if (resp.hash != null) {
  //       receivedHash = resp.hash;
  //     } else {
  //       throw Exception("Failed to open block");
  //     }
  //     // Hack that waits for blocks to be confirmed
  //     await Future<dynamic>.delayed(const Duration(milliseconds: 3000));
  //   }
  //   // check confirmation on the block hash:
  //   final BlockInfoItem blockInfoItem = await sl.get<AccountService>().requestBlockInfo(receivedHash);
  //   if (blockInfoItem.confirmed != "true") {
  //     throw Exception("Failed to confirm open block P1! (user -> account map)");
  //   }
  // }

  // Future<void> registerAccountToUsernameMap(BuildContext context, String username) async {
  //   // Part 2 to registration: Register an account -> username mapping:
  //   // 1. Prerequisite: verify that you have a confirmed username -> account mapping for this username
  //   // TODO:

  //   final String? accountOwner = await checkOnchainUsername(username);
  //   if (accountOwner != StateContainer.of(context).wallet!.address) {
  //     throw Exception("Username mapping isn't already registered");
  //   }

  //   // final String A2PrivateKey = NanoHelpers.byteToHex(blake2b(
  //   //   NanoHelpers.stringToBytesUtf8(
  //   //     "$USERNAME_SPACE:$username",
  //   //   ),
  //   // ));
  //   // final String A2Account = NanoUtil.privateKeyToAddress(A2PrivateKey);

  //   // 2. Compute the account A3 which has the expanded private key P + blake2b("username registration")*G where G is the ed25519 basepoint and P is assumed to be already expanded here
  //   final String publicKey = NanoUtil.addressToPublicKey(StateContainer.of(context).wallet!.address!);
  //   final U8Array32 publicKeyBytes = U8Array32(NanoHelpers.hexToBytes(publicKey));
  //   final U8Array32? A3PublicKey =
  //       await api.publicKeyUsernameRegistration(namespace: USERNAME_SPACE, publicKey: publicKeyBytes);
  //   final String A3Account =
  //       NanoUtil.publicKeyToAddress(NanoHelpers.byteToHex(Uint8List.fromList(A3PublicKey!.toList())));

  //   // 3. Send 1 raw from your account to A3
  //   const String ONE_RAW = "1";

  //   final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
  //   final String privKey = await NanoUtil.uniSeedToPrivate(
  //     await StateContainer.of(context).getSeed(),
  //     StateContainer.of(context).selectedAccount!.index!,
  //     derivationMethod,
  //   );
  //   final ProcessResponse resp = await sl.get<AccountService>().requestSend(
  //         StateContainer.of(context).wallet!.representative,
  //         StateContainer.of(context).wallet!.frontier,
  //         ONE_RAW,
  //         A3Account,
  //         StateContainer.of(context).wallet!.address,
  //         privKey,
  //         max: false,
  //       );

  //   // TODO: check confirmation:
  //   await Future<dynamic>.delayed(const Duration(milliseconds: 3000));

  //   // update the wallet history:
  //   await StateContainer.of(context).requestUpdate();

  //   // receive the open block on A3:
  //   Uint8List usernameEncodedBytes = NanoHelpers.stringToBytesUtf8(username);
  //   while (usernameEncodedBytes.length < 32) {
  //     usernameEncodedBytes = Uint8List.fromList(usernameEncodedBytes.toList()..add(0));
  //   }
  //   final String representativeEncodedUsername = NanoUtil.publicKeyToAddress(
  //     NanoHelpers.byteToHex(usernameEncodedBytes),
  //   );

  //   // 4. Receive the 1 raw as the open block on A3 which a representative field encoding your username in ASCII.
  //   // You can sign this because you can compute A3's expanded private key given your own.

  //   // Receive receivable blocks
  //   final ReceivableResponse pr = await sl.get<AccountService>().getReceivable(A3Account, 10, threshold: "0");
  //   final Map<String, ReceivableResponseItem> receivableBlocks = pr.blocks!;
  //   String? receivedHash;
  //   for (final String hash in receivableBlocks.keys) {
  //     final ReceivableResponseItem? item = receivableBlocks[hash];

  //     String stateHash = NanoBlocks.computeStateHash(
  //       NonTranslatable.accountType,
  //       A3Account,
  //       "0",
  //       representativeEncodedUsername,
  //       BigInt.parse(item!.amount!),
  //       hash,
  //     );

  //     StateBlock stateBlock = StateBlock(
  //       subtype: BlockTypes.OPEN,
  //       account: A3Account,
  //       previous: "0",
  //       representative: representativeEncodedUsername,
  //       balance: item.amount,
  //       link: hash,
  //     );

  //     final String derivationMethod = await sl.get<SharedPrefsUtil>().getKeyDerivationMethod();
  //     final String privKey = await NanoUtil.uniSeedToPrivate(
  //       await StateContainer.of(context).getSeed(),
  //       StateContainer.of(context).selectedAccount!.index!,
  //       derivationMethod,
  //     );

  //     final U8Array32 privateKeyBytes = U8Array32(NanoHelpers.hexToBytes(privKey));

  //     print("signing this state block hash: $stateHash");

  //     final Uint8List stateHashBytes = NanoHelpers.hexToBytes(stateHash);

  //     final signedStateHash = await api.signAsUsernameRegistration(
  //       namespace: USERNAME_SPACE,
  //       privateKey: privateKeyBytes,
  //       message: stateHashBytes,
  //     );

  //     final Uint8List signedBytes = Uint8List.fromList(signedStateHash.toList());
  //     final String signature = NanoHelpers.byteToHex(signedBytes);
  //     stateBlock.signature = signature;

  //     print(stateBlock.toJson());

  //     // Process
  //     final ProcessRequest processRequest = ProcessRequest(
  //       block: json.encode(stateBlock.toJson()),
  //       subtype: BlockTypes.OPEN,
  //     );

  //     // signing is special so we can't use the regular open method here:
  //     final ProcessResponse resp = await sl.get<AccountService>().requestProcess(processRequest);

  //     if (resp.hash != null) {
  //       receivedHash = resp.hash;
  //     } else {
  //       throw Exception("Failed to open block");
  //     }
  //     // Hack that waits for blocks to be confirmed
  //     await Future<dynamic>.delayed(const Duration(milliseconds: 500));
  //     break;
  //   }
  //   // check confirmation on the block hash:
  //   final BlockInfoItem blockInfoItem = await sl.get<AccountService>().requestBlockInfo(receivedHash);
  //   if (blockInfoItem.confirmed != "true") {
  //     throw Exception("Failed to confirm open block P1! (account -> username map)");
  //   }

  //   // You can re-register another username -> account mapping by repeating part 1
  //   // To change your account -> username mapping:
  //   // 1. Prerequisite: verify that you have a confirmed username -> account mapping for this username
  //   // 2. Compute the account A3 which has the expanded private key P + blake2b("username registration")*G where G is the ed25519 basepoint and P is assumed to be already expanded here
  //   // 3. Prerequisite: this account must be open if you already have an existing account -> username mapping (if not, just do Part 2)
  //   // 4. Issue a change block on that account, with a new rep encoding your new username. You can compute A3's private key as previously mentioned.
  //   // ----------
  // }

  // // LOOKUP FUNCTIONS:
  // Future<bool> checkOnchainUsernameAvailability(String username) async {
  //   final String A2PrivateKey = NanoHelpers.byteToHex(blake2b(
  //     NanoHelpers.stringToBytesUtf8(
  //       "$USERNAME_SPACE:$username",
  //     ),
  //   ));
  //   final String A2PublicKey = NanoUtil.privateKeyToPublic(A2PrivateKey);
  //   final String A2Account = NanoUtil.privateKeyToAddress(A2PrivateKey);

  //   // check if the account has any blocks, if it does, it's taken:
  //   final AccountInfoResponse accountInfo = await sl.get<AccountService>().getAccountInfo(A2Account);
  //   if (accountInfo.unopened) {
  //     return true;
  //   }

  //   return false;
  // }

  // Future<String?> checkOnchainUsername(String username) async {
  //   final String A2PrivateKey = NanoHelpers.byteToHex(blake2b(
  //     NanoHelpers.stringToBytesUtf8(
  //       "$USERNAME_SPACE:$username",
  //     ),
  //   ));
  //   final String A2Account = NanoUtil.privateKeyToAddress(A2PrivateKey);

  //   // check if the account has any blocks, if it does, it's taken:
  //   final AccountInfoResponse accountInfo = await sl.get<AccountService>().getAccountInfo(A2Account);

  //   if (accountInfo.unopened) {
  //     return null;
  //   }

  //   // get the open block:
  //   final String? openBlockHash = accountInfo.openBlock;
  //   if (openBlockHash == null) {
  //     return null;
  //   }

  //   // - query the open block
  //   // - query the block which is the open block's link
  //   // - that last block's account is the sender

  //   BlockInfoItem blockInfoItem = await sl.get<AccountService>().requestBlockInfo(openBlockHash);
  //   if (blockInfoItem.confirmed != "true") {
  //     throw Exception("Failed to confirm open block!");
  //   }

  //   if (blockInfoItem.contents == null) {
  //     throw Exception("Failed to get contents of open block!");
  //   }

  //   // check if the rep field encodes the username:
  //   final Map<String, dynamic> openBlockContents = json.decode(blockInfoItem.contents!) as Map<String, dynamic>;
  //   final String linkHash = openBlockContents["link"]! as String;

  //   blockInfoItem = await sl.get<AccountService>().requestBlockInfo(linkHash);

  //   final Map<String, dynamic> sendBlockContents = json.decode(blockInfoItem.contents!) as Map<String, dynamic>;

  //   final String usernameOwnerAddress = sendBlockContents["account"] as String;

  //   return usernameOwnerAddress;

  //   // // check if the rep field encodes the username:
  //   // final String repDecodedUsername = "TODO: $rep";
  //   // if (repDecodedUsername != username) {
  //   //   return null;
  //   // }

  //   // // the person who sent the open block to the account is the owner of the username:
  //   // final String? sender = openBlockContents["link_as_account"];
  //   // return sender;
  // }

  // // get the username from an account:
  // Future<String?> checkOnchainAddress(String address) async {
  //   // To lookup the username of an account:
  //   // 1. Compute the account A3 which has the public key A + blake2b("username registration")*G

  //   final String A2PublicKey = NanoUtil.addressToPublicKey(address);
  //   // 2. Compute the account A3 which has the expanded private key P + blake2b("username registration")*G where G is the ed25519 basepoint and P is assumed to be already expanded here
  //   final U8Array32 A2PublicKeyBytes = U8Array32(NanoHelpers.hexToBytes(A2PublicKey));
  //   final U8Array32? A3PublicKey =
  //       await api.publicKeyUsernameRegistration(namespace: USERNAME_SPACE, publicKey: A2PublicKeyBytes);
  //   final String A3Account =
  //       NanoUtil.publicKeyToAddress(NanoHelpers.byteToHex(Uint8List.fromList(A3PublicKey!.toList())));

  //   // 2. If it has not been opened, this account does not have an associated username

  //   // check if the account has any blocks, if it does, it's taken:
  //   final AccountInfoResponse accountInfo = await sl.get<AccountService>().getAccountInfo(A3Account);

  //   if (accountInfo.unopened) {
  //     return null;
  //   }

  //   // get the open block:
  //   final String? openBlockHash = accountInfo.openBlock;
  //   if (openBlockHash == null) {
  //     return null;
  //   }

  //   // 3. If it has been opened, its rep field encodes a username

  //   // decode the rep username:
  //   final BlockInfoItem blockInfoItem = await sl.get<AccountService>().requestBlockInfo(openBlockHash);
  //   if (blockInfoItem.confirmed != "true") {
  //     throw Exception("open block isn't confirmed!");
  //   }

  //   if (blockInfoItem.contents == null) {
  //     throw Exception("Failed to get contents of open block!");
  //   }

  //   // check if the rep field encodes the username:
  //   final Map<String, dynamic> openBlockContents = json.decode(blockInfoItem.contents!) as Map<String, dynamic>;
  //   final String rep = openBlockContents["representative"] as String? ?? "";

  //   Uint8List representativeEncodedUsernameBytes = NanoHelpers.hexToBytes(
  //     NanoUtil.addressToPublicKey(rep),
  //   );

  //   // remove padded 0s:
  //   while (representativeEncodedUsernameBytes.last == 0) {
  //     representativeEncodedUsernameBytes =
  //         representativeEncodedUsernameBytes.sublist(0, representativeEncodedUsernameBytes.length - 1);
  //   }

  //   final String decodedRep = NanoHelpers.bytesToUtf8String(representativeEncodedUsernameBytes);

  //   // 4. Important: lookup the account of that username. If it's unregistered or registered to a different account, this account is said to not have an associated username.
  //   // 5. If the username -> account mapping returns the A, then that username is the associated username of the account
  //   // now check the username -> account mapping to make sure it matches:

  //   final String? usernameAddressOwner = await checkOnchainUsername(decodedRep);

  //   if (usernameAddressOwner == address) {
  //     return decodedRep;
  //   }

  //   return null;
  // }

  // figure out what type of username, if any, this string is:
  Future<User?> figureOutUsernameType(String username) async {
    final String strippedUsername = SendSheetHelpers.stripPrefixes(username);
    String? type;
    String? address;

    // // check onchain username:
    // if (address == null) {
    //   address = await sl.get<UsernameService>().checkOnchainUsername(strippedUsername);
    //   if (address != null) {
    //     type = UserTypes.ONCHAIN;
    //   }
    // }

    // check if opencap address:
    if (address == null) {
      if (username.contains(r"$")) {
        address = await sl.get<UsernameService>().checkOpencapDomain(strippedUsername);
        if (address != null) {
          type = UserTypes.OPENCAP;
        }
      }
    }

    // check if UD domain:
    if (address == null) {
      if (username.contains(".")) {
        address = await sl.get<UsernameService>().checkUnstoppableDomain(strippedUsername);
        if (address != null) {
          type = UserTypes.UD;
        } else {
          // check if ENS domain:
          address = await sl.get<UsernameService>().checkENSDomain(strippedUsername);
          if (address != null) {
            type = UserTypes.ENS;
          }
        }
      }
    }

    // check if nano.to username:
    // if (address == null) {
    //   address = await sl.get<UsernameService>().checkNanoToUsername(strippedUsername);
    //   if (address != null) {
    //     type = UserTypes.NANO_TO;
    //   }
    // }

    // check if .well-known:
    if (address == null) {
      if (username.contains(".") && username.contains("@")) {
        address = await sl.get<UsernameService>().checkWellKnownUsername(username);
        if (address != null) {
          // strippedUsername = username;// bit of a hack, but we need the full username for the .well-known address
          type = UserTypes.WELL_KNOWN;
        }
      }
    }

    // add to the db if missing:
    if (type != null) {
      final User user = User(username: strippedUsername, address: address, type: type, is_blocked: false);
      await sl.get<DBHelper>().addUser(user);
      // force users list to update on the home page:
      EventTaxiImpl.singleton().fire(ContactModifiedEvent());
      EventTaxiImpl.singleton().fire(PaymentsHomeEvent(items: <TXData>[]));
      return user;
    }
    return null;
  }

  Future<User?> figureOutIfAddressHasName(String address) async {
    String? type;
    String? username;

    // // check if onchain address:
    // if (username == null) {
    //   username = await sl.get<UsernameService>().checkOnchainAddress(address);
    //   if (username != null) {
    //     type = UserTypes.ONCHAIN;
    //   }
    // }

    // check if nano.to (well-known) address:
    final List<String> domains = ["nano.to"];
    for (final String domain in domains) {
      if (username == null) {
        username = await sl.get<UsernameService>().checkWellKnownAddress(domain, address);
        if (username != null) {
          type = UserTypes.WELL_KNOWN;
          break;
        }
      }
    }

    // add to the db if missing:
    if (type != null) {
      final String strippedUsername = SendSheetHelpers.stripPrefixes(username!);
      final User user = User(username: strippedUsername, address: address, type: type, is_blocked: false);
      await sl.get<DBHelper>().addUser(user);
      // force users list to update on the home page:
      EventTaxiImpl.singleton().fire(ContactModifiedEvent());
      EventTaxiImpl.singleton().fire(PaymentsHomeEvent(items: <TXData>[]));
      return user;
    }
    return null;
  }

  Future<void> checkAddressDebounced(BuildContext context, String address) async {
    log.d("checking address: $address");
    try {
      String? checked = await sl.get<SharedPrefsUtil>().getWithExpiry(address) as String?;
      if (checked == null) {
        // check if we already have a record for this address:
        User? user = await sl.get<DBHelper>().getUserWithAddress(address);
        // adds to the db if found:
        user ??= await sl.get<UsernameService>().figureOutIfAddressHasName(address);

        // add some kind of timeout so we don't keep checking for the same username within a day:
        const int dayInSeconds = 86400;
        await sl.get<SharedPrefsUtil>().setWithExpiry(address, "1", dayInSeconds);
      }
    } catch (e) {
      log.e("error checking address: $address $e");
    }
  }

  Future<String?> checkWellKnownUsername(String username) async {
    // split the string by the @ symbol:
    try {
      final List<String> splitStrs = username.split("@");
      String name = splitStrs.first.toLowerCase();
      final String domain = splitStrs.last;

      if (name.isEmpty) {
        name = "_";
      }
      // lookup domain/.well-known/nano-currency.json and check if it has a nano address:
      final http.Response response = await http.get(
        Uri.parse("https://$domain/.well-known/nano-currency.json?names=$name"),
        headers: <String, String>{"Accept": "application/json"},
      );

      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;

      // Access the first element in the names array and retrieve its address
      final List<dynamic> names = decoded["names"] as List<dynamic>;
      for (final dynamic item in names) {
        if (item["name"].toLowerCase() == name) {
          return item["address"] as String;
        }
      }
    } catch (e) {
      log.e("error checking well-known username: $e");
    }
    return null;
  }

  Future<String?> checkWellKnownAddress(String domain, String address) async {
    try {
      // lookup domain/.well-known/nano-currency.json and check if it has a nano address:
      final http.Response response = await http.get(
        // Uri.parse("https://$domain/.well-known/nano-currency.json?address=$address"),// todo: this doesn't work for some reason
        Uri.parse("https://$domain/.well-known/nano-currency.json?names=$address"),
        headers: <String, String>{"Accept": "application/json"},
      );

      if (response.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;

      // Access the first element in the names array and retrieve its address
      final List<dynamic> names = decoded["names"] as List<dynamic>;
      for (final dynamic item in names) {
        if (item["address"].toLowerCase() == address) {
          return "${item["name"] as String}@$domain";
        }
      }
    } catch (e) {
      log.e("error checking well-known address: $e");
    }
    return null;
  }
}
