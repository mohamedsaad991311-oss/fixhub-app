// lib/features/expenses/presentation/providers/expense_detail_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/expense_service.dart';
import '../../data/models/expense.dart';

/// ═══════════════════════════════════════════════════════════
/// ExpenseDetailState — حالة تفاصيل مصروف
/// ═══════════════════════════════════════════════════════════
class ExpenseDetailState {
  final String expenseId;
  final Expense? expense;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const ExpenseDetailState({
    required this.expenseId,
    this.expense,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  bool get hasExpense => expense != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  ExpenseDetailState copyWith({
    String? expenseId,
    Expense? expense,
    bool clearExpense = false,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExpenseDetailState(
      expenseId: expenseId ?? this.expenseId,
      expense: clearExpense ? null : (expense ?? this.expense),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ExpenseDetailNotifier
/// ═══════════════════════════════════════════════════════════
class ExpenseDetailNotifier extends StateNotifier<ExpenseDetailState> {
  ExpenseDetailNotifier(this._ref, String expenseId)
      : super(ExpenseDetailState(expenseId: expenseId)) {
    load();
  }

  final Ref _ref;

  ExpenseService get _service => _ref.read(expenseServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final expense = await _service.getById(state.expenseId);
      if (expense == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'المصروف غير موجود',
        );
        return;
      }
      state = state.copyWith(expense: expense, isLoading: false);
    } catch (e) {
      debugPrint('ExpenseDetailNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل المصروف',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final expense = await _service.getById(state.expenseId);
      if (expense == null) return;
      state = state.copyWith(expense: expense, clearError: true);
    } catch (e) {
      debugPrint('ExpenseDetailNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  UPDATE
  // ─────────────────────────────────────────────────────────

  Future<bool> update(Expense expense) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await _service.update(expense);
      if (updated == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث المصروف',
        );
        return false;
      }
      state = state.copyWith(expense: updated, isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('ExpenseDetailNotifier.update error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث المصروف',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────

  Future<bool> delete() async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.delete(state.expenseId);
      state = state.copyWith(isUpdating: false);
      return ok;
    } catch (e) {
      debugPrint('ExpenseDetailNotifier.delete error: $e');
      state = state.copyWith(isUpdating: false);
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

final expenseDetailProvider = StateNotifierProvider.family<
    ExpenseDetailNotifier, ExpenseDetailState, String>((ref, id) {
  return ExpenseDetailNotifier(ref, id);
});

/// اختصار: المصروف
final expenseByIdProvider = Provider.family<Expense?, String>((ref, id) {
  return ref.watch(expenseDetailProvider(id)).expense;
});

/// اختصار: هل التحميل جاري؟
final expenseDetailLoadingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(expenseDetailProvider(id)).isLoading;
});

/// اختصار: هل التحديث جاري؟
final expenseDetailUpdatingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(expenseDetailProvider(id)).isUpdating;
});
