import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/core/network/dio_client.dart';
import 'package:uit_mobile/core/utils/constants.dart';
import 'package:uit_mobile/shared/models/models.dart';

/// Provider for [UitApiService].
final uitApiServiceProvider = Provider<UitApiService>((ref) {
  return UitApiService(ref.read(dioProvider));
});

/// High-level wrapper around UIT API endpoints.
class UitApiService {
  final Dio _dio;

  UitApiService(this._dio);

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  /// Generates a new token using encoded credentials.
  /// Returns `(token, expires)` on success.
  Future<({String token, DateTime expires})> generateToken(
    String encodedCredentials,
  ) async {
    final response = await _dio.post(
      '/v2/stc/generate',
      data: {},
      options: Options(
        headers: {'Authorization': '$kAuthScheme $encodedCredentials'},
      ),
    );
    final data = response.data as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      expires: DateTime.parse(data['expires'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // User info
  // ---------------------------------------------------------------------------

  /// Fetches current user profile.
  Future<UserInfo> getUserInfo() async {
    final response = await _dio.get('/v2/data?task=current');
    return UserInfo.fromJson(response.data as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Full student data
  // ---------------------------------------------------------------------------

  /// Fetches the complete student data (courses, scores, fees, notifications,
  /// deadlines, exams).
  Future<StudentData> getStudentData() async {
    final response = await _dio.get('/v2/data?task=all&v=1');
    return StudentData.fromJson(response.data as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Convenience parsed accessors
  // ---------------------------------------------------------------------------

  /// Fetches and parses all semesters of courses.
  Future<List<Semester>> getCourses() async {
    final data = await getStudentData();
    return data.coursesRaw
        .map((e) => Semester.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches and parses all semesters of scores.
  Future<List<ScoreSemester>> getScores() async {
    final data = await getStudentData();
    return data.scoresRaw
        .map((e) => ScoreSemester.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches and parses fee records.
  Future<List<Fee>> getFees() async {
    final data = await getStudentData();
    return data.feeRaw
        .map((e) => Fee.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches and parses notifications.
  Future<List<UitNotification>> getNotifications() async {
    final data = await getStudentData();
    return data.notifyRaw
        .map((e) => UitNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches and parses deadlines.
  Future<List<Deadline>> getDeadlines() async {
    final data = await getStudentData();
    return data.deadlineRaw
        .map((e) => Deadline.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
