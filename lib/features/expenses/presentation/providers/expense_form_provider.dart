// lib/features/expenses/presentation/providers/expense_form_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/expense_service.dart';
import '../../data/models/expense.dart';

class ExpenseFormState {
  final String? editingId;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final ExpensePaymentMethod paymentMethod;
  final DateTime expenseDate;
  final String? vendor;
  final String? notes;
  final String? receiptUrl;
  final bool isSaving;
  final String? errorMessage;

  ExpenseFormState({
    this.editingId,
    this.description = '',
    this.amount = 0,
    this.category = ExpenseCategory.other,
    this.paymentMethod = ExpensePaymentMethod.cash,
    DateTime? expenseDate,
    this.vendor,
    this.notes,
    this.receiptUrl,
    this.isSaving = false,
    this.errorMessage,
  }) : expenseDate = expenseDate ?? DateTime.now();

  bool get isEditing => editingId != null;
  bool get isAdd => editingId == null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isValid => description.trim().isNotEmpty && amount > 0;

  ExpenseFormState copyWith({
    String? editingId,
    bool clearEditingId = false,
    String? description,
    double? amount,
    ExpenseCategory? category,
    ExpensePaymentMethod? paymentMethod,
    DateTime? expenseDate,
    String? vendor,
    bool clearVendor = false,
    String? notes,
    bool clearNotes = false,
    String? receiptUrl,
    bool clearReceiptUrl = false,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExpenseFormState(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      expenseDate: expenseDate ?? this.expenseDate,
      vendor: clearVendor ? null : (vendor ?? this.vendor),
      notes: clearNotes ? null : (notes ?? this.notes),
      receiptUrl: clearReceiptUrl ? null : (receiptUrl ?? this.receiptUrl),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ExpenseFormNotifier extends StateNotifier<ExpenseFormState> {
  ExpenseFormNotifier(this._ref) : super(ExpenseFormState());

  final Ref _ref;
  ExpenseService get _service => _ref.read(expenseServiceProvider);

  Future<void> loadForEdit(String id) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final expense = await _service.getById(id);
      if (expense == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'المصروف غير موجود',
        );
        return;
      }
      state = ExpenseFormState(
        editingId: expense.id,
        description: expense.description ?? '',
        amount: expense.amount,
        category: expense.category,
        paymentMethod: expense.paymentMethod,
        expenseDate: expense.expenseDate,
        vendor: expense.vendor,
        notes: expense.notes,
        receiptUrl: expense.receiptUrl,
      );
    } catch (e) {
      debugPrint('ExpenseFormNotifier.loadForEdit error: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'فشل تحميل المصروف',
      );
    }
  }

  void reset() => state = ExpenseFormState();

  void setDescription(String v) => state = state.copyWith(description: v);
  void setAmount(double v) => state = state.copyWith(amount: v);
  void setCategory(ExpenseCategory c) => state = state.copyWith(category: c);
  void setPaymentMethod(ExpensePaymentMethod m) =>
      state = state.copyWith(paymentMethod: m);
  void setExpenseDate(DateTime d) => state = state.copyWith(expenseDate: d);

  void setVendor(String? v) => state =
      v == null ? state.copyWith(clearVendor: true) : state.copyWith(vendor: v);

  void setNotes(String? v) => state =
      v == null ? state.copyWith(clearNotes: true) : state.copyWith(notes: v);

  void setReceiptUrl(String? v) => state = v == null
      ? state.copyWith(clearReceiptUrl: true)
      : state.copyWith(receiptUrl: v);

  Future<Expense?> save() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'الرجاء إدخال الوصف + المبلغ');
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final expense = Expense(
        id: state.editingId ?? '',
        tenantId: '',
        description: state.description.trim(),
        amount: state.amount,
        category: state.category,
        paymentMethod: state.paymentMethod,
        expenseDate: state.expenseDate,
        vendor: _nullIfEmpty(state.vendor),
        notes: _nullIfEmpty(state.notes),
        receiptUrl: _nullIfEmpty(state.receiptUrl),
      );

      final saved = state.isEditing
          ? await _service.update(expense)
          : await _service.create(expense);

      if (saved == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'فشل الحفظ — حاول تاني',
        );
        return null;
      }

      state = state.copyWith(isSaving: false);
      return saved;
    } catch (e) {
      debugPrint('ExpenseFormNotifier.save error: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'حدث خطأ غير متوقع',
      );
      return null;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  String? _nullIfEmpty(String? v) {
    if (v == null) return null;
    final trimmed = v.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

final expenseFormProvider =
    StateNotifierProvider<ExpenseFormNotifier, ExpenseFormState>((ref) {
  return ExpenseFormNotifier(ref);
});

final expenseFormIsEditingProvider = Provider<bool>((ref) {
  return ref.watch(expenseFormProvider).isEditing;
});

final expenseFormSavingProvider = Provider<bool>((ref) {
  return ref.watch(expenseFormProvider).isSaving;
});

final expenseFormValidProvider = Provider<bool>((ref) {
  return ref.watch(expenseFormProvider).isValid;
});
