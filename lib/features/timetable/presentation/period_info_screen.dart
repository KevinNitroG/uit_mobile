import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Static data for UIT period time slots.
const _periods = [
  (period: 1, startHour: 7, startMin: 30, endHour: 8, endMin: 15),
  (period: 2, startHour: 8, startMin: 15, endHour: 9, endMin: 0),
  (period: 3, startHour: 9, startMin: 0, endHour: 9, endMin: 45),
  (period: 4, startHour: 10, startMin: 0, endHour: 10, endMin: 45),
  (period: 5, startHour: 10, startMin: 45, endHour: 11, endMin: 30),
  (period: 6, startHour: 13, startMin: 0, endHour: 13, endMin: 45),
  (period: 7, startHour: 13, startMin: 45, endHour: 14, endMin: 30),
  (period: 8, startHour: 14, startMin: 30, endHour: 15, endMin: 15),
  (period: 9, startHour: 15, startMin: 30, endHour: 16, endMin: 15),
  (period: 10, startHour: 16, startMin: 15, endHour: 17, endMin: 0),
];

/// Check if the current time falls within the given period.
bool _isCurrentPeriod(int startHour, int startMin, int endHour, int endMin) {
  final now = DateTime.now();
  final startMinutes = startHour * 60 + startMin;
  final endMinutes = endHour * 60 + endMin;
  final nowMinutes = now.hour * 60 + now.minute;
  return nowMinutes >= startMinutes && nowMinutes < endMinutes;
}

/// Format time as "H:MM".
String _formatTime(int hour, int minute) {
  return '$hour:${minute.toString().padLeft(2, '0')}';
}

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
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final p = _periods[index];
          final isMorning = p.period <= 5;
          final isCurrent = _isCurrentPeriod(
            p.startHour,
            p.startMin,
            p.endHour,
            p.endMin,
          );
          final startStr = _formatTime(p.startHour, p.startMin);
          final endStr = _formatTime(p.endHour, p.endMin);

          return Card(
            color: isMorning
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            shape: isCurrent
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isMorning
                          ? theme.colorScheme.primary
                          : theme.colorScheme.tertiary,
                      width: 2,
                    ),
                  )
                : null,
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
                '$startStr - $endStr',
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
