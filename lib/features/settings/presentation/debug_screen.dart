import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';

/// Debug hub screen – lists each API data section as a navigable tile,
/// plus a "Full Response" entry that shows the entire raw JSON.
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
          final sections = <_DebugSectionInfo>[
            _DebugSectionInfo(
              title: 'Courses',
              icon: Icons.calendar_today,
              data: rawJson['courses'],
              count: (rawJson['courses'] as List?)?.length ?? 0,
            ),
            _DebugSectionInfo(
              title: 'Scores',
              icon: Icons.score,
              data: rawJson['scores'],
              count: (rawJson['scores'] as List?)?.length ?? 0,
            ),
            _DebugSectionInfo(
              title: 'Fees',
              icon: Icons.receipt_long,
              data: rawJson['fee'],
              count: (rawJson['fee'] as List?)?.length ?? 0,
            ),
            _DebugSectionInfo(
              title: 'Notifications',
              icon: Icons.notifications,
              data: rawJson['notify'],
              count: (rawJson['notify'] as List?)?.length ?? 0,
            ),
            _DebugSectionInfo(
              title: 'Deadlines',
              icon: Icons.assignment,
              data: rawJson['deadline'],
              count: (rawJson['deadline'] as List?)?.length ?? 0,
            ),
            _DebugSectionInfo(
              title: 'Exams',
              icon: Icons.event,
              data: rawJson['exams'],
              count: (rawJson['exams'] as Map?)?.length ?? 0,
            ),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Full response tile
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.data_object,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    'settings.debugFullResponse'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${sections.length} sections',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.outline,
                  ),
                  onTap: () => context.push(
                    '/debug/json',
                    extra: {
                      'title': 'settings.debugFullResponse'.tr(),
                      'data': rawJson,
                    },
                  ),
                ),
              ),

              const Divider(height: 24),

              // Per-section tiles
              ...sections.map((section) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
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
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.outline,
                    ),
                    onTap: () => context.push(
                      '/debug/json',
                      extra: {'title': section.title, 'data': section.data},
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _DebugSectionInfo {
  final String title;
  final IconData icon;
  final dynamic data;
  final int count;

  const _DebugSectionInfo({
    required this.title,
    required this.icon,
    required this.data,
    required this.count,
  });
}
