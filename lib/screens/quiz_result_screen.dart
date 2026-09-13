import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_skeleton.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key, required this.quizId});

  final int quizId;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late Future<QuizResult> _future;

  @override
  void initState() {
    super.initState();
    _future = QuizService.instance.quizResult(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نتيجة الاختبار')),
      body: SafeArea(
        child: FutureBuilder<QuizResult>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(AppSpacing.pageHorizontal), child: SkeletonList());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('تعذر تحميل النتيجة'));
            }

            final result = snapshot.data!;
            final color = result.passed ? AppColors.primary : AppColors.error;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(
                          result.passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                          size: 56,
                          color: color,
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        result.passed ? 'أحسنت! لقد نجحت 🎉' : 'حاول مرة أخرى',
                        style: AppTypography.headline,
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${result.score} من ${result.totalScore} نقطة (${result.percentage.toStringAsFixed(0)}%)',
                        style: AppTypography.body.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('مراجعة الإجابات', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                for (var i = 0; i < result.answers.length; i++)
                  _AnswerReviewCard(index: i + 1, answer: result.answers[i]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnswerReviewCard extends StatelessWidget {
  const _AnswerReviewCard({required this.index, required this.answer});

  final int index;
  final QuizAnswerResult answer;

  @override
  Widget build(BuildContext context) {
    final color = answer.isCorrect ? AppColors.primary : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        animateIn: true,
        animationDelay: Duration(milliseconds: index * 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(answer.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(answer.questionText, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('إجابتك: ${answer.yourAnswer ?? '-'}', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
            if (!answer.isCorrect)
              Text('الإجابة الصحيحة: ${answer.correctAnswer ?? '-'}', style: AppTypography.caption.copyWith(color: AppColors.primaryDark)),
          ],
        ),
      ),
    );
  }
}
