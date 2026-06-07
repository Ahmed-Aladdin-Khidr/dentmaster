import '../../../../core/usecases/usecase.dart';
import '../repositories/patient_repository.dart';

class DeleteAppointmentImage extends UseCase<void, String> {
  final PatientRepository repository;
  DeleteAppointmentImage(this.repository);

  @override
  Future<void> call(String id) => repository.deleteAppointmentImage(id);
}
