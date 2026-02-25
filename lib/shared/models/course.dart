import 'package:flutter/material.dart';

/// Teaching format for a course.
///
/// API field: `hinhthucgd`.
///   - `"LT"` → Regular lecture ([TeachingFormat.lt])
///   - `"HT2"` → Hình thức 2 ([TeachingFormat.ht2])
///   - `"TTTN"` → Thực tập tốt nghiệp ([TeachingFormat.tttn])
///   - `"KLTN"` → Khoá luận tốt nghiệp ([TeachingFormat.kltn])
enum TeachingFormat {
  lt,
  ht2,
  tttn,
  kltn;

  /// Parses the raw API string into a [TeachingFormat].
  static TeachingFormat? fromApi(String? raw) {
    return switch (raw?.toUpperCase()) {
      'LT' => TeachingFormat.lt,
      'HT2' => TeachingFormat.ht2,
      'TTTN' => TeachingFormat.tttn,
      'KLTN' => TeachingFormat.kltn,
      _ => null,
    };
  }

  /// Display label for the badge.
  String get label => switch (this) {
    TeachingFormat.lt => 'LT',
    TeachingFormat.ht2 => 'HT2',
    TeachingFormat.tttn => 'TTTN',
    TeachingFormat.kltn => 'KLTN',
  };

  /// Badge background color.
  Color badgeColor(ColorScheme cs) => switch (this) {
    TeachingFormat.lt => cs.primaryContainer,
    TeachingFormat.ht2 => cs.tertiaryContainer,
    TeachingFormat.tttn => cs.secondaryContainer,
    TeachingFormat.kltn => cs.errorContainer,
  };

  /// Badge foreground (text) color.
  Color badgeTextColor(ColorScheme cs) => switch (this) {
    TeachingFormat.lt => cs.onPrimaryContainer,
    TeachingFormat.ht2 => cs.onTertiaryContainer,
    TeachingFormat.tttn => cs.onSecondaryContainer,
    TeachingFormat.kltn => cs.onErrorContainer,
  };

  /// Whether this format is a non-lecture type (HT2/TTTN/KLTN).
  bool get isNonLecture => this != TeachingFormat.lt;
}

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
  final String? teachingFormat; // hinhthucgd (LT, HT2, TTTN, KLTN, etc.)
  final TeachingFormat? format; // parsed enum from teachingFormat
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
    this.format,
    this.ht2Schedule,
    this.startDate,
    this.endDate,
    this.lecturers = const [],
  });

  /// Whether this course is a non-lecture type (HT2, TTTN, or KLTN).
  bool get isHT2 => format != null && format!.isNonLecture;

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

    final rawFormat = json['hinhthucgd'] as String?;

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
      teachingFormat: rawFormat,
      format: TeachingFormat.fromApi(rawFormat),
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
