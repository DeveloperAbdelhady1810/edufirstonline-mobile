import 'package:flutter/material.dart';

import '../models/package.dart';
import '../services/directory_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import 'package_detail_screen.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  late Future<List<CoursePackage>> _future;

  @override
  void initState() {
    super.initState();
    _future = DirectoryService.instance.packages();
  }

  void _refresh() => setState(() {
        _future = DirectoryService.instance.packages();
      });

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
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الباقات التعليمية', style: AppTypography.title.copyWith(color: Colors.white)),
                        Text(
                          'اشترك في مجموعة حصص وفر أكثر 💰',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CoursePackage>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SkeletonList();
                  }
                  if (snapshot.hasError) {
                    return EmptyState(
                      title: 'تعذر تحميل الباقات',
                      icon: Icons.wifi_off_rounded,
                      actionLabel: 'إعادة المحاولة',
                      onAction: _refresh,
                    );
                  }
                  final packages = snapshot.data ?? [];
                  if (packages.isEmpty) {
                    return const EmptyState(
                      title: 'لا توجد باقات متاحة حاليًا',
                      icon: Icons.inventory_2_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    itemCount: packages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _PackageTile(package: packages[i], delay: i * 50),
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

class _PackageTile extends StatelessWidget {
  const _PackageTile({required this.package, this.delay = 0});

  final CoursePackage package;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      animateIn: true,
      animationDelay: Duration(milliseconds: delay),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PackageDetailScreen(packageId: package.id)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            child: const Icon(Icons.inventory_2_rounded, color: Color(0xFFB45309)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package.name, style: AppTypography.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    AppBadge(label: '${package.courseCount} حصة', variant: AppBadgeVariant.info),
                    const SizedBox(width: 6),
                    if (package.grade.isNotEmpty) AppBadge(label: package.grade, variant: AppBadgeVariant.neutral),
                  ],
                ),
              ],
            ),
          ),
          Text('${package.price} ج.م', style: AppTypography.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}
