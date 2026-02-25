# UIT Mobile - Project Architecture

## Overview

**UIT Mobile** is a Flutter application (Android & iOS) for University of Information Technology (UIT) students. It provides a mobile interface to access timetables, scores, exams, deadlines, tuition fees, notifications, and account management through the UIT API.

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
│   ├── main.dart                          # App entry: Hive init, HomeWidget init, ProviderScope, EasyLocalization
│   │
│   ├── core/
│   │   ├── network/
│   │   │   ├── dio_client.dart            # Dio HTTP client (baseUrl, timeouts, JwtInterceptor, LogInterceptor)
│   │   │   ├── jwt_interceptor.dart       # Auto-refresh JWT on 401, request queuing with _pendingRequests
│   │   │   └── api_service.dart           # Typed API endpoint wrappers (generateToken, getUserInfo, getStudentData, etc.)
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter config with auth guard redirect logic
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart       # Multi-account JWT CRUD (getSessions, upsertSession, getActiveSession, etc.)
│   │   │   ├── hive_cache_service.dart           # Offline-first caching (boxes: courses, scores, notifications, deadlines, userInfo, exams, fees)
│   │   │   └── home_widget_service.dart          # Timetable & deadline data → native home screen widgets (Android + iOS)
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material 3 light + dark themes (primary=#1565C0, secondary=#00897B)
│   │   └── utils/
│   │       ├── constants.dart             # API URL, encoding prefix, auth scheme, storage keys, Hive box names
│   │       └── encoding.dart              # UIT auth encoding: encodeCredentials(), encodeToken()
│   │
│   ├── shared/
│   │   ├── models/
│   │   │   ├── models.dart                # Barrel file exporting all models
│   │   │   ├── user_session.dart          # UserSession: studentId, encodedCredentials, token, encodedToken, tokenExpiry, name, avatarHash
│   │   │   ├── user_info.dart             # UserInfo: name, sid, mail, status, course, major, dob, role, className, address, avatar
│   │   │   ├── course.dart                # Course (classCode, room, lecturer, dayOfWeek, periods) + Semester + TeachingFormat enum (lt/ht2/tttn/kltn)
│   │   │   ├── score.dart                 # Score (grades, weights, isExempted, countsForGpa) + ScoreSemester
│   │   │   ├── exam.dart                  # Exam: parsed from flat API map, getters for date/room/time/subjectName/subjectCode via regex
│   │   │   ├── fee.dart                   # Fee: amountDue, amountPaid, semester, year, dkhp; getter for parsed subjects
│   │   │   ├── notification.dart          # UitNotification: id, title, content, dated
│   │   │   ├── deadline.dart              # Deadline: shortname, name, niceDate, status (pending/overdue/submitted), closed, cmid, url getter
│   │   │   └── student_data.dart          # StudentData: raw JSON wrapper (coursesRaw, scoresRaw, feeRaw, notifyRaw, deadlineRaw, examsRaw)
│   │   └── widgets/
│   │       └── main_shell.dart            # MainShell: 5-tab bottom nav (Home, TKB, Deadlines, Exams, Scores)
│   │
│   └── features/
│       ├── auth/
│       │   ├── providers/
│       │   │   └── auth_provider.dart     # AuthNotifier (sealed states: Initial/Loading/Authenticated/Unauthenticated/NeedsAccountSelection/Error)
│       │   └── presentation/
│       │       ├── login_screen.dart       # Login with Student ID + password, addAccount mode
│       │       ├── accounts_screen.dart    # Switch/remove accounts, add account via FAB
│       │       └── account_switcher_screen.dart # Startup account selection when multiple saved, none active
│       │
│       ├── home/
│       │   ├── providers/
│       │   │   └── data_providers.dart    # studentDataProvider (AsyncNotifier, cache-first), userInfoProvider, derived: courses/scores/fees/notifications/deadlines/exams
│       │   └── presentation/
│       │       └── home_screen.dart       # Profile card, overview stats (courses, deadlines as remaining/total), tuition fees summary with nav to /fees
│       │
│       ├── timetable/
│       │   └── presentation/
│       │       ├── timetable_screen.dart  # TabBar day navigation (Mon-Sun), today indicated with circled border, swipeable
│       │       ├── ht2_screen.dart        # HT2/TTTN/KLTN classes with color-coded badges and meeting schedules
│       │       └── period_info_screen.dart # All 10 UIT periods with time ranges; morning=blue, afternoon=teal; current period highlighted with colored border
│       │
│       ├── deadlines/
│       │   └── presentation/
│       │       └── deadlines_screen.dart  # Filter chips (All/Pending/Finished/Overdue), status badges, deadlineFilterProvider
│       │
│       ├── exams/
│       │   └── presentation/
│       │       └── exams_screen.dart      # Exam schedule with sort (asc/desc); cards colored by date: past (blue), current (teal+border), future (teal)
│       │
│       ├── scores/
│       │   └── presentation/
│       │       ├── scores_screen.dart     # GPA (overall + per-semester), expandable subjects with component breakdown
│       │       └── general_scores_screen.dart # Tabular score view (MAMH, LOP, TC, QT, TH, GK, CK, TB)
│       │
│       ├── fees/
│       │   └── presentation/
│       │       └── fees_screen.dart       # Fee summary (total due/paid/remaining) + per-semester cards with progress bars and registered subjects│       │
│       ├── notifications/
│       │   └── presentation/
│       │       └── notifications_screen.dart # Search/filter notifications, expandable tiles
│       │
│       └── settings/
│           └── presentation/
│               ├── settings_screen.dart   # Language (VI/EN), account management, logout with confirmation
│               ├── debug_screen.dart      # Raw JSON API data viewer with copy buttons
│               └── debug_json_screen.dart # Per-section JSON detail: raw text (default) + tree view toggle
│
├── assets/
│   ├── translations/
│   │   ├── en.json                  # English localization
│   │   └── vi.json                  # Vietnamese localization
│   └── images/
│       └── uit_logo.png             # UIT logo (960x776 PNG)
│
├── android/
│   ├── app/
│   │   ├── build.gradle.kts         # namespace = "com.kevinnitro.uit_mobile", compileSdk=36, minSdk=33
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml  # app label = "UIT"
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
│   │   ├── Info.plist               # CFBundleDisplayName = "UIT", CFBundleName = "uit_mobile"
│   │   ├── Assets.xcassets/
│   │   │   ├── AppIcon.appiconset/  # UIT logo (all sizes: 20x20 - 1024x1024)
│   │   │   └── LaunchImage/
│   │   └── GeneratedPluginRegistrant.swift
│   │
│   ├── Runner.xcodeproj/
│   │   └── project.pbxproj          # PRODUCT_BUNDLE_IDENTIFIER = "com.kevinnitro.uitMobile"
│   │
│   ├── UitWidgets/
│   │   ├── UitWidgets.swift         # SwiftUI home screen widgets (Timetable, Deadlines)
│   │   └── Info.plist               # Widget bundle identifier
│   │
│   └── Podfile                      # CocoaPods dependencies
│
├── pubspec.yaml                     # version: 0.1.0+1, dependencies (Riverpod 3.2.1, Dio, go_router, etc)
├── pubspec.lock
│
├── .github/
│   └── workflows/
│       ├── release-please.yml       # Runs on main push, creates release PRs from conventional commits
│       └── build.yml                # Analyze, build APK (arm64/armv7/x86_64), build IPA
│
├── release-please-config.json       # release-type: "dart"
├── .release-please-manifest.json    # Current version tracking: {"."  : "0.1.0"}
│
├── PLAN.md                          # Implementation plan + UIT API details
├── uit.md                           # API endpoints, encodings, JSON schemas
└── ARCHITECTURE.md                  # This file
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
- **url_launcher 6.3.2** - Opens external URLs (Moodle assignment pages) in system browser

### Routing

- **GoRouter 17.1.0** - Declarative routing with nested routes and auth guards

### Storage

- **flutter_secure_storage 10.0.0** - Encrypted JWT token storage (multi-account)
- **hive_flutter 1.1.0** - Local offline-first caching
- **home_widget 0.9.0** - Push timetable/deadline data to native home screen widgets

### Internationalization

- **easy_localization 3.0.8** - Dart-based i18n (EN/VI), re-exports `intl`
- **intl 0.20.2** - Date/currency formatting

### Serialization

- **json_annotation 4.11.0** - JSON codec generation
- **freezed_annotation 3.1.0** - Immutable model generation (optional, used selectively)

### Development

- **build_runner 2.11.1** - Code generation
- **riverpod_generator 4.0.3** - Generate AsyncNotifier providers
- **json_serializable 6.13.0** - Generate `fromJson`/`toJson` methods
- **flutter_lints 6.0.0** - Dart linting rules

### UI Enhancement

- **flutter_json_view** - Interactive, collapsible JSON tree viewer used in the debug screen

---

## Routing Configuration

### Route Tree

```
/login (LoginScreen)
  └─ ?addAccount=true (add new account mode)

/account-switcher (AccountSwitcherScreen)

/ (MainShell - authenticated root, 5-tab bottom nav)
  ├─ Tab 0: HomeScreen
  ├─ Tab 1: TimetableScreen
  ├─ Tab 2: DeadlinesScreen
  ├─ Tab 3: ExamsScreen
  ├─ Tab 4: ScoresScreen
  ├─ /accounts (AccountsScreen)
  ├─ /notifications (NotificationsScreen)
  ├─ /settings (SettingsScreen)
  ├─ /period-info (PeriodInfoScreen)
  ├─ /fees (FeesScreen)
  ├─ /ht2 (HT2Screen)
  ├─ /scores/general (GeneralScoresScreen)
  └─ /debug (DebugScreen)
```

### Auth Guard Redirect Logic

| Auth State              | On /login              | On /account-switcher | Elsewhere           |
|-------------------------|------------------------|----------------------|---------------------|
| AuthInitial/AuthLoading | no redirect            | no redirect          | no redirect         |
| AuthUnauthenticated     | stay                   | → /login             | → /login            |
| NeedsAccountSelection   | stay                   | stay                 | → /account-switcher |
| AuthAuthenticated       | → / (unless addAccount)| → /                  | stay                |

---

## Authentication Flow

1. User enters Student ID + password on login screen
2. Credentials encoded as `base64("3sn@fah.{id}:{password}")` → sent to `POST /v2/stc/generate`
3. API returns JWT tokens (access, refresh)
4. Tokens stored encrypted via `flutter_secure_storage`
5. On app startup, `AuthNotifier` auto-restores last session
6. `JwtInterceptor` adds `Authorization: UitAu {base64("3sn@fah.{token}:")}` header to all requests
7. If 401 received, interceptor re-authenticates using stored credentials, retries request, processes queued requests

### Auth States (Sealed Class)

- `AuthInitial` - First build, before restore
- `AuthLoading` - Processing login/switch/logout
- `AuthAuthenticated(session)` - Active user
- `AuthUnauthenticated` - No session, no saved sessions
- `AuthNeedsAccountSelection` - Multiple saved sessions, no active
- `AuthError(message)` - Error occurred

---

## Data Flow

### API → Storage → UI

1. **API Service** (`lib/core/network/api_service.dart`) wraps UIT endpoints:
   - `POST /v2/stc/generate` → Token generation
   - `GET /v2/data?task=current` → UserInfo
   - `GET /v2/data?task=all&v=1` → StudentData (full data: courses, scores, fees, notifications, deadlines, exams)

2. **Data Providers** (`lib/features/home/providers/data_providers.dart`):
   - `studentDataProvider` - AsyncNotifier, cache-first strategy, auto-refresh in background, watches authProvider
   - `userInfoProvider` - FutureProvider, separate endpoint for profile, cache-first with background refresh
   - **Derived FutureProviders** (from studentDataProvider):
     - `coursesProvider` → `List<Semester>`
     - `scoresProvider` → `List<ScoreSemester>`
     - `feesProvider` → `List<Fee>`
     - `notificationsProvider` → `List<UitNotification>`
     - `deadlinesProvider` → `List<Deadline>`
     - `examsProvider` → `List<Exam>`

3. **Hive Cache** (`lib/core/storage/hive_cache_service.dart`):
   - Stores JSON serialized models in boxes keyed by account ID
   - Boxes: `courses`, `scores`, `notifications`, `deadlines`, `userInfo`, `exams`, `fees`
   - Offline-first: reads cache first, refreshes in background if stale

4. **UI Screens** consume providers and rebuild reactively

### Feature-Specific Providers

- `deadlineFilterProvider` (NotifierProvider) - Filter: all/pending/finished/overdue
- `filteredDeadlinesProvider` (FutureProvider) - Filtered deadline list
- `examSortOrderProvider` (NotifierProvider) - Sort: asc/desc
- `sortedExamsProvider` (FutureProvider) - Sorted exam list
- `notificationSearchProvider` (NotifierProvider) - Search query string
- `filteredNotificationsProvider` (FutureProvider) - Filtered notification list

### Home Screen Widgets (Native)

- **Android**: Kotlin `TimetableWidgetProvider`, `DeadlinesWidgetProvider` read from `SharedPreferences` (app group)
- **iOS**: SwiftUI widgets read from `UserDefaults` (app group: `group.com.kevinnitro.uitMobile`)
- **Dart Side**: `HomeWidgetService` serializes today's courses + upcoming deadlines → widgets
- **Data Keys**: `today_courses`, `upcoming_deadlines`, `last_updated`

---

## Screen Implementations

### Home Screen (`lib/features/home/presentation/home_screen.dart`)

- **App Bar**: Refresh, Notifications (→ /notifications), Settings (→ /settings)
- **Profile Card**: Avatar (first letter), name, student ID, major, class, email, DOB, address (if non-empty)
- **Overview Section**: Course count (total across all days), Deadline count as `remaining/total` (where remaining = total - submitted)
- **Tuition Fees Section**: Summary card showing remaining amount, progress bar, paid/due totals; tappable to navigate to /fees

### Timetable Screen (`lib/features/timetable/presentation/timetable_screen.dart`)

- **TabBar**: 7 days (Mon-Sun), bold if has classes, outline color if no classes
- **Today Indicator**: Current day tab has a **circled border** (primary color, rounded rectangle)
- **Day Mapping**: Dart weekday (1=Mon) → UIT code (+1); initial tab = today
- **Course Tiles**: Period badge (primaryContainer), class code, room, lecturer name
- **App Bar Action**: Period Info button (→ /period-info)
- **App Bar Action**: HT2/TTTN/KLTN button (→ /ht2) — opens the non-lecture classes screen

### HT2 Screen (`lib/features/timetable/presentation/ht2_screen.dart`)

- **Title**: "HT2 - TTTN - KLTN" (i18n key `timetable.ht2Title`)
- **Course Tiles**: Class code, subject name, credits, department, date range, lecturers
- **Teaching Format Badge**: Color-coded by `TeachingFormat` enum — HT2 (teal/tertiary), TTTN (secondary), KLTN (error/red)
- **Meeting Schedule**: Displays `ht2_lichgapsv` if available, otherwise shows "No meeting schedule yet"

### Period Info Screen (`lib/features/timetable/presentation/period_info_screen.dart`)

- **Static Data**: 10 UIT periods with numeric start/end hour+minute for time comparison
- **Morning (1-5)**: Blue/primaryContainer colored
- **Afternoon (6-10)**: Teal/tertiaryContainer colored
- **Current Period Highlight**: If current time falls within a period's range, that card gets a **colored border** (primary for morning, tertiary for afternoon)

### Deadlines Screen (`lib/features/deadlines/presentation/deadlines_screen.dart`)

- **Filter Chips**: All, Pending, Finished, Overdue
- **Status Icons**: check_circle (green/submitted), assignment_late (red/overdue), assignment (orange/pending)
- **Additional Badges**: "Closed" if submission closed
- **Tap to Open**: Clicking a deadline with a `cmid` shows a confirmation dialog to open the Moodle assignment URL in the external browser (via `url_launcher`)

### Exams Screen (`lib/features/exams/presentation/exams_screen.dart`)

- **Sort Toggle**: Ascending (oldest first) / Descending (newest first, default)
- **Date-Based Card Coloring** (like period info screen):
  - **Past exams**: primaryContainer background (blue tint)
  - **Current (today)**: tertiaryContainer background + **colored border** (tertiary)
  - **Future exams**: tertiaryContainer background (teal tint)
- **Date Parsing**: Supports dd/MM/yyyy, dd-MM-yyyy, yyyy-MM-dd formats

### Scores Screen (`lib/features/scores/presentation/scores_screen.dart`)

- **Overall GPA Card**: Color-coded (green >=8.5, teal >=7.0, orange >=5.5, red <5.5), total credits
- **Semester Cards** (most recent first): Expandable, per-semester GPA, subject count
  - Each subject expandable: final grade badge, code, credits, type
  - Component breakdown table: QT, TH, GK, CK (only non-zero weights)
  - "Miễn" label for exempted courses

### General Scores Screen (`lib/features/scores/presentation/general_scores_screen.dart`)

- **Tabular View**: One semester per card
- **Columns**: MAMH (code), LOP (class), TC (credits), QT, TH, GK, CK, TB (final)
- **Features**: Alternating row colors, color-coded final grade chips

### Fees Screen (`lib/features/fees/presentation/fees_screen.dart`)

- **Summary Card**: Total due, total paid, remaining (green if paid, red if not), progress bar
- **Per-Fee Cards**: Semester label, paid/unpaid badge, amount columns (due, paid, previous debt, remaining), progress bar
- **Registered Subjects**: Tags parsed from dkhp (code + credits)
- **Currency**: VND formatted with thousands separator

### Notifications Screen (`lib/features/notifications/presentation/notifications_screen.dart`)

- **Search**: Toggle search bar, filters by title or content (case-insensitive)
- **Tiles**: Expandable, title (truncate 2 lines collapsed), date, full content on expand
- **Pull-to-Refresh**: Available

### Settings Screen (`lib/features/settings/presentation/settings_screen.dart`)

- **Language**: Radio buttons (Vietnamese/English)
- **Account**: Manage accounts (→ /accounts), Logout with confirmation
- **About**: App version (v1.0.1), Author, GitHub link (external), Debug screen (→ /debug)

### Debug Screen (`lib/features/settings/presentation/debug_screen.dart`)

- **Raw JSON Viewer**: Expandable sections for Courses, Scores, Fees, Notifications, Deadlines, Exams
- **Copy Buttons**: Per-section and copy-all in app bar
- **Detail View** (`debug_json_screen.dart`): Default shows raw pretty-printed JSON text (monospace); toggle button switches to interactive collapsible tree view (via `flutter_json_view`)

---

## Data Models

### UserSession
- `studentId`, `encodedCredentials`, `token`, `encodedToken`, `tokenExpiry`, `name`, `avatarHash`

### UserInfo
- `name`, `sid`, `mail`, `status`, `course`, `major`, `dob`, `role`, `className`, `address`, `avatar`

### Course + Semester + TeachingFormat
- **TeachingFormat** (enum): `lt` (LT), `ht2` (HT2), `tttn` (TTTN), `kltn` (KLTN); parsed from API field `hinhthucgd`
  - Each value provides: `label`, `badgeColor(cs)`, `badgeTextColor(cs)`, `isNonLecture`
  - LT uses primaryContainer, HT2 uses tertiaryContainer, TTTN uses secondaryContainer, KLTN uses errorContainer
- Course: `id`, `classCode`, `room`, `lecturerName`, `lecturerEmail`, `department`, `dayOfWeek`, `periods`, `subjectCode`, `subjectName`, `credits`, `totalCredits`, `teachingFormat`, `format` (TeachingFormat enum), `ht2Schedule`, `startDate`, `endDate`, `lecturers`
  - `isHT2` getter: `format != null && format!.isNonLecture` (covers HT2, TTTN, KLTN)
- Semester: `name` (UIT day code '2'-'8', or `"HT2/TTTN/KLTN"` for non-lecture groups), `courses` (list)

### Score + ScoreSemester
- Score: `subjectCode`, `classCode`, `semester`, `year`, `credits`, `subjectName`, `subjectType`, `finalGrade`, `grade1-4`, `weight1-4`
- Getters: `isExempted` (all weights=0), `countsForGpa` (not exempted, numeric grade, credits>0)

### Exam
- `classCode`, `details` (raw key-value), `dateKey`
- Getters: `date`, `room` (regex), `time` (regex), `subjectName` (regex), `subjectCode` (regex)
- Static: `listFromJson(Map)` parses flat API structure

### Fee
- `amountDue`, `amountPaid`, `semester`, `year`, `dkhp`
- Getter: `subjects` (parsed from dkhp into code+credits pairs)

### Deadline
- `cmid` (int?, Moodle course-module ID), `shortname`, `name`, `niceDate`, `status` (pending/overdue/submitted), `closed`
- `url` getter: builds `https://courses.uit.edu.vn/mod/assign/view.php?id={cmid}` (null if cmid absent)
- Status mapping: null->pending, "new"->overdue, "submitted"->submitted

### UitNotification
- `id`, `title`, `content`, `dated`

### StudentData (raw wrapper)
- `coursesRaw`, `scoresRaw`, `feeRaw`, `notifyRaw`, `deadlineRaw`, `examsRaw`

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
- Exams returned as flat `Map<date, Map<slot, description>>` — parsed via regex

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
  "exams": { "sortAsc": "Sort oldest first", "sortDesc": "Sort newest first" },
  "scores": {
    "component1": "QT",
    "component2": "TH",
    "component3": "GK",
    "component4": "CK",
    "exempted": "Exempted" / "Miễn"
  },
  "fees": { "title": "Tuition Fees" / "Học phí", "paidInFull": "Paid in full" / "Đã đóng đủ" }
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
