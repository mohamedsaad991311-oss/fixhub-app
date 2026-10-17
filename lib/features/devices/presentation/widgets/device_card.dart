// lib/features/devices/presentation/widgets/device_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../data/models/active_device.dart';

/// ═══════════════════════════════════════════════════════════════
/// DeviceCard — كارت جهاز مرتبط بحساب
/// ═══════════════════════════════════════════════════════════════
///
/// - أيقونة المنصة + اسم الجهاز
/// - علامة "هذا الجهاز" للجهاز الحالي
/// - الموديل + نظام التشغيل
/// - آخر ظهور (منذ X)
/// - الحالة (نشط / موقوف)
/// - إلغاء تفعيل (للأدمن، على الأجهزة الأخرى)
///
class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.isCurrent,
    this.canRevoke = false,
    this.onRevoke,
    this.isBusy = false,
  });

  final ActiveDevice device;
  final bool isCurrent;
  final bool canRevoke;
  final VoidCallback? onRevoke;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // لون الحالة
    final isActive = device.isActive;
    final statusColor =
        isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    // لون خاص للجهاز الحالي
    final accentColor = isCurrent ? scheme.primary : scheme.outline;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isCurrent
              ? scheme.primary.withValues(alpha: 0.5)
              : scheme.outlineVariant.withValues(alpha: 0.4),
          width: isCurrent ? AppSizes.borderThick : AppSizes.borderNormal,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceSmMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── الهيدر: أيقونة + اسم ───
            Row(
              children: [
                // أيقونة المنصة
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    device.platformIcon,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSmMd),

                // الاسم + badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              device.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: AppSizes.spaceXs),
                            _badge(
                              context,
                              label: 'هذا الجهاز',
                              color: scheme.primary,
                              icon: Icons.check_circle,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.platformLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // الحالة / busy
                if (isBusy)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  _statusDot(context, statusColor, isActive),
              ],
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── معلومات تفصيلية ───
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceSm),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                children: [
                  if (device.deviceModel != null &&
                      device.deviceModel!.isNotEmpty)
                    _infoRow(
                      context,
                      icon: Icons.phone_android_outlined,
                      label: 'الموديل',
                      value: device.deviceModel!,
                      scheme: scheme,
                    ),
                  if (device.osVersion != null &&
                      device.osVersion!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spaceXs),
                    _infoRow(
                      context,
                      icon: Icons.system_update_outlined,
                      label: 'النظام',
                      value: device.osVersion!,
                      scheme: scheme,
                    ),
                  ],
                  const SizedBox(height: AppSizes.spaceXs),
                  _infoRow(
                    context,
                    icon: Icons.access_time,
                    label: 'آخر ظهور',
                    value: device.relativeLastSeen,
                    scheme: scheme,
                  ),
                ],
              ),
            ),

            // ─── زر إلغاء التفعيل (اختياري) ───
            if (canRevoke && isActive && !isCurrent && onRevoke != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.spaceSmMd),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onRevoke,
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('إلغاء تفعيل هذا الجهاز'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      minimumSize: const Size.fromHeight(
                        AppSizes.buttonHeightMd,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

  /// شارة صغيرة (هذا الجهاز)
  Widget _badge(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// نقطة حالة (نشط / موقوف)
  Widget _statusDot(BuildContext context, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'نشط' : 'موقوف',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// صف معلومات
  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSizes.spaceXs),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSizes.spaceXs),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
