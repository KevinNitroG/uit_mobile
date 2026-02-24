import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/core/network/api_service.dart';
import 'package:uit_mobile/core/storage/hive_cache_service.dart';
import 'package:uit_mobile/core/storage/secure_storage_service.dart';
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
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = const AuthUnauthenticated();
    }
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
    await _storage.removeSession(studentId);
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
    // Clear cached data to prevent stale data leaking across accounts.
    await _cache.clearBox('courses');
    await _cache.clearBox('scores');
    await _cache.clearBox('notifications');
    await _cache.clearBox('deadlines');
    await _cache.clearBox('user_info');
    state = const AuthUnauthenticated();
  }
}
