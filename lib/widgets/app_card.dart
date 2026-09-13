import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Rounded, soft-shadowed card - the single most impactful component for
/// making the app feel premium instead of generic. Used for every "chunk of
/// content" on every screen (course tile, stat card, list row) instead of
/// each screen defining its own container styling.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.animateIn = false,
    this.animationDelay = Duration.zero,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  /// Fade + slide-in on first build - set true for cards in a list so items
  /// appear staggered rather than popping in all at once.
  final bool animateIn;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: card,
        ),
      );
    }

    if (!animateIn) return card;

    return card
        .animate(delay: animationDelay)
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
