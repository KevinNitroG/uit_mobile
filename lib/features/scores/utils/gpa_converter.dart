/// GPA conversion utilities for the Vietnamese university grading system.
///
/// Raw data is on the **10-point scale**. This utility converts to:
/// - 4-point scale (used for graduation classification)
/// - Letter grade (A, B+, B, C+, C, D+, D, F)
/// - Graduation classification (Xuất sắc / Giỏi / Khá / Trung bình / Yếu)
library;

// ---------------------------------------------------------------------------
// 10-point classification (thang 10)
// Xuất sắc: 9.0–10, Giỏi: 8.0–<9.0, Khá: 7.0–<8.0,
// Trung bình: 5.0–<7.0, Yếu/Kém: <5.0
// ---------------------------------------------------------------------------

/// Returns the Vietnamese classification for a raw 10-point GPA.
String tenPointClass(double gpa10) {
  if (gpa10 >= 9.0) return 'Xuất sắc';
  if (gpa10 >= 8.0) return 'Giỏi';
  if (gpa10 >= 7.0) return 'Khá';
  if (gpa10 >= 5.0) return 'Trung bình';
  return 'Yếu';
}

// ---------------------------------------------------------------------------
// 10-point → 4-point  (step mapping, used for INDIVIDUAL subject grades)
//
// Mapping per user's grading system (no A- intermediate step):
//   9.0–10.0  → 4.0  (A)
//   8.0–<9.0  → 3.5  (B+)
//   7.0–<8.0  → 3.0  (B)
//   6.5–<7.0  → 2.5  (C+)
//   5.5–<6.5  → 2.0  (C)
//   5.0–<5.5  → 1.5  (D+)
//   4.0–<5.0  → 1.0  (D)
//   <4.0      → 0.0  (F)
// ---------------------------------------------------------------------------

/// Converts a single subject grade from 10-point to 4-point scale.
/// Returns `null` if [grade] is null.
double? tenToFour(double? grade) {
  if (grade == null) return null;
  if (grade >= 9.0) return 4.0; // A
  if (grade >= 8.0) return 3.5; // B+
  if (grade >= 7.0) return 3.0; // B
  if (grade >= 6.5) return 2.5; // C+
  if (grade >= 5.5) return 2.0; // C
  if (grade >= 5.0) return 1.5; // D+
  if (grade >= 4.0) return 1.0; // D
  return 0.0; // F
}

// ---------------------------------------------------------------------------
// 4-point → letter grade
//   A  (Giỏi/Xuất sắc): 4.0
//   B+ (Khá giỏi):      3.5
//   B  (Khá):           3.0
//   C+ (Trung bình khá):2.5
//   C  (Trung bình):    2.0
//   D+ (Trung bình yếu):1.5
//   D  (Yếu):           1.0
//   F  (Kém - trượt):   0
// ---------------------------------------------------------------------------

/// Maps a 4-point GPA value to the corresponding letter grade.
String fourToLetter(double gpa4) {
  if (gpa4 >= 4.0) return 'A';
  if (gpa4 >= 3.5) return 'B+';
  if (gpa4 >= 3.0) return 'B';
  if (gpa4 >= 2.5) return 'C+';
  if (gpa4 >= 2.0) return 'C';
  if (gpa4 >= 1.5) return 'D+';
  if (gpa4 >= 1.0) return 'D';
  return 'F';
}

// ---------------------------------------------------------------------------
// Graduation classification (xếp loại tốt nghiệp, dựa trên thang 4.0)
//
//   Xuất sắc : 3.60–4.00
//   Giỏi     : 3.20–3.59
//   Khá      : 2.50–3.19
//   Trung bình: 2.00–2.49
//   Yếu      : <2.00
// ---------------------------------------------------------------------------

/// Returns the Vietnamese graduation classification label for a 4-point GPA.
String graduationClass(double gpa4) {
  if (gpa4 >= 3.60) return 'Xuất sắc';
  if (gpa4 >= 3.20) return 'Giỏi';
  if (gpa4 >= 2.50) return 'Khá';
  if (gpa4 >= 2.00) return 'Trung bình';
  return 'Yếu';
}

// ---------------------------------------------------------------------------
// GPA display mode
// ---------------------------------------------------------------------------

/// Cycles through available GPA display modes when tapping the GPA card.
enum GpaDisplayMode {
  /// Raw 10-point scale (e.g. 8.62)
  tenPoint,

  /// Converted 4-point scale (e.g. 3.45)
  fourPoint,

  /// Letter grade derived from 4-point GPA (e.g. B+)
  letter,
}

extension GpaDisplayModeX on GpaDisplayMode {
  /// Returns the next mode in the cycle.
  GpaDisplayMode get next {
    final values = GpaDisplayMode.values;
    return values[(index + 1) % values.length];
  }

  /// Short label shown as a badge/hint below the GPA value.
  String get label {
    switch (this) {
      case GpaDisplayMode.tenPoint:
        return '/10';
      case GpaDisplayMode.fourPoint:
        return '/4.0';
      case GpaDisplayMode.letter:
        return 'Letter';
    }
  }
}

// ---------------------------------------------------------------------------
// Overall GPA conversion  (thang 10 → thang 4, dành cho điểm trung bình tích lũy)
//
// For the OVERALL accumulated GPA (already a weighted average on the 10-pt
// scale), the correct approach is to linearly scale:
//   gpa4 = gpa10 / 10 * 4
//
// This is the standard used by most Vietnamese universities when reporting an
// accumulated GPA on the 4-point scale, and matches user expectation
// (e.g. 8.62 / 10 * 4 = 3.45).
//
// The step-table (tenToFour) is only correct for INDIVIDUAL subject grades.
// ---------------------------------------------------------------------------

/// Converts an overall 10-point accumulated GPA to 4-point scale using
/// linear scaling: `gpa4 = gpa10 / 10 * 4`.
double overallTenToFour(double gpa10) => (gpa10 / 10.0) * 4.0;

// ---------------------------------------------------------------------------
// Unified format helper
// ---------------------------------------------------------------------------

/// Formats [gpa10] (on the 10-point scale) according to [mode].
///
/// For [GpaDisplayMode.fourPoint] and [GpaDisplayMode.letter], the overall
/// linear formula ([overallTenToFour]) is used — not the per-subject step
/// table — because [gpa10] is an already-averaged value.
String formatGpa(double gpa10, GpaDisplayMode mode) {
  switch (mode) {
    case GpaDisplayMode.tenPoint:
      return gpa10.toStringAsFixed(2);
    case GpaDisplayMode.fourPoint:
      return overallTenToFour(gpa10).toStringAsFixed(2);
    case GpaDisplayMode.letter:
      return fourToLetter(overallTenToFour(gpa10));
  }
}
