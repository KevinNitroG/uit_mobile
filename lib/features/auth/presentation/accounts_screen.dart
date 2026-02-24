import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/auth/providers/auth_provider.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Screen for managing multiple accounts.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final authState = ref.watch(authProvider);

    final activeStudentId = switch (authState) {
      AuthAuthenticated(:final session) => session.studentId,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text('accounts.title'.tr())),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(child: Text('accounts.noAccounts'.tr()));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final isActive = session.studentId == activeStudentId;
              return _AccountTile(
                session: session,
                isActive: isActive,
                onSwitch: () {
                  ref
                      .read(authProvider.notifier)
                      .switchAccount(session.studentId);
                  context.pop();
                },
                onRemove: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('accounts.removeTitle'.tr()),
                      content: Text(
                        'accounts.removeConfirm'.tr(args: [session.studentId]),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('common.cancel'.tr()),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('common.remove'.tr()),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref
                        .read(authProvider.notifier)
                        .removeAccount(session.studentId);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to login to add a new account.
          context.push('/login?addAccount=true');
        },
        icon: const Icon(Icons.person_add_outlined),
        label: Text('accounts.addAccount'.tr()),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final UserSession session;
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback onRemove;

  const _AccountTile({
    required this.session,
    required this.isActive,
    required this.onSwitch,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isActive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            session.studentId.substring(
              session.studentId.length > 2 ? session.studentId.length - 2 : 0,
            ),
          ),
        ),
        title: Text(session.name ?? session.studentId),
        subtitle: Text(session.studentId),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Chip(
                label: Text(
                  'accounts.active'.tr(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
                side: BorderSide.none,
              )
            else
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'accounts.switchTo'.tr(),
                onPressed: onSwitch,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'common.remove'.tr(),
              onPressed: onRemove,
            ),
          ],
        ),
        onTap: isActive ? null : onSwitch,
      ),
    );
  }
}
