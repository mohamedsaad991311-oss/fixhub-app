// lib/features/suppliers/presentation/widgets/supplier_stats_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/supplier_detail_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierStatsBar — شريط إحصائيات المورد في صفحة التفاصيل
/// ═══════════════════════════════════════════════════════════
class SupplierStatsBar extends StatelessWidget {
  const SupplierStatsBar({super.key, required this.state});

  final SupplierDetailState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supplier = state.supplier;

    if (supplier == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Balance (الأهم) ───
          _BalanceBanner(
            balance: supplier.balance,
            scheme: scheme,
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ─── Stats row ───
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.receipt_long_outlined,
                  label: 'إجمالي الفواتير',
                  value: CurrencyFormatter.formatCompact(state.totalInvoices),
                  color: scheme.primary,
                  scheme: scheme,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.payments_outlined,
                  label: 'إجمالي المدفوع',
                  value: CurrencyFormatter.formatCompact(state.totalPayments),
                  color: const Color(0xFF10B981),
                  scheme: scheme,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.warning_amber_outlined,
                  label: 'فواتير متأخرة',
                  value: '${state.overdueInvoices.length}',
                  color: state.overdueInvoices.isEmpty
                      ? scheme.onSurfaceVariant
                      : const Color(0xFFEF4444),
                  scheme: scheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  BALANCE BANNER
// ═══════════════════════════════════════════════════════════

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.balance, required this.scheme});

  final double balance;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon, String label) = _resolve();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSmMd,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.format(balance.abs()),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData, String) _resolve() {
    if (balance > 0) {
      // مستحق للمورد (مدين)
      return (
        const Color(0xFFEF4444).withValues(alpha: 0.1),
        const Color(0xFFEF4444),
        Icons.arrow_upward,
        'مستحق للمورد',
      );
    }
    if (balance < 0) {
      // دفعة مقدمة (دائن)
      return (
        const Color(0xFF10B981).withValues(alpha: 0.1),
        const Color(0xFF10B981),
        Icons.arrow_downward,
        'دفعة مقدمة',
      );
    }
    return (
      const Color(0xFF6B7280).withValues(alpha: 0.1),
      const Color(0xFF6B7280),
      Icons.check_circle_outline,
      'لا يوجد رصيد',
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  MINI STAT
// ═══════════════════════════════════════════════════════════

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
