import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetAllPatients extends UseCase<List<Patient>, NoParams> {
  final PatientRepository repository;
  GetAllPatients(this.repository);

  @override
  Future<List<Patient>> call(NoParams params) => repository.getAllPatients();
}
