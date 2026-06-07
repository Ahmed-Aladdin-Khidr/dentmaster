# DentMaster — Agent & Session Guidance

> Read this file at the start of every session and before every significant change.  
> It is the contract that keeps the codebase clean, extensible, and version-controlled across all contributors and AI sessions.

---

## Table of Contents

1. [Project North Star](#1-project-north-star)
2. [Clean Architecture Rules](#2-clean-architecture-rules)
3. [Layer-by-Layer Responsibilities](#3-layer-by-layer-responsibilities)
4. [How to Add a New Feature — Checklist](#4-how-to-add-a-new-feature--checklist)
5. [How to Add a New Screen](#5-how-to-add-a-new-screen)
6. [Naming Conventions](#6-naming-conventions)
7. [State Management Rules (BLoC)](#7-state-management-rules-bloc)
8. [Dependency Injection Rules](#8-dependency-injection-rules)
9. [What Must Never Happen](#9-what-must-never-happen)
10. [Git Workflow](#10-git-workflow)
11. [Machine-Specific Git Issues (This Dev Machine)](#11-machine-specific-git-issues-this-dev-machine)
12. [Commit Message Format](#12-commit-message-format)
13. [Branching Strategy](#13-branching-strategy)
14. [Before You Commit — Checklist](#14-before-you-commit--checklist)
15. [Before You Merge — Checklist](#15-before-you-merge--checklist)
16. [How to Extend Without Breaking Things](#16-how-to-extend-without-breaking-things)
17. [File Reference Map](#17-file-reference-map)

---

## 1. Project North Star

DentMaster is a **local-first, single-user, Windows desktop** Flutter application.  
It stores all data on the device using SQLite (Drift). No cloud, no auth, no network calls in v1.

**Architecture:** Clean Architecture — strict separation of Domain / Data / Presentation.  
**State:** BLoC pattern (`flutter_bloc`).  
**DB:** Drift (SQLite ORM with code generation).  
**DI:** get_it + injectable (code-gen based).  
**Routing:** go_router (declarative).

Master plan: [`PLAN.md`](PLAN.md) — consult it for scope, data models, and phase status.  
Execution plan: [`EXECUTION_PLAN.md`](EXECUTION_PLAN.md) — step-by-step commands, exact file content shapes, and verification gates for every phase.

---

## 2. Clean Architecture Rules

### The Dependency Rule

**Dependencies only point inward. Never outward.**

```
Presentation  →  Domain  ←  Data
     (BLoC)     (Entities,    (Drift models,
     (Pages)     UseCases,    Datasources,
     (Widgets)   Repos)       RepoImpls)
```

- `domain/` knows **nothing** about Flutter widgets, Drift, file_picker, or BLoC.
- `data/` knows about Drift and file I/O. It implements domain interfaces.
- `presentation/` knows about BLoC and widgets. It calls use cases through BLoC.
- `core/` is shared infrastructure (errors, utils, base classes). It has no feature knowledge.

### The Three Questions Before Placing Code

1. **Does this contain business rules?** → `domain/`
2. **Does this touch a storage/IO mechanism?** → `data/`
3. **Does this render UI or respond to user gestures?** → `presentation/`

If it fits none cleanly, it is a utility → `core/utils/` or `core/widgets/`.

---

## 3. Layer-by-Layer Responsibilities

### `domain/` — The Heart (Pure Dart, No Flutter, No Drift)

| Subfolder | Contains | Rules |
|---|---|---|
| `entities/` | Plain Dart classes with `Equatable` | No JSON methods. No Drift annotations. No `toJson`. |
| `repositories/` | Abstract interfaces only | `abstract class PatientRepository { ... }` |
| `usecases/` | One class per use case, one `call()` method | Returns `Either<Failure, T>` or `Future<T>`. No UI logic. |

### `data/` — The Plumbing

| Subfolder | Contains | Rules |
|---|---|---|
| `models/` | Drift table classes + model classes | Extends or wraps domain entities. Has `toEntity()` and `fromEntity()`. |
| `datasources/` | Direct Drift queries and file IO | No business rules. No formatting. Raw CRUD only. |
| `repositories/` | `*RepositoryImpl` classes | Implements the domain interface. Translates data exceptions to domain `Failure`s. |

### `presentation/` — The Face

| Subfolder | Contains | Rules |
|---|---|---|
| `bloc/` | BLoC classes (events, states, bloc) | Calls use cases only. Never calls datasources or repositories directly. |
| `pages/` | Full screens / routes | One page per route. Thin — delegates logic to BLoC and widgets. |
| `widgets/` | Reusable feature-specific widgets | May access BLoC via `context`. Never accesses use cases or repos directly. |

### `core/` — Shared Infrastructure

| Subfolder | Contains |
|---|---|
| `constants/` | App-wide color, string, dimension constants |
| `errors/` | `Failure` sealed class and `AppException` types |
| `usecases/` | Abstract `UseCase<Type, Params>` base class |
| `utils/` | Date formatter, image utils, validators |
| `widgets/` | Truly generic UI atoms (`ConfirmDialog`, `AppTextField`, `LoadingOverlay`) |

---

## 4. How to Add a New Feature — Checklist

When asked to add a feature that doesn't fit an existing feature folder, follow this exact order:

```
[ ] 1. Create feature folder under lib/features/<feature_name>/
[ ] 2. Domain first:
        - Define entity/entities in domain/entities/
        - Define repository interface in domain/repositories/
        - Implement each use case in domain/usecases/
[ ] 3. Data layer:
        - Add Drift table(s) in data/models/
        - Add datasource methods in data/datasources/
        - Implement repository in data/repositories/
        - Run code gen: dart run build_runner build --delete-conflicting-outputs
[ ] 4. Register in injection_container.dart (get_it)
[ ] 5. Add route in app_router.dart (go_router)
[ ] 6. Presentation:
        - Write BLoC (events → states → bloc)
        - Build page(s)
        - Build widgets
[ ] 7. Wire DI: register BLoC and use cases in injection_container.dart
[ ] 8. Manual smoke test on Windows
```

**Never skip domain first.** If you define models before entities you will couple data to presentation.

---

## 5. How to Add a New Screen

```
[ ] 1. Add a route constant in lib/core/constants/app_routes.dart
[ ] 2. Add the GoRoute entry in lib/app_router.dart
[ ] 3. Create the page file in the correct feature's presentation/pages/
[ ] 4. If stateful: create a BLoC in the feature's presentation/bloc/
[ ] 5. Register the BLoC in injection_container.dart
[ ] 6. Provide the BLoC with BlocProvider at the page level (not app level unless global)
[ ] 7. If the screen reuses another screen in a different mode (e.g. create vs edit),
        use a mode enum or boolean parameter — do NOT duplicate the page file.
```

---

## 6. Naming Conventions

### Files

| Type | Pattern | Example |
|---|---|---|
| Entity | `<name>.dart` | `patient.dart` |
| Model (Drift) | `<name>_model.dart` | `patient_model.dart` |
| Repository interface | `<name>_repository.dart` | `patient_repository.dart` |
| Repository impl | `<name>_repository_impl.dart` | `patient_repository_impl.dart` |
| Datasource | `<name>_local_datasource.dart` | `patient_local_datasource.dart` |
| Use case | `<verb>_<noun>.dart` | `search_patients.dart`, `delete_appointment.dart` |
| BLoC event file | `<name>_event.dart` | `patient_list_event.dart` |
| BLoC state file | `<name>_state.dart` | `patient_list_state.dart` |
| BLoC class file | `<name>_bloc.dart` | `patient_list_bloc.dart` |
| Page | `<name>_page.dart` | `patient_search_page.dart` |
| Widget | `<name>_widget.dart` or descriptive noun | `patient_card.dart`, `confirm_dialog.dart` |

### Classes

| Type | Pattern | Example |
|---|---|---|
| Entity | `PascalCase` | `Patient`, `Appointment` |
| Model | `PascalCase + Model` | `PatientModel`, `AppointmentModel` |
| Repository interface | `PascalCase + Repository` | `PatientRepository` |
| Repository impl | `PascalCase + RepositoryImpl` | `PatientRepositoryImpl` |
| Use case | verb + noun `PascalCase` | `SearchPatients`, `DeleteAppointment` |
| BLoC | `PascalCase + Bloc` | `PatientListBloc` |
| Event base | `PascalCase + Event` | `PatientListEvent` |
| Event subtype | noun + verb `PascalCase + Event` | `PatientListSearched`, `PatientListLoaded` |
| State base | `PascalCase + State` | `PatientListState` |
| State subtype | descriptive adjective | `PatientListInitial`, `PatientListLoading`, `PatientListSuccess`, `PatientListFailure` |
| Page class | `PascalCase + Page` | `PatientSearchPage` |
| Widget class | descriptive `PascalCase` | `PatientCard`, `AppointmentForm` |

### Variables and Parameters

- `camelCase` always.
- Boolean fields: prefix with `is`, `has`, `can`, `should`. e.g. `isCompressed`, `hasAppointments`.
- IDs: always `String` UUID, named `id` on the entity, `patientId` / `appointmentId` as FK fields.
- Dates: always `DateTime` in domain entities and use cases. Convert to int (epoch ms) only in the Drift layer.

---

## 7. State Management Rules (BLoC)

### Structure

Each BLoC folder has exactly three files:

```
patient_list_bloc.dart    # class PatientListBloc extends Bloc<PatientListEvent, PatientListState>
patient_list_event.dart   # sealed class + subtypes
patient_list_state.dart   # sealed class + subtypes (use freezed)
```

### Rules

1. **BLoC only calls use cases.** Never call a repository, datasource, or Drift directly from a BLoC.
2. **Use cases are injected via constructor.** Never call `GetIt.instance` inside a BLoC.
3. **States are immutable.** Use `freezed` for state classes.
4. **One BLoC per logical screen concern.** If a screen has two very different concerns, use two BLoCs.
5. **BlocProvider at the page level** unless the state is needed across multiple unrelated screens.
6. **Never put business logic in event handlers** beyond calling the appropriate use case and emitting states.

### Standard State Pattern

```dart
@freezed
sealed class PatientListState with _$PatientListState {
  const factory PatientListState.initial() = PatientListInitial;
  const factory PatientListState.loading() = PatientListLoading;
  const factory PatientListState.success(List<Patient> patients) = PatientListSuccess;
  const factory PatientListState.failure(String message) = PatientListFailure;
}
```

### Standard Event Pattern

```dart
@freezed
sealed class PatientListEvent with _$PatientListEvent {
  const factory PatientListEvent.started() = PatientListStarted;
  const factory PatientListEvent.searched(String query) = PatientListSearched;
}
```

---

## 8. Dependency Injection Rules

All wiring happens in `lib/injection_container.dart`.

### Registration Order

```
1. External dependencies (path_provider, drift DB instance)
2. Datasources
3. Repositories
4. Use cases
5. BLoCs
```

### Rules

1. **BLoCs are registered as `Factory`** (new instance per `BlocProvider`).
2. **Use cases, repositories, datasources are `LazySingleton`**.
3. **The Drift database instance is a `Singleton`** (single connection to the file).
4. **Never call `GetIt.instance` in domain layer code** — domain is pure Dart and must not know about DI.
5. When adding a new use case: register it in `injection_container.dart` before writing the BLoC that uses it.

---

## 9. What Must Never Happen

These are hard rules. If you find yourself about to do one of these, stop and reconsider.

| # | Forbidden | Why |
|---|---|---|
| 1 | Import `drift` or `sqflite` in a domain file | Domain must be pure Dart and storage-agnostic |
| 2 | Import `flutter/material.dart` in a domain or data file | Keeps layers platform-independent |
| 3 | Call a repository or datasource directly from a page or widget | All DB access goes through BLoC → use case → repository |
| 4 | Put `BuildContext` in a BLoC, use case, or repository | Context belongs in presentation only |
| 5 | Store absolute image paths that include `C:\Users\<username>\` hardcoded | Always use `path_provider` to resolve the base path at runtime |
| 6 | Delete or overwrite user data without a `ConfirmDialog` | Destructive actions always ask first |
| 7 | Add a new Drift table without running `build_runner` afterward | Generated code will be out of sync |
| 8 | Add a new package without updating `PLAN.md` dependency table | Plan must stay as the source of truth |
| 9 | Add a feature that talks to the network | v1 is local-only; flag it and discuss before implementing |
| 10 | Create two page files that are near-duplicates | Use a mode parameter instead |

---

## 10. Git Workflow

### Repository Initialisation

```bash
git init
git add .
git commit -m "chore: initial flutter windows project scaffold"
```

### Branching Model

We use a simplified **GitHub Flow** (not full Gitflow — this is a solo/small team project):

```
main          ← always deployable / stable
  └── feature/<slug>    ← one branch per feature or phase
  └── fix/<slug>        ← bug fixes
  └── chore/<slug>      ← tooling, deps, config changes
  └── refactor/<slug>   ← structural changes, no new features
```

### Branch Lifecycle

```bash
# Start work
git checkout main
git pull origin main
git checkout -b feature/patient-search

# Work, commit often (see commit format below)

# Before merge: rebase onto latest main
git fetch origin
git rebase origin/main

# Merge (prefer merge commit to preserve history)
git checkout main
git merge --no-ff feature/patient-search
git tag v0.x.0    # if this completes a phase
git push origin main --tags

# Clean up
git branch -d feature/patient-search
```

### Never Do On `main`

- Force push (`git push --force`)
- Direct commits of incomplete features
- Commits that break `flutter run -d windows`

---

## 11. Machine-Specific Git Issues (This Dev Machine)

> These are known environmental constraints on the current Windows development machine.  
> Do not attempt to work around them in ways not listed here — they will fail silently or leave the repo in a broken state.

### SSL Certificate Problem — HTTPS Git Operations Fail

**Symptom:**
```
fatal: unable to access 'https://github.com/...': SSL certificate problem: unable to get local issuer certificate
```

This affects every HTTPS git remote operation on this machine (push, pull, fetch, clone).  
It also affects Flutter's own toolchain when fetching updates (`flutter upgrade`, `flutter pub get` on first run).

**Root cause:** A corporate/network root certificate is not in the system's trusted certificate store, so OpenSSL rejects GitHub's certificate chain.

**Confirmed working fix — local repo config only:**
```bash
# Run once per repo, inside the repo directory — does NOT affect global git config
git config http.sslVerify false
```

This setting is stored in `.git/config` (not committed) and applies only to this repo.

**For new clones or new repos on this machine** — run the command above immediately after `git init` or `git clone` before attempting any remote operations.

**Do NOT use the global flag** (`git config --global http.sslVerify false`) — it disables SSL for all git operations system-wide and is a security risk.

### SSH Remote — Wrong Account

**Symptom:**
```
ERROR: Permission to Ahmed-Aladdin-Khidr/dentmaster.git denied to Ahmed1Aladdin.
```

The SSH key on this machine is registered to the GitHub account `Ahmed1Aladdin`, which does not have access to the `Ahmed-Aladdin-Khidr` organisation repos.

**Do not use SSH remotes on this machine for this project.** Always use HTTPS:
```
https://github.com/Ahmed-Aladdin-Khidr/dentmaster.git
```

### Git Push Authentication

GitHub no longer accepts account passwords over HTTPS. Use a **Personal Access Token (PAT)**:
- Generate at: https://github.com/settings/tokens (classic token, `repo` scope is sufficient)
- When git prompts for a password during push/pull, enter the PAT — not the GitHub account password
- To avoid re-entering: use Git Credential Manager (already bundled with Git for Windows)

### CMake SSL Error — `flutter run -d windows` Fails on First Build

**Symptom:**
```
SSL connect error ... status_code: 35 ... cmake_install.cmake:213 (file): file INSTALL cannot find
"D:/.../build/native_assets/windows": No error.
```

The CMake build step for `sqlite3_flutter_libs` downloads SQLite source from `sqlite.org` over HTTPS, which also fails due to the same corporate SSL issue.  
Additionally, CMake's install step fails if `build/native_assets/windows` doesn't exist yet.

**Confirmed working fixes:**

1. Set `CMAKE_TLS_VERIFY=0` as an environment variable before running `flutter run`:
   ```powershell
   $env:CMAKE_TLS_VERIFY = '0'
   flutter run -d windows
   ```
   This environment variable tells CMake to skip SSL certificate verification for its own HTTP downloads.

2. `windows/CMakeLists.txt` already contains a `file(MAKE_DIRECTORY ...)` call that pre-creates the `build/native_assets/windows` directory — this is already committed, no action needed.

> Note: `CMAKE_TLS_VERIFY=0` is only needed on the first build (when SQLite is downloaded). Subsequent builds skip the download and don't need it. After `flutter clean`, set it again for the next build.

### Checklist When Setting Up a New Repo on This Machine

```bash
git init
# ... add files, commit ...
git remote add origin https://github.com/Ahmed-Aladdin-Khidr/<repo>.git
git config http.sslVerify false    # ← must do this before any push/pull
git push -u origin main
```

---

## 12. Commit Message Format

Use **Conventional Commits** (https://www.conventionalcommits.org).

```
<type>(<scope>): <short description>

[optional body — explain WHY, not WHAT]

[optional footer — breaking changes, issue refs]
```

### Types

| Type | When to use |
|---|---|
| `feat` | New user-facing feature |
| `fix` | Bug fix |
| `chore` | Build scripts, deps, config, code gen — no production code change |
| `refactor` | Code restructure with no behavior change |
| `style` | Formatting, whitespace — no logic change |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |
| `perf` | Performance improvement |

### Scopes (use these consistently)

| Scope | Meaning |
|---|---|
| `patient` | Patient feature (search, detail, CRUD) |
| `appointment` | Appointment feature |
| `image` | Image picking, compression, quality dialog |
| `data-mgmt` | Export / import feature |
| `db` | Drift schema, migrations, codegen |
| `di` | Dependency injection wiring |
| `router` | go_router config |
| `core` | core/ shared utilities |
| `ui` | Global theme, colors, typography |
| `build` | pubspec, build config, windows runner |

### Examples

```
feat(patient): add live search with 300ms debounce
fix(appointment): prevent duplicate image ids on rapid tap
chore(db): run build_runner after adding appointment_images table
refactor(patient): extract PatientCard into its own file
feat(image): add quality comparison dialog with file size display
chore(build): enable windows desktop target in flutter config
docs: update PLAN.md phase 2 status to complete
```

### Commit Size Rule

**One logical change per commit.**  
If your diff touches domain entities AND a page AND a BLoC AND a DB table, split into multiple commits:

```
chore(db): add appointment_images table and run codegen
feat(appointment): implement AppointmentImage entity and repository interface
feat(appointment): implement AppointmentImageRepositoryImpl with file copy logic
feat(image): add quality comparison dialog
feat(appointment): wire image picker into appointment form
```

---

## 13. Branching Strategy

### Phase-Based Branches

Each implementation phase from `PLAN.md` gets its own branch:

| Phase | Branch name |
|---|---|
| Phase 1 — Project Scaffold | `chore/project-scaffold` |
| Phase 2 — Data Layer | `feat/data-layer` |
| Phase 3 — Domain Layer | `feat/domain-layer` |
| Phase 4 — Patient Search | `feat/patient-search` |
| Phase 5 — Patient Detail | `feat/patient-detail` |
| Phase 6 — Appointment Form | `feat/appointment-form` |
| Phase 7 — Add New Patient | `feat/add-patient` |
| Phase 8 — Data Management | `feat/data-management` |
| Phase 9 — Polish | `chore/polish` |
| Phase 10 — Build | `chore/release-build` |

### Tags / Versions

Tag `main` after each completed phase:

```
v0.1.0  — Phase 1-3 complete (scaffold + data + domain)
v0.2.0  — Phase 4-5 complete (patient search + detail)
v0.3.0  — Phase 6-7 complete (appointments + add patient)
v0.4.0  — Phase 8 complete (data management + change password UI)
v0.5.0  — Phase 9 complete (app lock / password protection)
v1.0.0  — Phase 10-11 complete (polished + releasable build)
v1.x.0  — Phase 12 (DB encryption, post-v1 planned)
```

Tag format:
```bash
git tag -a v0.1.0 -m "feat: scaffold, data layer, and domain layer complete"
git push origin v0.1.0
```

---

## 14. Before You Commit — Checklist

Run through this before every `git commit`:

```
[ ] flutter analyze         — zero errors, zero warnings
[ ] flutter test            — all tests pass
[ ] No debug print() statements left in
[ ] No TODO comments added (use GitHub issues instead)
[ ] No hardcoded paths like C:\Users\...
[ ] No unused imports
[ ] New Drift tables → build_runner was run
[ ] New injectable classes → build_runner was run
[ ] injection_container.dart updated if new use case/bloc was added
[ ] PLAN.md phase checklist updated if a task was completed
[ ] Commit message follows Conventional Commits format
```

Quick command to run before committing:
```bash
flutter analyze && flutter test
```

---

## 15. Before You Merge — Checklist

```
[ ] Branch is rebased on latest main (no merge conflicts)
[ ] flutter analyze passes on the branch
[ ] flutter test passes on the branch
[ ] flutter run -d windows launches the app without errors
[ ] The feature was manually tested (golden path + one edge case)
[ ] PLAN.md updated to reflect completed phase items
[ ] No forbidden patterns from Section 9 introduced
[ ] Commit history is clean (squash WIP commits if needed)
```

---

## 16. How to Extend Without Breaking Things

### Adding a New Field to an Existing Entity

1. Add field to domain entity (`domain/entities/patient.dart`)
2. Add column to Drift table in model (`data/models/patient_model.dart`)
3. Write a **Drift schema migration** (increment schema version, add `onUpgrade`)
4. Update `toEntity()` and `fromEntity()` in the model
5. Run `build_runner`
6. Update any use cases or BLoC states that need to carry the new field
7. Update UI forms/displays last

**Never** alter the DB schema without a migration. Drift will throw on version mismatch.

### Adding a New Platform (e.g., Android/iOS later)

1. Run `flutter create . --platforms android` (adds android/ folder)
2. Replace `drift_flutter` native implementation if needed for mobile SQLite
3. Check `path_provider` paths — mobile uses different directories
4. The domain and data layers need **zero changes** if the above rules were followed

### Adding a New Storage Backend (e.g., cloud sync)

1. Create a new repository implementation (e.g., `PatientCloudRepositoryImpl`)
2. Register it in DI with a flag or environment variable
3. Domain use cases are **unchanged** — they only know about `PatientRepository` abstract interface

### Adding a New Screen to an Existing Feature

1. Follow the [How to Add a New Screen](#5-how-to-add-a-new-screen) checklist
2. Add a new BLoC only if the screen has meaningfully different state concerns from existing BLoCs
3. Reuse existing use cases where possible — don't duplicate logic

---

## 17. File Reference Map

Quick navigation for agents and developers:

| File | Purpose |
|---|---|
| `lib/main.dart` | App entry point, DI initialization |
| `lib/app.dart` | `MaterialApp.router` + theme |
| `lib/app_router.dart` | All go_router routes |
| `lib/injection_container.dart` | All get_it registrations |
| `lib/core/errors/failures.dart` | Sealed `Failure` class hierarchy |
| `lib/core/usecases/usecase.dart` | Abstract `UseCase<T, P>` base |
| `lib/core/widgets/confirm_dialog.dart` | Reusable ask-before-action modal |
| `lib/features/patient/domain/entities/patient.dart` | Patient entity |
| `lib/features/patient/domain/entities/appointment.dart` | Appointment entity |
| `lib/features/patient/domain/repositories/patient_repository.dart` | Abstract repo interface |
| `lib/features/patient/data/models/patient_model.dart` | Drift table + model |
| `lib/features/patient/data/repositories/patient_repository_impl.dart` | Concrete repo |
| `lib/features/patient/presentation/pages/patient_search_page.dart` | Home screen |
| `lib/features/patient/presentation/pages/patient_detail_page.dart` | Detail + create screen |
| `lib/features/data_management/presentation/pages/data_management_page.dart` | Export/import screen |
| `PLAN.md` | Master plan — phases, data models, package list |
| `AGENTS.md` | This file — system design and git rules |
| `EXECUTION_PLAN.md` | Step-by-step commands and verification gates per phase |

---

*This file must be updated whenever a significant architectural decision is made or a new pattern is established. It is the living contract for this codebase.*
