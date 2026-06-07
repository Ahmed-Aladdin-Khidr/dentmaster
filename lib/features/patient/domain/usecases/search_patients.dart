import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class SearchPatients extends UseCase<List<Patient>, String> {
  final PatientRepository repository;
  SearchPatients(this.repository);

  @override
  Future<List<Patient>> call(String query) => repository.searchPatients(query);
}
