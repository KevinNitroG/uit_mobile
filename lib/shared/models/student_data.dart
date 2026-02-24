/// Full student data response from `/v2/data?task=all&v=1`.
class StudentData {
  final List<dynamic> coursesRaw;
  final List<dynamic> scoresRaw;
  final List<dynamic> feeRaw;
  final List<dynamic> notifyRaw;
  final List<dynamic> deadlineRaw;
  final Map<String, dynamic> examsRaw;

  const StudentData({
    required this.coursesRaw,
    required this.scoresRaw,
    required this.feeRaw,
    required this.notifyRaw,
    required this.deadlineRaw,
    required this.examsRaw,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      coursesRaw: json['courses'] as List<dynamic>? ?? [],
      scoresRaw: json['scores'] as List<dynamic>? ?? [],
      feeRaw: json['fee'] as List<dynamic>? ?? [],
      notifyRaw: json['notify'] as List<dynamic>? ?? [],
      deadlineRaw: json['deadline'] as List<dynamic>? ?? [],
      examsRaw: json['exams'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': coursesRaw,
      'scores': scoresRaw,
      'fee': feeRaw,
      'notify': notifyRaw,
      'deadline': deadlineRaw,
      'exams': examsRaw,
    };
  }
}
