import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/data_stats.dart';

abstract class DataManagementDatasource {
  Future<DataStats> getStats();
  Future<void> exportData(String destinationZipPath);
  Future<DataStats> previewImport(String zipPath);
  Future<void> importData(String zipPath);
}

class DataManagementDatasourceImpl implements DataManagementDatasource {
  final AppDatabase _db;

  DataManagementDatasourceImpl(this._db);

  // ── Stats ────────────────────────────────────────────────────────────────

  @override
  Future<DataStats> getStats() async {
    final patientRow = await _db
        .customSelect('SELECT COUNT(*) AS c FROM patients')
        .getSingle();
    final apptRow = await _db
        .customSelect('SELECT COUNT(*) AS c FROM appointments')
        .getSingle();
    final imgRow = await _db
        .customSelect('SELECT COUNT(*) AS c FROM appointment_images')
        .getSingle();

    final dbFile = File(await _getDbPath());
    final imagesDir = Directory(await _getImagesDir());

    final dbSize = await dbFile.exists() ? await dbFile.length() : 0;
    final imgFolderSize = await _dirSize(imagesDir);

    return DataStats(
      patientCount: patientRow.read<int>('c'),
      appointmentCount: apptRow.read<int>('c'),
      imageCount: imgRow.read<int>('c'),
      databaseSizeBytes: dbSize,
      imageFolderSizeBytes: imgFolderSize,
    );
  }

  // ── Helpers — paths ──────────────────────────────────────────────────────

  // Asks SQLite for the actual on-disk path of the open database so we never
  // have to guess the path that drift_flutter chose for this platform.
  Future<String> _getDbPath() async {
    final rows = await _db.customSelect('PRAGMA database_list').get();
    for (final row in rows) {
      if (row.read<String>('name') == 'main') {
        return row.read<String>('file');
      }
    }
    // Fallback — should never be reached while the DB is open.
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, 'dentmaster.sqlite');
  }

  Future<String> _getImagesDir() async {
    final appDir = await getApplicationSupportDirectory();
    return p.join(appDir.path, 'images');
  }

  // ── Export ───────────────────────────────────────────────────────────────

  @override
  Future<void> exportData(String destinationZipPath) async {
    await _db.customStatement('PRAGMA wal_checkpoint(FULL)');

    final dbPath = await _getDbPath();
    final imagesPath = await _getImagesDir();

    final encoder = ZipFileEncoder();
    encoder.create(destinationZipPath);
    if (await File(dbPath).exists()) {
      await encoder.addFile(File(dbPath), 'dentmaster.sqlite');
    }
    if (await Directory(imagesPath).exists()) {
      await encoder.addDirectory(Directory(imagesPath), includeDirName: true);
    }
    await encoder.close();
  }

  // ── Preview Import ───────────────────────────────────────────────────────

  @override
  Future<DataStats> previewImport(String zipPath) async {
    final tempDir = await Directory.systemTemp.createTemp('dent_import_');
    try {
      await _extractZip(zipPath, tempDir.path);

      final tempDbPath = p.join(tempDir.path, 'dentmaster.sqlite');
      if (!await File(tempDbPath).exists()) {
        throw Exception(
            'Invalid backup: dentmaster.sqlite not found in archive.');
      }

      final tempDb = AppDatabase.forTesting(NativeDatabase(File(tempDbPath)));
      try {
        final patientRow = await tempDb
            .customSelect('SELECT COUNT(*) AS c FROM patients')
            .getSingle();
        final apptRow = await tempDb
            .customSelect('SELECT COUNT(*) AS c FROM appointments')
            .getSingle();
        final imgRow = await tempDb
            .customSelect('SELECT COUNT(*) AS c FROM appointment_images')
            .getSingle();

        final imagesDir =
            Directory(p.join(tempDir.path, 'images'));
        final imgFolderSize = await _dirSize(imagesDir);

        return DataStats(
          patientCount: patientRow.read<int>('c'),
          appointmentCount: apptRow.read<int>('c'),
          imageCount: imgRow.read<int>('c'),
          databaseSizeBytes: 0,
          imageFolderSizeBytes: imgFolderSize,
        );
      } finally {
        await tempDb.close();
      }
    } finally {
      await _deleteTempDir(tempDir);
    }
  }

  // ── Import ───────────────────────────────────────────────────────────────

  @override
  Future<void> importData(String zipPath) async {
    final tempDir = await Directory.systemTemp.createTemp('dent_import_apply_');
    try {
      await _extractZip(zipPath, tempDir.path);

      final tempDbPath = p.join(tempDir.path, 'dentmaster.sqlite');
      if (!await File(tempDbPath).exists()) {
        throw Exception(
            'Invalid backup: dentmaster.sqlite not found in archive.');
      }

      final dbPath = await _getDbPath();
      final imagesPath = await _getImagesDir();

      // Close DB before replacing the file.
      await _db.close();

      final destFile = File(dbPath);
      if (await destFile.exists()) await destFile.delete();
      await File(tempDbPath).copy(dbPath);

      final tempImagesDir = Directory(p.join(tempDir.path, 'images'));
      if (await tempImagesDir.exists()) {
        final targetImagesDir = Directory(imagesPath);
        if (await targetImagesDir.exists()) {
          await targetImagesDir.delete(recursive: true);
        }
        await _copyDirectory(tempImagesDir, targetImagesDir);
      }
    } finally {
      await _deleteTempDir(tempDir);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _extractZip(String zipPath, String outputDir) async {
    final inputStream = InputFileStream(zipPath);
    final archive = ZipDecoder().decodeBuffer(inputStream);
    await extractArchiveToDisk(archive, outputDir);
    inputStream.close();
  }

  Future<int> _dirSize(Directory dir) async {
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  Future<void> _copyDirectory(Directory source, Directory dest) async {
    await dest.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final newPath = p.join(dest.path, p.basename(entity.path));
      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      }
    }
  }

  // On Windows, SQLite releases WAL/SHM handles asynchronously after close().
  // Retry deletion with back-off to avoid errno 145 (directory not empty).
  Future<void> _deleteTempDir(Directory dir) async {
    for (int attempt = 0; attempt < 5; attempt++) {
      try {
        await dir.delete(recursive: true);
        return;
      } on FileSystemException {
        if (attempt == 4) rethrow;
        await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
      }
    }
  }
}
