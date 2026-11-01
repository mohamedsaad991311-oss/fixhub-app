// lib/features/expenses/presentation/widgets/expense_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/expense.dart';

/// ═══════════════════════════════════════════════════════════
/// ExpenseCard — كارت عرض مصروف في القائمة
/// ═══════════════════════════════════════════════════════════
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? scheme.surfaceContainerHigh
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceSmMd),
          child: Row(
            children: [
              // ─── Category Icon ───
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: expense.category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  expense.category.icon,
                  color: expense.category.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),

              // ─── Details ───
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.displayDescription(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          expense.category.labelAr,
                          style: TextStyle(
                            fontSize: 11,
                            color: expense.category.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _formatDate(expense.expenseDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (expense.vendor != null &&
                        expense.vendor!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        expense.vendor!,
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),

              // ─── Amount ───
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(expense.amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: scheme.error,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}