import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Score classification thresholds (Vietnamese grading system).
/// - Gioi (Excellent): 8.5 - 10
/// - Kha (Good): 7.0 - 8.4
/// - Trung binh (Average): 5.5 - 6.9
/// - Yeu/Kem (Weak/Poor): < 5.5

/// Returns the foreground color for a numeric grade.
Color _scoreColor(ThemeData theme, double? grade) {
  if (grade == null || grade < 0) return theme.colorScheme.outline;
  if (grade >= 8.5) return theme.colorScheme.primary; // Gioi
  if (grade >= 7.0) return theme.colorScheme.secondary; // Kha
  if (grade >= 5.5) return theme.colorScheme.tertiary; // Trung binh
  return theme.colorScheme.error; // Yeu/Kem
}

/// Returns a background color (low opacity) for a numeric grade.
Color _scoreColorBg(ThemeData theme, double? grade) {
  return _scoreColor(theme, grade).withValues(alpha: 0.12);
}

/// Calculate credit-weighted GPA for a list of scores.
/// Excludes exempted courses (all weights=0, e.g. "Mien") and courses with
/// non-numeric grades. Returns (gpa, totalCredits) or null if no valid scores.
({double gpa, int totalCredits})? _calculateGpa(List<Score> scores) {
  double weightedSum = 0;
  int totalCredits = 0;

  for (final score in scores) {
    if (!score.countsForGpa) continue;
    final grade = double.parse(score.finalGrade!);
    final credits = int.parse(score.credits);
    weightedSum += grade * credits;
    totalCredits += credits;
  }

  if (totalCredits == 0) return null;
  return (gpa: weightedSum / totalCredits, totalCredits: totalCredits);
}

/// Displays student scores grouped by semester with GPA calculations.
class ScoresScreen extends ConsumerWidget {
  const ScoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(scoresProvider);

    return Scaffold(
      appBar: AppBar(title: Text('scores.title'.tr())),
      body: scoresAsync.when(
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
            return Center(child: Text('scores.noScores'.tr()));
          }

          // Calculate overall GPA across all semesters.
          final allScores = semesters.expand((s) => s.scores).toList();
          final overallGpa = _calculateGpa(allScores);

          return SelectionArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              // +1 for the overall GPA card at the top.
              itemCount: semesters.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _OverallGpaCard(gpaResult: overallGpa);
                }
                // Show most recent first.
                final semIndex = semesters.length - index;
                final semester = semesters[semIndex];
                return _SemesterScoreCard(semester: semester);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Card showing the overall GPA summary at the top.
class _OverallGpaCard extends StatelessWidget {
  final ({double gpa, int totalCredits})? gpaResult;

  const _OverallGpaCard({required this.gpaResult});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'scores.overallGpa'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (gpaResult != null)
                    Text(
                      '${gpaResult!.totalCredits} ${'scores.totalCredits'.tr().toLowerCase()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _scoreColor(theme, gpaResult?.gpa),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                gpaResult != null ? gpaResult!.gpa.toStringAsFixed(2) : '-',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterScoreCard extends StatelessWidget {
  final ScoreSemester semester;

  const _SemesterScoreCard({required this.semester});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semGpa = _calculateGpa(semester.scores);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(
          context,
        ).copyWith(dividerTheme: const DividerThemeData(space: 0)),
        child: ExpansionTile(
          initiallyExpanded: false,
          title: Text(
            semester.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                'scores.subjectCount'.tr(args: ['${semester.scores.length}']),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              if (semGpa != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: _scoreColorBg(theme, semGpa.gpa),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${semGpa.gpa.toStringAsFixed(2)} · ${semGpa.totalCredits} tc',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _scoreColor(theme, semGpa.gpa),
                    ),
                  ),
                ),
              ],
            ],
          ),
          children: [
            ...semester.scores.map((score) => _ScoreDetailTile(score: score)),
          ],
        ),
      ),
    );
  }
}

/// Each subject is an expandable tile: summary row on top, detail table below.
class _ScoreDetailTile extends StatelessWidget {
  final Score score;

  const _ScoreDetailTile({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExempted = score.isExempted;
    final displayGrade = isExempted ? 'Mien' : (score.finalGrade ?? '-');
    final gradeNum = double.tryParse(score.finalGrade ?? '');

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(dividerTheme: const DividerThemeData(space: 0)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isExempted
                ? theme.colorScheme.tertiary.withValues(alpha: 0.12)
                : _scoreColorBg(theme, gradeNum),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayGrade,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isExempted ? 10 : null,
              color: isExempted
                  ? theme.colorScheme.tertiary
                  : _scoreColor(theme, gradeNum),
            ),
          ),
        ),
        title: Text(
          score.subjectName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${score.subjectCode} · ${score.credits} ${'scores.credits'.tr()}${score.subjectType.isNotEmpty ? ' · ${score.subjectType}' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        children: [
          if (isExempted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'scores.exempted'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            _ScoreTable(score: score, theme: theme),
        ],
      ),
    );
  }
}

/// A compact table showing all score components.
class _ScoreTable extends StatelessWidget {
  final Score score;
  final ThemeData theme;

  const _ScoreTable({required this.score, required this.theme});

  @override
  Widget build(BuildContext context) {
    // Build rows for each non-empty component
    final rows = <_ScoreComponentRow>[];

    _addRow(rows, 'scores.component1'.tr(), score.grade1, score.weight1);
    _addRow(rows, 'scores.component2'.tr(), score.grade2, score.weight2);
    _addRow(rows, 'scores.component3'.tr(), score.grade3, score.weight3);
    _addRow(rows, 'scores.component4'.tr(), score.grade4, score.weight4);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'scores.component'.tr(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'scores.grade'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'scores.weight'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Component rows
          ...rows.map((r) => _buildRow(r)),
          // Final grade row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'scores.final'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    score.finalGrade ?? '-',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _scoreColor(
                        theme,
                        double.tryParse(score.finalGrade ?? ''),
                      ),
                    ),
                  ),
                ),
                const Expanded(flex: 2, child: SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addRow(
    List<_ScoreComponentRow> rows,
    String label,
    String? grade,
    String weight,
  ) {
    final w = double.tryParse(weight) ?? 0;
    // Only show components that have a non-zero weight
    if (w > 0) {
      rows.add(
        _ScoreComponentRow(
          label: label,
          grade: grade ?? '-',
          weight: '${(w * 100).round()}%',
        ),
      );
    }
  }

  Widget _buildRow(_ScoreComponentRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(row.label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.grade,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _scoreColor(
                  theme,
                  double.tryParse(row.grade == '-' ? '' : row.grade),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.weight,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreComponentRow {
  final String label;
  final String grade;
  final String weight;

  const _ScoreComponentRow({
    required this.label,
    required this.grade,
    required this.weight,
  });
}
