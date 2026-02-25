import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Screen showing all HT2/TTTN/KLTN classes.
///
/// These classes have dynamic schedules (no fixed day/period) and are grouped
/// separately from the regular timetable. Their meeting times are specified
/// in [Course.ht2Schedule].
class HT2Screen extends ConsumerWidget {
  const HT2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('timetable.ht2Title'.tr())),
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
          // Find the HT2 group — it has name "HT2/TTTN/KLTN" or contains
          // courses with teachingFormat == 'HT2'.
          final ht2Courses = <Course>[];
          for (final dayGroup in semesters) {
            for (final course in dayGroup.courses) {
              if (course.isHT2) {
                ht2Courses.add(course);
              }
            }
          }

          if (ht2Courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'timetable.noHt2Courses'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return SelectionArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ht2Courses.length,
              itemBuilder: (context, index) =>
                  _HT2CourseTile(course: ht2Courses[index]),
            ),
          );
        },
      ),
    );
  }
}

class _HT2CourseTile extends StatelessWidget {
  final Course course;

  const _HT2CourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final credits = course.totalCredits ?? course.credits;
    final format = course.format ?? TeachingFormat.ht2;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: class code + teaching format badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.classCode,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (course.subjectName != null &&
                          course.subjectName!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          course.subjectName!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: format.badgeColor(cs),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    format.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: format.badgeTextColor(cs),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Credits and department
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _InfoChip(
                  icon: Icons.school_outlined,
                  label: '$credits TC',
                  theme: theme,
                ),
                _InfoChip(
                  icon: Icons.business_outlined,
                  label: course.department,
                  theme: theme,
                ),
                if (course.startDate != null && course.endDate != null)
                  _InfoChip(
                    icon: Icons.date_range_outlined,
                    label: '${course.startDate} - ${course.endDate}',
                    theme: theme,
                  ),
              ],
            ),

            // Lecturers
            if (course.lecturers.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...course.lecturers.map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: cs.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${l.name} (${l.email})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // HT2 meeting schedule
            if (course.ht2Schedule != null &&
                course.ht2Schedule!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 16,
                          color: cs.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'timetable.ht2MeetingSchedule'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.ht2Schedule!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (course.isHT2) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: cs.outline),
                  const SizedBox(width: 6),
                  Text(
                    'timetable.ht2NoScheduleYet'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
