import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

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
    DeadlineFilter.pending =>
      all.where((d) => d.status == DeadlineStatus.pending).toList(),
    DeadlineFilter.finished =>
      all.where((d) => d.status == DeadlineStatus.submitted).toList(),
    DeadlineFilter.overdue =>
      all.where((d) => d.status == DeadlineStatus.overdue).toList(),
  };
});

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

    final (
      IconData icon,
      Color color,
      String badgeKey,
    ) = switch (deadline.status) {
      DeadlineStatus.submitted => (
        Icons.check_circle_rounded,
        theme.colorScheme.primary,
        'deadlines.submitted',
      ),
      DeadlineStatus.overdue => (
        Icons.assignment_late_outlined,
        theme.colorScheme.error,
        'deadlines.overdue',
      ),
      DeadlineStatus.pending => (
        Icons.assignment_outlined,
        theme.colorScheme.tertiary,
        'deadlines.pending',
      ),
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
              Icon(icon, color: color),
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
                        const SizedBox(width: 8),
                        _StatusBadge(label: badgeKey.tr(), color: color),
                        if (deadline.closed) ...[
                          const SizedBox(width: 6),
                          _StatusBadge(
                            label: 'deadlines.closed'.tr(),
                            color: theme.colorScheme.outline,
                          ),
                        ],
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
