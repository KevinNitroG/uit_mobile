import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Filter mode for deadlines.
enum DeadlineFilter { all, pending, finished, overdue }

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
    DeadlineFilter.pending => all.where((d) => _isPending(d)).toList(),
    DeadlineFilter.finished =>
      all.where((d) => d.status != null && d.status!.isNotEmpty).toList(),
    DeadlineFilter.overdue => all.where((d) => _isOverdue(d)).toList(),
  };
});

bool _isPending(Deadline d) =>
    (d.status == null || d.status!.isEmpty) && !_isOverdue(d);

bool _isOverdue(Deadline d) {
  if (d.status != null && d.status!.isNotEmpty) return false;
  // Try to parse the date from niceDate to determine if overdue.
  // niceDate is typically a human-readable date string from the API.
  // We do a best-effort parse; if it fails, treat as not overdue.
  try {
    final parsed = DateTime.tryParse(d.niceDate);
    if (parsed != null) return parsed.isBefore(DateTime.now());
  } catch (_) {
    // ignore
  }
  return false;
}

/// Displays upcoming deadlines/assignments with filter toggles.
class DeadlinesScreen extends ConsumerWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredDeadlinesProvider);
    final currentFilter = ref.watch(deadlineFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('deadlines.title'.tr())),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: DeadlineFilter.values.map((filter) {
                final isSelected = filter == currentFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(filter)),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(deadlineFilterProvider.notifier).set(filter);
                    },
                  ),
                );
              }).toList(),
            ),
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
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.read(studentDataProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: deadlines.length,
                      itemBuilder: (context, index) {
                        return _DeadlineTile(deadline: deadlines[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(DeadlineFilter filter) {
    return switch (filter) {
      DeadlineFilter.all => 'deadlines.filterAll'.tr(),
      DeadlineFilter.pending => 'deadlines.filterPending'.tr(),
      DeadlineFilter.finished => 'deadlines.filterFinished'.tr(),
      DeadlineFilter.overdue => 'deadlines.filterOverdue'.tr(),
    };
  }
}

class _DeadlineTile extends StatelessWidget {
  final Deadline deadline;

  const _DeadlineTile({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitted = deadline.status != null && deadline.status!.isNotEmpty;
    final isOverdue = _isOverdue(deadline);

    final (IconData icon, Color color) = switch (true) {
      _ when isSubmitted => (
        Icons.check_circle_rounded,
        theme.colorScheme.primary,
      ),
      _ when isOverdue => (Icons.error_outline, theme.colorScheme.error),
      _ => (Icons.assignment_late_outlined, theme.colorScheme.tertiary),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(deadline.name, style: theme.textTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deadline.shortname,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  deadline.niceDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isSubmitted) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'deadlines.submitted'.tr(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
                if (isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'deadlines.overdue'.tr(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
