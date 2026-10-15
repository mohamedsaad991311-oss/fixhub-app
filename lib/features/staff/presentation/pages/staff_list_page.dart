// lib/features/staff/presentation/pages/staff_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/staff_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/staff_member.dart';
import '../providers/staff_list_provider.dart';
import '../widgets/staff_card.dart';
import '../widgets/staff_filters_bar.dart';

/// ═══════════════════════════════════════════════════════════
/// StaffListPage — صفحة قائمة الموظفين
/// ═══════════════════════════════════════════════════════════
class StaffListPage extends ConsumerStatefulWidget {
  const StaffListPage({super.key});

  @override
  ConsumerState<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends ConsumerState<StaffListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(staffListProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'الموظفين',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(staffListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Stats Bar ───
          _StatsBar(stats: state.stats),

          // ─── Filters ───
          StaffFiltersBar(
            filter: state.filter,
            searchController: _searchController,
            roleCounts: state.stats.byRole,
            onSearchChanged: (q) {
              ref.read(staffListProvider.notifier).search(q);
              setState(() {});
            },
            onRoleChanged: (role) {
              ref.read(staffListProvider.notifier).filterByRole(role);
            },
            onToggleActive: () {
              ref.read(staffListProvider.notifier).toggleOnlyActive();
            },
            onSortChanged: (sort) {
              ref.read(staffListProvider.notifier).setFilter(
                    state.filter.copyWith(sortBy: sort),
                  );
            },
            onClearFilters: () {
              _searchController.clear();
              ref.read(staffListProvider.notifier).clearFilters();
              setState(() {});
            },
          ),

          // ─── Content ───
          Expanded(child: _buildContent(state)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.staffEdit),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('موظف جديد'),
      ),
    );
  }

  Widget _buildContent(StaffListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(staffListProvider.notifier).load(),
      );
    }

    if (state.isEmpty) {
      return _EmptyState(
        hasFilters: !state.filter.onlyActive ||
            state.filter.role != null ||
            (state.filter.search != null && state.filter.search!.isNotEmpty),
        onClearFilters: () {
          _searchController.clear();
          ref.read(staffListProvider.notifier).clearFilters();
          setState(() {});
        },
        onAddNew: () => context.push(RouteNames.staffEdit),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(staffListProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.staff.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSmMd),
        itemBuilder: (context, index) {
          final member = state.staff[index];
          return StaffCard(
            member: member,
            onTap: () => context.push(
              RouteNames.staffDetailOf(member.id),
            ),
            onLongPress: () => _showContextMenu(member),
          );
        },
      ),
    );
  }

  Future<void> _showContextMenu(StaffMember member) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('عرض التفاصيل'),
              onTap: () => Navigator.pop(ctx, 'view'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('تعديل'),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            if (!member.isOwner)
              ListTile(
                leading: Icon(
                  member.isActive
                      ? Icons.block_outlined
                      : Icons.check_circle_outline,
                ),
                title: Text(
                  member.isActive ? 'تعطيل' : 'تفعيل',
                ),
                onTap: () => Navigator.pop(ctx, 'toggle'),
              ),
            if (!member.isOwner)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('حذف'),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'view') {
      context.push(RouteNames.staffDetailOf(member.id));
    } else if (action == 'edit') {
      context.push(RouteNames.staffEdit, extra: member);
    } else if (action == 'toggle') {
      await ref.read(staffListProvider.notifier).setActive(
            member.id,
            isActive: !member.isActive,
          );
    } else if (action == 'delete') {
      await _confirmDelete(member);
    }
  }

  Future<void> _confirmDelete(StaffMember member) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الموظف؟'),
        content: Text(
          'هل أنت متأكد من حذف "${member.displayName()}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await ref.read(staffListProvider.notifier).delete(member.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم الحذف' : 'فشل الحذف'),
        backgroundColor: ok ? null : scheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  STATS BAR
// ═══════════════════════════════════════════════════════════

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.stats});

  final StaffStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.groups_outlined,
              label: 'موظفين',
              value: '${stats.totalStaff}',
              color: scheme.primary,
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.check_circle_outline,
              label: 'نشطين',
              value: '${stats.activeStaff}',
              color: const Color(0xFF10B981),
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.attach_money,
              label: 'رواتب',
              value: CurrencyFormatter.formatCompact(stats.totalSalaries),
              color: const Color(0xFFF59E0B),
              scheme: scheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
    required this.onAddNew,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off : Icons.people_outline,
              size: 72,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              hasFilters ? 'مفيش نتائج للفلتر الحالي' : 'مفيش موظفين لسه',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              hasFilters ? 'جرب تغير الفلتر أو امسحه' : 'ابدأ بإضافة أول موظف',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceLg),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('مسح الفلاتر'),
              )
            else
              FilledButton.icon(
                onPressed: onAddNew,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('موظف جديد'),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ERROR STATE
// ═══════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: scheme.onSurface),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('حاول تاني'),
            ),
          ],
        ),
      ),
    );
  }
}
