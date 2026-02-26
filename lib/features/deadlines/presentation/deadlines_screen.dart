import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

/// Filter mode for deadlines.
enum DeadlineFilter { all, pending, submitted, overdue }

/// Current filter state.
final deadlineFilterProvider =
    NotifierProvider<_DeadlineFilterNotifier, DeadlineFilter>(
      _DeadlineFilterNotifier.new,
    );

class _DeadlineFilterNotifier extends Notifier<DeadlineFilter> {
  @override
  DeadlineFilter build() => DeadlineFilter.all;

  void set(DeadlineFilter filter) => state = filter;
}

/// Filtered deadlines based on selected filter.
final filteredDeadlinesProvider = FutureProvider<List<Deadline>>((ref) async {
  final all = await ref.watch(deadlinesProvider.future);
  final filter = ref.watch(deadlineFilterProvider);

  return switch (filter) {
    DeadlineFilter.all => all,
    DeadlineFilter.pending =>
      all
          .where(
            (d) =>
                d.pendingStatus == PendingStatus.pending &&
                d.submittedStatus != SubmittedStatus.submitted,
          )
          .toList(),
    DeadlineFilter.submitted =>
      all.where((d) => d.submittedStatus == SubmittedStatus.submitted).toList(),
    DeadlineFilter.overdue =>
      all
          .where(
            (d) =>
                d.pendingStatus == PendingStatus.overdue &&
                d.submittedStatus != SubmittedStatus.submitted,
          )
          .toList(),
  };
});

/// Displays upcoming deadlines/assignments with filter toggles.
class DeadlinesScreen extends ConsumerWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredDeadlinesProvider);
    final allDeadlinesAsync = ref.watch(deadlinesProvider);
    final currentFilter = ref.watch(deadlineFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('deadlines.title'.tr())),
      body: Column(
        children: [
          // Filter chips with counts
          allDeadlinesAsync.when(
            loading: () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: DeadlineFilter.values.map((filter) {
                  final isSelected = filter == currentFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filterLabel(filter, null)),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(deadlineFilterProvider.notifier).set(filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (deadlines) {
              final counts = _computeCounts(deadlines);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: DeadlineFilter.values.map((filter) {
                    final isSelected = filter == currentFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filterLabel(filter, counts)),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(deadlineFilterProvider.notifier).set(filter);
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          // Deadline list
          Expanded(
            child: filteredAsync.when(
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
              data: (deadlines) {
                if (deadlines.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text('deadlines.noDeadlines'.tr()),
                      ],
                    ),
                  );
                }

                return SelectionArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: deadlines.length,
                    itemBuilder: (context, index) {
                      return _DeadlineTile(deadline: deadlines[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Compute counts for each filter category.
  Map<DeadlineFilter, int> _computeCounts(List<Deadline> deadlines) {
    var pending = 0;
    var submitted = 0;
    var overdue = 0;
    for (final d in deadlines) {
      if (d.submittedStatus == SubmittedStatus.submitted) {
        submitted++;
      } else if (d.pendingStatus == PendingStatus.overdue) {
        overdue++;
      } else {
        pending++;
      }
    }
    return {
      DeadlineFilter.all: deadlines.length,
      DeadlineFilter.pending: pending,
      DeadlineFilter.submitted: submitted,
      DeadlineFilter.overdue: overdue,
    };
  }

  String _filterLabel(DeadlineFilter filter, Map<DeadlineFilter, int>? counts) {
    final base = switch (filter) {
      DeadlineFilter.all => 'deadlines.filterAll'.tr(),
      DeadlineFilter.pending => 'deadlines.filterPending'.tr(),
      DeadlineFilter.submitted => 'deadlines.filterSubmitted'.tr(),
      DeadlineFilter.overdue => 'deadlines.filterOverdue'.tr(),
    };
    if (counts == null) return base;
    return '$base (${counts[filter]})';
  }
}

class _DeadlineTile extends StatelessWidget {
  final Deadline deadline;

  const _DeadlineTile({required this.deadline});

  Future<void> _showOpenUrlDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deadlines.openWebsite'.tr()),
        content: Text(deadline.url),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('deadlines.open'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await launchUrl(
        Uri.parse(deadline.url),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitted = deadline.submittedStatus == SubmittedStatus.submitted;

    // Determine the leading icon based on submittedStatus + pendingStatus.
    // If submitted, always show check icon (no pending consideration).
    final (IconData leadingIcon, Color leadingColor) = switch (isSubmitted) {
      true => (Icons.check_circle_rounded, theme.colorScheme.primary),
      false => switch (deadline.pendingStatus) {
        PendingStatus.overdue => (
          Icons.assignment_late_outlined,
          theme.colorScheme.error,
        ),
        PendingStatus.pending => (
          Icons.assignment_outlined,
          theme.colorScheme.tertiary,
        ),
      },
    };

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showOpenUrlDialog(context),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(leadingIcon, color: leadingColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deadline.name, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(
                      deadline.shortname,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date row
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            deadline.niceDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Status badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // pendingStatus badge: only show when NOT submitted
                        if (!isSubmitted)
                          _StatusBadge(
                            label:
                                deadline.pendingStatus == PendingStatus.pending
                                ? 'deadlines.pending'.tr()
                                : 'deadlines.overdue'.tr(),
                            color:
                                deadline.pendingStatus == PendingStatus.pending
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.error,
                          ),
                        // submittedStatus badge
                        _StatusBadge(
                          label: isSubmitted
                              ? 'deadlines.submitted'.tr()
                              : 'deadlines.notSubmitted'.tr(),
                          color: isSubmitted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary,
                        ),
                        // closedStatus badge
                        _StatusBadge(
                          label: deadline.closedStatus == ClosedStatus.closed
                              ? 'deadlines.closed'.tr()
                              : 'deadlines.openStatus'.tr(),
                          color: deadline.closedStatus == ClosedStatus.closed
                              ? theme.colorScheme.outline
                              : theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small colored label badge used to display deadline status.
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
