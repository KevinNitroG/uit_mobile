# UIT Mobile - Project Architecture

## Overview

**UIT Mobile** is a Flutter application (Android & iOS) for University of Information Technology (UIT) students. It provides a mobile interface to access timetables, scores, deadlines, notifications, and account management through the UIT API.

**Author**: KevinNitroG  
**Package Name**: `com.kevinnitro.uit_mobile` (Android), `com.kevinnitro.uitMobile` (iOS)  
**GitHub Repo**: `KevinNitroG/uit_mobile`  
**Flutter Version**: 3.x (stable)  
**Dart Version**: 3.11.0+  
**Min SDK**: Android 13+ (minSdk=33), iOS 16+

---

## Directory Structure

```
uit-mobile/
├── lib/
│   ├── core/
│   │   ├── network/
│   │   │   ├── dio_client.dart           # Dio HTTP client with JWT interceptor
│   │   │   ├── jwt_interceptor.dart      # Auto-refresh JWT on 401, request queuing
│   │   │   └── api_service.dart          # Typed API endpoint wrappers
│   │   ├── router/
│   │   │   └── app_router.dart           # GoRouter config: /login, /, /accounts, /notifications, /settings, /period-info
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart      # Multi-account JWT CRUD
│   │   │   ├── hive_cache_service.dart          # Offline-first caching
│   │   │   └── home_widget_service.dart         # Timetable & deadline data → home screen widgets
│   │   ├── theme/
│   │   │   └── app_theme.dart            # Material 3 light + dark themes
│   │   └── utils/
│   │       ├── constants.dart            # API URL, Hive box names, secure storage keys
│   │       └── encoding.dart             # UIT auth encoding: encodeCredentials(), encodeToken()
│   │
│   ├── shared/
│   │   ├── models/
│   │   │   ├── models.dart               # Barrel file exporting all models
│   │   │   ├── user_session.dart         # JWT tokens (access, refresh, expired_at)
│   │   │   ├── user_info.dart            # User profile (name, class, email, etc)
│   │   │   ├── course.dart               # Course (day group) + Semester
│   │   │   ├── score.dart                # Score (final, components) + ScoreSemester
│   │   │   ├── fee.dart                  # Fee data
│   │   │   ├── notification.dart         # Notification data
│   │   │   ├── deadline.dart             # Deadline with status (pending/finished/overdue)
│   │   │   └── student_data.dart         # Aggregate: courses, scores, fees, notifications, deadlines
│   │   └── widgets/
│   │       └── main_shell.dart           # MainShell: 4-tab bottom nav (Home, TKB, Deadlines, Scores)
│   │
│   └── features/
│       ├── auth/
│       │   ├── providers/
│       │   │   └── auth_provider.dart    # AuthNotifier: login, switch, remove, logout (auto-restore on startup)
│       │   └── presentation/
│       │       ├── login_screen.dart     # Login with Student ID + password, multi-account support
│       │       └── accounts_screen.dart  # Switch/remove accounts, add account via FAB
│       │
│       ├── home/
│       │   ├── providers/
│       │   │   └── data_providers.dart   # AsyncNotifier providers: studentData, courses, scores, etc (cache-first)
│       │   └── presentation/
│       │       └── home_screen.dart      # User overview, quick stats, refresh, app bar actions (notifications, settings, accounts)
│       │
│       ├── timetable/
│       │   └── presentation/
│       │       ├── timetable_screen.dart # TabBar day navigation (Mon-Sun), today auto-selected, swipeable
│       │       └── period_info_screen.dart # All 10 UIT periods with time ranges
│       │
│       ├── deadlines/
│       │   └── presentation/
│       │       └── deadlines_screen.dart # Filter chips (All/Pending/Finished/Overdue), status badges
│       │
│       ├── scores/
│       │   └── presentation/
│       │       └── scores_screen.dart    # GPA (overall + per-semester), exempted courses ("Miễn"), component breakdown table
│       │
│       ├── notifications/
│       │   └── presentation/
│       │       └── notifications_screen.dart # Search/filter notifications, accessible via top app bar
│       │
│       └── settings/
│           └── presentation/
│               └── settings_screen.dart  # Language (VI/EN), account management, logout with confirmation
│
├── assets/
│   ├── translations/
│   │   ├── en.json                 # English localization
│   │   └── vi.json                 # Vietnamese localization
│   └── images/
│       └── uit_logo.png            # UIT logo (960x776 PNG)
│
├── android/
│   ├── app/
│   │   ├── build.gradle.kts        # namespace = "com.kevinnitro.uit_mobile", compileSdk=36, minSdk=33
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml # app label = "UIT"
│   │   │   ├── kotlin/com/kevinnitro/uit_mobile/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── TimetableWidgetProvider.kt
│   │   │   │   └── DeadlinesWidgetProvider.kt
│   │   │   ├── res/
│   │   │   │   ├── mipmap-*/ic_launcher.png          # UIT logo (all densities: mdpi-xxxhdpi)
│   │   │   │   ├── layout/
│   │   │   │   │   ├── timetable_widget.xml
│   │   │   │   │   └── deadlines_widget.xml
│   │   │   │   ├── xml/
│   │   │   │   │   ├── timetable_widget_info.xml
│   │   │   │   │   └── deadlines_widget_info.xml
│   │   │   │   └── values/strings.xml
│   │   │   └── res_service/
│   │   │       └── NotificationService.kt (if used in future)
│   │
│   └── gradle/  # Gradle Wrapper
│
├── ios/
│   ├── Runner/
│   │   ├── Info.plist              # CFBundleDisplayName = "UIT", CFBundleName = "uit_mobile"
│   │   ├── Assets.xcassets/
│   │   │   ├── AppIcon.appiconset/ # UIT logo (all sizes: 20x20 - 1024x1024)
│   │   │   └── LaunchImage/
│   │   └── GeneratedPluginRegistrant.swift
│   │
│   ├── Runner.xcodeproj/
│   │   └── project.pbxproj         # PRODUCT_BUNDLE_IDENTIFIER = "com.kevinnitro.uitMobile"
│   │
│   ├── UitWidgets/
│   │   ├── UitWidgets.swift        # SwiftUI home screen widgets (Timetable, Deadlines)
│   │   └── Info.plist              # Widget bundle identifier
│   │
│   └── Podfile                     # CocoaPods dependencies
│
├── pubspec.yaml                    # version: 0.1.0+1, dependencies (Riverpod 3.2.1, Dio, go_router, etc)
├── pubspec.lock
│
├── .github/
│   └── workflows/
│       ├── release-please.yml      # Runs on main push, creates release PRs from conventional commits
│       └── build.yml               # Analyze, build APK (arm64/armv7/x86_64), build IPA
│
├── release-please-config.json      # release-type: "dart"
├── .release-please-manifest.json   # Current version tracking: {"."  : "0.1.0"}
│
├── PLAN.md                         # Implementation plan + UIT API details
├── uit.md                          # API endpoints, encodings, JSON schemas
└── ARCHITECTURE.md                 # This file
```

---

## Key Technologies & Packages

### Core Framework

- **Flutter 3.x** (stable) - Cross-platform UI framework
- **Dart 3.11.0+** - Language with null safety

### State Management

- **Flutter Riverpod 3.2.1** - Reactive state management using `Notifier`/`NotifierProvider` and `AsyncNotifier`/`AsyncNotifierProvider` (NOT StateNotifier)

### HTTP & Networking

- **Dio 5.9.1** - HTTP client with interceptor support
- Custom `JwtInterceptor` for auto-refresh on 401, request queuing

### Routing

- **GoRouter 17.1.0** - Declarative routing with nested routes and auth guards

### Storage

- **flutter_secure_storage 10.0.0** - Encrypted JWT token storage (multi-account)
- **hive_flutter 1.1.0** - Local offline-first caching
- **home_widget 0.9.0** - Push timetable/deadline data to native home screen widgets

### Internationalization

- **easy_localization 3.0.8** - Dart-based i18n (EN/VI)
- **intl 0.20.2** - Date formatting

### Serialization

- **json_annotation 4.11.0** - JSON codec generation
- **freezed_annotation 3.1.0** - Immutable model generation (optional, used selectively)

### Development

- **build_runner 2.11.1** - Code generation
- **riverpod_generator 4.0.3** - Generate AsyncNotifier providers
- **json_serializable 6.13.0** - Generate `fromJson`/`toJson` methods
- **flutter_lints 6.0.0** - Dart linting rules

---

## Authentication Flow

1. User enters Student ID + password on login screen
2. Credentials encoded as `base64("3sn@fah.{id}:{password}")` → sent to `POST /v2/stc/generate`
3. API returns JWT tokens (access, refresh)
4. Tokens stored encrypted via `flutter_secure_storage`
5. On app startup, `AuthNotifier` auto-restores last session
6. `JwtInterceptor` adds `Authorization: UitAu {base64("3sn@fah.{token}:")}` header to all requests
7. If 401 received, intercept refreshes token and retries request

---

## Data Flow

### API → Storage → UI

1. **API Service** (`lib/core/network/api_service.dart`) wraps UIT endpoints:
   - `GET /v2/data?task=current` → UserInfo
   - `GET /v2/data?task=all&v=1` → StudentData (full data: courses, scores, fees, notifications, deadlines)

2. **Data Providers** (`lib/features/home/providers/data_providers.dart`):
   - `studentDataProvider` - AsyncNotifier, cache-first strategy, auto-refresh in background
   - `userInfoProvider` - AsyncNotifier, invalidates itself on profile changes
   - Derived providers: `coursesProvider`, `scoresProvider`, `feesProvider`, etc.

3. **Hive Cache** (`lib/core/storage/hive_cache_service.dart`):
   - Stores JSON serialized models in boxes keyed by account ID
   - Offline-first: reads cache first, refreshes in background if stale

4. **UI Screens** consume providers and rebuild reactively

### Home Screen Widgets

- **Android**: Kotlin `TimetableWidgetProvider`, `DeadlinesWidgetProvider` read from `SharedPreferences` (app group)
- **iOS**: SwiftUI widgets read from `UserDefaults` (app group: `group.com.kevinnitro.uitMobile`)
- **Dart Side**: `HomeWidgetService` serializes today's courses + upcoming deadlines → widgets

---

## API Encoding Details

UIT API uses custom auth scheme:

**Credentials Encoding**:

```dart
base64("3sn@fah.{studentId}:{password}")
// Sent as: Authorization: UitAu {encoded}
```

**Token Encoding**:

```dart
base64("3sn@fah.{jwtToken}:")
// Sent as: Authorization: UitAu {encoded}
```

**Day-of-Week Mapping** (API vs Dart):

- API: 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat, 8=Sun
- Dart: 1=Mon, 2=Tue, ..., 7=Sun
- Conversion: `(weekday + 1).toString()` (API) ↔ `(parseInt(apiDay) - 1)` (Dart)

**API Oddities**:

- `magv` field (lecturer data) is a `List<Map>`, not a String
- `courses[].name` and `scores[].name` can be returned as `int` or `String`
- Exempted courses (`"Miễn"`) have `diem: "0"` and all weights = `"0"` in API

---

## GPA Calculation

**Criteria for Inclusion**:

- Course must NOT be exempted (all weights = 0)
- Final grade must be numeric (parseable to `double`)
- Credits must be > 0

**Calculation**:

```
GPA = Σ(grade × credits) / Σ(credits)
```

**Per-Semester**: Only includes scores in that semester  
**Overall**: Includes all semesters across all years

**Exempted Courses**: Displayed as "Miễn" in UI, excluded from GPA with note "Miễn — không tính vào GPA"

---

## Localization (EN/VI)

All UI strings are in `assets/translations/{en,vi}.json`:

```json
{
  "login": { "signIn": "Sign In" / "Đăng nhập" },
  "home": { "overview": "Overview" / "Tổng quan" },
  "timetable": { "periodInfo": "Period Info" / "Chi tiết tiết học" },
  "scores": {
    "component1": "QT (Process)" / "QT (Quá trình)",
    "component2": "TH (Practice)" / "TH (Thực hành)",
    "component3": "GK (Midterm)" / "GK (Giữa kỳ)",
    "component4": "CK (Final)" / "CK (Cuối kỳ)",
    "exempted": "Exempted — not counted in GPA" / "Miễn — không tính vào GPA"
  },
  // ... more keys
}
```

Accessed via `'key.path'.tr()` (EasyLocalization).

---

## Responsive Layout

- **Mobile-first**: Designed for Portrait on phones (6"+ typical)
- **Tablets**: Apps expand naturally (no specific layout breakpoints yet)
- **Orientation**: Supports portrait + landscape
- **Text Selection**: `SelectionArea` wraps content for user copy-paste

---

## Testing Notes

- **Static Analysis**: `flutter analyze --no-fatal-infos` → 0 errors, 0 warnings
- **Manual Testing**: Built and deployed on Redmi K30 5G (Android 13)
- **iOS**: Not yet tested on physical device; simulator support ready

---

## Git & Release Management

**Repository**: `KevinNitroG/uit_mobile` on GitHub

**Commit Convention**: Follows [Conventional Commits](https://www.conventionalcommits.org/):

- `feat: ...` → Minor version bump + release note
- `fix: ...` → Patch version bump
- `docs: ...`, `chore: ...`, `test: ...` → No version bump (hidden in changelog)

**Release Pipeline**:

1. Merge feature/fix branches to `main`
2. GitHub Action `release-please` creates Release PR with:
   - Version bump in `pubspec.yaml` (SemVer + build number)
   - CHANGELOG.md entry
3. Merge Release PR → creates GitHub Release + git tag
4. `build.yml` action optionally builds APK/IPA artifacts

**Version Format**: `X.Y.Z+N` (e.g., `0.1.0+1`)

- X.Y.Z = SemVer
- N = build number (auto-incremented by release-please)

---

## Future Enhancements

- Push notifications (Firebase Cloud Messaging)
- Grade prediction/analytics
- Timetable export (iCal)
- Dark theme refinements
- Offline-first sync improvements
- Unit & widget tests
- iOS/Android app signing for production release
- App Store & Google Play deployment

---

## Contact & Support

**Author**: KevinNitroG  
**Project**: UIT Mobile - Flutter App for UIT Students  
**License**: (To be defined)
