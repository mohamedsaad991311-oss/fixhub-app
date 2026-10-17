// lib/features/reports/presentation/widgets/summary_cards.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/reports_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// SummaryCards — كروت ملخص الأداء المالي
/// ═══════════════════════════════════════════════════════════
///
/// بتعرض 4 كروت:
/// - الإيرادات
/// - المصروفات
/// - صافي الربح
/// - هامش الربح
///
class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.stats});

  final ReportsStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final columns = isNarrow ? 2 : 4;
        // زيادة الارتفاع عشان المحتوى يبقى مناسب (كان 1.6 و 1.8)
        final aspectRatio = isNarrow ? 1.4 : 1.6;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: AppSizes.spaceSmMd,
          mainAxisSpacing: AppSizes.spaceSmMd,
          childAspectRatio: aspectRatio,
          children: [
            _SummaryCard(
              label: 'الإيرادات',
              value: CurrencyFormatter.formatCompact(stats.totalRevenue),
              icon: Icons.trending_up,
              color: const Color(0xFF10B981),
              subtitle: '${stats.deliveredReceipts} إيصال مسلَّم',
            ),
            _SummaryCard(
              label: 'المصروفات',
              value: CurrencyFormatter.formatCompact(stats.totalExpenses),
              icon: Icons.trending_down,
              color: const Color(0xFFEF4444),
              subtitle: 'خلال الفترة',
            ),
            _SummaryCard(
              label: 'صافي الربح',
              value: CurrencyFormatter.formatCompact(stats.netProfit),
              icon: stats.netProfit >= 0
                  ? Icons.account_balance_wallet
                  : Icons.money_off,
              color: stats.netProfit >= 0
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFEF4444),
              subtitle: stats.netProfit >= 0 ? 'ربح' : 'خسارة',
            ),
            _SummaryCard(
              label: 'هامش الربح',
              value: '${stats.profitMargin.toStringAsFixed(1)}%',
              icon: Icons.percent,
              color: const Color(0xFFF59E0B),
              subtitle: 'من الإيرادات',
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SUMMARY CARD
// ═══════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),

          // Value + Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                  height: 1.2,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
