import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// App Group ID for iOS widget data sharing.
const String kAppGroupId = 'group.com.kevinnitro.uitMobile';

/// Android widget provider class names.
const String kAndroidTimetableWidget =
    'com.kevinnitro.uit_mobile.TimetableWidgetProvider';
const String kAndroidDeadlinesWidget =
    'com.kevinnitro.uit_mobile.DeadlinesWidgetProvider';

/// Keys for the shared data store.
abstract final class WidgetDataKeys {
  static const String todayCourses = 'today_courses';
  static const String upcomingDeadlines = 'upcoming_deadlines';
  static const String lastUpdated = 'last_updated';
}

/// Service that pushes timetable/deadline data to native home screen widgets.
class HomeWidgetService {
  HomeWidgetService._();

  /// Initialize home_widget with the App Group ID (required for iOS).
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(kAppGroupId);
  }

  /// Filter courses for today by finding the day group whose name matches
  /// today's UIT day code.
  ///
  /// The API `courses` array has items where `name` = day number ('2'=Mon ..
  /// '8'=Sun) and `courses` = the courses for that day. So each "Semester"
  /// object is actually a single day group.
  static List<Map<String, String>> _todayCourses(List<Semester> semesters) {
    if (semesters.isEmpty) return [];

    // Dart: DateTime.now().weekday -> Mon=1 .. Sun=7.
    // UIT API: '2'=Mon, '3'=Tue, ..., '8'=Sun.
    final uitDay = (DateTime.now().weekday + 1).toString();

    // Find the day group matching today.
    final todayGroup = semesters.where((s) => s.name == uitDay).toList();
    if (todayGroup.isEmpty) return [];

    return todayGroup.first.courses
        .map(
          (c) => {
            'classCode': c.classCode,
            'room': c.room,
            'periods': c.periods,
          },
        )
        .toList();
  }

  /// Take the first [max] upcoming deadlines.
  static List<Map<String, String>> _upcomingDeadlines(
    List<Deadline> deadlines, {
    int max = 3,
  }) {
    // Filter to only unsubmitted and not-closed deadlines (pending or overdue), take first N.
    final upcoming = deadlines
        .where(
          (d) => d.submittedStatus != SubmittedStatus.submitted && !d.closed,
        )
        .take(max)
        .toList();

    return upcoming
        .map(
          (d) => {
            'name': d.name,
            'shortname': d.shortname,
            'niceDate': d.niceDate,
          },
        )
        .toList();
  }

  /// Push the latest data to native widgets.
  static Future<void> updateWidgets({
    required List<Semester> semesters,
    required List<Deadline> deadlines,
  }) async {
    final todayCourses = _todayCourses(semesters);
    final upcomingDeadlines = _upcomingDeadlines(deadlines);
    final now = DateTime.now().toIso8601String();

    // Save data as JSON strings into the shared store.
    await Future.wait([
      HomeWidget.saveWidgetData<String>(
        WidgetDataKeys.todayCourses,
        jsonEncode(todayCourses),
      ),
      HomeWidget.saveWidgetData<String>(
        WidgetDataKeys.upcomingDeadlines,
        jsonEncode(upcomingDeadlines),
      ),
      HomeWidget.saveWidgetData<String>(WidgetDataKeys.lastUpdated, now),
    ]);

    // Request native widget updates.
    await Future.wait([
      HomeWidget.updateWidget(
        androidName: kAndroidTimetableWidget,
        iOSName: 'TimetableWidget',
      ),
      HomeWidget.updateWidget(
        androidName: kAndroidDeadlinesWidget,
        iOSName: 'DeadlinesWidget',
      ),
    ]);
  }
}

/// Provider for accessing the home widget service.
final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService._();
});
