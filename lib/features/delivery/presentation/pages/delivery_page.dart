// lib/features/delivery/presentation/pages/delivery_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../receipts/data/models/receipt.dart';
import '../providers/delivery_provider.dart';
import '../widgets/delivery_receipt_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// DeliveryPage — صفحة تسليم الإيصالات الجاهزة
/// ═══════════════════════════════════════════════════════════════
///
/// - قائمة الإيصالات الجاهزة (status = ready)
/// - بحث سريع
/// - إحصائيات (عدد + متبقي + عربون)
/// - تسليم الإيصال (confirm + changeStatus)
///
class DeliveryPage extends ConsumerStatefulWidget {
  const DeliveryPage({super.key});

  @override
  ConsumerState<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends ConsumerState<DeliveryPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      ref.read(deliveryProvider.notifier).loadReadyReceipts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  DELIVER
  // ═══════════════════════════════════════════════════════════════

  Future<void> _handleDeliver(Receipt receipt) async {
    final total = receipt.finalCost > 0
        ? receipt.finalCost
        : (receipt.total > 0 ? receipt.total : receipt.estimatedCost);
    final remaining = (total - receipt.deposit).clamp(0, double.infinity);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.local_shipping_outlined,
          color: Color(0xFF10B981),
          size: 40,
        ),
        title: const Text('تأكيد التسليم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العميل: ${receipt.customerName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text('الإيصال: ${receipt.receiptNumber}'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceSm),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المتبقي:'),
                  Text(
                    CurrencyFormatter.format(remaining.toDouble()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'هل تأكد استلام العميل للجهاز ودفع المتبقي؟',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check),
            label: const Text('تأكيد التسليم'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final notifier = ref.read(deliveryProvider.notifier);
    final success = await notifier.deliverReceipt(receipt.id);
    if (!mounted) return;

    if (success) {
      _showSnack('تم تسليم الإيصال بنجاح ✅', isError: false);
    } else {
      _showSnack('فشل تسليم الإيصال', isError: true);
    }
    notifier.clearMessages();
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: isError ? scheme.error : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التسليم'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(deliveryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(deliveryProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final isMedium = constraints.maxWidth >= 600;
            final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ──── Stats Row ────
                    _buildStatsRow(context, state, scheme, isWide),

                    const SizedBox(height: AppSizes.spaceMd),

                    // ──── Search Bar ────
                    _buildSearchBar(context, state, scheme),

                    const SizedBox(height: AppSizes.spaceMd),

                    // ──── Content ────
                    if (state.isLoading && state.receipts.isEmpty)
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: AppSizes.spaceXl),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.filteredReceipts.isEmpty)
                      _buildEmptyState(context, scheme, state)
                    else
                      _buildGrid(
                        context,
                        state.filteredReceipts,
                        isWide: isWide,
                        isMedium: isMedium,
                      ),

                    const SizedBox(height: AppSizes.spaceXl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STATS ROW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatsRow(
    BuildContext context,
    DeliveryState state,
    ColorScheme scheme,
    bool isWide,
  ) {
    final items = [
      _StatItem(
        icon: Icons.inventory_2_outlined,
        label: 'إيصالات جاهزة',
        value: '${state.receipts.length}',
        color: scheme.primary,
      ),
      _StatItem(
        icon: Icons.payments_outlined,
        label: 'إجمالي المتبقي',
        value: CurrencyFormatter.formatCompact(state.totalPending),
        color: const Color(0xFFEF4444),
      ),
      _StatItem(
        icon: Icons.savings_outlined,
        label: 'إجمالي العربون',
        value: CurrencyFormatter.formatCompact(state.totalDeposits),
        color: const Color(0xFF3B82F6),
      ),
    ];

    if (isWide) {
      return Row(
        children: items
            .map((e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppSizes.spaceSm,
                    ),
                    child: _buildStatCard(e, scheme),
                  ),
                ))
            .toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AppSizes.spaceSm,
                  ),
                  child: SizedBox(
                    width: 160,
                    child: _buildStatCard(e, scheme),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStatCard(_StatItem item, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: item.color.withValues(alpha: 0.3),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: item.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
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
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SEARCH BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchBar(
    BuildContext context,
    DeliveryState state,
    ColorScheme scheme,
  ) {
    return TextField(
      controller: _searchController,
      onChanged: (v) => ref.read(deliveryProvider.notifier).setSearchQuery(v),
      decoration: InputDecoration(
        hintText: 'بحث بالاسم / التليفون / IMEI / رقم الإيصال',
        hintStyle: TextStyle(
          fontSize: 13,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: scheme.onSurfaceVariant,
        ),
        suffixIcon: state.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _searchController.clear();
                  ref.read(deliveryProvider.notifier).clearSearch();
                },
              )
            : null,
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            width: AppSizes.borderNormal,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            width: AppSizes.borderNormal,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.primary,
            width: AppSizes.borderMedium,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceSmMd,
          vertical: AppSizes.spaceSm,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  GRID
  // ═══════════════════════════════════════════════════════════════

  Widget _buildGrid(
    BuildContext context,
    List<Receipt> receipts, {
    required bool isWide,
    required bool isMedium,
  }) {
    final columns = isWide ? 3 : (isMedium ? 2 : 1);
    final spacing = AppSizes.spaceSmMd;

    if (columns == 1) {
      return Column(
        children: receipts
            .map((r) => Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: DeliveryReceiptCard(
                    receipt: r,
                    onTap: () => _openReceipt(r),
                    onDeliver: () => _handleDeliver(r),
                  ),
                ))
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: receipts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: 320,
      ),
      itemBuilder: (context, index) {
        final r = receipts[index];
        return DeliveryReceiptCard(
          receipt: r,
          onTap: () => _openReceipt(r),
          onDeliver: () => _handleDeliver(r),
        );
      },
    );
  }

  void _openReceipt(Receipt receipt) {
    context.push(RouteNames.receiptDetailOf(receipt.id));
  }

  // ═══════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme scheme,
    DeliveryState state,
  ) {
    final hasSearch = state.searchQuery.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spaceXl,
        horizontal: AppSizes.spaceMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.local_shipping_outlined,
            size: AppSizes.iconXl,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            hasSearch ? 'لا توجد نتائج للبحث' : 'لا توجد إيصالات جاهزة للتسليم',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasSearch
                ? 'جرّب كلمة بحث مختلفة'
                : 'ستظهر هنا الإيصالات التي حالتها "جاهز للتسليم"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STAT ITEM — helper
// ═══════════════════════════════════════════════════════════════

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}
