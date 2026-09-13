import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import 'quiz_result_screen.dart';
import 'quiz_take_screen.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key, required this.courseId, required this.courseTitle});

  final int courseId;
  final String courseTitle;

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  late Future<List<QuizSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = QuizService.instance.courseQuizzes(widget.courseId);
  }

  void _refresh() => setState(() => _future = QuizService.instance.courseQuizzes(widget.courseId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DecorativeHeader(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اختبارات الدورة', style: AppTypography.title.copyWith(color: Colors.white)),
                        Text(
                          widget.courseTitle,
                          style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<QuizSummary>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SkeletonList();
                  }
                  if (snapshot.hasError) {
                    return EmptyState(
                      title: 'تعذر تحميل الاختبارات',
                      icon: Icons.wifi_off_rounded,
                      actionLabel: 'إعادة المحاولة',
                      onAction: _refresh,
                    );
                  }
                  final quizzes = snapshot.data ?? [];
                  if (quizzes.isEmpty) {
                    return const EmptyState(
                      title: 'لا توجد اختبارات بعد',
                      message: 'سيقوم المعلم بإضافة اختبارات قريبًا',
                      icon: Icons.quiz_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    itemCount: quizzes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _QuizTile(quiz: quizzes[i], delay: i * 50),
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

class _QuizTile extends StatelessWidget {
  const _QuizTile({required this.quiz, this.delay = 0});

  final QuizSummary quiz;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      animateIn: true,
      animationDelay: Duration(milliseconds: delay),
      onTap: () {
        if (quiz.submitted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => QuizResultScreen(quizId: quiz.id)),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => QuizTakeScreen(quizId: quiz.id, quizTitle: quiz.title)),
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            child: const Icon(Icons.quiz_rounded, color: Color(0xFFB45309)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quiz.title, style: AppTypography.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${quiz.questionCount} سؤال${quiz.durationMinutes != null ? ' • ${quiz.durationMinutes} دقيقة' : ''}',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          if (quiz.submitted)
            const AppBadge(label: 'تم الحل', variant: AppBadgeVariant.success, icon: Icons.check_circle)
          else
            const AppBadge(label: 'جديد', variant: AppBadgeVariant.info),
        ],
      ),
    );
  }
}
