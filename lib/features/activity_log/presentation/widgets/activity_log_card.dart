// lib/features/activity_log/presentation/widgets/activity_log_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/activity_log_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// ActivityLogCard — كارت سجل نشاط واحد
/// ═══════════════════════════════════════════════════════════════
///
/// - أيقونة حسب نوع الإجراء
/// - وصف + وقت نسبي
/// - شارة نوع الكيان
/// - التفاصيل (metadata) في dialog
///
class ActivityLogCard extends StatelessWidget {
  const ActivityLogCard({
    super.key,
    required this.log,
    this.onTap,
  });

  final ActivityLog log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // لون وأيقونة حسب الإجراء
    final (actionColor, actionIcon) = _styleForAction(log.action);

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة الإجراء
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: actionColor.withValues(alpha: 0.3),
                      width: AppSizes.borderNormal,
                    ),
                  ),
                  child: Icon(
                    actionIcon,
                    size: AppSizes.iconSm,
                    color: actionColor,
                  ),
                ),

                const SizedBox(width: AppSizes.spaceSmMd),

                // المحتوى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // السطر الأول: وصف الإجراء + شارة الكيان
                      Row(
                        children: [
                          // شارة الإجراء
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSizes.spaceSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: actionColor.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: Text(
                              log.actionLabelAr,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: actionColor,
                              ),
                            ),
                          ),
                          // شارة الكيان
                          if (log.entityLabelAr.isNotEmpty) ...[
                            const SizedBox(width: AppSizes.spaceXs),
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: AppSizes.spaceSm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: Text(
                                log.entityLabelAr,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // الوصف
                      if (log.description != null &&
                          log.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          log.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ],

                      const SizedBox(height: 6),

                      // الوقت + المستخدم
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatRelativeTime(log.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (log.userId != null) ...[
                            const SizedBox(width: AppSizes.spaceSm),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: scheme.onSurfaceVariant,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSizes.spaceSm),
                            Icon(
                              Icons.person_outline,
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _shortUserId(log.userId!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // سهم يفتح التفاصيل
                if (log.metadata.isNotEmpty)
                  Icon(
                    Icons.chevron_left,
                    size: AppSizes.iconSm,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
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

  /// لون وأيقونة حسب الإجراء
  (Color, IconData) _styleForAction(String action) {
    switch (action) {
      case ActivityAction.create:
        return (const Color(0xFF10B981), Icons.add_circle_outline);
      case ActivityAction.update:
        return (const Color(0xFF3B82F6), Icons.edit_outlined);
      case ActivityAction.delete:
        return (const Color(0xFFEF4444), Icons.delete_outline);
      case ActivityAction.login:
        return (const Color(0xFF8B5CF6), Icons.login);
      case ActivityAction.logout:
        return (const Color(0xFF64748B), Icons.logout);
      case ActivityAction.statusChange:
        return (const Color(0xFFF59E0B), Icons.swap_horiz);
      case ActivityAction.payment:
        return (const Color(0xFF059669), Icons.payments_outlined);
      case ActivityAction.print:
        return (const Color(0xFF6366F1), Icons.print_outlined);
      case ActivityAction.export:
        return (const Color(0xFF0EA5E9), Icons.download_outlined);
      case ActivityAction.restore:
        return (const Color(0xFFF97316), Icons.restore);
      case ActivityAction.invite:
        return (const Color(0xFF14B8A6), Icons.person_add_outlined);
      case ActivityAction.view:
        return (const Color(0xFF94A3B8), Icons.visibility_outlined);
      default:
        return (const Color(0xFF64748B), Icons.circle_outlined);
    }
  }

  /// وقت نسبي بالعربي
  String _formatRelativeTime(DateTime? d) {
    if (d == null) return 'غير معروف';
    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) {
      return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  /// اختصار user id (أول 8 أحرف)
  String _shortUserId(String userId) {
    if (userId.length <= 8) return userId;
    return '${userId.substring(0, 8)}...';
  }
}
