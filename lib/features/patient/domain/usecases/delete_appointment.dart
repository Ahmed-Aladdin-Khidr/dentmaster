import '../../../../core/usecases/usecase.dart';
import '../repositories/patient_repository.dart';

class DeleteAppointment extends UseCase<void, String> {
  final PatientRepository repository;
  DeleteAppointment(this.repository);

  @override
  Future<void> call(String id) => repository.deleteAppointment(id);
}
