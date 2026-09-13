import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/decorative_header.dart';
import 'app_shell.dart';
import 'register_screen.dart';

/// Flagship screen (Step 4 checkpoint) - first impression of the app, and
/// the one screen meant to showcase every element of the design system at
/// once: gradient hero, decorative shapes, Lottie welcome moment, typography
/// scale, AppButton/AppTextField/AppBadge, staggered entrance animation,
/// RTL-correct layout, and the required Quadro Cloud attribution.
///
/// NOTE: this screen is visually complete but not yet wired to the real
/// login API (POST /api/auth/login) - that's Step 5/Backend Integration,
/// intentionally deferred until this design direction is approved. Pressing
/// "تسجيل الدخول" here only simulates a loading state.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _identifierController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد الإلكتروني وكلمة المرور')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().login(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AppShell()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal,
                        AppSpacing.xl,
                        AppSpacing.pageHorizontal,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('تسجيل الدخول', style: AppTypography.headline)
                              .animate()
                              .fadeIn(delay: 150.ms, duration: 300.ms)
                              .slideY(begin: 0.15, end: 0, delay: 150.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'يلا نكمل رحلتك التعليمية! 🚀',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            label: 'البريد الإلكتروني',
                            hint: 'أدخل بريدك الإلكتروني',
                            controller: _identifierController,
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.username],
                          ).animate().fadeIn(delay: 250.ms, duration: 300.ms).slideY(
                              begin: 0.1, end: 0, delay: 250.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            label: 'كلمة المرور',
                            hint: 'أدخل كلمة المرور',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                          ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(
                              begin: 0.1, end: 0, delay: 300.ms, duration: 300.ms),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('نسيت كلمة المرور؟'),
                            ),
                          ).animate().fadeIn(delay: 350.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: 'تسجيل الدخول',
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(
                              begin: 0.1, end: 0, delay: 400.ms, duration: 300.ms),
                          const SizedBox(height: AppSpacing.xl),
                          const _OrDivider().animate().fadeIn(delay: 450.ms),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('ليس لديك حساب؟', style: AppTypography.bodySmall),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                ),
                                child: const Text('إنشاء حساب جديد'),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _QuadroCloudFooter(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return DecorativeHeader(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
                // Placeholder welcome animation - swap for a branded/
                // education-themed Lottie once one is chosen; this one is
                // only confirmed stable and free to use (hosted in the
                // lottie package's own example assets), not a final
                // creative pick.
                SizedBox(
                  height: 150,
                  child: Lottie.network(
                    'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    )
                    // Gentle idle float - the kind of small, constant motion
                    // that makes a screen feel alive instead of static.
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -8, duration: 1600.ms, curve: Curves.easeInOut),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'EduFirstOnline',
                  style: AppTypography.headline.copyWith(color: Colors.white),
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                const SizedBox(height: 2),
                Text(
                  'منصة "ذا فيرست" التعليمية',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                const SizedBox(height: AppSpacing.lg),
                // Value-prop chips - gives a first-time student a reason to
                // care in 3 seconds, and puts the gold accent color to real
                // use instead of it sitting unused in the palette.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _FeatureChip(icon: Icons.menu_book_rounded, label: 'دروس شيقة'),
                    SizedBox(width: AppSpacing.sm),
                    _FeatureChip(icon: Icons.emoji_events_rounded, label: 'شارات وإنجازات'),
                    SizedBox(width: AppSpacing.sm),
                    _FeatureChip(icon: Icons.trending_up_rounded, label: 'تتبع تقدمك'),
                  ],
                ).animate().fadeIn(delay: 250.ms, duration: 350.ms).slideY(
                    begin: 0.2, end: 0, delay: 250.ms, duration: 350.ms),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.gold),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('أو', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

/// Contractual branding requirement - must stay visible somewhere in the
/// app (also planned for the About/Settings screen once built in Step 5).
class _QuadroCloudFooter extends StatelessWidget {
  const _QuadroCloudFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg, top: AppSpacing.sm),
      child: Text(
        'بالتعاون مع Quadro Cloud',
        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }
}
