// lib/features/suppliers/presentation/pages/supplier_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/supplier.dart';
import '../providers/supplier_detail_provider.dart';
import '../widgets/supplier_invoice_card.dart';
import '../widgets/supplier_payment_card.dart';
import '../widgets/supplier_stats_bar.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierDetailPage — صفحة تفاصيل مورد
/// ═══════════════════════════════════════════════════════════
class SupplierDetailPage extends ConsumerStatefulWidget {
  const SupplierDetailPage({super.key, required this.supplierId});

  final String supplierId;

  @override
  ConsumerState<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends ConsumerState<SupplierDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(supplierDetailProvider(widget.supplierId));

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          state.supplier?.name ?? 'تفاصيل المورد',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (state.supplier != null)
            IconButton(
              tooltip: 'تعديل',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                RouteNames.supplierEdit,
                extra: state.supplier,
              ),
            ),
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(supplierDetailProvider(widget.supplierId).notifier)
                .refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.receipt_long_outlined, size: 20),
              text: 'الفواتير (${state.invoices.length})',
            ),
            Tab(
              icon: const Icon(Icons.payments_outlined, size: 20),
              text: 'المدفوعات (${state.payments.length})',
            ),
            Tab(
              icon: const Icon(Icons.assignment_return_outlined, size: 20),
              text: 'المرتجعات (${state.returns.length})',
            ),
          ],
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, SupplierDetailState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasSupplier) {
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
                state.errorMessage ?? 'خطأ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: scheme.onSurface),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              FilledButton.icon(
                onPressed: () => ref
                    .read(supplierDetailProvider(widget.supplierId).notifier)
                    .load(),
                icon: const Icon(Icons.refresh),
                label: const Text('حاول تاني'),
              ),
            ],
          ),
        ),
      );
    }

    final supplier = state.supplier;
    if (supplier == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return Column(
      children: [
        // ─── Contact card ───
        _ContactCard(supplier: supplier, scheme: Theme.of(context).colorScheme),

        // ─── Stats Bar ───
        SupplierStatsBar(state: state),

        // ─── Tabs Content ───
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // ═══ Tab 1: الفواتير ═══
              _InvoicesTab(supplierId: widget.supplierId),

              // ═══ Tab 2: المدفوعات ═══
              _PaymentsTab(supplierId: widget.supplierId),

              // ═══ Tab 3: المرتجعات ═══
              _ReturnsTab(supplierId: widget.supplierId),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CONTACT CARD
// ═══════════════════════════════════════════════════════════

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.supplier, required this.scheme});

  final Supplier supplier;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          if (supplier.contactPerson != null &&
              supplier.contactPerson!.isNotEmpty)
            _InfoChip(
              icon: Icons.person_outline,
              value: supplier.contactPerson!,
              scheme: scheme,
            ),
          if (supplier.phone != null && supplier.phone!.isNotEmpty)
            _InfoChip(
              icon: Icons.phone_outlined,
              value: supplier.phone!,
              scheme: scheme,
              ltr: true,
            ),
          if (supplier.email != null && supplier.email!.isNotEmpty)
            _InfoChip(
              icon: Icons.email_outlined,
              value: supplier.email!,
              scheme: scheme,
              ltr: true,
            ),
          if (supplier.address != null && supplier.address!.isNotEmpty)
            _InfoChip(
              icon: Icons.location_on_outlined,
              value: supplier.address!,
              scheme: scheme,
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.value,
    required this.scheme,
    this.ltr = false,
  });

  final IconData icon;
  final String value;
  final ColorScheme scheme;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            value,
            textDirection: ltr ? TextDirection.ltr : null,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  INVOICES TAB
// ═══════════════════════════════════════════════════════════

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab({required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supplierDetailProvider(supplierId));
    final scheme = Theme.of(context).colorScheme;

    if (state.invoices.isEmpty) {
      return _EmptyTab(
        icon: Icons.receipt_long_outlined,
        title: 'مفيش فواتير',
        subtitle: 'ابدأ بإضافة فاتورة جديدة',
        actionLabel: 'فاتورة جديدة',
        onAction: () => context.push(
          '${RouteNames.supplierDetailOf(supplierId)}/invoices',
          extra: {'create': true},
        ),
        scheme: scheme,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(supplierDetailProvider(supplierId).notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.invoices.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSm),
        itemBuilder: (context, index) {
          final invoice = state.invoices[index];
          return SupplierInvoiceCard(
            invoice: invoice,
            onTap: () => context.push(
              '${RouteNames.supplierDetailOf(supplierId)}/invoices',
              extra: invoice,
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PAYMENTS TAB
// ═══════════════════════════════════════════════════════════

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supplierDetailProvider(supplierId));
    final scheme = Theme.of(context).colorScheme;

    if (state.payments.isEmpty) {
      return _EmptyTab(
        icon: Icons.payments_outlined,
        title: 'مفيش مدفوعات',
        subtitle: 'ابدأ بتسجيل دفعة',
        actionLabel: 'تسجيل دفعة',
        onAction: () => context.push(
          '${RouteNames.supplierDetailOf(supplierId)}/payments',
        ),
        scheme: scheme,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(supplierDetailProvider(supplierId).notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSm),
        itemBuilder: (context, index) {
          final payment = state.payments[index];
          return SupplierPaymentCard(payment: payment);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  RETURNS TAB
// ═══════════════════════════════════════════════════════════

class _ReturnsTab extends ConsumerWidget {
  const _ReturnsTab({required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supplierDetailProvider(supplierId));
    final scheme = Theme.of(context).colorScheme;

    if (state.returns.isEmpty) {
      return _EmptyTab(
        icon: Icons.assignment_return_outlined,
        title: 'مفيش مرتجعات',
        subtitle: 'ابدأ بإنشاء مرتجع',
        actionLabel: 'مرتجع جديد',
        onAction: () => context.push(
          '${RouteNames.supplierDetailOf(supplierId)}/returns',
        ),
        scheme: scheme,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(supplierDetailProvider(supplierId).notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.returns.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSm),
        itemBuilder: (context, index) {
          final ret = state.returns[index];
          return _ReturnTile(ret: ret);
        },
      ),
    );
  }
}

class _ReturnTile extends StatelessWidget {
  const _ReturnTile({required this.ret});

  final SupplierReturn ret;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _returnColor(ret.status);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              Icons.assignment_return_outlined,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ret.returnNumber ?? 'مرتجع',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ret.status.labelAr,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(ret.total),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _returnColor(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.pending:
        return const Color(0xFFF59E0B);
      case ReturnStatus.approved:
        return const Color(0xFF3B82F6);
      case ReturnStatus.completed:
        return const Color(0xFF10B981);
      case ReturnStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  EMPTY TAB
// ═══════════════════════════════════════════════════════════

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.scheme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
