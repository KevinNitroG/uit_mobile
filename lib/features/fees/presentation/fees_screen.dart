import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Displays tuition fee records grouped by academic year/semester.
class FeesScreen extends ConsumerWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(feesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('fees.title'.tr())),
      body: feesAsync.when(
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
        data: (fees) {
          if (fees.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'fees.noFees'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          // Aggregate totals using the model's computed properties.
          final totalDue = fees.fold<double>(0, (s, f) => s + f.due);
          final totalPaid = fees.fold<double>(0, (s, f) => s + f.paid);
          final totalDebt = fees.fold<double>(0, (s, f) => s + f.debt);
          final totalRemaining = fees.fold<double>(
            0,
            (s, f) => s + f.remaining,
          );
          final allPaid = totalRemaining <= 0;
          final totalProgress = totalDue > 0
              ? ((totalDue - totalRemaining) / totalDue).clamp(0.0, 1.0)
              : 1.0;

          return SelectionArea(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.read(studentDataProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                // +1 for the summary card at top.
                itemCount: fees.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _FeeSummaryCard(
                      totalDue: totalDue,
                      totalPaid: totalPaid,
                      totalDebt: totalDebt,
                      totalRemaining: totalRemaining,
                      allPaid: allPaid,
                      progress: totalProgress,
                    );
                  }
                  // Show most recent first.
                  final feeIndex = fees.length - index;
                  return _FeeCard(fee: fees[feeIndex]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Summary card at the top showing total due, paid, debt, and remaining.
class _FeeSummaryCard extends StatelessWidget {
  final double totalDue;
  final double totalPaid;
  final double totalDebt;
  final double totalRemaining;
  final bool allPaid;
  final double progress;

  const _FeeSummaryCard({
    required this.totalDue,
    required this.totalPaid,
    required this.totalDebt,
    required this.totalRemaining,
    required this.allPaid,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'fees.summary'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'fees.totalDue'.tr(),
              value: _formatCurrency(totalDue),
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'fees.totalPaid'.tr(),
              value: _formatCurrency(totalPaid),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'fees.totalPreviousDebt'.tr(),
              value: _formatCurrency(totalDebt),
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const Divider(height: 20),
            _SummaryRow(
              label: 'fees.remaining'.tr(),
              value: _formatCurrency(totalRemaining),
              color: allPaid
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
              isBold: true,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  allPaid ? theme.colorScheme.primary : theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Individual fee record card.
class _FeeCard extends StatelessWidget {
  final Fee fee;

  const _FeeCard({required this.fee});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Semester / Year header + status badge
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'fees.semesterLabel'.tr(args: [fee.semester, fee.year]),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: fee.isPaid
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : theme.colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    fee.isPaid ? 'fees.paid'.tr() : 'fees.unpaid'.tr(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fee.isPaid
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amount details: Due, Paid, Previous Debt, Remaining
            Row(
              children: [
                Expanded(
                  child: _AmountColumn(
                    label: 'fees.due'.tr(),
                    value: _formatCurrency(fee.due),
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Expanded(
                  child: _AmountColumn(
                    label: 'fees.paidAmount'.tr(),
                    value: _formatCurrency(fee.paid),
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _AmountColumn(
                    label: 'fees.previousDebtAmount'.tr(),
                    value: _formatCurrency(fee.debt),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: _AmountColumn(
                    label: 'fees.remaining'.tr(),
                    value: _formatCurrency(fee.remaining),
                    color: fee.isPaid
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),

            // Progress bar
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fee.progress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  fee.isPaid
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ),

            // Registered subjects (dkhp)
            if (fee.subjects.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'fees.registeredSubjects'.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: fee.subjects.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${s.code} (${double.tryParse(s.credits)?.toInt() ?? s.credits})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AmountColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Format a number as VND currency.
String _formatCurrency(double amount) {
  final formatter = NumberFormat('#,###', 'vi');
  return '${formatter.format(amount.round())} VND';
}
