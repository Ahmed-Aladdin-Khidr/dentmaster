import 'package:get_it/get_it.dart';
import 'core/database/app_database.dart';
import 'features/data_management/data/datasources/data_management_datasource.dart';
import 'features/data_management/data/repositories/data_management_repository_impl.dart';
import 'features/data_management/domain/repositories/data_management_repository.dart';
import 'features/data_management/domain/usecases/export_data.dart';
import 'features/data_management/domain/usecases/get_data_stats.dart';
import 'features/data_management/domain/usecases/import_data.dart';
import 'features/data_management/domain/usecases/preview_import.dart';
import 'features/data_management/presentation/bloc/data_management_bloc.dart';
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
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/change_password.dart';
import 'features/auth/domain/usecases/is_password_set.dart';
import 'features/auth/domain/usecases/setup_password.dart';
import 'features/auth/domain/usecases/verify_password.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/patient/presentation/bloc/patient_list/patient_list_bloc.dart';
import 'features/patient/presentation/bloc/patient_detail/patient_detail_bloc.dart';

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

  // BLoCs
  sl.registerFactory(() => PatientListBloc(
        getAllPatients: sl(),
        searchPatients: sl(),
      ));

  sl.registerFactory(() => PatientDetailBloc(
        getPatientById: sl(),
        createPatient: sl(),
        updatePatient: sl(),
        deletePatient: sl(),
        addAppointment: sl(),
        updateAppointment: sl(),
        deleteAppointment: sl(),
        addAppointmentImage: sl(),
        deleteAppointmentImage: sl(),
      ));

  // Data management datasource + repository
  sl.registerLazySingleton<DataManagementDatasource>(
    () => DataManagementDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<DataManagementRepository>(
    () => DataManagementRepositoryImpl(sl()),
  );

  // Use cases — data management
  sl.registerLazySingleton(() => GetDataStats(sl()));
  sl.registerLazySingleton(() => ExportData(sl()));
  sl.registerLazySingleton(() => PreviewImport(sl()));
  sl.registerLazySingleton(() => ImportData(sl()));

  // BLoC — data management
  sl.registerFactory(() => DataManagementBloc(
        getDataStats: sl(),
        exportData: sl(),
        previewImport: sl(),
        importData: sl(),
      ));

  // Auth — Phase 9
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => IsPasswordSet(sl()));
  sl.registerLazySingleton(() => SetupPassword(sl()));
  sl.registerLazySingleton(() => VerifyPassword(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerSingleton<AuthBloc>(AuthBloc(
    isPasswordSet: sl(),
    setupPassword: sl(),
    verifyPassword: sl(),
    changePassword: sl(),
  ));
}
