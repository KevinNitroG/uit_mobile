/// A tuition fee record.
class Fee {
  final String amountDue; // phaidong
  final String amountPaid; // dadong
  final String previousDebt; // notruoc
  final String semester; // hocky
  final String year; // namhoc

  /// Registered subjects string from the API, e.g. "IT004(5.0),IT005(5.0)".
  /// May be null or empty when no subjects are registered yet.
  final String? dkhp;

  const Fee({
    required this.amountDue,
    required this.amountPaid,
    required this.previousDebt,
    required this.semester,
    required this.year,
    this.dkhp,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      amountDue: json['phaidong'] as String? ?? '0',
      amountPaid: json['dadong'] as String? ?? '0',
      previousDebt: json['notruoc'] as String? ?? '0',
      semester: json['hocky'] as String? ?? '',
      year: json['namhoc'] as String? ?? '',
      dkhp: json['dkhp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phaidong': amountDue,
      'dadong': amountPaid,
      'notruoc': previousDebt,
      'hocky': semester,
      'namhoc': year,
      'dkhp': dkhp,
    };
  }

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  double get due => double.tryParse(amountDue) ?? 0;
  double get paid => double.tryParse(amountPaid) ?? 0;
  double get debt => double.tryParse(previousDebt) ?? 0;

  /// remaining = max(due - paid + previousDebt, 0)
  /// Negative result (over-payment / credit) is clamped to 0.
  double get remaining {
    final r = due - paid + debt;
    return r < 0 ? 0 : r;
  }

  /// Whether this semester's fee is fully settled (remaining == 0).
  bool get isPaid => remaining <= 0;

  /// Progress value in [0.0, 1.0].
  ///
  /// Represents the fraction paid: paid / due.
  /// When due is zero, returns 1.0 (nothing owed).
  double get progress {
    if (due <= 0) return 1.0;
    return (paid / due).clamp(0.0, 1.0);
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
