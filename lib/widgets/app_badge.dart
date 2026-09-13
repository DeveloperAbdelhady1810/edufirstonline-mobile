import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

enum AppBadgeVariant { success, info, gold, danger, neutral, live }

/// Small pill label - course status, "Free", live-now indicator, streak
/// counts, etc. One component instead of every screen inventing its own
/// Container+BoxDecoration+Text combo.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  (Color bg, Color fg) get _colors => switch (variant) {
        AppBadgeVariant.success => (AppColors.primary.withValues(alpha: 0.12), AppColors.primaryDark),
        AppBadgeVariant.info => (AppColors.secondary.withValues(alpha: 0.12), AppColors.secondary),
        AppBadgeVariant.gold => (AppColors.gold.withValues(alpha: 0.15), const Color(0xFFB45309)),
        AppBadgeVariant.danger => (AppColors.error.withValues(alpha: 0.12), AppColors.error),
        AppBadgeVariant.neutral => (AppColors.border, AppColors.textMuted),
        AppBadgeVariant.live => (AppColors.error.withValues(alpha: 0.12), AppColors.error),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (variant == AppBadgeVariant.live) ...[
            _LiveDot(color: fg),
            const SizedBox(width: 5),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTypography.caption.copyWith(color: fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(
          duration: 700.ms,
          curve: Curves.easeInOut,
          begin: 1,
        );
  }
}
