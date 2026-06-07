// ignore_for_file: prefer_initializing_formals
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_all_patients.dart';
import '../../../domain/usecases/search_patients.dart';
import 'patient_list_event.dart';
import 'patient_list_state.dart';

class PatientListBloc extends Bloc<PatientListEvent, PatientListState> {
  final GetAllPatients _getAllPatients;
  final SearchPatients _searchPatients;

  PatientListBloc({
    required GetAllPatients getAllPatients,
    required SearchPatients searchPatients,
  })  : _getAllPatients = getAllPatients,
        _searchPatients = searchPatients,
        super(const PatientListState.initial()) {
    on<PatientListStarted>(_onStarted);
    on<PatientListSearched>(_onSearched, transformer: restartable());
  }

  Future<void> _onStarted(
    PatientListStarted event,
    Emitter<PatientListState> emit,
  ) async {
    emit(const PatientListState.loading());
    try {
      final patients = await _getAllPatients(const NoParams());
      emit(PatientListState.success(patients));
    } catch (e) {
      emit(PatientListState.failure(e.toString()));
    }
  }

  Future<void> _onSearched(
    PatientListSearched event,
    Emitter<PatientListState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    emit(const PatientListState.loading());
    try {
      final patients = event.query.isEmpty
          ? await _getAllPatients(const NoParams())
          : await _searchPatients(event.query);
      emit(PatientListState.success(patients));
    } catch (e) {
      emit(PatientListState.failure(e.toString()));
    }
  }
}
