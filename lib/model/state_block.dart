import 'dart:convert';

import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet_flutter/network/model/block_types.dart';

part 'state_block.g.dart';

/// For running in an isolate, needs to be top-level function
StateBlock stateBlockFromJson(String contents) {
  return StateBlock.fromJson(json.decode(contents) as Map<String, dynamic>);
}

@JsonSerializable()
class StateBlock {
  @JsonKey(name: 'type')
  String? type;

  // Represents subtype of this block: send/receive/change/open
  @JsonKey(name: 'subtype')
  String? subType;

  @JsonKey(name: 'previous')
  String? previous;

  @JsonKey(name: 'account')
  String? account;

  @JsonKey(name: 'representative')
  String? representative;

  @JsonKey(name: 'balance')
  String? balance;

  @JsonKey(name: 'link')
  String? link;

  @JsonKey(name: 'signature')
  String? signature;

  @JsonKey(name: 'work', includeIfNull: false)
  String? work;


  // new 1/25/23:
  @JsonKey(name: 'link_as_account', includeIfNull: false)
  String? linkAsAccount;
  // end new

  @JsonKey(ignore: true)
  String? hash;

  // Private key is only included on this object for seed sweeping requests
  @JsonKey(ignore: true)
  String? privKey;

  // Represents the amount this block intends to send
  // should be used to calculate balance after this send
  @JsonKey(ignore: true)
  String? sendAmount;
  // Represents local currency value of this TX
  @JsonKey(ignore: true)
  String? localCurrencyValue;

  /// StateBlock constructor.
  /// subtype is one of "send", "receive", "change", "open"
  /// In the case of subtype == "send" or subtype == "receive",
  /// then balance should be send amount (not balance after send).
  /// This is by design of this app, where we get previous balance in a server request
  /// and update it later before signing
  StateBlock({
    String? subtype,
    this.previous,
    this.representative,
    required String? balance,
    this.link,
    this.account,
    this.work,
    this.privKey,
    this.localCurrencyValue,
  }) {
    subType = subtype;
    type = BlockTypes.STATE;
    work = work;
    if (subtype == BlockTypes.SEND || subtype == BlockTypes.RECEIVE) {
      sendAmount = balance;
    } else {
      this.balance = balance;
    }
  }

  /// Used to set balance after receiving previous balance info from server
  void setBalance(String? previousBalance) {
    if (sendAmount == null) {
      return;
    }
    BigInt previous = BigInt.parse(previousBalance!);
    if (subType == BlockTypes.SEND) {
      // Subtract sendAmount from previous balance
      // If given a 0 as sendAmount, this is a special case indicating a max send
      if (BigInt.parse(sendAmount!) == BigInt.zero) {
        balance = "0";
      } else {
        balance = (previous - BigInt.parse(sendAmount!)).toString();
      }
    } else if (subType == BlockTypes.RECEIVE) {
      // Add previous balance to sendAmount
      balance = (previous + BigInt.parse(sendAmount!)).toString();
    }
  }

  /// Sign block with private key
  /// Returns signature if signed, null if this block is invalid and can't be signed
  Future<String?> sign(String? privateKey) async {
    if (balance == null) {
      return null;
    }
    hash = NanoBlocks.computeStateHash(
        NanoAccountType.NANO, account!, previous!, representative!, BigInt.parse(balance!), link!);
    signature = NanoSignatures.signBlock(hash!, privateKey!);
    return signature;
  }

  factory StateBlock.fromJson(Map<String, dynamic> json) => _$StateBlockFromJson(json);
  Map<String, dynamic> toJson() => _$StateBlockToJson(this);
}
