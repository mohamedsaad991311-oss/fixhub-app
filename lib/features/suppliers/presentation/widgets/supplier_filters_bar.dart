// lib/features/suppliers/presentation/widgets/supplier_filters_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/supplier_service.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierFiltersBar — شريط فلاتر الموردين
/// ═══════════════════════════════════════════════════════════
class SupplierFiltersBar extends StatelessWidget {
  const SupplierFiltersBar({
    super.key,
    required this.filter,
    required this.searchController,
    required this.stats,
    required this.onSearchChanged,
    required this.onToggleActive,
    required this.onToggleWithDebt,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  final SupplierFilter filter;
  final TextEditingController searchController;
  final SupplierStats stats;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleWithDebt;
  final ValueChanged<SupplierSortBy> onSortChanged;
  final VoidCallback onClearFilters;

  bool get _hasAnyFilter =>
      !filter.onlyActive ||
      filter.onlyWithDebt ||
      filter.sortBy != SupplierSortBy.name ||
      (filter.search != null && filter.search!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
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
              hintText: 'ابحث بالاسم، التليفون، الإيميل، أو المسؤول',
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
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
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                borderSide: BorderSide(
                  color: scheme.primary,
                  width: AppSizes.borderMedium,
                ),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ─── Toggles ───
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // نشط فقط
              _FilterToggle(
                label: 'النشطين فقط',
                icon: Icons.check_circle_outline,
                isActive: filter.onlyActive,
                onTap: onToggleActive,
                scheme: scheme,
                color: const Color(0xFF10B981),
              ),

              // عليهم رصيد
              _FilterToggle(
                label: 'عليهم رصيد',
                icon: Icons.account_balance_wallet_outlined,
                isActive: filter.onlyWithDebt,
                onTap: onToggleWithDebt,
                scheme: scheme,
                color: const Color(0xFFEF4444),
              ),

              // ترتيب
              _SortMenu(
                current: filter.sortBy,
                ascending: filter.sortAscending,
                onChanged: onSortChanged,
                scheme: scheme,
              ),

              // مسح
              if (_hasAnyFilter)
                _ClearButton(onTap: onClearFilters, scheme: scheme),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  FILTER TOGGLE
// ═══════════════════════════════════════════════════════════

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
              Icon(
                icon,
                size: 14,
                color: isActive ? color : scheme.onSurfaceVariant,
              ),
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

// ═══════════════════════════════════════════════════════════
//  SORT MENU
// ═══════════════════════════════════════════════════════════

class _SortMenu extends StatelessWidget {
  const _SortMenu({
    required this.current,
    required this.ascending,
    required this.onChanged,
    required this.scheme,
  });

  final SupplierSortBy current;
  final bool ascending;
  final ValueChanged<SupplierSortBy> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SupplierSortBy>(
      tooltip: 'ترتيب',
      onSelected: onChanged,
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        _sortItem(SupplierSortBy.name, 'الاسم', Icons.sort_by_alpha),
        _sortItem(SupplierSortBy.balance, 'الرصيد', Icons.trending_up),
        _sortItem(
          SupplierSortBy.createdAt,
          'الأحدث',
          Icons.calendar_today_outlined,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 14,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _label(current),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<SupplierSortBy> _sortItem(
    SupplierSortBy type,
    String label,
    IconData icon,
  ) {
    final isCurrent = type == current;
    return PopupMenuItem<SupplierSortBy>(
      value: type,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isCurrent ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent ? scheme.primary : scheme.onSurface,
            ),
          ),
          if (isCurrent) ...[
            const Spacer(),
            Icon(Icons.check, size: 16, color: scheme.primary),
          ],
        ],
      ),
    );
  }

  String _label(SupplierSortBy s) {
    switch (s) {
      case SupplierSortBy.name:
        return 'الاسم';
      case SupplierSortBy.balance:
        return 'الرصيد';
      case SupplierSortBy.createdAt:
        return 'الأحدث';
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  CLEAR BUTTON
// ═══════════════════════════════════════════════════════════

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap, required this.scheme});

  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: scheme.error.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.clear_all,
              size: 14,
              color: scheme.error,
            ),
            const SizedBox(width: 4),
            Text(
              'مسح',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: scheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
