import 'package:flutter/material.dart';

import '../data/education_data.dart';
import '../models/course.dart';
import '../services/content_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import 'course_player_screen.dart';
import 'discover_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  late Future<List<MyCourse>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService.instance.myCourses();
  }

  Future<void> _refresh() async {
    final next = ContentService.instance.myCourses();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DecorativeHeader(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.lg,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('دوراتي', style: AppTypography.headline.copyWith(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                          'استمر من حيث توقفت 🎯',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.video_library_rounded, color: Colors.white, size: 36),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _refresh,
                child: FutureBuilder<List<MyCourse>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SkeletonList();
                    }
                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          EmptyState(
                            title: 'تعذر تحميل دوراتك',
                            icon: Icons.wifi_off_rounded,
                            actionLabel: 'إعادة المحاولة',
                            onAction: _refresh,
                          ),
                        ],
                      );
                    }
                    final courses = snapshot.data ?? [];
                    if (courses.isEmpty) {
                      return ListView(
                        children: [
                          EmptyState(
                            title: 'لا توجد دورات مشترك بها بعد',
                            message: 'تصفح الدورات المتاحة وابدأ التعلم',
                            icon: Icons.video_library_outlined,
                            actionLabel: 'تصفح الدورات',
                            onAction: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) => _MyCourseTile(course: courses[i], delay: i * 50),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyCourseTile extends StatelessWidget {
  const _MyCourseTile({required this.course, this.delay = 0});

  final MyCourse course;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      animateIn: true,
      animationDelay: Duration(milliseconds: delay),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CoursePlayerScreen(courseId: course.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: AppTypography.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      '${course.teacherName} • ${EducationData.subjectLabel(course.subject)}',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text('${course.progress}%', style: AppTypography.title.copyWith(color: AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: course.progress / 100,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
