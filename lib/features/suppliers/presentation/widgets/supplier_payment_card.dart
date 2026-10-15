// lib/features/suppliers/presentation/widgets/supplier_payment_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierPaymentCard — كارت دفعة لمورد
/// ═══════════════════════════════════════════════════════════
class SupplierPaymentCard extends StatelessWidget {
  const SupplierPaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.onDelete,
  });

  final SupplierPayment payment;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final methodColor = _methodColor(payment.paymentMethod);

    return Material(
      color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            child: Row(
              children: [
                // ─── Icon ───
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: methodColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    _methodIcon(payment.paymentMethod),
                    color: methodColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSm),

                // ─── Info ───
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              CurrencyFormatter.format(payment.amount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: methodColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                            child: Text(
                              _methodLabel(payment.paymentMethod),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: methodColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _fmtDateTime(payment.paymentDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (payment.invoiceId != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'فاتورة',
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (payment.notes != null &&
                          payment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          payment.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───

  Color _methodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return const Color(0xFF10B981);
      case PaymentMethod.bankTransfer:
        return const Color(0xFF3B82F6);
      case PaymentMethod.creditCard:
        return const Color(0xFF8B5CF6);
      case PaymentMethod.mobileWallet:
        return const Color(0xFF06B6D4);
      case PaymentMethod.check:
        return const Color(0xFFF59E0B);
      case PaymentMethod.other:
        return const Color(0xFF6B7280);
    }
  }

  IconData _methodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.creditCard:
        return Icons.credit_card_outlined;
      case PaymentMethod.mobileWallet:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethod.check:
        return Icons.receipt_outlined;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  String _methodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.bankTransfer:
        return 'تحويل';
      case PaymentMethod.creditCard:
        return 'بطاقة';
      case PaymentMethod.mobileWallet:
        return 'محفظة';
      case PaymentMethod.check:
        return 'شيك';
      case PaymentMethod.other:
        return 'أخرى';
    }
  }

  String _fmtDateTime(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
