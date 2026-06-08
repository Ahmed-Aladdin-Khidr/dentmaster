# DentMaster — Flutter Desktop App — Master Plan

**Status:** Pre-development planning  
**Date:** 2026-06-07  
**Target Platform:** Windows Desktop (primary), expandable to mobile/web later  
**Architecture:** Clean Architecture (Domain / Data / Presentation)

---

## Table of Contents

1. [Prerequisites & Environment Setup](#1-prerequisites--environment-setup)
2. [Flutter Project Bootstrap](#2-flutter-project-bootstrap)
3. [Clean Architecture — Folder Structure](#3-clean-architecture--folder-structure)
4. [Package Dependencies](#4-package-dependencies)
5. [Feature Map](#5-feature-map)
6. [Screen-by-Screen Design Spec](#6-screen-by-screen-design-spec)
7. [Data Models](#7-data-models)
8. [Local Storage Strategy](#8-local-storage-strategy)
9. [Image Handling Strategy](#9-image-handling-strategy)
10. [Export / Import Strategy](#10-export--import-strategy)
11. [Implementation Phases](#11-implementation-phases)
12. [Open Decisions / Risks](#12-open-decisions--risks)

---

## 1. Prerequisites & Environment Setup

### 1.1 Visual Studio (REQUIRED — NOT YET INSTALLED)

Flutter Windows desktop builds compile native C++ code through Visual Studio's MSVC toolchain.

**Action:** Install Visual Studio 2022 Community (free)
- URL: https://visualstudio.microsoft.com/downloads/
- **Mandatory workload:** `Desktop development with C++`
  - This workload includes: MSVC compiler, Windows SDK, CMake tools
- Estimated size: ~7–10 GB
- After install run: `flutter doctor` — expect `[√] Visual Studio`

> Without this step, `flutter run -d windows` and `flutter build windows` will fail.

### 1.2 Enable Windows Desktop Target

```bash
flutter config --enable-windows-desktop
flutter doctor    # should show Windows as a valid target
```

### 1.3 Verify Full Toolchain

```bash
flutter devices   # should list "Windows (desktop)"
```

---

## 2. Flutter Project Bootstrap

### 2.1 Create Project

```bash
# Run from d:\Work\Private\
flutter create dentmaster --org com.dentmaster --platforms windows
cd dentmaster
```

> `--org` sets the bundle ID prefix  
> `--platforms windows` skips generating Android/iOS boilerplate (can be added later)

### 2.2 Initial Run Test

```bash
flutter run -d windows
```

Expect the default counter app to open as a native Windows window.

### 2.3 Git Initialisation

```bash
git init
git add .
git commit -m "chore: initial flutter windows project"
```

---

## 3. Clean Architecture — Folder Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp / theme / router
│
├── core/                              # Shared utilities, no business logic
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_dimensions.dart
│   ├── errors/
│   │   ├── failures.dart              # Sealed failure classes
│   │   └── exceptions.dart
│   ├── usecases/
│   │   └── usecase.dart               # Abstract UseCase<Type, Params>
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── image_utils.dart
│   │   └── validators.dart
│   └── widgets/                       # Truly generic, reusable UI atoms
│       ├── confirm_dialog.dart        # Ask-before-action modal (reused everywhere)
│       ├── app_text_field.dart
│       └── loading_overlay.dart
│
├── features/
│   │
│   ├── patient/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── patient.dart
│   │   │   │   └── appointment.dart
│   │   │   ├── repositories/
│   │   │   │   └── patient_repository.dart   # Abstract interface
│   │   │   └── usecases/
│   │   │       ├── get_all_patients.dart
│   │   │       ├── search_patients.dart
│   │   │       ├── get_patient_by_id.dart
│   │   │       ├── create_patient.dart
│   │   │       ├── update_patient.dart
│   │   │       ├── delete_patient.dart
│   │   │       ├── add_appointment.dart
│   │   │       ├── update_appointment.dart
│   │   │       └── delete_appointment.dart
│   │   │
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── patient_model.dart        # Extends Patient entity + JSON
│   │   │   │   └── appointment_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── patient_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── patient_repository_impl.dart
│   │   │
│   │   └── presentation/
│   │       ├── bloc/                          # or Riverpod providers
│   │       │   ├── patient_list/
│   │       │   │   ├── patient_list_bloc.dart
│   │       │   │   ├── patient_list_event.dart
│   │       │   │   └── patient_list_state.dart
│   │       │   └── patient_detail/
│   │       │       ├── patient_detail_bloc.dart
│   │       │       ├── patient_detail_event.dart
│   │       │       └── patient_detail_state.dart
│   │       ├── pages/
│   │       │   ├── patient_search_page.dart   # Main/home screen
│   │       │   └── patient_detail_page.dart   # Detail + add (mode-aware)
│   │       └── widgets/
│   │           ├── patient_card.dart
│   │           ├── appointment_card.dart
│   │           ├── appointment_form.dart
│   │           ├── patient_form.dart
│   │           └── image_picker_widget.dart
│   │
│   └── data_management/
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── data_management_repository.dart
│       │   └── usecases/
│       │       ├── export_data.dart
│       │       └── import_data.dart
│       ├── data/
│       │   ├── datasources/
│       │   │   └── data_management_datasource.dart
│       │   └── repositories/
│       │       └── data_management_repository_impl.dart
│       └── presentation/
│           ├── bloc/
│           │   └── data_management_bloc.dart
│           ├── pages/
│           │   └── data_management_page.dart
│           └── widgets/
│               └── import_export_card.dart
│
└── injection_container.dart           # Dependency injection (get_it)
```

---

## 4. Package Dependencies

### 4.1 Core

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^9.x | State management (BLoC pattern) |
| `bloc_concurrency` | ^0.x | `restartable()` EventTransformer for BLoC debounce (search) |
| `equatable` | ^2.x | Value equality for entities/states |
| `get_it` | ^8.x | Service locator / DI container |
| `injectable` | ^2.x | Code-gen annotations for get_it |
| `go_router` | ^15.x | Declarative routing |

### 4.2 Local Storage

| Package | Version | Purpose |
|---|---|---|
| `drift` | ^2.x | SQLite ORM — stores patients, appointments |
| `drift_flutter` | ^0.x | Drift SQLite FFI for desktop/mobile |
| `path_provider` | ^2.x | App data directory path |
| `path` | ^1.x | Path manipulation |

> **Why Drift over Hive/SharedPrefs?**  
> Patients have relational data (patient → many appointments → many images).  
> Drift gives us typed SQL queries, migrations, and foreign keys — the right tool for structured relational local data.

### 4.3 Image Handling

| Package | Version | Purpose |
|---|---|---|
| `file_picker` | ^8.x | Desktop-native file picker dialog |
| `image` | ^4.x | Pure Dart image decode/resize/compress |
| `flutter_image_compress` | ^2.x | Fast native compression (fallback: `image` pkg) |

> On Windows desktop, `flutter_image_compress` uses a native plugin. `image` pkg is the pure-Dart fallback and is always available.

### 4.4 Export / Import

| Package | Version | Purpose |
|---|---|---|
| `archive` | ^3.x | ZIP creation for export bundle |
| `file_picker` | (same) | Save file / open file dialogs |

### 4.5 Authentication / Security

| Package | Version | Purpose |
|---|---|---|
| `bcrypt` | ^1.x | Hash and verify the app password (never store plaintext) |
| `shared_preferences` | ^2.x | Store the password hash and first-run flag locally |

### 4.6 UI

| Package | Version | Purpose |
|---|---|---|
| `intl` | ^0.x | Date/number formatting |
| `flutter_staggered_animations` | ^1.x | List entry animations |
| `gap` | ^3.x | Spacing widget (replaces SizedBox padding everywhere) |

### 4.7 Dev / Code Generation

| Package | Version | Purpose |
|---|---|---|
| `build_runner` | ^2.x | Code generation runner |
| `drift_dev` | ^2.x | Drift schema + DAO code gen |
| `injectable_generator` | ^2.x | DI boilerplate code gen |
| `freezed` | ^2.x | Immutable data classes + union types |
| `freezed_annotation` | ^2.x | Annotations for freezed |
| `json_serializable` | ^6.x | JSON encode/decode code gen |

---

## 5. Feature Map

```
DentMaster
├── F1 — Patient Search (Home)
│   ├── Search by name (live filter)
│   ├── Search by phone
│   ├── Patient list with quick info card
│   └── FAB → Add New Patient
│
├── F2 — Patient Detail / Edit
│   ├── Personal info section (editable inline)
│   ├── Contact info section (editable inline)
│   ├── Appointment history (grouped by date, desc)
│   │   ├── Add appointment
│   │   ├── Edit appointment (modal/inline)
│   │   └── Delete appointment (confirm dialog)
│   └── Delete patient (confirm dialog)
│
├── F3 — Add New Patient
│   └── Reuses Patient Detail page in "create" mode
│
├── F4 — Appointment Detail / Entry
│   ├── Date + time
│   ├── Chief complaint / notes (rich textarea)
│   ├── Diagnosis / treatment notes
│   ├── Attached images (X-rays, photos)
│   │   ├── Pick image from disk
│   │   ├── Quality comparison dialog
│   │   │   ├── Show original vs compressed side-by-side
│   │   │   ├── Show file sizes
│   │   │   └── Dentist chooses quality
│   │   ├── View full-screen image
│   │   └── Remove image (confirm)
│   └── Save / cancel
│
├── F5 — Data Management
│   ├── Export all data
│   │   ├── Creates ZIP: db file + images folder
│   │   └── Save-as dialog → user picks location
│   └── Import data
│       ├── Open-file dialog → pick ZIP
│       ├── Preview: patient count, appointment count
│       ├── Confirm dialog (will overwrite current data)
│       └── Restore from ZIP
│
└── F6 — App Lock (Password Protection)
    ├── Lock screen on app launch
    │   ├── Password input field
    │   └── Submit → unlock app
    ├── First-run setup
    │   ├── Prompted to set a password on very first launch
    │   └── Password stored as bcrypt hash in local config file
    └── Change password (in Data Management screen)
        ├── Enter current password
        ├── Enter new password + confirm
        └── Save
```

---

## 6. Screen-by-Screen Design Spec

### 6.1 Patient Search Screen (Home)

```
┌──────────────────────────────────────────────────┐
│  DentMaster                         [Data Mgmt]  │
├──────────────────────────────────────────────────┤
│  [ 🔍 Search by name or phone...              ]  │
├──────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────┐    │
│  │ Ahmed Hassan          +20 100 123 4567   │    │
│  │ Last visit: 12 May 2026                  │    │
│  └──────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────┐    │
│  │ Sara Mohamed          +20 112 987 6543   │    │
│  │ Last visit: 03 Jun 2026                  │    │
│  └──────────────────────────────────────────┘    │
│                                                  │
│                                        [  +  ]   │
└──────────────────────────────────────────────────┘
```

- Desktop layout: sidebar nav on left (optional phase 2), content on right
- Search is live (debounced 300ms) — no submit button
- Patient card taps → Patient Detail

### 6.2 Patient Detail Screen

```
┌──────────────────────────────────────────────────┐
│  ← Back          Ahmed Hassan        [Edit] [🗑]  │
├────────────────────┬─────────────────────────────┤
│  PERSONAL INFO     │  APPOINTMENT HISTORY         │
│  Name: Ahmed       │                              │
│  DOB:  1985-03-12  │  ▼ 07 Jun 2026               │
│  Gender: Male      │    Chief complaint: ...      │
│                    │    Diagnosis: ...            │
│  CONTACT INFO      │    [img] [img]               │
│  Phone: +20...     │    [Edit Appt] [Delete]      │
│  Address: ...      │                              │
│                    │  ▼ 15 May 2026               │
│                    │    ...                       │
│                    │                              │
│                    │    [+ Add Appointment]        │
└────────────────────┴─────────────────────────────┘
```

- Left pane: patient info (static → click Edit to make fields editable)
- Right pane: scrollable appointment timeline
- Desktop: two-pane layout; mobile (future): tabs or stacked

### 6.3 Image Quality Comparison Dialog

```
┌──────────────────────────────────────────────────┐
│  Choose Image Quality                      [✕]   │
├──────────────────────────────────────────────────┤
│   ORIGINAL                  COMPRESSED           │
│  ┌───────────┐              ┌───────────┐        │
│  │           │              │           │        │
│  │  <image>  │              │  <image>  │        │
│  │           │              │           │        │
│  └───────────┘              └───────────┘        │
│  4.2 MB                     680 KB               │
│  [Keep Original]            [Use Compressed]     │
└──────────────────────────────────────────────────┘
```

### 6.4 Data Management Screen

```
┌──────────────────────────────────────────────────┐
│  ← Back    Data Management                       │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────────────────────┐                    │
│  │  EXPORT DATA             │                    │
│  │  Save all patients and   │                    │
│  │  appointments to a ZIP.  │                    │
│  │                          │                    │
│  │  Patients: 47            │                    │
│  │  Appointments: 213       │                    │
│  │  Images: 89              │                    │
│  │                          │                    │
│  │  [Export Now]            │                    │
│  └──────────────────────────┘                    │
│                                                  │
│  ┌──────────────────────────┐                    │
│  │  IMPORT DATA             │                    │
│  │  Restore from a ZIP.     │                    │
│  │  ⚠ This will replace all │                    │
│  │  current data.           │                    │
│  │                          │                    │
│  │  [Select ZIP File]       │                    │
│  └──────────────────────────┘                    │
│                                                  │
│  ┌──────────────────────────┐                    │
│  │  CHANGE PASSWORD         │                    │
│  │  Current password: [   ] │                    │
│  │  New password:     [   ] │                    │
│  │  Confirm new:      [   ] │                    │
│  │                          │                    │
│  │  [Update Password]       │                    │
│  └──────────────────────────┘                    │
└──────────────────────────────────────────────────┘
```

### 6.5 Lock Screen (App Launch)

```
┌──────────────────────────────────────────────────┐
│                                                  │
│                  DentMaster                      │
│                                                  │
│            Enter your password                   │
│          ┌────────────────────────┐              │
│          │  ••••••••              │              │
│          └────────────────────────┘              │
│                                                  │
│                  [Unlock]                        │
│                                                  │
└──────────────────────────────────────────────────┘
```

Shown on every app launch before any data is accessible.  
On first-ever launch (no password set): prompt to create a password instead.

---

## 7. Data Models

### 7.1 Patient Entity

```dart
class Patient {
  final String id;           // UUID v4
  final String fullName;
  final String? phone;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;      // 'male' | 'female' | 'other'
  final String? address;
  final String? notes;       // general notes about patient
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Appointment> appointments;
}
```

### 7.2 Appointment Entity

```dart
class Appointment {
  final String id;           // UUID v4
  final String patientId;    // FK
  final DateTime date;
  final String? chiefComplaint;
  final String? diagnosis;
  final String? treatmentNotes;
  final String? nextVisitNotes;
  final List<AppointmentImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 7.3 AppointmentImage Entity

```dart
class AppointmentImage {
  final String id;           // UUID v4
  final String appointmentId; // FK
  final String filePath;     // absolute local path to saved image file
  final String fileName;     // original file name
  final int fileSizeBytes;
  final bool isCompressed;
  final DateTime addedAt;
}
```

### 7.4 Database Schema (Drift)

```
TABLE patients
  id TEXT PK
  full_name TEXT NOT NULL
  phone TEXT
  email TEXT
  date_of_birth INTEGER (ms epoch)
  gender TEXT
  address TEXT
  notes TEXT
  created_at INTEGER
  updated_at INTEGER

TABLE appointments
  id TEXT PK
  patient_id TEXT FK → patients.id (CASCADE DELETE)
  date INTEGER NOT NULL
  chief_complaint TEXT
  diagnosis TEXT
  treatment_notes TEXT
  next_visit_notes TEXT
  created_at INTEGER
  updated_at INTEGER

TABLE appointment_images
  id TEXT PK
  appointment_id TEXT FK → appointments.id (CASCADE DELETE)
  file_path TEXT NOT NULL
  file_name TEXT NOT NULL
  file_size_bytes INTEGER
  is_compressed INTEGER (0/1)
  added_at INTEGER
```

---

## 8. Local Storage Strategy

### Storage Layout on Disk

```
%APPDATA%\DentMaster\                  (Windows: C:\Users\<user>\AppData\Roaming\DentMaster\)
├── dentmaster.db                      # Drift SQLite database
└── images\
    └── <appointment_id>\
        └── <image_id>.jpg             # Saved image files
```

- Images are **copied** into the app's data directory on first pick
- Database stores the absolute path
- On export, both the `.db` file and the `images/` folder are zipped together
- On import, ZIP is extracted, `.db` replaces current, images folder replaces current

### Why Not Store Images as Blobs in DB

- SQLite can store BLOBs but file system is more efficient for large binary data
- Easier to browse/debug during development
- Export/import as ZIP is straightforward

---

## 9. Image Handling Strategy

### Flow

1. Dentist clicks "Add Image" in appointment form
2. `file_picker` opens native Windows file dialog (filter: jpg, jpeg, png, bmp, gif, webp)
3. App reads original image → decodes dimensions and file size
4. App generates a compressed version at 70% quality, max 1920px wide (using `image` package)
5. **Quality Comparison Dialog** shown:
   - Left: original thumbnail + file size
   - Right: compressed thumbnail + file size
   - Two buttons: "Keep Original" / "Use Compressed"
6. Chosen version is copied to `%APPDATA%\DentMaster\images\<appointment_id>\<uuid>.jpg`
7. `AppointmentImage` record created in DB

### Compression Parameters (default, adjustable later)

- Quality: 70%
- Max width: 1920px (maintain aspect ratio)
- Format: JPEG (convert PNGs too, for size savings)

---

## 10. Export / Import Strategy

### Export

1. Show stats (patient count, appointment count, image count)
2. `file_picker` opens save-as dialog (default name: `dentmaster_backup_YYYYMMDD.zip`)
3. ZIP is built using `archive` package:
   - Add `dentmaster.db` as `db/dentmaster.db`
   - Add entire `images/` folder as `images/...`
4. Write ZIP to chosen path
5. Show success toast with file path

### Import

1. `file_picker` opens open-file dialog (filter: `.zip`)
2. Read ZIP, parse and show preview:
   - Scan `db/dentmaster.db` for patient/appointment counts using Drift
   - Show count to user
3. **Confirm Dialog:** "This will replace all current data. Are you sure?"
4. On confirm:
   - Stop database connection
   - Replace `dentmaster.db` with the one from ZIP
   - Replace `images/` folder with the one from ZIP
   - Reconnect database
5. Reload app state

---

## 11. Implementation Phases

### Phase 0 — Environment (Do First)
- [ ] Install Visual Studio 2022 with "Desktop development with C++" workload
- [ ] Run `flutter config --enable-windows-desktop`
- [ ] Verify `flutter doctor` shows Windows OK
- [ ] Run `flutter devices` shows Windows device

### Phase 1 — Project Scaffold
- [ ] `flutter create dentmaster --org com.dentmaster --platforms windows`
- [ ] Add all dependencies to `pubspec.yaml`
- [ ] Create full folder structure (empty files with correct names)
- [ ] Run `flutter pub get`
- [ ] Set up `get_it` injection container skeleton
- [ ] Set up `go_router` with placeholder routes
- [ ] Verify app still runs: `flutter run -d windows`

### Phase 2 — Data Layer
- [ ] Define Drift database schema (`patients`, `appointments`, `appointment_images`)
- [ ] Run drift code generation: `dart run build_runner build`
- [ ] Implement `PatientLocalDatasource` (CRUD operations)
- [ ] Implement `PatientRepositoryImpl`
- [ ] Write unit tests for repository

### Phase 3 — Domain Layer
- [ ] Define all domain entities (`Patient`, `Appointment`, `AppointmentImage`)
- [ ] Implement all use cases (search, CRUD patient, CRUD appointment)
- [ ] Write unit tests for use cases with mock repository

### Phase 4 — Patient Search Screen (F1)
- [ ] `PatientListBloc` (search event + state)
- [ ] `PatientSearchPage` UI
- [ ] `PatientCard` widget
- [ ] Search bar with 300ms debounce
- [ ] Wire up DI and routing
- [ ] Manual test: add dummy data via DB browser, verify search

### Phase 5 — Patient Detail / Edit Screen (F2)
- [ ] `PatientDetailBloc`
- [ ] Two-pane desktop layout
- [ ] Patient info section (view + inline edit)
- [ ] Appointment timeline (grouped by date)
- [ ] `ConfirmDialog` for deletes
- [ ] Manual test

### Phase 6 — Appointment Form (F4)
- [ ] `AppointmentForm` widget (modal sheet or inline panel)
- [ ] Image picker integration
- [ ] Image copy to app data directory
- [ ] Image compression with `image` package
- [ ] Quality comparison dialog
- [ ] Manual test: add appointment with images

### Phase 7 — Add New Patient (F3)
- [ ] Reuse `PatientDetailPage` in create mode
- [ ] FAB on search screen routes to create mode
- [ ] Validate required fields
- [ ] Manual test

### Phase 8 — Data Management (F5)
- [ ] Export: ZIP creation, file save dialog
- [ ] Import: ZIP read, preview dialog, confirm, restore
- [ ] Change password UI in Data Management screen
- [ ] Manual test: export → delete a patient → import → verify patient back

### Phase 9 — App Lock / Password Protection (F6)
- [ ] First-run password setup screen
- [ ] Lock screen shown on every app launch
- [ ] `bcrypt` hash + verify password using `bcrypt` package
- [ ] Store hash and first-run flag in `shared_preferences`
- [ ] `AuthBloc` (setup, unlock, change password events + states)
- [ ] Route guard: redirect to lock screen if not authenticated
- [ ] Change password flow wired into Data Management screen
- [ ] Manual test: set password → restart app → verify lock → wrong password → correct password

### Phase 10 — Polish & UX
- [ ] App icon (Windows `.ico`)
- [ ] Window title and minimum size
- [ ] Keyboard navigation (Tab order, Enter to save)
- [ ] Unsaved-changes guard on all forms (discard changes dialog)
- [ ] Empty states (no patients, no appointments)
- [ ] Error states (DB failure, file access error)
- [ ] Consistent typography and color theme
- [ ] Loading indicators for DB operations

### Phase 11 — Build & Distribution
- [ ] `flutter build windows --release`
- [ ] Output: `build\windows\x64\runner\Release\dentmaster.exe`
- [ ] Test on a clean machine (no Flutter dev tools)
- [ ] Optional: package with Inno Setup or MSIX installer

### Phase 12 — DB Encryption (post-v1)
- [ ] Evaluate `sqlcipher_flutter_libs` for Windows desktop compatibility
- [ ] Derive encryption key from app password (PBKDF2 or argon2)
- [ ] Migrate existing unencrypted DB to encrypted on upgrade
- [ ] Update export/import to handle encrypted DB correctly
- [ ] Update AGENTS.md and PLAN.md when this phase is started
Security Note: Never include plain secrets on codebase repo, use env.

---

## 12. Open Decisions / Risks

| # | Topic | Decision / Notes |
|---|---|---|
| 1 | State management | **BLoC** chosen. Alternatives considered: Riverpod (simpler but less strict separation), Provider (too simple for this scale). BLoC fits clean architecture naturally. |
| 2 | ORM | **Drift** chosen over Isar (less mature desktop support) or ObjectBox (paid for some features). |
| 3 | Image compression on Windows | `flutter_image_compress` requires native plugin — test on Windows. Fallback: `image` package (pure Dart, always works). |
| 4 | App window management | Use `window_manager` package (Phase 9) to set minimum window size and title bar. |
| 5 | Multi-window | **Permanently out of scope.** Single window, no MDI. Decision is final — not revisited in future phases. |
| 6 | Authentication | **Simple app-level password protection in v1.** On launch, prompt for a password before showing any data. No user accounts — single password for the whole app. Store as a bcrypt hash in a local config file (never plaintext). Add a "Change Password" option in Data Management screen. |
| 7 | Cloud sync | **Permanently out of scope.** Export/import ZIP covers portability. |
| 8 | Undo/redo | **No undo/redo.** Instead: unsaved-changes guard on every form — if the user navigates away or closes a form with unsaved edits, show a "Discard changes?" confirm dialog. Confirm dialogs cover destructive deletes. |
| 9 | Image format support | Accept: jpg, jpeg, png, bmp, gif, webp. **Re-encoding rule:** if source is already JPEG and dentist chooses "Keep Original", copy the file as-is (no re-encode, no quality loss). Only re-encode when dentist chooses "Use Compressed", or when source is a non-JPEG format (PNG, BMP, etc.). |
| 10 | DB encryption | **Planned for a later phase (post-v1).** App-level SQLite encryption using `sqlcipher_flutter_libs` or equivalent. The password from decision #6 will be used as (or used to derive) the encryption key, so both features are implemented together. Flag this as a Phase 11 task when scoping. |

---

## Quick Reference: Commands

```bash
# Create project
flutter create dentmaster --org com.dentmaster --platforms windows

# Get packages
flutter pub get

# Run code generation (Drift + Injectable + Freezed)
dart run build_runner build --delete-conflicting-outputs

# Run on Windows
flutter run -d windows

# Build release
flutter build windows --release

# Run tests
flutter test
```

---

*This plan is the source of truth. Update it as decisions are made or scope changes.*  
*For step-by-step execution instructions, exact commands, and verification gates see [`EXECUTION_PLAN.md`](EXECUTION_PLAN.md).*
