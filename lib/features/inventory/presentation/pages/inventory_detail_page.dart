// lib/features/inventory/presentation/pages/inventory_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/inventory_item.dart';
import '../providers/inventory_detail_provider.dart';
import '../widgets/stock_adjust_sheet.dart';

/// ═══════════════════════════════════════════════════════════
/// InventoryDetailPage — صفحة تفاصيل صنف
/// ═══════════════════════════════════════════════════════════
class InventoryDetailPage extends ConsumerWidget {
  const InventoryDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(inventoryDetailProvider(itemId));

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          state.item?.displayName() ?? 'تفاصيل الصنف',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (state.item != null)
            IconButton(
              tooltip: 'تعديل',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                RouteNames.inventoryEdit,
                extra: state.item,
              ),
            ),
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(inventoryDetailProvider(itemId).notifier).refresh(),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
      bottomNavigationBar:
          state.item != null ? _StockActionsBar(item: state.item!) : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    InventoryDetailState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasItem) {
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: scheme.error),
              const SizedBox(height: AppSizes.spaceMd),
              Text(
                state.errorMessage ?? 'خطأ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: scheme.onSurface),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(inventoryDetailProvider(itemId).notifier).load(),
                icon: const Icon(Icons.refresh),
                label: const Text('حاول تاني'),
              ),
            ],
          ),
        ),
      );
    }

    final item = state.item;
    if (item == null) return const Center(child: Text('لا توجد بيانات'));

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(inventoryDetailProvider(itemId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Quantity Hero ───
            _QuantityHero(item: item),

            const SizedBox(height: AppSizes.spaceMd),

            // ─── المعلومات الأساسية ───
            _Section(
              icon: Icons.info_outline,
              title: 'المعلومات الأساسية',
              rows: [
                _Row(label: 'الاسم', value: item.name),
                if (item.nameAr != null)
                  _Row(label: 'الاسم (عربي)', value: item.nameAr!),
                _Row(label: 'الفئة', value: item.category.labelAr),
                if (item.sku != null)
                  _Row(label: 'SKU', value: item.sku!, ltr: true),
                if (item.barcode != null)
                  _Row(label: 'الباركود', value: item.barcode!, ltr: true),
                if (item.location != null)
                  _Row(label: 'الموقع', value: item.location!),
                if (item.description != null)
                  _Row(label: 'الوصف', value: item.description!),
              ],
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── المخزون ───
            _Section(
              icon: Icons.warehouse_outlined,
              title: 'المخزون',
              rows: [
                _Row(
                  label: 'الكمية الحالية',
                  value: '${item.quantity}',
                ),
                _Row(
                  label: 'الحد الأدنى',
                  value: '${item.minQuantity}',
                ),
                _Row(
                  label: 'الحالة',
                  value: item.stockStatusAr,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── التسعير ───
            _PricingSection(item: item),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── الحركات ───
            if (state.movements.isNotEmpty)
              _MovementsSection(movements: state.movements),

            const SizedBox(height: AppSizes.spaceLg),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  QUANTITY HERO
// ═══════════════════════════════════════════════════════════

class _QuantityHero extends StatelessWidget {
  const _QuantityHero({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bgColor, fgColor) = _colors(scheme);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: fgColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(item.category.icon, color: fgColor, size: 32),
          ),
          const SizedBox(width: AppSizes.spaceSmMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.displayName(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: fgColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: fgColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'متاح',
                      style: TextStyle(
                        fontSize: 12,
                        color: fgColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colors(ColorScheme scheme) {
    if (item.quantity <= 0) {
      return (
        const Color(0xFFEF4444).withValues(alpha: 0.1),
        const Color(0xFFEF4444),
      );
    }
    if (item.isLowStock) {
      return (
        const Color(0xFFF59E0B).withValues(alpha: 0.1),
        const Color(0xFFF59E0B),
      );
    }
    return (
      const Color(0xFF10B981).withValues(alpha: 0.1),
      const Color(0xFF10B981),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SECTION
// ═══════════════════════════════════════════════════════════

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
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
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: AppSizes.spaceSm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          ...rows,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              value,
              textDirection: ltr ? TextDirection.ltr : null,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PRICING
// ═══════════════════════════════════════════════════════════

class _PricingSection extends StatelessWidget {
  const _PricingSection({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money_outlined,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceSm),
              Text(
                'التسعير',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          _PriceRow(
            label: 'سعر التكلفة',
            value: CurrencyFormatter.format(item.costPrice),
            scheme: scheme,
          ),
          _PriceRow(
            label: 'سعر البيع',
            value: CurrencyFormatter.format(item.sellingPrice),
            scheme: scheme,
            color: const Color(0xFF10B981),
            bold: true,
          ),
          Divider(height: 12, color: scheme.outlineVariant),
          _PriceRow(
            label: 'الربح للوحدة',
            value: CurrencyFormatter.format(item.profit),
            scheme: scheme,
            color: item.profit >= 0 ? const Color(0xFF10B981) : scheme.error,
          ),
          _PriceRow(
            label: 'هامش الربح',
            value: '${item.profitMargin.toStringAsFixed(1)}%',
            scheme: scheme,
          ),
          Divider(height: 12, color: scheme.outlineVariant),
          _PriceRow(
            label: 'قيمة المخزون',
            value: CurrencyFormatter.format(item.stockValue),
            scheme: scheme,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.scheme,
    this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: FontWeight.w700,
              color: color ?? scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  MOVEMENTS
// ═══════════════════════════════════════════════════════════

class _MovementsSection extends StatelessWidget {
  const _MovementsSection({required this.movements});

  final List<InventoryMovement> movements;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
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
          Row(
            children: [
              Icon(Icons.history_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: AppSizes.spaceSm),
              Text(
                'سجل الحركات (${movements.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),
          ...movements.take(20).map((m) {
            final isIncrease = m.type.isIncrease;
            final color =
                isIncrease ? const Color(0xFF10B981) : const Color(0xFFEF4444);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(
                      isIncrease ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          m.type.labelAr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (m.notes != null && m.notes!.isNotEmpty)
                          Text(
                            m.notes!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${isIncrease ? "+" : "-"}${m.quantity}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      if (m.createdAt != null)
                        Text(
                          _fmt(m.createdAt!),
                          style: TextStyle(
                            fontSize: 9,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    return '${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════
//  STOCK ACTIONS BAR
// ═══════════════════════════════════════════════════════════

class _StockActionsBar extends ConsumerWidget {
  const _StockActionsBar({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isUpdating = ref.watch(inventoryItemUpdatingProvider(item.id));

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.spaceMd,
        AppSizes.spaceSmMd,
        AppSizes.spaceMd,
        MediaQuery.of(context).padding.bottom + AppSizes.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // stock in
          Expanded(
            child: FilledButton.icon(
              onPressed: isUpdating
                  ? null
                  : () => _openAdjustSheet(context, ref, isIncrease: true),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'إدخال',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size(0, AppSizes.buttonHeightLg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          // stock out
          Expanded(
            child: FilledButton.icon(
              onPressed: isUpdating
                  ? null
                  : () => _openAdjustSheet(context, ref, isIncrease: false),
              icon: const Icon(Icons.remove, size: 18),
              label: const Text(
                'إخراج',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                minimumSize: const Size(0, AppSizes.buttonHeightLg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          // adjust
          IconButton.filledTonal(
            tooltip: 'تسوية',
            onPressed: isUpdating
                ? null
                : () => _openAdjustSheet(context, ref, isAdjust: true),
            icon: const Icon(Icons.tune, size: 20),
            style: IconButton.styleFrom(
              minimumSize: const Size(52, 52),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAdjustSheet(
    BuildContext context,
    WidgetRef ref, {
    bool isIncrease = false,
    bool isAdjust = false,
  }) async {
    final result = await showModalBottomSheet<StockAdjustResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StockAdjustSheet(
        item: item,
        mode: isAdjust
            ? StockAdjustMode.adjust
            : (isIncrease ? StockAdjustMode.add : StockAdjustMode.remove),
      ),
    );

    if (result == null || !context.mounted) return;

    final notifier = ref.read(inventoryDetailProvider(item.id).notifier);

    bool ok;
    if (result.mode == StockAdjustMode.adjust) {
      ok = await notifier.adjustStock(
        newQuantity: result.quantity,
        notes: result.notes,
      );
    } else if (result.mode == StockAdjustMode.add) {
      ok = await notifier.stockIn(
        quantity: result.quantity,
        type: result.movementType,
        notes: result.notes,
      );
    } else {
      ok = await notifier.stockOut(
        quantity: result.quantity,
        type: result.movementType,
        notes: result.notes,
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم التحديث' : 'فشل التحديث'),
        backgroundColor:
            ok ? const Color(0xFF10B981) : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
