import '../repositories/auth_repository.dart';

class IsPasswordSet {
  final AuthRepository _repo;
  IsPasswordSet(this._repo);

  Future<bool> call() => _repo.isPasswordSet();
}
