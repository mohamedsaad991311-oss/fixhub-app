// lib/features/receipts/presentation/widgets/receipt_filters_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/receipt_service.dart';
import '../../data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceiptFiltersBar — شريط فلاتر الإيصالات
/// ═══════════════════════════════════════════════════════════
///
/// - Search bar
/// - Status chips (الكل + 6 حالات)
/// - Toggle: النشطة فقط
/// - Toggle: المتأخرة فقط
/// - زر مسح الفلاتر
///
class ReceiptFiltersBar extends StatelessWidget {
  const ReceiptFiltersBar({
    super.key,
    required this.filter,
    required this.searchController,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onToggleActive,
    required this.onToggleDelayed,
    required this.onClearFilters,
    required this.statusCounts,
  });

  final ReceiptFilter filter;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ReceiptStatus?> onStatusChanged;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleDelayed;
  final VoidCallback onClearFilters;

  /// عدد كل حالة (لعرضه في الـ chip)
  final Map<ReceiptStatus, int> statusCounts;

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
              hintText: 'ابحث برقم الإيصال، اسم العميل، أو التليفون',
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

          // ─── Status chips (Wrap — كل الـ chips ظاهرة) ───
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // "الكل"
              _StatusChipAll(
                isSelected: filter.status == null,
                onTap: () => onStatusChanged(null),
                scheme: scheme,
              ),

              // كل حالة
              for (final status in ReceiptStatus.values)
                _StatusChipWithCount(
                  status: status,
                  count: statusCounts[status] ?? 0,
                  isSelected: filter.status == status,
                  onTap: () => onStatusChanged(status),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ─── Toggles + Clear ───
          Row(
            children: [
              // النشطة فقط
              _FilterToggle(
                label: 'النشطة',
                icon: Icons.pending_outlined,
                isActive: filter.onlyActive,
                onTap: onToggleActive,
                scheme: scheme,
              ),
              const SizedBox(width: 6),

              // المتأخرة
              _FilterToggle(
                label: 'المتأخرة',
                icon: Icons.warning_amber_outlined,
                isActive: filter.onlyDelayed,
                onTap: onToggleDelayed,
                scheme: scheme,
                color: const Color(0xFFEF4444),
              ),

              const Spacer(),

              // مسح الفلاتر
              if (filter.status != null ||
                  filter.onlyActive ||
                  filter.onlyDelayed ||
                  (filter.customerSearch != null &&
                      filter.customerSearch!.isNotEmpty))
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text(
                    'مسح',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
//  STATUS CHIP WITH COUNT
// ═══════════════════════════════════════════════════════════

class _StatusChipWithCount extends StatelessWidget {
  const _StatusChipWithCount({
    required this.status,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final ReceiptStatus status;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = status.color;

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
                status.icon,
                size: 14,
                color: isSelected ? color : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                status.labelAr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : scheme.onSurfaceVariant,
                ),
              ),
              if (count > 0) ...[
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

// ═══════════════════════════════════════════════════════════
//  ALL CHIP
// ═══════════════════════════════════════════════════════════

class _StatusChipAll extends StatelessWidget {
  const _StatusChipAll({
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

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
                ? scheme.primary.withValues(alpha: 0.15)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            border: Border.all(
              color: isSelected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.list_alt_outlined,
                size: 14,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'الكل',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
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
//  FILTER TOGGLE
// ═══════════════════════════════════════════════════════════

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.scheme,
    this.color,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? scheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? accent.withValues(alpha: 0.15)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            border: Border.all(
              color: isActive
                  ? accent
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
                color: isActive ? accent : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? accent : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
