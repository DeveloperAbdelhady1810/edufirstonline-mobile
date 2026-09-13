import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

/// Base shimmer box - the building block for every loading skeleton. Use
/// this instead of a bare CircularProgressIndicator wherever a list/card is
/// loading; skeleton loaders are what make an app feel finished rather than
/// "still fetching data" the whole time.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = AppSpacing.radiusSm,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.background,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A ready-made skeleton shaped like a course/teacher card (thumbnail +
/// title lines + a meta row) - drop this into a list while real course data
/// is loading, instead of a spinner.
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const LoadingSkeleton(width: 72, height: 72, borderRadius: AppSpacing.radiusMd),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoadingSkeleton(width: double.infinity, height: 16),
                const SizedBox(height: AppSpacing.sm),
                LoadingSkeleton(width: MediaQuery.sizeOf(context).width * 0.35, height: 12),
                const SizedBox(height: AppSpacing.sm),
                const LoadingSkeleton(width: 80, height: 20, borderRadius: AppSpacing.radiusPill),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders [count] [CourseCardSkeleton]s with spacing between them - the
/// standard way to show "a list is loading" anywhere in the app.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => const CourseCardSkeleton(),
    );
  }
}
