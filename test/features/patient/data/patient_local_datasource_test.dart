import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dentmaster/core/database/app_database.dart';
import 'package:dentmaster/features/patient/data/datasources/patient_local_datasource.dart';

void main() {
  late AppDatabase db;
  late PatientLocalDatasourceImpl datasource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = PatientLocalDatasourceImpl(db);
  });

  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  PatientsCompanion makePatient({
    String id = 'p1',
    String name = 'Alice',
    String? phone,
  }) =>
      PatientsCompanion.insert(
        id: id,
        fullName: name,
        phone: Value(phone),
        createdAt: 1000000,
        updatedAt: 1000000,
      );

  AppointmentsCompanion makeAppointment({
    String id = 'a1',
    String patientId = 'p1',
    int date = 2000000,
  }) =>
      AppointmentsCompanion.insert(
        id: id,
        patientId: patientId,
        date: date,
        createdAt: 1000000,
        updatedAt: 1000000,
      );

  AppointmentImagesCompanion makeImage({
    String id = 'i1',
    String appointmentId = 'a1',
    int addedAt = 3000000,
  }) =>
      AppointmentImagesCompanion.insert(
        id: id,
        appointmentId: appointmentId,
        filePath: '/images/$id.jpg',
        fileName: '$id.jpg',
        fileSizeBytes: 1024,
        isCompressed: false,
        addedAt: addedAt,
      );

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('getAllPatients', () {
    test('returns inserted patient', () async {
      await datasource.insertPatient(makePatient());

      final result = await datasource.getAllPatients();

      expect(result, hasLength(1));
      expect(result.first.fullName, 'Alice');
    });

    test('returns patients ordered by fullName ascending', () async {
      await datasource.insertPatient(makePatient(id: 'p2', name: 'Zara'));
      await datasource.insertPatient(makePatient(id: 'p1', name: 'Alice'));

      final result = await datasource.getAllPatients();

      expect(result.map((p) => p.fullName).toList(), ['Alice', 'Zara']);
    });
  });

  group('searchPatients', () {
    setUp(() async {
      await datasource.insertPatient(
          makePatient(id: 'p1', name: 'Alice Smith', phone: '0501112233'));
      await datasource.insertPatient(
          makePatient(id: 'p2', name: 'Bob Jones', phone: '0509998877'));
    });

    test('matches by name substring (case-insensitive)', () async {
      final result = await datasource.searchPatients('alice');
      expect(result, hasLength(1));
      expect(result.first.id, 'p1');
    });

    test('matches by phone substring', () async {
      final result = await datasource.searchPatients('0509');
      expect(result, hasLength(1));
      expect(result.first.id, 'p2');
    });

    test('returns empty list when no match', () async {
      final result = await datasource.searchPatients('zzznomatch');
      expect(result, isEmpty);
    });
  });

  group('getPatientById', () {
    test('returns patient when found', () async {
      await datasource.insertPatient(makePatient());
      final result = await datasource.getPatientById('p1');
      expect(result, isNotNull);
      expect(result!.id, 'p1');
    });

    test('returns null when not found', () async {
      final result = await datasource.getPatientById('missing');
      expect(result, isNull);
    });
  });

  group('updatePatient', () {
    test('updates fullName in place', () async {
      await datasource.insertPatient(makePatient());
      await datasource.updatePatient(
        PatientsCompanion(
          id: const Value('p1'),
          fullName: const Value('Alice Updated'),
          updatedAt: const Value(2000000),
        ),
      );

      final result = await datasource.getPatientById('p1');
      expect(result!.fullName, 'Alice Updated');
    });
  });

  group('deletePatient', () {
    test('removes patient from list', () async {
      await datasource.insertPatient(makePatient());
      await datasource.deletePatient('p1');
      final result = await datasource.getAllPatients();
      expect(result, isEmpty);
    });
  });

  group('appointments', () {
    setUp(() async {
      await datasource.insertPatient(makePatient());
    });

    test('getAppointmentsForPatient returns appointments desc by date',
        () async {
      await datasource.insertAppointment(makeAppointment(id: 'a1', date: 1000));
      await datasource.insertAppointment(makeAppointment(id: 'a2', date: 3000));
      await datasource.insertAppointment(makeAppointment(id: 'a3', date: 2000));

      final result = await datasource.getAppointmentsForPatient('p1');
      expect(result.map((a) => a.id).toList(), ['a2', 'a3', 'a1']);
    });

    test('deleteAppointment removes the row', () async {
      await datasource.insertAppointment(makeAppointment());
      await datasource.deleteAppointment('a1');
      final result = await datasource.getAppointmentsForPatient('p1');
      expect(result, isEmpty);
    });
  });

  group('appointment images', () {
    setUp(() async {
      await datasource.insertPatient(makePatient());
      await datasource.insertAppointment(makeAppointment());
    });

    test('getImagesForAppointment returns images asc by addedAt', () async {
      await datasource.insertAppointmentImage(makeImage(id: 'i2', addedAt: 5000));
      await datasource.insertAppointmentImage(makeImage(id: 'i1', addedAt: 1000));

      final result = await datasource.getImagesForAppointment('a1');
      expect(result.map((i) => i.id).toList(), ['i1', 'i2']);
    });

    test('deleteAppointmentImage removes the row', () async {
      await datasource.insertAppointmentImage(makeImage());
      await datasource.deleteAppointmentImage('i1');
      final result = await datasource.getImagesForAppointment('a1');
      expect(result, isEmpty);
    });
  });
}
