import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uit_mobile/core/utils/constants.dart';

/// Provider for [HiveCacheService].
final hiveCacheServiceProvider = Provider<HiveCacheService>((ref) {
  return HiveCacheService();
});

/// Provides local caching via Hive for offline-first experience.
class HiveCacheService {
  /// Initializes Hive and opens all required boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(HiveBoxes.courses),
      Hive.openBox<String>(HiveBoxes.scores),
      Hive.openBox<String>(HiveBoxes.notifications),
      Hive.openBox<String>(HiveBoxes.deadlines),
      Hive.openBox<String>(HiveBoxes.userInfo),
      Hive.openBox<String>(HiveBoxes.exams),
      Hive.openBox<String>(HiveBoxes.fees),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Generic helpers
  // ---------------------------------------------------------------------------

  /// Caches a JSON-serializable [data] object into [boxName].
  Future<void> put(String boxName, String key, dynamic data) async {
    final box = Hive.box<String>(boxName);
    await box.put(key, jsonEncode(data));
  }

  /// Retrieves cached data from [boxName] for [key], or `null`.
  dynamic get(String boxName, String key) {
    final box = Hive.box<String>(boxName);
    final raw = box.get(key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  /// Clears an entire box.
  Future<void> clearBox(String boxName) async {
    final box = Hive.box<String>(boxName);
    await box.clear();
  }

  // ---------------------------------------------------------------------------
  // Typed accessors
  // ---------------------------------------------------------------------------

  Future<void> cacheStudentData(Map<String, dynamic> data) async {
    await put(HiveBoxes.courses, 'data', data['courses']);
    await put(HiveBoxes.scores, 'data', data['scores']);
    await put(HiveBoxes.notifications, 'data', data['notify']);
    await put(HiveBoxes.deadlines, 'data', data['deadline']);
    await put(HiveBoxes.exams, 'data', data['exams']);
    await put(HiveBoxes.fees, 'data', data['fee']);
  }

  List<dynamic>? getCachedCourses() => get(HiveBoxes.courses, 'data') as List?;

  List<dynamic>? getCachedScores() => get(HiveBoxes.scores, 'data') as List?;

  List<dynamic>? getCachedNotifications() =>
      get(HiveBoxes.notifications, 'data') as List?;

  List<dynamic>? getCachedDeadlines() =>
      get(HiveBoxes.deadlines, 'data') as List?;

  Map<String, dynamic>? getCachedExams() =>
      get(HiveBoxes.exams, 'data') as Map<String, dynamic>?;

  List<dynamic>? getCachedFees() => get(HiveBoxes.fees, 'data') as List?;

  Future<void> cacheUserInfo(Map<String, dynamic> data) async {
    await put(HiveBoxes.userInfo, 'data', data);
  }

  Map<String, dynamic>? getCachedUserInfo() =>
      get(HiveBoxes.userInfo, 'data') as Map<String, dynamic>?;
}
