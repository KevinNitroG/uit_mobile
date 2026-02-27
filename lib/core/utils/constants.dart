/// API base URL for UIT services.
const String kApiBaseUrl = 'https://apiservice.uit.edu.vn';

/// Prefix used for encoding credentials and tokens.
const String kEncodingPrefix = '3sn@fah.';

/// Authorization header scheme.
const String kAuthScheme = 'UitAu';

/// Secure storage keys.
abstract final class StorageKeys {
  static const String sessions = 'sessions';
  static const String activeSessionId = 'active_session_id';
}

/// Hive box names.
abstract final class HiveBoxes {
  static const String courses = 'courses';
  static const String scores = 'scores';
  static const String notifications = 'notifications';
  static const String deadlines = 'deadlines';
  static const String userInfo = 'user_info';
  static const String exams = 'exams';
  static const String fees = 'fees';
  static const String metadata = 'metadata';
}

/// Hive metadata keys.
abstract final class HiveMetadataKeys {
  /// ISO-8601 timestamp of the last successful student-data network fetch.
  static const String studentDataFetchedAt = 'student_data_fetched_at';
}
