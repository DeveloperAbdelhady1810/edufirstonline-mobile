import 'package:flutter/material.dart';

import '../data/education_data.dart';
import '../models/course.dart';
import '../services/api_client.dart';
import '../services/content_service.dart';
import '../services/webview_ticket_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/webview_screen.dart';
import 'course_player_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Future<(CourseDetail, bool)> _future;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(CourseDetail, bool)> _load() async {
    final detail = await ContentService.instance.courseDetail(widget.courseId);
    // The public course-detail endpoint doesn't expose enrollment status -
    // this cross-checks against the student's own enrolled-courses list
    // instead of inventing a new backend field.
    bool isEnrolled = false;
    try {
      final mine = await ContentService.instance.myCourses();
      isEnrolled = mine.any((c) => c.id == widget.courseId);
    } catch (_) {
      // Not logged in as a student or call failed - default to "not
      // enrolled" so the purchase CTA still shows.
    }
    return (detail, isEnrolled);
  }

  void _refresh() => setState(() {
        _future = _load();
      });

  Future<void> _handlePurchase(CourseDetail course) async {
    // A free course never goes through Paymob - the backend's own web
    // purchase route explicitly rejects that combination, so this mirrors
    // the website's dedicated free-enrollment endpoint instead.
    if (course.isFree) {
      setState(() => _isPurchasing = true);
      try {
        await ContentService.instance.enrollFree(course.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الاشتراك في الدورة بنجاح!')),
        );
        _refresh();
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      } finally {
        if (mounted) setState(() => _isPurchasing = false);
      }
      return;
    }

    setState(() => _isPurchasing = true);
    try {
      final url = await WebviewTicketService.instance.payCourseUrl(course.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AppWebviewScreen(url: url, title: 'إتمام الشراء')),
      );
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<(CourseDetail, bool)>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _DetailSkeleton();
            }
            if (snapshot.hasError) {
              return _ErrorView(onRetry: _refresh);
            }

            final (course, isEnrolled) = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DecorativeHeader(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                                ),
                                const Spacer(),
                                if (isEnrolled)
                                  const AppBadge(label: 'مشترك', variant: AppBadgeVariant.success, icon: Icons.check_circle)
                                else if (course.isFree)
                                  const AppBadge(label: 'مجانًا', variant: AppBadgeVariant.gold, icon: Icons.celebration_rounded),
                              ],
                            ),
                            Text(course.title, style: AppTypography.headline.copyWith(color: Colors.white)),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                                  backgroundImage: course.teacherAvatar != null ? NetworkImage(course.teacherAvatar!) : null,
                                  child: course.teacherAvatar == null
                                      ? const Icon(Icons.person, size: 16, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(course.teacherName, style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (course.grade.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                                    child: Text(course.grade, style: AppTypography.caption.copyWith(color: Colors.white)),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                                  child: Text(EducationData.subjectLabel(course.subject), style: AppTypography.caption.copyWith(color: Colors.white)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                                  child: Text('${course.lectureCount} محاضرة', style: AppTypography.caption.copyWith(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (course.description.isNotEmpty) ...[
                              Text('عن الدورة', style: AppTypography.title),
                              const SizedBox(height: AppSpacing.xs),
                              Text(course.description, style: AppTypography.body.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                            Text('محتوى الدورة', style: AppTypography.title),
                            const SizedBox(height: AppSpacing.sm),
                            for (var i = 0; i < course.sections.length; i++)
                              _SectionCard(section: course.sections[i], delay: i * 60, unlocked: isEnrolled),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isEnrolled)
                  _BuyBar(course: course, isLoading: _isPurchasing, onBuy: () => _handlePurchase(course))
                else
                  _ContinueBar(courseId: course.id),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.unlocked, this.delay = 0});

  final CourseSection section;
  final bool unlocked;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        animateIn: true,
        animationDelay: Duration(milliseconds: delay),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            for (final lecture in section.lectures)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      unlocked || lecture.isFree ? _iconFor(lecture.type) : Icons.lock_outline_rounded,
                      size: 18,
                      color: unlocked || lecture.isFree ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(lecture.title, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (lecture.isFree && !unlocked) const AppBadge(label: 'مجانًا', variant: AppBadgeVariant.gold),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        'external_link' => Icons.link_rounded,
        'document_link' => Icons.description_outlined,
        'live_session' => Icons.podcasts_rounded,
        _ => Icons.play_circle_outline_rounded,
      };
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.course, required this.isLoading, required this.onBuy});

  final CourseDetail course;
  final bool isLoading;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('السعر', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                  Text(
                    course.isFree ? 'مجانًا' : '${course.price} ج.م',
                    style: AppTypography.headline.copyWith(
                      color: course.isFree ? AppColors.primary : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppButton(
                  label: course.isFree ? 'اشترك مجانًا' : 'اشترك الآن',
                  icon: course.isFree ? Icons.celebration_rounded : Icons.shopping_cart_checkout_rounded,
                  isLoading: isLoading,
                  onPressed: onBuy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.courseId});

  final int courseId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: AppButton(
            label: 'متابعة التعلم',
            icon: Icons.play_arrow_rounded,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CoursePlayerScreen(courseId: courseId)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          LoadingSkeleton(width: double.infinity, height: 160, borderRadius: AppSpacing.radiusXl),
          SizedBox(height: AppSpacing.lg),
          LoadingSkeleton(width: double.infinity, height: 80, borderRadius: AppSpacing.radiusXl),
          SizedBox(height: AppSpacing.lg),
          LoadingSkeleton(width: double.infinity, height: 80, borderRadius: AppSpacing.radiusXl),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('تعذر تحميل تفاصيل الدورة', style: AppTypography.title),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'إعادة المحاولة', onPressed: onRetry, fullWidth: false),
          ],
        ),
      ),
    );
  }
}
