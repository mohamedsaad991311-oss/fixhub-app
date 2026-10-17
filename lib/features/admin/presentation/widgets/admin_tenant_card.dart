// lib/features/admin/presentation/widgets/admin_tenant_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../auth/data/models/tenant.dart';

/// ═══════════════════════════════════════════════════════════════
/// AdminTenantCard — كارت ورشة في لوحة الأدمن
/// ═══════════════════════════════════════════════════════════════
class AdminTenantCard extends StatelessWidget {
  const AdminTenantCard({
    super.key,
    required this.tenant,
    required this.staffCount,
    required this.onToggleActive,
    this.onTap,
    this.onEditSubscription,
    this.isBusy = false,
  });

  final Tenant tenant;
  final int staffCount;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback? onTap;
  final VoidCallback? onEditSubscription;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان الحالة
    final isActive = tenant.isActive;
    final statusColor =
        isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    // اشتراك
    final expiresAt = tenant.subscriptionExpiresAt;
    final daysLeft = expiresAt?.difference(DateTime.now()).inDays;
    final isExpired = daysLeft != null && daysLeft < 0;
    final isExpiringSoon = daysLeft != null && daysLeft >= 0 && daysLeft <= 7;

    Color subColor = const Color(0xFF10B981);
    if (isExpired) {
      subColor = const Color(0xFFEF4444);
    } else if (isExpiringSoon) {
      subColor = const Color(0xFFF59E0B);
    }

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: AppSizes.borderMedium,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── الهيدر: اسم + badge ───
                Row(
                  children: [
                    // أيقونة الورشة
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Icon(
                        Icons.store,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSmMd),

                    // الاسم + الحالة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'نشط' : 'معطل',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Switch + Menu
                    if (isBusy)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else ...[
                      Switch.adaptive(
                        value: isActive,
                        onChanged: onToggleActive,
                        activeThumbColor: statusColor,
                      ),
                      if (onEditSubscription != null)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            size: AppSizes.iconSm,
                            color: scheme.onSurfaceVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                          onSelected: (v) {
                            if (v == 'subscription') {
                              onEditSubscription!();
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'subscription',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.workspace_premium_outlined,
                                    size: AppSizes.iconSm,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(width: AppSizes.spaceSm),
                                  const Text('تعديل الاشتراك'),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),

                const SizedBox(height: AppSizes.spaceSmMd),

                // ─── معلومات الاشتراك ───
                Container(
                  padding: const EdgeInsets.all(AppSizes.spaceSm),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Column(
                    children: [
                      // الخطة
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            size: 14,
                            color: subColor,
                          ),
                          const SizedBox(width: AppSizes.spaceXs),
                          Text(
                            'الخطة:',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceXs),
                          Text(
                            _planLabel(tenant.subscriptionPlan),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: subColor,
                            ),
                          ),
                          const Spacer(),
                          // الأيام المتبقية
                          if (daysLeft != null)
                            Text(
                              isExpired ? 'منتهي' : 'متبقي $daysLeft يوم',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subColor,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.spaceSm),

                      // فاصل
                      Divider(
                        height: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.3),
                      ),

                      const SizedBox(height: AppSizes.spaceSm),

                      // عدد الموظفين
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSizes.spaceXs),
                          Text(
                            'الموظفين:',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceXs),
                          Text(
                            '$staffCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          if (expiresAt != null)
                            Text(
                              'حتى ${expiresAt.day}/${expiresAt.month}/${expiresAt.year}',
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

  /// ترجمة اسم الخطة
  String _planLabel(dynamic plan) {
    final name = plan?.toString().split('.').last.toLowerCase();
    switch (name) {
      case 'free':
        return 'مجانية';
      case 'pro':
      case 'premium':
        return 'احترافية';
      default:
        return 'مجانية';
    }
  }
}
