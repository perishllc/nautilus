import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:nautilus_wallet_flutter/localization.dart';
import 'package:nautilus_wallet_flutter/model/address.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/ui/util/ui_util.dart';
import 'package:quiver/strings.dart';
import 'package:validators/validators.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

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

  static String? _parseData(String data, DataType type) {
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
      if (NanoSeeds.isValidSeed(data)) {
        return data;
      }
    } else if (type == DataType.DATA) {
      // Check if an address or manta result
      final Address address = Address(data);
      if (address.isValid()) {
        return data;
      }
    }
    return null;
  }

  static Future<String?> getClipboardText(DataType type) async {
    final ClipboardData? data = await Clipboard.getData("text/plain");
    if (data == null || data.text == null) {
      return null;
    }
    return _parseData(data.text!, type);
  }

  static Future<String?> getQRData(DataType type, BuildContext context) async {
    UIUtil.cancelLockEvent();
    try {
      final String data = (await BarcodeScanner.scan(/*StateContainer.of(context).curTheme.qrScanTheme*/)).rawContent;
      if (isEmpty(data)) {
        return null;
      }
      return _parseData(data, type);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        UIUtil.showSnackbar(AppLocalization.of(context)!.qrInvalidPermissions, context);
        return QRScanErrs.PERMISSION_DENIED;
      } else {
        UIUtil.showSnackbar(AppLocalization.of(context)!.qrUnknownError, context);
        return QRScanErrs.UNKNOWN_ERROR;
      }
    } on FormatException {
      return QRScanErrs.CANCEL_ERROR;
    } catch (e) {
      log.e("Unknown QR Scan Error ${e.toString()}", e);
      return QRScanErrs.UNKNOWN_ERROR;
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
      final Future<dynamic> delayed = Future.delayed(const Duration(minutes: 2));
      delayed.then((_) {
        return true;
      });
      setStream = delayed.asStream().listen((_) {
        Clipboard.getData("text/plain").then((ClipboardData? data) {
          if (data != null && data.text != null && NanoSeeds.isValidSeed(data.text!)) {
            Clipboard.setData(const ClipboardData(text: ""));
          }
        });
      });
    }
  }
}
