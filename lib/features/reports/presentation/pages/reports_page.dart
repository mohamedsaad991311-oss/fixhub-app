// lib/features/reports/presentation/pages/reports_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/reports_provider.dart';
import '../widgets/expenses_pie_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/receipts_bar_chart.dart';
import '../widgets/receipts_status_pie_chart.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/summary_cards.dart';
import '../widgets/top_receipts_list.dart';

/// ═══════════════════════════════════════════════════════════════
/// ReportsPage — صفحة التقارير الرئيسية
/// ═══════════════════════════════════════════════════════════════
///
/// تحتوي على:
/// - Period Selector
/// - Summary Cards (4)
/// - Revenue Chart (Line)
/// - Receipts Status Pie Chart
/// - Expenses Pie Chart
/// - Receipts Bar Chart
/// - Top Receipts List
///
class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(reportsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportsProvider.notifier).refresh(),
        child: _buildBody(context, state, scheme),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BODY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBody(
    BuildContext context,
    ReportsState state,
    ColorScheme scheme,
  ) {
    // ──── Error ────
    if (state.hasError) {
      return _buildError(context, state);
    }

    // ──── Loading (first time) ────
    if (state.isLoading && state.stats.totalReceipts == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    // ──── Content ────
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
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
                // ──── Period Selector ────
                const PeriodSelector(),

                const SizedBox(height: AppSizes.spaceLg),

                // ──── Summary Cards ────
                SummaryCards(stats: state.stats),

                const SizedBox(height: AppSizes.spaceLg),

                // ──── Revenue Chart (full width) ────
                RevenueChart(stats: state.stats),

                const SizedBox(height: AppSizes.spaceLg),

                // ──── Charts Grid (2 columns on tablet) ────
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ReceiptsStatusPieChart(stats: state.stats),
                      ),
                      const SizedBox(width: AppSizes.spaceMd),
                      Expanded(
                        child: ReceiptsBarChart(stats: state.stats),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      ReceiptsStatusPieChart(stats: state.stats),
                      const SizedBox(height: AppSizes.spaceLg),
                      ReceiptsBarChart(stats: state.stats),
                    ],
                  ),

                const SizedBox(height: AppSizes.spaceLg),

                // ──── Expenses Pie Chart (full width) ────
                ExpensesPieChart(stats: state.stats),

                const SizedBox(height: AppSizes.spaceLg),

                // ──── Top Receipts List (full width) ────
                TopReceiptsList(stats: state.stats),

                const SizedBox(height: AppSizes.spaceXl),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  ERROR STATE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildError(BuildContext context, ReportsState state) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXxl,
              color: scheme.error,
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              state.errorMessage ?? 'حدث خطأ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLg),
            FilledButton.icon(
              onPressed: () {
                // ignore: unused_result
                // ref.read(reportsProvider.notifier).load();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
