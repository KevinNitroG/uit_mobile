import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/auth/providers/auth_provider.dart';
import 'package:uit_mobile/features/settings/providers/update_check_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings screen with language switching and account management.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = context.locale;
    final updateState = ref.watch(updateCheckProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Update banner — shown only when a newer version is available.
          updateState.when(
            data: (result) => switch (result) {
              UpdateCheckUpdateAvailable(:final latestVersion) => _UpdateBanner(
                latestVersion: latestVersion,
              ),
              _ => const SizedBox.shrink(),
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // Language section
          _SectionHeader(title: 'settings.language'.tr()),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<Locale>(
              groupValue: currentLocale,
              onChanged: (locale) {
                if (locale != null) context.setLocale(locale);
              },
              child: Column(
                children: [
                  RadioListTile<Locale>(
                    title: const Text('Tiếng Việt'),
                    subtitle: const Text('Vietnamese'),
                    value: const Locale('vi'),
                  ),
                  const Divider(height: 1),
                  RadioListTile<Locale>(
                    title: const Text('English'),
                    subtitle: const Text('English'),
                    value: const Locale('en'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Account section
          _SectionHeader(title: 'settings.account'.tr()),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.manage_accounts_outlined),
                  title: Text('accounts.title'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/accounts'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    'home.logout'.tr(),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('settings.logoutTitle'.tr()),
                        content: Text('settings.logoutConfirm'.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('common.cancel'.tr()),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('home.logout'.tr()),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      ref.read(authProvider.notifier).logout();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App info
          _SectionHeader(title: 'settings.about'.tr()),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('UIT Mobile'),
                  subtitle: Text(kCurrentAppVersion),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('settings.author'.tr()),
                  subtitle: const Text('Kevin Nitro'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: Text('settings.sourceCode'.tr()),
                  subtitle: const Text('github.com/KevinNitroG/uit_mobile'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => launchUrl(
                    Uri.parse('https://github.com/KevinNitroG/uit_mobile'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const Divider(height: 1),
                _UpdateCheckTile(updateState: updateState, ref: ref),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text('settings.debug'.tr()),
                  subtitle: Text('settings.debugSubtitle'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/debug'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Update banner
// ---------------------------------------------------------------------------

class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner({required this.latestVersion});
  final String latestVersion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.system_update_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'settings.updateAvailableMessage'.tr(args: [latestVersion]),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => launchUrl(
                  Uri.parse(
                    'https://github.com/KevinNitroG/uit_mobile/releases/latest',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text('settings.updateDownload'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Check for updates" list tile inside the About card
// ---------------------------------------------------------------------------

class _UpdateCheckTile extends StatelessWidget {
  const _UpdateCheckTile({required this.updateState, required this.ref});
  final AsyncValue<UpdateCheckResult> updateState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switch (updateState) {
      AsyncLoading() => ListTile(
        leading: const Icon(Icons.update),
        title: Text('settings.checkForUpdates'.tr()),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      AsyncData(:final value) => switch (value) {
        UpdateCheckUpdateAvailable(:final latestVersion) => ListTile(
          leading: Icon(
            Icons.system_update_outlined,
            color: theme.colorScheme.primary,
          ),
          title: Text('settings.checkForUpdates'.tr()),
          subtitle: Text(
            'settings.updateAvailableTitle'.tr(),
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          trailing: Text(
            latestVersion,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => launchUrl(
            Uri.parse(
              'https://github.com/KevinNitroG/uit_mobile/releases/latest',
            ),
            mode: LaunchMode.externalApplication,
          ),
        ),
        UpdateCheckUpToDate() => ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text('settings.checkForUpdates'.tr()),
          subtitle: Text('settings.upToDate'.tr()),
          onTap: () => ref.read(updateCheckProvider.notifier).recheck(),
        ),
        UpdateCheckFailed() => ListTile(
          leading: const Icon(Icons.update),
          title: Text('settings.checkForUpdates'.tr()),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => ref.read(updateCheckProvider.notifier).recheck(),
        ),
      },
      AsyncError() => ListTile(
        leading: const Icon(Icons.update),
        title: Text('settings.checkForUpdates'.tr()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => ref.read(updateCheckProvider.notifier).recheck(),
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
