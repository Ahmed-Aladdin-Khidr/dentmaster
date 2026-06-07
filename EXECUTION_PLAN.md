# DentMaster — Execution Plan

> This file is the **how-to** for every phase in `PLAN.md`.  
> Each phase has exact commands, exact files to create, exact content shapes, and a verification gate before moving on.  
> Complete phases in order. Do not start a phase until the previous one passes its verification gate.

---

## Table of Contents

- [Phase 0 — Environment Setup](#phase-0--environment-setup)
- [Phase 1 — Project Scaffold](#phase-1--project-scaffold)
- [Phase 2 — Data Layer](#phase-2--data-layer)
- [Phase 3 — Domain Layer](#phase-3--domain-layer)
- [Phase 4 — Patient Search Screen](#phase-4--patient-search-screen)
- [Phase 5 — Patient Detail Screen](#phase-5--patient-detail-screen)
- [Phase 6 — Appointment Form & Images](#phase-6--appointment-form--images)
- [Phase 7 — Add New Patient](#phase-7--add-new-patient)
- [Phase 8 — Data Management](#phase-8--data-management)
- [Phase 9 — App Lock / Password Protection](#phase-9--app-lock--password-protection)
- [Phase 10 — Polish & UX](#phase-10--polish--ux)
- [Phase 11 — Build & Distribution](#phase-11--build--distribution)
- [Phase 12 — DB Encryption (post-v1)](#phase-12--db-encryption-post-v1)

---

## Phase 0 — Environment Setup

**Goal:** Windows desktop Flutter target is fully working on this machine.  
**Branch:** no branch — run directly, this is machine setup not code.

### Step 0.1 — Install Visual Studio 2022

1. Download Visual Studio 2022 Community from https://visualstudio.microsoft.com/downloads/
2. Run the installer
3. On the workload selection screen, check **"Desktop development with C++"**
   - This pulls in: MSVC v143 compiler, Windows 11 SDK, CMake tools, C++ ATL
   - No other workloads needed
4. Click Install (~7–10 GB, ~20–40 min depending on connection)
5. Restart machine after install completes

### Step 0.2 — Enable Windows Desktop Target

```bash
flutter config --enable-windows-desktop
```

### Step 0.3 — Verify Toolchain

```bash
flutter doctor -v
```

Expected output (relevant lines):
```
[√] Flutter (Channel stable, 3.44.0 ...)
[√] Windows Version (10 Pro ...)
[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.x.x)
[√] Connected device (... Windows (desktop) ...)
```

```bash
flutter devices
```

Must list: `Windows (desktop) • windows • windows-x64 • Microsoft Windows ...`

### Verification Gate ✓

- `flutter doctor` shows `[√] Visual Studio`
- `flutter devices` lists a Windows device
- **Do not proceed to Phase 1 until both pass.**

---

## Phase 1 — Project Scaffold

**Goal:** Running Flutter Windows app with full folder structure, all packages installed, DI and router wired as empty skeletons.  
**Branch:** `chore/project-scaffold`

```bash
git checkout main && git checkout -b chore/project-scaffold
```

### Step 1.1 — Create Flutter Project

Run from `d:\Work\Private\` (one level above DentMaster):

```bash
cd d:\Work\Private
flutter create dentmaster --org com.dentmaster --platforms windows
```

> The project is created in `d:\Work\Private\dentmaster\`.  
> Copy/move planning files (`PLAN.md`, `AGENTS.md`, `EXECUTION_PLAN.md`, `.gitignore`) into the new project root, then continue from inside it.

```bash
cd dentmaster
```

### Step 1.2 — Configure pubspec.yaml

Replace the `dependencies` and `dev_dependencies` sections with:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Core
  flutter_bloc: ^9.0.0
  equatable: ^2.0.5
  get_it: ^8.0.0
  injectable: ^2.5.0
  go_router: ^15.0.0

  # Local Storage
  drift: ^2.20.0
  drift_flutter: ^0.2.0
  path_provider: ^2.1.0
  path: ^1.9.0

  # Image Handling
  file_picker: ^8.0.0
  image: ^4.2.0

  # Export / Import
  archive: ^3.6.0

  # Authentication
  bcrypt: ^1.1.3
  shared_preferences: ^2.3.0

  # UI
  intl: ^0.19.0
  gap: ^3.0.1
  flutter_staggered_animations: ^1.1.1

  # Annotations (runtime)
  freezed_annotation: ^2.4.1
  injectable_annotation: ^2.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.0
  drift_dev: ^2.20.0
  injectable_generator: ^2.6.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  mocktail: ^1.0.4
```

```bash
flutter pub get
```

Expect: no errors. All packages resolve.

### Step 1.3 — Create Folder Structure

Create every folder and placeholder file listed below. Files start empty — just `// TODO` is fine.

```
lib/
  main.dart                          ← replace default content (Step 1.6)
  app.dart                           ← new file
  injection_container.dart           ← new file
  app_router.dart                    ← new file

  core/
    constants/
      app_colors.dart
      app_strings.dart
      app_dimensions.dart
    errors/
      failures.dart
      exceptions.dart
    usecases/
      usecase.dart
    utils/
      date_formatter.dart
      image_utils.dart
      validators.dart
    widgets/
      confirm_dialog.dart
      app_text_field.dart
      loading_overlay.dart

  features/
    patient/
      domain/
        entities/
          patient.dart
          appointment.dart
          appointment_image.dart
        repositories/
          patient_repository.dart
        usecases/
          get_all_patients.dart
          search_patients.dart
          get_patient_by_id.dart
          create_patient.dart
          update_patient.dart
          delete_patient.dart
          add_appointment.dart
          update_appointment.dart
          delete_appointment.dart
          add_appointment_image.dart
          delete_appointment_image.dart
      data/
        models/
          patient_model.dart
          appointment_model.dart
          appointment_image_model.dart
        datasources/
          patient_local_datasource.dart
        repositories/
          patient_repository_impl.dart
      presentation/
        bloc/
          patient_list/
            patient_list_bloc.dart
            patient_list_event.dart
            patient_list_state.dart
          patient_detail/
            patient_detail_bloc.dart
            patient_detail_event.dart
            patient_detail_state.dart
        pages/
          patient_search_page.dart
          patient_detail_page.dart
        widgets/
          patient_card.dart
          appointment_card.dart
          appointment_form.dart
          patient_form.dart
          image_picker_widget.dart
          image_quality_dialog.dart

    data_management/
      domain/
        repositories/
          data_management_repository.dart
        usecases/
          export_data.dart
          import_data.dart
          get_data_stats.dart
      data/
        datasources/
          data_management_datasource.dart
        repositories/
          data_management_repository_impl.dart
      presentation/
        bloc/
          data_management_bloc.dart
          data_management_event.dart
          data_management_state.dart
        pages/
          data_management_page.dart
        widgets/
          export_card.dart
          import_card.dart
          change_password_card.dart

    auth/
      domain/
        repositories/
          auth_repository.dart
        usecases/
          setup_password.dart
          verify_password.dart
          change_password.dart
          is_password_set.dart
      data/
        datasources/
          auth_local_datasource.dart
        repositories/
          auth_repository_impl.dart
      presentation/
        bloc/
          auth_bloc.dart
          auth_event.dart
          auth_state.dart
        pages/
          lock_screen_page.dart
          setup_password_page.dart
        widgets/
          password_field.dart
```

### Step 1.4 — Write Core Skeletons

**`lib/core/errors/failures.dart`**
```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
```

**`lib/core/usecases/usecase.dart`**
```dart
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {
  const NoParams();
}
```

### Step 1.5 — Write Injection Container Skeleton

**`lib/injection_container.dart`**
```dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Phase 2: register database
  // Phase 2: register datasources
  // Phase 2: register repositories
  // Phase 3: register use cases
  // Phase 4+: register BLoCs
  // Phase 9: register auth
}
```

### Step 1.6 — Write Router Skeleton

**`lib/app_router.dart`**
```dart
import 'package:go_router/go_router.dart';
import 'features/patient/presentation/pages/patient_search_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PatientSearchPage(),
    ),
    // Phase 4: patient search
    // Phase 5: patient detail
    // Phase 8: data management
    // Phase 9: lock screen
  ],
);
```

### Step 1.7 — Write app.dart and main.dart

**`lib/app.dart`**
```dart
import 'package:flutter/material.dart';
import 'app_router.dart';

class DentMasterApp extends StatelessWidget {
  const DentMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DentMaster',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
    );
  }
}
```

**`lib/main.dart`**
```dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const DentMasterApp());
}
```

Add a stub `PatientSearchPage` in its file so the app compiles:
```dart
import 'package:flutter/material.dart';

class PatientSearchPage extends StatelessWidget {
  const PatientSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('DentMaster — Phase 1 scaffold')),
    );
  }
}
```

### Step 1.8 — Run and Verify

```bash
flutter analyze          # must be zero errors
flutter run -d windows   # must open a Windows window showing the stub text
```

### Step 1.9 — Commit and Merge

```bash
flutter analyze
git add .
git commit -m "chore: project scaffold with full folder structure and package deps"
git checkout main
git merge --no-ff chore/project-scaffold
git tag v0.0.1 -m "chore: scaffold complete"
git push origin main --tags
```

### Verification Gate ✓

- `flutter analyze` zero issues
- App opens in a native Windows window
- All folders in Step 1.3 exist
- `flutter pub get` succeeds with no version conflicts

---

## Phase 2 — Data Layer

**Goal:** Drift database defined, code generated, datasource implemented, repository implementation complete, unit-tested.  
**Branch:** `feat/data-layer`

```bash
git checkout main && git checkout -b feat/data-layer
```

### Step 2.1 — Define Drift Database

**`lib/features/patient/data/models/patient_model.dart`**

```dart
import 'package:drift/drift.dart';

class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  IntColumn get dateOfBirth => integer().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**`lib/features/patient/data/models/appointment_model.dart`**

```dart
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
```

**`lib/features/patient/data/models/appointment_image_model.dart`**

```dart
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
```

### Step 2.2 — Create the Drift Database Class

Create `lib/core/database/app_database.dart`:

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../features/patient/data/models/patient_model.dart';
import '../../features/patient/data/models/appointment_model.dart';
import '../../features/patient/data/models/appointment_image_model.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Patients, Appointments, AppointmentImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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
```

> `driftDatabase(name: 'dentmaster')` resolves to `%APPDATA%\dentmaster\dentmaster.sqlite` on Windows via `drift_flutter`.

### Step 2.3 — Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `app_database.g.dart` is generated inside `lib/core/database/`.  
No errors in the output.

### Step 2.4 — Implement PatientLocalDatasource

**`lib/features/patient/data/datasources/patient_local_datasource.dart`**

```dart
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

abstract class PatientLocalDatasource {
  Future<List<PatientData>> getAllPatients();
  Future<List<PatientData>> searchPatients(String query);
  Future<PatientData?> getPatientById(String id);
  Future<void> insertPatient(PatientsCompanion patient);
  Future<void> updatePatient(PatientsCompanion patient);
  Future<void> deletePatient(String id);
  Future<List<AppointmentData>> getAppointmentsForPatient(String patientId);
  Future<void> insertAppointment(AppointmentsCompanion appointment);
  Future<void> updateAppointment(AppointmentsCompanion appointment);
  Future<void> deleteAppointment(String id);
  Future<List<AppointmentImageData>> getImagesForAppointment(String appointmentId);
  Future<void> insertAppointmentImage(AppointmentImagesCompanion image);
  Future<void> deleteAppointmentImage(String id);
}

class PatientLocalDatasourceImpl implements PatientLocalDatasource {
  final AppDatabase _db;
  PatientLocalDatasourceImpl(this._db);

  @override
  Future<List<PatientData>> getAllPatients() =>
      (_db.select(_db.patients)
            ..orderBy([(p) => OrderingTerm.asc(p.fullName)]))
          .get();

  @override
  Future<List<PatientData>> searchPatients(String query) {
    final q = '%${query.toLowerCase()}%';
    return (_db.select(_db.patients)
          ..where((p) =>
              p.fullName.lower().like(q) | p.phone.lower().like(q)))
        .get();
  }

  @override
  Future<PatientData?> getPatientById(String id) =>
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
  Future<List<AppointmentData>> getAppointmentsForPatient(String patientId) =>
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
  Future<List<AppointmentImageData>> getImagesForAppointment(
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
      (_db.delete(_db.appointmentImages)..where((i) => i.id.equals(id))).go();
}
```

### Step 2.5 — Register Database in DI

Update `lib/injection_container.dart`:

```dart
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
}
```

### Step 2.6 — Write Unit Tests

Create `test/features/patient/data/patient_local_datasource_test.dart`:

- Use an **in-memory** Drift database for tests
- Test: insert patient → getAllPatients returns it
- Test: searchPatients by name substring
- Test: searchPatients by phone substring
- Test: deletePatient cascades to appointments and images
- Test: getAppointmentsForPatient returns desc order by date

### Step 2.7 — Verify

```bash
flutter analyze
flutter test
```

### Step 2.8 — Commit and Merge

```bash
git add .
git commit -m "feat(db): define drift schema, implement patient datasource, register in DI"
git checkout main && git merge --no-ff feat/data-layer
git tag v0.1.0-data -m "feat: data layer complete"
git push origin main --tags
```

### Verification Gate ✓

- `app_database.g.dart` exists and is non-empty
- `flutter analyze` zero issues
- All datasource unit tests pass
- App still launches: `flutter run -d windows`

### Deviations from Plan (recorded 2026-06-07)

**Drift-generated data class names** — The plan's Step 2.4 used `PatientData`, `AppointmentData`, `AppointmentImageData` as the generated type names. Drift actually generates `Patient`, `Appointment`, `AppointmentImage` (no `Data` suffix). `PatientsCompanion`, `AppointmentsCompanion`, `AppointmentImagesCompanion` are correct as written.

**Impact on Phase 3:** The domain entities defined in Phase 3 use the same names (`Patient`, `Appointment`, `AppointmentImage`). Any file that imports both `app_database.dart` and a domain entity must use an import alias to avoid collision:
```dart
import '../../../../core/database/app_database.dart' as db;
// Then use db.Patient, db.Appointment, db.AppointmentImage for Drift rows.
```
`PatientRepositoryImpl` and any mapper code must follow this pattern.

**`AppDatabase.forTesting` constructor** — Added a named constructor `AppDatabase.forTesting(super.e)` to support in-memory Drift databases in unit tests. Not in original plan but required for Step 2.6.

---

## Phase 3 — Domain Layer

**Goal:** All domain entities defined, all use cases implemented and unit-tested against a mock repository.  
**Branch:** `feat/domain-layer`

```bash
git checkout main && git checkout -b feat/domain-layer
```

### Step 3.1 — Define Domain Entities

**`lib/features/patient/domain/entities/patient.dart`**
```dart
import 'package:equatable/equatable.dart';
import 'appointment.dart';

class Patient extends Equatable {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Appointment> appointments;

  const Patient({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.appointments = const [],
  });

  @override
  List<Object?> get props => [id, fullName, phone, email, dateOfBirth,
      gender, address, notes, createdAt, updatedAt, appointments];
}
```

**`lib/features/patient/domain/entities/appointment.dart`**
```dart
import 'package:equatable/equatable.dart';
import 'appointment_image.dart';

class Appointment extends Equatable {
  final String id;
  final String patientId;
  final DateTime date;
  final String? chiefComplaint;
  final String? diagnosis;
  final String? treatmentNotes;
  final String? nextVisitNotes;
  final List<AppointmentImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.date,
    this.chiefComplaint,
    this.diagnosis,
    this.treatmentNotes,
    this.nextVisitNotes,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, patientId, date, chiefComplaint,
      diagnosis, treatmentNotes, nextVisitNotes, images, createdAt, updatedAt];
}
```

**`lib/features/patient/domain/entities/appointment_image.dart`**
```dart
import 'package:equatable/equatable.dart';

class AppointmentImage extends Equatable {
  final String id;
  final String appointmentId;
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final bool isCompressed;
  final DateTime addedAt;

  const AppointmentImage({
    required this.id,
    required this.appointmentId,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.isCompressed,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [id, appointmentId, filePath, fileName,
      fileSizeBytes, isCompressed, addedAt];
}
```

### Step 3.2 — Define Repository Interface

**`lib/features/patient/domain/repositories/patient_repository.dart`**
```dart
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
```

### Step 3.3 — Implement Use Cases

Each use case follows the same pattern. One class, one `call()`.

**`lib/features/patient/domain/usecases/search_patients.dart`**
```dart
import '../../../../core/usecases/usecase.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class SearchPatients extends UseCase<List<Patient>, String> {
  final PatientRepository repository;
  SearchPatients(this.repository);

  @override
  Future<List<Patient>> call(String query) =>
      repository.searchPatients(query);
}
```

Implement all remaining use cases following this pattern:
- `GetAllPatients` — params: `NoParams`
- `GetPatientById` — params: `String id`
- `CreatePatient` — params: `Patient`
- `UpdatePatient` — params: `Patient`
- `DeletePatient` — params: `String id`
- `AddAppointment` — params: `Appointment`
- `UpdateAppointment` — params: `Appointment`
- `DeleteAppointment` — params: `String id`
- `AddAppointmentImage` — params: `AppointmentImage`
- `DeleteAppointmentImage` — params: `String id`

### Step 3.4 — Implement PatientRepositoryImpl

Add `toEntity()` factory constructors to each model class (converts `PatientData` → `Patient`, etc.) and `toCompanion()` methods (converts entity → Drift companion for writes).

**`lib/features/patient/data/repositories/patient_repository_impl.dart`**
```dart
import '../../domain/entities/patient.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_image.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_local_datasource.dart';
// import model mappers

class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDatasource datasource;
  PatientRepositoryImpl(this.datasource);

  @override
  Future<List<Patient>> getAllPatients() async {
    final rows = await datasource.getAllPatients();
    return Future.wait(rows.map(_enrichPatient));
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    final rows = await datasource.searchPatients(query);
    return Future.wait(rows.map(_enrichPatient));
  }

  // _enrichPatient: fetches appointments + images for a PatientData row
  // and converts to Patient entity.
  // implement all other methods similarly ...
}
```

### Step 3.5 — Register Repository and Use Cases in DI

```dart
// In injection_container.dart, add:

// Repository
sl.registerLazySingleton<PatientRepository>(
  () => PatientRepositoryImpl(sl()),
);

// Use cases
sl.registerLazySingleton(() => GetAllPatients(sl()));
sl.registerLazySingleton(() => SearchPatients(sl()));
sl.registerLazySingleton(() => GetPatientById(sl()));
sl.registerLazySingleton(() => CreatePatient(sl()));
sl.registerLazySingleton(() => UpdatePatient(sl()));
sl.registerLazySingleton(() => DeletePatient(sl()));
sl.registerLazySingleton(() => AddAppointment(sl()));
sl.registerLazySingleton(() => UpdateAppointment(sl()));
sl.registerLazySingleton(() => DeleteAppointment(sl()));
sl.registerLazySingleton(() => AddAppointmentImage(sl()));
sl.registerLazySingleton(() => DeleteAppointmentImage(sl()));
```

### Step 3.6 — Write Unit Tests for Use Cases

Create `test/features/patient/domain/usecases/`:
- Use `mocktail` to mock `PatientRepository`
- One test file per use case
- Test: happy path (returns expected entity)
- Test: empty list when no patients match

### Verification Gate ✓

- `flutter analyze` zero issues
- `flutter test` all pass
- Entities have no Flutter imports
- Entities have no Drift imports

---

## Phase 4 — Patient Search Screen

**Goal:** Working home screen with live patient search, patient cards, and FAB.  
**Branch:** `feat/patient-search`

```bash
git checkout main && git checkout -b feat/patient-search
```

### Step 4.1 — Write PatientListBloc

**Events:**
```dart
sealed class PatientListEvent {
  const factory PatientListEvent.started() = PatientListStarted;
  const factory PatientListEvent.searched(String query) = PatientListSearched;
}
```

**States:**
```dart
sealed class PatientListState {
  const factory PatientListState.initial() = PatientListInitial;
  const factory PatientListState.loading() = PatientListLoading;
  const factory PatientListState.success(List<Patient> patients) = PatientListSuccess;
  const factory PatientListState.failure(String message) = PatientListFailure;
}
```

**Bloc logic:**
- `PatientListStarted` → emit loading → call `GetAllPatients` → emit success/failure
- `PatientListSearched(query)`:
  - if query is empty → call `GetAllPatients`
  - if query is non-empty → call `SearchPatients(query)`
  - Debounce: use `EventTransformer` with `debounceTime(Duration(milliseconds: 300))`

### Step 4.2 — Register PatientListBloc in DI

```dart
sl.registerFactory(() => PatientListBloc(
  getAllPatients: sl(),
  searchPatients: sl(),
));
```

### Step 4.3 — Build PatientSearchPage

```dart
// Structure:
// Scaffold
//   appBar: AppBar with title "DentMaster" + action button → DataManagementPage
//   body: Column
//     SearchBar (AppTextField) — onChange triggers PatientListSearched
//     Expanded → BlocBuilder<PatientListBloc, PatientListState>
//       loading → CircularProgressIndicator centered
//       success(patients) → ListView.builder → PatientCard
//       failure → error message + retry button
//       initial → empty (PatientListStarted fired in initState)
//   floatingActionButton → navigate to PatientDetailPage(mode: create)
```

### Step 4.4 — Build PatientCard Widget

```dart
// ListTile or Card:
//   title: patient.fullName
//   subtitle: patient.phone ?? 'No phone'
//   trailing: last appointment date (or 'No visits yet')
//   onTap: context.push('/patient/${patient.id}')
```

### Step 4.5 — Add Routes

```dart
// In app_router.dart:
GoRoute(path: '/', builder: (_, __) => const PatientSearchPage()),
GoRoute(path: '/patient/:id', builder: (_, state) =>
  PatientDetailPage(patientId: state.pathParameters['id']!)),
GoRoute(path: '/patient/new', builder: (_, __) =>
  const PatientDetailPage(patientId: null)),
GoRoute(path: '/data-management', builder: (_, __) =>
  const DataManagementPage()),
```

### Step 4.6 — Seed Test Data

Use a temporary button or DB Browser for SQLite to add 2–3 patients directly to the DB.  
Verify search filters them correctly.

#### Deviation (recorded 2026-06-07) — no DB Browser available on this machine

DB Browser for SQLite is not installed. Seed data is injected programmatically via `lib/core/utils/dev_seeder.dart`:
- `seedTestDataIfEmpty()` is called from `main()` before `runApp()`
- Guarded by `kDebugMode` (Flutter constant) — no-ops in release builds
- Checks `GetAllPatients` first; only seeds when the DB is completely empty
- Seeds 4 realistic dental patients: Ahmed Hassan (3 appointments), Sara Mohamed (2 appointments), Omar Khalil (2 appointments), Nour Ibrahim (0 appointments — tests empty-appointments state)
- Uses fixed string IDs (`seed-p001` … `seed-p004`, `seed-a001` … `seed-a007`) to ensure idempotency if somehow called twice
- Calls `CreatePatient` and `AddAppointment` use cases through the DI container — no direct DB access

### Verification Gate ✓

- App shows list of patients on launch
- Typing in search bar filters in real time (debounced)
- Empty state shows when no results
- FAB navigates to patient detail (stub page is fine at this phase)

---

## Phase 5 — Patient Detail Screen

**Goal:** Full patient detail screen with two-pane layout, inline edit, appointment timeline, and all confirm-guarded deletes.  
**Branch:** `feat/patient-detail`

```bash
git checkout main && git checkout -b feat/patient-detail
```

### Step 5.1 — Write PatientDetailBloc

**Events:**
```
PatientDetailLoaded(patientId)
PatientDetailEditStarted
PatientDetailSaved(Patient updated)
PatientDetailDeleted
```

**States:**
```
PatientDetailInitial
PatientDetailLoading
PatientDetailViewMode(Patient patient)
PatientDetailEditMode(Patient patient)
PatientDetailSaving
PatientDetailDeleted          ← triggers navigation back
PatientDetailFailure(String message)
```

**Bloc logic:**
- `PatientDetailLoaded` → fetch patient by id with all appointments → emit `ViewMode`
- `PatientDetailEditStarted` → emit `EditMode` (same data, form becomes editable)
- `PatientDetailSaved` → validate → call `UpdatePatient` → re-fetch → emit `ViewMode`
- `PatientDetailDeleted` → confirm in UI first → call `DeletePatient` → emit `Deleted`

### Step 5.2 — Build PatientDetailPage (two-pane layout)

```
Row(
  Expanded(flex: 2) → PatientInfoPanel (left)
  VerticalDivider
  Expanded(flex: 3) → AppointmentTimelinePanel (right)
)
```

**PatientInfoPanel:**
- View mode: display all fields with labels
- Edit mode: `AppTextField` for each field
- `[Edit]` button toggles to edit mode
- In edit mode: `[Save]` and `[Cancel]` buttons
- `[Save]` checks for changes — if none, just go back to view mode
- Navigate away while in edit mode → unsaved-changes `ConfirmDialog`

**AppointmentTimelinePanel:**
- `ListView` of appointments grouped by date (descending)
- Each group header: formatted date
- Each item: `AppointmentCard`
- Bottom: `[+ Add Appointment]` button

### Step 5.3 — Build AppointmentCard Widget

```
Card:
  date + time header
  chiefComplaint text (truncated)
  diagnosis text (truncated)
  image thumbnails row (if any)
  [Edit] and [Delete] icon buttons
  Delete → ConfirmDialog("Delete this appointment?") → DeleteAppointment use case
```

### Step 5.4 — Build ConfirmDialog (core/widgets)

```dart
// Static method: ConfirmDialog.show(context, title, message)
// Returns Future<bool>
// Uses AlertDialog with [Cancel] and [Confirm] buttons
// [Confirm] is styled as a destructive (red) action
```

### Step 5.5 — Unsaved-Changes Guard

Wrap `PatientDetailPage` with a `PopScope`:
```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, _) async {
    if (didPop) return;
    if (bloc.state is PatientDetailEditMode) {
      final discard = await ConfirmDialog.show(
        context, 'Discard changes?', 'Your unsaved changes will be lost.');
      if (discard) context.pop();
    } else {
      context.pop();
    }
  },
)
```

### Verification Gate ✓

- Patient info displays correctly
- Edit mode activates and deactivates cleanly
- Save updates the patient in DB and refreshes view
- Delete patient shows confirm dialog, deletes, navigates back
- Delete appointment shows confirm dialog, removes from timeline
- Navigating away while editing shows discard dialog

---

## Phase 6 — Appointment Form & Images

**Goal:** Full appointment add/edit form with image picking, compression comparison dialog, and image management.  
**Branch:** `feat/appointment-form`

```bash
git checkout main && git checkout -b feat/appointment-form
```

### Step 6.1 — Build AppointmentForm Widget

A `showModalBottomSheet` or side panel with:
- Date picker (shows `DatePicker` dialog)
- `AppTextField` for: chief complaint, diagnosis, treatment notes, next visit notes
- Image section: grid of thumbnails + `[+ Add Image]` button
- `[Save]` / `[Cancel]` buttons
- Uses its own form key for validation

### Step 6.2 — Image Picking Flow

**`lib/features/patient/presentation/widgets/image_picker_widget.dart`**

```
1. User taps [+ Add Image]
2. file_picker opens:
   FilePicker.platform.pickFiles(
     type: FileType.custom,
     allowedExtensions: ['jpg','jpeg','png','bmp','gif','webp'],
   )
3. If user cancels → do nothing
4. Read picked file bytes
5. Detect if source is JPEG: check file extension
6. Generate compressed version:
   - Decode with image package
   - Resize to max 1920px width (maintain aspect ratio)
   - Encode as JPEG at quality 70
7. Show ImageQualityDialog
```

### Step 6.3 — Build ImageQualityDialog

```dart
// Dialog with two columns:
// Left: original image thumbnail + file size formatted
// Right: compressed image thumbnail + file size formatted
// Buttons: [Keep Original] | [Use Compressed]
// Special case: if source is JPEG → [Keep Original] copies file as-is (no re-encode)
// Returns: chosen Uint8List bytes + isCompressed flag
```

### Step 6.4 — Image Save Logic

In `core/utils/image_utils.dart`:
```dart
Future<String> saveImageToAppDirectory({
  required String appointmentId,
  required String imageId,
  required Uint8List bytes,
}) async {
  final appDir = await getApplicationSupportDirectory();
  final imageDir = Directory(
    path.join(appDir.path, 'images', appointmentId));
  await imageDir.create(recursive: true);
  final filePath = path.join(imageDir.path, '$imageId.jpg');
  await File(filePath).writeAsBytes(bytes);
  return filePath;
}
```

### Step 6.5 — Wire AddAppointmentImage Use Case

After image is saved to disk:
```dart
await addAppointmentImage(AppointmentImage(
  id: uuid,
  appointmentId: appointment.id,
  filePath: savedPath,
  fileName: originalFileName,
  fileSizeBytes: bytes.length,
  isCompressed: isCompressed,
  addedAt: DateTime.now(),
));
```

### Step 6.6 — Image Display in AppointmentCard

Show thumbnails as a horizontal row using `Image.file(File(image.filePath))`.  
Tapping a thumbnail → full-screen image viewer (simple `Dialog` with `InteractiveViewer`).  
Delete image → `ConfirmDialog` → `DeleteAppointmentImage` use case → also delete file from disk.

### Verification Gate ✓

- Add appointment with no images — saves and appears in timeline
- Add appointment with images — quality dialog appears, chosen version is saved
- Images display as thumbnails in appointment card
- Tap thumbnail → full-screen view
- Delete image → confirm → removed from card and disk
- Edit appointment — pre-populates all fields

---

## Phase 7 — Add New Patient

**Goal:** FAB on search screen creates a new patient using the same `PatientDetailPage`.  
**Branch:** `feat/add-patient`

```bash
git checkout main && git checkout -b feat/add-patient
```

### Step 7.1 — Make PatientDetailPage Mode-Aware

`PatientDetailPage` accepts `String? patientId`.  
- `patientId == null` → **create mode**
- `patientId != null` → **view/edit mode**

In create mode:
- Left pane: all fields are immediately editable (no separate Edit toggle)
- Right pane: appointment timeline is hidden (no appointments yet)
- App bar title: "New Patient"
- Bottom: single `[Create Patient]` button
- On save: call `CreatePatient` use case → navigate to `/patient/<new_id>` (replace)

### Step 7.2 — Validation

Required field: `fullName` — must not be empty.  
Optional: all other fields.  
Show inline error under the field if validation fails.

### Step 7.3 — Bloc Update

Add to `PatientDetailBloc`:
- `PatientDetailCreated(Patient newPatient)` event
- Handle: validate → call `CreatePatient` → emit `PatientDetailViewMode` with new patient

### Verification Gate ✓

- FAB on search screen opens blank new patient form
- Saving without a name shows validation error
- Saving with a name creates patient, navigates to detail view
- New patient appears in search list

---

## Phase 8 — Data Management

**Goal:** Export to ZIP, import from ZIP with preview and confirm, change password UI.  
**Branch:** `feat/data-management`

```bash
git checkout main && git checkout -b feat/data-management
```

### Step 8.1 — Domain Layer for Data Management

**`lib/features/data_management/domain/repositories/data_management_repository.dart`**
```dart
abstract class DataManagementRepository {
  Future<DataStats> getStats();
  Future<void> exportData(String destinationZipPath);
  Future<DataStats> previewImport(String zipPath);
  Future<void> importData(String zipPath);
}

class DataStats {
  final int patientCount;
  final int appointmentCount;
  final int imageCount;
  const DataStats({required this.patientCount,
    required this.appointmentCount, required this.imageCount});
}
```

### Step 8.2 — Implement Export

```dart
Future<void> exportData(String destinationZipPath) async {
  final appDir = await getApplicationSupportDirectory();
  final dbFile = File(path.join(appDir.path, 'dentmaster.sqlite'));
  final imagesDir = Directory(path.join(appDir.path, 'images'));

  final archive = Archive();

  // Add DB
  archive.addFile(ArchiveFile(
    'db/dentmaster.sqlite',
    await dbFile.readAsBytes()));

  // Add all image files recursively
  if (await imagesDir.exists()) {
    await for (final entity in imagesDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = path.relative(entity.path, from: appDir.path);
        archive.addFile(ArchiveFile(
          relativePath.replaceAll(r'\', '/'),
          await entity.readAsBytes()));
      }
    }
  }

  final zipBytes = ZipEncoder().encode(archive)!;
  await File(destinationZipPath).writeAsBytes(zipBytes);
}
```

### Step 8.3 — Implement Import

```dart
Future<void> importData(String zipPath) async {
  final appDir = await getApplicationSupportDirectory();
  final bytes = await File(zipPath).readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  // Close DB connection first
  await sl<AppDatabase>().close();

  // Extract
  for (final file in archive) {
    final filePath = path.join(appDir.path, file.name.replaceAll('/', path.separator));
    if (file.isFile) {
      await File(filePath).create(recursive: true);
      await File(filePath).writeAsBytes(file.content as List<int>);
    }
  }

  // Reopen DB
  sl.unregister<AppDatabase>();
  sl.registerSingleton<AppDatabase>(AppDatabase());
}
```

### Step 8.4 — Build DataManagementPage

Three cards stacked vertically (see wireframe in PLAN.md section 6.4):
1. **Export card** — shows stats (patient/appointment/image counts) + `[Export Now]` button
2. **Import card** — `[Select ZIP File]` → preview dialog → confirm → import
3. **Change Password card** — Phase 9 wires this; Phase 8 builds the UI only

**Import preview dialog:**
```
Importing will replace:
  47 patients → 12 patients
  213 appointments → 8 appointments
  [Cancel] [Confirm Import]
```

### Step 8.5 — Register in DI and Router

```dart
sl.registerLazySingleton<DataManagementRepository>(
  () => DataManagementRepositoryImpl(sl()));
sl.registerLazySingleton(() => ExportData(sl()));
sl.registerLazySingleton(() => ImportData(sl()));
sl.registerLazySingleton(() => GetDataStats(sl()));
sl.registerFactory(() => DataManagementBloc(
  exportData: sl(), importData: sl(), getDataStats: sl()));
```

### Verification Gate ✓

- Export creates a valid ZIP with the DB and images folder
- Open the ZIP in Windows Explorer and verify contents
- Import: pick the ZIP, preview shows correct counts, confirm replaces data
- Manual: add a patient → export → delete patient → import → patient is back

---

## Phase 9 — App Lock / Password Protection

**Goal:** Lock screen on every launch, first-run setup, bcrypt hash storage, route guard.  
**Branch:** `feat/app-lock`

```bash
git checkout main && git checkout -b feat/app-lock
```

### Step 9.1 — Auth Domain Layer

**`lib/features/auth/domain/repositories/auth_repository.dart`**
```dart
abstract class AuthRepository {
  Future<bool> isPasswordSet();
  Future<void> setupPassword(String password);
  Future<bool> verifyPassword(String password);
  Future<void> changePassword(String currentPassword, String newPassword);
}
```

**Use cases:** `IsPasswordSet`, `SetupPassword`, `VerifyPassword`, `ChangePassword`

### Step 9.2 — Auth Data Layer

**`lib/features/auth/data/datasources/auth_local_datasource.dart`**
```dart
// Uses shared_preferences:
//   key 'password_hash' → stores bcrypt hash string
//   key 'is_password_set' → bool flag

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  Future<void> savePasswordHash(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password_hash', hash);
    await prefs.setBool('is_password_set', true);
  }

  Future<String?> getPasswordHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password_hash');
  }

  Future<bool> isPasswordSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_password_set') ?? false;
  }
}
```

**`lib/features/auth/data/repositories/auth_repository_impl.dart`**
```dart
// setupPassword: BCrypt.hashpw(password, BCrypt.gensalt()) → save hash
// verifyPassword: BCrypt.checkpw(password, storedHash)
// changePassword: verify current → hash new → save
```

### Step 9.3 — AuthBloc

**Events:** `AuthCheckRequested`, `AuthPasswordSubmitted(password)`, `AuthSetupSubmitted(password)`, `AuthChangePasswordSubmitted(current, newPw)`

**States:** `AuthInitial`, `AuthLoading`, `AuthSetupRequired`, `AuthLocked`, `AuthAuthenticated`, `AuthFailure(message)`

**Logic:**
- `AuthCheckRequested` → `isPasswordSet()` → if not set emit `SetupRequired`, else emit `Locked`
- `AuthPasswordSubmitted` → `verifyPassword()` → success emit `Authenticated`, fail emit `Failure`
- `AuthSetupSubmitted` → `setupPassword()` → emit `Authenticated`

### Step 9.4 — Build Lock Screen and Setup Screen

**LockScreenPage:** centered password field + [Unlock] button.  
Wrong password: shake animation on the field + red error text.  
Enter key submits the form.

**SetupPasswordPage:** two fields (password + confirm) + [Create Password] button.  
Validate: both fields match, min 4 characters.

### Step 9.5 — Route Guard

Wrap the root `GoRouter` with a redirect:

```dart
GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authBloc = sl<AuthBloc>();
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final isOnAuthRoute = state.matchedLocation == '/lock' ||
                          state.matchedLocation == '/setup';
    if (!isAuthenticated && !isOnAuthRoute) return '/lock';
    return null;
  },
  routes: [
    GoRoute(path: '/lock', builder: (_, __) => const LockScreenPage()),
    GoRoute(path: '/setup', builder: (_, __) => const SetupPasswordPage()),
    // ... all existing routes
  ],
)
```

`AuthBloc` must be registered as a **Singleton** (not factory) so the router redirect reads the same instance that the lock screen writes to.

### Step 9.6 — Wire Change Password into Data Management

`ChangePasswordCard` already built in Phase 8.  
Wire it: on submit → dispatch `AuthChangePasswordSubmitted` to `AuthBloc`.  
On success → show "Password updated" snackbar.  
On failure (wrong current password) → show error under the current-password field.

### Verification Gate ✓

- Cold launch → lock screen appears
- Wrong password → error shown, no access
- Correct password → navigates to patient search
- First-ever launch → setup screen, not lock screen
- Change password → old password no longer works, new one does
- Restart app after change password → new password unlocks correctly

---

## Phase 10 — Polish & UX

**Goal:** App is visually consistent, handles edge cases, and feels complete.  
**Branch:** `chore/polish`

```bash
git checkout main && git checkout -b chore/polish
```

### Step 10.1 — App Icon

1. Create a 256×256 PNG icon (tooth / cross symbol / DM monogram)
2. Convert to `.ico` with multiple sizes: 16, 32, 48, 64, 128, 256
3. Replace `windows\runner\resources\app_icon.ico`
4. Update `windows\runner\Runner.rc` if needed

### Step 10.2 — Window Size

Add `window_manager` package to `pubspec.yaml`.

In `main.dart`:
```dart
await windowManager.ensureInitialized();
windowManager.waitUntilReadyToShow(
  const WindowOptions(
    minimumSize: Size(1024, 700),
    title: 'DentMaster',
  ),
  () async => await windowManager.show(),
);
```

### Step 10.3 — Unsaved-Changes Guard Audit

Confirm `PopScope` is present on:
- `PatientDetailPage` (edit mode)
- `AppointmentForm` (any changes)

### Step 10.4 — Empty States

- **No patients:** illustration + "No patients yet. Add your first patient →" with arrow pointing to FAB
- **No appointments:** "No appointments recorded yet. Tap + Add Appointment to begin."
- **Search no results:** "No patients found for '[query]'."

### Step 10.5 — Error States

- DB failure on load → show error card with retry button
- File system error on image save → snackbar "Could not save image. Check available disk space."
- Import ZIP corrupt → dialog "This file does not appear to be a valid DentMaster backup."

### Step 10.6 — Keyboard Navigation

- All interactive elements reachable via Tab
- Enter key submits focused form
- Escape key cancels dialogs and edit mode
- Ctrl+F focuses the search bar on patient search screen

### Step 10.7 — Loading Indicators

- `LoadingOverlay` widget (semi-transparent overlay + `CircularProgressIndicator`) shown during:
  - DB save operations
  - Image compression
  - Export ZIP creation
  - Import ZIP extraction

### Step 10.8 — Typography and Theme Audit

Review every screen for:
- Consistent heading sizes (use `Theme.of(context).textTheme`)
- Consistent spacing (use `gap` package, no magic numbers)
- Color usage only from `AppColors` constants
- No hardcoded `Colors.blue`, `Colors.red` etc. except in `AppColors`

### Verification Gate ✓

- App opens with correct title bar and minimum size
- All empty states display correctly
- All error states are reachable via manual testing
- Tab navigation works across all forms
- App icon shows in taskbar and title bar

---

## Phase 11 — Build & Distribution

**Goal:** A release `.exe` that runs on a clean Windows machine.  
**Branch:** `chore/release-build`

```bash
git checkout main && git checkout -b chore/release-build
```

### Step 11.1 — Release Build

```bash
flutter build windows --release
```

Output: `build\windows\x64\runner\Release\dentmaster.exe`

### Step 11.2 — Verify Release Build

```bash
# Run the release exe directly (no flutter run)
.\build\windows\x64\runner\Release\dentmaster.exe
```

- App must launch without Flutter installed
- All features must work (DB, file picker, images)

### Step 11.3 — Test on Clean Machine

Copy the entire `Release\` folder to a machine without Flutter/VS installed.  
Run `dentmaster.exe`.  
Verify:
- App launches
- Can add a patient
- Can add an appointment with an image
- Export creates a valid ZIP
- Lock screen works

### Step 11.4 — Optional MSIX Packaging

```bash
# Add msix package to pubspec.yaml dev_dependencies
# Configure in pubspec.yaml:
msix_config:
  display_name: DentMaster
  publisher_display_name: DentMaster
  identity_name: com.dentmaster.app
  msix_version: 1.0.0.0

dart run msix:create
```

Output: `build\windows\x64\runner\Release\dentmaster.msix`  
Install by double-clicking the `.msix` file.

### Step 11.5 — Tag Release

```bash
git add .
git commit -m "chore: release build v1.0.0"
git checkout main && git merge --no-ff chore/release-build
git tag v1.0.0 -m "release: v1.0.0 — full patient history app with auth"
git push origin main --tags
```

### Verification Gate ✓

- Release `.exe` runs on a machine without Flutter
- No console window opens behind the app
- All Phase 1–10 features work in release mode

---

## Phase 12 — DB Encryption (post-v1)

**Goal:** SQLite database encrypted at rest using the app password as the key.  
**Branch:** `feat/db-encryption` — start this branch from `main` after v1.0.0 is tagged.

> Do not start this phase until v1.0.0 is released and stable.  
> Update this section with findings when the phase begins.

### Planned Steps

1. Evaluate `sqlcipher_flutter_libs` Windows desktop compatibility
   - Check: does it compile on Windows with MSVC?
   - Check: does it work with Drift's `LazyDatabase`?
2. Choose key derivation: PBKDF2 with the app password + a stored salt
   - Salt stored in `shared_preferences` (non-sensitive — it's public by design)
   - Derived key passed to SQLCipher as the database passphrase
3. Migration path for existing users:
   - Detect if DB is unencrypted on launch (version flag in `shared_preferences`)
   - If unencrypted: encrypt in place using SQLCipher's `sqlcipher_export()` pragma
   - Set version flag to encrypted
4. Update export/import:
   - Export must decrypt → write plain ZIP (so backup is portable)
   - Or: export the encrypted DB and document that the password is needed to restore
5. Update `AGENTS.md` and this file with final implementation notes

---

*Keep this file up to date. When a phase is complete, mark its tasks in `PLAN.md` and note any deviations here.*
