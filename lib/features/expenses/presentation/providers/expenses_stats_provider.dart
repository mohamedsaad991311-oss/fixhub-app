// lib/features/expenses/presentation/providers/expenses_stats_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/expense_service.dart';
import '../../data/models/expense.dart';

/// ═══════════════════════════════════════════════════════════
/// 1) ملخص الشهر الحالي
/// ═══════════════════════════════════════════════════════════
final currentMonthExpenseSummaryProvider =
    FutureProvider.autoDispose<ExpenseSummary>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getCurrentMonthSummary();
});

/// ═══════════════════════════════════════════════════════════
/// 2) ملخص السنة الحالية
/// ═══════════════════════════════════════════════════════════
final currentYearExpenseSummaryProvider =
    FutureProvider.autoDispose<ExpenseSummary>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getCurrentYearSummary();
});

/// ═══════════════════════════════════════════════════════════
/// 3) ملخص فترة مخصصة (fromDate + toDate)
/// ═══════════════════════════════════════════════════════════
class ExpensePeriodParams {
  const ExpensePeriodParams({
    required this.fromDate,
    required this.toDate,
    this.category,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final ExpenseCategory? category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpensePeriodParams &&
          other.fromDate == fromDate &&
          other.toDate == toDate &&
          other.category == category;

  @override
  int get hashCode => Object.hash(fromDate, toDate, category);
}

final expensePeriodSummaryProvider = FutureProvider.autoDispose
    .family<PeriodExpenseSummary, ExpensePeriodParams>((ref, params) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getPeriodSummary(
    fromDate: params.fromDate,
    toDate: params.toDate,
    category: params.category,
  );
});

/// ═══════════════════════════════════════════════════════════
/// 4) توزيع المصروفات حسب الفئة (فترة)
/// ═══════════════════════════════════════════════════════════
final expensesByCategoryPeriodProvider = FutureProvider.autoDispose
    .family<Map<ExpenseCategory, double>, ExpensePeriodParams>(
        (ref, params) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getByCategory(
    fromDate: params.fromDate,
    toDate: params.toDate,
  );
});

/// ═══════════════════════════════════════════════════════════
/// 5) سلسلة زمنية يومية (للرسم البياني)
/// ═══════════════════════════════════════════════════════════
final expensesTimeSeriesProvider = FutureProvider.autoDispose
    .family<Map<DateTime, double>, ExpensePeriodParams>((ref, params) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getExpensesTimeSeries(
    fromDate: params.fromDate,
    toDate: params.toDate,
  );
});

/// ═══════════════════════════════════════════════════════════
/// 6) أعلى المصروفات (فترة + limit)
/// ═══════════════════════════════════════════════════════════
class ExpenseTopParams {
  const ExpenseTopParams({
    this.fromDate,
    this.toDate,
    this.limit = 10,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final int limit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTopParams &&
          other.fromDate == fromDate &&
          other.toDate == toDate &&
          other.limit == limit;

  @override
  int get hashCode => Object.hash(fromDate, toDate, limit);
}

final topExpensesProvider = FutureProvider.autoDispose
    .family<List<Expense>, ExpenseTopParams>((ref, params) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getTopExpenses(
    fromDate: params.fromDate,
    toDate: params.toDate,
    limit: params.limit,
  );
});

/// ═══════════════════════════════════════════════════════════
/// 7) مصروفات ثابتة (recurring)
/// ═══════════════════════════════════════════════════════════
final recurringExpensesProvider =
    FutureProvider.autoDispose<List<Expense>>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getRecurringExpenses();
});

/// ═══════════════════════════════════════════════════════════
/// 8) تفصيل المصروفات الثابتة حسب الفئة (شهر معيّن)
/// ═══════════════════════════════════════════════════════════
final recurringBreakdownProvider = FutureProvider.autoDispose
    .family<Map<ExpenseCategory, double>, DateTime?>((ref, month) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getRecurringBreakdown(month: month);
});