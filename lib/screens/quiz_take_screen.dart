import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../services/api_client.dart';
import '../services/quiz_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/loading_skeleton.dart';
import 'quiz_result_screen.dart';

class QuizTakeScreen extends StatefulWidget {
  const QuizTakeScreen({super.key, required this.quizId, required this.quizTitle});

  final int quizId;
  final String quizTitle;

  @override
  State<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends State<QuizTakeScreen> {
  late Future<QuizDetail> _future;
  final Map<int, String> _answers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _future = _start();
  }

  Future<QuizDetail> _start() async {
    try {
      return await QuizService.instance.startQuiz(widget.quizId);
    } on ApiException catch (e) {
      if (e.statusCode == 409 && mounted) {
        // Already submitted (e.g. re-entered after a previous attempt) -
        // send the student straight to their result instead of an error.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => QuizResultScreen(quizId: widget.quizId)),
          );
        });
      }
      rethrow;
    }
  }

  Future<void> _submit(QuizDetail quiz) async {
    if (_answers.length < quiz.questions.length) {
      final missing = quiz.questions.length - _answers.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى الإجابة على جميع الأسئلة (متبقي $missing)')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await QuizService.instance.submitQuiz(quiz.id, _answers);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => QuizResultScreen(quizId: quiz.id)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<QuizDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.pageHorizontal),
                child: SkeletonList(),
              );
            }
            if (snapshot.hasError) {
              return const SizedBox.shrink();
            }

            final quiz = snapshot.data!;
            return Column(
              children: [
                DecorativeHeader(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          quiz.title,
                          style: AppTypography.title.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${_answers.length}/${quiz.questions.length}',
                        style: AppTypography.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    itemCount: quiz.questions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _QuestionCard(
                      index: i + 1,
                      question: quiz.questions[i],
                      selected: _answers[quiz.questions[i].id],
                      onSelect: (letter) => setState(() => _answers[quiz.questions[i].id] = letter),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                      child: AppButton(
                        label: 'تسليم الإجابات',
                        icon: Icons.send_rounded,
                        isLoading: _isSubmitting,
                        onPressed: () => _submit(quiz),
                      ),
                    ),
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.index, required this.question, required this.selected, required this.onSelect});

  final int index;
  final QuizQuestion question;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      animateIn: true,
      animationDelay: Duration(milliseconds: index * 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text('$index', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(question.questionText, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final option in question.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _OptionRow(
                letter: option.key,
                text: option.value,
                isSelected: selected == option.key,
                onTap: () => onSelect(option.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.letter, required this.text, required this.isSelected, required this.onTap});

  final String letter;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isSelected ? AppColors.primary : AppColors.border,
              child: Text(letter, style: AppTypography.caption.copyWith(color: isSelected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text, style: AppTypography.bodySmall)),
          ],
        ),
      ),
    );
  }
}
