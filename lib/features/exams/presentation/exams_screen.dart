import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Sort order for exams.
enum ExamSortOrder { asc, desc }

/// Current sort order state. Default: descending (newest first).
final examSortOrderProvider =
    NotifierProvider<_ExamSortOrderNotifier, ExamSortOrder>(
      _ExamSortOrderNotifier.new,
    );

class _ExamSortOrderNotifier extends Notifier<ExamSortOrder> {
  @override
  ExamSortOrder build() => ExamSortOrder.desc;

  void toggle() {
    state = state == ExamSortOrder.asc ? ExamSortOrder.desc : ExamSortOrder.asc;
  }
}

/// Sorted exams based on selected sort order.
final sortedExamsProvider = FutureProvider<List<Exam>>((ref) async {
  final exams = await ref.watch(examsProvider.future);
  final sortOrder = ref.watch(examSortOrderProvider);

  final sorted = List<Exam>.from(exams);
  sorted.sort((a, b) {
    final dateA = _parseExamDate(a.date);
    final dateB = _parseExamDate(b.date);
    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    return sortOrder == ExamSortOrder.asc
        ? dateA.compareTo(dateB)
        : dateB.compareTo(dateA);
  });
  return sorted;
});

/// Try multiple date formats the API might return.
DateTime? _parseExamDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  // Common formats: "dd/MM/yyyy", "dd-MM-yyyy", "yyyy-MM-dd"
  for (final fmt in ['dd/MM/yyyy', 'dd-MM-yyyy', 'yyyy-MM-dd']) {
    try {
      return DateFormat(fmt).parseStrict(dateStr);
    } catch (_) {}
  }
  // Fallback: try standard parse
  return DateTime.tryParse(dateStr);
}

/// Temporal category for an exam relative to today.
enum _ExamTimeCategory { past, current, future }

/// Determine whether an exam is past, current (today), or future.
_ExamTimeCategory _examTimeCategory(Exam exam) {
  final examDate = _parseExamDate(exam.date);
  if (examDate == null) return _ExamTimeCategory.future;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final examDay = DateTime(examDate.year, examDate.month, examDate.day);
  if (examDay.isBefore(today)) return _ExamTimeCategory.past;
  if (examDay.isAtSameMomentAs(today)) return _ExamTimeCategory.current;
  return _ExamTimeCategory.future;
}

/// Displays the exam schedule fetched from the student data API.
class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(sortedExamsProvider);
    final sortOrder = ref.watch(examSortOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('exams.title'.tr()),
        actions: [
          IconButton(
            icon: Icon(
              sortOrder == ExamSortOrder.desc
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
            tooltip: sortOrder == ExamSortOrder.desc
                ? 'exams.sortAsc'.tr()
                : 'exams.sortDesc'.tr(),
            onPressed: () => ref.read(examSortOrderProvider.notifier).toggle(),
          ),
        ],
      ),
      body: examsAsync.when(
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
        data: (exams) {
          if (exams.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'exams.noExams'.tr(),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: exams.length,
              itemBuilder: (context, index) => _ExamCard(exam: exams[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = _examTimeCategory(exam);

    // Determine card colors and border based on temporal category.
    final Color cardColor;
    final Color? borderColor;
    switch (category) {
      case _ExamTimeCategory.past:
        cardColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
        borderColor = null;
      case _ExamTimeCategory.current:
        cardColor = theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3);
        borderColor = theme.colorScheme.tertiary;
      case _ExamTimeCategory.future:
        cardColor = theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3);
        borderColor = null;
    }

    // Build the date/time/room info chips.
    final infoParts = <String>[
      if (exam.date != null) exam.date!,
      if (exam.time != null) exam.time!,
      if (exam.room != null) '${'exams.room'.tr()}: ${exam.room}',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cardColor,
      shape: borderColor != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject name + subject code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    exam.subjectName ?? exam.classCode,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (exam.subjectCode != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    exam.subjectCode!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),

            // Date · Time · Room
            if (infoParts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                infoParts.join('  ·  '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
