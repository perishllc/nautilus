import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:wallet_flutter/generated/l10n.dart';
import 'package:wallet_flutter/model/address.dart';
import 'package:wallet_flutter/model/db/subscription.dart';
import 'package:wallet_flutter/network/model/response/auth_item.dart';
import 'package:wallet_flutter/network/model/response/pay_item.dart';
import 'package:wallet_flutter/network/model/response/sub_item.dart';
import 'package:wallet_flutter/service_locator.dart';
import 'package:wallet_flutter/ui/scan/scan_screen.dart';
import 'package:wallet_flutter/ui/util/ui_util.dart';
import 'package:wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:wallet_flutter/util/nanoutil.dart';
import 'package:quiver/strings.dart';
import 'package:validators/validators.dart';

enum DataType { RAW, URL, ADDRESS, SEED, DATA }

class QRScanErrs {
  static const String PERMISSION_DENIED = "qr_denied";
  static const String UNKNOWN_ERROR = "qr_unknown";
  static const String CANCEL_ERROR = "qr_cancel";
  static const List<String> ERROR_LIST = [PERMISSION_DENIED, UNKNOWN_ERROR, CANCEL_ERROR];
}

class UserDataUtil {
  static final Logger log = sl.get<Logger>();

  static const MethodChannel _channel = MethodChannel('fappchannel');
  static StreamSubscription<dynamic>? setStream;

  static dynamic _parseData(String data, DataType type) {
    data = data.trim();
    if (type == DataType.RAW) {
      return data;
    } else if (type == DataType.URL) {
      if (isIP(data)) {
        return data;
      } else if (isURL(data)) {
        return data;
      }
    } else if (type == DataType.ADDRESS) {
      final Address address = Address(data);
      if (address.isValid()) {
        return address.address;
      }
    } else if (type == DataType.SEED) {
      // Check if valid seed
      if (NanoUtil.isValidSeed(data)) {
        return data;
      }
    } else if (type == DataType.DATA) {
      // Check if an address / URI scheme:
      dynamic fin;
      try {
        fin = uriParser(data);
      } catch (e) {
        sl.get<Logger>().e(e);
      }
      if (fin is Address && fin.isValid()) {
        return fin;
      } else if (fin is PayItem && fin.isValid()) {
        return fin;
      } else if (fin is AuthItem && fin.isValid()) {
        return fin;
      } else if (fin is SubItem && fin.isValid()) {
        return fin;
      }
    }
    return null;
  }

  static Future<String?> getClipboardText(DataType type) async {
    final ClipboardData? data = await Clipboard.getData("text/plain");
    if (data == null || data.text == null) {
      return null;
    }

    if (type == DataType.DATA) {
      throw Exception("getClipboard called with datatype: DATA!");
    }

    return _parseData(data.text!, type) as String?;
  }

  static Future<dynamic> getQRData(DataType type, BuildContext context) async {
    UIUtil.cancelLockEvent();
    try {
      final String? data = await Sheets.showAppHeightFullSheet(
        context: context,
        widget: const ScanScreen(),
      );

      if (isEmpty(data)) {
        return null;
      }
      return _parseData(data!, type);
    } catch (e) {
      UIUtil.showSnackbar(Z.of(context).qrUnknownError, context);
      log.e("Unknown QR Scan Error ${e.toString()}", e);
      return null;
    }
  }

  static Future<void> setSecureClipboardItem(String? value) async {
    if (Platform.isIOS) {
      final Map<String, dynamic> params = <String, dynamic>{
        'value': value,
      };
      await _channel.invokeMethod("setSecureClipboardItem", params);
    } else {
      // Set item in clipboard
      await Clipboard.setData(ClipboardData(text: value));
      // Auto clear it after 2 minutes
      if (setStream != null) {
        setStream!.cancel();
      }
      final Future<dynamic> delayed = Future<dynamic>.delayed(const Duration(minutes: 2));
      delayed.then((_) {
        return true;
      });
      setStream = delayed.asStream().listen((_) {
        Clipboard.getData("text/plain").then((ClipboardData? data) {
          if (data != null && data.text != null && NanoUtil.isValidSeed(data.text!)) {
            Clipboard.setData(const ClipboardData(text: ""));
          }
        });
      });
    }
  }
}
