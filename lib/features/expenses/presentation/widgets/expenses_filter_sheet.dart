// lib/features/expenses/presentation/widgets/expenses_filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../data/models/expense.dart';
import '../providers/expenses_list_provider.dart';

class ExpensesFilterSheet extends ConsumerStatefulWidget {
  const ExpensesFilterSheet({super.key});

  @override
  ConsumerState<ExpensesFilterSheet> createState() =>
      _ExpensesFilterSheetState();
}

class _ExpensesFilterSheetState extends ConsumerState<ExpensesFilterSheet> {
  ExpenseCategory? _category;
  ExpensePaymentMethod? _method;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _onlyRecurring = false;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(expensesListProvider).filter;
    _category = filter.category;
    _method = filter.paymentMethod;
    _fromDate = filter.fromDate;
    _toDate = filter.toDate;
    _onlyRecurring = filter.onlyRecurring;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(expensesListProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // ─── Handle ───
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ─── Header ───
              Padding(
                padding: const EdgeInsets.all(AppSizes.spaceMd),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: scheme.primary),
                    const SizedBox(width: AppSizes.spaceSm),
                    Text(
                      'تصفية المصاريف',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _category = null;
                          _method = null;
                          _fromDate = null;
                          _toDate = null;
                          _onlyRecurring = false;
                        });
                      },
                      child: const Text('مسح الكل'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // ─── Body ───
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Category ───
                      _SectionTitle(
                        title: 'الفئة',
                        scheme: scheme,
                      ),
                      const SizedBox(height: AppSizes.spaceSm),
                      Wrap(
                        spacing: AppSizes.spaceSm,
                        runSpacing: AppSizes.spaceSm,
                        children: [
                          _FilterChip(
                            label: 'الكل',
                            selected: _category == null,
                            onTap: () =>
                                setState(() => _category = null),
                          ),
                          ...ExpenseCategory.values.map(
                            (c) => _FilterChip(
                              label: c.labelAr,
                              icon: c.icon,
                              color: c.color,
                              selected: _category == c,
                              onTap: () => setState(() => _category = c),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceLg),

                      // ─── Payment Method ───
                      _SectionTitle(
                        title: 'طريقة الدفع',
                        scheme: scheme,
                      ),
                      const SizedBox(height: AppSizes.spaceSm),
                      Wrap(
                        spacing: AppSizes.spaceSm,
                        runSpacing: AppSizes.spaceSm,
                        children: [
                          _FilterChip(
                            label: 'الكل',
                            selected: _method == null,
                            onTap: () => setState(() => _method = null),
                          ),
                          ...ExpensePaymentMethod.values.map(
                            (m) => _FilterChip(
                              label: m.labelAr,
                              icon: m.icon,
                              selected: _method == m,
                              onTap: () => setState(() => _method = m),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceLg),

                      // ─── Date Range ───
                      _SectionTitle(
                        title: 'الفترة',
                        scheme: scheme,
                      ),
                      const SizedBox(height: AppSizes.spaceSm),
                      Row(
                        children: [
                          Expanded(
                            child: _DateButton(
                              label: 'من',
                              date: _fromDate,
                              onTap: () => _pickDate(isFrom: true),
                              scheme: scheme,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceSm),
                          Expanded(
                            child: _DateButton(
                              label: 'إلى',
                              date: _toDate,
                              onTap: () => _pickDate(isFrom: false),
                              scheme: scheme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceLg),

                      // ─── Recurring ───
                      SwitchListTile(
                        title: const Text('المصاريف الثابتة فقط'),
                        subtitle: const Text('مثل الإيجار والرواتب'),
                        value: _onlyRecurring,
                        onChanged: (v) =>
                            setState(() => _onlyRecurring = v),
                      ),
                    ],
                  ),
                ),
              ),
              // ─── Apply Button ───
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spaceMd),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                       final currentFilter = ref.read(expensesListProvider).filter;
final filter = currentFilter.copyWith(
                          category: _category,
                          clearCategory: _category == null,
                          paymentMethod: _method,
                          clearPayment: _method == null,
                          fromDate: _fromDate,
                          toDate: _toDate,
                          onlyRecurring: _onlyRecurring,
                        );
                        await notifier.setFilter(filter);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('تطبيق'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_fromDate ?? now) : (_toDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.scheme});
  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceSmMd,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.15) : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: selected ? c : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? c : scheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? c : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceSmMd,
          vertical: AppSizes.spaceSm,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                date == null
                    ? label
                    : '${date!.day}/${date!.month}/${date!.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: date == null
                      ? scheme.onSurfaceVariant
                      : scheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}