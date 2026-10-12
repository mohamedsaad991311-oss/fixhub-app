// lib/features/home/presentation/widgets/stats_grid.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/dashboard_stats.dart';

/// ═══════════════════════════════════════════════════════════
/// StatsGrid — شبكة الإحصائيات الرئيسية
/// ═══════════════════════════════════════════════════════════
///
/// بتعرض 4 كروت:
/// - إيصالات اليوم
/// - قيد الإصلاح
/// - جاهز للتسليم
/// - مبيعات اليوم
///
class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.stats,
    this.onTapActive,
    this.onTapReady,
  });

  final DashboardStats stats;

  /// عند الضغط على "قيد الإصلاح"
  final VoidCallback? onTapActive;

  /// عند الضغط على "جاهز للتسليم"
  final VoidCallback? onTapReady;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // عدد الأعمدة حسب العرض
        int columns;
        if (constraints.maxWidth < 600) {
          columns = 2; // موبايل
        } else if (constraints.maxWidth < 1024) {
          columns = 4; // تابلت
        } else {
          columns = 4; // ديسكتوب
        }

        final aspectRatio = constraints.maxWidth < 600 ? 1.4 : 1.6;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: AppSizes.spaceSmMd,
          mainAxisSpacing: AppSizes.spaceSmMd,
          childAspectRatio: aspectRatio,
          children: [
            _StatCard(
              label: 'إيصالات اليوم',
              value: '${stats.todayReceivedReceipts}',
              icon: Icons.receipt_long_outlined,
              color: _cardColors(context)[0],
              onTap: null,
            ),
            _StatCard(
              label: 'قيد الإصلاح',
              value: '${stats.activeReceipts}',
              icon: Icons.build_outlined,
              color: _cardColors(context)[1],
              onTap: onTapActive,
            ),
            _StatCard(
              label: 'جاهز للتسليم',
              value: '${stats.readyReceipts}',
              icon: Icons.check_circle_outline,
              color: _cardColors(context)[2],
              onTap: onTapReady,
              highlight: stats.readyReceipts > 0,
            ),
            _StatCard(
              label: 'مبيعات اليوم',
              value: CurrencyFormatter.format(stats.todayRevenue),
              icon: Icons.payments_outlined,
              color: _cardColors(context)[3],
              onTap: null,
            ),
          ],
        );
      },
    );
  }

  /// ألوان الكروت حسب الثيم
  List<Color> _cardColors(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      scheme.primary,
      scheme.tertiary,
      const Color(0xFF10B981), // أخضر
      const Color(0xFFF59E0B), // برتقالي
    ];
  }
}

// ═══════════════════════════════════════════════════════════════
//  STAT CARD
// ═══════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spaceSmMd),
          decoration: BoxDecoration(
            color: isDark
                ? scheme.surfaceContainerHigh
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: highlight
                  ? color.withValues(alpha: 0.5)
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: highlight ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ─── Icon ───
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, size: 20, color: color),
              ),

              // ─── Value + Label ───
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
