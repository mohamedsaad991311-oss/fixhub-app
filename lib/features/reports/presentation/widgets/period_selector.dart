// lib/features/reports/presentation/widgets/period_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/reports_filter_provider.dart';
import '../providers/reports_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// PeriodSelector — اختيار فترة التقرير
/// ═══════════════════════════════════════════════════════════════
///
/// خيارات:
/// - اليوم / أسبوع / شهر / سنة / مخصص
///
/// عند اختيار "مخصص" → يفتح DateRangePicker
///
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(reportsFilterProvider);
    final scheme = Theme.of(context).colorScheme;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ──── Label ────
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSizes.spaceXs,
            bottom: AppSizes.spaceSm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'الفترة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),
              // ──── Current label ────
              Expanded(
                child: Text(
                  filterState.label(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ──── Selector ────
        isNarrow
            ? _buildDropdown(context, ref, filterState)
            : _buildSegmented(context, ref, filterState),

        // ──── Custom range indicator ────
        if (filterState.isCustom &&
            filterState.customFrom != null &&
            filterState.customTo != null) ...[
          const SizedBox(height: AppSizes.spaceSm),
          _buildCustomRangeChip(context, ref, filterState),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Segmented (Tablet/Desktop)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSegmented(
    BuildContext context,
    WidgetRef ref,
    ReportsFilterState filterState,
  ) {
    return SegmentedButton<ReportsPeriod>(
      segments: const [
        ButtonSegment(
          value: ReportsPeriod.today,
          label: Text('اليوم'),
          icon: Icon(Icons.today, size: AppSizes.iconXs),
        ),
        ButtonSegment(
          value: ReportsPeriod.week,
          label: Text('أسبوع'),
          icon: Icon(Icons.view_week, size: AppSizes.iconXs),
        ),
        ButtonSegment(
          value: ReportsPeriod.month,
          label: Text('شهر'),
          icon: Icon(Icons.calendar_view_month, size: AppSizes.iconXs),
        ),
        ButtonSegment(
          value: ReportsPeriod.year,
          label: Text('سنة'),
          icon: Icon(Icons.calendar_today, size: AppSizes.iconXs),
        ),
        ButtonSegment(
          value: ReportsPeriod.custom,
          label: Text('مخصص'),
          icon: Icon(Icons.date_range, size: AppSizes.iconXs),
        ),
      ],
      selected: {filterState.period},
      onSelectionChanged: (selection) =>
          _onPeriodSelected(context, ref, selection.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Dropdown (Mobile)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDropdown(
    BuildContext context,
    WidgetRef ref,
    ReportsFilterState filterState,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant,
          width: AppSizes.borderNormal,
        ),
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSizes.spaceSmMd,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReportsPeriod>(
          value: filterState.period,
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          items: ReportsPeriod.values.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Row(
                children: [
                  Icon(
                    _iconForPeriod(p),
                    size: AppSizes.iconSm,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Text(_labelForPeriod(p)),
                ],
              ),
            );
          }).toList(),
          onChanged: (p) {
            if (p == null) return;
            _onPeriodSelected(context, ref, p);
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Custom Range Chip
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCustomRangeChip(
    BuildContext context,
    WidgetRef ref,
    ReportsFilterState filterState,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSizes.spaceSmMd,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            size: AppSizes.iconSm,
            color: scheme.onPrimaryContainer,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              'من ${_fmtDate(filterState.customFrom!)} إلى ${_fmtDate(filterState.customTo!)}',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // ──── Edit button ────
          InkWell(
            onTap: () => _pickCustomRange(
              context,
              ref,
              initialFrom: filterState.customFrom,
              initialTo: filterState.customTo,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spaceXs),
              child: Icon(
                Icons.edit,
                size: AppSizes.iconSm,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          // ──── Clear button ────
          InkWell(
            onTap: () => ref.read(reportsFilterProvider.notifier).clear(),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spaceXs),
              child: Icon(
                Icons.close,
                size: AppSizes.iconSm,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Actions
  // ═══════════════════════════════════════════════════════════════

  Future<void> _onPeriodSelected(
    BuildContext context,
    WidgetRef ref,
    ReportsPeriod period,
  ) async {
    if (period == ReportsPeriod.custom) {
      await _pickCustomRange(context, ref);
      return;
    }
    await ref.read(reportsFilterProvider.notifier).selectPeriod(period);
  }

  Future<void> _pickCustomRange(
    BuildContext context,
    WidgetRef ref, {
    DateTime? initialFrom,
    DateTime? initialTo,
  }) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: (initialFrom != null && initialTo != null)
          ? DateTimeRange(start: initialFrom, end: initialTo)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    await ref.read(reportsFilterProvider.notifier).selectCustomRange(
          DateTime(picked.start.year, picked.start.month, picked.start.day),
          DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          ),
        );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Helpers
  // ═══════════════════════════════════════════════════════════════

  IconData _iconForPeriod(ReportsPeriod p) {
    switch (p) {
      case ReportsPeriod.today:
        return Icons.today;
      case ReportsPeriod.week:
        return Icons.view_week;
      case ReportsPeriod.month:
        return Icons.calendar_view_month;
      case ReportsPeriod.year:
        return Icons.calendar_today;
      case ReportsPeriod.custom:
        return Icons.date_range;
    }
  }

  String _labelForPeriod(ReportsPeriod p) {
    switch (p) {
      case ReportsPeriod.today:
        return 'اليوم';
      case ReportsPeriod.week:
        return 'آخر 7 أيام';
      case ReportsPeriod.month:
        return 'هذا الشهر';
      case ReportsPeriod.year:
        return 'هذه السنة';
      case ReportsPeriod.custom:
        return 'فترة مخصصة';
    }
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
