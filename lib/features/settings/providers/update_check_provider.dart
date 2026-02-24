import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Keep in sync with the constant in settings_screen.dart.
// x-release-please-version
const _kCurrentAppVersion = 'v1.0.1';

const _kGithubReleasesUrl =
    'https://api.github.com/repos/KevinNitroG/uit_mobile/releases/latest';

/// Result of an update check.
sealed class UpdateCheckResult {
  const UpdateCheckResult();
}

/// The app is up to date.
class UpdateCheckUpToDate extends UpdateCheckResult {
  const UpdateCheckUpToDate();
}

/// A newer version is available.
class UpdateCheckUpdateAvailable extends UpdateCheckResult {
  const UpdateCheckUpdateAvailable({required this.latestVersion});
  final String latestVersion;
}

/// The check failed (network error, parse error, etc.).
class UpdateCheckFailed extends UpdateCheckResult {
  const UpdateCheckFailed({required this.error});
  final Object error;
}

/// Fetches the latest GitHub release tag and compares it to [currentVersion].
/// Returns an [UpdateCheckResult] — never throws.
final updateCheckProvider =
    AsyncNotifierProvider<UpdateCheckNotifier, UpdateCheckResult>(
      UpdateCheckNotifier.new,
    );

class UpdateCheckNotifier extends AsyncNotifier<UpdateCheckResult> {
  @override
  Future<UpdateCheckResult> build() async {
    return _check();
  }

  Future<UpdateCheckResult> _check() async {
    try {
      // Use a plain, unauthenticated Dio instance — not the UIT one.
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/vnd.github+json'},
        ),
      );

      final response = await dio.get<Map<String, dynamic>>(_kGithubReleasesUrl);

      final tagName = response.data?['tag_name'] as String?;
      if (tagName == null) {
        return const UpdateCheckFailed(error: 'Missing tag_name in response');
      }

      return isNewerVersion(_kCurrentAppVersion, tagName)
          ? UpdateCheckUpdateAvailable(latestVersion: tagName)
          : const UpdateCheckUpToDate();
    } catch (e) {
      return UpdateCheckFailed(error: e);
    }
  }

  /// Re-run the update check manually (e.g. user taps "Check for updates").
  Future<void> recheck() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_check);
  }
}

/// Helper that compares two semver strings of the form "vX.Y.Z".
/// Returns `true` if [latest] is strictly newer than [current].
bool isNewerVersion(String current, String latest) {
  final c = _parse(current);
  final l = _parse(latest);
  if (c == null || l == null) return false;
  if (l.$1 != c.$1) return l.$1 > c.$1;
  if (l.$2 != c.$2) return l.$2 > c.$2;
  return l.$3 > c.$3;
}

(int, int, int)? _parse(String version) {
  final clean = version.startsWith('v') ? version.substring(1) : version;
  final parts = clean.split('.');
  if (parts.length != 3) return null;
  final nums = parts.map(int.tryParse).toList();
  if (nums.any((n) => n == null)) return null;
  return (nums[0]!, nums[1]!, nums[2]!);
}
