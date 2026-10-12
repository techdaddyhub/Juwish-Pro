import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(String name, String email, String password);
  Future<bool> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> submitKyc({
    required String fullName,
    required String idType,
    required String idNumber,
    required String documentFilePath,
  });
  Future<bool> verifyTwoFactor(String otpCode);
}
