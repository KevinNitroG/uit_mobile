/// A tuition fee record.
class Fee {
  final String amountDue; // phaidong
  final String amountPaid; // dadong
  final String semester; // hocky
  final String year; // namhoc

  const Fee({
    required this.amountDue,
    required this.amountPaid,
    required this.semester,
    required this.year,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      amountDue: json['phaidong'] as String? ?? '0',
      amountPaid: json['dadong'] as String? ?? '0',
      semester: json['hocky'] as String? ?? '',
      year: json['namhoc'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phaidong': amountDue,
      'dadong': amountPaid,
      'hocky': semester,
      'namhoc': year,
    };
  }
}
