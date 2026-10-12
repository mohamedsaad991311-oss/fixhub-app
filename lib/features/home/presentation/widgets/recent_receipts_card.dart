// lib/features/home/presentation/widgets/recent_receipts_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════
/// RecentReceiptsCard — كارت آخر الإيصالات
/// ═══════════════════════════════════════════════════════════
///
/// - يعرض آخر 5 إيصالات
/// - كل إيصال: رقم + عميل + جهاز + حالة + إجمالي
/// - زر "عرض الكل"
///
class RecentReceiptsCard extends StatelessWidget {
  const RecentReceiptsCard({
    super.key,
    required this.receipts,
    this.onViewAll,
    this.onTapReceipt,
  });

  final List<Receipt> receipts;
  final VoidCallback? onViewAll;
  final ValueChanged<Receipt>? onTapReceipt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ───
          Padding(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: scheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Text(
                    'آخر الإيصالات',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceSm,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Divider ───
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),

          // ─── Content ───
          if (receipts.isEmpty)
            _EmptyState()
          else
            ...receipts.take(5).map(
                  (r) => _ReceiptRow(
                    receipt: r,
                    onTap: onTapReceipt == null ? null : () => onTapReceipt!(r),
                  ),
                ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            'لا توجد إيصالات بعد',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RECEIPT ROW
// ═══════════════════════════════════════════════════════════════

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.receipt, this.onTap});

  final Receipt receipt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(receipt.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceSmMd,
            vertical: AppSizes.spaceSm,
          ),
          child: Row(
            children: [
              // ─── Status dot ───
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  _statusIcon(receipt.status),
                  size: 18,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),

              // ─── Info ───
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            receipt.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceXs),
                        Text(
                          receipt.receiptNumber,
                          style: TextStyle(
                            fontSize: 10,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _deviceLabel(receipt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceXs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            receipt.status.labelAr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),

              // ─── Total ───
              if (receipt.total > 0)
                Text(
                  CurrencyFormatter.format(receipt.total),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───

  String _deviceLabel(Receipt r) {
    final parts = <String>[];
    if ((r.deviceBrand ?? '').isNotEmpty) parts.add(r.deviceBrand!);
    if ((r.deviceModel ?? '').isNotEmpty) parts.add(r.deviceModel!);
    if (parts.isEmpty && (r.deviceType ?? '').isNotEmpty) {
      parts.add(r.deviceType!);
    }
    return parts.isEmpty ? 'جهاز' : parts.join(' ');
  }

  Color _statusColor(ReceiptStatus status) {
    switch (status) {
      case ReceiptStatus.received:
        return const Color(0xFF3B82F6); // أزرق
      case ReceiptStatus.inProgress:
        return const Color(0xFFF59E0B); // برتقالي
      case ReceiptStatus.waitingParts:
        return const Color(0xFF8B5CF6); // بنفسجي
      case ReceiptStatus.ready:
        return const Color(0xFF10B981); // أخضر
      case ReceiptStatus.delivered:
        return const Color(0xFF64748B); // رمادي
      case ReceiptStatus.rejected:
        return const Color(0xFFEF4444); // أحمر
    }
  }

  IconData _statusIcon(ReceiptStatus status) {
    switch (status) {
      case ReceiptStatus.received:
        return Icons.inbox_outlined;
      case ReceiptStatus.inProgress:
        return Icons.build_outlined;
      case ReceiptStatus.waitingParts:
        return Icons.hourglass_empty_outlined;
      case ReceiptStatus.ready:
        return Icons.check_circle_outline;
      case ReceiptStatus.delivered:
        return Icons.done_all_outlined;
      case ReceiptStatus.rejected:
        return Icons.cancel_outlined;
    }
  }
}
