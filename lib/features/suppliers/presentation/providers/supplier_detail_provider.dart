// lib/features/suppliers/presentation/providers/supplier_detail_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supplier_service.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierDetailState — حالة تفاصيل مورد
/// ═══════════════════════════════════════════════════════════
class SupplierDetailState {
  final String supplierId;
  final Supplier? supplier;
  final List<SupplierInvoice> invoices;
  final List<SupplierPayment> payments;
  final List<SupplierReturn> returns;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const SupplierDetailState({
    required this.supplierId,
    this.supplier,
    this.invoices = const [],
    this.payments = const [],
    this.returns = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  bool get hasSupplier => supplier != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// إجمالي الفواتير
  double get totalInvoices =>
      invoices.fold<double>(0, (sum, inv) => sum + inv.total);

  /// إجمالي المدفوعات
  double get totalPayments =>
      payments.fold<double>(0, (sum, p) => sum + p.amount);

  /// عدد الفواتير غير المدفوعة
  int get unpaidInvoicesCount =>
      invoices.where((inv) => inv.status != InvoiceStatus.paid).length;

  /// الفواتير المتأخرة
  List<SupplierInvoice> get overdueInvoices => invoices
      .where((inv) =>
          inv.status != InvoiceStatus.paid &&
          inv.status != InvoiceStatus.cancelled &&
          inv.dueDate != null &&
          DateTime.now().isAfter(inv.dueDate!))
      .toList();

  SupplierDetailState copyWith({
    String? supplierId,
    Supplier? supplier,
    bool clearSupplier = false,
    List<SupplierInvoice>? invoices,
    List<SupplierPayment>? payments,
    List<SupplierReturn>? returns,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierDetailState(
      supplierId: supplierId ?? this.supplierId,
      supplier: clearSupplier ? null : (supplier ?? this.supplier),
      invoices: invoices ?? this.invoices,
      payments: payments ?? this.payments,
      returns: returns ?? this.returns,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// SupplierDetailNotifier
/// ═══════════════════════════════════════════════════════════
class SupplierDetailNotifier extends StateNotifier<SupplierDetailState> {
  SupplierDetailNotifier(this._ref, String supplierId)
      : super(SupplierDetailState(supplierId: supplierId)) {
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
      final supplier = await _service.getById(state.supplierId);
      if (supplier == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'المورد غير موجود',
        );
        return;
      }

      final results = await Future.wait([
        _service.listInvoices(supplierId: state.supplierId),
        _service.listPayments(supplierId: state.supplierId),
        _service.listReturns(supplierId: state.supplierId),
      ]);

      state = state.copyWith(
        supplier: supplier,
        invoices: results[0] as List<SupplierInvoice>,
        payments: results[1] as List<SupplierPayment>,
        returns: results[2] as List<SupplierReturn>,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('SupplierDetailNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل المورد',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final supplier = await _service.getById(state.supplierId);
      if (supplier == null) return;

      final results = await Future.wait([
        _service.listInvoices(supplierId: state.supplierId),
        _service.listPayments(supplierId: state.supplierId),
        _service.listReturns(supplierId: state.supplierId),
      ]);

      state = state.copyWith(
        supplier: supplier,
        invoices: results[0] as List<SupplierInvoice>,
        payments: results[1] as List<SupplierPayment>,
        returns: results[2] as List<SupplierReturn>,
      );
    } catch (e) {
      debugPrint('SupplierDetailNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  UPDATE
  // ─────────────────────────────────────────────────────────

  Future<bool> update(Supplier supplier) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await _service.update(supplier);
      if (updated == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث المورد',
        );
        return false;
      }
      state = state.copyWith(supplier: updated, isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierDetailNotifier.update error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث المورد',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  INVOICES
  // ─────────────────────────────────────────────────────────

  Future<bool> createInvoice(SupplierInvoice invoice) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final created = await _service.createInvoice(invoice);
      if (created == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل إنشاء الفاتورة',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierDetailNotifier.createInvoice error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل إنشاء الفاتورة',
      );
      return false;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.deleteInvoice(id);
      if (ok) await refresh();
      state = state.copyWith(isUpdating: false);
      return ok;
    } catch (e) {
      debugPrint('SupplierDetailNotifier.deleteInvoice error: $e');
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  PAYMENTS
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
      debugPrint('SupplierDetailNotifier.recordPayment error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تسجيل الدفعة',
      );
      return false;
    }
  }

  Future<bool> deletePayment(String id) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.deletePayment(id);
      if (ok) await refresh();
      state = state.copyWith(isUpdating: false);
      return ok;
    } catch (e) {
      debugPrint('SupplierDetailNotifier.deletePayment error: $e');
      state = state.copyWith(isUpdating: false);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  RETURNS
  // ─────────────────────────────────────────────────────────

  Future<bool> createReturn(SupplierReturn ret) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final created = await _service.createReturn(ret);
      if (created == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل إنشاء المرتجع',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierDetailNotifier.createReturn error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل إنشاء المرتجع',
      );
      return false;
    }
  }

  Future<bool> changeReturnStatus({
    required String returnId,
    required ReturnStatus newStatus,
    String? note,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final result = await _service.changeReturnStatus(
        returnId: returnId,
        newStatus: newStatus,
        note: note,
      );
      if (result == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث حالة المرتجع',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierDetailNotifier.changeReturnStatus error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث حالة المرتجع',
      );
      return false;
    }
  }

  Future<bool> deleteReturn(String id) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.deleteReturn(id);
      if (ok) await refresh();
      state = state.copyWith(isUpdating: false);
      return ok;
    } catch (e) {
      debugPrint('SupplierDetailNotifier.deleteReturn error: $e');
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

/// Family provider — كل مورد له notifier
final supplierDetailProvider = StateNotifierProvider.family<
    SupplierDetailNotifier, SupplierDetailState, String>((ref, id) {
  return SupplierDetailNotifier(ref, id);
});

/// اختصار: المورد
final supplierByIdProvider = Provider.family<Supplier?, String>((ref, id) {
  return ref.watch(supplierDetailProvider(id)).supplier;
});

/// اختصار: الفواتير
final supplierInvoicesProvider =
    Provider.family<List<SupplierInvoice>, String>((ref, id) {
  return ref.watch(supplierDetailProvider(id)).invoices;
});

/// اختصار: المدفوعات
final supplierPaymentsProvider =
    Provider.family<List<SupplierPayment>, String>((ref, id) {
  return ref.watch(supplierDetailProvider(id)).payments;
});

/// اختصار: المرتجعات
final supplierReturnsProvider =
    Provider.family<List<SupplierReturn>, String>((ref, id) {
  return ref.watch(supplierDetailProvider(id)).returns;
});

/// اختصار: هل التحميل جاري؟
final supplierDetailLoadingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(supplierDetailProvider(id)).isLoading;
});

/// اختصار: هل التحديث جاري؟
final supplierDetailUpdatingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(supplierDetailProvider(id)).isUpdating;
});

/// الفواتير المتأخرة
final supplierOverdueInvoicesProvider =
    Provider.family<List<SupplierInvoice>, String>((ref, id) {
  return ref.watch(supplierDetailProvider(id)).overdueInvoices;
});
