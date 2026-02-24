import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

// ---------------------------------------------------------------------------
// Grade colour helpers (Vietnamese grading system)
// ---------------------------------------------------------------------------

Color _gradeColor(ThemeData theme, double? grade) {
  if (grade == null) return theme.colorScheme.outline;
  if (grade >= 8.5) return theme.colorScheme.primary;
  if (grade >= 7.0) return theme.colorScheme.secondary;
  if (grade >= 5.5) return theme.colorScheme.tertiary;
  return theme.colorScheme.error;
}

Color _gradeColorBg(ThemeData theme, double? grade) =>
    _gradeColor(theme, grade).withValues(alpha: 0.12);

// ---------------------------------------------------------------------------
// Column definitions
// ---------------------------------------------------------------------------

/// Fixed column widths.  MAMH / LOP are wider; the rest are compact.
const double _colMAMH = 64;
const double _colLOP = 110;
const double _colTC = 32;
const double _colGrade = 38; // QT, TH, GK, CK, TB

const _headers = ['MAMH', 'LOP', 'TC', 'QT', 'TH', 'GK', 'CK', 'TB'];

const _colWidths = <double>[
  _colMAMH,
  _colLOP,
  _colTC,
  _colGrade, // QT
  _colGrade, // TH
  _colGrade, // GK
  _colGrade, // CK
  _colGrade, // TB
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Tabular overview of scores grouped by semester.
///
/// Each semester is a Material 3 [Card] with:
/// - a centred, chip-style header showing the semester name,
/// - a custom fixed-layout [Table] with aligned columns,
/// - alternating row tints and a bottom-border divider between rows,
/// - a colour-coded chip for the final (TB) grade.
class GeneralScoresScreen extends ConsumerWidget {
  const GeneralScoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(scoresProvider);

    return Scaffold(
      appBar: AppBar(title: Text('scores.generalViewTitle'.tr())),
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

          return SelectionArea(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: semesters.length,
              itemBuilder: (context, index) =>
                  _SemesterCard(semester: semesters[index]),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Semester card
// ---------------------------------------------------------------------------

class _SemesterCard extends StatelessWidget {
  final ScoreSemester semester;

  const _SemesterCard({required this.semester});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Semester header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.45),
            ),
            child: Text(
              semester.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // ── Table ────────────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _ScoreTable(scores: semester.scores),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score table
// ---------------------------------------------------------------------------

class _ScoreTable extends StatelessWidget {
  final List<Score> scores;

  const _ScoreTable({required this.scores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Build TableColumnWidth map from the fixed widths list.
    final colWidths = <int, TableColumnWidth>{
      for (var i = 0; i < _colWidths.length; i++)
        i: FixedColumnWidth(_colWidths[i]),
    };

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: colWidths,
      children: [
        // Header row
        _buildHeaderRow(theme, cs),
        // Divider after header
        _buildDividerRow(cs, bold: true),
        // Data rows
        for (var i = 0; i < scores.length; i++) ...[
          _buildDataRow(theme, cs, scores[i], isEven: i.isEven),
          _buildDividerRow(cs),
        ],
      ],
    );
  }

  TableRow _buildHeaderRow(ThemeData theme, ColorScheme cs) {
    return TableRow(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      children: _headers
          .map(
            (h) => _Cell(
              child: Text(
                h,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// A zero-height row that acts as a horizontal rule.
  TableRow _buildDividerRow(ColorScheme cs, {bool bold = false}) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withValues(alpha: bold ? 0.8 : 0.4),
            width: bold ? 1.0 : 0.5,
          ),
        ),
      ),
      children: List.filled(_headers.length, const SizedBox.shrink()),
    );
  }

  TableRow _buildDataRow(
    ThemeData theme,
    ColorScheme cs,
    Score score, {
    required bool isEven,
  }) {
    final finalGrade = double.tryParse(score.finalGrade ?? '');
    final isExempted = score.isExempted;

    final rowBg = isEven
        ? Colors.transparent
        : cs.surfaceContainerLow.withValues(alpha: 0.5);

    String comp(String? grade, String weight) {
      final w = double.tryParse(weight) ?? 0;
      if (w == 0) return '';
      return grade ?? '';
    }

    return TableRow(
      decoration: BoxDecoration(color: rowBg),
      children: [
        // MAMH
        _Cell(
          child: Text(
            score.subjectCode,
            textAlign: TextAlign.left,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // LOP
        _Cell(
          child: Text(
            score.classCode,
            textAlign: TextAlign.left,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // TC
        _Cell(
          child: Text(
            score.credits,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        // QT
        _Cell(
          child: _GradeText(
            value: comp(score.grade1, score.weight1),
            theme: theme,
          ),
        ),
        // TH
        _Cell(
          child: _GradeText(
            value: comp(score.grade2, score.weight2),
            theme: theme,
          ),
        ),
        // GK
        _Cell(
          child: _GradeText(
            value: comp(score.grade3, score.weight3),
            theme: theme,
          ),
        ),
        // CK
        _Cell(
          child: _GradeText(
            value: comp(score.grade4, score.weight4),
            theme: theme,
          ),
        ),
        // TB — coloured chip
        _Cell(
          child: isExempted
              ? Center(
                  child: _GradeChip(
                    label: 'Mien',
                    fg: cs.tertiary,
                    bg: cs.tertiary.withValues(alpha: 0.12),
                    theme: theme,
                  ),
                )
              : Center(
                  child: _GradeChip(
                    label: score.finalGrade ?? '',
                    fg: _gradeColor(theme, finalGrade),
                    bg: _gradeColorBg(theme, finalGrade),
                    theme: theme,
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

/// Uniform padding wrapper for every table cell.
class _Cell extends StatelessWidget {
  final Widget child;

  const _Cell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      child: child,
    );
  }
}

/// Plain grade text centred, coloured by value.  Empty string → blank.
class _GradeText extends StatelessWidget {
  final String value;
  final ThemeData theme;

  const _GradeText({required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    final grade = double.tryParse(value);
    return Text(
      value,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: _gradeColor(theme, grade),
        fontWeight: grade != null ? FontWeight.w500 : null,
      ),
    );
  }
}

/// Compact rounded chip used for the TB (final) column.
class _GradeChip extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  final ThemeData theme;

  const _GradeChip({
    required this.label,
    required this.fg,
    required this.bg,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
