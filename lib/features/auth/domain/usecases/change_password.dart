import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository _repo;
  ChangePassword(this._repo);

  Future<void> call(String currentPassword, String newPassword) =>
      _repo.changePassword(currentPassword, newPassword);
}
