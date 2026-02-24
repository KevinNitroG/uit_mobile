/// A single exam entry parsed from the `exams` map in the student data response.
///
/// The API returns exams as a flat `Map<String, Map<String, String>>` where the
/// outer key is the exam date (e.g. "06-01-2025") and the inner map contains
/// slot keys (e.g. "ca2") mapped to a description string.  This class wraps one
/// slot entry and stores the date separately for sorting.
class Exam {
  /// The class code extracted from the description, e.g. "IT005.P13".
  /// Falls back to the slot key if extraction fails.
  final String classCode;

  /// Raw key-value pairs for this exam, e.g. `{phongthi: A101, ngaythi: ...}`.
  final Map<String, String> details;

  /// The exam date string as provided by the API outer key (e.g. "06-01-2025").
  final String? dateKey;

  const Exam({required this.classCode, required this.details, this.dateKey});

  /// Parses the flat `exams` map from the API into a list of [Exam] entries.
  ///
  /// API shape: `{ "06-01-2025": { "ca2": "Ca 2(9h30): IT005.P13 (...), Phòng B4.22" } }`
  static List<Exam> listFromJson(Map<String, dynamic> json) {
    final exams = <Exam>[];
    for (final dateEntry in json.entries) {
      final dateStr = dateEntry.key; // e.g. "06-01-2025"
      final slots = dateEntry.value;
      if (slots is Map) {
        for (final slotEntry in slots.entries) {
          final slotKey = slotEntry.key as String; // e.g. "ca2"
          final desc = slotEntry.value?.toString() ?? '';
          exams.add(
            Exam(
              classCode: _extractClassCode(desc) ?? slotKey,
              details: {'slot': slotKey, 'description': desc},
              dateKey: dateStr,
            ),
          );
        }
      }
    }
    return exams;
  }

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------

  /// Exam date from the outer map key.
  String? get date => dateKey;

  /// Exam room extracted from description (text after "Phòng " or "Phong ").
  String? get room {
    final desc = details['description'] ?? '';
    final match = RegExp(r'Ph[oò]ng\s+(\S+)').firstMatch(desc);
    return match?.group(1);
  }

  /// Exam time extracted from description, e.g. "9h30".
  String? get time {
    final desc = details['description'] ?? '';
    // Matches patterns like "Ca 2(9h30)" or "Ca 67890(7h30)"
    final match = RegExp(r'\((\d+h\d+)\)').firstMatch(desc);
    return match?.group(1);
  }

  /// Full subject name extracted from description, e.g. "Nhập môn mạng máy tính".
  String? get subjectName {
    final desc = details['description'] ?? '';
    // Pattern: "CLASS_CODE (Subject Name)," or "CLASS_CODE (Subject Name),"
    final match = RegExp(r'\w+\.\w+\s+\((.+?)\)').firstMatch(desc);
    return match?.group(1);
  }

  /// Subject code extracted from description, e.g. "IT005.P13".
  String? get subjectCode => _extractClassCode(details['description'] ?? '');

  /// Extract a class code like "IT005.P13" from a description string.
  static String? _extractClassCode(String desc) {
    final match = RegExp(r'[A-Z]{2,}\d+\.\w+').firstMatch(desc);
    return match?.group(0);
  }
}
