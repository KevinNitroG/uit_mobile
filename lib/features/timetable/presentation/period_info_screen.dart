import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Static data for UIT period time slots.
const _periods = [
  (period: 1, start: '7:30', end: '8:15'),
  (period: 2, start: '8:15', end: '9:00'),
  (period: 3, start: '9:00', end: '9:45'),
  (period: 4, start: '10:00', end: '10:45'),
  (period: 5, start: '10:45', end: '11:30'),
  (period: 6, start: '13:00', end: '13:45'),
  (period: 7, start: '13:45', end: '14:30'),
  (period: 8, start: '14:30', end: '15:15'),
  (period: 9, start: '15:30', end: '16:15'),
  (period: 10, start: '16:15', end: '17:00'),
];

/// Screen showing the period-to-time mapping for UIT.
class PeriodInfoScreen extends StatelessWidget {
  const PeriodInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('timetable.periodInfo'.tr())),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _periods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final p = _periods[index];
          final isMorning = p.period <= 5;

          return Card(
            color: isMorning
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isMorning
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${p.period}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isMorning
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              title: Text(
                'timetable.period'.tr(args: ['${p.period}']),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${p.start} - ${p.end}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
