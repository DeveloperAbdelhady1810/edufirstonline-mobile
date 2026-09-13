import 'package:flutter/material.dart';

import '../models/package.dart';
import '../services/api_client.dart';
import '../services/directory_service.dart';
import '../services/webview_ticket_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/webview_screen.dart';

class PackageDetailScreen extends StatefulWidget {
  const PackageDetailScreen({super.key, required this.packageId});

  final int packageId;

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  late Future<CoursePackage> _future;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _future = DirectoryService.instance.packageDetail(widget.packageId);
  }

  void _refresh() => setState(() => _future = DirectoryService.instance.packageDetail(widget.packageId));

  Future<void> _handlePurchase() async {
    setState(() => _isPurchasing = true);
    try {
      final url = await WebviewTicketService.instance.payPackageUrl(widget.packageId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AppWebviewScreen(url: url, title: 'إتمام الشراء')),
      );
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<CoursePackage>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(AppSpacing.pageHorizontal), child: SkeletonList());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('تعذر تحميل تفاصيل الباقة'));
            }

            final package = snapshot.data!;
            final purchased = package.alreadyPurchased ?? false;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DecorativeHeader(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                                ),
                                const Spacer(),
                                if (purchased) const AppBadge(label: 'مشترك', variant: AppBadgeVariant.success, icon: Icons.check_circle),
                              ],
                            ),
                            Text(package.name, style: AppTypography.headline.copyWith(color: Colors.white)),
                            const SizedBox(height: AppSpacing.sm),
                            Text(package.teacherName, style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (package.description.isNotEmpty) ...[
                              Text('عن الباقة', style: AppTypography.title),
                              const SizedBox(height: AppSpacing.xs),
                              Text(package.description, style: AppTypography.body.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                            Text('الدورات المتضمنة (${package.courses?.length ?? 0})', style: AppTypography.title),
                            const SizedBox(height: AppSpacing.sm),
                            for (final course in package.courses ?? [])
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: AppCard(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.menu_book_rounded, color: AppColors.secondary),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(child: Text(course.title, style: AppTypography.bodySmall)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!purchased)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('السعر', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                Text('${package.price} ج.م', style: AppTypography.headline.copyWith(color: AppColors.primaryDark)),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: AppButton(
                                label: 'اشترك في الباقة',
                                icon: Icons.shopping_cart_checkout_rounded,
                                isLoading: _isPurchasing,
                                onPressed: _handlePurchase,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
