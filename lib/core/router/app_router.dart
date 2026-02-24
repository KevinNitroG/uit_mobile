import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uit_mobile/features/auth/presentation/accounts_screen.dart';
import 'package:uit_mobile/features/auth/presentation/login_screen.dart';
import 'package:uit_mobile/features/auth/providers/auth_provider.dart';
import 'package:uit_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:uit_mobile/features/settings/presentation/settings_screen.dart';
import 'package:uit_mobile/features/timetable/presentation/period_info_screen.dart';
import 'package:uit_mobile/shared/widgets/main_shell.dart';

/// GoRouter configuration provider.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // While loading/restoring session, don't redirect.
      if (authState is AuthLoading || authState is AuthInitial) return null;

      final isAuthenticated = authState is AuthAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      // Allow authenticated users to reach /login when adding an account.
      final isAddingAccount = state.uri.queryParameters['addAccount'] == 'true';

      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn && !isAddingAccount) return '/';
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
        ],
      ),
    ],
  );
});
