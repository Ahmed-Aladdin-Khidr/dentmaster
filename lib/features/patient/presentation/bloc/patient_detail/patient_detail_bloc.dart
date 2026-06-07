// ignore_for_file: prefer_initializing_formals
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_patient_by_id.dart';
import '../../../domain/usecases/update_patient.dart';
import '../../../domain/usecases/delete_patient.dart';
import '../../../domain/usecases/delete_appointment.dart';
import 'patient_detail_event.dart';
import 'patient_detail_state.dart';

class PatientDetailBloc extends Bloc<PatientDetailEvent, PatientDetailState> {
  final GetPatientById _getPatientById;
  final UpdatePatient _updatePatient;
  final DeletePatient _deletePatient;
  final DeleteAppointment _deleteAppointment;

  PatientDetailBloc({
    required GetPatientById getPatientById,
    required UpdatePatient updatePatient,
    required DeletePatient deletePatient,
    required DeleteAppointment deleteAppointment,
  })  : _getPatientById = getPatientById,
        _updatePatient = updatePatient,
        _deletePatient = deletePatient,
        _deleteAppointment = deleteAppointment,
        super(const PatientDetailState.initial()) {
    on<PatientDetailLoaded>(_onLoaded);
    on<PatientDetailEditStarted>(_onEditStarted);
    on<PatientDetailEditCancelled>(_onEditCancelled);
    on<PatientDetailSaved>(_onSaved);
    on<PatientDetailDeleteRequested>(_onDeleted);
    on<PatientDetailAppointmentDeleted>(_onAppointmentDeleted);
  }

  Future<void> _onLoaded(
      PatientDetailLoaded event, Emitter<PatientDetailState> emit) async {
    emit(const PatientDetailState.loading());
    try {
      final patient = await _getPatientById(event.patientId);
      if (patient == null) {
        emit(const PatientDetailState.failure('Patient not found.'));
        return;
      }
      emit(PatientDetailState.viewMode(patient));
    } catch (e) {
      emit(PatientDetailState.failure(e.toString()));
    }
  }

  void _onEditStarted(
      PatientDetailEditStarted event, Emitter<PatientDetailState> emit) {
    final current = state;
    if (current is PatientDetailViewMode) {
      emit(PatientDetailState.editMode(current.patient));
    }
  }

  void _onEditCancelled(
      PatientDetailEditCancelled event, Emitter<PatientDetailState> emit) {
    final current = state;
    if (current is PatientDetailEditMode) {
      emit(PatientDetailState.viewMode(current.patient));
    }
  }

  Future<void> _onSaved(
      PatientDetailSaved event, Emitter<PatientDetailState> emit) async {
    emit(const PatientDetailState.saving());
    try {
      await _updatePatient(event.updated);
      final refreshed = await _getPatientById(event.updated.id);
      if (refreshed == null) {
        emit(const PatientDetailState.failure('Patient not found after save.'));
        return;
      }
      emit(PatientDetailState.viewMode(refreshed));
    } catch (e) {
      emit(PatientDetailState.failure(e.toString()));
    }
  }

  Future<void> _onDeleted(
      PatientDetailDeleteRequested event, Emitter<PatientDetailState> emit) async {
    final current = state;
    final patientId = switch (current) {
      PatientDetailViewMode(:final patient) => patient.id,
      PatientDetailEditMode(:final patient) => patient.id,
      _ => null,
    };
    if (patientId == null) return;
    emit(const PatientDetailState.saving());
    try {
      await _deletePatient(patientId);
      emit(const PatientDetailState.deleted());
    } catch (e) {
      emit(PatientDetailState.failure(e.toString()));
    }
  }

  Future<void> _onAppointmentDeleted(PatientDetailAppointmentDeleted event,
      Emitter<PatientDetailState> emit) async {
    final current = state;
    final patientId = switch (current) {
      PatientDetailViewMode(:final patient) => patient.id,
      PatientDetailEditMode(:final patient) => patient.id,
      _ => null,
    };
    if (patientId == null) return;
    try {
      await _deleteAppointment(event.appointmentId);
      final refreshed = await _getPatientById(patientId);
      if (refreshed == null) return;
      emit(PatientDetailState.viewMode(refreshed));
    } catch (e) {
      emit(PatientDetailState.failure(e.toString()));
    }
  }
}
