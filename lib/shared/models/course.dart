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

  const Course({
    required this.id,
    required this.classCode,
    required this.room,
    this.lecturerName,
    this.lecturerEmail,
    required this.department,
    required this.dayOfWeek,
    required this.periods,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // magv can be null, a String, or a List of {hoten, email} objects
    String? lecturerName;
    String? lecturerEmail;
    final magv = json['magv'];
    if (magv is List && magv.isNotEmpty) {
      final first = magv[0];
      if (first is Map<String, dynamic>) {
        lecturerName = first['hoten'] as String?;
        lecturerEmail = first['email'] as String?;
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'malop': classCode,
      'phonghoc': room,
      'magv': lecturerName != null
          ? [
              {'hoten': lecturerName, 'email': lecturerEmail},
            ]
          : null,
      'khoaql': department,
      'thu': dayOfWeek,
      'tiet': periods,
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
