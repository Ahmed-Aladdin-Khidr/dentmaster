import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dentmaster/features/patient/domain/entities/appointment.dart';
import 'package:dentmaster/features/patient/domain/entities/patient.dart';
import 'package:dentmaster/features/patient/domain/usecases/delete_appointment.dart';
import 'package:dentmaster/features/patient/domain/usecases/delete_patient.dart';
import 'package:dentmaster/features/patient/domain/usecases/get_patient_by_id.dart';
import 'package:dentmaster/features/patient/domain/usecases/update_patient.dart';
import 'package:dentmaster/features/patient/presentation/bloc/patient_detail/patient_detail_bloc.dart';
import 'package:dentmaster/features/patient/presentation/bloc/patient_detail/patient_detail_event.dart';
import 'package:dentmaster/features/patient/presentation/bloc/patient_detail/patient_detail_state.dart';

class MockGetPatientById extends Mock implements GetPatientById {}
class MockUpdatePatient extends Mock implements UpdatePatient {}
class MockDeletePatient extends Mock implements DeletePatient {}
class MockDeleteAppointment extends Mock implements DeleteAppointment {}

class _FakePatient extends Fake implements Patient {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePatient());
  });
  late MockGetPatientById mockGetPatientById;
  late MockUpdatePatient mockUpdatePatient;
  late MockDeletePatient mockDeletePatient;
  late MockDeleteAppointment mockDeleteAppointment;
  late PatientDetailBloc bloc;

  final now = DateTime(2025, 1, 1);
  final tAppointment = Appointment(
    id: 'appt-1',
    patientId: 'p-1',
    date: DateTime(2025, 1, 15),
    createdAt: now,
    updatedAt: now,
  );
  final tPatient = Patient(
    id: 'p-1',
    fullName: 'Test Patient',
    createdAt: now,
    updatedAt: now,
    appointments: [tAppointment],
  );
  final tUpdatedPatient = Patient(
    id: 'p-1',
    fullName: 'Updated Patient',
    createdAt: now,
    updatedAt: now,
    appointments: [tAppointment],
  );

  setUp(() {
    mockGetPatientById = MockGetPatientById();
    mockUpdatePatient = MockUpdatePatient();
    mockDeletePatient = MockDeletePatient();
    mockDeleteAppointment = MockDeleteAppointment();
    bloc = PatientDetailBloc(
      getPatientById: mockGetPatientById,
      updatePatient: mockUpdatePatient,
      deletePatient: mockDeletePatient,
      deleteAppointment: mockDeleteAppointment,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is PatientDetailInitial', () {
    expect(bloc.state, isA<PatientDetailInitial>());
  });

  group('PatientDetailLoaded', () {
    test('emits loading then viewMode when patient is found', () async {
      when(() => mockGetPatientById(any())).thenAnswer((_) async => tPatient);

      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.loaded('p-1'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<PatientDetailLoading>());
      expect(states[1], isA<PatientDetailViewMode>());
      expect((states[1] as PatientDetailViewMode).patient, tPatient);
    });

    test('emits loading then failure when patient is null', () async {
      when(() => mockGetPatientById(any())).thenAnswer((_) async => null);

      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.loaded('missing-id'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<PatientDetailLoading>());
      expect(states[1], isA<PatientDetailFailure>());
    });

    test('emits failure on exception', () async {
      when(() => mockGetPatientById(any()))
          .thenThrow(Exception('DB error'));

      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.loaded('p-1'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states.last, isA<PatientDetailFailure>());
    });
  });

  group('PatientDetailEditStarted', () {
    test('emits editMode with same patient from viewMode', () async {
      when(() => mockGetPatientById(any())).thenAnswer((_) async => tPatient);
      bloc.add(const PatientDetailEvent.loaded('p-1'));
      await Future.delayed(const Duration(milliseconds: 50));

      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.editStarted());
      await Future.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(states.single, isA<PatientDetailEditMode>());
      expect((states.single as PatientDetailEditMode).patient, tPatient);
    });

    test('does nothing when not in viewMode', () async {
      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.editStarted());
      await Future.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(states, isEmpty);
    });
  });

  group('PatientDetailEditCancelled', () {
    test('reverts to viewMode with same patient', () async {
      when(() => mockGetPatientById(any())).thenAnswer((_) async => tPatient);
      bloc.add(const PatientDetailEvent.loaded('p-1'));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const PatientDetailEvent.editStarted());
      await Future.delayed(const Duration(milliseconds: 20));

      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.editCancelled());
      await Future.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(states.single, isA<PatientDetailViewMode>());
      expect((states.single as PatientDetailViewMode).patient, tPatient);
    });
  });

  group('PatientDetailSaved', () {
    test('emits saving then viewMode with refreshed patient', () async {
      when(() => mockGetPatientById(any())).thenAnswer((_) async => tPatient);
      bloc.add(const PatientDetailEvent.loaded('p-1'));
      await Future.delayed(const Duration(milliseconds: 50));

      when(() => mockUpdatePatient(any())).thenAnswer((_) async {});
      when(() => mockGetPatientById('p-1'))
          .thenAnswer((_) async => tUpdatedPatient);

      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(PatientDetailEvent.saved(tUpdatedPatient));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<PatientDetailSaving>());
      expect(states[1], isA<PatientDetailViewMode>());
      expect(
        (states[1] as PatientDetailViewMode).patient.fullName,
        'Updated Patient',
      );
    });
  });

  group('PatientDetailDeleteRequested', () {
    test('emits saving then deleted', () async {
      when(() => mockGetPatientById(any())).thenAnswer((_) async => tPatient);
      bloc.add(const PatientDetailEvent.loaded('p-1'));
      await Future.delayed(const Duration(milliseconds: 50));

      when(() => mockDeletePatient(any())).thenAnswer((_) async {});

      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.deleteRequested());
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states[0], isA<PatientDetailSaving>());
      expect(states[1], isA<PatientDetailDeleted>());
    });

    test('does nothing when not in view or edit mode', () async {
      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.deleteRequested());
      await Future.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(states, isEmpty);
      verifyNever(() => mockDeletePatient(any()));
    });
  });

  group('PatientDetailAppointmentDeleted', () {
    test('deletes appointment and re-emits viewMode', () async {
      final patientAfterDelete = Patient(
        id: 'p-1',
        fullName: 'Test Patient',
        createdAt: now,
        updatedAt: now,
      );
      when(() => mockGetPatientById('p-1'))
          .thenAnswer((_) async => tPatient);
      bloc.add(const PatientDetailEvent.loaded('p-1'));
      await Future.delayed(const Duration(milliseconds: 50));

      when(() => mockDeleteAppointment('appt-1')).thenAnswer((_) async {});
      when(() => mockGetPatientById('p-1'))
          .thenAnswer((_) async => patientAfterDelete);

      final states = <PatientDetailState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PatientDetailEvent.appointmentDeleted('appt-1'));
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(states.single, isA<PatientDetailViewMode>());
      expect(
        (states.single as PatientDetailViewMode).patient.appointments,
        isEmpty,
      );
      verify(() => mockDeleteAppointment('appt-1')).called(1);
    });
  });
}
