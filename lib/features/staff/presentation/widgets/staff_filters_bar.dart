// lib/features/staff/presentation/widgets/staff_filters_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/staff_service.dart';
import '../../../auth/data/models/app_user.dart' show UserRole, UserRoleX;

/// ═══════════════════════════════════════════════════════════
/// StaffFiltersBar — شريط فلاتر الموظفين
/// ═══════════════════════════════════════════════════════════
class StaffFiltersBar extends StatelessWidget {
  const StaffFiltersBar({
    super.key,
    required this.filter,
    required this.searchController,
    required this.roleCounts,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.onToggleActive,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  final StaffFilter filter;
  final TextEditingController searchController;
  final Map<UserRole, int> roleCounts;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UserRole?> onRoleChanged;
  final VoidCallback onToggleActive;
  final ValueChanged<StaffSortBy> onSortChanged;
  final VoidCallback onClearFilters;

  bool get _hasAnyFilter =>
      !filter.onlyActive ||
      filter.role != null ||
      filter.sortBy != StaffSortBy.name ||
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
              hintText: 'ابحث بالاسم، التليفون، الإيميل',
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

          // ─── Role chips ───
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _AllChip(
                isSelected: filter.role == null,
                onTap: () => onRoleChanged(null),
                scheme: scheme,
              ),
              for (final role in UserRole.values)
                _RoleChip(
                  role: role,
                  count: roleCounts[role] ?? 0,
                  isSelected: filter.role == role,
                  onTap: () => onRoleChanged(role),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ─── Toggles + Sort + Clear ───
          Row(
            children: [
              _FilterToggle(
                label: 'النشطين',
                icon: Icons.check_circle_outline,
                isActive: filter.onlyActive,
                onTap: onToggleActive,
                scheme: scheme,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 6),
              _SortMenu(
                current: filter.sortBy,
                ascending: filter.sortAscending,
                onChanged: onSortChanged,
                scheme: scheme,
              ),
              const Spacer(),
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
      icon: Icons.groups_outlined,
      label: 'الكل',
      isSelected: isSelected,
      onTap: onTap,
      scheme: scheme,
      color: scheme.primary,
      count: null,
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.role,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final UserRole role;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _roleColor(role);

    return _BaseChip(
      icon: _roleIcon(role),
      label: role.labelAr,
      isSelected: isSelected,
      onTap: onTap,
      scheme: scheme,
      color: color,
      count: count > 0 ? count : null,
    );
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const Color(0xFFF59E0B);
      case UserRole.manager:
        return const Color(0xFF8B5CF6);
      case UserRole.technician:
        return const Color(0xFF3B82F6);
      case UserRole.receptionist:
        return const Color(0xFF10B981);
      case UserRole.accountant:
        return const Color(0xFF06B6D4);
    }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Icons.workspace_premium;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.technician:
        return Icons.build;
      case UserRole.receptionist:
        return Icons.support_agent;
      case UserRole.accountant:
        return Icons.calculate;
    }
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
              if (count != null && count! > 0) ...[
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

  final StaffSortBy current;
  final bool ascending;
  final ValueChanged<StaffSortBy> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StaffSortBy>(
      tooltip: 'ترتيب',
      onSelected: onChanged,
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        _sortItem(StaffSortBy.name, 'الاسم', Icons.sort_by_alpha),
        _sortItem(StaffSortBy.role, 'الدور', Icons.badge_outlined),
        _sortItem(
          StaffSortBy.hireDate,
          'تاريخ التعيين',
          Icons.calendar_today_outlined,
        ),
        _sortItem(StaffSortBy.salary, 'الراتب', Icons.attach_money),
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

  PopupMenuItem<StaffSortBy> _sortItem(
    StaffSortBy type,
    String label,
    IconData icon,
  ) {
    final isCurrent = type == current;
    return PopupMenuItem<StaffSortBy>(
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

  String _label(StaffSortBy s) {
    switch (s) {
      case StaffSortBy.name:
        return 'الاسم';
      case StaffSortBy.role:
        return 'الدور';
      case StaffSortBy.hireDate:
        return 'التعيين';
      case StaffSortBy.salary:
        return 'الراتب';
      case StaffSortBy.createdAt:
        return 'الأحدث';
    }
  }
}
