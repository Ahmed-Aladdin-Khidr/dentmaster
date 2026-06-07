import '../entities/patient.dart';
import '../entities/appointment.dart';
import '../entities/appointment_image.dart';

abstract class PatientRepository {
  Future<List<Patient>> getAllPatients();
  Future<List<Patient>> searchPatients(String query);
  Future<Patient?> getPatientById(String id);
  Future<void> createPatient(Patient patient);
  Future<void> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<void> addAppointment(Appointment appointment);
  Future<void> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<void> addAppointmentImage(AppointmentImage image);
  Future<void> deleteAppointmentImage(String id);
}
