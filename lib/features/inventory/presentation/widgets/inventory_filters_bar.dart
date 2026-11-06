// lib/features/inventory/presentation/widgets/inventory_filters_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/device_brands.dart';
import '../../../../core/services/inventory_service.dart';
import '../../data/models/inventory_item.dart';
import '../../data/models/supplier_simple.dart';

class InventoryFiltersBar extends ConsumerWidget {
  const InventoryFiltersBar({
    super.key,
    required this.filter,
    required this.searchController,
    required this.stats,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onToggleLowStock,
    required this.onToggleOutOfStock,
    required this.onClearFilters,
    required this.onSupplierChanged,
    required this.onBrandChanged,
  });

  final InventoryFilter filter;
  final TextEditingController searchController;
  final InventoryStats stats;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<InventoryCategory?> onCategoryChanged;
  final VoidCallback onToggleLowStock;
  final VoidCallback onToggleOutOfStock;
  final VoidCallback onClearFilters;
  final ValueChanged<String?> onSupplierChanged;
  final ValueChanged<String?> onBrandChanged;

  bool get _hasAnyFilter =>
      filter.category != null ||
      filter.supplierId != null ||
      filter.brandName != null ||
      filter.onlyLowStock ||
      filter.onlyOutOfStock ||
      (filter.search != null && filter.search!.isNotEmpty);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Search Bar ───
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم، SKU، أو الباركود',
              prefixIcon:
                  Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceSmMd,
                vertical: AppSizes.spaceSm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                borderSide: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                borderSide: BorderSide(
                    color: scheme.primary, width: AppSizes.borderMedium),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ─── Category chips ───
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _AllChip(
                isSelected: filter.category == null,
                onTap: () => onCategoryChanged(null),
                scheme: scheme,
              ),
              for (final category in InventoryCategory.values)
                _CategoryChip(
                  category: category,
                  count: stats.countOf(category),
                  isSelected: filter.category == category,
                  onTap: () => onCategoryChanged(category),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ─── Toggles + Clear ───
          Row(
            children: [
              _FilterToggle(
                label: 'منخفض (${stats.lowStockCount})',
                icon: Icons.warning_amber_outlined,
                isActive: filter.onlyLowStock,
                onTap: onToggleLowStock,
                scheme: scheme,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              _FilterToggle(
                label: 'خلص (${stats.outOfStockCount})',
                icon: Icons.remove_circle_outline,
                isActive: filter.onlyOutOfStock,
                onTap: onToggleOutOfStock,
                scheme: scheme,
                color: const Color(0xFFEF4444),
              ),
              const Spacer(),
              if (_hasAnyFilter)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('مسح', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceSm),

          // ─── فلتر الموردين ───
          Consumer(
            builder: (context, ref, child) {
              final suppliersAsync = ref.watch(suppliersProvider);
              return suppliersAsync.when(
                loading: () => const SizedBox(height: 40),
                error: (err, _) => const SizedBox.shrink(),
                data: (suppliers) => DropdownButtonFormField<String?>(
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.store_outlined, size: 18),
                    hintText: 'كل الموردين',
                    filled: true,
                    fillColor: isDark
                        ? scheme.surfaceContainerHigh
                        : scheme.surfaceContainerLow,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: filter.supplierId,
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('كل الموردين')),
                    ...suppliers.map((s) => DropdownMenuItem<String?>(
                          value: s.id,
                          child: Text(s.name),
                        )),
                  ],
                  onChanged: onSupplierChanged,
                ),
              );
            },
          ),

          const SizedBox(height: AppSizes.spaceSm),

          // ─── فلتر الماركة ───
          DropdownButtonFormField<String?>(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.phone_iphone, size: 18),
              hintText: 'كل الماركات',
              filled: true,
              fillColor: isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLow,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                borderSide: BorderSide.none,
              ),
            ),
            value: filter.brandName,
            items: [
              const DropdownMenuItem<String?>(
                  value: null, child: Text('كل الماركات')),
              ...deviceBrands.map((b) => DropdownMenuItem<String?>(
                    value: b.nameEn,
                    child: Text(b.nameAr),
                  )),
            ],
            onChanged: onBrandChanged,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CHIPS (الكلاسات المساعدة اللي كانت ناقصة)
// ═══════════════════════════════════════════════════════════

class _AllChip extends StatelessWidget {
  const _AllChip(
      {required this.isSelected, required this.onTap, required this.scheme});
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return _BaseChip(
      icon: Icons.list_alt_outlined,
      label: 'الكل',
      isSelected: isSelected,
      onTap: onTap,
      scheme: scheme,
      color: scheme.primary,
      count: null,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });
  final InventoryCategory category;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _BaseChip(
      icon: category.icon,
      label: category.labelAr,
      isSelected: isSelected,
      onTap: onTap,
      scheme: scheme,
      color: scheme.primary,
      count: count > 0 ? count : null,
    );
  }
}

class _BaseChip extends StatelessWidget {
  const _BaseChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
    required this.color,
    this.count,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final Color color;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            border: Border.all(
              color: isSelected
                  ? color
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: isSelected ? color : scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : scheme.onSurfaceVariant,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : scheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.scheme,
    required this.color,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.15)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            border: Border.all(
              color: isActive
                  ? color
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14, color: isActive ? color : scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? color : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
