### Original requirement

Overview score should have min width table and max width table for each. Ensure they have enough width to show. And currently we have ratio for 3, but I need to sepate the last column, and it would be 4, with ratio of 3 6 2 3. You need so HT2 type of class in timetable, like in another screen, we need to know even all of HT2, not like normal day. HT2 is "hình thức 2" in vietnamese, it doesn’t have static datetime, can be updated overtime, so you might want to choose a suitable icon for that screen. Check in the tuition fee related code, do not do any abs in calculation. The notification card doesn’t need the notification icon. Update the release please config, currently it doesn’t match the bump the version. In the score screen, calculate the credit including "Miễn" (called tín chỉ tích luỹ) and without "miễn" (called tín chỉ đã học). The score card should split number of subject • credit (with annotate credit or "tín chỉ" in vietnamese (in shortform of C or TC) • score in color. And so do the short form with inner subject card showing credit annotation. In the tuition fee screen, the remain should be called "nợ trước", in english is "previous debt" i guess. The overview section of homescreen should show how many credit in current semester beside how many subjects. The color of today in the timetable should only show as tertiary color when is it not selected, else just show as primary color.

You should diagnostic and make task, grouping my requirements in todo task into TASKS.md first, write in very detail.

Example data of HT2

```
[
  {
    "name": 2,
    "course": [
      {
        "thu": "2",
        "online": "0",
        "phonghoc": "C314",
        "magv": [
          {
            "hoten": "Nguyễn Duy Khánh",
            "email": "khanhnd@uit.edu.vn"
          }
        ],
        "ht2_lichgapsv": null,
        "khoaql": "CNPM",
        "thuchanh": "0",
        "sotc": "3",
        "dadk": "78",
        "ngonngu": "VN",
        "hinhthucgd": "LT",
        "malop": "SE361.Q21",
        "hocky": "2",
        "namhoc": "2025",
        "tiet": "1-3"
      },
      {
        "thu": "2",
        "online": "0",
        "phonghoc": "Sân Bóng Chuyền",
        "magv": [
          {
            "hoten": "Cao Hồng Châu",
            "email": "chchau@hcmuit.edu.vn"
          }
        ],
        "ht2_lichgapsv": null,
        "khoaql": "P.DTDH",
        "thuchanh": "0",
        "sotc": "0",
        "dadk": "60",
        "ngonngu": "VN",
        "hinhthucgd": "LT",
        "malop": "PE232.Q21",
        "hocky": "2",
        "namhoc": "2025",
        "tiet": "6-8"
      }
    ]
  },
  {
    "name": 3,
    "course": [
      {
        "thu": "3",
        "online": "0",
        "phonghoc": "C314",
        "magv": [
          {
            "hoten": "Võ Tuấn Kiệt",
            "email": "kietvt@uit.edu.vn"
          }
        ],
        "ht2_lichgapsv": null,
        "khoaql": "CNPM",
        "thuchanh": "0",
        "sotc": "2",
        "dadk": "77",
        "ngonngu": "VN",
        "hinhthucgd": "LT",
        "malop": "SE359.Q21",
        "hocky": "2",
        "namhoc": "2025",
        "tiet": "1-3"
      }
    ]
  },
  {
    "name": 4,
    "course": [
      {
        "thu": "4",
        "online": "0",
        "phonghoc": "C311",
        "magv": [
          {
            "hoten": "Nguyễn Thị Thanh Trúc",
            "email": "trucntt@uit.edu.vn"
          }
        ],
        "ht2_lichgapsv": null,
        "khoaql": "CNPM",
        "thuchanh": "0",
        "sotc": "3",
        "dadk": "66",
        "ngonngu": "VN",
        "hinhthucgd": "LT",
        "malop": "SE109.Q21",
        "hocky": "2",
        "namhoc": "2025",
        "tiet": "1-4"
      }
    ]
  },
  {
    "name": 5,
    "course": [
      {
        "thu": "5",
        "online": "0",
        "phonghoc": "C309",
        "magv": [
          {
            "hoten": "Trần Thị Hồng Yến",
            "email": "yentth@uit.edu.vn"
          }
        ],
        "ht2_lichgapsv": null,
        "khoaql": "CNPM",
        "thuchanh": "0",
        "sotc": "2",
        "dadk": "68",
        "ngonngu": "VN",
        "hinhthucgd": "LT",
        "malop": "SE332.Q21",
        "hocky": "2",
        "namhoc": "2025",
        "tiet": "1-4"
      }
    ]
  },
  {
    "name": "HT2/TTTN/KLTN",
    "course": [
      {
        "mamh": "SE359",
        "tenmh": "DevOps trong phát triển phần mềm",
        "sotinchi": "3",
        "malop": "SE359.Q21.1",
        "hinhthucgd": "HT2",
        "hocky": "2",
        "namhoc": "2025",
        "thuchanh": "1",
        "sotc": "1",
        "dadk": "77",
        "khoaql": "CNPM",
        "ngaybatdau": "2026-01-26",
        "ngayketthuc": "2026-05-30",
        "ht2_lichgapsv": "Tiết 6,7,8 ngày 2026-03-03, P. C314\nTiết 6,7,8 ngày 2026-03-17, P. C314\nTiết 6,7,8 ngày 2026-03-31, P. C314",
        "ngonngu": "VN",
        "thu": "*",
        "tiet": "*",
        "phonghoc": "*",
        "magv": [
          {
            "hoten": "Quan Chí Khánh An",
            "email": "anqck@uit.edu.vn"
          },
          {
            "hoten": "Võ Tuấn Kiệt",
            "email": "kietvt@uit.edu.vn"
          }
        ]
      },
      {
        "mamh": "SE361",
        "tenmh": "Phát triển Phần mềm theo Kiến trúc Microservices",
        "sotinchi": "4",
        "malop": "SE361.Q21.1",
        "hinhthucgd": "HT2",
        "hocky": "2",
        "namhoc": "2025",
        "thuchanh": "1",
        "sotc": "1",
        "dadk": "78",
        "khoaql": "CNPM",
        "ngaybatdau": "2026-01-26",
        "ngayketthuc": "2026-05-30",
        "ht2_lichgapsv": null,
        "ngonngu": "VN",
        "thu": "*",
        "tiet": "*",
        "phonghoc": "*",
        "magv": [
          {
            "hoten": "Nguyễn Duy Khánh",
            "email": "khanhnd@uit.edu.vn"
          },
          {
            "hoten": "Đặng Việt Dũng",
            "email": "dungdv@uit.edu.vn"
          }
        ]
      }
    ]
  }
]
```

### Plan tasks

1. General Scores Screen (Overview Score Width & Ratios)

- Target: lib/features/scores/presentation/general_scores_screen.dart
- Diagnostic: The table is currently locked to a maxWidth of 600. It uses an 8-column layout with 3 flex constants: \_flexMAMH = 3, \_flexLOP = 6, and \_flexRest = 2 (used for all other 6 columns).
- Task:
  - Wrap the Table in an InteractiveViewer or a horizontal SingleChildScrollView containing a ConstrainedBox with a minWidth (e.g., 500) and maxWidth (e.g., 800) so columns aren't squished on small devices but expand well on tablets.
  - Add a 4th flex constant (\_flexTB = 3) to separate the last column. Update the \_colFlex array to [3, 6, 2, 2, 2, 2, 2, 3], successfully mapping the 3:6:2:3 ratio constraint for the grouped categories.

2. Timetable - HT2 Class Type Support

- Target: lib/shared/models/course.dart & lib/features/timetable/presentation/timetable_screen.dart
- Diagnostic: The Course model currently doesn't parse sotc (credits), tenmh (subject name), and ht2_lichgapsv (the string schedule for HT2 classes). Timetable tabs currently strictly map to days of the week.
- Task:
  - Update Course.fromJson to safely parse sotc, tenmh, and ht2_lichgapsv.
  - Create a new screen/view for HT2 classes (e.g. HT2Screen).
  - Add an icon button (e.g., Icons.view_agenda or Icons.schedule) in the TimetableScreen AppBar to navigate to the HT2 screen.
  - In the HT2 screen, filter the dayMap for courses belonging to the HT2 group and render them in cards, properly displaying their dynamic ht2_lichgapsv text schedule.

3. Tuition Fee Calculation & Terminology

- Target: lib/features/fees/presentation/fees_screen.dart & assets/translations/{en,vi}.json
- Diagnostic: The fee screen calculates remaining.abs() causing overpayments (negative remaining) to show as a positive balance. The current label is "Remaining".
- Task:
  - Remove .abs() from totalRemaining and remaining calculations.
  - Update translation files: Change the translation key for the remaining amount to "Previous debt" (EN) and "Nợ trước" (VI). Update the UI text accordingly.

4. Notification Card Icon Removal

- Target: lib/features/notifications/presentation/notifications_screen.dart
- Diagnostic: Notifications currently display a leading Icon(Icons.notifications_outlined).
- Task: Remove the leading icon property from the notification tile to achieve the requested clean look.

5. Release Please Configuration Update

- Target: release-please-config.json
- Diagnostic: The config uses search-by-regex and replace incorrectly for a generic file, which is why it fails to bump kCurrentAppVersion in update_check_provider.dart.
- Task: Simplify the extra-files entry to correctly utilize the built-in // x-release-please-version magic comment that you already have configured in update_check_provider.dart (removing the regex config).

6. Score Screen Credits Calculation (Tín chỉ đã học / Tín chỉ tích luỹ)

- Target: lib/features/scores/presentation/scores_screen.dart & lib/shared/models/score.dart
- Diagnostic: Currently, the \_calculateGpa function only returns a single totalCredits tally.
- Task:
  - Update the calculation logic to return two separate tallies:
    - Tín chỉ đã học (Credits Studied): Sum of credits excluding "Miễn" courses.
    - Tín chỉ tích luỹ (Accumulated Credits): Sum of credits including "Miễn" courses.
  - Update \_OverallGpaCard to display both of these values cleanly.

7. Score Card Subject & Credit Formatting

- Target: lib/features/scores/presentation/scores_screen.dart
- Diagnostic: Subtitles currently concatenate data without the " • " split formatting or proper TC/C shortforms.
- Task:
  - Update \_SemesterScoreCard subtitle format to: {N} subjects • {totalCredits} tc • [semGpa.gpa colored chip].
  - Update the inner \_ScoreDetailTile subtitle to the requested short form: {score.subjectCode} • {score.credits} TC • {score.subjectType}.

8. Home Screen - Overview Section

- Target: lib/features/home/presentation/home_screen.dart
- Diagnostic: The "Courses" quick stat only displays the total number of subjects.
- Task: Calculate the total credits for the current semester by summing credits across the semesters array. Format the quick stat to display both (e.g., X subjects • Y credits).

9. Timetable - Today Color Highlight

- Target: lib/features/timetable/presentation/timetable_screen.dart
- Diagnostic: The today tab is hardcoded to be the tertiary color, overriding the TabBar's natural primary selection color.
- Task: Wrap the TabBar tabs in a widget that listens to the \_tabController (like AnimatedBuilder). If the today tab is not selected, show it as the tertiary color. If it is selected, let it use the active primary color.
