import 'package:get_it/get_it.dart';
import 'core/database/app_database.dart';
import 'features/patient/data/datasources/patient_local_datasource.dart';
import 'features/patient/data/repositories/patient_repository_impl.dart';
import 'features/patient/domain/repositories/patient_repository.dart';
import 'features/patient/domain/usecases/add_appointment.dart';
import 'features/patient/domain/usecases/add_appointment_image.dart';
import 'features/patient/domain/usecases/create_patient.dart';
import 'features/patient/domain/usecases/delete_appointment.dart';
import 'features/patient/domain/usecases/delete_appointment_image.dart';
import 'features/patient/domain/usecases/delete_patient.dart';
import 'features/patient/domain/usecases/get_all_patients.dart';
import 'features/patient/domain/usecases/get_patient_by_id.dart';
import 'features/patient/domain/usecases/search_patients.dart';
import 'features/patient/domain/usecases/update_appointment.dart';
import 'features/patient/domain/usecases/update_patient.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database
  sl.registerSingleton<AppDatabase>(AppDatabase());

  // Datasources
  sl.registerLazySingleton<PatientLocalDatasource>(
    () => PatientLocalDatasourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(sl()),
  );

  // Use cases — patient
  sl.registerLazySingleton(() => GetAllPatients(sl()));
  sl.registerLazySingleton(() => SearchPatients(sl()));
  sl.registerLazySingleton(() => GetPatientById(sl()));
  sl.registerLazySingleton(() => CreatePatient(sl()));
  sl.registerLazySingleton(() => UpdatePatient(sl()));
  sl.registerLazySingleton(() => DeletePatient(sl()));

  // Use cases — appointment
  sl.registerLazySingleton(() => AddAppointment(sl()));
  sl.registerLazySingleton(() => UpdateAppointment(sl()));
  sl.registerLazySingleton(() => DeleteAppointment(sl()));

  // Use cases — appointment image
  sl.registerLazySingleton(() => AddAppointmentImage(sl()));
  sl.registerLazySingleton(() => DeleteAppointmentImage(sl()));

  // BLoCs — Phase 4+
  // Auth — Phase 9
}
