import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

/// Detail screen that displays a JSON value using [JsonView] from
/// `flutter_json_view` for an interactive, collapsible tree.
///
/// Expects [GoRouter] `extra` to be a `Map` with:
///   - `'title'` → `String`
///   - `'data'`  → `dynamic` (Map, List, or primitive)
class DebugJsonScreen extends StatelessWidget {
  final String title;
  final dynamic data;

  const DebugJsonScreen({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    // Wrap data in a Map for JsonView.map when it's already a Map;
    // otherwise encode as string.
    final bool isMap = data is Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'settings.debugCopy'.tr(),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
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
      body: SelectionArea(
        child: isMap
            ? JsonView.map(
                data as Map<String, dynamic>,
                theme: JsonViewTheme(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  viewType: JsonViewType.collapsible,
                ),
              )
            : JsonView.string(
                jsonStr,
                theme: JsonViewTheme(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  viewType: JsonViewType.collapsible,
                ),
              ),
      ),
    );
  }
}
