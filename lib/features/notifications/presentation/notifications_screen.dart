import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/home/providers/data_providers.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Search query state for notifications.
final notificationSearchProvider = NotifierProvider<_SearchNotifier, String>(
  _SearchNotifier.new,
);

class _SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;

  void clear() => state = '';
}

/// Filtered notifications based on search query.
final filteredNotificationsProvider = FutureProvider<List<UitNotification>>((
  ref,
) async {
  final allNotifications = await ref.watch(notificationsProvider.future);
  final query = ref.watch(notificationSearchProvider).toLowerCase();

  if (query.isEmpty) return allNotifications;

  return allNotifications.where((n) {
    return n.title.toLowerCase().contains(query) ||
        n.content.toLowerCase().contains(query);
  }).toList();
});

/// Notifications screen with search and filter.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'notifications.searchHint'.tr(),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (value) {
                  ref.read(notificationSearchProvider.notifier).update(value);
                },
              )
            : Text('notifications.title'.tr()),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(notificationSearchProvider.notifier).clear();
                }
              });
            },
          ),
        ],
      ),
      body: filteredAsync.when(
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
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(child: Text('notifications.noNotifications'.tr()));
          }

          return SelectionArea(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.read(studentDataProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _NotificationTile(notification: notifications[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final UitNotification notification;

  const _NotificationTile({required this.notification});

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          widget.notification.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          // When collapsed, truncate to 2 lines; when expanded, show full text.
          maxLines: _isExpanded ? null : 2,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
        ),
        subtitle: Text(
          widget.notification.dated,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.notification.content,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
