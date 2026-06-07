import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_image.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_local_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDatasource datasource;
  PatientRepositoryImpl(this.datasource);

  // ---------------------------------------------------------------------------
  // Patients
  // ---------------------------------------------------------------------------

  @override
  Future<List<Patient>> getAllPatients() async {
    final rows = await datasource.getAllPatients();
    return Future.wait(rows.map(_toPatientEntity));
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    final rows = await datasource.searchPatients(query);
    return Future.wait(rows.map(_toPatientEntity));
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    final row = await datasource.getPatientById(id);
    if (row == null) return null;
    return _toPatientEntity(row);
  }

  @override
  Future<void> createPatient(Patient patient) =>
      datasource.insertPatient(_toPatientCompanion(patient));

  @override
  Future<void> updatePatient(Patient patient) =>
      datasource.updatePatient(_toPatientCompanion(patient));

  @override
  Future<void> deletePatient(String id) => datasource.deletePatient(id);

  // ---------------------------------------------------------------------------
  // Appointments
  // ---------------------------------------------------------------------------

  @override
  Future<void> addAppointment(Appointment appointment) =>
      datasource.insertAppointment(_toAppointmentCompanion(appointment));

  @override
  Future<void> updateAppointment(Appointment appointment) =>
      datasource.updateAppointment(_toAppointmentCompanion(appointment));

  @override
  Future<void> deleteAppointment(String id) =>
      datasource.deleteAppointment(id);

  // ---------------------------------------------------------------------------
  // Appointment Images
  // ---------------------------------------------------------------------------

  @override
  Future<void> addAppointmentImage(AppointmentImage image) =>
      datasource.insertAppointmentImage(_toImageCompanion(image));

  @override
  Future<void> deleteAppointmentImage(String id) =>
      datasource.deleteAppointmentImage(id);

  // ---------------------------------------------------------------------------
  // Mappers — Drift row → domain entity
  // ---------------------------------------------------------------------------

  Future<Patient> _toPatientEntity(db.Patient row) async {
    final apptRows =
        await datasource.getAppointmentsForPatient(row.id);
    final appointments =
        await Future.wait(apptRows.map(_toAppointmentEntity));
    return Patient(
      id: row.id,
      fullName: row.fullName,
      phone: row.phone,
      email: row.email,
      dateOfBirth: row.dateOfBirth != null
          ? DateTime.fromMillisecondsSinceEpoch(row.dateOfBirth!)
          : null,
      gender: row.gender,
      address: row.address,
      notes: row.notes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
      appointments: appointments,
    );
  }

  Future<Appointment> _toAppointmentEntity(db.Appointment row) async {
    final imageRows =
        await datasource.getImagesForAppointment(row.id);
    final images = imageRows.map(_toImageEntity).toList();
    return Appointment(
      id: row.id,
      patientId: row.patientId,
      date: DateTime.fromMillisecondsSinceEpoch(row.date),
      chiefComplaint: row.chiefComplaint,
      diagnosis: row.diagnosis,
      treatmentNotes: row.treatmentNotes,
      nextVisitNotes: row.nextVisitNotes,
      images: images,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  AppointmentImage _toImageEntity(db.AppointmentImage row) => AppointmentImage(
        id: row.id,
        appointmentId: row.appointmentId,
        filePath: row.filePath,
        fileName: row.fileName,
        fileSizeBytes: row.fileSizeBytes,
        isCompressed: row.isCompressed,
        addedAt: DateTime.fromMillisecondsSinceEpoch(row.addedAt),
      );

  // ---------------------------------------------------------------------------
  // Mappers — domain entity → Drift companion
  // ---------------------------------------------------------------------------

  db.PatientsCompanion _toPatientCompanion(Patient p) =>
      db.PatientsCompanion.insert(
        id: p.id,
        fullName: p.fullName,
        phone: Value(p.phone),
        email: Value(p.email),
        dateOfBirth:
            Value(p.dateOfBirth?.millisecondsSinceEpoch),
        gender: Value(p.gender),
        address: Value(p.address),
        notes: Value(p.notes),
        createdAt: p.createdAt.millisecondsSinceEpoch,
        updatedAt: p.updatedAt.millisecondsSinceEpoch,
      );

  db.AppointmentsCompanion _toAppointmentCompanion(Appointment a) =>
      db.AppointmentsCompanion.insert(
        id: a.id,
        patientId: a.patientId,
        date: a.date.millisecondsSinceEpoch,
        chiefComplaint: Value(a.chiefComplaint),
        diagnosis: Value(a.diagnosis),
        treatmentNotes: Value(a.treatmentNotes),
        nextVisitNotes: Value(a.nextVisitNotes),
        createdAt: a.createdAt.millisecondsSinceEpoch,
        updatedAt: a.updatedAt.millisecondsSinceEpoch,
      );

  db.AppointmentImagesCompanion _toImageCompanion(AppointmentImage i) =>
      db.AppointmentImagesCompanion.insert(
        id: i.id,
        appointmentId: i.appointmentId,
        filePath: i.filePath,
        fileName: i.fileName,
        fileSizeBytes: i.fileSizeBytes,
        isCompressed: i.isCompressed,
        addedAt: i.addedAt.millisecondsSinceEpoch,
      );
}
