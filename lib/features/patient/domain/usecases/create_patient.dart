import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class CreatePatient extends UseCase<void, Patient> {
  final PatientRepository repository;
  CreatePatient(this.repository);

  @override
  Future<void> call(Patient patient) => repository.createPatient(patient);
}
