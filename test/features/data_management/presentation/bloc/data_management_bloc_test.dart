import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dentmaster/features/data_management/domain/entities/data_stats.dart';
import 'package:dentmaster/features/data_management/domain/usecases/export_data.dart';
import 'package:dentmaster/features/data_management/domain/usecases/get_data_stats.dart';
import 'package:dentmaster/features/data_management/domain/usecases/import_data.dart';
import 'package:dentmaster/features/data_management/domain/usecases/preview_import.dart';
import 'package:dentmaster/features/data_management/presentation/bloc/data_management_bloc.dart';
import 'package:dentmaster/features/data_management/presentation/bloc/data_management_event.dart';
import 'package:dentmaster/features/data_management/presentation/bloc/data_management_state.dart';

class MockGetDataStats extends Mock implements GetDataStats {}
class MockExportData extends Mock implements ExportData {}
class MockPreviewImport extends Mock implements PreviewImport {}
class MockImportData extends Mock implements ImportData {}

DataManagementBloc _makeBloc({
  required MockGetDataStats getDataStats,
  required MockExportData exportData,
  required MockPreviewImport previewImport,
  required MockImportData importData,
}) =>
    DataManagementBloc(
      getDataStats: getDataStats,
      exportData: exportData,
      previewImport: previewImport,
      importData: importData,
    );

const tStats = DataStats(
  patientCount: 5,
  appointmentCount: 12,
  imageCount: 30,
  databaseSizeBytes: 204800,
  imageFolderSizeBytes: 1048576,
);

const tIncomingStats = DataStats(
  patientCount: 3,
  appointmentCount: 7,
  imageCount: 15,
  databaseSizeBytes: 0,
  imageFolderSizeBytes: 512000,
);

void main() {
  late MockGetDataStats mockGetDataStats;
  late MockExportData mockExportData;
  late MockPreviewImport mockPreviewImport;
  late MockImportData mockImportData;
  late DataManagementBloc bloc;

  setUp(() {
    mockGetDataStats = MockGetDataStats();
    mockExportData = MockExportData();
    mockPreviewImport = MockPreviewImport();
    mockImportData = MockImportData();
    bloc = _makeBloc(
      getDataStats: mockGetDataStats,
      exportData: mockExportData,
      previewImport: mockPreviewImport,
      importData: mockImportData,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is DataManagementInitial', () {
    expect(bloc.state, isA<DataManagementInitial>());
  });

  group('DataManagementLoadRequested', () {
    test('emits loading then ready with stats', () async {
      when(() => mockGetDataStats()).thenAnswer((_) async => tStats);

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.loadRequested());
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<DataManagementLoading>());
      expect(states[1], isA<DataManagementReady>());
      expect((states[1] as DataManagementReady).stats.patientCount, 5);
    });

    test('emits failure on exception', () async {
      when(() => mockGetDataStats()).thenThrow(Exception('DB error'));

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.loadRequested());
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states.last, isA<DataManagementFailure>());
    });
  });

  group('DataManagementExportRequested', () {
    test('emits exporting then exportSuccess', () async {
      when(() => mockExportData(any())).thenAnswer((_) async {});

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.exportRequested('/tmp/backup.zip'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<DataManagementExporting>());
      expect(states[1], isA<DataManagementExportSuccess>());
      expect(
        (states[1] as DataManagementExportSuccess).path,
        '/tmp/backup.zip',
      );
      verify(() => mockExportData('/tmp/backup.zip')).called(1);
    });

    test('emits failure on exception', () async {
      when(() => mockExportData(any())).thenThrow(Exception('Disk full'));

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.exportRequested('/tmp/backup.zip'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states.last, isA<DataManagementFailure>());
    });
  });

  group('DataManagementImportFileSelected', () {
    test('emits loading then importPreview with both stat sets', () async {
      when(() => mockGetDataStats()).thenAnswer((_) async => tStats);
      when(() => mockPreviewImport(any()))
          .thenAnswer((_) async => tIncomingStats);

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.importFileSelected('/tmp/restore.zip'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<DataManagementLoading>());
      expect(states[1], isA<DataManagementImportPreview>());
      final preview = states[1] as DataManagementImportPreview;
      expect(preview.current.patientCount, 5);
      expect(preview.incoming.patientCount, 3);
      expect(preview.zipPath, '/tmp/restore.zip');
    });

    test('emits failure when previewImport throws', () async {
      when(() => mockGetDataStats()).thenAnswer((_) async => tStats);
      when(() => mockPreviewImport(any()))
          .thenThrow(Exception('Invalid archive'));

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.importFileSelected('/tmp/bad.zip'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states.last, isA<DataManagementFailure>());
    });
  });

  group('DataManagementImportConfirmed', () {
    test('emits importing then importSuccess', () async {
      when(() => mockImportData(any())).thenAnswer((_) async {});

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.importConfirmed('/tmp/restore.zip'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<DataManagementImporting>());
      expect(states[1], isA<DataManagementImportSuccess>());
      verify(() => mockImportData('/tmp/restore.zip')).called(1);
    });

    test('emits failure on exception', () async {
      when(() => mockImportData(any()))
          .thenThrow(Exception('File not found'));

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.importConfirmed('/tmp/restore.zip'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states.last, isA<DataManagementFailure>());
    });
  });

  group('DataManagementResultDismissed', () {
    test('reloads stats and emits ready', () async {
      when(() => mockGetDataStats()).thenAnswer((_) async => tStats);

      final states = <DataManagementState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DataManagementEvent.resultDismissed());
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<DataManagementLoading>());
      expect(states[1], isA<DataManagementReady>());
    });
  });
}
