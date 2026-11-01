// lib/features/expenses/presentation/screens/expense_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/constants/app_sizes.dart';
import '../../data/models/expense.dart';
import '../providers/expense_form_provider.dart';
import '../providers/expenses_list_provider.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expenseId});

  final String? expenseId;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descController;
  late final TextEditingController _amountController;
  late final TextEditingController _vendorController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(expenseFormProvider);
    _descController = TextEditingController(text: form.description);
    _amountController = TextEditingController(
      text: form.amount > 0 ? form.amount.toStringAsFixed(2) : '',
    );
    _vendorController = TextEditingController(text: form.vendor ?? '');
    _notesController = TextEditingController(text: form.notes ?? '');

    if (widget.expenseId != null) {
      Future.microtask(() =>
          ref.read(expenseFormProvider.notifier).loadForEdit(widget.expenseId!));
    } else {
      Future.microtask(() => ref.read(expenseFormProvider.notifier).reset());
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final form = ref.watch(expenseFormProvider);
    final notifier = ref.read(expenseFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(form.isEditing ? 'تعديل المصروف' : 'مصروف جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Category ───
              _Label(text: 'الفئة', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              Wrap(
                spacing: AppSizes.spaceSm,
                runSpacing: AppSizes.spaceSm,
                children: ExpenseCategory.values.map((c) {
                  final selected = form.category == c;
                  return InkWell(
                    onTap: () => notifier.setCategory(c),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceSmMd,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? c.color.withValues(alpha: 0.15)
                            : scheme.surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusPill),
                        border: Border.all(
                          color: selected ? c.color : scheme.outlineVariant,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon, size: 14, color: c.color),
                          const SizedBox(width: 4),
                          Text(
                            c.labelAr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? c.color : scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.spaceMd),

              // ─── Description ───
              _Label(text: 'الوصف *', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              TextFormField(
                controller: _descController,
                onChanged: notifier.setDescription,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hint: 'مثال: فاتورة كهرباء شهر أكتوبر',
                  scheme: scheme,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل الوصف' : null,
              ),
              const SizedBox(height: AppSizes.spaceMd),

              // ─── Amount ───
              _Label(text: 'المبلغ *', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) =>
                    notifier.setAmount(double.tryParse(v) ?? 0),
                decoration: _inputDecoration(
                  hint: '0.00',
                  scheme: scheme,
                  suffix: 'ج.م',
                ),
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return 'أدخل مبلغ صحيح';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spaceMd),

              // ─── Payment Method ───
              _Label(text: 'طريقة الدفع', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              Wrap(
                spacing: AppSizes.spaceSm,
                runSpacing: AppSizes.spaceSm,
                children: ExpensePaymentMethod.values.map((m) {
                  final selected = form.paymentMethod == m;
                  return InkWell(
                    onTap: () => notifier.setPaymentMethod(m),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceSmMd,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? scheme.primary.withValues(alpha: 0.15)
                            : scheme.surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusPill),
                        border: Border.all(
                          color: selected
                              ? scheme.primary
                              : scheme.outlineVariant,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(m.icon,
                              size: 14,
                              color: selected
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            m.labelAr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? scheme.primary
                                  : scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.spaceMd),

              // ─── Date ───
              _Label(text: 'التاريخ', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: form.expenseDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) notifier.setExpenseDate(picked);
                },
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceMd,
                    vertical: AppSizes.spaceSmMd,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: AppSizes.spaceSm),
                      Text(
                        '${form.expenseDate.day}/${form.expenseDate.month}/${form.expenseDate.year}',
                        style: TextStyle(fontSize: 14, color: scheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),

              // ─── Vendor ───
              _Label(text: 'المورد (اختياري)', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              TextFormField(
                controller: _vendorController,
                onChanged: notifier.setVendor,
                decoration: _inputDecoration(
                  hint: 'مثال: شركة الكهرباء',
                  scheme: scheme,
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),

              // ─── Notes ───
              _Label(text: 'ملاحظات (اختياري)', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              TextFormField(
                controller: _notesController,
                onChanged: notifier.setNotes,
                maxLines: 3,
                decoration: _inputDecoration(
                  hint: 'أي تفاصيل إضافية',
                  scheme: scheme,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLg),

              // ─── Error ───
              if (form.hasError) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.spaceSmMd),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: scheme.onErrorContainer, size: 18),
                      const SizedBox(width: AppSizes.spaceSm),
                      Expanded(
                        child: Text(
                          form.errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spaceMd),
              ],

              // ─── Save ───
              FilledButton.icon(
                onPressed: form.isSaving
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        final saved = await notifier.save();
                        if (saved != null && context.mounted) {
                          await ref
                              .read(expensesListProvider.notifier)
                              .refresh();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(form.isEditing
                                    ? 'تم تحديث المصروف'
                                    : 'تم إضافة المصروف'),
                              ),
                            );
                          }
                        }
                      },
                icon: form.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(form.isEditing ? 'حفظ التعديلات' : 'حفظ المصروف'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required ColorScheme scheme,
    String? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSmMd,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.scheme});
  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    );
  }
}