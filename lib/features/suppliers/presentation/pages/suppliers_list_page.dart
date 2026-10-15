// lib/features/suppliers/presentation/pages/suppliers_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/supplier.dart';
import '../providers/suppliers_list_provider.dart';
import '../../../../core/services/supplier_service.dart';
import '../widgets/supplier_card.dart';
import '../widgets/supplier_filters_bar.dart';

/// ═══════════════════════════════════════════════════════════
/// SuppliersListPage — صفحة قائمة الموردين
/// ═══════════════════════════════════════════════════════════
class SuppliersListPage extends ConsumerStatefulWidget {
  const SuppliersListPage({super.key});

  @override
  ConsumerState<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends ConsumerState<SuppliersListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(suppliersListProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'الموردين',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(suppliersListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Stats Bar ───
          _StatsBar(stats: state.stats),

          // ─── Filters ───
          SupplierFiltersBar(
            filter: state.filter,
            searchController: _searchController,
            stats: state.stats,
            onSearchChanged: (q) {
              ref.read(suppliersListProvider.notifier).search(q);
              setState(() {});
            },
            onToggleActive: () {
              ref.read(suppliersListProvider.notifier).toggleOnlyActive();
            },
            onToggleWithDebt: () {
              ref.read(suppliersListProvider.notifier).toggleOnlyWithDebt();
            },
            onSortChanged: (sort) {
              ref.read(suppliersListProvider.notifier).setFilter(
                    state.filter.copyWith(sortBy: sort),
                  );
            },
            onClearFilters: () {
              _searchController.clear();
              ref.read(suppliersListProvider.notifier).clearFilters();
              setState(() {});
            },
          ),

          // ─── Content ───
          Expanded(child: _buildContent(state)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.supplierEdit),
        icon: const Icon(Icons.add),
        label: const Text('مورد جديد'),
      ),
    );
  }

  Widget _buildContent(SuppliersListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(suppliersListProvider.notifier).load(),
      );
    }

    if (state.isEmpty) {
      return _EmptyState(
        hasFilters: !state.filter.onlyActive ||
            state.filter.onlyWithDebt ||
            (state.filter.search != null && state.filter.search!.isNotEmpty),
        onClearFilters: () {
          _searchController.clear();
          ref.read(suppliersListProvider.notifier).clearFilters();
          setState(() {});
        },
        onAddNew: () => context.push(RouteNames.supplierEdit),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(suppliersListProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.suppliers.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSmMd),
        itemBuilder: (context, index) {
          final supplier = state.suppliers[index];
          return SupplierCard(
            supplier: supplier,
            onTap: () => context.push(
              RouteNames.supplierDetailOf(supplier.id),
            ),
            onLongPress: () => _showContextMenu(supplier),
          );
        },
      ),
    );
  }

  Future<void> _showContextMenu(Supplier supplier) async {
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
            ListTile(
              leading: Icon(
                supplier.isActive
                    ? Icons.block_outlined
                    : Icons.check_circle_outline,
              ),
              title: Text(
                supplier.isActive ? 'تعطيل' : 'تفعيل',
              ),
              onTap: () => Navigator.pop(ctx, 'toggle'),
            ),
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
      context.push(RouteNames.supplierDetailOf(supplier.id));
    } else if (action == 'edit') {
      context.push(RouteNames.supplierEdit, extra: supplier);
    } else if (action == 'toggle') {
      await ref.read(suppliersListProvider.notifier).setActive(
            supplier.id,
            isActive: !supplier.isActive,
          );
    } else if (action == 'delete') {
      await _confirmDelete(supplier);
    }
  }

  Future<void> _confirmDelete(Supplier supplier) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المورد؟'),
        content: Text(
          'هل أنت متأكد من حذف "${supplier.name}"؟ '
          'سيتم حذف كل الفواتير والمدفوعات المرتبطة.',
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

    final ok =
        await ref.read(suppliersListProvider.notifier).delete(supplier.id);

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

  final SupplierStats stats;

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
              icon: Icons.store_outlined,
              label: 'موردين',
              value: '${stats.totalSuppliers}',
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
              icon: Icons.arrow_upward,
              label: 'مستحق',
              value: CurrencyFormatter.formatCompact(stats.totalDebt),
              color: const Color(0xFFEF4444),
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
              icon: Icons.arrow_downward,
              label: 'دفعات',
              value: CurrencyFormatter.formatCompact(stats.totalOwed),
              color: const Color(0xFF10B981),
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
              hasFilters ? Icons.filter_list_off : Icons.store_outlined,
              size: 72,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              hasFilters ? 'مفيش نتائج للفلتر الحالي' : 'مفيش موردين لسه',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              hasFilters ? 'جرب تغير الفلتر أو امسحه' : 'ابدأ بإضافة أول مورد',
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
                icon: const Icon(Icons.add),
                label: const Text('مورد جديد'),
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
