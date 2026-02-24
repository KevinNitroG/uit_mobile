/// A tuition fee record.
class Fee {
  final String amountDue; // phaidong
  final String amountPaid; // dadong
  final String semester; // hocky
  final String year; // namhoc

  /// Registered subjects string from the API, e.g. "IT004(5.0),IT005(5.0)".
  /// May be null or empty when no subjects are registered yet.
  final String? dkhp;

  const Fee({
    required this.amountDue,
    required this.amountPaid,
    required this.semester,
    required this.year,
    this.dkhp,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      amountDue: json['phaidong'] as String? ?? '0',
      amountPaid: json['dadong'] as String? ?? '0',
      semester: json['hocky'] as String? ?? '',
      year: json['namhoc'] as String? ?? '',
      dkhp: json['dkhp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phaidong': amountDue,
      'dadong': amountPaid,
      'hocky': semester,
      'namhoc': year,
      'dkhp': dkhp,
    };
  }

  /// Parses [dkhp] into a list of (subjectCode, credits) pairs.
  /// e.g. "IT004(5.0),IT005(5.0)" → [("IT004", "5.0"), ("IT005", "5.0")]
  List<({String code, String credits})> get subjects {
    if (dkhp == null || dkhp!.isEmpty) return [];
    return RegExp(r'(\w+)\(([^)]+)\)')
        .allMatches(dkhp!)
        .map((m) => (code: m.group(1)!, credits: m.group(2)!))
        .toList();
  }
}
