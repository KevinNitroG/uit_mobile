/// A single course entry in a semester.
class Course {
  final int id;
  final String classCode; // malop
  final String room; // phonghoc
  final String? lecturerName; // magv[0].hoten
  final String? lecturerEmail; // magv[0].email
  final String department; // khoaql
  final String dayOfWeek; // thu
  final String periods; // tiet
  final String? subjectCode; // mamh
  final String? subjectName; // tenmh
  final String credits; // sotc (credits for this class group)
  final String? totalCredits; // sotinchi (total credits for the subject)
  final String? teachingFormat; // hinhthucgd (LT, HT2, etc.)
  final String? ht2Schedule; // ht2_lichgapsv (HT2 meeting schedule)
  final String? startDate; // ngaybatdau
  final String? endDate; // ngayketthuc
  final List<({String name, String email})> lecturers; // all magv entries

  const Course({
    required this.id,
    required this.classCode,
    required this.room,
    this.lecturerName,
    this.lecturerEmail,
    required this.department,
    required this.dayOfWeek,
    required this.periods,
    this.subjectCode,
    this.subjectName,
    this.credits = '0',
    this.totalCredits,
    this.teachingFormat,
    this.ht2Schedule,
    this.startDate,
    this.endDate,
    this.lecturers = const [],
  });

  /// Whether this course is an HT2 (hình thức 2) class.
  bool get isHT2 => teachingFormat == 'HT2';

  factory Course.fromJson(Map<String, dynamic> json) {
    // magv can be null, a String, or a List of {hoten, email} objects
    String? lecturerName;
    String? lecturerEmail;
    final lecturers = <({String name, String email})>[];
    final magv = json['magv'];
    if (magv is List && magv.isNotEmpty) {
      for (final entry in magv) {
        if (entry is Map<String, dynamic>) {
          final name = entry['hoten'] as String? ?? '';
          final email = entry['email'] as String? ?? '';
          lecturers.add((name: name, email: email));
        }
      }
      if (lecturers.isNotEmpty) {
        lecturerName = lecturers.first.name;
        lecturerEmail = lecturers.first.email;
      }
    } else if (magv is String) {
      lecturerName = magv;
    }

    return Course(
      id: json['id'] as int? ?? 0,
      classCode: json['malop'] as String? ?? '',
      room: json['phonghoc'] as String? ?? '',
      lecturerName: lecturerName,
      lecturerEmail: lecturerEmail,
      department: json['khoaql'] as String? ?? '',
      dayOfWeek: json['thu'] as String? ?? '',
      periods: json['tiet'] as String? ?? '',
      subjectCode: json['mamh'] as String?,
      subjectName: json['tenmh'] as String?,
      credits: json['sotc']?.toString() ?? '0',
      totalCredits: json['sotinchi']?.toString(),
      teachingFormat: json['hinhthucgd'] as String?,
      ht2Schedule: json['ht2_lichgapsv'] as String?,
      startDate: json['ngaybatdau'] as String?,
      endDate: json['ngayketthuc'] as String?,
      lecturers: lecturers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'malop': classCode,
      'phonghoc': room,
      'magv': lecturers.isNotEmpty
          ? lecturers.map((l) => {'hoten': l.name, 'email': l.email}).toList()
          : lecturerName != null
          ? [
              {'hoten': lecturerName, 'email': lecturerEmail},
            ]
          : null,
      'khoaql': department,
      'thu': dayOfWeek,
      'tiet': periods,
      'mamh': subjectCode,
      'tenmh': subjectName,
      'sotc': credits,
      'sotinchi': totalCredits,
      'hinhthucgd': teachingFormat,
      'ht2_lichgapsv': ht2Schedule,
      'ngaybatdau': startDate,
      'ngayketthuc': endDate,
    };
  }
}

/// A semester grouping of courses.
class Semester {
  final String name;
  final List<Course> courses;

  const Semester({required this.name, required this.courses});

  factory Semester.fromJson(Map<String, dynamic> json) {
    // API returns name as either int or String
    final nameValue = json['name'];
    final name = nameValue is int
        ? nameValue.toString()
        : (nameValue as String? ?? '');

    return Semester(
      name: name,
      courses:
          (json['course'] as List<dynamic>?)
              ?.map((e) => Course.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'course': courses.map((c) => c.toJson()).toList()};
  }
}
