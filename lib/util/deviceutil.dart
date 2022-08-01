import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Utilities for device specific info
class DeviceUtil {
  /// Return true if this device is an iPhone7 or greater
  static Future<bool> isIPhone7OrGreater() async {
    if (!Platform.isIOS) {
      return false;
    }
    final IosDeviceInfo deviceInfo = await DeviceInfoPlugin().iosInfo;
    final String? deviceIdentifier = deviceInfo.utsname.machine;
    if (deviceIdentifier == null) {
      return false;
    }
    switch (deviceIdentifier) {
      case 'iPhone5,1': // iPhone 5
      case 'iPhone5,2': // iPhone 5
      case 'iPhone5,3': // iPhone 5C
      case 'iPhone5,4': // iPhone 5C
      case 'iPhone6,1': // iPhone 5S
      case 'iPhone6,2': // iPhone 5S
      case 'iPhone7,2': // iPhone 6
      case 'iPhone7,1': // iPhone 6 plus
      case 'iPhone8,1': // iPhone 6s
      case 'iPhone8,2': // iPhone 6s plus
        return false;
      default:
        return true;
    }
  }

  static Future<bool> isIOS11OrGreater() async {
    if (!Platform.isIOS) {
      return false;
    }
    final IosDeviceInfo deviceInfo = await DeviceInfoPlugin().iosInfo;
    final String? version = deviceInfo.systemVersion;
    if (version == null) return false;
    final List<String> l = version.split('.');
    if (l.isNotEmpty) {
      return int.parse(l.elementAt(0)) >= 11;
    }
    return false;
  }

  static Future<bool> supportsNFCReader() async {
    return await isIPhone7OrGreater() && await isIOS11OrGreater();
  }
}
