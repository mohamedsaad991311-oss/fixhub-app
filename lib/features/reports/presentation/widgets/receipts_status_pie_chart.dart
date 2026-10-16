// lib/features/reports/presentation/widgets/receipts_status_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../receipts/data/models/receipt.dart';
import '../providers/reports_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// ReceiptsStatusPieChart — توزيع الإيصالات حسب الحالة
/// ═══════════════════════════════════════════════════════════════
///
/// - Pie Chart (Donut) بـ fl_chart
/// - 6 حالات بألوان مختلفة
/// - Legend أسفل الرسم مع النسب
/// - Responsive
///
class ReceiptsStatusPieChart extends StatelessWidget {
  const ReceiptsStatusPieChart({super.key, required this.stats});

  final ReportsStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final chartHeight =
        isNarrow ? AppSizes.chartHeightMd : AppSizes.chartHeightLg;

    // ═══ تجميع البيانات ═══
    final entries = <_StatusEntry>[];
    var total = 0;

    for (final status in ReceiptStatus.values) {
      final count = stats.byStatus[status] ?? 0;
      if (count > 0) {
        entries.add(_StatusEntry(status: status, count: count));
        total += count;
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
                Icons.pie_chart_outline,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'توزيع الإيصالات',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'الإجمالي: $total',
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
          if (entries.isEmpty)
            SizedBox(
              height: chartHeight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
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
            // ──── Chart + Legend ────
            isNarrow
                ? Column(
                    children: [
                      SizedBox(
                        height: chartHeight,
                        child: _buildChart(context, entries, total, scheme),
                      ),
                      const SizedBox(height: AppSizes.spaceMd),
                      _buildLegend(entries, total, scheme),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: chartHeight,
                          child: _buildChart(context, entries, total, scheme),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceMd),
                      Expanded(
                        flex: 2,
                        child: _buildLegend(entries, total, scheme),
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

  Widget _buildChart(
    BuildContext context,
    List<_StatusEntry> entries,
    int total,
    ColorScheme scheme,
  ) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        startDegreeOffset: -90,
        sections: entries.map((e) {
          final percent = (e.count / total) * 100;
          return PieChartSectionData(
            value: e.count.toDouble(),
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
    List<_StatusEntry> entries,
    int total,
    ColorScheme scheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: entries.map((e) {
        final percent = total > 0 ? (e.count / total) * 100 : 0;
        return Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: AppSizes.spaceSm,
          ),
          child: Row(
            children: [
              // ──── Color dot ────
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: e.color,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),
              // ──── Label ────
              Expanded(
                child: Text(
                  e.labelAr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // ──── Count + % ────
              Text(
                '${e.count}',
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
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STATUS ENTRY — helper class
// ═══════════════════════════════════════════════════════════════

class _StatusEntry {
  const _StatusEntry({required this.status, required this.count});

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
}
