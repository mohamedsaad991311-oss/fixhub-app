// lib/features/suppliers/presentation/widgets/supplier_invoice_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierInvoiceCard — كارت فاتورة مورد
/// ═══════════════════════════════════════════════════════════
class SupplierInvoiceCard extends StatelessWidget {
  const SupplierInvoiceCard({
    super.key,
    required this.invoice,
    this.onTap,
    this.onPay,
    this.onDelete,
  });

  final SupplierInvoice invoice;
  final VoidCallback? onTap;
  final VoidCallback? onPay;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = invoice.status.color;

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
              color: invoice.isOverdue
                  ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: invoice.isOverdue ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header: invoice number + status ───
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spaceSmMd,
                  AppSizes.spaceSm,
                  AppSizes.spaceSmMd,
                  AppSizes.spaceSm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            invoice.invoiceNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtDate(invoice.invoiceDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(
                      label: invoice.status.labelAr,
                      color: statusColor,
                    ),
                  ],
                ),
              ),

              // ─── Divider ───
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),

              // ─── Body: amounts ───
              Padding(
                padding: const EdgeInsets.all(AppSizes.spaceSmMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _AmountBox(
                            label: 'الإجمالي',
                            value: CurrencyFormatter.format(invoice.total),
                            color: scheme.onSurface,
                            scheme: scheme,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceSm),
                        Expanded(
                          child: _AmountBox(
                            label: 'المدفوع',
                            value: CurrencyFormatter.format(invoice.paid),
                            color: const Color(0xFF10B981),
                            scheme: scheme,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceSm),
                        Expanded(
                          child: _AmountBox(
                            label: 'المتبقي',
                            value: CurrencyFormatter.format(invoice.remaining),
                            color: invoice.remaining > 0
                                ? const Color(0xFFEF4444)
                                : scheme.onSurfaceVariant,
                            scheme: scheme,
                          ),
                        ),
                      ],
                    ),

                    // ─── Progress bar ───
                    if (invoice.total > 0) ...[
                      const SizedBox(height: AppSizes.spaceSm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        child: LinearProgressIndicator(
                          value: (invoice.paid / invoice.total).clamp(0, 1),
                          minHeight: 6,
                          backgroundColor: scheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            invoice.isFullyPaid
                                ? const Color(0xFF10B981)
                                : statusColor,
                          ),
                        ),
                      ),
                    ],

                    // ─── Due date ───
                    if (invoice.dueDate != null) ...[
                      const SizedBox(height: AppSizes.spaceSm),
                      Row(
                        children: [
                          Icon(
                            invoice.isOverdue
                                ? Icons.warning_amber_outlined
                                : Icons.calendar_today_outlined,
                            size: 14,
                            color: invoice.isOverdue
                                ? const Color(0xFFEF4444)
                                : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            invoice.isOverdue
                                ? 'متأخرة — ${_fmtDate(invoice.dueDate!)}'
                                : 'الاستحقاق: ${_fmtDate(invoice.dueDate!)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: invoice.isOverdue
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: invoice.isOverdue
                                  ? const Color(0xFFEF4444)
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ─── Footer: pay button ───
              if (!invoice.isFullyPaid &&
                  invoice.status != InvoiceStatus.cancelled &&
                  onPay != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPay,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spaceSmMd,
                          vertical: AppSizes.spaceSm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.payments_outlined,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'تسجيل دفعة',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════
//  STATUS BADGE
// ═══════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  AMOUNT BOX
// ═══════════════════════════════════════════════════════════

class _AmountBox extends StatelessWidget {
  const _AmountBox({
    required this.label,
    required this.value,
    required this.color,
    required this.scheme,
  });

  final String label;
  final String value;
  final Color color;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
