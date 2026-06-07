import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class GetPatientById extends UseCase<Patient?, String> {
  final PatientRepository repository;
  GetPatientById(this.repository);

  @override
  Future<Patient?> call(String id) => repository.getPatientById(id);
}
