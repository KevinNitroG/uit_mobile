import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

/// Detail screen that displays JSON data with two view modes:
///   1. **Raw** — Pretty-printed JSON text (default).
///   2. **Tree** — Interactive, collapsible tree via [JsonView].
///
/// Expects [GoRouter] `extra` to be a `Map` with:
///   - `'title'` → `String`
///   - `'data'`  → `dynamic` (Map, List, or primitive)
class DebugJsonScreen extends StatefulWidget {
  final String title;
  final dynamic data;

  const DebugJsonScreen({super.key, required this.title, required this.data});

  @override
  State<DebugJsonScreen> createState() => _DebugJsonScreenState();
}

class _DebugJsonScreenState extends State<DebugJsonScreen> {
  bool _showTreeView = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final jsonStr = const JsonEncoder.withIndent('  ').convert(widget.data);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Toggle between raw text and tree view
          IconButton(
            icon: Icon(
              _showTreeView ? Icons.text_snippet_outlined : Icons.account_tree,
            ),
            tooltip: _showTreeView
                ? 'settings.debugRawView'.tr()
                : 'settings.debugTreeView'.tr(),
            onPressed: () {
              setState(() => _showTreeView = !_showTreeView);
            },
          ),
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
        child: _showTreeView
            ? _buildTreeView(theme, cs, jsonStr)
            : _buildRawView(theme, jsonStr),
      ),
    );
  }

  Widget _buildRawView(ThemeData theme, String jsonStr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        jsonStr,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTreeView(ThemeData theme, ColorScheme cs, String jsonStr) {
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

    final bool isMap = widget.data is Map<String, dynamic>;

    return isMap
        ? JsonView.map(widget.data as Map<String, dynamic>, theme: jsonTheme)
        : JsonView.string(jsonStr, theme: jsonTheme);
  }
}
