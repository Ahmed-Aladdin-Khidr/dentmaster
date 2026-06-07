import '../../../../core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/patient_repository.dart';

class UpdateAppointment extends UseCase<void, Appointment> {
  final PatientRepository repository;
  UpdateAppointment(this.repository);

  @override
  Future<void> call(Appointment appointment) =>
      repository.updateAppointment(appointment);
}
