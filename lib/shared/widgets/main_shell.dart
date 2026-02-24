import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uit_mobile/features/deadlines/presentation/deadlines_screen.dart';
import 'package:uit_mobile/features/home/presentation/home_screen.dart';
import 'package:uit_mobile/features/scores/presentation/scores_screen.dart';
import 'package:uit_mobile/features/timetable/presentation/timetable_screen.dart';

/// Main shell with bottom navigation for the authenticated app.
/// 4 tabs: Home, TKB, Deadlines, Scores.
/// Notifications and Settings are accessible from Home's app bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    TimetableScreen(),
    DeadlinesScreen(),
    ScoresScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'nav.home'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: 'nav.timetable'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: 'nav.deadlines'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.score_outlined),
            selectedIcon: const Icon(Icons.score),
            label: 'nav.scores'.tr(),
          ),
        ],
      ),
    );
  }
}
