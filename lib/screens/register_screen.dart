import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../data/education_data.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/decorative_header.dart';
import 'app_shell.dart';

/// Student sign-up - fields match exactly what `POST /auth/register/student`
/// accepts (name, email, password, phone, grade, education_stage, gender,
/// age). No extra fields invented beyond what the API validates.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  EducationStage? _stage;
  EducationGrade? _grade;
  String? _gender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _ageController.text.trim().isEmpty ||
        _stage == null ||
        _grade == null ||
        _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().registerStudent({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'phone': _phoneController.text.trim(),
        'education_stage': _stage!.key,
        'grade': _grade!.key,
        'gender': _gender,
        'age': int.tryParse(_ageController.text.trim()) ?? 15,
      });
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.person_add_alt_1_rounded, size: 48, color: Colors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Text('إنشاء حساب جديد', style: AppTypography.headline.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    'انضم لآلاف الطلاب في رحلتهم التعليمية',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'الاسم بالكامل',
                      hint: 'أدخل اسمك بالكامل',
                      controller: _nameController,
                      prefixIcon: Icons.badge_outlined,
                    ).animate().fadeIn(duration: 250.ms),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'البريد الإلكتروني',
                      hint: 'example@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ).animate().fadeIn(delay: 50.ms, duration: 250.ms),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'رقم الهاتف',
                      hint: '01xxxxxxxxx',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ).animate().fadeIn(delay: 100.ms, duration: 250.ms),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'كلمة المرور',
                      hint: '8 أحرف على الأقل',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ).animate().fadeIn(delay: 150.ms, duration: 250.ms),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _Dropdown<EducationStage>(
                            label: 'المرحلة',
                            value: _stage,
                            items: EducationData.stages,
                            itemLabel: (s) => s.nameAr,
                            onChanged: (s) => setState(() {
                              _stage = s;
                              _grade = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _Dropdown<EducationGrade>(
                            label: 'الصف',
                            value: _grade,
                            items: _stage?.grades ?? const [],
                            itemLabel: (g) => g.nameAr,
                            onChanged: (g) => setState(() => _grade = g),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 250.ms),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _Dropdown<String>(
                            label: 'النوع',
                            value: _gender,
                            items: const ['male', 'female'],
                            itemLabel: (g) => g == 'male' ? 'ذكر' : 'أنثى',
                            onChanged: (g) => setState(() => _gender = g),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            label: 'السن',
                            hint: 'مثال: 16',
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.cake_outlined,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms, duration: 250.ms),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'إنشاء الحساب',
                      isLoading: _isLoading,
                      onPressed: _handleRegister,
                    ).animate().fadeIn(delay: 300.ms, duration: 250.ms),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(itemLabel(item), style: AppTypography.body)),
          ],
          onChanged: items.isEmpty ? null : onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
