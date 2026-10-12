// lib/features/home/presentation/widgets/low_stock_alert_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../inventory/data/models/inventory_item.dart';

/// ═══════════════════════════════════════════════════════════
/// LowStockAlertCard — كارت تنبيهات المخزون
/// ═══════════════════════════════════════════════════════════
///
/// - لو مفيش تنبيهات → يظهر "المخزون بخير" ✅
/// - لو فيه → يعرض قائمة الأصناف + زر "عرض الكل"
///
class LowStockAlertCard extends StatelessWidget {
  const LowStockAlertCard({
    super.key,
    required this.items,
    required this.totalLowStock,
    required this.totalOutOfStock,
    this.onViewAll,
    this.onTapItem,
  });

  /// الأصناف المنخفضة (أول 5)
  final List<InventoryItem> items;

  /// العدد الكلي (للـ "عرض الكل")
  final int totalLowStock;
  final int totalOutOfStock;

  /// عند الضغط على "عرض الكل"
  final VoidCallback? onViewAll;

  /// عند الضغط على صنف معيّن
  final ValueChanged<InventoryItem>? onTapItem;

  bool get _hasAlerts => totalLowStock > 0 || totalOutOfStock > 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ─── لو مفيش تنبيهات ───
    if (!_hasAlerts) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        decoration: BoxDecoration(
          color:
              isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF10B981),
                size: 22,
              ),
            ),
            const SizedBox(width: AppSizes.spaceSmMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المخزون بخير',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'لا توجد أصناف منخفضة حالياً',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ─── لو فيه تنبيهات ───
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
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
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Icon(
                    Icons.warning_amber_outlined,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تنبيهات المخزون',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _summaryText(),
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

          // ─── Items ───
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.spaceMd),
              child: Text(
                'لا توجد تفاصيل للعرض',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...items.take(5).map(
                  (item) => _ItemRow(
                    item: item,
                    onTap: onTapItem == null ? null : () => onTapItem!(item),
                  ),
                ),
        ],
      ),
    );
  }

  String _summaryText() {
    final parts = <String>[];
    if (totalLowStock > 0) {
      parts.add('$totalLowStock قارب على النفاد');
    }
    if (totalOutOfStock > 0) {
      parts.add('$totalOutOfStock نفد');
    }
    return parts.join(' • ');
  }
}

// ═══════════════════════════════════════════════════════════════
//  ITEM ROW
// ═══════════════════════════════════════════════════════════════

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, this.onTap});

  final InventoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOut = item.quantity <= 0;
    final alertColor =
        isOut ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

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
              // ─── Icon ───
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  isOut
                      ? Icons.remove_circle_outline
                      : Icons.inventory_2_outlined,
                  size: 16,
                  color: alertColor,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),

              // ─── Name ───
              Expanded(
                child: Text(
                  (item.nameAr ?? '').isNotEmpty ? item.nameAr! : item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),

              // ─── Quantity badge ───
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  isOut ? 'نفد' : '${item.quantity} / ${item.minQuantity}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: alertColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
