import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/patient.dart';

part 'patient_detail_state.freezed.dart';

@freezed
sealed class PatientDetailState with _$PatientDetailState {
  const factory PatientDetailState.initial() = PatientDetailInitial;
  const factory PatientDetailState.loading() = PatientDetailLoading;
  const factory PatientDetailState.viewMode(Patient patient) = PatientDetailViewMode;
  const factory PatientDetailState.editMode(Patient patient) = PatientDetailEditMode;
  const factory PatientDetailState.createMode() = PatientDetailCreateMode;
  const factory PatientDetailState.saving() = PatientDetailSaving;
  const factory PatientDetailState.deleted() = PatientDetailDeleted;
  const factory PatientDetailState.failure(String message) = PatientDetailFailure;
}
