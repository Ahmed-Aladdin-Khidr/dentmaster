import '../../domain/entities/data_stats.dart';
import '../../domain/repositories/data_management_repository.dart';
import '../datasources/data_management_datasource.dart';

class DataManagementRepositoryImpl implements DataManagementRepository {
  final DataManagementDatasource _datasource;

  DataManagementRepositoryImpl(this._datasource);

  @override
  Future<DataStats> getStats() => _datasource.getStats();

  @override
  Future<void> exportData(String destinationZipPath) =>
      _datasource.exportData(destinationZipPath);

  @override
  Future<DataStats> previewImport(String zipPath) =>
      _datasource.previewImport(zipPath);

  @override
  Future<void> importData(String zipPath) => _datasource.importData(zipPath);
}
