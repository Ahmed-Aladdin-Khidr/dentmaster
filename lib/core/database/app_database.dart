import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../features/patient/data/models/patient_model.dart';
import '../../features/patient/data/models/appointment_model.dart';
import '../../features/patient/data/models/appointment_image_model.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Patients, Appointments, AppointmentImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'dentmaster');
  }
}
