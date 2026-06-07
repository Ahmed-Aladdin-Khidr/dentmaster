import '../repositories/data_management_repository.dart';

class ExportData {
  final DataManagementRepository _repo;
  ExportData(this._repo);

  Future<void> call(String destinationZipPath) =>
      _repo.exportData(destinationZipPath);
}
