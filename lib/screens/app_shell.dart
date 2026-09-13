import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'discover_screen.dart';
import 'home_dashboard_screen.dart';
import 'my_courses_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

/// Root shell after login - bottom nav + the 5 main tabs. Every tab keeps
/// its own scroll/state alive via IndexedStack so switching tabs doesn't
/// re-fetch data each time.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'الرئيسية'),
    (icon: Icons.explore_rounded, label: 'اكتشف'),
    (icon: Icons.video_library_rounded, label: 'دوراتي'),
    (icon: Icons.notifications_rounded, label: 'الإشعارات'),
    (icon: Icons.person_rounded, label: 'حسابي'),
  ];

  static const _screens = [
    HomeDashboardScreen(),
    DiscoverScreen(),
    MyCoursesScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _tabs[i].icon,
                      label: _tabs[i].label,
                      selected: _index == i,
                      onTap: () => setState(() => _index = i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption.copyWith(color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
