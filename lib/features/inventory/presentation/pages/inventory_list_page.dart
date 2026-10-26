// lib/features/inventory/presentation/pages/inventory_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/inventory_item.dart';
import '../providers/inventory_list_provider.dart';
import '../widgets/inventory_card.dart';
import '../widgets/inventory_filters_bar.dart';

/// ═══════════════════════════════════════════════════════════
/// InventoryListPage — صفحة قائمة المخزون
/// ═══════════════════════════════════════════════════════════
class InventoryListPage extends ConsumerStatefulWidget {
  const InventoryListPage({super.key});

  @override
  ConsumerState<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends ConsumerState<InventoryListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(inventoryListProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'المخزون',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(inventoryListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Stats Bar ───
          _StatsBar(stats: state.stats),

          // ─── Filters ───
          InventoryFiltersBar(
            filter: state.filter,
            searchController: _searchController,
            stats: state.stats,
            onSearchChanged: (q) {
              ref.read(inventoryListProvider.notifier).search(q);
              setState(() {});
            },
            onCategoryChanged: (c) {
              ref.read(inventoryListProvider.notifier).filterByCategory(c);
            },
            onToggleLowStock: () {
              ref.read(inventoryListProvider.notifier).toggleLowStock();
            },
            onToggleOutOfStock: () {
              ref.read(inventoryListProvider.notifier).toggleOutOfStock();
            },
            onClearFilters: () {
              _searchController.clear();
              ref.read(inventoryListProvider.notifier).clearFilters();
              setState(() {});
            },
          ),

          // ─── Content ───
          Expanded(child: _buildContent(state)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.inventoryEdit),
        icon: const Icon(Icons.add),
        label: const Text('صنف جديد'),
      ),
    );
  }

  Widget _buildContent(InventoryListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(inventoryListProvider.notifier).load(),
      );
    }

    if (state.isEmpty) {
      return _EmptyState(
        hasFilters: state.filter.category != null ||
            state.filter.onlyLowStock ||
            state.filter.onlyOutOfStock ||
            (state.filter.search != null && state.filter.search!.isNotEmpty),
        onClearFilters: () {
          _searchController.clear();
          ref.read(inventoryListProvider.notifier).clearFilters();
          setState(() {});
        },
        onAddNew: () => context.push(RouteNames.inventoryEdit),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(inventoryListProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 380,
          crossAxisSpacing: AppSizes.spaceSmMd,
          mainAxisSpacing: AppSizes.spaceSmMd,
          childAspectRatio: 1.4,
        ),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return InventoryCard(
            item: item,
            onTap: () => context.push(
              RouteNames.inventoryDetailOf(item.id),
            ),
            onLongPress: () => _showContextMenu(item),
          );
        },
      ),
    );
  }

  Future<void> _showContextMenu(InventoryItem item) async {
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
      context.push(RouteNames.inventoryDetailOf(item.id));
    } else if (action == 'edit') {
      context.push(RouteNames.inventoryDetailOf(item.id));
    } else if (action == 'delete') {
      await _confirmDelete(item);
    }
  }

  Future<void> _confirmDelete(InventoryItem item) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الصنف؟'),
        content: Text(
          'هل أنت متأكد من حذف "${item.displayName()}"؟',
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

    final ok = await ref.read(inventoryListProvider.notifier).delete(item.id);

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

  final dynamic stats;

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
              icon: Icons.inventory_2_outlined,
              label: 'أصناف',
              value: '${stats.totalItems}',
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
              icon: Icons.warehouse_outlined,
              label: 'الكمية',
              value: '${stats.totalQuantity}',
              color: const Color(0xFF3B82F6),
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
              label: 'قيمة',
              value: CurrencyFormatter.formatCompact(stats.totalStockValue),
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
//  EMPTY STATE (قابل للـ Scroll عشان نمنع Overflow)
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppSizes.spaceLg * 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFilters
                      ? Icons.filter_list_off
                      : Icons.inventory_2_outlined,
                  size: 72,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: AppSizes.spaceMd),
                Text(
                  hasFilters
                      ? 'مفيش نتائج للفلتر الحالي'
                      : 'مفيش أصناف في المخزون',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Text(
                  hasFilters
                      ? 'جرب تغير الفلتر أو امسحه'
                      : 'ابدأ بإضافة أول صنف',
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
                    label: const Text('صنف جديد'),
                  ),
              ],
            ),
          ),
        );
      },
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppSizes.spaceLg * 2,
            ),
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
      },
    );
  }
}
