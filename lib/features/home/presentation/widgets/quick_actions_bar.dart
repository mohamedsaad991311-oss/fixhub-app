// lib/features/home/presentation/widgets/quick_actions_bar.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════
/// QuickActionsBar — شريط الإجراءات السريعة
/// ═══════════════════════════════════════════════════════════
///
/// 4 أزرار رئيسية:
/// - إيصال جديد
/// - إضافة صنف
/// - إضافة مصروف
/// - فاتورة مورد
///
class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({
    super.key,
    this.onNewReceipt,
    this.onAddInventory,
    this.onAddExpense,
    this.onSupplierInvoice,
  });

  final VoidCallback? onNewReceipt;
  final VoidCallback? onAddInventory;
  final VoidCallback? onAddExpense;
  final VoidCallback? onSupplierInvoice;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        final actions = <_ActionData>[
          _ActionData(
            label: 'إيصال جديد',
            icon: Icons.add_circle_outline,
            color: Theme.of(context).colorScheme.primary,
            onTap: onNewReceipt,
            isPrimary: true,
          ),
          _ActionData(
            label: 'إضافة صنف',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF3B82F6), // أزرق
            onTap: onAddInventory,
          ),
          _ActionData(
            label: 'إضافة مصروف',
            icon: Icons.trending_down_outlined,
            color: const Color(0xFFEF4444), // أحمر
            onTap: onAddExpense,
          ),
          _ActionData(
            label: 'فاتورة مورد',
            icon: Icons.receipt_outlined,
            color: const Color(0xFF8B5CF6), // بنفسجي
            onTap: onSupplierInvoice,
          ),
        ];

        if (isNarrow) {
          // موبايل: 2 صف × 2 عمود
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _ActionTile(data: actions[0])),
                  const SizedBox(width: AppSizes.spaceSmMd),
                  Expanded(child: _ActionTile(data: actions[1])),
                ],
              ),
              const SizedBox(height: AppSizes.spaceSmMd),
              Row(
                children: [
                  Expanded(child: _ActionTile(data: actions[2])),
                  const SizedBox(width: AppSizes.spaceSmMd),
                  Expanded(child: _ActionTile(data: actions[3])),
                ],
              ),
            ],
          );
        }

        // تابلت + ديسكتوب: صف واحد × 4
        return Row(
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(child: _ActionTile(data: actions[i])),
            ],
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DATA
// ═══════════════════════════════════════════════════════════════

class _ActionData {
  const _ActionData({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isPrimary;
}

// ═══════════════════════════════════════════════════════════════
//  ACTION TILE
// ═══════════════════════════════════════════════════════════════

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.data});

  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = data.onTap == null;

    // لو primary → خلفية ملونة كاملة
    final bgColor = data.isPrimary
        ? data.color
        : (isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow);

    final fgColor = data.isPrimary ? scheme.onPrimary : data.color;

    final labelColor = data.isPrimary ? scheme.onPrimary : scheme.onSurface;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: data.onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceSmMd,
              vertical: AppSizes.spaceSmMd,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: data.isPrimary
                  ? null
                  : Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: data.isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : fgColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    data.icon,
                    size: 20,
                    color: data.isPrimary ? scheme.onPrimary : fgColor,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
