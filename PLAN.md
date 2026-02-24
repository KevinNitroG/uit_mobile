# UIT Mobile App - Detailed Implementation Plan

## 1. Executive Summary

This document outlines the architecture, tech stack, and implementation strategy for the UIT Mobile Application (Android, iOS, iPadOS). The goal is to deliver a highly maintainable, modern, and clean application leveraging the latest Flutter standards in 2026, with a focus on seamless user experience (caching, preloading, native feel).

## 2. Core Tech Stack & Dependencies

To ensure the app is "easy to maintain" and avoids unnecessary complexity, we will use modern, industry-standard packages:

- **State Management & Dependency Injection: `flutter_riverpod`**
  - _Why:_ Riverpod is the modern standard for Flutter state management. It provides compile-time safety, effortless asynchronous data handling (built-in caching, loading/error states via `AsyncValue`), and minimal boilerplate. It perfectly handles the "no complex" requirement while scaling extremely well.
- **Networking: `dio`**
  - _Why:_ Advanced HTTP client. Crucial for the **JWT auto-refresh** mechanism via Dio Interceptors and handling complex API requests gracefully.
- **Local Storage & Caching: `hive` (or `isar`) & `flutter_secure_storage`**
  - _Why:_ `flutter_secure_storage` safely stores multiple JWT tokens and credentials for the "multiple accounts" feature. `hive` provides blazing-fast local NoSQL caching for subjects and notifications, enhancing the offline UX.
- **Localization: `easy_localization`**
  - _Why:_ Simplifies English and Vietnamese multi-language support with JSON translation files and easy-to-use context extensions.
- **Home Screen Widgets: `home_widget`**
  - _Why:_ Essential for creating native Android (AppWidget) and iOS/iPadOS (WidgetKit) widgets for "Today's subjects" and "Deadlines".
- **Routing: `go_router`**
  - _Why:_ Official declarative routing package, essential for deep linking and navigating between authentication and home screens smoothly.

Support Android 13+ and iOS 16+ to cover a wide user base.

## 3. Feature Implementation Strategy

### 3.1. Authentication & Multiple Accounts

- **Storage:** Use `flutter_secure_storage` to keep a secure list of user sessions. Each session contains a username, user profile info, and access/refresh tokens.
- **JWT Auto-Refresh:** Implement a `Dio` Interceptor. When an API call returns a `401 Unauthorized` (indicating the 30-day token expired), the interceptor will pause the request queue, call the login/refresh endpoint in the background, update the stored JWT, and seamlessly retry the failed request without bothering the user.

### 3.2. Caching & Preloading (Enhancing UX)

- **Riverpod Caching:** Use Riverpod's `keepAlive` features to cache API responses in memory during a session.
- **Offline First:** When fetching subjects or deadlines, store the JSON payload in `hive`. Upon app launch, immediately display the cached data (preload) while silently fetching updates from the server in the background. This creates a "zero-loading-screen" experience.

### 3.3. Home Screen Widgets (Today's Subjects & Deadlines)

- **Mechanism:** When the app fetches the latest timetable/deadlines, it serializes the data and writes it to a shared native group container (iOS App Group / Android SharedPreferences) using the `home_widget` package.
- **Native Code:** Small native Kotlin (Android) and Swift (iOS) widgets will read this shared data to render the UI on the home screen without needing to boot up the entire Flutter engine.

### 3.4. Notifications Search & Filter

- Load notifications via Dio, and manage the state via Riverpod.
- Implement a local search feature using a `StateProvider` for the search query. Apply a `.where()` filter on the cached list of notifications to provide instant, zero-latency search results.

### 3.5. Multi-Language Support (VI / EN)

- Define `assets/translations/en.json` and `assets/translations/vi.json`.
- Wrap the app in an `EasyLocalization` provider, allowing users to switch languages via settings seamlessly without restarting the app.

### 3.6. Clean UI & Native Feel

- **Material Design 3:** Enable `useMaterial3: true` in `ThemeData`. Use native-feeling bottom navigation bars, rounded cards, and smooth page transitions.
- **Select & Copy:** Wrap text content that users might want to copy (e.g., student IDs, course codes, notification details) in a `SelectionArea` widget. This provides the standard native long-press to select and copy behavior across the entire app.

## 4. Proposed Folder Structure

A feature-first (layer-based inside features) approach for high maintainability:

```text
lib/
├── core/
│   ├── network/         # Dio client, JWT Refresh Interceptor
│   ├── theme/           # Material 3 Themes, Colors, Typography
│   ├── storage/         # Secure storage and Hive setup
│   └── utils/           # Helper functions, constants
├── features/
│   ├── auth/            # Login UI, Multiple Accounts Management
│   ├── timetable/       # Subjects, Schedules UI & Logic
│   ├── deadlines/       # Assignments, Deadlines UI & Logic
│   └── notifications/   # List, Search, Filter UI & Logic
├── shared/              # Reusable widgets (Custom Buttons, Loaders)
└── main.dart
```

## 5. Next Steps for Development

1. Run `flutter create uit_mobile`.
2. Add the selected dependencies to `pubspec.yaml`.
3. Setup the basic routing (`go_router`) and Material 3 theme.
4. Implement the core network layer (Dio + JWT Interceptor) and test it.
5. Scaffold the authentication and multiple accounts flow.
