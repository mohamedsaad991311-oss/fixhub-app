// lib/features/reports/presentation/widgets/expenses_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../expenses/data/models/expense.dart';
import '../providers/reports_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// ExpensesPieChart — توزيع المصروفات حسب الفئة
/// ═══════════════════════════════════════════════════════════════
class ExpensesPieChart extends ConsumerWidget {
  const ExpensesPieChart({super.key, required this.stats});

  final ReportsStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final chartHeight =
        isNarrow ? AppSizes.chartHeightMd : AppSizes.chartHeightLg;

    // ═══ تجميع البيانات ═══
    final entries = <_CategoryEntry>[];
    double total = 0.0;

    // ترتيب الفئات تنازلياً بالمبلغ
    final sorted = stats.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final e in sorted) {
      final amount = e.value.toDouble();
      if (amount > 0) {
        entries.add(_CategoryEntry(category: e.key, amount: amount));
        total += amount;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant,
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ──── Header ────
          Row(
            children: [
              Icon(
                Icons.donut_large,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                l10n.reportsExpensesDistribution,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                CurrencyFormatter.formatCompact(total),
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // ──── Empty State ────
          if (entries.isEmpty)
            SizedBox(
              height: chartHeight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.donut_large,
                      size: AppSizes.iconXl,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSizes.spaceSm),
                    Text(
                      l10n.reportsNoExpensesInPeriod,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            isNarrow
                ? Column(
                    children: [
                      SizedBox(
                        height: chartHeight,
                        child: _buildChart(entries, total),
                      ),
                      const SizedBox(height: AppSizes.spaceMd),
                      _buildLegend(context, entries, total, scheme,
                          isNarrow: true),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: chartHeight,
                          child: _buildChart(entries, total),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceMd),
                      Expanded(
                        flex: 2,
                        child: _buildLegend(context, entries, total, scheme),
                      ),
                    ],
                  ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  CHART
  // ═══════════════════════════════════════════════════════════════

  Widget _buildChart(List<_CategoryEntry> entries, double total) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        startDegreeOffset: -90,
        sections: entries.map((e) {
          final double percent =
              total > 0 ? ((e.amount / total) * 100).toDouble() : 0.0;
          return PieChartSectionData(
            value: e.amount,
            color: e.color,
            radius: 60,
            title: percent >= 8 ? '${percent.toStringAsFixed(0)}%' : '',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 2, color: Colors.black38),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LEGEND
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLegend(
    BuildContext context,
    List<_CategoryEntry> entries,
    double total,
    ColorScheme scheme, {
    bool isNarrow = false,
  }) {
    final l10n = context.l10n;
    final maxItems = isNarrow ? 6 : 10;
    final visible = entries.take(maxItems).toList();
    final hidden = entries.skip(maxItems).toList();

    final items = <Widget>[];

    for (final e in visible) {
      final double percent =
          total > 0 ? ((e.amount / total) * 100).toDouble() : 0.0;
      items.add(_buildLegendRow(
        color: e.color,
        label: e.label(l10n),
        value: CurrencyFormatter.formatCompact(e.amount),
        percent: percent,
        scheme: scheme,
      ));
    }

    // إذا في فئات مخفية → "أخرى"
    if (hidden.isNotEmpty) {
      double otherTotal = 0.0;
      for (final e in hidden) {
        otherTotal += e.amount;
      }
      final double percent =
          total > 0 ? ((otherTotal / total) * 100).toDouble() : 0.0;
      items.add(_buildLegendRow(
        color: scheme.outline,
        label: l10n.reportsOthers(hidden.length),
        value: CurrencyFormatter.formatCompact(otherTotal),
        percent: percent,
        scheme: scheme,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required String value,
    required double percent,
    required ColorScheme scheme,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSizes.spaceSm),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSizes.radiusXs),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSizes.spaceXs),
          Text(
            '(${percent.toStringAsFixed(0)}%)',
            style: TextStyle(
              fontSize: 10,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CATEGORY ENTRY — helper class
// ═══════════════════════════════════════════════════════════════

class _CategoryEntry {
  const _CategoryEntry({required this.category, required this.amount});

  final ExpenseCategory category;
  final double amount;

  Color get color {
    final index = ExpenseCategory.values.indexOf(category);
    final hue = ((index * 360.0) / ExpenseCategory.values.length) % 360.0;
    return HSLColor.fromAHSL(1.0, hue, 0.65, 0.55).toColor();
  }

  String label(AppLocalizations l10n) {
    switch (category) {
      case ExpenseCategory.rent:
        return l10n.expenseCategoryRent;
      case ExpenseCategory.salaries:
        return l10n.expenseCategorySalaries;
      case ExpenseCategory.utilities:
        return l10n.expenseCategoryUtilities;
      case ExpenseCategory.internet:
        return l10n.expenseCategoryInternet;
      case ExpenseCategory.phone:
        return l10n.expenseCategoryPhone;
      case ExpenseCategory.supplies:
        return l10n.expenseCategorySupplies;
      case ExpenseCategory.tools:
        return l10n.expenseCategoryTools;
      case ExpenseCategory.maintenance:
        return l10n.expenseCategoryMaintenance;
      case ExpenseCategory.marketing:
        return l10n.expenseCategoryMarketing;
      case ExpenseCategory.transportation:
        return l10n.expenseCategoryTransportation;
      case ExpenseCategory.taxes:
        return l10n.expenseCategoryTaxes;
      case ExpenseCategory.insurance:
        return l10n.expenseCategoryInsurance;
      case ExpenseCategory.training:
        return l10n.expenseCategoryTraining;
      case ExpenseCategory.subscriptions:
        return l10n.expenseCategorySubscriptions;
      case ExpenseCategory.charity:
        return l10n.expenseCategoryCharity;
      case ExpenseCategory.other:
        return l10n.expenseCategoryOther;
    }
  }
}
