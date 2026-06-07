// ignore_for_file: prefer_initializing_formals
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/export_data.dart';
import '../../domain/usecases/get_data_stats.dart';
import '../../domain/usecases/import_data.dart';
import '../../domain/usecases/preview_import.dart';
import 'data_management_event.dart';
import 'data_management_state.dart';

class DataManagementBloc
    extends Bloc<DataManagementEvent, DataManagementState> {
  final GetDataStats _getDataStats;
  final ExportData _exportData;
  final PreviewImport _previewImport;
  final ImportData _importData;

  DataManagementBloc({
    required GetDataStats getDataStats,
    required ExportData exportData,
    required PreviewImport previewImport,
    required ImportData importData,
  })  : _getDataStats = getDataStats,
        _exportData = exportData,
        _previewImport = previewImport,
        _importData = importData,
        super(const DataManagementState.initial()) {
    on<DataManagementLoadRequested>(_onLoadRequested);
    on<DataManagementExportRequested>(_onExportRequested);
    on<DataManagementImportFileSelected>(_onImportFileSelected);
    on<DataManagementImportConfirmed>(_onImportConfirmed);
    on<DataManagementResultDismissed>(_onResultDismissed);
  }

  Future<void> _onLoadRequested(
      DataManagementLoadRequested event,
      Emitter<DataManagementState> emit) async {
    emit(const DataManagementState.loading());
    try {
      final stats = await _getDataStats();
      emit(DataManagementState.ready(stats));
    } catch (e) {
      emit(DataManagementState.failure(e.toString()));
    }
  }

  Future<void> _onExportRequested(
      DataManagementExportRequested event,
      Emitter<DataManagementState> emit) async {
    emit(const DataManagementState.exporting());
    try {
      await _exportData(event.destinationPath);
      emit(DataManagementState.exportSuccess(event.destinationPath));
    } catch (e) {
      emit(DataManagementState.failure(e.toString()));
    }
  }

  Future<void> _onImportFileSelected(
      DataManagementImportFileSelected event,
      Emitter<DataManagementState> emit) async {
    emit(const DataManagementState.loading());
    try {
      final current = await _getDataStats();
      final incoming = await _previewImport(event.zipPath);
      emit(DataManagementState.importPreview(
        current: current,
        incoming: incoming,
        zipPath: event.zipPath,
      ));
    } catch (e) {
      emit(DataManagementState.failure(e.toString()));
    }
  }

  Future<void> _onImportConfirmed(
      DataManagementImportConfirmed event,
      Emitter<DataManagementState> emit) async {
    emit(const DataManagementState.importing());
    try {
      await _importData(event.zipPath);
      emit(const DataManagementState.importSuccess());
    } catch (e) {
      emit(DataManagementState.failure(e.toString()));
    }
  }

  Future<void> _onResultDismissed(
      DataManagementResultDismissed event,
      Emitter<DataManagementState> emit) async {
    emit(const DataManagementState.loading());
    try {
      final stats = await _getDataStats();
      emit(DataManagementState.ready(stats));
    } catch (e) {
      emit(DataManagementState.failure(e.toString()));
    }
  }
}
