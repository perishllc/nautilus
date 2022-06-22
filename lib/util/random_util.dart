import 'dart:math';

class RandomUtil {
  static String generateEncryptionSecret(int length) {
    String result = ""; // Resulting passcode
    const String chars = "abcdefghijklmnopqrstuvwxyz0123456789!?&+\\-'."; // Characters a passcode may contain
    final Random rng = new Random.secure();
    for (int i = 0; i < length; i ++) {
      result += chars[rng.nextInt(chars.length)];
    }
    return result;
  }
}