// lib/features/expenses/presentation/widgets/expenses_filters_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/expense_service.dart';
import '../../data/models/expense.dart';

/// ═══════════════════════════════════════════════════════════
/// ExpensesFiltersBar — شريط فلاتر المصروفات
/// ═══════════════════════════════════════════════════════════
class ExpensesFiltersBar extends StatelessWidget {
  const ExpensesFiltersBar({
    super.key,
    required this.filter,
    required this.searchController,
    required this.categoryCounts,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onMethodChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
  });

  final ExpenseFilter filter;
  final TextEditingController searchController;
  final Map<ExpenseCategory, double> categoryCounts;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExpenseCategory?> onCategoryChanged;
  final ValueChanged<ExpensePaymentMethod?> onMethodChanged;
  final void Function(DateTime?, DateTime?) onDateRangeChanged;
  final VoidCallback onClearFilters;

  bool get _hasAnyFilter =>
      filter.category != null ||
      filter.paymentMethod != null ||
      filter.fromDate != null ||
      filter.toDate != null ||
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
              hintText: 'ابحث بالوصف، المورد، أو الملاحظات',
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
              for (final category in ExpenseCategory.values)
                _CategoryChip(
                  category: category,
                  total: categoryCounts[category] ?? 0,
                  isSelected: filter.category == category,
                  onTap: () => onCategoryChanged(category),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ─── Method chips + Date range + Clear ───
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Payment method
              _MethodChip(
                label: 'الكل',
                icon: Icons.list_alt_outlined,
                color: scheme.primary,
                isSelected: filter.paymentMethod == null,
                onTap: () => onMethodChanged(null),
                scheme: scheme,
              ),
              for (final method in ExpensePaymentMethod.values)
                _MethodChip(
                  label: method.labelAr,
                  icon: method.icon,
                  color: scheme.onSurfaceVariant,
                  isSelected: filter.paymentMethod == method,
                  onTap: () => onMethodChanged(method),
                  scheme: scheme,
                ),
              // Date range
              _DateRangeChip(
                from: filter.fromDate,
                to: filter.toDate,
                onChanged: onDateRangeChanged,
                scheme: scheme,
              ),
              // Clear
              if (_hasAnyFilter)
                InkWell(
                  onTap: onClearFilters,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CHIPS
// ═══════════════════════════════════════════════════════════

class _AllChip extends StatelessWidget {
  const _AllChip({
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

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
      total: null,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.total,
    required this.isSelected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final double total;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = category.color;

    return _BaseChip(
      icon: category.icon,
      label: category.labelAr,
      isSelected: isSelected,
      onTap: onTap,
      scheme: scheme,
      color: color,
      total: total > 0 ? total : null,
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
    this.total,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final Color color;
  final double? total;

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
              Icon(
                icon,
                size: 14,
                color: isSelected ? color : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : scheme.onSurfaceVariant,
                ),
              ),
              if (total != null && total! > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : scheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    _fmtShort(total!),
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

  String _fmtShort(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════════════════════
//  METHOD CHIP
// ═══════════════════════════════════════════════════════════

class _MethodChip extends StatelessWidget {
  const _MethodChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;

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
              Icon(
                icon,
                size: 14,
                color: isSelected ? color : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : scheme.onSurfaceVariant,
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
//  DATE RANGE CHIP
// ═══════════════════════════════════════════════════════════

class _DateRangeChip extends StatelessWidget {
  const _DateRangeChip({
    required this.from,
    required this.to,
    required this.onChanged,
    required this.scheme,
  });

  final DateTime? from;
  final DateTime? to;
  final void Function(DateTime?, DateTime?) onChanged;
  final ColorScheme scheme;

  bool get _isActive => from != null || to != null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickRange(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isActive
                ? scheme.primary.withValues(alpha: 0.15)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            border: Border.all(
              color: _isActive
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: _isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 14,
                color: _isActive ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _label(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: _isActive ? FontWeight.w700 : FontWeight.w500,
                  color: _isActive ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              if (_isActive) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => onChanged(null, null),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: scheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _label() {
    if (from == null && to == null) return 'تاريخ';
    final f = from != null ? _fmt(from!) : '—';
    final t = to != null ? _fmt(to!) : '—';
    return '$f → $t';
  }

  String _fmt(DateTime d) {
    return '${d.day}/${d.month}';
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: (from != null && to != null)
          ? DateTimeRange(start: from!, end: to!)
          : null,
    );
    if (picked != null) {
      onChanged(picked.start, picked.end);
    }
  }
}
