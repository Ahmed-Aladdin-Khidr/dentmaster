import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dentmaster/features/patient/domain/entities/appointment.dart';
import 'package:dentmaster/features/patient/domain/entities/appointment_image.dart';
import 'package:dentmaster/features/patient/domain/entities/patient.dart';
import 'package:dentmaster/features/patient/domain/repositories/patient_repository.dart';
import 'package:dentmaster/features/patient/domain/usecases/add_appointment.dart';
import 'package:dentmaster/features/patient/domain/usecases/add_appointment_image.dart';
import 'package:dentmaster/features/patient/domain/usecases/create_patient.dart';
import 'package:dentmaster/features/patient/domain/usecases/delete_appointment.dart';
import 'package:dentmaster/features/patient/domain/usecases/delete_appointment_image.dart';
import 'package:dentmaster/features/patient/domain/usecases/delete_patient.dart';
import 'package:dentmaster/features/patient/domain/usecases/get_all_patients.dart';
import 'package:dentmaster/features/patient/domain/usecases/get_patient_by_id.dart';
import 'package:dentmaster/features/patient/domain/usecases/search_patients.dart';
import 'package:dentmaster/features/patient/domain/usecases/update_appointment.dart';
import 'package:dentmaster/features/patient/domain/usecases/update_patient.dart';
import 'package:dentmaster/core/usecases/usecase.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  late MockPatientRepository repo;

  setUp(() => repo = MockPatientRepository());

  // ---------------------------------------------------------------------------
  // Fixtures
  // ---------------------------------------------------------------------------

  final now = DateTime(2024, 1, 1);

  final tPatient = Patient(
    id: 'p1',
    fullName: 'Alice',
    createdAt: now,
    updatedAt: now,
  );

  final tAppointment = Appointment(
    id: 'a1',
    patientId: 'p1',
    date: now,
    createdAt: now,
    updatedAt: now,
  );

  final tImage = AppointmentImage(
    id: 'i1',
    appointmentId: 'a1',
    filePath: '/images/i1.jpg',
    fileName: 'i1.jpg',
    fileSizeBytes: 1024,
    isCompressed: false,
    addedAt: now,
  );

  // ---------------------------------------------------------------------------
  // GetAllPatients
  // ---------------------------------------------------------------------------

  group('GetAllPatients', () {
    test('returns all patients from repository', () async {
      when(() => repo.getAllPatients()).thenAnswer((_) async => [tPatient]);

      final result = await GetAllPatients(repo)(const NoParams());

      expect(result, [tPatient]);
      verify(() => repo.getAllPatients()).called(1);
    });

    test('returns empty list when no patients', () async {
      when(() => repo.getAllPatients()).thenAnswer((_) async => []);

      final result = await GetAllPatients(repo)(const NoParams());

      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // SearchPatients
  // ---------------------------------------------------------------------------

  group('SearchPatients', () {
    test('delegates query to repository', () async {
      when(() => repo.searchPatients('alice'))
          .thenAnswer((_) async => [tPatient]);

      final result = await SearchPatients(repo)('alice');

      expect(result, [tPatient]);
      verify(() => repo.searchPatients('alice')).called(1);
    });

    test('returns empty list when no match', () async {
      when(() => repo.searchPatients(any())).thenAnswer((_) async => []);

      final result = await SearchPatients(repo)('zzz');

      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // GetPatientById
  // ---------------------------------------------------------------------------

  group('GetPatientById', () {
    test('returns patient when found', () async {
      when(() => repo.getPatientById('p1'))
          .thenAnswer((_) async => tPatient);

      final result = await GetPatientById(repo)('p1');

      expect(result, tPatient);
    });

    test('returns null when not found', () async {
      when(() => repo.getPatientById(any())).thenAnswer((_) async => null);

      final result = await GetPatientById(repo)('missing');

      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // CreatePatient
  // ---------------------------------------------------------------------------

  group('CreatePatient', () {
    test('calls repository.createPatient once', () async {
      when(() => repo.createPatient(tPatient)).thenAnswer((_) async {});

      await CreatePatient(repo)(tPatient);

      verify(() => repo.createPatient(tPatient)).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // UpdatePatient
  // ---------------------------------------------------------------------------

  group('UpdatePatient', () {
    test('calls repository.updatePatient once', () async {
      when(() => repo.updatePatient(tPatient)).thenAnswer((_) async {});

      await UpdatePatient(repo)(tPatient);

      verify(() => repo.updatePatient(tPatient)).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // DeletePatient
  // ---------------------------------------------------------------------------

  group('DeletePatient', () {
    test('calls repository.deletePatient with correct id', () async {
      when(() => repo.deletePatient('p1')).thenAnswer((_) async {});

      await DeletePatient(repo)('p1');

      verify(() => repo.deletePatient('p1')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // AddAppointment
  // ---------------------------------------------------------------------------

  group('AddAppointment', () {
    test('calls repository.addAppointment once', () async {
      when(() => repo.addAppointment(tAppointment)).thenAnswer((_) async {});

      await AddAppointment(repo)(tAppointment);

      verify(() => repo.addAppointment(tAppointment)).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // UpdateAppointment
  // ---------------------------------------------------------------------------

  group('UpdateAppointment', () {
    test('calls repository.updateAppointment once', () async {
      when(() => repo.updateAppointment(tAppointment))
          .thenAnswer((_) async {});

      await UpdateAppointment(repo)(tAppointment);

      verify(() => repo.updateAppointment(tAppointment)).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // DeleteAppointment
  // ---------------------------------------------------------------------------

  group('DeleteAppointment', () {
    test('calls repository.deleteAppointment with correct id', () async {
      when(() => repo.deleteAppointment('a1')).thenAnswer((_) async {});

      await DeleteAppointment(repo)('a1');

      verify(() => repo.deleteAppointment('a1')).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // AddAppointmentImage
  // ---------------------------------------------------------------------------

  group('AddAppointmentImage', () {
    test('calls repository.addAppointmentImage once', () async {
      when(() => repo.addAppointmentImage(tImage)).thenAnswer((_) async {});

      await AddAppointmentImage(repo)(tImage);

      verify(() => repo.addAppointmentImage(tImage)).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // DeleteAppointmentImage
  // ---------------------------------------------------------------------------

  group('DeleteAppointmentImage', () {
    test('calls repository.deleteAppointmentImage with correct id', () async {
      when(() => repo.deleteAppointmentImage('i1')).thenAnswer((_) async {});

      await DeleteAppointmentImage(repo)('i1');

      verify(() => repo.deleteAppointmentImage('i1')).called(1);
    });
  });
}
