// lib/features/inventory/presentation/widgets/inventory_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/inventory_item.dart';
import '../../data/models/inventory_variants.dart';
import '../../data/models/supplier_simple.dart';

enum InventoryViewMode { grid, list, table }

class InventoryCard extends StatelessWidget {
  const InventoryCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.viewMode = InventoryViewMode.grid,
  });

  final InventoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final InventoryViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    if (viewMode == InventoryViewMode.table) return _buildTableRow(context);
    if (viewMode == InventoryViewMode.list) return _buildListItem(context);
    return _buildGridCard(context);
  }

  // ─────────────────────────────────────────────────────────
  //  1. عرض الشبكة (Grid Card)
  // ─────────────────────────────────────────────────────────
  Widget _buildGridCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertColor = _alertColor();
    final variantColor = Color(item.variant.colorValue);

    final Color bgColor = item.quantity <= 0
        ? const Color(0xFFEF4444).withValues(alpha: 0.25)
        : (item.isLowStock
            ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
            : (isDark
                ? scheme.surfaceContainerHigh
                : scheme.surfaceContainerLow));

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        hoverColor: scheme.primary.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: alertColor ?? scheme.outlineVariant.withValues(alpha: 0.5),
              width: alertColor != null ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Icon(item.category.icon,
                          color: scheme.primary, size: 22),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
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
                                color: scheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.categoryLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onPrimaryContainer),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: variantColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color:
                                          variantColor.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  item.variant.labelAr,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: variantColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              color: scheme.primary,
                              tooltip: 'تعديل',
                              visualDensity: VisualDensity.compact,
                              onPressed: onTap,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: scheme.error,
                              tooltip: 'حذف',
                              visualDensity: VisualDensity.compact,
                              onPressed: onLongPress,
                            ),
                          ],
                        ),
                        _QuantityBadge(item: item),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      CurrencyFormatter.format(item.costPrice),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    if (item.supplierId != null)
                      Consumer(
                        builder: (context, ref, child) {
                          final suppliersAsync = ref.watch(suppliersProvider);
                          return suppliersAsync.maybeWhen(
                            data: (suppliers) {
                              final supplier = suppliers.firstWhere(
                                (s) => s.id == item.supplierId,
                                orElse: () => SimpleSupplier(id: '', name: ''),
                              );
                              if (supplier.name.isEmpty)
                                return const SizedBox.shrink();
                              return Row(
                                children: [
                                  Icon(Icons.store_outlined,
                                      size: 12, color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 2),
                                  Text(supplier.name,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: scheme.onSurfaceVariant)),
                                  const SizedBox(width: 8),
                                ],
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          );
                        },
                      ),
                    if (item.quantity <= 0)
                      _StatusBadge(label: 'خلص', color: const Color(0xFFEF4444))
                    else if (item.isLowStock)
                      _StatusBadge(
                          label: 'قارب على النفاد',
                          color: const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  2. عرض القائمة (List Item) — تم إضافة الأزرار هنا ✅
  // ─────────────────────────────────────────────────────────
  Widget _buildListItem(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variantColor = Color(item.variant.colorValue);

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      tileColor: item.quantity <= 0
          ? const Color(0xFFEF4444).withValues(alpha: 0.2)
          : (item.isLowStock
              ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
              : (isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLow)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
            color:
                _alertColor() ?? scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: scheme.primary.withValues(alpha: 0.15),
        child: Icon(item.category.icon, color: scheme.primary, size: 20),
      ),
      title: Text(
        item.displayName(isArabic: true),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(item.categoryLabel,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
          const SizedBox(width: 6),
          Text('|', style: TextStyle(color: scheme.outlineVariant)),
          const SizedBox(width: 6),
          Text(item.variant.labelAr,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: variantColor)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ أزرار التعديل والحذف
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: scheme.primary,
            tooltip: 'تعديل',
            visualDensity: VisualDensity.compact,
            onPressed: onTap,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: scheme.error,
            tooltip: 'حذف',
            visualDensity: VisualDensity.compact,
            onPressed: onLongPress,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(CurrencyFormatter.format(item.costPrice),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary)),
              Text('تكلفة',
                  style:
                      TextStyle(fontSize: 9, color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(width: 12),
          _QuantityBadge(item: item),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  3. عرض الجدول (Table Row) — تم إضافة الأزرار هنا ✅
  // ─────────────────────────────────────────────────────────
  Widget _buildTableRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final variantColor = Color(item.variant.colorValue);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: item.quantity <= 0
              ? const Color(0xFFEF4444).withValues(alpha: 0.1)
              : (item.isLowStock
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                  : Colors.transparent),
          border: Border(
              bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.3))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                item.displayName(isArabic: true),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(item.categoryLabel,
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ),
            Expanded(
              flex: 2,
              child: Text(item.variant.labelAr,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: variantColor)),
            ),
            Expanded(
              flex: 2,
              child: Text(CurrencyFormatter.format(item.costPrice),
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: item.quantity <= 0
                      ? const Color(0xFFEF4444)
                      : scheme.onSurface,
                ),
              ),
            ),
            // ✅ أزرار التعديل والحذف في الجدول
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    color: scheme.primary,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onTap,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    color: scheme.error,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onLongPress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _alertColor() {
    if (item.quantity <= 0) return const Color(0xFFEF4444);
    if (item.isLowStock) return const Color(0xFFF59E0B);
    return null;
  }
}

class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = _colors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${item.quantity}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: fg,
                  height: 1.1)),
          Text('متاح',
              style: TextStyle(fontSize: 8, color: fg.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  (Color, Color) _colors() {
    if (item.quantity <= 0)
      return (
        const Color(0xFFEF4444).withValues(alpha: 0.15),
        const Color(0xFFEF4444)
      );
    if (item.isLowStock)
      return (
        const Color(0xFFF59E0B).withValues(alpha: 0.15),
        const Color(0xFFF59E0B)
      );
    return (
      const Color(0xFF10B981).withValues(alpha: 0.12),
      const Color(0xFF10B981)
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
