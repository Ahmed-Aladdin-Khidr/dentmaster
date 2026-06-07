import '../repositories/data_management_repository.dart';

class ImportData {
  final DataManagementRepository _repo;
  ImportData(this._repo);

  Future<void> call(String zipPath) => _repo.importData(zipPath);
}
