// lib/features/delivery/presentation/pages/delivery_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../receipts/data/models/receipt.dart';
import '../../../receipts/presentation/providers/receipts_list_provider.dart';
import '../providers/delivery_provider.dart';

class DeliveryDetailPage extends ConsumerWidget {
  final String receiptId;

  const DeliveryDetailPage({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final listState = ref.watch(receiptsListProvider);

    // ✅ التعامل مع ReceiptsListState (مش AsyncValue)
    if (listState.isLoading && listState.receipts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل التسليم'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (listState.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل التسليم'), centerTitle: true),
        body: Center(child: Text(listState.errorMessage ?? 'حدث خطأ')),
      );
    }

    final receipt = listState.receipts.firstWhere(
      (r) => r.id == receiptId,
      orElse: () => Receipt.empty,
    );

    if (receipt.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل التسليم'), centerTitle: true),
        body: const Center(child: Text('الإيصال غير موجود')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل التسليم'),
        centerTitle: true,
      ),
      body: _buildContent(context, ref, receipt, scheme),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Receipt receipt,
    ColorScheme scheme,
  ) {
    final total = receipt.finalCost > 0
        ? receipt.finalCost
        : (receipt.total > 0 ? receipt.total : receipt.estimatedCost);
    final remaining = (total - receipt.deposit).clamp(0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ───
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.customerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إيصال رقم: ${receipt.receiptNumber}',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ─── Device Info ───
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'بيانات الجهاز',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  _infoRow('الجهاز', receipt.deviceFullName, scheme),
                  _infoRow('IMEI', receipt.deviceImei ?? 'غير مسجل', scheme),
                  _infoRow('الحالة', receipt.status.labelAr, scheme),
                  _infoRow(
                    'ملاحظات',
                    receipt.conditionNotes ?? 'لا توجد',
                    scheme,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ─── Financial Summary ───
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص مالي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  _infoRow(
                    'التكلفة النهائية',
                    CurrencyFormatter.format(total),
                    scheme,
                  ),
                  _infoRow(
                    'العربون المدفوع',
                    CurrencyFormatter.format(receipt.deposit),
                    scheme,
                  ),
                  const Divider(),
                  _infoRow(
                    'المتبقي المطلوب',
                    CurrencyFormatter.format(remaining),
                    scheme,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.spaceXl),

          // ─── Confirm Button ───
          FilledButton.icon(
            onPressed: () => _handleDeliver(context, ref, receipt),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('تأكيد التسليم للعميل'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    ColorScheme scheme, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? scheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeliver(
    BuildContext context,
    WidgetRef ref,
    Receipt receipt,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد التسليم'),
        content: const Text(
            'هل تأكدت من استلام العميل للجهاز ودفع المبلغ المتبقي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(deliveryProvider.notifier)
        .deliverReceipt(receipt.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسليم الإيصال بنجاح ✅'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      context.pop(); // رجوع لقائمة التسليم
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('فشل التسليم'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}