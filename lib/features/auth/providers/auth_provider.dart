import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/core/network/api_service.dart';
import 'package:uit_mobile/core/storage/hive_cache_service.dart';
import 'package:uit_mobile/core/storage/secure_storage_service.dart';
import 'package:uit_mobile/core/utils/constants.dart';
import 'package:uit_mobile/core/utils/encoding.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// The current authentication state.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserSession session;
  const AuthAuthenticated(this.session);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// There are saved sessions but no active one — the user should choose which
/// account to use, or add a new one.
class AuthNeedsAccountSelection extends AuthState {
  const AuthNeedsAccountSelection();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// Provider for the [AuthNotifier].
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Provider that exposes all stored sessions for account switching.
final sessionsProvider = FutureProvider<List<UserSession>>((ref) async {
  final storage = ref.read(secureStorageServiceProvider);
  return storage.getSessions();
});

/// Manages authentication lifecycle.
class AuthNotifier extends Notifier<AuthState> {
  late final SecureStorageService _storage;
  late final UitApiService _api;
  late final HiveCacheService _cache;

  @override
  AuthState build() {
    _storage = ref.read(secureStorageServiceProvider);
    _api = ref.read(uitApiServiceProvider);
    _cache = ref.read(hiveCacheServiceProvider);

    // Restore session from storage on startup.
    _restoreSession();

    return const AuthLoading();
  }

  /// Checks for an existing session on app start.
  ///
  /// Authenticates immediately with the cached token so the UI can show cached
  /// data right away, then refreshes the token in the background.
  Future<void> _restoreSession() async {
    try {
      final session = await _storage.getActiveSession();
      if (session != null && session.token != null) {
        // Authenticate immediately so cached data renders instantly.
        state = AuthAuthenticated(session);

        // Refresh the token in the background. The JWT interceptor handles
        // 401s as a fallback if the existing token expires before this finishes.
        Future(() async {
          final refreshed = await _refreshToken(session);
          if (refreshed != null) {
            state = AuthAuthenticated(refreshed);
          }
        });
      } else {
        // No active session — check if there are saved sessions the user can pick.
        final sessions = await _storage.getSessions();
        if (sessions.isNotEmpty) {
          state = const AuthNeedsAccountSelection();
        } else {
          state = const AuthUnauthenticated();
        }
      }
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  /// Attempts to refresh the token using stored credentials.
  /// Returns the updated session, or null if the refresh fails.
  Future<UserSession?> _refreshToken(UserSession session) async {
    try {
      final result = await _api.generateToken(session.encodedCredentials);
      final encodedTok = encodeToken(result.token);
      final updated = session.copyWith(
        token: result.token,
        encodedToken: encodedTok,
        tokenExpiry: result.expires,
      );
      await _storage.upsertSession(updated);
      return updated;
    } catch (_) {
      // Token refresh failed — caller decides what to do.
      return null;
    }
  }

  /// Clears all Hive cache boxes so the next fetch retrieves fresh data for the
  /// newly active account.
  Future<void> _clearCache() async {
    await _cache.clearBox(HiveBoxes.courses);
    await _cache.clearBox(HiveBoxes.scores);
    await _cache.clearBox(HiveBoxes.notifications);
    await _cache.clearBox(HiveBoxes.deadlines);
    await _cache.clearBox(HiveBoxes.userInfo);
    await _cache.clearBox(HiveBoxes.exams);
    await _cache.clearBox(HiveBoxes.fees);
  }

  /// Logs in with [studentId] and [password].
  Future<void> login(String studentId, String password) async {
    state = const AuthLoading();
    try {
      final encodedCreds = encodeCredentials(studentId, password);

      // Generate token.
      final result = await _api.generateToken(encodedCreds);
      final encodedTok = encodeToken(result.token);

      // Build session.
      final session = UserSession(
        studentId: studentId,
        encodedCredentials: encodedCreds,
        token: result.token,
        encodedToken: encodedTok,
        tokenExpiry: result.expires,
      );

      // Persist and activate.
      await _storage.upsertSession(session);
      await _storage.setActiveSessionId(studentId);

      // Invalidate the sessions list so the accounts screen updates.
      ref.invalidate(sessionsProvider);

      // Clear cache so the data providers fetch fresh data for this account.
      // Data providers watch authProvider, so they re-run automatically when
      // state changes to AuthAuthenticated below.
      await _clearCache();

      state = AuthAuthenticated(session);
    } catch (e) {
      state = AuthError('Login failed: $e');
    }
  }

  /// Switches to an existing session by [studentId].
  Future<void> switchAccount(String studentId) async {
    state = const AuthLoading();
    try {
      await _storage.setActiveSessionId(studentId);
      final session = await _storage.getActiveSession();
      ref.invalidate(sessionsProvider);

      // Clear cache so the data providers fetch fresh data for this account.
      // Data providers watch authProvider, so they re-run automatically when
      // state changes below.
      await _clearCache();

      if (session != null) {
        // Proactively refresh token on account switch too.
        final refreshed = await _refreshToken(session);
        state = AuthAuthenticated(refreshed ?? session);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthError('Switch failed: $e');
    }
  }

  /// Removes a session and logs out if it was the active one.
  Future<void> removeAccount(String studentId) async {
    await _storage.removeSession(studentId);
    ref.invalidate(sessionsProvider);
    final activeId = await _storage.getActiveSessionId();
    if (activeId == studentId) {
      await _storage.clearActiveSession();
      final sessions = await _storage.getSessions();
      if (sessions.isNotEmpty) {
        await switchAccount(sessions.first.studentId);
      } else {
        state = const AuthUnauthenticated();
      }
    }
  }

  /// Logs out the current session (does not remove it from storage).
  Future<void> logout() async {
    await _storage.clearActiveSession();
    // Clear cache to prevent stale data leaking across accounts.
    await _clearCache();

    // Check if there are other saved sessions to show the account switcher.
    final sessions = await _storage.getSessions();
    if (sessions.isNotEmpty) {
      state = const AuthNeedsAccountSelection();
    } else {
      state = const AuthUnauthenticated();
    }
  }
}
