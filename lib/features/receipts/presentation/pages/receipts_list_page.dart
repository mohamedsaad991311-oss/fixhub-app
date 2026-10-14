// lib/features/receipts/presentation/pages/receipts_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../data/models/receipt.dart';
import '../providers/receipts_list_provider.dart';
import '../widgets/receipt_card.dart';
import '../widgets/receipt_filters_bar.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceiptsListPage — صفحة قائمة الإيصالات
/// ═══════════════════════════════════════════════════════════
class ReceiptsListPage extends ConsumerStatefulWidget {
  const ReceiptsListPage({super.key});

  @override
  ConsumerState<ReceiptsListPage> createState() => _ReceiptsListPageState();
}

class _ReceiptsListPageState extends ConsumerState<ReceiptsListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final listState = ref.watch(receiptsListProvider);
    final stats = ref.watch(receiptsStatsProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'الإيصالات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(receiptsListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Filters Bar ───
          ReceiptFiltersBar(
            filter: listState.filter,
            searchController: _searchController,
            statusCounts: stats,
            onSearchChanged: (q) {
              ref.read(receiptsListProvider.notifier).search(q);
              setState(() {}); // لتحديث زر Clear
            },
            onStatusChanged: (status) {
              ref.read(receiptsListProvider.notifier).filterByStatus(status);
            },
            onToggleActive: () {
              ref.read(receiptsListProvider.notifier).toggleOnlyActive();
            },
            onToggleDelayed: () {
              ref.read(receiptsListProvider.notifier).toggleOnlyDelayed();
            },
            onClearFilters: () {
              _searchController.clear();
              ref.read(receiptsListProvider.notifier).clearFilters();
              setState(() {});
            },
          ),

          // ─── Content ───
          Expanded(
            child: _buildContent(listState),
          ),
        ],
      ),

      // ─── FAB: إيصال جديد ───
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.receivingWizard),
        icon: const Icon(Icons.add),
        label: const Text('إيصال جديد'),
      ),
    );
  }

  Widget _buildContent(ReceiptsListState state) {
    // ─── Loading ───
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ─── Error ───
    if (state.hasError) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(receiptsListProvider.notifier).load(),
      );
    }

    // ─── Empty ───
    if (state.isEmpty) {
      return _EmptyState(
        hasFilters: state.filter.status != null ||
            state.filter.onlyActive ||
            state.filter.onlyDelayed ||
            (state.filter.customerSearch != null &&
                state.filter.customerSearch!.isNotEmpty),
        onClearFilters: () {
          _searchController.clear();
          ref.read(receiptsListProvider.notifier).clearFilters();
          setState(() {});
        },
        onNewReceipt: () => context.push(RouteNames.receivingWizard),
      );
    }

    // ─── List ───
    return RefreshIndicator(
      onRefresh: () => ref.read(receiptsListProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.receipts.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSmMd),
        itemBuilder: (context, index) {
          final receipt = state.receipts[index];
          return ReceiptCard(
            receipt: receipt,
            onTap: () => context.push(
              RouteNames.receiptDetailOf(receipt.id),
            ),
            onLongPress: () => _showContextMenu(receipt),
          );
        },
      ),
    );
  }

  // ─── Context Menu (Long Press) ───

  Future<void> _showContextMenu(Receipt receipt) async {
    final action = await showModalBottomSheet<String>(
      context: context,
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
              leading: const Icon(Icons.delete_outline),
              title: const Text('حذف'),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (action == 'view') {
      context.push(RouteNames.receiptDetailOf(receipt.id));
    } else if (action == 'delete') {
      await _confirmDelete(receipt);
    }
  }

  Future<void> _confirmDelete(Receipt receipt) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الإيصال؟'),
        content: Text(
          'هل أنت متأكد من حذف الإيصال ${receipt.receiptNumber}؟ '
          'لا يمكن التراجع عن هذا الإجراء.',
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

    if (confirmed != true) return;

    final ok = await ref.read(receiptsListProvider.notifier).delete(receipt.id);

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
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
    required this.onNewReceipt,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onNewReceipt;

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
              hasFilters ? Icons.filter_list_off : Icons.receipt_long_outlined,
              size: 72,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              hasFilters ? 'مفيش نتائج للفلتر الحالي' : 'مفيش إيصالات لسه',
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
                  : 'ابدأ باستلام أول جهاز من زرار "إيصال جديد"',
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
                onPressed: onNewReceipt,
                icon: const Icon(Icons.add),
                label: const Text('إيصال جديد'),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: scheme.error,
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface,
              ),
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
