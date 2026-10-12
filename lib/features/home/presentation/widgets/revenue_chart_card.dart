// lib/features/home/presentation/widgets/revenue_chart_card.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';

/// ═══════════════════════════════════════════════════════════
/// RevenueChartCard — رسم بياني لإيرادات آخر 7 أيام
/// ═══════════════════════════════════════════════════════════
///
/// - Bar chart (fl_chart)
/// - 7 أيام (اليوم + 6 أيام اللي فاتوا)
/// - يعرض: total + average
///
class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({
    super.key,
    required this.dailyRevenue, // [6 days ago ... today] = 7 entries
    this.title = 'إيرادات آخر 7 أيام',
  });

  /// قائمة بـ 7 قيم (الأقدم → الأحدث)
  final List<double> dailyRevenue;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = dailyRevenue.fold<double>(0, (sum, v) => sum + v);
    final average = dailyRevenue.isEmpty ? 0.0 : total / dailyRevenue.length;

    final maxVal = dailyRevenue.isEmpty
        ? 0.0
        : dailyRevenue.reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal * 1.25).ceilToDouble();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ───
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  Icons.bar_chart_outlined,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceSmMd),

          // ─── Summary row ───
          Row(
            children: [
              _MiniStat(
                label: 'الإجمالي',
                value: CurrencyFormatter.format(total),
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceLg),
              _MiniStat(
                label: 'المتوسط',
                value: CurrencyFormatter.format(average),
                color: scheme.secondary,
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceSmMd),

          // ─── Chart ───
          SizedBox(
            height: 180,
            child: maxVal == 0
                ? _emptyState(scheme)
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY < 1 ? 1 : maxY,
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => scheme.inverseSurface,
                          getTooltipItem: (
                            group,
                            groupIndex,
                            rod,
                            rodIndex,
                          ) {
                            return BarTooltipItem(
                              CurrencyFormatter.format(rod.toY),
                              TextStyle(
                                color: scheme.onInverseSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= dailyRevenue.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _dayLabel(index),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval:
                            maxY < 4 ? 1 : (maxY / 4).ceilToDouble(),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        dailyRevenue.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: dailyRevenue[i],
                              color: i == dailyRevenue.length - 1
                                  ? scheme.primary
                                  : scheme.primary.withValues(alpha: 0.5),
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 42,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد إيرادات مسجّلة',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// اسم اليوم من المؤشر (0 = أقدم، 6 = اليوم)
  String _dayLabel(int index) {
    final now = DateTime.now();
    final daysAgo = (dailyRevenue.length - 1) - index;
    final date = now.subtract(Duration(days: daysAgo));

    if (daysAgo == 0) return 'اليوم';
    if (daysAgo == 1) return 'أمس';

    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[date.weekday - 1];
  }
}

// ═══════════════════════════════════════════════════════════════
//  MINI STAT
// ═══════════════════════════════════════════════════════════════

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
