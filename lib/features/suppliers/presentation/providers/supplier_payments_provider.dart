// lib/features/suppliers/presentation/providers/supplier_payments_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supplier_service.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierPaymentsState — حالة قائمة مدفوعات مورد
/// ═══════════════════════════════════════════════════════════
class SupplierPaymentsState {
  final String supplierId;
  final List<SupplierPayment> payments;
  final PaymentMethod? methodFilter;
  final String? search;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const SupplierPaymentsState({
    required this.supplierId,
    this.payments = const [],
    this.methodFilter,
    this.search,
    this.fromDate,
    this.toDate,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && payments.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// الإجمالي
  double get totalAmount =>
      payments.fold<double>(0, (sum, p) => sum + p.amount);

  /// حسب الطريقة
  Map<PaymentMethod, double> get byMethod {
    final map = <PaymentMethod, double>{};
    for (final p in payments) {
      map[p.paymentMethod] = (map[p.paymentMethod] ?? 0) + p.amount;
    }
    return map;
  }

  /// المدفوعات المفلترة
  List<SupplierPayment> get filteredPayments {
    var list = payments;

    if (methodFilter != null) {
      list = list.where((p) => p.paymentMethod == methodFilter).toList();
    }

    if (fromDate != null) {
      list = list.where((p) => !p.paymentDate.isBefore(fromDate!)).toList();
    }

    if (toDate != null) {
      final endOfDay = DateTime(
        toDate!.year,
        toDate!.month,
        toDate!.day,
        23,
        59,
        59,
      );
      list = list.where((p) => !p.paymentDate.isAfter(endOfDay)).toList();
    }

    if (search != null && search!.trim().isNotEmpty) {
      final q = search!.toLowerCase().trim();
      list = list
          .where((p) => (p.notes?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return list;
  }

  SupplierPaymentsState copyWith({
    String? supplierId,
    List<SupplierPayment>? payments,
    PaymentMethod? methodFilter,
    bool clearMethodFilter = false,
    String? search,
    bool clearSearch = false,
    DateTime? fromDate,
    bool clearFromDate = false,
    DateTime? toDate,
    bool clearToDate = false,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierPaymentsState(
      supplierId: supplierId ?? this.supplierId,
      payments: payments ?? this.payments,
      methodFilter:
          clearMethodFilter ? null : (methodFilter ?? this.methodFilter),
      search: clearSearch ? null : (search ?? this.search),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// SupplierPaymentsNotifier
/// ═══════════════════════════════════════════════════════════
class SupplierPaymentsNotifier extends StateNotifier<SupplierPaymentsState> {
  SupplierPaymentsNotifier(this._ref, String supplierId)
      : super(SupplierPaymentsState(supplierId: supplierId)) {
    load();
  }

  final Ref _ref;

  SupplierService get _service => _ref.read(supplierServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final payments = await _service.listPayments(
        supplierId: state.supplierId,
      );
      state = state.copyWith(payments: payments, isLoading: false);
    } catch (e) {
      debugPrint('SupplierPaymentsNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل المدفوعات',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final payments = await _service.listPayments(
        supplierId: state.supplierId,
      );
      state = state.copyWith(payments: payments, clearError: true);
    } catch (e) {
      debugPrint('SupplierPaymentsNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  RECORD PAYMENT
  // ─────────────────────────────────────────────────────────

  Future<bool> recordPayment(SupplierPayment payment) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final created = await _service.recordPayment(payment);
      if (created == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تسجيل الدفعة',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierPaymentsNotifier.recordPayment error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تسجيل الدفعة',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────

  Future<bool> deletePayment(String id) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.deletePayment(id);
      if (ok) {
        state = state.copyWith(
          payments: state.payments.where((p) => p.id != id).toList(),
        );
      }
      state = state.copyWith(isUpdating: false);
      return ok;
    } catch (e) {
      debugPrint('SupplierPaymentsNotifier.deletePayment error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل حذف الدفعة',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  FILTERS
  // ─────────────────────────────────────────────────────────

  void filterByMethod(PaymentMethod? method) {
    state = method == null
        ? state.copyWith(clearMethodFilter: true)
        : state.copyWith(methodFilter: method);
  }

  void search(String? query) {
    final trimmed = query?.trim();
    state = (trimmed == null || trimmed.isEmpty)
        ? state.copyWith(clearSearch: true)
        : state.copyWith(search: trimmed);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(
      fromDate: from,
      clearFromDate: from == null,
      toDate: to,
      clearToDate: to == null,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      clearMethodFilter: true,
      clearSearch: true,
      clearFromDate: true,
      clearToDate: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

final supplierPaymentsListProvider = StateNotifierProvider.family<
    SupplierPaymentsNotifier, SupplierPaymentsState, String>((ref, id) {
  return SupplierPaymentsNotifier(ref, id);
});

/// المدفوعات المفلترة
final supplierPaymentsFilteredProvider =
    Provider.family<List<SupplierPayment>, String>((ref, id) {
  return ref.watch(supplierPaymentsListProvider(id)).filteredPayments;
});

/// إجمالي المدفوعات
final supplierPaymentsTotalProvider =
    Provider.family<double, String>((ref, id) {
  return ref.watch(supplierPaymentsListProvider(id)).totalAmount;
});

/// المدفوعات حسب الطريقة
final supplierPaymentsByMethodProvider =
    Provider.family<Map<PaymentMethod, double>, String>((ref, id) {
  return ref.watch(supplierPaymentsListProvider(id)).byMethod;
});

/// فلتر الحالة الحالي
final supplierPaymentsMethodFilterProvider =
    Provider.family<PaymentMethod?, String>((ref, id) {
  return ref.watch(supplierPaymentsListProvider(id)).methodFilter;
});
