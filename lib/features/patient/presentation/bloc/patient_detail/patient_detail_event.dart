import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/patient.dart';
import '../../models/pending_image.dart';

part 'patient_detail_event.freezed.dart';

@freezed
sealed class PatientDetailEvent with _$PatientDetailEvent {
  const factory PatientDetailEvent.loaded(String patientId) = PatientDetailLoaded;
  const factory PatientDetailEvent.createStarted() = PatientDetailCreateStarted;
  const factory PatientDetailEvent.created(Patient newPatient) = PatientDetailCreated;
  const factory PatientDetailEvent.editStarted() = PatientDetailEditStarted;
  const factory PatientDetailEvent.editCancelled() = PatientDetailEditCancelled;
  const factory PatientDetailEvent.saved(Patient updated) = PatientDetailSaved;
  const factory PatientDetailEvent.deleteRequested() = PatientDetailDeleteRequested;

  // Appointment events
  const factory PatientDetailEvent.appointmentDeleted(String appointmentId) =
      PatientDetailAppointmentDeleted;
  const factory PatientDetailEvent.appointmentAdded(
    Appointment appointment,
    List<PendingImage> pendingImages,
  ) = PatientDetailAppointmentAdded;
  const factory PatientDetailEvent.appointmentUpdated(
    Appointment appointment,
    List<PendingImage> newImages,
    List<String> removedImageIds,
    List<String> removedImagePaths,
  ) = PatientDetailAppointmentUpdated;

  // Image events
  const factory PatientDetailEvent.imageDeleted(
    String imageId,
    String imagePath,
  ) = PatientDetailImageDeleted;
}
