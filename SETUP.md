# UIT Mobile - Setup & Deployment Guide

## Prerequisites

### System Requirements
- **OS**: macOS (for iOS), Linux/Windows (for Android only)
- **Flutter**: 3.x (stable)
- **Dart**: 3.11.0+
- **Android**: SDK 36, NDK 27.2.12479018, Java 17
- **iOS**: Xcode 15.0+, iOS SDK 16.0+

### Tools Installation

```bash
# Install Flutter (if not already installed)
# https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor

# Clone project
git clone https://github.com/KevinNitroG/uit_mobile.git
cd uit-mobile

# Get dependencies
flutter pub get
```

---

## Project Setup

### 1. Configure Local Environment

**Android** (`android/app/build.gradle.kts`):
- `compileSdk = 36`
- `minSdk = 33` (Android 13+)
- `targetSdk = 36`
- `ndkVersion = "27.2.12479018"`
- `sourceCompatibility = JavaVersion.VERSION_17`

**iOS** (`ios/Runner/Info.plist`):
- `CFBundleIdentifier`: `com.kevinnitro.uitMobile` (set dynamically in Xcode)
- Minimum deployment target: iOS 16.0

### 2. Dart/Flutter Setup

```bash
# Install all dependencies
flutter pub get

# Generate code (Riverpod AsyncNotifier providers, JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Check for linting issues
flutter analyze --no-fatal-infos
```

### 3. App Signing (Production Only)

**Android**:
```bash
# Generate keystore (one-time)
keytool -genkey -v -keystore ~/key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Configure signing in android/key.properties:
# storeFile=~/key.jks
# storePassword=YOUR_PASSWORD
# keyAlias=upload
# keyPassword=YOUR_PASSWORD
```

**iOS**:
```bash
# Use Xcode to manage signing certificates & provisioning profiles
# Open ios/Runner.xcworkspace
# Go to Runner project → Signing & Capabilities
# Select team and provisioning profile
```

---

## Building & Running

### Debug Build (Development)

**Android** (on connected device):
```bash
flutter run -d <device_id>  # or -d emulator-5554
```

**Build APK**:
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

**Manual install**:
```bash
adb -s <device_id> install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s <device_id> shell am start -n com.kevinnitro.uit_mobile/.MainActivity
```

**iOS** (on simulator or physical device):
```bash
# Simulator (default)
flutter run

# Physical device
flutter run -d <ios_device_id>

# Build IPA (unsigned)
flutter build ipa --release --no-codesign
# Output: build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app
```

### Release Build (Production)

**Android** (signed APK):
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

**Android** (AAB for Play Store):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS** (IPA for App Store):
```bash
flutter build ipa --release
# Output: build/ios/archive/Runner.xcarchive

# Upload to App Store Connect via Xcode Organizer or transporter
```

---

## Testing

### Static Analysis
```bash
flutter analyze --no-fatal-infos
# Expected: 0 errors, ≤ 1 info (unnecessary_underscores in period_info_screen)
```

### Manual Testing Checklist

- [ ] Login with valid UIT credentials
- [ ] Multi-account add/switch/remove
- [ ] Home screen displays user info + quick stats
- [ ] Timetable shows today's courses (auto-selected day tab)
- [ ] Period info shows all 10 UIT periods
- [ ] Deadlines filter chips work (All/Pending/Finished/Overdue)
- [ ] Scores show correct GPA (overall + per-semester), exempted courses display "Miễn"
- [ ] Notifications can be searched/filtered
- [ ] Language switching (EN/VI) persists
- [ ] Logout with confirmation works
- [ ] Refresh from home screen refetches data
- [ ] Dark theme toggles correctly
- [ ] Home screen widgets display data
- [ ] Offline mode: cache data loads without internet

---

## CI/CD Pipeline

### GitHub Actions Workflows

**`release-please.yml`**:
- Runs on: `push` to `main`
- Action: Creates Release PR with bumped version (`pubspec.yaml`) + CHANGELOG
- Triggers: `build.yml` on release creation

**`build.yml`**:
- Runs on: `push` (to `lib/`, `assets/`, `android/`, `ios/`), `workflow_dispatch`, or called from `release-please.yml`
- Jobs:
  1. **analyze**: `flutter analyze --no-fatal-infos`
  2. **build-apk** (matrix: arm64, armv7, x86_64): `flutter build apk --release`
  3. **build-ipa**: `flutter build ipa --release --no-codesign`
- Output: Artifacts uploaded to GitHub Actions

### Conventional Commits

To trigger version bumps:
```bash
# Feature (minor bump: 0.1.0 → 0.2.0)
git commit -m "feat: add feature name"

# Bug fix (patch bump: 0.1.0 → 0.1.1)
git commit -m "fix: fix description"

# Docs, chore, test (no bump, hidden in changelog)
git commit -m "docs: update README"
git commit -m "chore: update dependencies"
git commit -m "test: add unit tests"
```

### Release Process

1. Merge feature branches to `main` with conventional commits
2. GitHub Action creates "Release PR" auto-magically
3. Review Release PR → merge to `main`
4. GitHub creates Release + git tag (e.g., `v0.2.0`)
5. `build.yml` builds APK/IPA (optional artifact upload)
6. Deploy manually to app stores

---

## Configuration Files

### `pubspec.yaml`

```yaml
name: uit_mobile
version: 0.1.0+1

environment:
  sdk: ^3.11.0

dependencies:
  # ... (see full pubspec.yaml)

flutter:
  uses-material-design: true
  assets:
    - assets/translations/
    - assets/images/
```

### `release-please-config.json`

```json
{
  "packages": {
    ".": {
      "release-type": "dart",
      "include-component-in-tag": false
    }
  }
}
```

### `.release-please-manifest.json`

```json
{
  ".": "0.1.0"
}
```

---

## Troubleshooting

### Build Errors

**Java 25 Gradle error**:
- Issue: `IllegalArgumentException: 25.0.2` (Gradle 8.14 doesn't support Java 25)
- Fix: Install Java 17 or 21, set `JAVA_HOME=/path/to/java17`
- Note: Build succeeds despite warning

**Flutter dependencies conflict**:
```bash
flutter pub get
flutter pub upgrade --major-versions
flutter pub run build_runner build --delete-conflicting-outputs
```

**iOS pod issues**:
```bash
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
```

### Device Connection

**Android device not recognized**:
```bash
adb devices
adb kill-server && adb start-server
adb -s <device_id> shell am start -n com.kevinnitro.uit_mobile/.MainActivity
```

**iOS simulator lagging**:
```bash
xcrun simctl erase all  # Reset all simulators
flutter run -d iPhone\ 15  # Specify device
```

### API Authentication

**401 Unauthorized**:
- Check credentials (Student ID + password)
- Verify encoding is correct: `base64("3sn@fah.{id}:{password}")`
- Check JWT refresh in interceptor logs

**API data parsing error**:
- API returns unexpected field types (e.g., `name` as `int` instead of `String`)
- Models handle both with `int.tryParse()` fallback
- Check `uit.md` for schema details

---

## Performance Tips

- Use **Hive cache** for offline data access (cache-first strategy)
- **Riverpod AsyncNotifier** handles async loading states automatically
- **HomeWidgetService** serializes data once per refresh
- **DividerThemeData** reduces ExpansionTile divider overhead
- **SelectionArea** wraps content for text selection (minimal perf impact)

---

## Useful Commands

```bash
# Clear everything
flutter clean
rm -rf build/ .dart_tool/ pubspec.lock
flutter pub get

# Run on specific device
flutter run -d <device_id>

# Build APK split by architecture (smaller downloads)
flutter build apk --release --split-per-abi

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Format code
flutter format lib/

# Hot reload (preserve state)
r  # In flutter run console

# Hot restart (reset state)
R  # In flutter run console

# Get device list
flutter devices
adb devices  # Android
xcrun simctl list  # iOS simulators
```

---

## Next Steps

1. **App Store Submission**:
   - Add app privacy policy (required by stores)
   - Create app store listings (description, screenshots, etc)
   - Submit IPA to App Store Connect
   - Submit APK/AAB to Google Play Console

2. **Feature Development**:
   - Push notifications (Firebase Cloud Messaging)
   - Grade analytics/predictions
   - Export timetable (iCal format)
   - Advanced filtering/search

3. **Monitoring**:
   - Crash reporting (Firebase Crashlytics)
   - Analytics (Firebase Analytics)
   - Error tracking (Sentry, etc)

---

## Support

For issues or questions:
- Check `ARCHITECTURE.md` for project structure
- Review `PLAN.md` for feature implementation details
- See `uit.md` for API documentation
- Contact KevinNitroG
