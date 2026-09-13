import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('تسجيل الخروج')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthService>().logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DecorativeHeader(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                    child: user?.avatar == null
                        ? Text(
                            user?.initials ?? '؟',
                            style: AppTypography.headline.copyWith(color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(user?.name ?? '', style: AppTypography.title.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(user?.email ?? '', style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    animateIn: true,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _MenuTile(icon: Icons.person_outline_rounded, label: 'تعديل البيانات الشخصية', onTap: () {}),
                        const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                        _MenuTile(icon: Icons.lock_outline_rounded, label: 'تغيير كلمة المرور', onTap: () {}),
                        const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                        _MenuTile(icon: Icons.help_outline_rounded, label: 'المساعدة والدعم', onTap: () {}),
                        const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                        _MenuTile(icon: Icons.info_outline_rounded, label: 'عن التطبيق', onTap: () => _showAbout(context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    animateIn: true,
                    animationDelay: const Duration(milliseconds: 80),
                    padding: EdgeInsets.zero,
                    child: _MenuTile(
                      icon: Icons.logout_rounded,
                      label: 'تسجيل الخروج',
                      iconColor: AppColors.error,
                      textColor: AppColors.error,
                      onTap: () => _confirmLogout(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Center(
                    child: Column(
                      children: [
                        Text('EduFirstOnline', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text('بالتعاون مع Quadro Cloud', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'EduFirstOnline',
      applicationVersion: '1.0.0',
      children: const [
        Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Text('منصة "ذا فيرست" التعليمية - بالتعاون مع Quadro Cloud'),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTypography.body.copyWith(color: textColor))),
            Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
