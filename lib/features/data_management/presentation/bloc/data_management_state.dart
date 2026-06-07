import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/data_stats.dart';

part 'data_management_state.freezed.dart';

@freezed
sealed class DataManagementState with _$DataManagementState {
  const factory DataManagementState.initial() = DataManagementInitial;
  const factory DataManagementState.loading() = DataManagementLoading;
  const factory DataManagementState.ready(DataStats stats) =
      DataManagementReady;
  const factory DataManagementState.exporting() = DataManagementExporting;
  const factory DataManagementState.exportSuccess(String path) =
      DataManagementExportSuccess;
  const factory DataManagementState.importPreview({
    required DataStats current,
    required DataStats incoming,
    required String zipPath,
  }) = DataManagementImportPreview;
  const factory DataManagementState.importing() = DataManagementImporting;
  const factory DataManagementState.importSuccess() =
      DataManagementImportSuccess;
  const factory DataManagementState.failure(String message) =
      DataManagementFailure;
}
