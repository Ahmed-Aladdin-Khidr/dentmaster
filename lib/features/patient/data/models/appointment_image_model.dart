import 'package:drift/drift.dart';
import 'appointment_model.dart';

class AppointmentImages extends Table {
  TextColumn get id => text()();
  TextColumn get appointmentId => text().references(Appointments, #id)();
  TextColumn get filePath => text()();
  TextColumn get fileName => text()();
  IntColumn get fileSizeBytes => integer()();
  BoolColumn get isCompressed => boolean()();
  IntColumn get addedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
