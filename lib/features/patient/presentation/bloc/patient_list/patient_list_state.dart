import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/patient.dart';

part 'patient_list_state.freezed.dart';

@freezed
sealed class PatientListState with _$PatientListState {
  const factory PatientListState.initial() = PatientListInitial;
  const factory PatientListState.loading() = PatientListLoading;
  const factory PatientListState.success(List<Patient> patients) =
      PatientListSuccess;
  const factory PatientListState.failure(String message) = PatientListFailure;
}
