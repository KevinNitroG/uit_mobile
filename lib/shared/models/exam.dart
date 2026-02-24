/// A single exam entry parsed from the `exams` map in the student data response.
///
/// The API returns exams as a flat `Map<String, Map<String, String>>` where the
/// outer key is the class code (malop) and the inner map contains exam details
/// (room, date, time, etc.). This class wraps one entry.
class Exam {
  /// The class code, e.g. "IT001.O13".
  final String classCode;

  /// Raw key-value pairs for this exam, e.g. `{phongthi: A101, ngaythi: ...}`.
  final Map<String, String> details;

  const Exam({required this.classCode, required this.details});

  /// Parses the flat `exams` map from the API into a list of [Exam] entries.
  static List<Exam> listFromJson(Map<String, dynamic> json) {
    return json.entries.map((e) {
      final raw = e.value;
      final details = <String, String>{};
      if (raw is Map) {
        for (final entry in raw.entries) {
          final v = entry.value;
          if (v != null) details[entry.key as String] = v.toString();
        }
      }
      return Exam(classCode: e.key, details: details);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Convenience getters for well-known field names from the UIT API.
  // ---------------------------------------------------------------------------

  String? get room => details['phongthi'];
  String? get date => details['ngaythi'];
  String? get time => details['giobatdau'];
  String? get subjectName => details['tenmh'];
  String? get subjectCode => details['mamh'];
}
