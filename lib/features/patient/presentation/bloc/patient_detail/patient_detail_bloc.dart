// ignore_for_file: prefer_initializing_formals
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../../core/utils/image_utils.dart';
import '../../../domain/entities/appointment_image.dart';
import '../../../domain/usecases/add_appointment.dart';
import '../../../domain/usecases/add_appointment_image.dart';
import '../../../domain/usecases/delete_appointment.dart';
import '../../../domain/usecases/delete_appointment_image.dart';
import '../../../domain/usecases/delete_patient.dart';
import '../../../domain/usecases/get_patient_by_id.dart';
import '../../../domain/usecases/update_appointment.dart';
import '../../../domain/usecases/update_patient.dart';
import 'patient_detail_event.dart';
import 'patient_detail_state.dart';

class PatientDetailBloc extends Bloc<PatientDetailEvent, PatientDetailState> {
  final GetPatientById _getPatientById;
  final UpdatePatient _updatePatient;
  final DeletePatient _deletePatient;
  final AddAppointment _addAppointment;
  final UpdateAppointment _updateAppointment;
  final DeleteAppointment _deleteAppointment;
  final AddAppointmentImage _addAppointmentImage;
  final DeleteAppointmentImage _deleteAppointmentImage;

  PatientDetailBloc({
    required GetPatientById getPatientById,
    required UpdatePatient updatePatient,
    required DeletePatient deletePatient,
    required AddAppointment addAppointment,
    required UpdateAppointment updateAppointment,
    required DeleteAppointment deleteAppointment,
    required AddAppointmentImage addAppointmentImage,
    required DeleteAppointmentImage deleteAppointmentImage,
  })  : _getPatientById = getPatientById,
        _updatePatient = updatePatient,
        _deletePatient = deletePatient,
        _addAppointment = addAppointment,
        _updateAppointment = updateAppointment,
        _deleteAppointment = deleteAppointment,
        _addAppointmentImage = addAppointmentImage,
        _deleteAppointmentImage = deleteAppointmentImage,
        super(const PatientDetailState.initial()) {
    on<PatientDetailLoaded>(_onLoaded);
    on<PatientDetailEditStarted>(_onEditStarted);
    on<PatientDetailEditCancelled>(_onEditCancelled);
    on<PatientDetailSaved>(_onSaved);
    on<PatientDetailDeleteRequested>(_onDeleted);
    on<PatientDetailAppointmentDeleted>(_onAppointmentDeleted);
    on<PatientDetailAppointmentAdded>(_onAppointmentAdded);
    on<PatientDetailAppointmentUpdated>(_onAppointmentUpdated);
    on<PatientDetailImageDeleted>(_onImageDeleted);
  }

  // ── Patient handlers ────────────────────────────────────────────────────

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
      PatientDetailDeleteRequested event,
      Emitter<PatientDetailState> emit) async {
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

  // ── Appointment handlers ─────────────────────────────────────────────────

  Future<void> _onAppointmentDeleted(PatientDetailAppointmentDeleted event,
      Emitter<PatientDetailState> emit) async {
    final patientId = _currentPatientId();
    if (patientId == null) return;
    try {
      await _deleteAppointment(event.appointmentId);
      // Clean up image files for this appointment
      try {
        final appDir = await getApplicationSupportDirectory();
        final imageDir =
            Directory(p.join(appDir.path, 'images', event.appointmentId));
        if (await imageDir.exists()) await imageDir.delete(recursive: true);
      } catch (_) {}
      final refreshed = await _getPatientById(patientId);
      if (refreshed == null) return;
      emit(PatientDetailState.viewMode(refreshed));
    } catch (e) {
      emit(PatientDetailState.failure(e.toString()));
    }
  }

  Future<void> _onAppointmentAdded(PatientDetailAppointmentAdded event,
      Emitter<PatientDetailState> emit) async {
    final patientId = _currentPatientId();
    if (patientId == null) return;
    emit(const PatientDetailState.saving());
    try {
      await _addAppointment(event.appointment);
      for (final pending in event.pendingImages) {
        final imageId = generateLocalId();
        final filePath = await saveImageToAppDirectory(
          appointmentId: event.appointment.id,
          imageId: imageId,
          bytes: pending.bytes,
        );
        await _addAppointmentImage(AppointmentImage(
          id: imageId,
          appointmentId: event.appointment.id,
          filePath: filePath,
          fileName: pending.fileName,
          fileSizeBytes: pending.bytes.length,
          isCompressed: pending.isCompressed,
          addedAt: DateTime.now(),
        ));
      }
      final refreshed = await _getPatientById(patientId);
      if (refreshed == null) {
        emit(const PatientDetailState.failure('Patient not found after save.'));
        return;
      }
      emit(PatientDetailState.viewMode(refreshed));
    } catch (e) {
      emit(PatientDetailState.failure(e.toString()));
    }
  }

  Future<void> _onAppointmentUpdated(PatientDetailAppointmentUpdated event,
      Emitter<PatientDetailState> emit) async {
    final patientId = _currentPatientId();
    if (patientId == null) return;
    emit(const PatientDetailState.saving());
    try {
      await _updateAppointment(event.appointment);
      // Delete removed images from DB and disk
      for (var i = 0; i < event.removedImageIds.length; i++) {
        await _deleteAppointmentImage(event.removedImageIds[i]);
        try {
          await File(event.removedImagePaths[i]).delete();
        } catch (_) {}
      }
      // Persist new images
      for (final pending in event.newImages) {
        final imageId = generateLocalId();
        final filePath = await saveImageToAppDirectory(
          appointmentId: event.appointment.id,
          imageId: imageId,
          bytes: pending.bytes,
        );
        await _addAppointmentImage(AppointmentImage(
          id: imageId,
          appointmentId: event.appointment.id,
          filePath: filePath,
          fileName: pending.fileName,
          fileSizeBytes: pending.bytes.length,
          isCompressed: pending.isCompressed,
          addedAt: DateTime.now(),
        ));
      }
      final refreshed = await _getPatientById(patientId);
      if (refreshed == null) {
        emit(const PatientDetailState.failure('Patient not found after save.'));
        return;
      }
      emit(PatientDetailState.viewMode(refreshed));
    } catch (e) {
      emit(PatientDetailState.failure(e.toString()));
    }
  }

  // ── Image handler ────────────────────────────────────────────────────────

  Future<void> _onImageDeleted(
      PatientDetailImageDeleted event, Emitter<PatientDetailState> emit) async {
    final patientId = _currentPatientId();
    if (patientId == null) return;
    try {
      await _deleteAppointmentImage(event.imageId);
      try {
        await File(event.imagePath).delete();
      } catch (_) {}
      final refreshed = await _getPatientById(patientId);
      if (refreshed == null) return;
      emit(PatientDetailState.viewMode(refreshed));
    } catch (e) {
      emit(PatientDetailState.failure(e.toString()));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String? _currentPatientId() => switch (state) {
        PatientDetailViewMode(:final patient) => patient.id,
        PatientDetailEditMode(:final patient) => patient.id,
        _ => null,
      };
}
