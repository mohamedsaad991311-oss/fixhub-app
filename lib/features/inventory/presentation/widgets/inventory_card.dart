// lib/features/inventory/presentation/widgets/inventory_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/inventory_item.dart';

/// ═══════════════════════════════════════════════════════════
/// InventoryCard — كارت صنف في قائمة المخزون
/// ═══════════════════════════════════════════════════════════
class InventoryCard extends StatelessWidget {
  const InventoryCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  final InventoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertColor = _alertColor(scheme);

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
              color: alertColor ?? scheme.outlineVariant.withValues(alpha: 0.5),
              width: alertColor != null ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header: الاسم + الفئة ───
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spaceSmMd,
                  AppSizes.spaceSm,
                  AppSizes.spaceSmMd,
                  AppSizes.spaceSm,
                ),
                child: Row(
                  children: [
                    // Icon category
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Icon(
                        item.category.icon,
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),

                    // Name + Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.displayName(isArabic: true),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.category.labelAr,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity badge
                    _QuantityBadge(item: item),
                  ],
                ),
              ),

              // ─── Divider ───
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),

              // ─── Body: prices + sku ───
              Padding(
                padding: const EdgeInsets.all(AppSizes.spaceSmMd),
                child: Row(
                  children: [
                    // سعر البيع
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.sell_outlined,
                        label: 'البيع',
                        value: CurrencyFormatter.format(item.sellingPrice),
                        color: const Color(0xFF10B981),
                        scheme: scheme,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
                    // سعر التكلفة
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.shopping_cart_outlined,
                        label: 'التكلفة',
                        value: CurrencyFormatter.format(item.costPrice),
                        color: scheme.onSurfaceVariant,
                        scheme: scheme,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Footer: SKU + Low Stock warning ───
              if (item.sku != null || item.isLowStock || item.quantity <= 0)
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
                      // SKU
                      if (item.sku != null && item.sku!.isNotEmpty) ...[
                        Icon(
                          Icons.qr_code_2,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.sku!,
                            textDirection: TextDirection.ltr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Low stock badge
                      if (item.quantity <= 0)
                        _StatusBadge(
                          label: 'خلص',
                          color: const Color(0xFFEF4444),
                        )
                      else if (item.isLowStock)
                        _StatusBadge(
                          label: 'قارب على النفاد',
                          color: const Color(0xFFF59E0B),
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

  /// لو الصنف منخفض → لون أصفر، لو خلص → أحمر، وإلا null
  Color? _alertColor(ColorScheme scheme) {
    if (item.quantity <= 0) return const Color(0xFFEF4444);
    if (item.isLowStock) return const Color(0xFFF59E0B);
    return null;
  }
}

// ═══════════════════════════════════════════════════════════
//  QUANTITY BADGE
// ═══════════════════════════════════════════════════════════

class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (Color bg, Color fg) = _colors(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${item.quantity}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: fg,
              height: 1.1,
            ),
          ),
          Text(
            'متاح',
            style: TextStyle(
              fontSize: 9,
              color: fg.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colors(ColorScheme scheme) {
    if (item.quantity <= 0) {
      return (
        const Color(0xFFEF4444).withValues(alpha: 0.15),
        const Color(0xFFEF4444),
      );
    }
    if (item.isLowStock) {
      return (
        const Color(0xFFF59E0B).withValues(alpha: 0.15),
        const Color(0xFFF59E0B),
      );
    }
    return (
      const Color(0xFF10B981).withValues(alpha: 0.12),
      const Color(0xFF10B981),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  MINI STAT
// ═══════════════════════════════════════════════════════════

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  STATUS BADGE
// ═══════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
