import 'package:get_it/get_it.dart';
import 'core/database/app_database.dart';
import 'features/patient/data/datasources/patient_local_datasource.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database
  sl.registerSingleton<AppDatabase>(AppDatabase());

  // Datasources
  sl.registerLazySingleton<PatientLocalDatasource>(
    () => PatientLocalDatasourceImpl(sl()),
  );

  // Repositories — Phase 3
  // Use cases — Phase 3
  // BLoCs — Phase 4+
  // Auth — Phase 9
}
