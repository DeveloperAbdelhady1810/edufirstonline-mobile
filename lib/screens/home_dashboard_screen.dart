import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_data.dart';
import '../services/auth_service.dart';
import '../services/content_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/stat_chip.dart';
import 'course_player_screen.dart';
import 'discover_screen.dart';
import 'my_courses_screen.dart';
import 'package_list_screen.dart';
import 'teacher_list_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late Future<DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService.instance.dashboard();
  }

  Future<void> _refresh() async {
    final next = ContentService.instance.dashboard();
    setState(() {
      _future = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthService>().currentUser?.name.split(' ').first ?? '';

    // No Scaffold here on purpose - this screen only ever lives inside
    // AppShell's IndexedStack, which already has the one real Scaffold
    // (with the persistent bottom nav). A second, nested Scaffold here
    // used to double up keyboard-inset handling and could make the outer
    // bottom nav bar intermittently disappear/misbehave.
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
          child: FutureBuilder<DashboardData>(
            future: _future,
            builder: (context, snapshot) {
              final data = snapshot.data;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  DecorativeHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحبًا، $userName 👋',
                          style: AppTypography.headline.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'يلا نكمل رحلتك التعليمية اليوم!',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatChip(
                              value: '${data?.enrolled ?? 0}',
                              label: 'حصصي',
                              icon: Icons.menu_book_rounded,
                            ),
                            StatChip(
                              value: '${data?.completed ?? 0}',
                              label: 'مكتمل',
                              icon: Icons.emoji_events_rounded,
                            ),
                            StatChip(
                              value: '${data?.streak ?? 0}',
                              label: 'أيام متتالية',
                              icon: Icons.local_fire_department_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (snapshot.connectionState == ConnectionState.waiting) ...[
                          const LoadingSkeleton(width: double.infinity, height: 100, borderRadius: AppSpacing.radiusXl),
                        ] else if (snapshot.hasError) ...[
                          _ErrorCard(onRetry: _refresh),
                        ] else if (data?.continueWatching != null) ...[
                          Text('أكمل من حيث توقفت', style: AppTypography.title)
                              .animate()
                              .fadeIn(duration: 250.ms),
                          const SizedBox(height: AppSpacing.sm),
                          _ContinueWatchingCard(data: data!.continueWatching!),
                          const SizedBox(height: AppSpacing.xl),
                        ] else if (data != null) ...[
                          const _NoActivityYetCard(),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                        Text('استكشف', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.sm),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.4,
                          children: [
                            _QuickActionCard(
                              icon: Icons.explore_rounded,
                              iconBg: AppColors.primary,
                              label: 'تصفح الدورات',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                              ),
                            ),
                            _QuickActionCard(
                              icon: Icons.video_library_rounded,
                              iconBg: AppColors.secondary,
                              label: 'حصصي',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
                              ),
                            ),
                            _QuickActionCard(
                              icon: Icons.inventory_2_rounded,
                              iconBg: const Color(0xFFB45309),
                              label: 'الباقات',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PackageListScreen()),
                              ),
                            ),
                            _QuickActionCard(
                              icon: Icons.groups_rounded,
                              iconBg: const Color(0xFF7C3AED),
                              label: 'المعلمون',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TeacherListScreen()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  const _ContinueWatchingCard({required this.data});

  final ContinueWatching data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      animateIn: true,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CoursePlayerScreen(courseId: data.courseId, initialLectureId: data.lectureId),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.courseTitle, style: AppTypography.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  data.lectureTitle,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: LinearProgressIndicator(
                    value: data.progressPercentage / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _NoActivityYetCard extends StatelessWidget {
  const _NoActivityYetCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      animateIn: true,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFFB45309)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('لم تبدأ أي درس بعد', style: AppTypography.title),
                Text(
                  'تصفح الدورات وابدأ رحلتك التعليمية الآن',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.iconBg, required this.label, required this.onTap});

  final IconData icon;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      animateIn: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'تعذر تحميل البيانات',
      message: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      icon: Icons.wifi_off_rounded,
      actionLabel: 'إعادة المحاولة',
      onAction: onRetry,
    );
  }
}
