// lib/features/reports/presentation/widgets/top_receipts_list.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../receipts/data/models/receipt.dart';
import '../providers/reports_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// TopReceiptsList — أعلى 5 إيصالات بالإيراد
/// ═══════════════════════════════════════════════════════════════
///
/// - قائمة الإيصالات الأعلى (من stats.topReceipts)
/// - كل عنصر: اسم العميل، الرقم، الجهاز، المبلغ
/// - الضغط → صفحة التفاصيل
///
class TopReceiptsList extends StatelessWidget {
  const TopReceiptsList({super.key, required this.stats});

  final ReportsStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final receipts = stats.topReceipts;

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
                Icons.emoji_events_outlined,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'أعلى الإيصالات',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${receipts.length} عناصر',
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
          if (receipts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spaceXl,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
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
            // ──── List ────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: receipts.length,
              separatorBuilder: (_, __) => Divider(
                height: AppSizes.spaceMdLg,
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return _ReceiptTile(
                  receipt: receipt,
                  rank: index + 1,
                  onTap: () {
                    context.push(
                      RouteNames.receiptDetailOf(receipt.id),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RECEIPT TILE
// ═══════════════════════════════════════════════════════════════

class _ReceiptTile extends StatelessWidget {
  const _ReceiptTile({
    required this.receipt,
    required this.rank,
    required this.onTap,
  });

  final Receipt receipt;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spaceXs,
        ),
        child: Row(
          children: [
            // ──── Rank Badge ────
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _rankColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(
                  color: _rankColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _rankColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spaceSmMd),

            // ──── Info ────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم العميل
                  Text(
                    receipt.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // الجهاز
                  Text(
                    '${receipt.deviceBrand} ${receipt.deviceModel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // رقم الإيصال
                  Text(
                    receipt.receiptNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSizes.spaceSm),

            // ──── Amount ────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatCompact(receipt.total),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981), // Emerald
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  Icons.chevron_left,
                  size: AppSizes.iconSm,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFF59E0B); // Gold
      case 2:
        return const Color(0xFF94A3B8); // Silver
      case 3:
        return const Color(0xFFB45309); // Bronze
      default:
        return const Color(0xFF64748B); // Slate
    }
  }
}
