import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/api_client.dart';
import '../services/content_service.dart';
import '../services/webview_ticket_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/webview_screen.dart';
import 'quiz_list_screen.dart';

/// Curriculum + lecture playback for a course the student is enrolled in.
/// Actual video/document/embed rendering happens inside a WebView pointed at
/// the existing web player (see WebviewTicketService) since the API has no
/// native streaming endpoint - this screen's own job is just navigation +
/// progress bookkeeping around that.
class CoursePlayerScreen extends StatefulWidget {
  const CoursePlayerScreen({super.key, required this.courseId, this.initialLectureId});

  final int courseId;
  final int? initialLectureId;

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> {
  late Future<(CourseDetail, List<CourseSection>)> _future;
  bool _openedInitial = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(CourseDetail, List<CourseSection>)> _load() async {
    final results = await Future.wait([
      ContentService.instance.courseDetail(widget.courseId),
      ContentService.instance.myCourseLectures(widget.courseId),
    ]);
    return (results[0] as CourseDetail, results[1] as List<CourseSection>);
  }

  void _refresh() => setState(() {
        _future = _load();
      });

  Future<void> _openLecture(LectureSummary lecture) async {
    try {
      final url = await WebviewTicketService.instance.learnUrl(courseId: widget.courseId, lectureId: lecture.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AppWebviewScreen(url: url, title: lecture.title)),
      );
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _toggleComplete(LectureSummary lecture) async {
    if (lecture.completed) return;
    try {
      await ContentService.instance.markLectureComplete(lecture.id);
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<(CourseDetail, List<CourseSection>)>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _PlayerSkeleton();
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(label: 'إعادة المحاولة', onPressed: _refresh, fullWidth: false),
                  ],
                ),
              );
            }

            final (course, sections) = snapshot.data!;
            final totalLectures = sections.fold<int>(0, (sum, s) => sum + s.lectures.length);
            final completedLectures = sections.fold<int>(0, (sum, s) => sum + s.completedCount);
            final overallProgress = totalLectures == 0 ? 0.0 : completedLectures / totalLectures;

            if (widget.initialLectureId != null && !_openedInitial) {
              _openedInitial = true;
              final target = sections.expand((s) => s.lectures).where((l) => l.id == widget.initialLectureId);
              if (target.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _openLecture(target.first));
              }
            }

            return ListView(
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
                          Expanded(
                            child: Text(
                              course.title,
                              style: AppTypography.title.copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('تقدمك', style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                                Text('$completedLectures / $totalLectures', style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              child: LinearProgressIndicator(
                                value: overallProgress,
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => QuizListScreen(courseId: course.id, courseTitle: course.title)),
                        ),
                        animateIn: true,
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                              child: const Icon(Icons.quiz_rounded, color: Color(0xFFB45309)),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('اختبارات الدورة', style: AppTypography.title),
                                  Text('اختبر نفسك بعد كل جزء', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('محتوى الدورة', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.sm),
                      for (var i = 0; i < sections.length; i++)
                        _SectionBlock(
                          section: sections[i],
                          delay: i * 60,
                          onLectureTap: _openLecture,
                          onToggleComplete: _toggleComplete,
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

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.section,
    required this.onLectureTap,
    required this.onToggleComplete,
    this.delay = 0,
  });

  final CourseSection section;
  final ValueChanged<LectureSummary> onLectureTap;
  final ValueChanged<LectureSummary> onToggleComplete;
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
            const Divider(height: AppSpacing.lg),
            for (final lecture in section.lectures)
              InkWell(
                onTap: () => onLectureTap(lecture),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(_iconFor(lecture.type), size: 20, color: AppColors.secondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(lecture.title, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => onToggleComplete(lecture),
                        child: Icon(
                          lecture.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: 22,
                          color: lecture.completed ? AppColors.primary : AppColors.disabled,
                        ),
                      ),
                    ],
                  ),
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

class _PlayerSkeleton extends StatelessWidget {
  const _PlayerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Padding(
          padding: EdgeInsets.all(AppSpacing.pageHorizontal),
          child: LoadingSkeleton(width: double.infinity, height: 120, borderRadius: AppSpacing.radiusXl),
        ),
        Expanded(child: SkeletonList(count: 3)),
      ],
    );
  }
}
