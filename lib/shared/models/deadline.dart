/// Whether the deadline is still pending or already overdue.
///
/// Determined by comparing [Deadline.duedate] with the current time.
enum PendingStatus {
  pending,
  overdue;

  @override
  String toString() => name;
}

/// The submission status from the API.
///
/// API values:
///   `"submitted"` → [SubmittedStatus.submitted]
///   `"new"`       → [SubmittedStatus.notSubmitted]
///   `null`        → [SubmittedStatus.notSubmitted]
enum SubmittedStatus {
  submitted,
  notSubmitted;

  @override
  String toString() => name;
}

/// Whether the deadline is closed for submissions.
enum ClosedStatus {
  open,
  closed;

  @override
  String toString() => name;
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
  final int id;

  final String shortname;
  final String name;
  final String niceDate;

  /// Unix timestamp (seconds) from the API `duedate` field.
  final int duedate;

  /// Raw status string from API: "submitted", "new", or null.
  final String? rawStatus;

  /// Whether the deadline submission is closed (no longer accepting uploads).
  final bool closed;

  const Deadline({
    required this.id,
    required this.shortname,
    required this.name,
    required this.niceDate,
    required this.duedate,
    this.rawStatus,
    this.closed = false,
  });

  /// URL to the assignment on the Moodle courses site.
  String get url => 'https://courses.uit.edu.vn/mod/assign/view.php?id=$id';

  // ---------------------------------------------------------------------------
  // Derived statuses
  // ---------------------------------------------------------------------------

  /// Whether the deadline is pending (duedate in the future) or overdue (past).
  PendingStatus get pendingStatus {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return duedate > now ? PendingStatus.pending : PendingStatus.overdue;
  }

  /// The submission status derived from API `status` field:
  ///   - `"submitted"` → submitted
  ///   - `"new"` → notSubmitted
  ///   - `null` → notSubmitted
  SubmittedStatus get submittedStatus {
    if (rawStatus == 'submitted') return SubmittedStatus.submitted;
    return SubmittedStatus.notSubmitted;
  }

  /// Whether the deadline is closed or still open.
  ClosedStatus get closedStatus {
    return closed ? ClosedStatus.closed : ClosedStatus.open;
  }

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      id: int.parse(json['id'].toString()),
      shortname: json['shortname'] as String? ?? '',
      name: json['name'] as String? ?? '',
      niceDate: json['niceDate'] as String? ?? '',
      duedate: int.tryParse(json['duedate']?.toString() ?? '0') ?? 0,
      rawStatus: json['status'] as String?,
      closed: _parseBool(json['closed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortname': shortname,
      'name': name,
      'niceDate': niceDate,
      'duedate': duedate.toString(),
      'status': rawStatus,
      'closed': closed ? '1' : '0',
    };
  }
}
