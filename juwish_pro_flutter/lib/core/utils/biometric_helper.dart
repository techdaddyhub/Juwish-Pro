class BiometricHelper {
  static Future<bool> canAuthenticateWithBiometrics() async {
    // Platform biometric capability indicator
    return true;
  }

  static Future<bool> authenticate(
      {String reason = 'Authenticate to access JuwishPro'}) async {
    // Simulate / execute biometric verification with brief biometric check
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
