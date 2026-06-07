abstract class AuthRepository {
  Future<bool> isPasswordSet();
  Future<void> setupPassword(String password);
  Future<bool> verifyPassword(String password);
  Future<void> changePassword(String currentPassword, String newPassword);
}
