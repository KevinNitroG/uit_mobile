/// Status of a deadline/assignment.
///
/// API mapping:
///   `null`        → [DeadlineStatus.pending]   (not submitted, still within deadline)
///   `"new"`       → [DeadlineStatus.overdue]    (not submitted, past deadline)
///   `"submitted"` → [DeadlineStatus.submitted]  (already submitted)
enum DeadlineStatus {
  pending,
  overdue,
  submitted;

  /// Parses the raw API status string into a [DeadlineStatus].
  static DeadlineStatus fromApi(String? raw) {
    return switch (raw) {
      'submitted' => DeadlineStatus.submitted,
      'new' => DeadlineStatus.overdue,
      _ => DeadlineStatus.pending,
    };
  }

  /// Converts back to the API string representation.
  String? toApi() {
    return switch (this) {
      DeadlineStatus.submitted => 'submitted',
      DeadlineStatus.overdue => 'new',
      DeadlineStatus.pending => null,
    };
  }
}

/// Parses a value that may be a bool, a String ("1"/"0"/"true"/"false"), or null.
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

/// A deadline/assignment entry.
class Deadline {
  /// Moodle course-module ID — comes from the `id` field in the API response.
  final int cmid;

  final String shortname;
  final String name;
  final String niceDate;
  final DeadlineStatus status;

  /// Whether the deadline submission is closed (no longer accepting uploads).
  final bool closed;

  const Deadline({
    required this.cmid,
    required this.shortname,
    required this.name,
    required this.niceDate,
    this.status = DeadlineStatus.pending,
    this.closed = false,
  });

  /// URL to the assignment on the Moodle courses site.
  String get url => 'https://courses.uit.edu.vn/mod/assign/view.php?id=$cmid';

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      cmid: int.parse(json['id'].toString()),
      shortname: json['shortname'] as String? ?? '',
      name: json['name'] as String? ?? '',
      niceDate: json['niceDate'] as String? ?? '',
      status: DeadlineStatus.fromApi(json['status'] as String?),
      closed: _parseBool(json['closed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': cmid,
      'shortname': shortname,
      'name': name,
      'niceDate': niceDate,
      'status': status.toApi(),
      'closed': closed,
    };
  }
}
