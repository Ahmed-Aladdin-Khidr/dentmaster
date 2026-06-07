import '../entities/data_stats.dart';

abstract class DataManagementRepository {
  Future<DataStats> getStats();
  Future<void> exportData(String destinationZipPath);
  Future<DataStats> previewImport(String zipPath);
  Future<void> importData(String zipPath);
}
