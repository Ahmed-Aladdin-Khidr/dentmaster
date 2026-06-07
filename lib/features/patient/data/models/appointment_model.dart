import 'package:drift/drift.dart';
import 'patient_model.dart';

class Appointments extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  IntColumn get date => integer()();
  TextColumn get chiefComplaint => text().nullable()();
  TextColumn get diagnosis => text().nullable()();
  TextColumn get treatmentNotes => text().nullable()();
  TextColumn get nextVisitNotes => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
