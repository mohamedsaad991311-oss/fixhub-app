// lib/features/reports/presentation/providers/reports_filter_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reports_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// ReportsFilterState — حالة الفلتر (للفصل عن الـ provider الرئيسي)
/// ═══════════════════════════════════════════════════════════
class ReportsFilterState {
  final ReportsPeriod period;
  final DateTime? customFrom;
  final DateTime? customTo;

  const ReportsFilterState({
    this.period = ReportsPeriod.month,
    this.customFrom,
    this.customTo,
  });

  bool get isCustom => period == ReportsPeriod.custom;

  /// نص عرض الفترة
  String label() {
    if (period != ReportsPeriod.custom) return period.labelAr;
    if (customFrom == null || customTo == null) return 'مخصص';
    return '${_fmt(customFrom!)} → ${_fmt(customTo!)}';
  }

  String _fmt(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }

  ReportsFilterState copyWith({
    ReportsPeriod? period,
    DateTime? customFrom,
    bool clearCustomFrom = false,
    DateTime? customTo,
    bool clearCustomTo = false,
  }) {
    return ReportsFilterState(
      period: period ?? this.period,
      customFrom: clearCustomFrom ? null : (customFrom ?? this.customFrom),
      customTo: clearCustomTo ? null : (customTo ?? this.customTo),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReportsFilterNotifier
/// ═══════════════════════════════════════════════════════════
class ReportsFilterNotifier extends StateNotifier<ReportsFilterState> {
  ReportsFilterNotifier(this._ref) : super(const ReportsFilterState());

  final Ref _ref;

  /// اختيار فترة جاهزة
  Future<void> selectPeriod(ReportsPeriod period) async {
    if (period == ReportsPeriod.custom) {
      // لو custom، ما نعملش load — نستنى المستخدم يختار
      state = state.copyWith(period: period);
      return;
    }

    state = ReportsFilterState(period: period);

    // حمّل الإحصائيات من جديد
    await _ref.read(reportsProvider.notifier).setPeriod(period);
  }

  /// اختيار فترة مخصصة
  Future<void> selectCustomRange(DateTime from, DateTime to) async {
    state = ReportsFilterState(
      period: ReportsPeriod.custom,
      customFrom: from,
      customTo: to,
    );
    await _ref.read(reportsProvider.notifier).setCustomRange(from, to);
  }

  /// مسح الفلتر
  Future<void> clear() async {
    state = const ReportsFilterState();
    await _ref.read(reportsProvider.notifier).setPeriod(ReportsPeriod.month);
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

final reportsFilterProvider =
    StateNotifierProvider<ReportsFilterNotifier, ReportsFilterState>((ref) {
  return ReportsFilterNotifier(ref);
});

/// اختصار: الفترة الحالية
final currentReportsPeriodProvider = Provider<ReportsPeriod>((ref) {
  return ref.watch(reportsFilterProvider).period;
});

/// اختصار: نص عرض الفترة
final reportsPeriodLabelProvider = Provider<String>((ref) {
  return ref.watch(reportsFilterProvider).label();
});

/// اختصار: هل الفترة مخصصة؟
final isCustomReportsPeriodProvider = Provider<bool>((ref) {
  return ref.watch(reportsFilterProvider).isCustom;
});
