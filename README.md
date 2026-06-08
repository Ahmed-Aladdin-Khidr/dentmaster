# DentMaster

A local-first Windows desktop application for dental practice management — built with Flutter.

DentMaster stores all patient records, appointment history, and clinical images on the local device with no cloud dependency, no accounts, and no network calls.

---

## Features

- **Patient management** — search by name or phone, create, edit, and delete patient records
- **Appointment history** — per-patient timeline of visits with chief complaint, diagnosis, treatment notes, and follow-up reminders
- **Clinical image attachments** — pick images from disk, compare original vs compressed side-by-side, and store the chosen version locally
- **Full data portability** — export all data (database + images) to a ZIP backup; restore from any previous backup
- **App-level password protection** — bcrypt-hashed password prompt on every launch; change password from the Data Management screen

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI framework | Flutter 3.x (Windows desktop) |
| State management | `flutter_bloc` (BLoC pattern) |
| Local database | Drift (SQLite ORM with code generation) |
| Dependency injection | `get_it` + `injectable` (code-gen) |
| Routing | `go_router` |
| Image handling | `file_picker` + `image` package (pure Dart compression) |
| Export / import | `archive` (ZIP) |
| Authentication | `bcrypt` + `shared_preferences` |

---

## Architecture

Clean Architecture with strict layer separation:

```
Presentation  →  Domain  ←  Data
  (BLoC)        (Entities,    (Drift models,
  (Pages)        UseCases,     Datasources,
  (Widgets)      Repos)        RepoImpls)
```

- **`domain/`** — pure Dart entities, repository interfaces, and use cases. No Flutter, no Drift.
- **`data/`** — Drift tables, datasources, and repository implementations.
- **`presentation/`** — BLoC, pages, and widgets.
- **`core/`** — shared errors, utilities, and generic UI atoms.

Full architecture reference: [`AGENTS.md`](AGENTS.md)  
Phase plan and data models: [`PLAN.md`](PLAN.md)

---

## Prerequisites

### Required

- **Flutter 3.x** with Windows desktop enabled:
  ```powershell
  flutter config --enable-windows-desktop
  flutter doctor
  ```
- **Visual Studio 2022** (Community edition is free) with the **"Desktop development with C++"** workload — required to compile the native Windows runner.

### Known environment constraints (this dev machine)

- HTTPS git operations fail due to a corporate SSL certificate issue. Fix per-repo:
  ```powershell
  git config http.sslVerify false
  ```
- CMake also fails SSL verification on first build. Set before the first `flutter run`:
  ```powershell
  $env:CMAKE_TLS_VERIFY = '0'
  flutter run -d windows
  ```
  Not required on subsequent builds (SQLite source is already cached).

---

## Getting Started

```powershell
# 1. Clone
git clone https://github.com/Ahmed-Aladdin-Khidr/dentmaster.git
cd dentmaster
git config http.sslVerify false   # if on the corporate dev machine

# 2. Install dependencies
flutter pub get

# 3. Run code generation (Drift + Injectable + Freezed)
dart run build_runner build --delete-conflicting-outputs

# 4. Run on Windows
$env:CMAKE_TLS_VERIFY = '0'   # first build only
flutter run -d windows
```

---

## Build (Release)

```powershell
flutter build windows --release
# Output: build\windows\x64\runner\Release\dentmaster.exe
```

---

## Data Storage

All data lives under `%APPDATA%\DentMaster\`:

```
%APPDATA%\DentMaster\
├── dentmaster.db          # SQLite database (patients, appointments, images metadata)
└── images\
    └── <appointment_id>\
        └── <image_id>.jpg
```

No data leaves the machine. Export produces a single ZIP of the above folder; import replaces it.

---

## Development

### Code generation

Run after any change to Drift tables, `@injectable` classes, or `@freezed` models:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

### Tests

```powershell
flutter analyze && flutter test
```

### Branching

| Branch prefix | When to use |
|---|---|
| `feature/<slug>` | New feature or phase |
| `fix/<slug>` | Bug fix |
| `chore/<slug>` | Tooling, deps, config |
| `refactor/<slug>` | Structural change, no new behaviour |

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org).

---

## Implementation Status

| Phase | Description | Status |
|---|---|---|
| 1 | Project scaffold | ✅ Done |
| 2 | Data layer (Drift schema + repositories) | ✅ Done |
| 3 | Domain layer (entities + use cases) | ✅ Done |
| 4 | Patient search screen | ✅ Done |
| 5 | Patient detail / edit screen | ✅ Done |
| 6 | Appointment form + image picker | ✅ Done |
| 7 | Add new patient | ✅ Done |
| 8 | Data management (export / import) | ✅ Done |
| 9 | App lock / password protection | ✅ Done |
| 10 | Polish & UX | ✅ Done |
| 11 | Release build | ✅ Done |
| 12 | DB encryption (post-v1) | Planned |

---

## License

Private — all rights reserved.
