import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

/// Shell Scaffold providing modern dock-style bottom navigation across core features
class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          height: 66,
          backgroundColor: Colors.transparent,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined, size: 21),
              selectedIcon: Icon(Icons.menu_book_rounded, size: 21),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded, size: 21),
              selectedIcon: Icon(Icons.favorite_rounded, size: 21),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined, size: 21),
              selectedIcon: Icon(Icons.quiz_rounded, size: 21),
              label: 'Quiz',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined, size: 21),
              selectedIcon: Icon(Icons.insights_rounded, size: 21),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded, size: 21),
              selectedIcon: Icon(Icons.add_circle_rounded, size: 21),
              label: 'Add Word',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 21),
              selectedIcon: Icon(Icons.settings_rounded, size: 21),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
