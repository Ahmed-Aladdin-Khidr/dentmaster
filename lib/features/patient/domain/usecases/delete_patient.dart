import '../../../../core/usecases/usecase.dart';
import '../repositories/patient_repository.dart';

class DeletePatient extends UseCase<void, String> {
  final PatientRepository repository;
  DeletePatient(this.repository);

  @override
  Future<void> call(String id) => repository.deletePatient(id);
}
