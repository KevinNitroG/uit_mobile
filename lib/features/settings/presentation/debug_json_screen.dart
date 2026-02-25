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
    final cs = theme.colorScheme;
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    final jsonTheme = JsonViewTheme(
      backgroundColor: theme.scaffoldBackgroundColor,
      viewType: JsonViewType.collapsible,
      keyStyle: TextStyle(
        color: cs.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      stringStyle: TextStyle(color: cs.secondary, fontSize: 14),
      intStyle: TextStyle(color: cs.tertiary, fontSize: 14),
      doubleStyle: TextStyle(color: cs.tertiary, fontSize: 14),
      boolStyle: TextStyle(color: cs.error, fontSize: 14),
      openIcon: Icon(Icons.expand_less, color: cs.primary, size: 20),
      closeIcon: Icon(Icons.expand_more, color: cs.primary, size: 20),
      separator: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(
          Icons.arrow_right_alt_outlined,
          size: 18,
          color: cs.outline,
        ),
      ),
    );

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
            ? JsonView.map(data as Map<String, dynamic>, theme: jsonTheme)
            : JsonView.string(jsonStr, theme: jsonTheme),
      ),
    );
  }
}
