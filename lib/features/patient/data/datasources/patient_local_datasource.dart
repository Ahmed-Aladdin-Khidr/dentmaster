import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

// Drift generates: Patient, Appointment, AppointmentImage (data classes)
// and PatientsCompanion, AppointmentsCompanion, AppointmentImagesCompanion.
// Domain entities (Phase 3) will use an import alias to avoid name collision.

abstract class PatientLocalDatasource {
  Future<List<Patient>> getAllPatients();
  Future<List<Patient>> searchPatients(String query);
  Future<Patient?> getPatientById(String id);
  Future<void> insertPatient(PatientsCompanion patient);
  Future<void> updatePatient(PatientsCompanion patient);
  Future<void> deletePatient(String id);
  Future<List<Appointment>> getAppointmentsForPatient(String patientId);
  Future<void> insertAppointment(AppointmentsCompanion appointment);
  Future<void> updateAppointment(AppointmentsCompanion appointment);
  Future<void> deleteAppointment(String id);
  Future<List<AppointmentImage>> getImagesForAppointment(String appointmentId);
  Future<void> insertAppointmentImage(AppointmentImagesCompanion image);
  Future<void> deleteAppointmentImage(String id);
}

class PatientLocalDatasourceImpl implements PatientLocalDatasource {
  final AppDatabase _db;
  PatientLocalDatasourceImpl(this._db);

  @override
  Future<List<Patient>> getAllPatients() =>
      (_db.select(_db.patients)
            ..orderBy([(p) => OrderingTerm.asc(p.fullName)]))
          .get();

  @override
  Future<List<Patient>> searchPatients(String query) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.patients)
          ..where(
              (p) => p.fullName.lower().like(q) | p.phone.lower().like(q)))
        .get();
  }

  @override
  Future<Patient?> getPatientById(String id) =>
      (_db.select(_db.patients)..where((p) => p.id.equals(id)))
          .getSingleOrNull();

  @override
  Future<void> insertPatient(PatientsCompanion patient) =>
      _db.into(_db.patients).insert(patient);

  @override
  Future<void> updatePatient(PatientsCompanion patient) =>
      (_db.update(_db.patients)
            ..where((p) => p.id.equals(patient.id.value)))
          .write(patient);

  @override
  Future<void> deletePatient(String id) =>
      (_db.delete(_db.patients)..where((p) => p.id.equals(id))).go();

  @override
  Future<List<Appointment>> getAppointmentsForPatient(String patientId) =>
      (_db.select(_db.appointments)
            ..where((a) => a.patientId.equals(patientId))
            ..orderBy([(a) => OrderingTerm.desc(a.date)]))
          .get();

  @override
  Future<void> insertAppointment(AppointmentsCompanion appointment) =>
      _db.into(_db.appointments).insert(appointment);

  @override
  Future<void> updateAppointment(AppointmentsCompanion appointment) =>
      (_db.update(_db.appointments)
            ..where((a) => a.id.equals(appointment.id.value)))
          .write(appointment);

  @override
  Future<void> deleteAppointment(String id) =>
      (_db.delete(_db.appointments)..where((a) => a.id.equals(id))).go();

  @override
  Future<List<AppointmentImage>> getImagesForAppointment(
          String appointmentId) =>
      (_db.select(_db.appointmentImages)
            ..where((i) => i.appointmentId.equals(appointmentId))
            ..orderBy([(i) => OrderingTerm.asc(i.addedAt)]))
          .get();

  @override
  Future<void> insertAppointmentImage(AppointmentImagesCompanion image) =>
      _db.into(_db.appointmentImages).insert(image);

  @override
  Future<void> deleteAppointmentImage(String id) =>
      (_db.delete(_db.appointmentImages)
            ..where((i) => i.id.equals(id)))
          .go();
}
