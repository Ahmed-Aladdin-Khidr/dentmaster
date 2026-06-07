import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_list_event.freezed.dart';

@freezed
sealed class PatientListEvent with _$PatientListEvent {
  const factory PatientListEvent.started() = PatientListStarted;
  const factory PatientListEvent.searched(String query) = PatientListSearched;
}
