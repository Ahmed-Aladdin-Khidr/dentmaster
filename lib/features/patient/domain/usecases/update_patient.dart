import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class UpdatePatient extends UseCase<void, Patient> {
  final PatientRepository repository;
  UpdatePatient(this.repository);

  @override
  Future<void> call(Patient patient) => repository.updatePatient(patient);
}
