import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Home/dashboard screen showing user info overview.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userInfoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UIT'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'common.refresh'.tr(),
            onPressed: () {
              ref.invalidate(userInfoProvider);
              ref.read(studentDataProvider.notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'notifications.title'.tr(),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'settings.title'.tr(),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userInfoProvider);
          ref.invalidate(studentDataProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile card
              userAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading profile: $e'),
                  ),
                ),
                data: (user) => _ProfileCard(user: user, theme: theme),
              ),
              const SizedBox(height: 24),

              // Quick stats
              _SectionHeader(title: 'home.overview'.tr()),
              const SizedBox(height: 8),
              _QuickStats(ref: ref, theme: theme),

              const SizedBox(height: 24),

              // Tuition fees section
              _FeesSection(ref: ref, theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserInfo user;
  final ThemeData theme;

  const _ProfileCard({required this.user, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.sid,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _InfoRow(label: 'home.major'.tr(), value: user.major),
              _InfoRow(label: 'home.class'.tr(), value: user.className),
              _InfoRow(label: 'home.email'.tr(), value: user.mail),
              _InfoRow(label: 'home.dob'.tr(), value: user.dob),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final WidgetRef ref;
  final ThemeData theme;

  const _QuickStats({required this.ref, required this.theme});

  @override
  Widget build(BuildContext context) {
    final deadlinesAsync = ref.watch(deadlinesProvider);
    final coursesAsync = ref.watch(coursesProvider);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today,
            label: 'home.courses'.tr(),
            value: coursesAsync.when(
              loading: () => '...',
              error: (_, _) => '-',
              data: (semesters) {
                // Sum all courses across all day groups.
                var total = 0;
                var totalCredits = 0;
                final seenClasses = <String>{};
                for (final s in semesters) {
                  total += s.courses.length;
                  for (final c in s.courses) {
                    // Avoid double-counting credits for same class across days
                    if (seenClasses.add(c.classCode)) {
                      totalCredits += int.tryParse(c.credits) ?? 0;
                    }
                  }
                }
                return '$total \u2022 $totalCredits TC';
              },
            ),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.assignment_outlined,
            label: 'home.deadlines'.tr(),
            value: deadlinesAsync.when(
              loading: () => '...',
              error: (_, _) => '-',
              data: (deadlines) {
                final total = deadlines.length;
                final submitted = deadlines
                    .where((d) => d.status == DeadlineStatus.submitted)
                    .length;
                final remaining = total - submitted;
                return '$remaining/$total';
              },
            ),
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Format a number as VND currency.
String _formatCurrency(double amount) {
  final formatter = NumberFormat('#,###', 'vi');
  return '${formatter.format(amount.round())} VND';
}

/// Tuition fees summary section on the home screen.
class _FeesSection extends StatelessWidget {
  final WidgetRef ref;
  final ThemeData theme;

  const _FeesSection({required this.ref, required this.theme});

  @override
  Widget build(BuildContext context) {
    final feesAsync = ref.watch(feesProvider);

    return feesAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '-',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ),
      data: (fees) {
        if (fees.isEmpty) {
          return Card(
            child: ListTile(
              leading: Icon(
                Icons.receipt_long_outlined,
                color: theme.colorScheme.outline,
              ),
              title: Text(
                'fees.noFees'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }

        final totalDue = fees.fold<double>(0, (s, f) => s + f.due);
        final totalPaid = fees.fold<double>(0, (s, f) => s + f.paid);
        final totalDebt = fees.fold<double>(0, (s, f) => s + f.debt);
        final totalRemaining = totalDue - totalPaid + totalDebt;
        final allPaid = totalRemaining <= 0;
        final totalObligation = totalDue + totalDebt;
        final progress = totalObligation > 0
            ? ((totalDue - totalRemaining) / totalObligation).clamp(0.0, 1.0)
            : 1.0;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/fees'),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        allPaid
                            ? Icons.check_circle_outline
                            : Icons.receipt_long_outlined,
                        color: allPaid
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          allPaid
                              ? 'fees.paidInFull'.tr()
                              : _formatCurrency(totalRemaining),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: allPaid
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        allPaid
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
