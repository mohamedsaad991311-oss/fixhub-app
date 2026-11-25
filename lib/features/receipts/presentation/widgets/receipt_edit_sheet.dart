// lib/features/receipts/presentation/widgets/receipt_edit_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'receipt_edit_sheet.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/receipt_service.dart';
import '../../data/models/receipt.dart';
import '../providers/receipt_detail_provider.dart';
import '../providers/receipts_list_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceiptEditSheet — شاشة تعديل الإيصال (Bottom Sheet)
/// ═══════════════════════════════════════════════════════════
class ReceiptEditSheet extends ConsumerStatefulWidget {
  const ReceiptEditSheet({super.key, required this.receipt});

  final Receipt receipt;

  @override
  ConsumerState<ReceiptEditSheet> createState() => _ReceiptEditSheetState();
}

class _ReceiptEditSheetState extends ConsumerState<ReceiptEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameCtrl;
  late TextEditingController _customerPhoneCtrl;
  late TextEditingController _customerEmailCtrl;
  late TextEditingController _deviceBrandCtrl;
  late TextEditingController _deviceModelCtrl;
  late TextEditingController _deviceColorCtrl;
  late TextEditingController _estimatedCostCtrl;
  late TextEditingController _finalCostCtrl;
  late TextEditingController _depositCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _warrantyDaysCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _internalNotesCtrl;

  bool _isSaving = false;
  DateTime? _expectedDeliveryDate;

  bool get _isFinalStatus =>
      widget.receipt.status == ReceiptStatus.delivered ||
      widget.receipt.status == ReceiptStatus.rejected;

  @override
  void initState() {
    super.initState();
    final r = widget.receipt;
    _customerNameCtrl = TextEditingController(text: r.customerName);
    _customerPhoneCtrl = TextEditingController(text: r.customerPhone ?? '');
    _customerEmailCtrl = TextEditingController(text: r.customerEmail ?? '');
    _deviceBrandCtrl = TextEditingController(text: r.deviceBrand ?? '');
    _deviceModelCtrl = TextEditingController(text: r.deviceModel ?? '');
    _deviceColorCtrl = TextEditingController(text: r.deviceColor ?? '');
    _estimatedCostCtrl =
        TextEditingController(text: r.estimatedCost.toStringAsFixed(2));
    _finalCostCtrl = TextEditingController(
      text: r.finalCost > 0 ? r.finalCost.toStringAsFixed(2) : '',
    );
    _depositCtrl = TextEditingController(
      text: r.deposit > 0 ? r.deposit.toStringAsFixed(2) : '',
    );
    _discountCtrl = TextEditingController(
      text: r.discount > 0 ? r.discount.toStringAsFixed(2) : '',
    );
    _warrantyDaysCtrl = TextEditingController(text: r.warrantyDays.toString());
    _notesCtrl = TextEditingController(text: r.notes ?? '');
    _internalNotesCtrl = TextEditingController(text: r.internalNotes ?? '');
    _expectedDeliveryDate = r.expectedDeliveryDate;
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _customerEmailCtrl.dispose();
    _deviceBrandCtrl.dispose();
    _deviceModelCtrl.dispose();
    _deviceColorCtrl.dispose();
    _estimatedCostCtrl.dispose();
    _finalCostCtrl.dispose();
    _depositCtrl.dispose();
    _discountCtrl.dispose();
    _warrantyDaysCtrl.dispose();
    _notesCtrl.dispose();
    _internalNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // بناء الحقول اللي اتغيرت فقط
      final updates = <String, dynamic>{};
      final r = widget.receipt;

      if (_customerNameCtrl.text.trim() != r.customerName) {
        updates['customer_name'] = _customerNameCtrl.text.trim();
      }
      if (_customerPhoneCtrl.text.trim() != (r.customerPhone ?? '')) {
        updates['customer_phone'] = _customerPhoneCtrl.text.trim();
      }
      if (_customerEmailCtrl.text.trim() != (r.customerEmail ?? '')) {
        updates['customer_email'] = _customerEmailCtrl.text.trim();
      }
      if (_deviceBrandCtrl.text.trim() != (r.deviceBrand ?? '')) {
        updates['device_brand'] = _deviceBrandCtrl.text.trim();
      }
      if (_deviceModelCtrl.text.trim() != (r.deviceModel ?? '')) {
        updates['device_model'] = _deviceModelCtrl.text.trim();
      }
      if (_deviceColorCtrl.text.trim() != (r.deviceColor ?? '')) {
        updates['device_color'] = _deviceColorCtrl.text.trim();
      }
      if (_estimatedCostCtrl.text.trim() !=
          r.estimatedCost.toStringAsFixed(2)) {
        updates['estimated_cost'] =
            double.tryParse(_estimatedCostCtrl.text.trim()) ?? r.estimatedCost;
      }
      if (_finalCostCtrl.text.trim() !=
          (r.finalCost > 0 ? r.finalCost.toStringAsFixed(2) : '')) {
        updates['final_cost'] =
            double.tryParse(_finalCostCtrl.text.trim()) ?? 0;
      }
      if (_depositCtrl.text.trim() !=
          (r.deposit > 0 ? r.deposit.toStringAsFixed(2) : '')) {
        updates['deposit'] = double.tryParse(_depositCtrl.text.trim()) ?? 0;
      }
      if (_discountCtrl.text.trim() !=
          (r.discount > 0 ? r.discount.toStringAsFixed(2) : '')) {
        updates['discount'] = double.tryParse(_discountCtrl.text.trim()) ?? 0;
      }
      if (_warrantyDaysCtrl.text.trim() != r.warrantyDays.toString()) {
        updates['warranty_days'] =
            int.tryParse(_warrantyDaysCtrl.text.trim()) ?? 0;
      }
      if (_notesCtrl.text.trim() != (r.notes ?? '')) {
        updates['notes'] = _notesCtrl.text.trim();
      }
      if (_internalNotesCtrl.text.trim() != (r.internalNotes ?? '')) {
        updates['internal_notes'] = _internalNotesCtrl.text.trim();
      }
      if (_expectedDeliveryDate != r.expectedDeliveryDate) {
        updates['expected_delivery_date'] =
            _expectedDeliveryDate?.toIso8601String();
      }

      if (updates.isEmpty) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم تعديل أي حقل'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // استدعاء الـ RPC
      final service = ref.read(receiptServiceProvider);
      final result = await service.updateReceiptFields(
        receiptId: widget.receipt.id,
        updates: updates,
      );

      if (!mounted) return;

      if (result != null) {
        // ريفريش القايمة + تفاصيل الإيصال
        ref.read(receiptsListProvider.notifier).refresh();
        ref.read(receiptDetailProvider(widget.receipt.id).notifier).refresh();

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التعديلات بنجاح'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل حفظ التعديلات'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceMd),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: scheme.tertiary, size: 22),
                  const SizedBox(width: AppSizes.spaceSm),
                  Text(
                    'تعديل الإيصال',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.spaceMd),
                  children: [
                    if (_isFinalStatus)
                      Container(
                        padding: const EdgeInsets.all(AppSizes.spaceSmMd),
                        margin:
                            const EdgeInsets.only(bottom: AppSizes.spaceMd),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer.withValues(alpha: 0.3),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber,
                                color: scheme.error, size: 20),
                            const SizedBox(width: AppSizes.spaceSm),
                            Expanded(
                              child: Text(
                                'الإيصال مغلق — يُسمح بتعديل الملاحظات الداخلية فقط',
                                style: TextStyle(
                                  color: scheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // قسم بيانات العميل
                    _SectionHeader(title: 'بيانات العميل'),
                    _AppTextField(
                      controller: _customerNameCtrl,
                      label: 'اسم العميل',
                      icon: Icons.person_outline,
                      enabled: !_isFinalStatus,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'اسم العميل مطلوب'
                          : null,
                    ),
                    _AppTextField(
                      controller: _customerPhoneCtrl,
                      label: 'رقم التليفون',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: !_isFinalStatus,
                    ),
                    _AppTextField(
                      controller: _customerEmailCtrl,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isFinalStatus,
                    ),

                    // قسم بيانات الجهاز
                    _SectionHeader(title: 'بيانات الجهاز'),
                    _AppTextField(
                      controller: _deviceBrandCtrl,
                      label: 'الماركة',
                      icon: Icons.phone_android,
                      enabled: !_isFinalStatus,
                    ),
                    _AppTextField(
                      controller: _deviceModelCtrl,
                      label: 'الموديل',
                      icon: Icons.smartphone_outlined,
                      enabled: !_isFinalStatus,
                    ),
                    _AppTextField(
                      controller: _deviceColorCtrl,
                      label: 'اللون',
                      icon: Icons.palette_outlined,
                      enabled: !_isFinalStatus,
                    ),

                    // قسم التكاليف
                    _SectionHeader(title: 'التكاليف'),
                    _AppTextField(
                      controller: _estimatedCostCtrl,
                      label: 'التكلفة المقدرة',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      enabled: !_isFinalStatus,
                    ),
                    _AppTextField(
                      controller: _finalCostCtrl,
                      label: 'التكلفة النهائية',
                      icon: Icons.price_check_outlined,
                      keyboardType: TextInputType.number,
                      enabled: !_isFinalStatus,
                    ),
                    _AppTextField(
                      controller: _depositCtrl,
                      label: 'العربون المدفوع',
                      icon: Icons.savings_outlined,
                      keyboardType: TextInputType.number,
                      enabled: !_isFinalStatus,
                    ),
                    _AppTextField(
                      controller: _discountCtrl,
                      label: 'الخصم',
                      icon: Icons.discount_outlined,
                      keyboardType: TextInputType.number,
                      enabled: !_isFinalStatus,
                    ),
                    _AppTextField(
                      controller: _warrantyDaysCtrl,
                      label: 'أيام الضمان',
                      icon: Icons.verified_outlined,
                      keyboardType: TextInputType.number,
                      enabled: !_isFinalStatus,
                    ),

                    // قسم المواعيد
                    _SectionHeader(title: 'المواعيد'),
                    InkWell(
                      onTap: _isFinalStatus
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _expectedDeliveryDate ??
                                    DateTime.now()
                                        .add(const Duration(days: 3)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => _expectedDeliveryDate = picked);
                              }
                            },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'تاريخ التسليم المتوقع',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          enabled: !_isFinalStatus,
                        ),
                        child: Text(
                          _expectedDeliveryDate == null
                              ? 'غير محدد'
                              : '${_expectedDeliveryDate!.year}-'
                                  '${_expectedDeliveryDate!.month.toString().padLeft(2, '0')}-'
                                  '${_expectedDeliveryDate!.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),

                    // قسم الملاحظات
                    _SectionHeader(title: 'الملاحظات'),
                    _AppTextField(
                      controller: _notesCtrl,
                      label: 'ملاحظات عامة',
                      icon: Icons.notes_outlined,
                      maxLines: 3,
                      enabled: !_isFinalStatus,
                    ),
                    _AppTextField(
                      controller: _internalNotesCtrl,
                      label: 'ملاحظات داخلية',
                      icon: Icons.lock_outline,
                      maxLines: 3,
                      enabled: true, // دايماً متاح
                    ),

                    const SizedBox(height: AppSizes.spaceLg),
                  ],
                ),
              ),
            ),

            // Footer buttons
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSizes.spaceMd,
                AppSizes.spaceSmMd,
                AppSizes.spaceMd,
                MediaQuery.of(context).padding.bottom + AppSizes.spaceSmMd,
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Helper Widgets
// ═══════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.spaceMd,
        bottom: AppSizes.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: scheme.tertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceSmMd),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
        ),
      ),
    );
  }
}