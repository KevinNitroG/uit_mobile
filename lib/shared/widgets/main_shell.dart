import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uit_mobile/features/deadlines/presentation/deadlines_screen.dart';
import 'package:uit_mobile/features/exams/presentation/exams_screen.dart';
import 'package:uit_mobile/features/home/presentation/home_screen.dart';
import 'package:uit_mobile/features/scores/presentation/scores_screen.dart';
import 'package:uit_mobile/features/timetable/presentation/timetable_screen.dart';

/// Index of the currently selected bottom-navigation tab.
///
/// 0 = Home, 1 = Timetable, 2 = Deadlines, 3 = Exams, 4 = Scores.
final tabIndexProvider = NotifierProvider<_TabIndexNotifier, int>(
  _TabIndexNotifier.new,
);

class _TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void switchTo(int index) => state = index;
}

/// Main shell with bottom navigation for the authenticated app.
/// 5 tabs: Home, TKB, Deadlines, Exams, Scores.
/// Notifications and Settings are accessible from Home's app bar.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = <Widget>[
    HomeScreen(),
    TimetableScreen(),
    DeadlinesScreen(),
    ExamsScreen(),
    ScoresScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(tabIndexProvider.notifier).switchTo(index);
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
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: 'nav.exams'.tr(),
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
