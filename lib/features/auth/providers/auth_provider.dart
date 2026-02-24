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
  Future<void> _restoreSession() async {
    try {
      final session = await _storage.getActiveSession();
      if (session != null && session.token != null) {
        state = AuthAuthenticated(session);
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

  /// Clears all Hive cache boxes so the next fetch retrieves fresh data for the
  /// newly active account.
  Future<void> _clearCache() async {
    await _cache.clearBox(HiveBoxes.courses);
    await _cache.clearBox(HiveBoxes.scores);
    await _cache.clearBox(HiveBoxes.notifications);
    await _cache.clearBox(HiveBoxes.deadlines);
    await _cache.clearBox(HiveBoxes.userInfo);
    await _cache.clearBox(HiveBoxes.exams);
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
  ///
  /// Deliberately avoids an intermediate [AuthLoading] state so that watchers
  /// (e.g. [studentDataProvider]) only rebuild **once** — when the new
  /// [AuthAuthenticated] state is emitted with a clean cache.  Setting
  /// [AuthLoading] first would trigger an extra rebuild that returns empty data,
  /// and the subsequent [AuthAuthenticated] rebuild may not re-trigger watchers
  /// correctly depending on Riverpod's coalescing behaviour.
  Future<void> switchAccount(String studentId) async {
    try {
      // Prepare everything before emitting a new state so watchers see a single
      // transition from the old AuthAuthenticated(A) → AuthAuthenticated(B).
      await _storage.setActiveSessionId(studentId);
      final session = await _storage.getActiveSession();
      ref.invalidate(sessionsProvider);

      // Clear cache so the data providers fetch fresh data for this account.
      await _clearCache();

      if (session != null) {
        state = AuthAuthenticated(session);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthError('Switch failed: $e');
    }
  }

  /// Removes a session and logs out if it was the active one.
  Future<void> removeAccount(String studentId) async {
    // Read active ID before removing the session to avoid race conditions.
    final activeId = await _storage.getActiveSessionId();

    await _storage.removeSession(studentId);
    ref.invalidate(sessionsProvider);

    if (activeId == studentId) {
      await _storage.clearActiveSession();
      await _clearCache();

      final sessions = await _storage.getSessions();
      if (sessions.isNotEmpty) {
        await switchAccount(sessions.first.studentId);
      } else {
        state = const AuthUnauthenticated();
      }
    }
  }

  /// Logs out the current session and removes its credentials from storage.
  Future<void> logout() async {
    // Remove the active session's credentials from persistent storage.
    final activeId = await _storage.getActiveSessionId();
    if (activeId != null) {
      await _storage.removeSession(activeId);
    }
    await _storage.clearActiveSession();

    // Clear cache to prevent stale data leaking across accounts.
    await _clearCache();

    ref.invalidate(sessionsProvider);

    // Check if there are other saved sessions to show the account switcher.
    final sessions = await _storage.getSessions();
    if (sessions.isNotEmpty) {
      state = const AuthNeedsAccountSelection();
    } else {
      state = const AuthUnauthenticated();
    }
  }
}
