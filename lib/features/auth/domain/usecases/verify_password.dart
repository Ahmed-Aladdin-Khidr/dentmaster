import '../repositories/auth_repository.dart';

class VerifyPassword {
  final AuthRepository _repo;
  VerifyPassword(this._repo);

  Future<bool> call(String password) => _repo.verifyPassword(password);
}
