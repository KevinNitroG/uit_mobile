import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/auth/presentation/account_switcher_screen.dart';
import 'package:uit_mobile/features/auth/presentation/accounts_screen.dart';
import 'package:uit_mobile/features/auth/presentation/login_screen.dart';
import 'package:uit_mobile/features/auth/providers/auth_provider.dart';
import 'package:uit_mobile/features/fees/presentation/fees_screen.dart';
import 'package:uit_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:uit_mobile/features/settings/presentation/debug_screen.dart';
import 'package:uit_mobile/features/settings/presentation/settings_screen.dart';
import 'package:uit_mobile/features/timetable/presentation/period_info_screen.dart';
import 'package:uit_mobile/shared/widgets/main_shell.dart';

/// A [ChangeNotifier] that listens to [authProvider] and notifies GoRouter
/// when the auth state changes. This avoids recreating GoRouter on every state
/// change — instead, GoRouter calls its redirect function.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(authProvider, (_, _) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// GoRouter configuration provider.
/// Uses [refreshListenable] so auth state changes trigger redirect evaluation
/// without recreating the GoRouter instance.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      // While loading/restoring session, don't redirect.
      if (authState is AuthLoading || authState is AuthInitial) return null;

      final isAuthenticated = authState is AuthAuthenticated;
      final needsAccountSelection = authState is AuthNeedsAccountSelection;
      final location = state.matchedLocation;
      final isOnLogin = location == '/login';
      final isOnAccountSwitcher = location == '/account-switcher';
      final isAddingAccount = state.uri.queryParameters['addAccount'] == 'true';

      // Needs to pick an account from saved sessions.
      if (needsAccountSelection) {
        if (isOnAccountSwitcher || isOnLogin) return null;
        return '/account-switcher';
      }

      // Not authenticated and no saved sessions → go to login.
      if (!isAuthenticated && !isOnLogin) return '/login';

      // Authenticated → redirect away from login/account-switcher to home.
      if (isAuthenticated && isOnAccountSwitcher) return '/';
      if (isAuthenticated && isOnLogin && !isAddingAccount) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final isAddAccount =
              state.uri.queryParameters['addAccount'] == 'true';
          return LoginScreen(isAddAccount: isAddAccount);
        },
      ),
      GoRoute(
        path: '/account-switcher',
        builder: (context, state) => const AccountSwitcherScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShell(),
        routes: [
          GoRoute(
            path: 'accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'period-info',
            builder: (context, state) => const PeriodInfoScreen(),
          ),
          GoRoute(
            path: 'fees',
            builder: (context, state) => const FeesScreen(),
          ),
          GoRoute(
            path: 'debug',
            builder: (context, state) => const DebugScreen(),
          ),
        ],
      ),
    ],
  );
});
