// lib/features/admin/presentation/widgets/device_reset_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/admin_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// DeviceResetCard — كارت طلب إعادة تعيين جهاز
/// ═══════════════════════════════════════════════════════════════
class DeviceResetCard extends StatelessWidget {
  const DeviceResetCard({
    super.key,
    required this.request,
    this.userName,
    this.tenantName,
    this.onApprove,
    this.onReject,
    this.onTap,
    this.isBusy = false,
  });

  final DeviceResetRequest request;
  final String? userName;
  final String? tenantName;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // لون وأيقونة حسب الحالة
    final (statusColor, statusIcon) = _styleForStatus(request.status);

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
                // ─── الهيدر ───
                Row(
                  children: [
                    // أيقونة الحالة
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Icon(
                        statusIcon,
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
                            userName ?? 'مستخدم',
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
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: AppSizes.spaceSm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusSm,
                                  ),
                                ),
                                child: Text(
                                  request.statusLabelAr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              if (tenantName != null) ...[
                                const SizedBox(width: AppSizes.spaceXs),
                                Flexible(
                                  child: Text(
                                    tenantName!,
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

                    // الوقت
                    Text(
                      _formatRelativeTime(request.requestedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.spaceSmMd),

                // ─── معلومات الجهاز ───
                Container(
                  padding: const EdgeInsets.all(AppSizes.spaceSm),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        context,
                        icon: Icons.phone_android_outlined,
                        label: 'الجهاز الجديد',
                        value: request.requestedDeviceName ?? 'غير محدد',
                        scheme: scheme,
                      ),
                      if (request.requestedPlatform != null) ...[
                        const SizedBox(height: AppSizes.spaceXs),
                        _infoRow(
                          context,
                          icon: Icons.devices_outlined,
                          label: 'المنصة',
                          value: request.requestedPlatform!,
                          scheme: scheme,
                        ),
                      ],
                      if (request.reason != null &&
                          request.reason!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.spaceXs),
                        _infoRow(
                          context,
                          icon: Icons.notes_outlined,
                          label: 'السبب',
                          value: request.reason!,
                          scheme: scheme,
                        ),
                      ],
                    ],
                  ),
                ),

                // ─── أزرار الموافقة/الرفض (للطلبات المعلقة فقط) ───
                if (request.isPending && onApprove != null && onReject != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.spaceSmMd),
                    child: isBusy
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: onReject,
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('رفض'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                    side: const BorderSide(
                                      color: Color(0xFFEF4444),
                                    ),
                                    minimumSize: const Size.fromHeight(
                                      AppSizes.buttonHeightMd,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.spaceSm),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: onApprove,
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('موافقة'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    minimumSize: const Size.fromHeight(
                                      AppSizes.buttonHeightMd,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),

                // ─── عرض الملاحظات لو الطلب تمت معالجته ───
                if (!request.isPending &&
                    request.adminNotes != null &&
                    request.adminNotes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.spaceSm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.spaceSm),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: AppSizes.spaceXs),
                          Expanded(
                            child: Text(
                              request.adminNotes!,
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  /// لون وأيقونة حسب الحالة
  (Color, IconData) _styleForStatus(String status) {
    switch (status) {
      case 'pending':
        return (const Color(0xFFF59E0B), Icons.hourglass_top);
      case 'approved':
        return (const Color(0xFF10B981), Icons.check_circle_outline);
      case 'rejected':
        return (const Color(0xFFEF4444), Icons.cancel_outlined);
      default:
        return (const Color(0xFF64748B), Icons.help_outline);
    }
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
            maxLines: 2,
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

  /// وقت نسبي بالعربي
  String _formatRelativeTime(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return '${d.day}/${d.month}';
  }
}
