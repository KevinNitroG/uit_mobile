import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/auth/providers/auth_provider.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Shown on startup when there are saved sessions but no active one.
/// The user picks an existing account or adds a new one.
class AccountSwitcherScreen extends ConsumerWidget {
  const AccountSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset(
                  'assets/images/uit_logo.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'accounts.chooseAccount'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'accounts.chooseAccountSubtitle'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 32),

                // Account list
                sessionsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (sessions) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...sessions.map(
                        (session) => _AccountCard(
                          session: session,
                          theme: theme,
                          onTap: () {
                            ref
                                .read(authProvider.notifier)
                                .switchAccount(session.studentId);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Add account button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/login?addAccount=true'),
                    icon: const Icon(Icons.person_add_outlined),
                    label: Text('accounts.addAccount'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final UserSession session;
  final ThemeData theme;
  final VoidCallback onTap;

  const _AccountCard({
    required this.session,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            session.studentId.substring(
              session.studentId.length > 2 ? session.studentId.length - 2 : 0,
            ),
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          session.name ?? session.studentId,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: session.name != null ? Text(session.studentId) : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}
