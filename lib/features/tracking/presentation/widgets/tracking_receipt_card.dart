// lib/features/tracking/presentation/widgets/tracking_receipt_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════════
/// TrackingReceiptCard — كارت إيصال مع رابط تتبع
/// ═══════════════════════════════════════════════════════════════
///
/// - رقم الإيصال + حالة الإيصال
/// - اسم العميل + الجهاز
/// - رابط التتبع (مع نسخ)
/// - أزرار: نسخ / واتساب / معاينة / إجراءات إضافية
///
class TrackingReceiptCard extends StatelessWidget {
  const TrackingReceiptCard({
    super.key,
    required this.receipt,
    required this.onCopyLink,
    this.onWhatsapp,
    required this.onPreview,
    required this.onRegenerate,
    required this.onRevoke,
    this.isBusy = false,
  });

  final Receipt receipt;
  final VoidCallback onCopyLink;
  final VoidCallback? onWhatsapp;
  final VoidCallback onPreview;
  final VoidCallback onRegenerate;
  final VoidCallback onRevoke;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final token = receipt.trackingToken ?? '';
    final hasToken = token.isNotEmpty;
    final shortToken =
        hasToken && token.length > 12 ? '${token.substring(0, 12)}...' : token;

    // لون حالة الإيصال
    final statusColor = _statusColor(receipt.status);

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
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceSmMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── الهيدر ───
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSmMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.receiptNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          letterSpacing: 0.3,
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
                            receipt.status.labelAr,
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
                // قائمة إضافية (تجديد / إلغاء)
                if (hasToken)
                  PopupMenuButton<String>(
                    enabled: !isBusy,
                    icon: Icon(
                      Icons.more_vert,
                      size: AppSizes.iconSm,
                      color: scheme.onSurfaceVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    onSelected: (v) {
                      if (v == 'regenerate') onRegenerate();
                      if (v == 'revoke') onRevoke();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'regenerate',
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              size: AppSizes.iconSm,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: AppSizes.spaceSm),
                            const Text('تجديد الرابط'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'revoke',
                        child: Row(
                          children: [
                            Icon(
                              Icons.link_off,
                              size: AppSizes.iconSm,
                              color: scheme.error,
                            ),
                            const SizedBox(width: AppSizes.spaceSm),
                            Text(
                              'إلغاء الرابط',
                              style: TextStyle(color: scheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── العميل + الجهاز ───
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
                    icon: Icons.person_outline,
                    label: 'العميل',
                    value: receipt.customerName,
                    scheme: scheme,
                  ),
                  const SizedBox(height: AppSizes.spaceXs),
                  _infoRow(
                    context,
                    icon: Icons.phone_android_outlined,
                    label: 'الجهاز',
                    value: [
                      receipt.deviceBrand,
                      receipt.deviceModel,
                    ].where((e) => e != null && e.isNotEmpty).join(' '),
                    scheme: scheme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── رابط التتبع ───
            if (hasToken)
              Container(
                padding: const EdgeInsets.all(AppSizes.spaceSm),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    Expanded(
                      child: Text(
                        shortToken,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: isBusy ? null : onCopyLink,
                      icon: const Icon(Icons.copy, size: 16),
                      tooltip: 'نسخ الرابط',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      color: scheme.primary,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSizes.spaceSm),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: scheme.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_off,
                      size: 16,
                      color: scheme.error,
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    Expanded(
                      child: Text(
                        'لا يوجد رابط تتبع',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── الأزرار ───
            Row(
              children: [
                // معاينة
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onPreview,
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('معاينة'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        AppSizes.buttonHeightMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSm),
                // واتساب
                if (onWhatsapp != null && hasToken)
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: isBusy ? null : onWhatsapp,
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('واتساب'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppSizes.buttonHeightMd,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

  /// لون حالة الإيصال
  Color _statusColor(ReceiptStatus status) {
    switch (status) {
      case ReceiptStatus.received:
        return const Color(0xFF3B82F6);
      case ReceiptStatus.inProgress:
        return const Color(0xFFF59E0B);
      case ReceiptStatus.waitingParts:
        return const Color(0xFF8B5CF6);
      case ReceiptStatus.ready:
        return const Color(0xFF10B981);
      case ReceiptStatus.delivered:
        return const Color(0xFF059669);
      case ReceiptStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

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
            value.isEmpty ? '—' : value,
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
