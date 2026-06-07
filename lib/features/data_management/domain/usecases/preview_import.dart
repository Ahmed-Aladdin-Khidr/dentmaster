import '../entities/data_stats.dart';
import '../repositories/data_management_repository.dart';

class PreviewImport {
  final DataManagementRepository _repo;
  PreviewImport(this._repo);

  Future<DataStats> call(String zipPath) => _repo.previewImport(zipPath);
}
