// lib/features/reports/presentation/widgets/receipts_bar_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../receipts/data/models/receipt.dart';
import '../providers/reports_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// ReceiptsBarChart — توزيع الإيصالات حسب الحالة (Bar Chart)
/// ═══════════════════════════════════════════════════════════════
///
/// - Bar Chart بـ fl_chart
/// - 6 أعمدة (حالة لكل عمود)
/// - Responsive
///
class ReceiptsBarChart extends StatelessWidget {
  const ReceiptsBarChart({super.key, required this.stats});

  final ReportsStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final chartHeight =
        isNarrow ? AppSizes.chartHeightMd : AppSizes.chartHeightLg;

    // ═══ تجميع البيانات (6 حالات) ═══
    final entries = <_StatusBarEntry>[];
    var maxY = 0;

    for (final status in ReceiptStatus.values) {
      final count = stats.byStatus[status] ?? 0;
      entries.add(_StatusBarEntry(status: status, count: count));
      if (count > maxY) maxY = count;
    }

    // هامش 20% فوق
    maxY = (maxY * 1.2).ceil();
    if (maxY <= 0) maxY = 5;

    final isEmpty = entries.every((e) => e.count == 0);

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
                Icons.bar_chart,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'الإيصالات حسب الحالة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'الإجمالي: ${stats.totalReceipts}',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // ──── Empty State ────
          if (isEmpty)
            SizedBox(
              height: chartHeight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: AppSizes.iconXl,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSizes.spaceSm),
                    Text(
                      'لا توجد إيصالات في هذه الفترة',
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
            SizedBox(
              height: chartHeight,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY.toDouble(),
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: scheme.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
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
                        reservedSize: 32,
                        interval: (maxY / 4).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: AppSizes.spaceXs,
                            ),
                            child: Text(
                              entries[i].labelShortAr,
                              style: TextStyle(
                                fontSize: 9,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => isDark
                          ? scheme.surfaceContainerHighest
                          : scheme.surface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final e = entries[group.x];
                        return BarTooltipItem(
                          '${e.labelAr}\n${e.count}',
                          TextStyle(
                            color: e.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  barGroups: entries.asMap().entries.map((mapEntry) {
                    final index = mapEntry.key;
                    final e = mapEntry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: e.count.toDouble(),
                          color: e.color,
                          width: isNarrow ? 18 : 28,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STATUS BAR ENTRY — helper class
// ═══════════════════════════════════════════════════════════════

class _StatusBarEntry {
  const _StatusBarEntry({required this.status, required this.count});

  final ReceiptStatus status;
  final int count;

  Color get color {
    switch (status) {
      case ReceiptStatus.received:
        return const Color(0xFF3B82F6); // Blue
      case ReceiptStatus.inProgress:
        return const Color(0xFFF59E0B); // Amber
      case ReceiptStatus.waitingParts:
        return const Color(0xFF8B5CF6); // Violet
      case ReceiptStatus.ready:
        return const Color(0xFF10B981); // Emerald
      case ReceiptStatus.delivered:
        return const Color(0xFF059669); // Dark Emerald
      case ReceiptStatus.rejected:
        return const Color(0xFFEF4444); // Red
    }
  }

  String get labelAr {
    switch (status) {
      case ReceiptStatus.received:
        return 'تم الاستلام';
      case ReceiptStatus.inProgress:
        return 'قيد الإصلاح';
      case ReceiptStatus.waitingParts:
        return 'بانتظار قطع';
      case ReceiptStatus.ready:
        return 'جاهز للتسليم';
      case ReceiptStatus.delivered:
        return 'تم التسليم';
      case ReceiptStatus.rejected:
        return 'مرفوض';
    }
  }

  /// نسخة مختصرة للـ X axis
  String get labelShortAr {
    switch (status) {
      case ReceiptStatus.received:
        return 'استلام';
      case ReceiptStatus.inProgress:
        return 'إصلاح';
      case ReceiptStatus.waitingParts:
        return 'انتظار';
      case ReceiptStatus.ready:
        return 'جاهز';
      case ReceiptStatus.delivered:
        return 'تسليم';
      case ReceiptStatus.rejected:
        return 'مرفوض';
    }
  }
}
