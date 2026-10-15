// lib/features/expenses/presentation/pages/expense_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../data/models/expense.dart';
import '../providers/expense_form_provider.dart';
import '../providers/expenses_list_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// ExpenseFormPage — صفحة إضافة/تعديل مصروف
/// ═══════════════════════════════════════════════════════════
class ExpenseFormPage extends ConsumerStatefulWidget {
  const ExpenseFormPage({super.key, this.editingExpense});

  /// لو null → وضع الإضافة، لو موجود → وضع التعديل
  final Expense? editingExpense;

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _notesController = TextEditingController();
  final _receiptUrlController = TextEditingController();

  DateTime _expenseDate = DateTime.now();

  bool get _isEditing => widget.editingExpense != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        ref
            .read(expenseFormProvider.notifier)
            .loadForEdit(widget.editingExpense!.id);
      } else {
        ref.read(expenseFormProvider.notifier).reset();
      }
      _hydrateFromProvider();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _notesController.dispose();
    _receiptUrlController.dispose();
    super.dispose();
  }

  void _hydrateFromProvider() {
    final s = ref.read(expenseFormProvider);
    _descriptionController.text = s.description;
    _amountController.text = s.amount > 0 ? s.amount.toStringAsFixed(0) : '';
    _vendorController.text = s.vendor ?? '';
    _notesController.text = s.notes ?? '';
    _receiptUrlController.text = s.receiptUrl ?? '';
    _expenseDate = s.expenseDate;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formState = ref.watch(expenseFormProvider);
    final isSaving = formState.isSaving;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          _isEditing ? 'تعديل المصروف' : 'مصروف جديد',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══ الأساسيات ═══
              _SectionTitle(title: 'الأساسيات', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _descriptionController,
                label: 'الوصف *',
                hint: 'مثال: فاتورة كهرباء نوفمبر',
                prefixIcon: Icons.description_outlined,
                onChanged: (v) =>
                    ref.read(expenseFormProvider.notifier).setDescription(v),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'الوصف مطلوب' : null,
              ),
              const SizedBox(height: AppSizes.spaceSm),

              _number(
                controller: _amountController,
                label: 'المبلغ *',
                hint: '0',
                onChanged: (v) => ref
                    .read(expenseFormProvider.notifier)
                    .setAmount(double.tryParse(v) ?? 0),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'المبلغ مطلوب';
                  }
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'رقم غير صحيح';
                  return null;
                },
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ الفئة ═══
              _SectionTitle(title: 'الفئة *', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _CategoryPicker(
                selected: formState.category,
                onChanged: (c) =>
                    ref.read(expenseFormProvider.notifier).setCategory(c),
                scheme: scheme,
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ طريقة الدفع ═══
              _SectionTitle(title: 'طريقة الدفع', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _MethodPicker(
                selected: formState.paymentMethod,
                onChanged: (m) =>
                    ref.read(expenseFormProvider.notifier).setPaymentMethod(m),
                scheme: scheme,
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ التاريخ ═══
              _SectionTitle(title: 'التاريخ', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _DateField(
                date: _expenseDate,
                onChanged: (d) {
                  setState(() => _expenseDate = d);
                  ref.read(expenseFormProvider.notifier).setExpenseDate(d);
                },
                scheme: scheme,
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ إضافي ═══
              _SectionTitle(title: 'معلومات إضافية', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _vendorController,
                label: 'المورد / الجهة (اختياري)',
                hint: 'مثال: شركة الكهرباء',
                prefixIcon: Icons.store_outlined,
                ltr: true,
                onChanged: (v) => ref
                    .read(expenseFormProvider.notifier)
                    .setVendor(v.isEmpty ? null : v),
              ),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _receiptUrlController,
                label: 'رابط الإيصال (اختياري)',
                hint: 'https://...',
                prefixIcon: Icons.attach_file,
                ltr: true,
                onChanged: (v) => ref
                    .read(expenseFormProvider.notifier)
                    .setReceiptUrl(v.isEmpty ? null : v),
              ),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _notesController,
                label: 'ملاحظات (اختياري)',
                hint: 'أي تفاصيل إضافية',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
                onChanged: (v) => ref
                    .read(expenseFormProvider.notifier)
                    .setNotes(v.isEmpty ? null : v),
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ Save Button ═══
              FilledButton.icon(
                onPressed: isSaving ? null : _handleSave,
                icon: isSaving
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
                label: Text(
                  isSaving
                      ? 'جاري الحفظ...'
                      : (_isEditing ? 'حفظ التعديلات' : 'إضافة المصروف'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeightLg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceMd),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await ref.read(expenseFormProvider.notifier).save();

    if (!mounted) return;

    if (result != null) {
      ref.read(expensesListProvider.notifier).refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'تم تعديل المصروف' : 'تم إضافة المصروف',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } else {
      final error = ref.read(expenseFormProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل الحفظ'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Helpers ───

  Widget _text({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool ltr = false,
    IconData? prefixIcon,
    TextInputType? keyboard,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      textDirection: ltr ? TextDirection.ltr : null,
      onChanged: onChanged,
      validator: validator,
      decoration: _deco(scheme, label: label, hint: hint, icon: prefixIcon),
    );
  }

  Widget _number({
    required TextEditingController controller,
    required String label,
    String? hint,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      onChanged: onChanged,
      validator: validator,
      decoration: _deco(
        scheme,
        label: label,
        hint: hint,
        icon: Icons.attach_money,
      ),
    );
  }

  InputDecoration _deco(
    ColorScheme scheme, {
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: AppSizes.iconSm) : null,
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(
          color: scheme.primary,
          width: AppSizes.borderMedium,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(
          color: scheme.error,
          width: AppSizes.borderMedium,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SECTION TITLE
// ═══════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.scheme});

  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSizes.spaceSm),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CATEGORY PICKER
// ═══════════════════════════════════════════════════════════

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selected,
    required this.onChanged,
    required this.scheme,
  });

  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: ExpenseCategory.values.map((c) {
        final isSelected = c == selected;
        final color = c.color;
        return InkWell(
          onTap: () => onChanged(c),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                color: isSelected
                    ? color
                    : scheme.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  c.icon,
                  size: 14,
                  color: isSelected ? color : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  c.labelAr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  METHOD PICKER
// ═══════════════════════════════════════════════════════════

class _MethodPicker extends StatelessWidget {
  const _MethodPicker({
    required this.selected,
    required this.onChanged,
    required this.scheme,
  });

  final ExpensePaymentMethod selected;
  final ValueChanged<ExpensePaymentMethod> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: ExpensePaymentMethod.values.map((m) {
        final isSelected = m == selected;
        return InkWell(
          onTap: () => onChanged(m),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary.withValues(alpha: 0.15)
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                color: isSelected
                    ? scheme.primary
                    : scheme.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  m.icon,
                  size: 14,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  m.labelAr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  DATE FIELD
// ═══════════════════════════════════════════════════════════

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.onChanged,
    required this.scheme,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: now,
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: AppSizes.spaceSmMd,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSizes.spaceSm),
            Expanded(
              child: Text(
                '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
