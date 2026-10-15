// lib/features/expenses/presentation/providers/expenses_list_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/expense_service.dart';
import '../../data/models/expense.dart';

/// ═══════════════════════════════════════════════════════════
/// ExpensesListState — حالة قائمة المصروفات
/// ═══════════════════════════════════════════════════════════
class ExpensesListState {
  final ExpenseFilter filter;
  final List<Expense> expenses;
  final ExpenseSummary monthSummary;
  final bool isLoading;
  final String? errorMessage;

  const ExpensesListState({
    this.filter = const ExpenseFilter(),
    this.expenses = const [],
    this.monthSummary = const ExpenseSummary(),
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && expenses.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  double get totalShown => expenses.fold<double>(0, (sum, e) => sum + e.amount);

  ExpensesListState copyWith({
    ExpenseFilter? filter,
    List<Expense>? expenses,
    ExpenseSummary? monthSummary,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExpensesListState(
      filter: filter ?? this.filter,
      expenses: expenses ?? this.expenses,
      monthSummary: monthSummary ?? this.monthSummary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ExpensesListNotifier
/// ═══════════════════════════════════════════════════════════
class ExpensesListNotifier extends StateNotifier<ExpensesListState> {
  ExpensesListNotifier(this._ref) : super(const ExpensesListState()) {
    load();
  }

  final Ref _ref;

  ExpenseService get _service => _ref.read(expenseServiceProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.list(state.filter),
        _service.getCurrentMonthSummary(),
      ]);

      state = state.copyWith(
        expenses: results[0] as List<Expense>,
        monthSummary: results[1] as ExpenseSummary,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('ExpensesListNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل المصروفات',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _service.list(state.filter),
        _service.getCurrentMonthSummary(),
      ]);

      state = state.copyWith(
        expenses: results[0] as List<Expense>,
        monthSummary: results[1] as ExpenseSummary,
        clearError: true,
      );
    } catch (e) {
      debugPrint('ExpensesListNotifier.refresh error: $e');
    }
  }

  Future<void> setFilter(ExpenseFilter filter) async {
    state = state.copyWith(filter: filter, isLoading: true);
    await load();
  }

  Future<void> search(String? query) async {
    final trimmed = query?.trim();
    final newFilter = (trimmed == null || trimmed.isEmpty)
        ? state.filter.copyWith(search: '')
        : state.filter.copyWith(search: trimmed);
    await setFilter(newFilter);
  }

  Future<void> filterByCategory(ExpenseCategory? category) async {
    final newFilter = category == null
        ? state.filter.copyWith(clearCategory: true)
        : state.filter.copyWith(category: category);
    await setFilter(newFilter);
  }

  Future<void> filterByMethod(ExpensePaymentMethod? method) async {
    final newFilter = method == null
        ? state.filter.copyWith(clearPayment: true)
        : state.filter.copyWith(paymentMethod: method);
    await setFilter(newFilter);
  }

  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    await setFilter(
      state.filter.copyWith(fromDate: from, toDate: to),
    );
  }

  Future<void> clearFilters() async {
    await setFilter(const ExpenseFilter());
  }

  Future<bool> delete(String id) async {
    try {
      final ok = await _service.delete(id);
      if (ok) {
        state = state.copyWith(
          expenses: state.expenses.where((e) => e.id != id).toList(),
        );
        final summary = await _service.getCurrentMonthSummary();
        state = state.copyWith(monthSummary: summary);
      }
      return ok;
    } catch (e) {
      debugPrint('ExpensesListNotifier.delete error: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

final expensesListProvider =
    StateNotifierProvider<ExpensesListNotifier, ExpensesListState>((ref) {
  return ExpensesListNotifier(ref);
});

final expensesListDataProvider = Provider<List<Expense>>((ref) {
  return ref.watch(expensesListProvider).expenses;
});

final expensesMonthSummaryProvider = Provider<ExpenseSummary>((ref) {
  return ref.watch(expensesListProvider).monthSummary;
});

final expensesListLoadingProvider = Provider<bool>((ref) {
  return ref.watch(expensesListProvider).isLoading;
});

final expensesListEmptyProvider = Provider<bool>((ref) {
  return ref.watch(expensesListProvider).isEmpty;
});

final expensesListFilterProvider = Provider<ExpenseFilter>((ref) {
  return ref.watch(expensesListProvider).filter;
});

final expensesTotalShownProvider = Provider<double>((ref) {
  return ref.watch(expensesListProvider).totalShown;
});

final expensesByCategoryProvider =
    Provider<Map<ExpenseCategory, double>>((ref) {
  final list = ref.watch(expensesListDataProvider);
  final map = <ExpenseCategory, double>{};
  for (final e in list) {
    map[e.category] = (map[e.category] ?? 0) + e.amount;
  }
  return map;
});
