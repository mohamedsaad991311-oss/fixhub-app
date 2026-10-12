// lib/features/receiving/presentation/widgets/step_3_review.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../receipts/data/models/receipt.dart';
import '../providers/receiving_form_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// Step3Review — الخطوة 3: المراجعة والتأكيد
/// ═══════════════════════════════════════════════════════════
///
/// - عرض كل بيانات العميل والجهاز والأعطال والملحقات
/// - تسعير: التقديري، الخصم، العربون، الإجمالي
/// - الأولوية + مدة الضمان + تاريخ التسليم المتوقع
/// - زر "حفظ الإيصال"
///
class Step3Review extends ConsumerStatefulWidget {
  const Step3Review({super.key});

  @override
  ConsumerState<Step3Review> createState() => _Step3ReviewState();
}

class _Step3ReviewState extends ConsumerState<Step3Review> {
  late final TextEditingController _estimatedCostController;
  late final TextEditingController _depositController;
  late final TextEditingController _discountController;
  late final TextEditingController _warrantyController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(receivingFormProvider);
    _estimatedCostController = TextEditingController(
      text: form.estimatedCost > 0 ? form.estimatedCost.toStringAsFixed(0) : '',
    );
    _depositController = TextEditingController(
      text: form.deposit > 0 ? form.deposit.toStringAsFixed(0) : '',
    );
    _discountController = TextEditingController(
      text: form.discount > 0 ? form.discount.toStringAsFixed(0) : '',
    );
    _warrantyController = TextEditingController(
      text: form.warrantyDays > 0 ? form.warrantyDays.toString() : '',
    );
    _notesController = TextEditingController(text: form.notes ?? '');
  }

  @override
  void dispose() {
    _estimatedCostController.dispose();
    _depositController.dispose();
    _discountController.dispose();
    _warrantyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final form = ref.watch(receivingFormProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══ 1) العميل ═══
          _ReviewSection(
            icon: Icons.person_outline,
            title: 'العميل',
            scheme: scheme,
            isDark: isDark,
            rows: [
              _ReviewRow(label: 'الاسم', value: form.customerName),
              _ReviewRow(
                label: 'التليفون',
                value: form.customerPhone,
                ltr: true,
              ),
              if (form.customerEmail != null && form.customerEmail!.isNotEmpty)
                _ReviewRow(
                  label: 'الإيميل',
                  value: form.customerEmail!,
                  ltr: true,
                ),
              if (form.customerNotes != null && form.customerNotes!.isNotEmpty)
                _ReviewRow(label: 'ملاحظات', value: form.customerNotes!),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ═══ 2) الجهاز ═══
          _ReviewSection(
            icon: Icons.smartphone_outlined,
            title: 'الجهاز',
            scheme: scheme,
            isDark: isDark,
            rows: [
              _ReviewRow(
                label: 'النوع',
                value: _deviceTypeLabel(form.deviceType),
              ),
              if (form.deviceBrand != null && form.deviceBrand!.isNotEmpty)
                _ReviewRow(label: 'الماركة', value: form.deviceBrand!),
              if (form.deviceModel != null && form.deviceModel!.isNotEmpty)
                _ReviewRow(label: 'الموديل', value: form.deviceModel!),
              if (form.deviceImei != null && form.deviceImei!.isNotEmpty)
                _ReviewRow(
                  label: 'IMEI',
                  value: form.deviceImei!,
                  ltr: true,
                ),
              if (form.deviceSerial != null && form.deviceSerial!.isNotEmpty)
                _ReviewRow(
                  label: 'السيريال',
                  value: form.deviceSerial!,
                  ltr: true,
                ),
              if (form.deviceColor != null && form.deviceColor!.isNotEmpty)
                _ReviewRow(label: 'اللون', value: form.deviceColor!),
              if (form.devicePassword != null &&
                  form.devicePassword!.isNotEmpty)
                _ReviewRow(label: 'كلمة السر', value: form.devicePassword!),
              if (form.conditionNotes != null &&
                  form.conditionNotes!.isNotEmpty)
                _ReviewRow(
                  label: 'حالة الجهاز',
                  value: form.conditionNotes!,
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ═══ 3) الأعطال ═══
          _ReviewSection(
            icon: Icons.build_outlined,
            title: 'الأعطال (${form.issues.length})',
            scheme: scheme,
            isDark: isDark,
            customBody: form.issues.isEmpty
                ? Text(
                    'لا توجد أعطال',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  )
                : Column(
                    children: List.generate(
                      form.issues.length,
                      (i) => _IssueReviewRow(
                        index: i,
                        issue: form.issues[i],
                        scheme: scheme,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ═══ 4) الملحقات ═══
          if (form.accessories.isNotEmpty) ...[
            _ReviewSection(
              icon: Icons.inventory_2_outlined,
              title: 'الملحقات (${form.accessories.length})',
              scheme: scheme,
              isDark: isDark,
              customBody: Wrap(
                spacing: AppSizes.spaceSm,
                runSpacing: AppSizes.spaceSm,
                children: form.accessories
                    .where((a) => a.isIncluded)
                    .map(
                      (a) => Chip(
                        label: Text(a.name),
                        avatar: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: scheme.primary,
                        ),
                        backgroundColor: scheme.primary.withValues(alpha: 0.1),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSizes.spaceMd),
          ],

          // ═══ 5) الأولوية ═══
          _ReviewSection(
            icon: Icons.flag_outlined,
            title: 'الأولوية',
            scheme: scheme,
            isDark: isDark,
            customBody: _PrioritySelector(
              current: form.priority,
              onChanged: (p) =>
                  ref.read(receivingFormProvider.notifier).setPriority(p),
              scheme: scheme,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ═══ 6) التسعير ═══
          _ReviewSection(
            icon: Icons.attach_money_outlined,
            title: 'التسعير',
            scheme: scheme,
            isDark: isDark,
            customBody: Column(
              children: [
                _NumberField(
                  controller: _estimatedCostController,
                  label: 'التكلفة التقديرية',
                  hint: '0',
                  scheme: scheme,
                  isDark: isDark,
                  onChanged: (v) {
                    final val = double.tryParse(v) ?? 0;
                    ref
                        .read(receivingFormProvider.notifier)
                        .setEstimatedCost(val);
                  },
                ),
                const SizedBox(height: AppSizes.spaceSm),
                _NumberField(
                  controller: _discountController,
                  label: 'الخصم',
                  hint: '0',
                  scheme: scheme,
                  isDark: isDark,
                  onChanged: (v) {
                    final val = double.tryParse(v) ?? 0;
                    ref.read(receivingFormProvider.notifier).setDiscount(val);
                  },
                ),
                const SizedBox(height: AppSizes.spaceSm),
                _NumberField(
                  controller: _depositController,
                  label: 'العربون',
                  hint: '0',
                  scheme: scheme,
                  isDark: isDark,
                  onChanged: (v) {
                    final val = double.tryParse(v) ?? 0;
                    ref.read(receivingFormProvider.notifier).setDeposit(val);
                  },
                ),
                const SizedBox(height: AppSizes.spaceMd),
                // ─── Total box ───
                _TotalBox(form: form, scheme: scheme, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ═══ 7) الضمان + تاريخ التسليم ═══
          _ReviewSection(
            icon: Icons.verified_outlined,
            title: 'الضمان والتسليم',
            scheme: scheme,
            isDark: isDark,
            customBody: Column(
              children: [
                _NumberField(
                  controller: _warrantyController,
                  label: 'مدة الضمان (بالأيام)',
                  hint: '0 = بدون ضمان',
                  scheme: scheme,
                  isDark: isDark,
                  onChanged: (v) {
                    final val = int.tryParse(v) ?? 0;
                    ref
                        .read(receivingFormProvider.notifier)
                        .setWarrantyDays(val);
                  },
                ),
                const SizedBox(height: AppSizes.spaceSm),
                _DateField(
                  currentDate: form.expectedDeliveryDate,
                  onChanged: (d) => ref
                      .read(receivingFormProvider.notifier)
                      .setExpectedDeliveryDate(d),
                  scheme: scheme,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ═══ 8) ملاحظات ═══
          _ReviewSection(
            icon: Icons.notes_outlined,
            title: 'ملاحظات داخلية',
            scheme: scheme,
            isDark: isDark,
            customBody: TextField(
              controller: _notesController,
              maxLines: 3,
              onChanged: (v) {
                final notifier = ref.read(receivingFormProvider.notifier);
                if (v.trim().isEmpty) {
                  notifier.setNotes(null);
                } else {
                  notifier.setNotes(v);
                }
              },
              decoration: InputDecoration(
                hintText: 'أي ملاحظات داخلية (مش هتظهر للعميل)',
                filled: true,
                fillColor: isDark
                    ? scheme.surfaceContainerHigh
                    : scheme.surfaceContainerLow,
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
                contentPadding: const EdgeInsets.all(AppSizes.spaceSmMd),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.spaceLg),

          // ═══ Success note ═══
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Text(
                    'بعد الحفظ، هيتم توليد رقم إيصال وتوكن تتبع تلقائياً.',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  String _deviceTypeLabel(String? id) {
    switch (id) {
      case 'smartphone':
        return 'موبايل';
      case 'tablet':
        return 'تابلت';
      case 'laptop':
        return 'لابتوب';
      case 'smartwatch':
        return 'ساعة';
      case 'accessory':
        return 'ملحق';
      case 'other':
        return 'أخرى';
      default:
        return id ?? '-';
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  REVIEW SECTION
// ═══════════════════════════════════════════════════════════

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.icon,
    required this.title,
    required this.scheme,
    required this.isDark,
    this.rows,
    this.customBody,
  });

  final IconData icon;
  final String title;
  final ColorScheme scheme;
  final bool isDark;
  final List<_ReviewRow>? rows;
  final Widget? customBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: AppSizes.spaceSm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          // Body
          if (rows != null)
            ...rows!.map((r) => _ReviewRowWidget(row: r, scheme: scheme)),
          if (customBody != null) customBody!,
        ],
      ),
    );
  }
}

class _ReviewRow {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.ltr = false,
  });
  final String label;
  final String value;
  final bool ltr;
}

class _ReviewRowWidget extends StatelessWidget {
  const _ReviewRowWidget({required this.row, required this.scheme});

  final _ReviewRow row;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              row.label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              row.value,
              textDirection: row.ltr ? TextDirection.ltr : null,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ISSUE REVIEW ROW
// ═══════════════════════════════════════════════════════════

class _IssueReviewRow extends StatelessWidget {
  const _IssueReviewRow({
    required this.index,
    required this.issue,
    required this.scheme,
  });

  final int index;
  final ReceiptIssue issue;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  issue.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                if (issue.description != null &&
                    issue.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    issue.description!,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (issue.cost != null && issue.cost! > 0) ...[
            const SizedBox(width: AppSizes.spaceSm),
            Text(
              CurrencyFormatter.format(issue.cost),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PRIORITY SELECTOR
// ═══════════════════════════════════════════════════════════

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.current,
    required this.onChanged,
    required this.scheme,
  });

  final ReceiptPriority current;
  final ValueChanged<ReceiptPriority> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spaceSm,
      runSpacing: AppSizes.spaceSm,
      children: ReceiptPriority.values.map((p) {
        final selected = p == current;
        return InkWell(
          onTap: () => onChanged(p),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceSmMd,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? p.color.withValues(alpha: 0.15)
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                color: selected ? p.color : scheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  p.labelAr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? p.color : scheme.onSurface,
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
//  NUMBER FIELD
// ═══════════════════════════════════════════════════════════

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.scheme,
    required this.isDark,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ColorScheme scheme;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: 'ج.م',
        filled: true,
        fillColor:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide:
              BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide:
              BorderSide(color: scheme.primary, width: AppSizes.borderMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: AppSizes.spaceSmMd,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  DATE FIELD
// ═══════════════════════════════════════════════════════════

class _DateField extends StatelessWidget {
  const _DateField({
    required this.currentDate,
    required this.onChanged,
    required this.scheme,
    required this.isDark,
  });

  final DateTime? currentDate;
  final ValueChanged<DateTime?> onChanged;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: currentDate ?? now.add(const Duration(days: 3)),
          firstDate: now,
          lastDate: now.add(const Duration(days: 365)),
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
          color:
              isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSizes.spaceSm),
            Expanded(
              child: Text(
                currentDate == null
                    ? 'تاريخ التسليم المتوقع (اختياري)'
                    : '${currentDate!.year}/${currentDate!.month}/${currentDate!.day}',
                style: TextStyle(
                  fontSize: 13,
                  color: currentDate == null
                      ? scheme.onSurfaceVariant
                      : scheme.onSurface,
                ),
              ),
            ),
            if (currentDate != null)
              IconButton(
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close, size: 18),
                color: scheme.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TOTAL BOX
// ═══════════════════════════════════════════════════════════

class _TotalBox extends StatelessWidget {
  const _TotalBox({
    required this.form,
    required this.scheme,
    required this.isDark,
  });

  final ReceivingFormState form;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: 'الإجمالي',
            value: CurrencyFormatter.format(form.total),
            scheme: scheme,
            bold: true,
          ),
          const SizedBox(height: 4),
          _TotalRow(
            label: 'المدفوع (عربون)',
            value: CurrencyFormatter.format(form.deposit),
            scheme: scheme,
          ),
          const Divider(height: AppSizes.spaceMd),
          _TotalRow(
            label: 'المتبقي',
            value: CurrencyFormatter.format(form.remainingAmount),
            scheme: scheme,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.scheme,
    this.bold = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final bool bold;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: highlight ? scheme.primary : scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
