// lib/features/delivery/presentation/widgets/delivery_receipt_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════════
/// DeliveryReceiptCard — كارت إيصال جاهز للتسليم
/// ═══════════════════════════════════════════════════════════════
///
/// - Header: رقم الإيصال + شارة "جاهز"
/// - العميل + الجهاز
/// - المبالغ (إجمالي/عربون/متبقي)
/// - زر تسليم
///
class DeliveryReceiptCard extends StatelessWidget {
  const DeliveryReceiptCard({
    super.key,
    required this.receipt,
    required this.onTap,
    required this.onDeliver,
  });

  final Receipt receipt;
  final VoidCallback onTap;
  final VoidCallback onDeliver;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // حسابات المبالغ
    final total = receipt.finalCost > 0
        ? receipt.finalCost
        : (receipt.total > 0 ? receipt.total : receipt.estimatedCost);
    final deposit = receipt.deposit;
    final remaining = ((total - deposit).clamp(0, double.infinity)).toDouble();

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
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
                // ──── Header: رقم الإيصال + شارة "جاهز" ────
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receipt.receiptNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatRelativeTime(
                                receipt.updatedAt ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // شارة "جاهز"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceSm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusPill),
                      ),
                      child: const Text(
                        'جاهز',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.spaceSmMd),

                // ──── العميل ────
                _InfoRow(
                  icon: Icons.person_outline,
                  label: receipt.customerName,
                  sublabel: receipt.customerPhone,
                  scheme: scheme,
                ),

                const SizedBox(height: 6),

                // ──── الجهاز ────
                _InfoRow(
                  icon: Icons.phone_android_outlined,
                  label: [
                    receipt.deviceBrand,
                    receipt.deviceModel,
                  ].where((e) => e != null && e.isNotEmpty).join(' '),
                  sublabel: (receipt.deviceImei != null &&
                          receipt.deviceImei!.isNotEmpty)
                      ? 'IMEI: ${receipt.deviceImei}'
                      : null,
                  scheme: scheme,
                ),

                const SizedBox(height: AppSizes.spaceSmMd),

                // ──── المبالغ ────
                Container(
                  padding: const EdgeInsets.all(AppSizes.spaceSm),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      // الإجمالي
                      Expanded(
                        child: _AmountColumn(
                          label: 'الإجمالي',
                          amount: total,
                          color: scheme.onSurface,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      // العربون
                      Expanded(
                        child: _AmountColumn(
                          label: 'العربون',
                          amount: deposit,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      // المتبقي
                      Expanded(
                        child: _AmountColumn(
                          label: 'المتبقي',
                          amount: remaining,
                          color: remaining > 0
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                          bold: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceSmMd),

                // ──── زر التسليم ────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onDeliver,
                    icon: const Icon(Icons.local_shipping_outlined, size: 18),
                    label: const Text('تسليم للعميل'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size.fromHeight(AppSizes.buttonHeightMd),
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
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  String _formatRelativeTime(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════
//  INFO ROW
// ═══════════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.scheme,
    this.sublabel,
  });

  final IconData icon;
  final String label;
  final String? sublabel;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 2),
          child: Icon(
            icon,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSizes.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.isEmpty ? '—' : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              if (sublabel != null && sublabel!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sublabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AMOUNT COLUMN
// ═══════════════════════════════════════════════════════════════

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.color,
    this.bold = false,
  });

  final String label;
  final double amount;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            CurrencyFormatter.formatCompact(amount),
            maxLines: 1,
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
