import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/core/network/api_service.dart';
import 'package:uit_mobile/core/storage/hive_cache_service.dart';
import 'package:uit_mobile/core/storage/home_widget_service.dart';
import 'package:uit_mobile/features/auth/providers/auth_provider.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Provider that fetches and caches the full student data.
/// Other feature providers derive from this to avoid duplicate API calls.
final studentDataProvider =
    AsyncNotifierProvider<StudentDataNotifier, StudentData>(
      StudentDataNotifier.new,
    );

class StudentDataNotifier extends AsyncNotifier<StudentData> {
  /// When true the next [build] skips the Hive cache and fetches from the
  /// network directly.  Set by [forceRefresh] (called from the accounts screen
  /// after switching accounts) so that stale data left behind by a concurrent
  /// background refresh from the previous account is never served.
  bool _skipCache = false;

  /// Marks this provider so the next build bypasses cache.
  void forceRefresh() {
    _skipCache = true;
    ref.invalidateSelf();
  }

  /// Push data to native home screen widgets.
  Future<void> _updateHomeWidgets(StudentData data) async {
    try {
      final semesters = data.coursesRaw
          .map((e) => Semester.fromJson(e as Map<String, dynamic>))
          .toList();
      final deadlines = data.deadlineRaw
          .map((e) => Deadline.fromJson(e as Map<String, dynamic>))
          .toList();
      await HomeWidgetService.updateWidgets(
        semesters: semesters,
        deadlines: deadlines,
      );
    } catch (_) {
      // Widget update is best-effort; don't block the main flow.
    }
  }

  @override
  Future<StudentData> build() async {
    // Watch the auth state so this provider automatically re-runs whenever the
    // active account changes (login, switchAccount, logout).
    final authState = ref.watch(authProvider);
    if (authState is! AuthAuthenticated) {
      // Not logged in — return empty data rather than fetching.
      return const StudentData(
        coursesRaw: [],
        scoresRaw: [],
        feeRaw: [],
        notifyRaw: [],
        deadlineRaw: [],
        examsRaw: {},
      );
    }

    // Use a local variable captured by the background refresh closure so each
    // invocation of build() has its own disposal flag. An instance field would
    // be shared across rebuilds and could be reset to false by a newer build()
    // before the old background task checks it, allowing stale data through.
    var disposed = false;
    ref.onDispose(() => disposed = true);

    final cache = ref.read(hiveCacheServiceProvider);
    final api = ref.read(uitApiServiceProvider);

    // If a force-refresh was requested (e.g. after account switch), skip cache
    // entirely to avoid serving stale data that a concurrent background refresh
    // from the previous account may have written back.
    final shouldSkipCache = _skipCache;
    _skipCache = false; // reset for future builds

    // Try cache first (unless bypassed).
    final cachedCourses = shouldSkipCache ? null : cache.getCachedCourses();
    if (cachedCourses != null) {
      // Return cached immediately, then refresh in background.
      final cached = StudentData(
        coursesRaw: cachedCourses,
        scoresRaw: cache.getCachedScores() ?? [],
        feeRaw: [],
        notifyRaw: cache.getCachedNotifications() ?? [],
        deadlineRaw: cache.getCachedDeadlines() ?? [],
        examsRaw: cache.getCachedExams() ?? {},
      );

      // Update widgets with cached data immediately.
      _updateHomeWidgets(cached);

      // Fire-and-forget background refresh.
      // Guard with [disposed] to prevent a stale fetch (e.g. from a previous
      // account) from overwriting the cache or provider state after an account
      // switch.  We intentionally skip the cache write entirely if the provider
      // was invalidated to close the race window where _clearCache() runs
      // between the disposed check and the cache.cacheStudentData() await.
      Future(() async {
        try {
          final fresh = await api.getStudentData();
          if (disposed) return; // Provider was invalidated; discard result.
          state = AsyncData(fresh);
          // Only persist to cache if still valid — this is a best-effort
          // optimisation for the next cold start.
          if (!disposed) {
            cache.cacheStudentData(fresh.toJson()); // fire-and-forget
          }
          _updateHomeWidgets(fresh);
        } catch (_) {
          // Keep cached data if refresh fails.
        }
      });

      return cached;
    }

    // No cache: fetch from network.
    final data = await api.getStudentData();
    await cache.cacheStudentData(data.toJson());
    await _updateHomeWidgets(data);
    return data;
  }

  /// Force a fresh fetch from the network.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(uitApiServiceProvider);
      final cache = ref.read(hiveCacheServiceProvider);
      final data = await api.getStudentData();
      await cache.cacheStudentData(data.toJson());
      await _updateHomeWidgets(data);
      return data;
    });
  }
}

/// Derived provider: parsed semesters of courses.
final coursesProvider = FutureProvider<List<Semester>>((ref) async {
  final data = await ref.watch(studentDataProvider.future);
  return data.coursesRaw
      .map((e) => Semester.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Derived provider: parsed semesters of scores.
final scoresProvider = FutureProvider<List<ScoreSemester>>((ref) async {
  final data = await ref.watch(studentDataProvider.future);
  return data.scoresRaw
      .map((e) => ScoreSemester.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Derived provider: parsed fee records.
final feesProvider = FutureProvider<List<Fee>>((ref) async {
  final data = await ref.watch(studentDataProvider.future);
  return data.feeRaw
      .map((e) => Fee.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Derived provider: parsed notifications.
final notificationsProvider = FutureProvider<List<UitNotification>>((
  ref,
) async {
  final data = await ref.watch(studentDataProvider.future);
  return data.notifyRaw
      .map((e) => UitNotification.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Derived provider: parsed deadlines.
final deadlinesProvider = FutureProvider<List<Deadline>>((ref) async {
  final data = await ref.watch(studentDataProvider.future);
  return data.deadlineRaw
      .map((e) => Deadline.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Derived provider: parsed exam schedule entries.
final examsProvider = FutureProvider<List<Exam>>((ref) async {
  final data = await ref.watch(studentDataProvider.future);
  return Exam.listFromJson(data.examsRaw);
});

/// User info provider.
final userInfoProvider = FutureProvider<UserInfo>((ref) async {
  // Watch auth state so this provider re-runs on account switch.
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) {
    return const UserInfo(
      name: '',
      sid: '',
      mail: '',
      status: '',
      course: '',
      major: '',
      dob: '',
      role: '',
      className: '',
      address: '',
      avatar: '',
    );
  }

  final api = ref.read(uitApiServiceProvider);
  final cache = ref.read(hiveCacheServiceProvider);

  // Track whether this provider instance has been disposed/invalidated so we
  // can guard the fire-and-forget background refresh against writing stale data
  // from a previous account.
  var disposed = false;
  ref.onDispose(() => disposed = true);

  // Check cache first.
  final cached = cache.getCachedUserInfo();
  if (cached != null) {
    // Refresh in background and invalidate so UI sees the update.
    Future(() async {
      try {
        final fresh = await api.getUserInfo();
        if (disposed) return; // Provider was invalidated; discard result.
        // Persist to cache only if still valid — fire-and-forget so the await
        // gap doesn't create a race with _clearCache during account switch.
        if (!disposed) {
          cache.cacheUserInfo(fresh.toJson()); // fire-and-forget
        }
        if (!disposed) ref.invalidateSelf();
      } catch (_) {}
    });
    return UserInfo.fromJson(cached);
  }

  final info = await api.getUserInfo();
  await cache.cacheUserInfo(info.toJson());
  return info;
});
