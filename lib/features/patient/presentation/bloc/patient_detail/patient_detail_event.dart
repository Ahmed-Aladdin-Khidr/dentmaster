import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/patient.dart';

part 'patient_detail_event.freezed.dart';

@freezed
sealed class PatientDetailEvent with _$PatientDetailEvent {
  const factory PatientDetailEvent.loaded(String patientId) = PatientDetailLoaded;
  const factory PatientDetailEvent.editStarted() = PatientDetailEditStarted;
  const factory PatientDetailEvent.editCancelled() = PatientDetailEditCancelled;
  const factory PatientDetailEvent.saved(Patient updated) = PatientDetailSaved;
  const factory PatientDetailEvent.deleteRequested() = PatientDetailDeleteRequested;
  const factory PatientDetailEvent.appointmentDeleted(String appointmentId) =
      PatientDetailAppointmentDeleted;
}
