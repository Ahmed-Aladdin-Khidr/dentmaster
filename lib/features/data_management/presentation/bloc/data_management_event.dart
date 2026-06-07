import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_management_event.freezed.dart';

@freezed
sealed class DataManagementEvent with _$DataManagementEvent {
  const factory DataManagementEvent.loadRequested() =
      DataManagementLoadRequested;
  const factory DataManagementEvent.exportRequested(String destinationPath) =
      DataManagementExportRequested;
  const factory DataManagementEvent.importFileSelected(String zipPath) =
      DataManagementImportFileSelected;
  const factory DataManagementEvent.importConfirmed(String zipPath) =
      DataManagementImportConfirmed;
  const factory DataManagementEvent.resultDismissed() =
      DataManagementResultDismissed;
}
