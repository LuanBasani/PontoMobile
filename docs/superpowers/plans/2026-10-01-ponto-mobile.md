# PontoMobile Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the starter Flutter project into a documented attendance app with Firebase email authentication, optional local biometric unlock, workplace geofencing within 100 meters, Firestore records, and live history.

**Architecture:** Keep Firebase and device APIs behind focused services; keep pure validation, distance policy, and record sequencing independently testable. Use Firebase Auth's auth-state stream for root routing, Firestore user-scoped paths for profiles and records, and a Material UI for login, registration, attendance, history, and profile/logout.

**Tech Stack:** Flutter/Dart, firebase_core 4.15.0, firebase_auth 6.7.0, cloud_firestore 6.10.0, geolocator 14.1.1, local_auth 3.0.2, flutter_test.

**Spec:** User-provided pasted request in `C:\Users\35T1\.codex\attachments\65dfc744-e2ec-4c4b-b021-358abc0d7d32\Texto colado.txt`.

## Global Constraints

- Preserve `lib/firebase_options.dart`, Firebase project `pontomobile-86dee`, and Android application ID `com.example.ponto_mobile`.
- Reuse installed dependencies; do not add dependencies unless a demonstrated technical need requires one.
- Use the fixed SENAI Americana coordinates (`-22.7538572`, `-47.3513785`) from `AppConfig` for workplace geofencing.
- Store records under the signed-in user's UID; never store passwords or biometric data.
- Treat Firebase Console setup and physical-device biometrics/GPS as external validation items; never claim them as completed without access and verification.
- Add Firestore rules scoped to `users/{uid}` and that user's records; local rules files do not imply deployed rules.

## Review Focus

- Missing, malformed, or out-of-range work coordinates must disable attendance rather than permit it; test configuration parsing and validity.
- Exactly 100 m is allowed and any greater distance is blocked; test 100 m and 100.01 m.
- A record write must not allow another UID to read/write it; encode owner scoping in paths/rules and document emulator/deployment verification.
- Biometrics only unlock the already authenticated local session and must not create or replace Firebase credentials; review service flow and user-facing states.
- Location permission denial, permanent denial, disabled service, and acquisition errors must return understandable outcomes without recording a point; verify service/UI error mapping where testable without hardware.

---

### Task 1: App foundation and pure domain rules

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app/app.dart`, `lib/core/constants/app_config.dart`, `lib/core/theme/app_theme.dart`
- Create: `lib/models/user_profile.dart`, `lib/models/time_record.dart`
- Create: `lib/core/attendance_policy.dart`, `lib/core/form_validators.dart`
- Test: `test/core/attendance_policy_test.dart`, `test/core/app_config_test.dart`, `test/core/form_validators_test.dart`, `test/models/time_record_test.dart`

**Interfaces:**
- `AppConfig()` exposes the fixed workplace coordinates through `workplaceConfigured`, `workLatitude`, and `workLongitude`.
- `AttendancePolicy.isWithinAllowedRadius(double distanceMeters)` accepts exactly 100 m.
- `nextRecordType(List<TimeRecord> records)` alternates `entrada` and `saida`, starting with `entrada`.
- `UserProfile` and `TimeRecord` provide Firestore serialization/parsing with timestamps and location/distance fields.

- [x] **Step 1: Write failing pure Dart tests** for missing/invalid coordinates, radius edge cases, first/subsequent record sequence, validators, and model serialization.
- [x] **Step 2: Run `flutter test test/core test/models`** and confirm failures are due to absent interfaces.
- [x] **Step 3: Implement configuration, policy, validators, and models** with no Firebase/device calls.
- [x] **Step 4: Run the focused tests and `flutter analyze`**; resolve findings without suppressing analyzer rules.

### Task 2: Firebase and device services

**Files:**
- Create: `lib/services/auth_service.dart`, `lib/services/user_profile_service.dart`, `lib/services/biometric_service.dart`, `lib/services/location_service.dart`, `lib/services/time_record_service.dart`
- Modify: `android/app/src/main/AndroidManifest.xml` only for required location/biometric permissions.
- Test: pure service mapping/helpers under `test/services/` when they can be tested without live Firebase or hardware.

**Interfaces:**
- `AuthService` wraps auth state, sign-in, registration, and sign-out; registration creates `users/{uid}` profile with server timestamp.
- `BiometricService` checks device support/enrollment and authenticates locally; it does not issue Firebase credentials or persist biometric data.
- `LocationService` checks service and permission state, gets a current position with bounded timeout, and calculates distance from configured workplace coordinates.
- `TimeRecordService` writes and streams only `users/{uid}/records/{recordId}`; each record has server timestamp, client-captured position, distance, and type.

- [x] **Step 1: Add tests for extractable Firebase error mapping and record sequencing/write-input validation** before implementations.
- [x] **Step 2: Run those tests and confirm intended failures.**
- [x] **Step 3: Implement services using the installed package APIs**, keeping plugins out of UI and returning clear domain errors.
- [x] **Step 4: Add only required Android permissions/configuration** and review minSdk/MainActivity without changing package ID.
- [x] **Step 5: Run `flutter analyze` and all service/domain tests.**

### Task 3: Authentication and attendance UI

**Files:**
- Create: `lib/screens/auth/auth_gate.dart`, `lib/screens/auth/login_screen.dart`, `lib/screens/auth/register_screen.dart`
- Create: `lib/screens/home/home_screen.dart`, `lib/screens/history/history_screen.dart`, `lib/screens/profile/profile_screen.dart`
- Create: reusable widgets under `lib/widgets/` for forms, distance status, record rows, and loading/error states.
- Test: `test/widget/` for auth gate and core form/radius presentation where practical.

**Interfaces:**
- `AuthGate` listens to Firebase Auth state and selects login or authenticated shell.
- Login/register forms validate input, guard repeated submissions, show friendly errors, and dispose controllers.
- Home obtains location through `LocationService`, shows configuration/permission/distance states, and offers the next valid entry/exit action only within 100 m.
- History renders the signed-in user's Firestore stream; profile shows user information and logout; biometric action is offered only when supported/enrolled and local session is configured.

- [x] **Step 1: Add failing widget tests** for auth-state routing and invalid login/registration inputs.
- [x] **Step 2: Verify expected test failures.**
- [x] **Step 3: Implement the screens and reusable UI** with responsive layouts and explicit loading/error/success feedback.
- [x] **Step 4: Run widget tests, `flutter analyze`, and `flutter test`.**

### Task 4: Firebase rules, documentation, and final verification

**Files:**
- Create: `firestore.rules`
- Modify: `firebase.json`, `README.md`
- Create: `docs/RELATORIO_IMPLEMENTACAO.md`, `docs/INSTALACAO_E_USO.md`

- [x] **Step 1: Add Firestore security rules** requiring authentication and matching UID for profile and nested record access; preserve any existing Firebase config.
- [x] **Step 2: Document setup and usage** including Email/Password activation, Firestore database/rules deployment, work-coordinate defines, Android permissions, biometrics, run/test commands, and limitations not physically verified.
- [x] **Step 3: Complete the implementation report** using only observed findings; label unperformed console/device steps as pending manual configuration.
- [x] **Step 4: Run `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter run` if a usable device/emulator exists.**
- [x] **Step 5: Review `git status` and diff** to ensure only this project’s task files changed and Firebase-generated files/package identity were preserved.

## Coverage Check

The four tasks cover Firebase initialization, architecture, auth, registration/profile, local biometrics, location permissions and distance, record model/write/read stream, attendance UI, history, Firestore rules, errors, tests, and all three requested documentation files. Firebase Console enablement, Firestore creation/deployment, and physical-device behavior remain manual validation if they cannot be accessed from this workspace.
