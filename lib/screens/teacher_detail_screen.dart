import 'package:flutter/material.dart';

import '../data/education_data.dart';
import '../models/teacher.dart';
import '../services/api_client.dart';
import '../services/directory_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/loading_skeleton.dart';
import 'course_detail_screen.dart';

class TeacherDetailScreen extends StatefulWidget {
  const TeacherDetailScreen({super.key, required this.teacherId});

  final int teacherId;

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  late Future<TeacherProfile> _future;

  // Tracked separately from the FutureBuilder's snapshot so following/
  // unfollowing can update the button instantly without re-fetching the
  // whole teacher profile.
  bool? _isFollowing;
  bool _isTogglingFollow = false;

  @override
  void initState() {
    super.initState();
    _future = DirectoryService.instance.teacherDetail(widget.teacherId);
  }

  Future<void> _toggleFollow() async {
    if (_isFollowing == null) return;
    setState(() => _isTogglingFollow = true);
    try {
      final nowFollowing = _isFollowing!
          ? await DirectoryService.instance.unfollow(widget.teacherId)
          : await DirectoryService.instance.follow(widget.teacherId);
      if (!mounted) return;
      setState(() => _isFollowing = nowFollowing);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isTogglingFollow = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<TeacherProfile>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(AppSpacing.pageHorizontal), child: SkeletonList());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('تعذر تحميل بيانات المعلم'));
            }

            final teacher = snapshot.data!;
            _isFollowing ??= teacher.isFollowing;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DecorativeHeader(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                      ),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        backgroundImage: teacher.avatar != null ? NetworkImage(teacher.avatar!) : null,
                        child: teacher.avatar == null ? const Icon(Icons.person, size: 36, color: Colors.white) : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(teacher.name, style: AppTypography.headline.copyWith(color: Colors.white)),
                      if (teacher.isPremium) ...[
                        const SizedBox(height: 4),
                        const AppBadge(label: 'معلم مميز', variant: AppBadgeVariant.gold, icon: Icons.star_rounded),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: _isFollowing! ? 'إلغاء المتابعة' : 'متابعة',
                        icon: _isFollowing! ? Icons.check_rounded : Icons.add_rounded,
                        variant: _isFollowing! ? AppButtonVariant.secondary : AppButtonVariant.primary,
                        isLoading: _isTogglingFollow,
                        fullWidth: false,
                        onPressed: _toggleFollow,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (teacher.bio != null && teacher.bio!.isNotEmpty) ...[
                        Text('نبذة', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.xs),
                        Text(teacher.bio!, style: AppTypography.body.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (teacher.subjects.isNotEmpty) ...[
                        Text('المواد', style: AppTypography.title),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: teacher.subjects
                              .map((s) => AppBadge(label: EducationData.subjectLabel(s), variant: AppBadgeVariant.info))
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      Text('حصص ${teacher.name}', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.sm),
                      for (final course in teacher.courses)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CourseDetailScreen(courseId: course.id)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book_rounded, color: AppColors.secondary),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: Text(course.title, style: AppTypography.bodySmall)),
                                Text('${course.price} ج.م', style: AppTypography.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
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
