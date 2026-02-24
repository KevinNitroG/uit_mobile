import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Day labels indexed by UIT day code ('2'=Mon .. '8'=Sun).
const _dayLabels = {
  '2': 'Mon',
  '3': 'Tue',
  '4': 'Wed',
  '5': 'Thu',
  '6': 'Fri',
  '7': 'Sat',
  '8': 'Sun',
};

/// All UIT day codes in order.
const _allDays = ['2', '3', '4', '5', '6', '7', '8'];

/// Displays the weekly timetable as a tabbed day view.
class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('timetable.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'timetable.periodInfo'.tr(),
            onPressed: () => context.push('/period-info'),
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(studentDataProvider),
                child: Text('common.retry'.tr()),
              ),
            ],
          ),
        ),
        data: (semesters) {
          if (semesters.isEmpty) {
            return Center(child: Text('timetable.noCourses'.tr()));
          }

          // Build a map: day code -> list of courses.
          // Each "semester" item from the API is actually one day group
          // where `name` = day number and `courses` = courses for that day.
          final dayMap = <String, List<Course>>{};
          for (final dayGroup in semesters) {
            dayMap[dayGroup.name] = dayGroup.courses;
          }

          return _DayTabView(dayMap: dayMap);
        },
      ),
    );
  }
}

/// Tabbed view showing one day per tab with swipeable pages.
class _DayTabView extends StatefulWidget {
  final Map<String, List<Course>> dayMap;

  const _DayTabView({required this.dayMap});

  @override
  State<_DayTabView> createState() => _DayTabViewState();
}

class _DayTabViewState extends State<_DayTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Determine today's tab index.
    // Dart: DateTime.now().weekday -> Mon=1 .. Sun=7
    // UIT:  '2'=Mon .. '8'=Sun  =>  uitDay = weekday + 1
    final todayUitDay = (DateTime.now().weekday + 1).toString();
    final initialIndex = _allDays.indexOf(todayUitDay).clamp(0, 6);

    _tabController = TabController(
      length: _allDays.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: _allDays.map((day) {
            final hasClasses =
                widget.dayMap.containsKey(day) &&
                widget.dayMap[day]!.isNotEmpty;
            return Tab(
              child: Text(
                _dayLabels[day] ?? day,
                style: TextStyle(
                  fontWeight: hasClasses ? FontWeight.bold : FontWeight.normal,
                  color: hasClasses ? null : theme.colorScheme.outline,
                ),
              ),
            );
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _allDays.map((day) {
              final courses = widget.dayMap[day] ?? [];
              if (courses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.free_breakfast_outlined,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'timetable.noCourses'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _DayCoursesView(courses: courses);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// List of course cards for a single day.
class _DayCoursesView extends StatelessWidget {
  final List<Course> courses;

  const _DayCoursesView({required this.courses});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) => _CourseTile(course: courses[index]),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final Course course;

  const _CourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Period indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'timetable.period'.tr(args: [course.periods]),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.classCode,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.room,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (course.lecturerName != null &&
                      course.lecturerName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      course.lecturerName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
