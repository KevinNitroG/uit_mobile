import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/core/network/api_service.dart';
import 'package:uit_mobile/core/storage/hive_cache_service.dart';
import 'package:uit_mobile/core/storage/home_widget_service.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Provider that fetches and caches the full student data.
/// Other feature providers derive from this to avoid duplicate API calls.
final studentDataProvider =
    AsyncNotifierProvider<StudentDataNotifier, StudentData>(
      StudentDataNotifier.new,
    );

class StudentDataNotifier extends AsyncNotifier<StudentData> {
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
    final cache = ref.read(hiveCacheServiceProvider);
    final api = ref.read(uitApiServiceProvider);

    // Try cache first.
    final cachedCourses = cache.getCachedCourses();
    if (cachedCourses != null) {
      // Return cached immediately, then refresh in background.
      final cached = StudentData(
        coursesRaw: cachedCourses,
        scoresRaw: cache.getCachedScores() ?? [],
        feeRaw: [],
        notifyRaw: cache.getCachedNotifications() ?? [],
        deadlineRaw: cache.getCachedDeadlines() ?? [],
        examsRaw: {},
      );

      // Update widgets with cached data immediately.
      _updateHomeWidgets(cached);

      // Fire-and-forget background refresh.
      Future(() async {
        try {
          final fresh = await api.getStudentData();
          await cache.cacheStudentData(fresh.toJson());
          state = AsyncData(fresh);
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

/// User info provider.
final userInfoProvider = FutureProvider<UserInfo>((ref) async {
  final api = ref.read(uitApiServiceProvider);
  final cache = ref.read(hiveCacheServiceProvider);

  // Check cache first.
  final cached = cache.getCachedUserInfo();
  if (cached != null) {
    // Refresh in background and invalidate so UI sees the update.
    Future(() async {
      try {
        final fresh = await api.getUserInfo();
        await cache.cacheUserInfo(fresh.toJson());
        ref.invalidateSelf();
      } catch (_) {}
    });
    return UserInfo.fromJson(cached);
  }

  final info = await api.getUserInfo();
  await cache.cacheUserInfo(info.toJson());
  return info;
});
