import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _kAppVersion = 'v0.3.0'; // x-release-please-version

/// Settings screen with language switching and account management.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                  subtitle: const Text(_kAppVersion),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
