import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A small "number + label" pill for stats shown over a gradient hero (e.g.
/// dashboard header stats). Distinct from AppBadge (which is for status
/// labels on light backgrounds) - this one is always white-on-translucent,
/// built for sitting on top of AppColors.primaryGradient.
class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(height: 2),
          ],
          Text(value, style: AppTypography.title.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          Text(label, style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}
