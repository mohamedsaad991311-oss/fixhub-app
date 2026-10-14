// lib/features/receipts/presentation/widgets/receipt_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/receipt.dart';
import 'receipt_status_chip.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceiptCard — كارت إيصال في القائمة
/// ═══════════════════════════════════════════════════════════
///
/// بيعرض:
/// - رقم الإيصال + الحالة
/// - اسم العميل + رقم التليفون
/// - الجهاز (ماركة + موديل)
/// - الإجمالي + المتبقي
/// - الأولوية + badge متأخر
/// - عدد الأعطال
///
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    super.key,
    required this.receipt,
    this.onTap,
    this.onLongPress,
  });

  final Receipt receipt;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: receipt.isDelayed
                  ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: receipt.isDelayed ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header: رقم + حالة ───
              _CardHeader(receipt: receipt, scheme: scheme),

              // ─── Divider ───
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),

              // ─── Body ───
              Padding(
                padding: const EdgeInsets.all(AppSizes.spaceSmMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── العميل ───
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            receipt.customerName.isEmpty
                                ? 'بدون اسم'
                                : receipt.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (receipt.customerPhone != null &&
                            receipt.customerPhone!.isNotEmpty)
                          Text(
                            receipt.customerPhone!,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // ─── الجهاز ───
                    Row(
                      children: [
                        Icon(
                          Icons.smartphone_outlined,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _deviceLabel(receipt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ─── الأعطال ───
                    if (receipt.issuesCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${receipt.issuesCount} عطل',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ─── Footer: السعر + المتبقي ───
              if (receipt.total > 0 || receipt.deposit > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceSmMd,
                    vertical: AppSizes.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: Border(
                      top: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // الإجمالي
                      _PriceStat(
                        label: 'الإجمالي',
                        value: CurrencyFormatter.format(receipt.total),
                        color: scheme.onSurface,
                      ),
                      const SizedBox(width: AppSizes.spaceMd),
                      // المدفوع
                      if (receipt.deposit > 0)
                        _PriceStat(
                          label: 'مدفوع',
                          value: CurrencyFormatter.format(receipt.deposit),
                          color: const Color(0xFF10B981),
                        ),
                      const Spacer(),
                      // المتبقي
                      if (receipt.remainingAmount > 0)
                        _PriceStat(
                          label: 'متبقي',
                          value:
                              CurrencyFormatter.format(receipt.remainingAmount),
                          color: scheme.error,
                          alignEnd: true,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _deviceLabel(Receipt r) {
    final parts = <String>[];
    if (r.deviceBrand != null && r.deviceBrand!.isNotEmpty) {
      parts.add(r.deviceBrand!);
    }
    if (r.deviceModel != null && r.deviceModel!.isNotEmpty) {
      parts.add(r.deviceModel!);
    }
    if (parts.isEmpty) {
      if (r.deviceType != null && r.deviceType!.isNotEmpty) {
        return r.deviceType!;
      }
      return 'جهاز';
    }
    return parts.join(' ');
  }
}

// ═══════════════════════════════════════════════════════════
//  HEADER
// ═══════════════════════════════════════════════════════════

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.receipt, required this.scheme});

  final Receipt receipt;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSmMd,
        vertical: AppSizes.spaceSm,
      ),
      child: Row(
        children: [
          // رقم الإيصال
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    receipt.receiptNumber.isEmpty
                        ? 'بدون رقم'
                        : receipt.receiptNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Badge متأخر
          if (receipt.isDelayed) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    size: 12,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'متأخر',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],

          // الحالة
          ReceiptStatusChip(
            status: receipt.status,
            size: StatusChipSize.small,
            variant: StatusChipVariant.soft,
          ),

          // الأولوية
          if (receipt.priority != ReceiptPriority.normal) ...[
            const SizedBox(width: 6),
            ReceiptPriorityChip(
              priority: receipt.priority,
              size: StatusChipSize.small,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PRICE STAT
// ═══════════════════════════════════════════════════════════

class _PriceStat extends StatelessWidget {
  const _PriceStat({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
