import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/core/utils/constants.dart';
import 'package:uit_mobile/shared/models/user_session.dart';

/// Provider for [SecureStorageService].
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Manages encrypted storage for user sessions and tokens.
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  /// Retrieves all stored user sessions.
  Future<List<UserSession>> getSessions() async {
    final raw = await _storage.read(key: StorageKeys.sessions);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => UserSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Saves the full list of [sessions].
  Future<void> saveSessions(List<UserSession> sessions) async {
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _storage.write(key: StorageKeys.sessions, value: encoded);
  }

  /// Adds or updates a single [session] (matched by [UserSession.studentId]).
  Future<void> upsertSession(UserSession session) async {
    final sessions = await getSessions();
    final index = sessions.indexWhere((s) => s.studentId == session.studentId);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }
    await saveSessions(sessions);
  }

  /// Removes a session by [studentId].
  Future<void> removeSession(String studentId) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.studentId == studentId);
    await saveSessions(sessions);
  }

  // ---------------------------------------------------------------------------
  // Active session
  // ---------------------------------------------------------------------------

  /// Gets the currently active session ID (student ID).
  Future<String?> getActiveSessionId() async {
    return _storage.read(key: StorageKeys.activeSessionId);
  }

  /// Sets the currently active session ID.
  Future<void> setActiveSessionId(String studentId) async {
    await _storage.write(key: StorageKeys.activeSessionId, value: studentId);
  }

  /// Clears the active session (logout).
  Future<void> clearActiveSession() async {
    await _storage.delete(key: StorageKeys.activeSessionId);
  }

  /// Convenience: returns the full active [UserSession] or `null`.
  Future<UserSession?> getActiveSession() async {
    final activeId = await getActiveSessionId();
    if (activeId == null) return null;
    final sessions = await getSessions();
    try {
      return sessions.firstWhere((s) => s.studentId == activeId);
    } catch (_) {
      return null;
    }
  }
}
