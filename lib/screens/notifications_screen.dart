import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_card.dart';
import '../widgets/decorative_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationService.instance.list();
  }

  Future<void> _refresh() async {
    final next = NotificationService.instance.list();
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<void> _markAllRead() async {
    await NotificationService.instance.markAllRead();
    _refresh();
  }

  Future<void> _openNotification(NotificationItem item) async {
    if (!item.isRead) {
      await NotificationService.instance.markRead(item.id);
      _refresh();
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الإشعارات', style: AppTypography.headline.copyWith(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(
                          'كل جديد يخص دوراتك هنا 🔔',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllRead,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('تعليم الكل كمقروء'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _refresh,
                child: FutureBuilder<List<NotificationItem>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SkeletonList();
                    }
                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          EmptyState(
                            title: 'تعذر تحميل الإشعارات',
                            icon: Icons.wifi_off_rounded,
                            actionLabel: 'إعادة المحاولة',
                            onAction: _refresh,
                          ),
                        ],
                      );
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return ListView(
                        children: const [
                          EmptyState(
                            title: 'لا توجد إشعارات بعد',
                            message: 'ستظهر هنا كل التحديثات المتعلقة بدوراتك',
                            icon: Icons.notifications_none_rounded,
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => _NotificationTile(item: items[i], onTap: () => _openNotification(items[i])),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  IconData get _icon => switch (item.type) {
        'quiz_result' || 'quiz_fully_graded' => Icons.quiz_rounded,
        'course_enrolled' || 'payment_received' => Icons.shopping_bag_rounded,
        'teacher_approved' => Icons.verified_rounded,
        _ => Icons.notifications_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      animateIn: true,
      color: item.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            child: Icon(_icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.body, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(intl.DateFormat('d MMM, h:mm a', 'ar').format(item.createdAt), style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          if (!item.isRead)
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}
