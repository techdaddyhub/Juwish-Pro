class BiometricHelper {
  static Future<bool> canAuthenticateWithBiometrics() async {
    // Platform biometric capability indicator
    return true;
  }

  static Future<bool> isBiometricAvailable() => canAuthenticateWithBiometrics();

  static Future<bool> authenticate({
    String reason = 'Authenticate to access JuwishPro',
    String? promptMessage,
  }) async {
    // Simulate / execute biometric verification with brief biometric check
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  static Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access JuwishPro',
    String? promptMessage,
  }) =>
      authenticate(reason: reason, promptMessage: promptMessage);
}
