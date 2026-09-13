import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Shared gradient hero surface - decorative translucent circles behind a
/// gradient, rounded at the bottom. First built for the login screen (per
/// user feedback that a flat gradient banner felt too plain); pulled out
/// here so every screen with a hero/header area (dashboard, discover,
/// profile, course detail) gets the same "much better" treatment instead of
/// each screen re-inventing its own flat banner.
class DecorativeHeader extends StatelessWidget {
  const DecorativeHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.pageHorizontal,
      AppSpacing.xl,
      AppSpacing.pageHorizontal,
      AppSpacing.xl,
    ),
    this.gradient = AppColors.primaryGradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppSpacing.radiusXl),
        bottomRight: Radius.circular(AppSpacing.radiusXl),
      ),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const Positioned(top: -30, left: -20, child: DecorativeBlob(size: 100, opacity: 0.10)),
            const Positioned(top: 10, right: -35, child: DecorativeBlob(size: 120, opacity: 0.12)),
            const Positioned(bottom: -35, right: 30, child: DecorativeBlob(size: 70, opacity: 0.08)),
            child,
          ],
        ),
      ),
    );
  }
}

class DecorativeBlob extends StatelessWidget {
  const DecorativeBlob({super.key, required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
