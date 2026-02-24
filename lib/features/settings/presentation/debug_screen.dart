import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';

/// Debug screen showing the raw JSON data from the student data API.
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(studentDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.debug'.tr()),
        actions: [
          // Copy all JSON to clipboard
          if (dataAsync.hasValue)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'settings.debugCopy'.tr(),
              onPressed: () {
                final json = const JsonEncoder.withIndent(
                  '  ',
                ).convert(dataAsync.value!.toJson());
                Clipboard.setData(ClipboardData(text: json));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('settings.debugCopied'.tr()),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
      body: dataAsync.when(
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
        data: (studentData) {
          final rawJson = studentData.toJson();
          final sections = <_DebugSection>[
            _DebugSection(
              title: 'Courses',
              icon: Icons.calendar_today,
              data: rawJson['courses'],
              count: (rawJson['courses'] as List?)?.length ?? 0,
            ),
            _DebugSection(
              title: 'Scores',
              icon: Icons.score,
              data: rawJson['scores'],
              count: (rawJson['scores'] as List?)?.length ?? 0,
            ),
            _DebugSection(
              title: 'Fees',
              icon: Icons.receipt_long,
              data: rawJson['fee'],
              count: (rawJson['fee'] as List?)?.length ?? 0,
            ),
            _DebugSection(
              title: 'Notifications',
              icon: Icons.notifications,
              data: rawJson['notify'],
              count: (rawJson['notify'] as List?)?.length ?? 0,
            ),
            _DebugSection(
              title: 'Deadlines',
              icon: Icons.assignment,
              data: rawJson['deadline'],
              count: (rawJson['deadline'] as List?)?.length ?? 0,
            ),
            _DebugSection(
              title: 'Exams',
              icon: Icons.event,
              data: rawJson['exams'],
              count: (rawJson['exams'] as Map?)?.length ?? 0,
            ),
          ];

          return SelectionArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final jsonStr = const JsonEncoder.withIndent(
                  '  ',
                ).convert(section.data);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerTheme: const DividerThemeData(space: 0)),
                    child: ExpansionTile(
                      leading: Icon(
                        section.icon,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        section.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${section.count} items',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: jsonStr));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${section.title} JSON copied'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const Icon(Icons.expand_more),
                        ],
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          child: Text(
                            jsonStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DebugSection {
  final String title;
  final IconData icon;
  final dynamic data;
  final int count;

  const _DebugSection({
    required this.title,
    required this.icon,
    required this.data,
    required this.count,
  });
}
