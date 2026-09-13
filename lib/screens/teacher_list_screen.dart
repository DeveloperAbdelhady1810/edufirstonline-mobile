import 'package:flutter/material.dart';

import '../data/education_data.dart';
import '../models/teacher.dart';
import '../services/directory_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import 'teacher_detail_screen.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final _searchController = TextEditingController();
  late Future<List<TeacherProfile>> _future;

  @override
  void initState() {
    super.initState();
    _future = DirectoryService.instance.teachers();
  }

  void _search() => setState(() {
        _future = DirectoryService.instance.teachers(search: _searchController.text.trim());
      });

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                      Text('المعلمون', style: AppTypography.title.copyWith(color: Colors.white)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _search(),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن معلم...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<TeacherProfile>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SkeletonList();
                  }
                  if (snapshot.hasError) {
                    return EmptyState(
                      title: 'تعذر تحميل المعلمين',
                      icon: Icons.wifi_off_rounded,
                      actionLabel: 'إعادة المحاولة',
                      onAction: _search,
                    );
                  }
                  final teachers = snapshot.data ?? [];
                  if (teachers.isEmpty) {
                    return const EmptyState(title: 'لا يوجد معلمون مطابقون', icon: Icons.person_search_rounded);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    itemCount: teachers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _TeacherTile(teacher: teachers[i], delay: i * 50),
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

class _TeacherTile extends StatelessWidget {
  const _TeacherTile({required this.teacher, this.delay = 0});

  final TeacherProfile teacher;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      animateIn: true,
      animationDelay: Duration(milliseconds: delay),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TeacherDetailScreen(teacherId: teacher.id)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage: teacher.avatar != null ? NetworkImage(teacher.avatar!) : null,
            child: teacher.avatar == null ? const Icon(Icons.person, color: AppColors.primary) : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(teacher.name, style: AppTypography.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (teacher.isPremium) ...[
                      const SizedBox(width: 6),
                      const AppBadge(label: 'مميز', variant: AppBadgeVariant.gold, icon: Icons.star_rounded),
                    ],
                  ],
                ),
                if (teacher.subjects.isNotEmpty)
                  Text(
                    teacher.subjects.map(EducationData.subjectLabel).join('، '),
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
