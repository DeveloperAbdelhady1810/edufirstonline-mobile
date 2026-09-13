import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, text }

/// The single button used everywhere in the app - no screen should reach
/// for a bare ElevatedButton/OutlinedButton/TextButton directly. Handles
/// loading (shows a spinner in place of the label, keeps the button's size
/// stable) and disabled state consistently, plus a subtle press-scale so
/// tapping feels responsive rather than static.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  bool get _disabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary ? Colors.white : AppColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: _disabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: _disabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: _disabled ? null : onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.md,
            ),
          ),
          child: DefaultTextStyle.merge(
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: _disabled ? AppColors.textMuted : AppColors.primary,
            ),
            child: child,
          ),
        ),
    };

    if (fullWidth && variant != AppButtonVariant.text) {
      button = SizedBox(width: double.infinity, child: button);
    }

    // Subtle press feedback - the exact kind of micro-interaction generic
    // apps skip. Only applied when interactive (not on a disabled button).
    if (_disabled) return button;

    return _Pressable(child: button);
  }
}

/// Wraps [child] with a quick scale-down/up on tap-down/tap-up, using
/// flutter_animate under the hood, without swallowing the button's own
/// onPressed handling (the real button still receives the tap normally).
class _Pressable extends StatefulWidget {
  const _Pressable({required this.child});

  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: widget.child
          .animate(target: _pressed ? 1 : 0)
          .scaleXY(begin: 1, end: 0.97, duration: 90.ms, curve: Curves.easeOut),
    );
  }
}
