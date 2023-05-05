import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricUtil {
  ///
  /// hasBiometrics()
  ///
  /// @returns [true] if device has fingerprint/faceID available and registered, [false] otherwise
  Future<bool> hasBiometrics() async {
    final LocalAuthentication localAuth = LocalAuthentication();
    final bool canCheck = await localAuth.canCheckBiometrics;
    if (canCheck) {
      final List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
      // availableBiometrics.forEach((type) {
      //   sl.get<Logger>().i(type.toString());
      //   sl.get<Logger>().i(
      //       "${type == BiometricType.face ? 'face' : type == BiometricType.iris ? 'iris' : type == BiometricType.fingerprint ? 'fingerprint' : type == BiometricType.strong ? 'strong' : type == BiometricType.weak ? 'weak' : 'unknown'}");
      // });
      if (availableBiometrics.contains(BiometricType.face)) {
        return true;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return true;
      } else if (availableBiometrics.contains(BiometricType.strong)) {
        return true;
      }
    }
    return false;
  }

  ///
  /// authenticateWithBiometrics()
  ///
  /// @param [message] Message shown to user in FaceID/TouchID popup
  /// @returns [true] if successfully authenticated, [false] otherwise
  Future<bool> authenticateWithBiometrics(BuildContext context, String message) async {
    final bool hasBiometricsEnrolled = await hasBiometrics();
    if (hasBiometricsEnrolled) {
      final LocalAuthentication localAuth = LocalAuthentication();
      return localAuth.authenticate(
          localizedReason: message,
          options: const AuthenticationOptions(
            useErrorDialogs: false,
            stickyAuth: false,
            sensitiveTransaction: true,
            biometricOnly: true,
          ));
    }
    return false;
  }
}
