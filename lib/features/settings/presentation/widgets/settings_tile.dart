// lib/features/settings/presentation/widgets/settings_tile.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════
/// SettingsTile — عنصر في قائمة الإعدادات
/// ═══════════════════════════════════════════════════════════════
///
/// - أيقونة + عنوان + وصف فرعي (اختياري)
/// - trailing widget (افتراضياً chevron)
/// - onTap للضغط
/// - isDestructive للإجراءات الخطيرة (حذف/خروج)
///
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.isDestructive = false,
    this.showChevron = true,
    this.badge,
  });

  /// الأيقونة الرئيسية
  final IconData icon;

  /// العنوان
  final String title;

  /// الوصف الفرعي (اختياري)
  final String? subtitle;

  /// Widget على اليمين (بيستبدل chevron الافتراضي)
  final Widget? trailing;

  /// عند الضغط
  final VoidCallback? onTap;

  /// لون الأيقونة (افتراضياً primary)
  final Color? iconColor;

  /// إجراء خطير (لون أحمر)
  final bool isDestructive;

  /// إظهار chevron على اليمين
  final bool showChevron;

  /// شارة صغيرة (مثلاً "جديد" أو عدد)
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveIconColor =
        isDestructive ? scheme.error : (iconColor ?? scheme.primary);

    final effectiveTextColor = isDestructive ? scheme.error : scheme.onSurface;

    final effectiveSubtitleColor = isDestructive
        ? scheme.error.withValues(alpha: 0.7)
        : scheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceSmMd,
            vertical: AppSizes.spaceSm,
          ),
          child: Row(
            children: [
              // ──── Icon box ────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconSm,
                  color: effectiveIconColor,
                ),
              ),

              const SizedBox(width: AppSizes.spaceSmMd),

              // ──── Title + Subtitle ────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: effectiveTextColor,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: AppSizes.spaceSm),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: effectiveSubtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.spaceSm),

              // ──── Trailing ────
              if (trailing != null)
                trailing!
              else if (showChevron)
                Icon(
                  Icons.chevron_left, // RTL: بيشاور على اليسار
                  size: AppSizes.iconSm,
                  color: isDark
                      ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
