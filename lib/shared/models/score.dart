/// A single score entry.
class Score {
  final String subjectCode; // mamh
  final String classCode; // malop
  final String? finalGrade; // diem
  final String? grade1; // diem1
  final String? grade2; // diem2
  final String? grade3; // diem3
  final String? grade4; // diem4
  final String weight1; // heso1
  final String weight2; // heso2
  final String weight3; // heso3
  final String weight4; // heso4
  final String semester; // hocky
  final String year; // namhoc
  final String credits; // sotc
  final String subjectName; // tenmh
  final String subjectType; // loaimh

  const Score({
    required this.subjectCode,
    required this.classCode,
    this.finalGrade,
    this.grade1,
    this.grade2,
    this.grade3,
    this.grade4,
    required this.weight1,
    required this.weight2,
    required this.weight3,
    required this.weight4,
    required this.semester,
    required this.year,
    required this.credits,
    required this.subjectName,
    required this.subjectType,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      subjectCode: json['mamh'] as String? ?? '',
      classCode: json['malop'] as String? ?? '',
      finalGrade: json['diem'] as String?,
      grade1: json['diem1'] as String?,
      grade2: json['diem2'] as String?,
      grade3: json['diem3'] as String?,
      grade4: json['diem4'] as String?,
      weight1: json['heso1'] as String? ?? '0',
      weight2: json['heso2'] as String? ?? '0',
      weight3: json['heso3'] as String? ?? '0',
      weight4: json['heso4'] as String? ?? '0',
      semester: json['hocky'] as String? ?? '',
      year: json['namhoc'] as String? ?? '',
      credits: json['sotc'] as String? ?? '0',
      subjectName: json['tenmh'] as String? ?? '',
      subjectType: json['loaimh'] as String? ?? '',
    );
  }

  /// Whether this course is exempted ("Miễn").
  /// Exempted courses have all component weights = 0 in the API.
  bool get isExempted {
    final w1 = double.tryParse(weight1) ?? 0;
    final w2 = double.tryParse(weight2) ?? 0;
    final w3 = double.tryParse(weight3) ?? 0;
    final w4 = double.tryParse(weight4) ?? 0;
    return w1 == 0 && w2 == 0 && w3 == 0 && w4 == 0;
  }

  /// Whether this course should be included in GPA calculation.
  /// Excluded: exempted courses and courses with non-numeric final grades.
  bool get countsForGpa {
    if (isExempted) return false;
    final grade = double.tryParse(finalGrade ?? '');
    if (grade == null) return false;
    final c = int.tryParse(credits) ?? 0;
    if (c <= 0) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'mamh': subjectCode,
      'malop': classCode,
      'diem': finalGrade,
      'diem1': grade1,
      'diem2': grade2,
      'diem3': grade3,
      'diem4': grade4,
      'heso1': weight1,
      'heso2': weight2,
      'heso3': weight3,
      'heso4': weight4,
      'hocky': semester,
      'namhoc': year,
      'sotc': credits,
      'tenmh': subjectName,
      'loaimh': subjectType,
    };
  }
}

/// A semester grouping of scores.
class ScoreSemester {
  final String name;
  final List<Score> scores;

  const ScoreSemester({required this.name, required this.scores});

  factory ScoreSemester.fromJson(Map<String, dynamic> json) {
    // API returns name as either int or String
    final nameValue = json['name'];
    final name = nameValue is int
        ? nameValue.toString()
        : (nameValue as String? ?? '');

    return ScoreSemester(
      name: name,
      scores:
          (json['score'] as List<dynamic>?)
              ?.map((e) => Score.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'score': scores.map((s) => s.toJson()).toList()};
  }
}
