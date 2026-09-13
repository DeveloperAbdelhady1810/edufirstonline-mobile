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
import 'course_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  String? _gradeFilter;
  late Future<List<CourseSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService.instance.browseCourses();
  }

  void _reload() {
    setState(() {
      _future = ContentService.instance.browseCourses(
        grade: _gradeFilter,
        search: _searchController.text.trim(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allGrades = EducationData.stages.expand((s) => s.grades).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DecorativeHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اكتشف الدورات', style: AppTypography.headline.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    'ابحث عن دورتك القادمة 📚',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _reload(),
                      style: AppTypography.body,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن دورة أو موضوع...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded),
                          onPressed: _reload,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.sm),
                children: [
                  _FilterChip(
                    label: 'الكل',
                    selected: _gradeFilter == null,
                    onTap: () {
                      _gradeFilter = null;
                      _reload();
                    },
                  ),
                  for (final grade in allGrades) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(
                      label: grade.nameAr,
                      selected: _gradeFilter == grade.nameAr,
                      onTap: () {
                        _gradeFilter = grade.nameAr;
                        _reload();
                      },
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CourseSummary>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SkeletonList();
                  }
                  if (snapshot.hasError) {
                    return EmptyState(
                      title: 'تعذر تحميل الدورات',
                      message: 'تحقق من اتصالك بالإنترنت',
                      icon: Icons.wifi_off_rounded,
                      actionLabel: 'إعادة المحاولة',
                      onAction: _reload,
                    );
                  }
                  final courses = snapshot.data ?? [];
                  if (courses.isEmpty) {
                    return const EmptyState(
                      title: 'لا توجد دورات مطابقة',
                      message: 'جرّب كلمة بحث أو مرحلة دراسية مختلفة',
                      icon: Icons.search_off_rounded,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _CourseTile(course: courses[i], delay: i * 40),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course, this.delay = 0});

  final CourseSummary course;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      animateIn: true,
      animationDelay: Duration(milliseconds: delay),
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CourseDetailScreen(courseId: course.id)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: AppTypography.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  course.teacherName,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _Tag(text: course.grade),
                    const SizedBox(width: 6),
                    _Tag(text: EducationData.subjectLabel(course.subject)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('${course.price} ج.م', style: AppTypography.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
      child: Text(text, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
    );
  }
}
