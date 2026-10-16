// lib/features/reports/presentation/widgets/revenue_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/reports_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// RevenueChart — رسم بياني خطي للإيرادات والمصروفات عبر الزمن
/// ═══════════════════════════════════════════════════════════════
///
/// - Line Chart بـ fl_chart
/// - خطّين: الإيرادات (أخضر) + المصروفات (أحمر)
/// - Responsive: 200 ارتفاع على الموبايل، 300 على التابلت
///
class RevenueChart extends ConsumerWidget {
  const RevenueChart({super.key, required this.stats});

  final ReportsStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final chartHeight =
        isNarrow ? AppSizes.chartHeightMd : AppSizes.chartHeightLg;

    // ═══ دمج المفاتيح (تواريخ) من السلسلتين ═══
    final allDates = <DateTime>{
      ...stats.revenueSeries.keys,
      ...stats.expenseSeries.keys,
    }.toList()
      ..sort();

    // ═══ حالة فارغة ═══
    if (allDates.isEmpty) {
      return _buildEmptyState(context, chartHeight);
    }

    // ═══ حساب أقصى قيمة للـ Y axis ═══
    double maxY = 0;
    for (final d in allDates) {
      final r = stats.revenueSeries[d] ?? 0;
      final e = stats.expenseSeries[d] ?? 0;
      if (r > maxY) maxY = r;
      if (e > maxY) maxY = e;
    }
    // إضافة 20% هامش فوق
    maxY = maxY * 1.2;
    if (maxY <= 0) maxY = 100;

    // ═══ نقاط الإيرادات ═══
    final revenueSpots = <FlSpot>[];
    for (var i = 0; i < allDates.length; i++) {
      revenueSpots.add(
        FlSpot(i.toDouble(), stats.revenueSeries[allDates[i]] ?? 0),
      );
    }

    // ═══ نقاط المصروفات ═══
    final expenseSpots = <FlSpot>[];
    for (var i = 0; i < allDates.length; i++) {
      expenseSpots.add(
        FlSpot(i.toDouble(), stats.expenseSeries[allDates[i]] ?? 0),
      );
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
                Icons.show_chart,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'الإيرادات والمصروفات',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              // ──── Legend ────
              _LegendDot(color: const Color(0xFF10B981), label: 'إيرادات'),
              const SizedBox(width: AppSizes.spaceSmMd),
              _LegendDot(color: const Color(0xFFEF4444), label: 'مصروفات'),
            ],
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // ──── Chart ────
          SizedBox(
            height: chartHeight,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (allDates.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: AppSizes.spaceXs,
                          ),
                          child: Text(
                            CurrencyFormatter.formatCompact(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= allDates.length) {
                          return const SizedBox.shrink();
                        }
                        // نعرض تاريخ مختصر كل N نقطة (حسب العدد)
                        final step = allDates.length > 10
                            ? (allDates.length / 5).ceil()
                            : 1;
                        if (i % step != 0) return const SizedBox.shrink();
                        final d = allDates[i];
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSizes.spaceXs),
                          child: Text(
                            '${d.day}/${d.month}',
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
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: scheme.outlineVariant,
                      width: AppSizes.borderNormal,
                    ),
                    left: BorderSide(
                      color: scheme.outlineVariant,
                      width: AppSizes.borderNormal,
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark
                        ? scheme.surfaceContainerHighest
                        : scheme.surface,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final i = spot.x.toInt();
                        if (i < 0 || i >= allDates.length) return null;
                        final d = allDates[i];
                        final isRevenue = spot.barIndex == 0;
                        return LineTooltipItem(
                          '${d.day}/${d.month}/${d.year}\n'
                          '${isRevenue ? "إيرادات" : "مصروفات"}: '
                          '${CurrencyFormatter.format(spot.y)}',
                          TextStyle(
                            color: isRevenue
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // ──── Revenue Line ────
                  LineChartBarData(
                    spots: revenueSpots,
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: AppSizes.chartLineWidth,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: allDates.length <= 15,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: const Color(0xFF10B981),
                          strokeWidth: 1.5,
                          strokeColor: scheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    ),
                  ),
                  // ──── Expense Line ────
                  LineChartBarData(
                    spots: expenseSpots,
                    isCurved: true,
                    color: const Color(0xFFEF4444),
                    barWidth: AppSizes.chartLineWidth,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: allDates.length <= 15,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: const Color(0xFFEF4444),
                          strokeWidth: 1.5,
                          strokeColor: scheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context, double height) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant,
          width: AppSizes.borderNormal,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart,
              size: AppSizes.iconXl,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              'لا توجد بيانات في هذه الفترة',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  LEGEND DOT
// ═══════════════════════════════════════════════════════════════

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.radiusXs),
          ),
        ),
        const SizedBox(width: AppSizes.spaceXs),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
