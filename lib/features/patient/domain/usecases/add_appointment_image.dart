import '../../../../core/usecases/usecase.dart';
import '../entities/appointment_image.dart';
import '../repositories/patient_repository.dart';

class AddAppointmentImage extends UseCase<void, AppointmentImage> {
  final PatientRepository repository;
  AddAppointmentImage(this.repository);

  @override
  Future<void> call(AppointmentImage image) =>
      repository.addAppointmentImage(image);
}
