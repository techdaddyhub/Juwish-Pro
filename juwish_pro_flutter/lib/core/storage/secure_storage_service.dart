class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final Map<String, String> _inMemoryStore = {};
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyBiometricsEnabled = 'biometrics_enabled';
  static const String keyUserEmail = 'user_email';
  static const String keyTwoFactorEnabled = 'two_factor_enabled';

  Future<void> saveAuthToken(String token) async {
    _inMemoryStore[keyAuthToken] = token;
  }

  String? getAuthToken() {
    return _inMemoryStore[keyAuthToken];
  }

  Future<void> clearAuthToken() async {
    _inMemoryStore.remove(keyAuthToken);
    _inMemoryStore.remove(keyRefreshToken);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    _inMemoryStore[keyBiometricsEnabled] = enabled.toString();
  }

  bool isBiometricsEnabled() {
    return _inMemoryStore[keyBiometricsEnabled] == 'true';
  }

  Future<void> setTwoFactorEnabled(bool enabled) async {
    _inMemoryStore[keyTwoFactorEnabled] = enabled.toString();
  }

  bool isTwoFactorEnabled() {
    return _inMemoryStore[keyTwoFactorEnabled] == 'true';
  }

  Future<void> saveUserEmail(String email) async {
    _inMemoryStore[keyUserEmail] = email;
  }

  String? getUserEmail() {
    return _inMemoryStore[keyUserEmail];
  }
}
