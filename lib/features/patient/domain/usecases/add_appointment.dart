import '../../../../core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/patient_repository.dart';

class AddAppointment extends UseCase<void, Appointment> {
  final PatientRepository repository;
  AddAppointment(this.repository);

  @override
  Future<void> call(Appointment appointment) =>
      repository.addAppointment(appointment);
}
