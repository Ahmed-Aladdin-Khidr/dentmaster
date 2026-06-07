import '../repositories/auth_repository.dart';

class SetupPassword {
  final AuthRepository _repo;
  SetupPassword(this._repo);

  Future<void> call(String password) => _repo.setupPassword(password);
}
