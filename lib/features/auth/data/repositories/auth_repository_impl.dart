import 'package:bcrypt/bcrypt.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<bool> isPasswordSet() => _datasource.isPasswordSet();

  @override
  Future<void> setupPassword(String password) async {
    final hash = BCrypt.hashpw(password, BCrypt.gensalt());
    await _datasource.savePasswordHash(hash);
  }

  @override
  Future<bool> verifyPassword(String password) async {
    final hash = await _datasource.getPasswordHash();
    if (hash == null) return false;
    return BCrypt.checkpw(password, hash);
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final isValid = await verifyPassword(currentPassword);
    if (!isValid) throw Exception('Current password is incorrect.');
    await setupPassword(newPassword);
  }
}
