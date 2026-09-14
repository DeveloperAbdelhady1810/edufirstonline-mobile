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

/// Shown right after a brand-new Google/Apple sign-in (backend returned
/// needs_profile: true) - collects the same student-profile fields the web's
/// social-complete form does (App\Http\Controllers\Auth\SocialAuthController
/// ::storeComplete()), minus name/email/password since those already came
/// from the provider. Submits to POST /auth/social/complete-profile using
/// the short-lived ticket the sign-in call returned.
class CompleteSocialProfileScreen extends StatefulWidget {
  const CompleteSocialProfileScreen({
    super.key,
    required this.ticket,
    required this.name,
    required this.email,
  });

  final String ticket;
  final String name;
  final String email;

  @override
  State<CompleteSocialProfileScreen> createState() => _CompleteSocialProfileScreenState();
}

class _CompleteSocialProfileScreenState extends State<CompleteSocialProfileScreen> {
  late final _nameController = TextEditingController(text: widget.name);
  final _phoneController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _schoolController = TextEditingController();

  EducationStage? _stage;
  EducationGrade? _grade;
  EducationDivision? _division;
  String? _gender;
  String? _studyMode;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _parentPhoneController.dispose();
    _ageController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  bool get _needsDivision => _grade != null && _grade!.divisions.isNotEmpty;

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _parentPhoneController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _schoolController.text.trim().isEmpty ||
        _stage == null ||
        _grade == null ||
        _gender == null ||
        _studyMode == null ||
        (_needsDivision && _division == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().completeSocialProfile({
        'ticket': widget.ticket,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'parent_phone': _parentPhoneController.text.trim(),
        'education_stage': _stage!.key,
        'grade': _grade!.key,
        if (_division != null) 'division': _division!.key,
        'study_mode': _studyMode,
        'school': _schoolController.text.trim(),
        'gender': _gender,
        'age': int.tryParse(_ageController.text.trim()) ?? 15,
      });
      if (!mounted) return;
      // Don't push a second AppShell() - completeSocialProfile() already
      // called notifyListeners(), which SplashScreen's own
      // Consumer<AuthService> reacts to by rendering AppShell() itself.
      // Both would default to the same static GlobalKey (see
      // app_shell.dart) if both got built at once - popping back to reveal
      // the already-updated SplashScreen avoids ever constructing a second.
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, size: 40, color: Colors.white),
                  const SizedBox(height: AppSpacing.xs),
                  Text('استكمال بيانات الحساب', style: AppTypography.title.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    widget.email,
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
                    _SectionLabel('البيانات الشخصية'),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      label: 'الاسم بالكامل',
                      hint: 'أدخل اسمك بالكامل',
                      controller: _nameController,
                      prefixIcon: Icons.badge_outlined,
                    ).animate().fadeIn(duration: 250.ms),
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
                    ).animate().fadeIn(delay: 50.ms, duration: 250.ms),

                    const SizedBox(height: AppSpacing.xl),
                    _SectionLabel('بيانات التواصل'),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      label: 'رقم هاتفك',
                      hint: '01xxxxxxxxx',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ).animate().fadeIn(delay: 100.ms, duration: 250.ms),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'رقم هاتف ولي الأمر',
                      hint: '01xxxxxxxxx (مختلف عن رقمك)',
                      controller: _parentPhoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.family_restroom_rounded,
                    ).animate().fadeIn(delay: 150.ms, duration: 250.ms),

                    const SizedBox(height: AppSpacing.xl),
                    _SectionLabel('البيانات الدراسية'),
                    const SizedBox(height: AppSpacing.sm),
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
                              _division = null;
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
                            onChanged: (g) => setState(() {
                              _grade = g;
                              _division = null;
                            }),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 250.ms),
                    if (_needsDivision) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _Dropdown<EducationDivision>(
                        label: 'الشعبة',
                        value: _division,
                        items: _grade?.divisions ?? const [],
                        itemLabel: (d) => d.nameAr,
                        onChanged: (d) => setState(() => _division = d),
                      ).animate().fadeIn(duration: 200.ms),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _Dropdown<String>(
                      label: 'نظام الدراسة',
                      value: _studyMode,
                      items: const ['center', 'online'],
                      itemLabel: (m) => m == 'center' ? 'مركز' : 'أونلاين',
                      onChanged: (m) => setState(() => _studyMode = m),
                    ).animate().fadeIn(delay: 250.ms, duration: 250.ms),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'اسم المدرسة',
                      hint: 'أدخل اسم مدرستك',
                      controller: _schoolController,
                      prefixIcon: Icons.school_outlined,
                    ).animate().fadeIn(delay: 300.ms, duration: 250.ms),

                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'إتمام التسجيل',
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ).animate().fadeIn(delay: 350.ms, duration: 250.ms),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.body.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryDark));
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
